package Text::TabularDisplay;

# ----------------------------------------------------------------------
# $Id: Makefile.PL,v 1.3 2002/09/24 10:40:30 dlc Exp $
# ----------------------------------------------------------------------

use strict;
use vars qw($VERSION %PREREQ_PM %clean);

use ExtUtils::MakeMaker;
use File::Basename qw(basename);

$VERSION   = sprintf "%.02f", 0.37;
%PREREQ_PM = ('IO::File');
%clean     = ('FILES' => '$(DISTNAME)-$(VERSION).tar.gz');

WriteMakefile(
    NAME         => __PACKAGE__,
    VERSION_FROM => basename($0),
    PREREQ_PM    => \%PREREQ_PM,
    clean        => \%clean,
);

__END__
