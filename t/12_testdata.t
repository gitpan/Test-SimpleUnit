#!/usr/bin/perl
#
#		Test script for Test::SimpleUnit
#		$Id: 12_testdata.t,v 1.1 2003/01/15 20:46:44 deveiant Exp $
#
#		Before `make install' is performed this script should be runnable with
#		`make test'. After `make install' it should work as `perl 10_testdata.t'
#
#		Please do not commit any changes you make to the module without a
#		successful 'make test'!
#
package main;
use strict;

BEGIN	{ $| = 1; }

### Load up the test framework
use Test::SimpleUnit qw{:functions};

my (
	$filename,
	%testData,
   );


### Test suite (in the order they're run)
my @testSuite = (

  ### Setup/Teardown functions
	{
		name => 'setup',
		func => sub {
			$filename = "12testdata.$$";
			%testData = (
				some => 'data',
				for => "testing",
				complex => [qw{an arrayref }],
				hoh => {
					more	=> 'keys',
					and		=> 'vals',
					another	=> {},
				},
			   );
		},
	},

	{
		name => 'teardown',
		func => sub {
			$filename = '';
			%testData = ();
		},
	},


  ### Save the test data
	{
		name => 'savedata',
		test => sub {
			Test::SimpleUnit::Debug( 1 );
			assertNoException {
				saveTestData( $filename, %testData );
			};
			assert -f $filename;
		},
	},

  ### Load the test data back up and compare it with the original
	{
		name => 'loaddata',
		test => sub {
			my $datahash;

			Test::SimpleUnit::Debug( 1 );
			assertNoException {
				$datahash = loadTestData( $filename );
			};
			assertRef 'HASH', $datahash;
			assertEquals \%testData, $datahash;
		},
	},


);

runTests( @testSuite );

