#!/usr/bin/perl
#
#	Perl Makefile for Test::SimpleUnit
#	$Id: Makefile.PL,v 1.5 2003/01/15 20:47:17 deveiant Exp $
#
#	Invocation:
#		$ perl Makefile.PL                  # interactive behaviour
#		$ perl Makefile.PL --defaultdeps    # accept default value on prompts
#		$ perl Makefile.PL --checkdeps      # check only, no Makefile produced
#		$ perl Makefile.PL --skipdeps       # ignores all dependencies
#		$ perl Makefile.PL --testonly       # don't write installation targets
#
#	Then, to build:
#		$ make [all|test|install]           # install dependencies first
#		$ make checkdeps                    # same as the --checkdeps above
#		$ make installdeps                  # install dependencies only
#

# ExtUtils::AutoInstall Bootstrap Code, version 5.
BEGIN{my$p='ExtUtils::AutoInstall';my$v=0.40;eval"use $p $v;1
"or do{my$e=$ENV{PERL_EXTUTILS_AUTOINSTALL};(!defined($e)||$e
!~m/--(?:default|skip|testonly)/and-t STDIN or eval"use Ext".
"Utils::MakeMaker;WriteMakefile('PREREQ_PM'=>{'$p',$v});1"and
exit)and print"==> $p $v required. Install it from CPAN? [Y".
"/n] "and<STDIN>!~/^n/i and print"*** Installing $p\n"and do{
eval{require CPANPLUS;CPANPLUS::install $p};eval"use $p $v;1"
or eval{require CPAN;CPAN::install$p};eval"use $p $v;1"or die
"*** Please install $p $v manually from cpan.org first.\n"}}}

# the above handlers must be declared before the 'use' statement
use ExtUtils::AutoInstall (

	# required AutoInstall version
	-version        => '0.40',

	# core modules; may also be 'all'
	-core           => {
		Data::Compare	=> '0.02',
		Data::Dumper	=> '',
		Scalar::Util	=> '',
		Carp			=> '',
		IO::Handle		=> '',
		IO::File		=> '',
		Fcntl			=> '',
		constant		=> '',
	},

   );


WriteMakefile(
    NAME				=> 'Test::SimpleUnit',
	DISTNAME			=> 'Test-SimpleUnit',
    VERSION_FROM		=> 'lib/Test/SimpleUnit.pm', # finds $VERSION
	AUTHOR				=> 'Michael Granger <ged@FaerieMUD.org>',
	ABSTRACT			=> 'A simplified XUnit testing framework',
	dist					=> {
		CI						=> "cvs commit",
		RCS_LABEL				=> 'cvs tag RELEASE_$(VERSION_SYM)',
		SUFFIX					=> ".bz2",
		DIST_DEFAULT			=> 'all tardist',
		COMPRESS				=> "bzip2",
	},
	clean				=> { FILES => "*testdata*" },
);

