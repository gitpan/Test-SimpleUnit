#!/usr/bin/perl
#
#		Test script for Test::SimpleUnit
#		$Id: 06_skips.t,v 1.3 2002/04/15 19:54:35 deveiant Exp $
#
#		Before `make install' is performed this script should be runnable with
#		`make test'. After `make install' it should work as `perl 05_skip.t'
#
#		Please do not commit any changes you make to the module without a
#		successful 'make test'!
#
package main;
use strict;

BEGIN	{ $| = 1; }

### Load up the test framework
use Test::SimpleUnit qw{:functions};


### Test suite (in the order they're run)
my @testSuite = (

	{
		name => 'Autoskip setting',
		test => sub {
			# Backwards compat
			assertNoException { Test::SimpleUnit->AutoskipFailedSetup(1) };
			assert Test::SimpleUnit::AutoskipFailedSetup();

			assertNoException { Test::SimpleUnit::AutoskipFailedSetup(0) };
			assertNot Test::SimpleUnit::AutoskipFailedSetup();
		},
	},

	{
		name => 'Skip one (no message)',
		test => sub {
			eval { skipOne };
			assertInstanceOf 'SKIPONE', $@;
		},
	},

	{
		name => 'Skip one (with message)',
		test => sub {
			eval { skipOne "Testing" };
			assertInstanceOf 'SKIPONE', $@;
			assertEquals "Testing", ${$@};
		},
	},

	{
		name => 'Real skip one',
		test => sub {
			skipOne "Passed.";
			fail "Test wasn't skipped.";
		},
	},

	{
		name => 'Skip all (no message)',
		test => sub {
			eval { skipAll };
			assertInstanceOf 'SKIPALL', $@;
		},
	},

	{
		name => 'Skip all (with message)',
		test => sub {
			eval { skipAll "Testing" };
			assertInstanceOf 'SKIPALL', $@;
			assertEquals "Testing", ${$@};
		},
	},

	{
		name => 'Real skip all',
		test => sub {
			skipAll "Passed.";
			fail "Immediate test body wasn't skipped by skipAll.";
		},
	},

	{
		name => 'Should be skipped',
		test => sub {
			fail "Following test body wasn't skipped by skipAll.";
		},
	},


);

runTests( @testSuite );

