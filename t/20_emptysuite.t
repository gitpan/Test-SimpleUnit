#!/usr/bin/perl
#
#		Test script for Test::SimpleUnit
#		$Id: 20_emptysuite.t,v 1.1 2002/04/23 22:01:34 deveiant Exp $
#
#		Before `make install' is performed this script should be runnable with
#		`make test'. After `make install' it should work as `perl 08_emptysuite.t'
#
#		Please do not commit any changes you make to the module without a
#		successful 'make test'!
#
package main;
use strict;

BEGIN	{ $| = 1; }

### Load up the test framework
use Test::SimpleUnit qw{:functions};


### Test an empty test suite -- used to fail because the setup and teardown
### tests are spliced out. Should now just skip gracefully.
my @testSuite = (

	{
		name => 'setup',
		func => sub {
		},
	},

	{
		name => 'teardown',
		func => sub {
		},
	},

);

runTests( @testSuite );

