#!/usr/bin/perl
#
#		Test script for Test::SimpleUnit (import functions)
#		$Id: 05_asserts.t,v 1.4 2002/04/08 18:50:24 deveiant Exp $
#
#		Before `make install' is performed this script should be runnable with
#		`make test'. After `make install' it should work as `perl t/01_import.t'
#
#		Please do not commit any changes you make to the module without a
#		successful 'make test'!
#

# Packages for testing OO asserts
package ClassA;
sub new {return bless {}, $_[0]}

package ClassB;
use base qw{ClassA};

package ClassC;
use base qw{ClassB};

# Main testing package
package main;
use strict;

BEGIN	{ $| = 1; }

### Load up the test framework
use Test::SimpleUnit	qw{:asserts};

my @testSuite = (

	# Test the basic assert() function
	{
		name => 'Assert',
		test => sub {
			# Assert( true )
			eval { assert(1); };
			die "Failed assert(1): $@" if $@;

			# Assert( false )
			eval { assert(0); };
			die "assert(0) unexpectedly succeeded." unless $@;
			die "Unexpected error message for assert(0): $@ (expected '0')"
				unless "$@" =~ m{0};

			# Assert( false ) with message
			eval { assert(0, "message test") };
			die "assert(0,msg) unexpectedly succeeded." unless $@;
			die "Unexpected error message for assert(0): $@ (expected 'message test')"
				unless "$@" =~ m{message test};
		},
	},

	# Test assertNot()
	{
		name => 'AssertNot',
		test => sub {
			# assertNot( 0 )
			eval { assertNot(0); };
			die "Failed assertNot(0): $@" if $@;

			# assertNot( "" )
			eval { assertNot(""); };
			die "Failed assertNot(\"\"): $@" if $@;

			# assertNot( undef )
			eval { assertNot(undef); };
			die "Failed assertNot(undef): $@" if $@;

			# assertNot( 1 )
			eval { assertNot(1); };
			die "assertNot(1) unexpectedly succeeded." unless $@;
			die "Unexpected error message for assertNot(1): $@ (expected 'Expected a false value, got \"1\"')"
				unless "$@" =~ m{Expected a false value, got '1'};

			# AssertNot( false ) with message
			eval { assertNot(1, "message test") };
			die "assertNot(1,msg) unexpectedly succeeded." unless $@;
			die "Unexpected error message for assertNot(0): $@ (expected 'message test')"
				unless "$@" =~ m{message test};
		},
	},

	# Test assertDefined()
	{
		name => 'AssertDefined',
		test => sub {
			# assertDefined( 0 )
			eval { assertDefined(0); };
			die "Failed assertDefined(0): $@" if $@;

			# assertDefined( "" )
			eval { assertDefined(""); };
			die "Failed assertDefined(\"\"): $@" if $@;

			# assertDefined( undef )
			eval { assertDefined(undef); };
			die "assertDefined(undef) unexpectedly succeeded." unless $@;
			die "Unexpected error message for assertDefined(undef): $@ ",
				"(expected 'Expected a defined value, got an undef')"
				unless "$@" =~ m{Expected a defined value, got an undef};

			# AssertDefined( undef ) with message
			eval { assertDefined(undef, "message test") };
			die "assertDefined(undef,msg) unexpectedly succeeded." unless $@;
			die "Unexpected error message for assertDefined(undef,msg): $@ ",
				"(expected 'message test')"
				unless "$@" =~ m{message test};
		},
	},

	# Test assertUndef()
	{
		name => 'AssertUndef',
		test => sub {
			# assertUndef( undef )
			eval { assertUndef(undef); };
			die "Failed assertUndef(undef): $@" if $@;

			# assertUndef( undef )
			eval { assertUndef(1); };
			die "assertUndef(1) unexpectedly succeeded." unless $@;
			die "Unexpected error message for assertUndef(1): $@ ",
				"(expected 'Expected an undefined value, got '1'')"
				unless "$@" =~ m{Expected an undefined value, got '1'};

			# AssertUndef( undef ) with message
			eval { assertUndef(1, "message test") };
			die "assertUndef(1,msg) unexpectedly succeeded." unless $@;
			die "Unexpected error message for assertUndef(1,msg): $@ ",
				"(expected 'message test')"
				unless "$@" =~ m{message test};
		},
	},

	# Test assertException()
	{
		name => 'AssertException',
		test => sub {
			my $res;

			# assertException { die "test" }
			$res = eval { assertException {die "test"}; };
			die "Failed assertException {die \"test\"}: $@" if $@;
			assert( $res );
			undef $res;

			# assertException { 1 }
			eval { assertException {1} };
			die "assertException unexpectedly succeeded" unless $@;
			die "Unexpected error message for assertException {1}: $@ ",
				"(expected 'No exception raised.')"
				unless "$@" =~ m{No exception raised\.};

			# assertException { 1 }, $msg
			eval { assertException {1} "Ack! No exception?"; };
			die "assertException unexpectedly succeeded" unless $@;
			die "Unexpected error message for assertException {1}: $@ ",
				"(expected 'Ack! No exception?')"
				unless "$@" =~ m{Ack! No exception\?};
		},
	},

	# Test assertExceptionType()
	{
		name => 'AssertExceptionType',
		test => sub {

			# assertExceptionType { die "test" }
			eval { assertExceptionType {die bless ["test"], 'test'} 'test'; };
			die "Failed assertExceptionType {die bless [\"test\"], 'test'} 'test': $@" if $@;

			# assertExceptionType { 1 }
			eval { assertExceptionType {1} 'any' };
			die "assertExceptionType unexpectedly succeeded" unless $@;
			die "Unexpected error message for assertExceptionType {1} 'any': $@ ",
				"(expected 'Expected an exception of type 'any', but none was raised. at ",
				"blib/lib/Test/SimpleUnit.pm line...')"
				unless "$@" =~ m{Expected an exception of type 'any', but none was raised\.};

			# assertExceptionType { 1 }, $msg
			eval { assertExceptionType {1} 'any', "Ack! No exception?"; };
			die "assertExceptionType unexpectedly succeeded" unless $@;
			die "Unexpected error message for assertExceptionType {1} 'any', \"Ack! No exception?\": $@ ",
				"(expected 'Ack! No exception?')"
				unless "$@" =~ m{Ack! No exception\?};
		},
	},

	# Test assertExceptionMatch()
	{
		name => 'AssertExceptionMatches',
		test => sub {

			# Match a die()
			eval { assertExceptionMatches {die "Just testing"} qr{test}i; };
			die "Failed assertExceptionMatches {die \"Just testing\"} qr{test}i: $@" if $@;

			# assertExceptionMatches { 1 } 'any'
			eval { assertExceptionMatches {1} qr{any} };
			die "assertExceptionMatches unexpectedly succeeded" unless $@;
			die "Unexpected error message for assertExceptionMatches {1} qr{any}: $@ ",
				"(expected 'Expected an exception which matched /(?-xism:any)/, but none ",
				"was raised.')"
				unless "$@" =~ m{Expected an exception which matched \Q/(?-xism:any)/\E, but none was raised\.};

			# assertExceptionMatches { 1 } 'any', $msg
			eval { assertExceptionMatches {1} 'any', "Ack! No exception?"; };
			die "assertExceptionMatches unexpectedly succeeded" unless $@;
			die "Unexpected error message for assertExceptionMatches {1} 'any', \"Ack! No exception?\": $@ ",
				"(expected 'Ack! No exception?')"
				unless "$@" =~ m{Ack! No exception\?};
		},
	},

	# Test assertNoException()
	{
		name => 'AssertNoException',
		test => sub {
			my $res;
			my $file = __FILE__;
			my $line;

			# assertNoException { 1 }
			$res = eval { assertNoException {1}; };
			die "Failed assertNoException {1}: $@" if $@;
			assert( $res );
			undef $res;

			# assertNoException { die "test" }
			$line = __LINE__ + 1;
			eval { assertNoException {die "test"} };
			die "assertNoException unexpectedly succeeded" unless $@;
			die "Unexpected error message for assertNoException {die \"test\"}: $@ ",
				"(expected 'Exception raised: test at $file line $line')"
				unless "$@" =~ m{Exception raised: test at $file line $line};

			# assertNoException { die "test" }, $msg
			eval { assertNoException {die "test"} "Ack! Exception raised!"; };
			die "assertNoException unexpectedly succeeded" unless $@;
			die "Unexpected error message for assertNoException {die \"test\"}: $@ ",
				"(expected 'Ack! Exception raised!')"
				unless "$@" =~ m{Ack! Exception raised!};
		},
	},

	# Test assertEquals()
	{
		name => 'AssertEquals',
		test => sub {
			my $res;

			# assertEquals( 1, 1 )
			assertNoException { $res = assertEquals( 1, 1 ) };
			assert( $res );
			undef $res;

			# assertEquals( 1, "1" )
			assertNoException { $res = assertEquals( 1, "1" ) };
			assert( $res );
			undef $res;

			# assertEquals( "this", "this" )
			assertNoException { $res = assertEquals( "this", "this" ) };
			assert( $res );
			undef $res;

			# assertEquals( undef, undef )
			assertNoException { $res = assertEquals( undef, undef ) };
			assert( $res );
			undef $res;

			# assertEquals( 1, 2 )
			assertExceptionMatches { $res = assertEquals(1, 2) } qr{Wanted '1', got '2' instead};
			assertNot( $res );
			undef $res;

			# assertEquals( 1, 1.1 )
			assertExceptionMatches { $res = assertEquals(1, 1.1) } qr{Wanted '1', got '1.1' instead};
			assertNot( $res );
			undef $res;

		},
	},

	# Test assertMatches()
	{
		name => 'AssertMatches',
		test => sub {
			my $res;

			# assertMatches( '\d+', 1 )
			assertNoException { $res = assertMatches( '\d+', 1 ) };
			assert( $res );
			undef $res;

			# assertMatches( qr{\d+}, 1 )
			assertNoException { $res = assertMatches( qr{\d+}, 1 ) };
			assert( $res );
			undef $res;

			# assertMatches( qr{\s+}, " 1" )
			assertNoException { $res = assertMatches( qr{\s+}, " 1" ) };
			assert( $res );
			undef $res;

			# assertMatches( qr{\s+}, 1 )
			assertExceptionMatches {
				$res = assertMatches( qr{\s+}, 1 ) 
			} qr{Tested value '1' did not match wanted regex '\Q(?-xism:\s+)\E};
			assertNot( $res );
			undef $res;
		},
	},

	# Test assertRef()
	{
		name => 'AssertRef',
		test => sub {
			my $res;

			assertNoException { $res = assertRef('HASH', {}) };
			assert( $res );
			undef $res;

			assertNoException { $res = assertRef('GLOB', \*STDIN) };
			assert( $res );
			undef $res;

			assertNoException { $res = assertRef('ARRAY', []) };
			assert( $res );
			undef $res;

			assertNoException { $res = assertRef('SCALAR', \"something") };
			assert( $res );
			undef $res;

			assertNoException { $res = assertRef('ClassA', ClassA->new) };
			assert( $res );
			undef $res;

			assertException { $res = assertRef('HASH', 'something') };
			assertMatches( qr{Expected a HASH value, got a scalar}, $@ );
			assertNot( $res );
			undef $res;

			assertException { $res = assertRef('HASH', undef) };
			assertMatches( qr{Expected a HASH value, got a undefined value}, $@ );
			assertNot( $res );
			undef $res;

			assertException { $res = assertRef('HASH', []) };
			assertMatches( qr{Expected a HASH value, got a ARRAY}, $@ );
			assertNot( $res );
			undef $res;

			assertException { $res = assertRef('ClassA', []) };
			assertMatches( qr{Expected a ClassA value, got a ARRAY}, $@ );
			assertNot( $res );
			undef $res;

		},
	},


	# Test assertInstanceOf()
	{
		name => 'AssertInstanceOf',
		test => sub {
			my ( $res, $aInstance, $bInstance, $cInstance );

			$aInstance = ClassA->new;
			$bInstance = ClassB->new;
			$cInstance = ClassC->new;

			# aInstance should be only a ClassA object...
			assertException { assertInstanceOf('ClassB', $aInstance) };
			assertMatches qr{Expected an instance of 'ClassB', got an instance of 'ClassA'}, $@;
			assertException { assertInstanceOf('ClassC', $aInstance) };
			assertMatches qr{Expected an instance of 'ClassC', got an instance of 'ClassA'}, $@;
			assertNoException { assertInstanceOf('ClassA', $aInstance) };

			# bInstance should be only a ClassB object
			assertException { assertInstanceOf('ClassA', $bInstance) };
			assertMatches qr{Expected an instance of 'ClassA', got an instance of 'ClassB'}, $@;
			assertException { assertInstanceOf('ClassC', $bInstance) };
			assertMatches qr{Expected an instance of 'ClassC', got an instance of 'ClassB'}, $@;
			assertNoException { assertInstanceOf('ClassB', $bInstance) };

			# cInstance should be only a ClassC object
			assertException { assertInstanceOf('ClassA', $cInstance) };
			assertMatches qr{Expected an instance of 'ClassA', got an instance of 'ClassC'}, $@;
			assertException { assertInstanceOf('ClassB', $cInstance) };
			assertMatches qr{Expected an instance of 'ClassB', got an instance of 'ClassC'}, $@;
			assertNoException { assertInstanceOf('ClassC', $cInstance) };

			# A simple scalar shouldn't even make the ->isa() test
			assertException { assertInstanceOf('ClassA', "something") };
			assertMatches( qr{Expected an instance of 'ClassA', got a non-object \Q('something')\E}, $@ );

			# Neither should a plain (unblessed) reference
			assertException { assertInstanceOf('ClassA', []) };
			assertMatches( qr{Expected an instance of 'ClassA', got a non-object \('ARRAY\(0x\w+\)'\)}, $@ );

		},
	},

	# Test assertKindOf()
	{
		name => 'AssertKindOf',
		test => sub {
			my ( $res, $aInstance, $bInstance, $cInstance );

			$aInstance = ClassA->new;
			$bInstance = ClassB->new;
			$cInstance = ClassC->new;

			# aInstance should be an ClassA object...
			assertNoException { $res = assertKindOf('ClassA', $aInstance) };
			assert( $res );
			undef $res;

			# bInstance should be both a ClassA and a ClassB object
			assertNoException { $res = assertKindOf('ClassA', $bInstance) };
			assert( $res );
			undef $res;

			assertNoException { $res = assertKindOf('ClassB', $bInstance) };
			assert( $res );
			undef $res;

			# cInstance should be all three
			assertNoException { $res = assertKindOf('ClassA', $cInstance) };
			assert( $res );
			undef $res;

			assertNoException { $res = assertKindOf('ClassB', $cInstance) };
			assert( $res );
			undef $res;

			assertNoException { $res = assertKindOf('ClassC', $cInstance) };
			assert( $res );
			undef $res;

			# But aInstance should be neither a B nor a C
			assertException { $res = assertKindOf('ClassB', $aInstance) };
			assertMatches( qr{Expected an instance of 'ClassB' or a subclass, got an instance of 'ClassA'}, $@ );
			assertNot( $res );
			undef $res;

			assertException { $res = assertKindOf('ClassC', $aInstance) };
			assertMatches( qr{Expected an instance of 'ClassC' or a subclass, got an instance of 'ClassA'}, $@ );
			assertNot( $res );
			undef $res;

			# Neither should bInstance be a C
			assertException { $res = assertKindOf('ClassC', $bInstance) };
			assertMatches( qr{Expected an instance of 'ClassC' or a subclass, got an instance of 'ClassB'}, $@ );
			assertNot( $res );
			undef $res;

			# A simple scalar shouldn't even make the ->isa() test
			assertException { $res = assertKindOf('ClassA', "something") };
			assertMatches( qr{Expected an instance of 'ClassA' or a subclass, got a non-object \Q('something')\E}, $@ );
			assertNot( $res );
			undef $res;

			# Neither should a plain (unblessed) reference
			assertException { $res = assertKindOf('ClassA', []) };
			assertMatches( qr{Expected an instance of 'ClassA' or a subclass, got a non-object \('ARRAY\(0x\w+\)'\)}, $@ );
			assertNot( $res );
			undef $res;

		},
	},
);

Test::SimpleUnit::runTests( @testSuite );


