#!/usr/bin/perl
#
#		Test script for Test::SimpleUnit (require)
#		$Id: 00_require.t,v 1.2 2002/03/29 23:41:49 deveiant Exp $
#
#		Before `make install' is performed this script should be runnable with
#		`make test'. After `make install' it should work as `perl test.pl'
#
#		Please do not commit any changes you make to the module without a
#		successful 'make test'!
#
package main;
use strict;

BEGIN	{ $| = 1; use vars qw{$LoadedOkay} }
END		{ print "1..1\nnot ok 1\n" unless $LoadedOkay; }

### Load up the test framework
require Test::SimpleUnit;

### Test suite (in the order they're run)
my @testSuite = (
	{
		name => 'Require',
		test => sub {
			$LoadedOkay = 1;
		},
	},

);

Test::SimpleUnit::runTests( @testSuite );


