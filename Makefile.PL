#!/usr/bin/perl
#
#	Perl Makefile for Test::SimpleUnit
#	$Id: Makefile.PL,v 1.4 2002/05/14 03:02:03 deveiant Exp $
#
#	Invoke with 'perl Makefile.PL'
#
#	See ExtUtils::MakeMaker (3) for more information on how to influence
#	 the contents of the Makefile that is written
#

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME					=> 'Test-SimpleUnit',
    VERSION_FROM			=> 'lib/Test/SimpleUnit.pm', # finds $VERSION
	AUTHOR					=> 'Michael Granger <ged@FaerieMUD.org>',
	ABSTRACT				=> 'A simplified XUnit testing framework',
	PREREQ_PM				=> {
		Scalar::Util	=> 0,
		Carp			=> 0,
		IO::Handle		=> 0,
		Data::Dumper	=> 0,
		constant		=> 0,
	},
	dist					=> {
		CI						=> "cvs commit",
		RCS_LABEL				=> 'cvs tag RELEASE_$(VERSION_SYM)',
		SUFFIX					=> ".bz2",
		DIST_DEFAULT			=> 'all tardist',
		COMPRESS				=> "bzip2",
	},
);

