package Text::TabularDisplay;

# -------------------------------------------------------------------
# $Id: TabularDisplay.pm,v 1.8 2002/09/24 10:39:34 dlc Exp $
# -------------------------------------------------------------------
# Text::TabularDisplay - Display text in formatted table output
# Copyright (C) 2002 darren chamberlain <darren@cpan.org>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307  USA
# -------------------------------------------------------------------

use strict;
use vars qw($VERSION);
use overload '""' => "render";

sub Version {
    $VERSION = 0.37;
}

# ---======================= Public Methods ======================---

# -------------------------------------------------------------------
# new([@columns])
#
# Instantiate a new Text::TabularDisplay instance.  Optionally takes
# column names, which are passed to the columns method.
# -------------------------------------------------------------------
sub new {
    my $class = shift;
    return $class->clone
        if ref $class && UNIVERSAL::isa($class, __PACKAGE__);

    my $self = bless {
        _COLUMNS => [ ],
        _DATA    => [ ],
        _LENGTHS => [ ],
    } => $class;

    $self->columns(@_) if (@_);

    return $self;
}

# -------------------------------------------------------------------
# clone
#
# Clones a Text::TabluarDisplay instance.
# -------------------------------------------------------------------
sub clone {
    my $self = shift;
    my $class = ref $self || return $self->new;
    my $clone = $class->new($self->columns);

    for (@{ $self->{ _DATA } }) {
        $clone->add(@$_);
    }

    return $clone;
}

# -------------------------------------------------------------------
# columns([@columns])
#
# Passing in columns clears out the instance.  Returns a list of
# column names in list context, but returns the number of columns in
# scalar context.
# -------------------------------------------------------------------
sub columns {
    my $self = shift;
    my @columns;

    if (@_) {
        _add($self->{ _COLUMNS }, $self->{ _LENGTHS }, [ @_ ]);
    }
    @columns = @{ $self->{ _COLUMNS }->[0] || [ ]};

    return wantarray ? @columns : scalar @columns;
}

# -------------------------------------------------------------------
# add(@data)
#
# Adds a row to the instance.  Returns $self, for chaining:
#   $self->add(@one)->add(@two)->add(@three);
# -------------------------------------------------------------------
sub add {
    my $self = shift;
    my $add = UNIVERSAL::isa($_[0], 'ARRAY') ? shift : [ @_ ];

    if (@$add) {
        _add($self->{ _DATA }, $self->{ _LENGTHS }, $add);
    }

    return $self;
}

# -------------------------------------------------------------------
# render([$start, $end])
#
# Returns the data formatted as a table.  By default, all rows are
# returned; if $start or $end are specified, then only those indexes
# are returned.  Those are the start and end indexes!
# -------------------------------------------------------------------
sub render {
    my $self = shift;
    my $start = shift || 0;
    my $end = shift || $#{ $self->{ _DATA } };
    my ($bar, $datum, @text);
    $bar = join "+", "",
                     map( { "-" x ($_ + 2) } @{ $self->{ _LENGTHS } }),
                     "";

    push @text, $bar;
    if ($self->columns) {
        push @text, _format_line([ $self->columns ], $self->{ _LENGTHS });
        push @text, $bar;
    }

    for (my $i = $start; $i <= $end; $i++) {
        $datum = $self->{ _DATA }->[$i];
        last unless defined $datum;
        push @text, _format_line($datum, $self->{ _LENGTHS });
    }

    push @text, $bar;
    return join "\n", @text;
}

# ----------------------------------------------------------------------
# reset()
#
# Resets the instance.
# ----------------------------------------------------------------------
sub reset {
    my $self = shift;

    @{ $self->{ _COLUMNS } } = ();
    @{ $self->{ _LENGTHS } } = ();
    @{ $self->{ _DATA    } } = ();

    $self->columns(@_) if (@_);

    return $self;
}

# ----------------------------------------------------------------------
# populate(\@data)
#
# populate() takes a reference to an array of references to arrays,
# and calls add() repeatedly.  Primarily for use with DBI's
# selectall_arrayref() method.
# ----------------------------------------------------------------------
sub populate {
    my $self = shift;
    (@_) or return $self;
    my $data = UNIVERSAL::isa($_[0], 'ARRAY') ? shift : [ @_ ];

    while (defined (my $datum = shift @$data)) {
        $self->add($datum);
    }

    return $self;
}

# ---====================== Private Methods ======================---


# -------------------------------------------------------------------
# _add(\@where, \@lengths, \@add)
#
# Adds @add to @where and modifies @lengths, as necessary
# -------------------------------------------------------------------
sub _add {
    my ($where, $length, $add) = @_;
    my @data;

    for (my $i = 0; $i <= $#$add; $i++) {
        my $l = length $add->[$i];
        push @data, $add->[$i];
        $length->[$i] = $l
            unless $length->[$i] > $l;
    }
    push @$where, \@data;
}


# -------------------------------------------------------------------
# _format_line(\@columns, \@lengths)
#
# Returns a formatted line out of @columns; the size of $column[$i]
# is determined by $length[$i].
# -------------------------------------------------------------------
sub _format_line {
    my ($columns, $lengths) = @_;
    my @line;

    #return unless @$columns == @$length;
    for (my $i = 0; $i <= $#$columns; $i++) {
        push @line, sprintf " %-" . $lengths->[$i] . "s ", $columns->[$i];
    }

    return join '|', "", @line, "";
}

BEGIN { Version }

1;

__END__

=head1 NAME

Text::TabularDisplay - Display text in formatted table output

=head1 SYNOPSIS

    use Text::TabularDisplay;

    my $table = Text::TabularDisplay->new(@columns);
    $table->add(@row)
        while (@row = $sth->fetchrow);
    print $table->render;

    +----+-----------+
    | id | name      |
    +----+-----------+
    | 1  | Tom       |
    | 2  | Dick      |
    | 3  | Harry     |
    +----+-----------+


=head1 DESCRIPTION

Text::TabularDisplay simplifies displaying data in a table.  The
output is identical to the columnar display of query results in the
mysql text monitor.  For example, this data:

    1, "Tom Jones", "(666) 555-1212"
    2, "Barnaby Jones", "(666) 555-1213"
    3, "Bridget Jones", "(666) 555-1214"

Used like so:

    my $t = Text::TabularDisplay->new(qw(id name phone));
    $t->add(1, "Tom Jones", "(666) 555-1212");
    $t->add(2, "Barnaby Jones", "(666) 555-1213");
    $t->add(3, "Bridget Jones", "(666) 555-1214");
    print $t->render;

Produces:

    +----+---------------+----------------+
    | id | name          | phone          |
    +----+---------------+----------------+
    | 1  | Tom Jones     | (666) 555-1212 |
    | 2  | Barnaby Jones | (666) 555-1213 |
    | 3  | Bridget Jones | (666) 555-1214 |
    +----+---------------+----------------+


=head1 METHODS

Text::TabularDisplay has four primary methods: new(), columns(),
add(), and render().  new() creates a new Text::TabularDisplay
instance; columns() sets the expected columns in the output table;
add() adds data to the instance; and render() returns a formatted
string representation of the instance.

There are also a few auxilliary convenience methods: clone(), reset(),
and populate().

=over

=item B<new>

A Text::TabularDisplay instance can be created with column names
passed as constructor args, so these two calls produce similar
objects:

    my $t1 = Text::TabularDisplay->new;
    $t1->columns(qw< one two >);

    my $t2 = Text::TabularDisplay->new(qw< one two >);

Calling new() on a Text::TabularDisplay instance returns a clone of
the object.  See L<Text::TabularDisplay/clone>.

=item B<columns>

Gets or sets the column names for an instance.  This method is called
automatically by the constructor with any parameters that are passed
to the constructor.

When called in scalar context, columns() returns the I<number of
columns in the instance>, rather than the columns themselves.  Note
that in list context, copies of the columns names are returned; the
names of the columns cannot be set this way.

=item B<add>

Takes a list of items and adds them as the next column of data to be
displayed.  Can also take a reference to an array, so that large
arrays don't need to be copied.

As elements are processed, add() maintains the width of each column
so that the resulting table has the correct dimensions.

add() returns $self, so that calls to add() can be chained:

    $t->add(@one)->add(@two)->add(@three);

=item B<render>

render() does most of the actual work. It returns a string containing
the data added via add(), formatted as a table, with a header
containing the column names.

render() does not change the state of the object; it can be called
multiple times, with identical output (including identical running
time: the output of render is not cached).

If there are no columns defined, then the output table does not
contains a row of column names.  Compare these two sequences:

    my $t = Text::TabularDisplay->new;
    $t->add(qw< 1 2 3 4 >);
    $t->add(qw< 5 6 7 8 >);
    print $t->render;

    $t->columns(qw< one two three four >);
    print $t->render;

    # Example 1 output
    +---+---+---+---+
    | 1 | 2 | 3 | 4 |
    | 5 | 6 | 7 | 8 |
    +---+---+---+---+

    # Example 2 output
    +-----+-----+-------+------+
    | one | two | three | four |
    +-----+-----+-------+------+
    | 1   | 2   | 3     | 4    |
    | 5   | 6   | 7     | 8    |
    +-----+-----+-------+------+

render() takes optional $start and $end arguments; these indicate the
start and end I<indexes> for the data to be rendered.  This can be
used for paging and the like:

    $t->add(1, 2, 3)->add(4, 5, 6)->add(7, 8, 9)->add(10, 11, 12);
    print $t->render(0, 1), "\n";
    print $t->render(2, 3), "\n";

Produces:

    +-------+--------+-------+
    | First | Second | Third |
    +-------+--------+-------+
    | 1     | 2      | 3     |
    | 4     | 5      | 6     |
    +-------+--------+-------+

    +-------+--------+-------+
    | First | Second | Third |
    +-------+--------+-------+
    | 7     | 8      | 9     |
    | 10    | 11     | 12    |
    +-------+--------+-------+

As an aside, note the chaining of calls to add().

=back

=head1 OTHER METHODS

=over 4

=item clone()

The clone() method returns an identical copy of a Text::TabularDisplay
instance, completely separate from the cloned instance.

=item reset()

Reset deletes the data from the instance, including columns.  If
passed arguments, it passes them to columns(), just like new().

=item populate()

populate() as a special case of add(); populate() expects a reference
to an array of references to arrays, such as returned by DBI's
selectall_arrayref method:

    $sql = "SELECT " . join(", ", @c) . " FROM mytable";
    $t->columns(@c);
    $t->add($dbh->selectall_arrayref($sql));

This is for convenience only; the implementation maps this to multiple
calls to add().

=back

=head1 NOTES / ISSUES

Text::TabularDisplay assumes it is handling strings, and does stringy
things with the data, like legnth() and sprintf().  Non-character data
can be passed in, of course, but will be treated as strings; this may
have ramifications for objects that implement overloading.

Newlines contained within the data ruin formatting.  This is
consistent with the software that this module is emulating (the mysql
command line client), but only because this was easier to implement.

Currently, this:

    my $t = Text::TabularDisplay->new("id", "text");
    $t->add(1, "This is my text.\nThere are many like it, but this one is mine.");
    print $t->render;

renders as this:

    +----+----------------------------------------------------------------+
    | id | text
    |
    +----+----------------------------------------------------------------+
    | 1  | This is my text.
    There are many like it, but this one is mine. |
    +----+----------------------------------------------------------------+

I would like it to render like so:

    +----+----------------------------------------------------------------+
    | id | text                                                           |
    +----+----------------------------------------------------------------+
    | 1  | This is my text.                                               |
    |    | There are many like it, but this one is mine.                  |
    +----+----------------------------------------------------------------+

Patches welcome, of course. ;)

The biggest issue, though, is that this module duplicates a some of the
functionality of Data::ShowTable.  Of course, Data::ShowTable is a
large, complex monolithic tool that does a lot of things, while
Text::TabularDisplay is small and fast.

=head1 VERSION

$Id: TabularDisplay.pm,v 1.8 2002/09/24 10:39:34 dlc Exp $

=head1 AUTHOR

darren chamberlain E<lt>darren@cpan.orgE<gt>
