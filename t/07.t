#!/usr/bin/perl
# vim: set ft=perl:
# $Id: 07.t,v 1.2 2002/09/23 10:26:34 dlc Exp $

use strict;
use Text::TabularDisplay;
use Test;

BEGIN {
    plan tests => 5;
}

ok(my $t = Text::TabularDisplay->new);
ok($t->add("Joe Shmoe", "red", "9 1/2"));
ok($t->add("Bob Smith", "chartreuse", "11"));
ok($t->add("Jumpin' Jack Flash", "yellow", "12"));
ok($t->render, 
"+--------------------+------------+-------+
| Joe Shmoe          | red        | 9 1/2 |
| Bob Smith          | chartreuse | 11    |
| Jumpin' Jack Flash | yellow     | 12    |
+--------------------+------------+-------+");

