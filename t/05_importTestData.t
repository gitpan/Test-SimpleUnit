#!/usr/bin/perl
#
#		Test script for Test::SimpleUnit
#		$Id: 05_importTestData.t,v 1.1 2003/01/15 20:46:44 deveiant Exp $
#
#		Before `make install' is performed this script should be runnable with
#		`make test'. After `make install' it should work as `perl 05_importTestData.t'
#
#		Please do not commit any changes you make to the module without a
#		successful 'make test'!
#
package main;
use strict;

BEGIN	{ $| = 1; }

### Load up the test framework
use Test::SimpleUnit	qw{:testdata};

sub genTest {
	my $functionName = shift;
	return {
		name => $functionName,
		test => sub {
			no strict 'refs';
			die "$functionName() was not imported" unless defined *{"main::${functionName}"}{CODE};
		},
	};
}

### Generate a test suite out of the list of exported functions for the
### 'functions' tag
my @testSuite = map { s{^&}{}; genTest $_ } @{$Test::SimpleUnit::EXPORT_TAGS{testdata}};
Test::SimpleUnit::runTests( @testSuite );


