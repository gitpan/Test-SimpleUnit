#!/usr/bin/perl
#
#		Test script for Test::SimpleUnit
#		$Id: 07_setupteardown.t,v 1.2 2002/03/29 23:41:49 deveiant Exp $
#
#		Before `make install' is performed this script should be runnable with
#		`make test'. After `make install' it should work as `perl 07_setupteardown.t'
#
#		Please do not commit any changes you make to the module without a
#		successful 'make test'!
#
package main;
use strict;

BEGIN	{ $| = 1; }

### Load up the test framework
use Test::SimpleUnit qw{:functions};

my $ranSetup = 0;
my $ranTeardown = 0;


### Test suite (in the order they're run)
my @testSuite = (

	{
		name => 'setup',
		test => sub {
			$ranSetup = 1;
		},
	},

	{
		name => 'setup test',
		test => sub {
			assert $ranSetup;
		},
	},

	{
		name => 'teardown',
		test => sub {
			$ranTeardown = 1;
		},
	},

	{
		name => 'teardown test',
		test => sub {
			assert $ranTeardown;
		},
	},

);

runTests( @testSuite );

