#!/usr/bin/perl
# vim: set ft=perl:
# $Id: 03.t,v 1.3 2002/09/23 22:08:02 dlc Exp $
# Yes, this is the same test file (almost) as 01.t, but
# this one tests resetting the object, and there needs to
# be an object with data in order to test resetting it.

use strict;
use Text::TabularDisplay;
use Test;

BEGIN {
    plan tests => 6;
}

my @data = (
    [ qw(id name phone) ],
    [ 1, "Tom Jones",     "(666) 555-1212" ],
    [ 2, "Barnaby Jones", "(666) 555-1212" ],
    [ 3, "Bridget Jones", "(666) 555-1212" ],
    [ 4, "Quincy Jones",  "(666) 555-1212" ],
);

my $t;

ok(1); # loaded...

$t = Text::TabularDisplay->new;

ok(2); # instantiated...

my @columns = @{ shift @data };
$t->columns(@columns);

ok(scalar @columns, scalar $t->columns); # columns gets/sets correctly

for (@data) {
    $t->add(@$_);
}

# How's this for an ugly test?
ok($t->render,
"+----+---------------+----------------+
| id | name          | phone          |
+----+---------------+----------------+
| 1  | Tom Jones     | (666) 555-1212 |
| 2  | Barnaby Jones | (666) 555-1212 |
| 3  | Bridget Jones | (666) 555-1212 |
| 4  | Quincy Jones  | (666) 555-1212 |
+----+---------------+----------------+");

# Reset instance
$t->reset(@columns);

# Ensure that new columns resets instance
ok($t->render,
"+----+------+-------+
| id | name | phone |
+----+------+-------+
+----+------+-------+");

for (@data) {
    $t->add(@$_);
}

# ...And repeat the ugly test, to ensure that a re-instanted
# object renders the same way.
ok($t->render,
"+----+---------------+----------------+
| id | name          | phone          |
+----+---------------+----------------+
| 1  | Tom Jones     | (666) 555-1212 |
| 2  | Barnaby Jones | (666) 555-1212 |
| 3  | Bridget Jones | (666) 555-1212 |
| 4  | Quincy Jones  | (666) 555-1212 |
+----+---------------+----------------+");
