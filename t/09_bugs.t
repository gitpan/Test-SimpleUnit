#!/usr/bin/perl
#
#		Test script for fixed bugs that don't need their own suite
#		$Id: 09_bugs.t,v 1.1 2002/05/14 02:59:02 deveiant Exp $
#
#		Before `make install' is performed this script should be runnable with
#		`make test'. After `make install' it should work as `perl 09_bugs.t'
#
#		Please do not commit any changes you make to the module without a
#		successful 'make test'!
#
package main;
use strict;

BEGIN	{ $| = 1; }

### Load up the test framework
use Test::SimpleUnit qw{:functions};
use IO::Handle;
use IO::File;

#$Test::SimpleUnit::Debug = 1;

# Get a reference to stdout so we can switch it off for recursive tests
my $Stdout = IO::Handle->new_from_fd( fileno STDOUT, 'w' )
	or die "Ack: STDOUT doesn't exist";
my $DummyIO = new IO::File '/dev/null', 'w';

### Test suite (in the order they're run)
my @testSuite = (

	# Can't use string ("") as a subroutine ref while "strict refs" in use at
	# /usr/lib/perl5/site_perl/5.6.1/Test/SimpleUnit.pm line 665.
	{
		name => 'Missing "test" key-val pair',
		test => sub {
			assertNoException {
				Test::SimpleUnit::OutputHandle( $DummyIO );
				runTests({ name => 'subtest' });
				Test::SimpleUnit::OutputHandle();
			};
		},
	},

	# Error related to the above one: Test isn't a coderef.
	{
		name => 'non-coderef value in "test" key-val pair',
		test => sub {
			assertNoException {
				Test::SimpleUnit::OutputHandle( $DummyIO );
				runTests({ name => 'subtest', test => {} });
				Test::SimpleUnit::OutputHandle();
			};
		},
	},

);

runTests( @testSuite );

