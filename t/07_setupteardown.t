#!/usr/bin/perl
#
#		Test script for Test::SimpleUnit
#		$Id: 07_setupteardown.t,v 1.3 2002/04/25 20:53:27 deveiant Exp $
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

#Test::SimpleUnit::Debug( 1 );

my %setupRuns = ();
my %teardownRuns = ();


### Test suite (in the order they're run)
my @testSuite = (

  ### Plain setup

	# First setup function
	{
		name => 'setup',
		func => sub {
			$setupRuns{first}++;
		},
	},

	# Test to make sure the setup ran
	{
		name => 'test first setup',
		test => sub {
			assertEquals 1, $setupRuns{first};
		},
	},

  ### Overridden setup

	# Override the first setup with this, the second one
	{
		name => 'setup',
		test => sub {
			$setupRuns{second}++;
		},
	},

	# Test to be sure the two setup functions have run exactly once each
	{
		name => 'test second setup',
		test => sub {
			assertEquals 1, $setupRuns{first};
			assertEquals 1, $setupRuns{second};
		},
	},

	# Test to be sure the first setup has still only run once, but that the
	# second has now run twice
	{
		name => 'test second setup again',
		test => sub {
			assertEquals 1, $setupRuns{first};
			assertEquals 2, $setupRuns{second};
		},
	},


  ### Ignored setup collision

	# Override the second setup with this, the third one, but then clobber this
	# one with a fourth. This one should never be run.
	{
		name => 'setup',
		test => sub {
			$setupRuns{third}++;
		},
	},

	# Override the third setup with this, the fourth one.
	{
		name => 'setup',
		test => sub {
			$setupRuns{fourth}++;
		},
	},

	# Test to be sure the first has now run once, the second twice, the third no
	# times, and the fourth one once.
	{
		name => 'test third and fourth setup',
		test => sub {
			assertEquals 1, $setupRuns{first};
			assertEquals 2, $setupRuns{second};
			assertNot exists $setupRuns{third};
			assertEquals 1, $setupRuns{fourth};
		},
	},


  ### Now do the same thing for teardown functions

	# First teardown function
	{
		name => 'teardown',
		func => sub {
			$teardownRuns{first}++;
		},
	},

	# Test to make sure the teardown hasn't yet run, but will in the second test.
	{
		name => 'test first teardown (pre-run)',
		test => sub {
			assertNot exists $teardownRuns{first};
		},
	},

	# Test to make sure the teardown hasn't yet run, but will in the second test.
	{
		name => 'test first teardown (post-run)',
		test => sub {
			assertEquals 1, $teardownRuns{first};
		},
	},


  ### Overridden teardown

	# Override the first teardown with this, the second one
	{
		name => 'teardown',
		test => sub {
			$teardownRuns{second}++;
		},
	},

	# Test the second teardown, pre-run
	{
		name => 'test second teardown',
		test => sub {
			assertEquals 2, $teardownRuns{first};
			assertNot exists $teardownRuns{second};
		},
	},

	# Test the second teardown, post-run
	{
		name => 'test second teardown',
		test => sub {
			assertEquals 2, $teardownRuns{first};
			assertEquals 1, $teardownRuns{second};
		},
	},



  ### Ignored teardown collision

	# Override the second teardown with this, the third one, but then clobber this
	# one with a fourth. This one should never be run.
	{
		name => 'teardown',
		test => sub {
			$teardownRuns{third}++;
		},
	},

	# Override the third teardown with this, the fourth one.
	{
		name => 'teardown',
		test => sub {
			$teardownRuns{fourth}++;
		},
	},

	# Bogus test for the third and fourth teardown, pre-run
	{
		name => 'test third and fourth teardown (pre-run)',
		test => sub { 1 },
	},

	# Test to be sure the first has now run once, the second twice, the third no
	# times, and the fourth one once.
	{
		name => 'test third and fourth teardown',
		test => sub {
			assertEquals 2, $teardownRuns{first};
			assertEquals 2, $teardownRuns{second};
			assertNot exists $teardownRuns{third};
			assertEquals 1, $teardownRuns{fourth};
		},
	},

);

runTests( @testSuite );

