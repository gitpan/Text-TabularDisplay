#!/usr/bin/perl
# vim: set ft=perl:
# $Id: 14.t,v 1.1 2002/10/24 21:40:26 dlc Exp $

use strict;
use Text::TabularDisplay;
use Test;

BEGIN {
    plan tests => 4;
}

my @data = (
    [ "Joe Shmoe", "red", "9 1/2" ],
    [ qw(foo bar baz) ],
    [ "Bob Smith", "chartreuse", "11" ],
    [ qw(foo bar baz) ],
    [ "Jumpin' Jack Flash", "yellow", "12" ],
    [ qw(foo bar baz) ],
    [ "Joe Shmoe", "red", "9 1/2" ],
    [ qw(foo bar baz) ],
    [ "Bob Smith", "chartreuse", "11" ],
    [ qw(foo bar baz) ],
    [ "Jumpin' Jack Flash", "yellow", "12" ],
    [ qw(foo bar baz) ],
);

ok(my $t = Text::TabularDisplay->new("name", "favorite color", "shoe size"));
ok($t->populate([ @data ]));
ok($t->items, scalar @data);
ok($t->render, "+--------------------+----------------+-----------+
| name               | favorite color | shoe size |
+--------------------+----------------+-----------+
| Joe Shmoe          | red            | 9 1/2     |
| foo                | bar            | baz       |
| Bob Smith          | chartreuse     | 11        |
| foo                | bar            | baz       |
| Jumpin' Jack Flash | yellow         | 12        |
| foo                | bar            | baz       |
| Joe Shmoe          | red            | 9 1/2     |
| foo                | bar            | baz       |
| Bob Smith          | chartreuse     | 11        |
| foo                | bar            | baz       |
| Jumpin' Jack Flash | yellow         | 12        |
| foo                | bar            | baz       |
+--------------------+----------------+-----------+");
