#!/usr/bin/perl

# ----------------------------------------------------------------------
# $Id: mysql.pl,v 1.1 2002/09/24 02:44:01 dlc Exp $
# ----------------------------------------------------------------------
# Example usage of Text::TabularDisplay to implement a low-functionality
# version of the mysql text monitor.
# ----------------------------------------------------------------------

use strict;
use vars qw(%opts);

use Carp qw(carp);
use DBI;
use File::Basename qw(basename);
use Getopt::Long;
use Term::ReadLine;
use Text::TabularDisplay;

$0 = basename $0;

GetOptions(\%opts,
    "username|u=s",
    "password|p=s",
    "host|h=s",
    "help!");

$opts{'host'} ||= "localhost";
if (defined $opts{'help'}) {
    print STDERR "$0 - mysql command line client emulation\n",
                 "Usage: $0 [OPTIONS] DB_NAME\n\n",
                 "OPTIONS include:\n",
                 "\t--username=\$username\tUsername to connect as\n",
                 "\t--password=\$password\tPassword for \$username\n",
                 "\t--host=\$host\t\tHost on which DB_NAME can be found\n",
                 "\thelp\t\t\tYou're reading it.\n\n";
    exit(1);
}

my $db = shift(@ARGV) or die "$0: Must supply a database name!";

# Create the Text::TabularDisplay and Term::ReadLine instances, and
# make the database connection.
my $table = Text::TabularDisplay->new;
my $term = Term::ReadLine->new("mysql");
my $dbh = DBI->connect("dbi:mysql:database=$db;host=$opts{'host'}",
                        $opts{'username'}, $opts{'password'})
    or die "Can't connect to $db on $opts{'host'}: $DBI::errstr";


while (defined (my $line = $term->readline("mysql> "))) {
    #$term->AddHistory($line);
    my $sth;

    if ($line =~ /^\s*(quit|exit)/) {
        last;
    }

    unless ($sth = $dbh->prepare($line)) {
        carp "Can't prepare line: " . $dbh->errstr;
        next;
    }

    # Reset the table
    $table->reset;

    unless ($sth->execute) {
        carp "Can't execute query: " . $sth->errstr;
        next;
    }

    # Set the columns
    my $names = $sth->{'NAME'};
    $table->columns(@$names);

    while (my $row = $sth->fetchrow_arrayref) {
        # Add data to the table
        $table->add($row);
    }
    $sth->finish;

    # Print the final version of the table
    # Note that without the trailing \n, the last line is buffered,
    # which is pretty ugly...
    printf "%s\n", $table->render;
}

print "Bye!\n";
exit(0);
