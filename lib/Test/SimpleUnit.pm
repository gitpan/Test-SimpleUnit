#!/usr/bin/perl
##############################################################################

=head1 NAME

Test::SimpleUnit - Simplified XUnit-style testing framework for Perl classes

=head1 SYNOPSIS

  use Test::SimpleUnit qw{:functions};

  Test::SimpleUnit::AutoskipFailedSetup( 1 );

  my $testThing;

  my @testSuite = (

	# Setup function
	{
		name => 'setup',
		func => sub { $testThing = new Thing },
	},

	# Teardown function
	{
		name => 'teardown',
		func => sub { undef $testThing },
	},

	# Test 1
	{
		name => 'test1',
		test => sub { assertEquals 'something', somefunc() },
	}
  );

  runTests( @testSuite );

=head1 DESCRIPTION

This is a simplified XUnit-style test framework for creating unit tests to be
run either standalone or under Test::Harness.

Tests in Test::SimpleUnit consist of one or more test suites, each of which has
one or more test cases, and setup/teardown functions.

A test suite is an array of test cases which are run, in order, by passing the
array to the L<runTests()|/"runTests"> function. You may wish to split test suites up into
separate files under a C<t/> directory so they will run under a
L<Test::Harness|Test::Harness>-style C<make test>.

A test case is a hashref which contains two key-value pairs: a I<name> key with
the name of the test case as the value, and a code reference value under a
I<test> key. If a test case has the name 'setup' or 'teardown', it is added to a
list of functions to be run before or after each test case, respectively. The
code reference value within a I<setup> or I<teardown> test case can optionally
be named C<func> instead of C<test> for clarity. If there are both C<func> and
C<test> key-value pairs in a I<setup> or I<teardown> case, the C<test> pair is
silently ignored.

Each test case's test function can make one or more assertions by using the
L<Assertion Functions|/"Assertion Functions"> provided, or can indicate that it
or any trailing tests in the same suite should be skipped by calling one of the
provided L<Skip Functions|/"Skip Functions">.

=head1 REQUIRES

L<Scalar::Util|Scalar::Util>, L<Carp|Carp>, L<Exporter|Exporter>

=head1 EXPORTS

Nothing by default.

This module exports several useful assertion functions for the following tags:

=over 4

=item B<:asserts>

  assert, assertNot, assertDefined, assertUndef, assertNoException,
  assertException, assertExceptionType, assertExceptionMatches, assertEquals,
  assertMatches, assertRef, assertNotRef, assertInstanceOf, assertKindOf, fail

=item B<:skips>

  skipOne, skipAll

=item B<:testFunctions>

  runTests

=item B<:functions>

All of the above.

=back

=head1 AUTHOR

Michael Granger E<lt>ged@FaerieMUD.orgE<gt>

Copyright (c) 1999-2002 The FaerieMUD Consortium. All rights reserved.

This module is free software. You may use, modify, and/or redistribute this
software under the terms of the Perl Artistic License. (See
http://language.perl.com/misc/Artistic.html)

=cut

##############################################################################
package Test::SimpleUnit;
use strict;
use warnings qw{all};

###############################################################################
###  I N I T I A L I Z A T I O N
###############################################################################
BEGIN {
	### Versioning stuff and custom includes
	use vars qw{$VERSION $RCSID};
	$VERSION	= do { my @r = (q$Revision: 1.16 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
	$RCSID	= q$Id: SimpleUnit.pm,v 1.16 2002/04/23 22:04:34 deveiant Exp $;

	### Export functions
	use base qw{Exporter};
	use vars qw{@EXPORT @EXPORT_OK %EXPORT_TAGS};

	@EXPORT		= qw{};
	@EXPORT_OK	= qw{
					 &assert
					 &assertNot
					 &assertDefined
					 &assertUndef
					 &assertNoException
					 &assertException
					 &assertExceptionType
					 &assertExceptionMatches
					 &assertEquals
					 &assertMatches
					 &assertRef
					 &assertNotRef
					 &assertInstanceOf
					 &assertKindOf

					 &fail

					 &skipOne
					 &skipAll

					 &runTests
					};
	%EXPORT_TAGS = (
		functions		=> \@EXPORT_OK,
		asserts			=> [@EXPORT_OK[ 0 .. $#EXPORT_OK-3 ]],
		assertFunctions	=> [@EXPORT_OK[ 0 .. $#EXPORT_OK-3 ]], # Backwards-compatibility
		skips			=> [@EXPORT_OK[ $#EXPORT_OK-3 .. $#EXPORT_OK-1 ]],
		testFunctions	=> [$EXPORT_OK[ $#EXPORT_OK ]],
	   );

	use constant TRUE	=> 1;
	use constant FALSE	=> 0;

	use Scalar::Util qw{blessed};
	use Carp qw{confess};
}


#####################################################################
###	C L A S S   V A R I A B L E S
#####################################################################
our ( $AutoskipFailedSetup );

$AutoskipFailedSetup = FALSE;



### FUNCTION: AutoskipFailedSetup( $trueOrFalse )
### If set to a true value, any failed setup functions will cause the test to be
### skipped instead of running.
sub AutoskipFailedSetup {
	shift if @_ && $_[0] eq __PACKAGE__; # <- Backward compatibility
	$AutoskipFailedSetup = shift if @_;
	return $AutoskipFailedSetup;
}



#####################################################################
###	F O R W A R D   D E C L A R A T I O N S
#####################################################################
sub assert ($;$);
sub assertNot ($;$);
sub assertDefined ($;$);
sub assertUndef ($;$);
sub assertNoException (&;$);
sub assertException (&;$);
sub assertExceptionType (&$;$);
sub assertExceptionMatches (&$;$);
sub assertEquals ($$;$);
sub assertMatches ($$;$);
sub assertRef ($$;$);
sub assertNotRef ($;$);
sub assertInstanceOf ($$;$);
sub assertKindOf ($$;$);

sub fail (;$);

sub skipOne (;$);
sub skipAll (;$);

sub runTests;




###############################################################################
###	T E S T I N G   F U N C T I O N S
###############################################################################
our ( $assertCount, $succeedCount ) = (0) x 2;

### (ASSERTION) FUNCTION: assert( $value[, $failureMessage] )
### Die with a failure message if the specified value is not true. If the
### optional failureMessage is not given, one will be generated.
sub assert ($;$) {
	my ( $assert, $message ) = @_;

	$assertCount++;
	$message ||= defined $assert ? "$assert" : "(undef)";
	die( $message, "\n" ) unless $assert;
	$succeedCount++;

	return 1;
}

### (ASSERTION) FUNCTION: assertNot( $value[, $failureMessage] )
### Die with a failure message if the specified value B<is> true. If the
### optional failureMessage is not given, one will be generated.
sub assertNot ($;$) {
	my ( $assert, $message ) = @_;
	assert( !$assert, $message || "Expected a false value, got '".
			(defined $assert ? "$assert" : "(undef)"). "'" );
}

### (ASSERTION) FUNCTION: assertDefined( $value[, $failureMessage] )
### Die with a failure message if the specified value is undefined. If the
### optional failureMessage is not given, one will be generated.
sub assertDefined ($;$) {
	my ( $assert, $message ) = @_;
	assert( defined($assert), $message || "Expected a defined value, got an undef" );
}

### (ASSERTION) FUNCTION: assertUndef( $value[, $failureMessage] )
### Die with a failure message if the specified value is defined. If the
### optional failureMessage is not given, one will be generated.
sub assertUndef ($;$) {
	my ( $assert, $message ) = @_;
	assert( !defined($assert), $message || "Expected an undefined value, got '".
				(defined $assert ? "$assert" : "(undef)") . "'" );
}

### (ASSERTION) FUNCTION: assertNoException( \&code[, $failureMessage] )
### Evaluate the specified coderef, and die with a failure message if it
### generates an exception. If the optional failureMessage is not given, one
### will be generated.
sub assertNoException (&;$) {
	my ( $code, $message ) = @_;

	eval { $code->() };
	assertNot( $@, $message || "Exception raised: $@" );
}

### (ASSERTION) FUNCTION: assertException( \&code[, $failureMessage] )
### Evaluate the specified I<coderef>, and die with a failure message if it does
### not generate an exception. If the optional I<failureMessage> is not given, one
### will be generated.
sub assertException (&;$) {
	my ( $code, $message ) = @_;

	eval { $code->() };
	assert( $@, $message || "No exception raised." );
}

### (ASSERTION) FUNCTION: assertExceptionType( \&code, $type[, $failureMessage] )
### Evaluate the specified I<coderef>, and die with a failure message if it does
### not generate an exception which is an object blessed into the specified
### I<type> or one of its subclasses (ie., the exception must return true to
### C<$exception->isa($type)>.  If the optional I<failureMessage> is not given, one
### will be generated.
sub assertExceptionType (&$;$) {
	my ( $code, $type, $message ) = @_;

	eval { $code->() };
	assert $@, ($message||"Expected an exception of type '$type', but none was raised.");

	$message ||= sprintf( "Expected exception of type '%s', got a '%s' instead.",
						  $type, blessed $@ || $@ );
	assertKindOf( $type, $@, $message );
}

### (ASSERTION) FUNCTION: assertExceptionMatches( \&code, $regex[, $failureMessage] )
### Evaluate the specified I<coderef>, and die with a failure message if it does
### not generate an exception which matches the specified I<regex>.  If the
### optional I<failureMessage> is not given, one will be generated.
sub assertExceptionMatches (&$;$) {
	my ( $code, $regex, $message ) = @_;

	eval { $code->() };
	assert $@, ($message || "Expected an exception which matched /$regex/, but none was raised.");
	my $err = "$@";

	$message ||= sprintf( "Expected exception matching '%s', got '%s' instead.",
						  $regex, $err );
	assertMatches( $regex, $err, $message );
}


### (ASSERTION) FUNCTION: assertEquals( $wanted, $tested[, $failureMessage] )
### Die with a failure message if the specified wanted value doesn't equal
### (stringwise) the specified tested value. If the optional failureMessage is
### not given, one will be generated.
sub assertEquals ($$;$) {
	my ( $wanted, $tested, $message ) = @_;

	$wanted = '(undef)' unless defined $wanted;
	$tested = '(undef)' unless defined $tested;
	$message ||= "Wanted '$wanted', got '$tested' instead";
	assert( ("$wanted" eq "$tested"), $message );
}

### (ASSERTION) FUNCTION: assertMatches( $wantedRegexp, $testedValue[, $failureMessage] )
### Die with a failure message if the specified tested value doesn't match
### the specified wanted regular expression. If the optional failureMessage is
### not given, one will be generated.
sub assertMatches ($$;$) {
	my ( $wanted, $tested, $message ) = @_;

	if ( ! blessed $wanted || ! $wanted->isa('Regexp') ) {
		$wanted = qr{$wanted};
	}

	$message ||= "Tested value '$tested' did not match wanted regex '$wanted'";
	assert( ($tested =~ $wanted), $message );
}

### (ASSERTION) FUNCTION: assertRef( $wantedType, $testedValue[, $failureMessage] )
### Die with a failure message if the specified testedValue is not of the
### specified wantedType. The wantedType can either be a ref-type like 'ARRAY'
### or 'GLOB' or a package name for testing object classes.  If the optional
### failureMessage is not given, one will be generated.
sub assertRef ($$;$) {
	my ( $wantedType, $testValue, $message ) = @_;

	$message ||= ("Expected a $wantedType value, got a " .
					  ( ref $testValue ? ref $testValue : (defined $testValue ? 'scalar' : 'undefined value') ));
	assert( ref $testValue && (ref $testValue eq $wantedType || UNIVERSAL::isa($wantedType, $testValue)), $message );
}


### (ASSERTION) FUNCTION: assertNotRef( $testedValue[, $failureMessage] )
### Die with a failure message if the specified testedValue is a reference of
### any kind. If the optional failureMessage is not given, one will be
### generated.
sub assertNotRef ($;$) {
	my ( $testValue, $message ) = @_;

	$message ||= ( "Expected a simple scalar, got a " . (ref $testValue ? ref $testValue : 'scalar') );
	assert( !ref $testValue, $message );
}


### (ASSERTION) FUNCTION: assertInstanceOf( $wantedClass, $testedValue[, $failureMessage] )
### Die with a failure message if the specified testedValue is not an instance
### of the specified wantedClass. If the optional failureMessage is not given,
### one will be generated.
sub assertInstanceOf ($$;$) {
	my ( $wantedClass, $testValue, $message ) = @_;

	assert( blessed $testValue,
			$message || "Expected an instance of '$wantedClass', got a non-object ('$testValue')" );

	$message ||= sprintf( "Expected an instance of '$wantedClass', got an instance of '%s' instead",
						  blessed $testValue );
	assertEquals( $wantedClass, ref $testValue, $message );
}


### (ASSERTION) FUNCTION: assertKindOf( $wantedClass, $testedValue[, $failureMessage] )
### Die with a failure message if the specified testedValue is not an instance
### of the specified wantedClass B<or> one of its derivatives. If the optional
### failureMessage is not given, one will be generated.
sub assertKindOf ($$;$) {
	my ( $wantedClass, $testValue, $message ) = @_;

	assert( blessed $testValue,
			$message || "Expected an instance of '$wantedClass' or a subclass, got a non-object ('$testValue')" );

	$message ||= sprintf "Expected an instance of '$wantedClass' or a subclass, got an instance of '%s' instead",
		blessed $testValue;
	assert( $testValue->isa($wantedClass), $message );
}


### (ASSERTION) FUNCTION: fail( [$failureMessage] )
### Die with a failure message unconditionally. If the optional
### I<failureMessage> is not given, a generic failure message will be used
### instead.
sub fail (;$) {
	my $message = shift || "Failed (no reason given)";
	$assertCount++;
	die( $message );
}


### (SKIP) FUNCTION: skipOne( [$message] )
### Skip the rest of this test, optionally outputting a message as to why the
### rest of the test was skipped.
sub skipOne (;$) {
	my $message = shift || '';
	die bless \$message, 'SKIPONE';
}


### (SKIP) FUNCTION: skipAll( [$message] )
### Skip all the remaining tests, optionally outputting a message as to why the
### they were skipped.
sub skipAll (;$) {
	my $message = shift || '';
	die bless \$message, 'SKIPALL';
}


### FUNCTION: runTests( @testSuite )
### Run the tests in the specified testSuite, generating output appropriate for
### the harness under which it is running. The testSuite should consist of one
### or more hashrefs of the following form:
###
###	{
###		name => 'testName',
###		test => sub { I<testCode> }
###	}
###
### The I<testCode> should make one or more assertions, and eventually return a
### true value if it succeeds.
sub runTests {
	my @testSuite = @_;

	my (
		$tests,
		$setupFuncs,
		$teardownFuncs,
		@failures,
	   );

	# Split setup funcs, teardown funcs, and tests into three arrayrefs
	( $setupFuncs, $tests, $teardownFuncs ) = _prepSuite( @testSuite );

	# If we have non-setup/teardown tests, run them
	if ( @$tests ) {
		@failures = _runTests( $setupFuncs, $tests, $teardownFuncs );

		# If there were any failures
		if ( @failures && ($ENV{VERBOSE} || $ENV{TEST_VERBOSE}) ) {
			print STDERR "Failures: \n", join( "\n", @failures ), "\n\n";
		}
	}

	# Otherwise, just skip everything
	else {
		print "1..1\n";
		print "ok # skip: Empty test suite.\n";
	}

	return 1;
}


### (PROTECTED) FUNCTION: _runTests( \@setupFuncs, \@tests, \@teardownFuncs )
### Run the specified I<tests>, running any I<setupFuncs> before each one, and
### any I<teardownFuncs> after each one.
sub _runTests {
	my ( $setupFuncs, $tests, $teardownFuncs ) = @_;

	my (
		$runningUnderTestHarness,
		$testCount,
		@failures,
		$skip,
	   );

	$runningUnderTestHarness = 1 if $ENV{HARNESS_ACTIVE};

	# Print the preamble and intialize some vars
	printf "1..%d\n", scalar @$tests;
	$testCount = 0;
	@failures = ();
	$skip = '';

	# If neither the VERBOSE nor TEST_VERBOSE vars were set, don't show STDERR
	unless ( $ENV{VERBOSE} || $ENV{TEST_VERBOSE} ) {
		open( STDERR, "+>/dev/null" );
	}


  TEST: foreach my $test ( @$tests ) {

		# Run any setup functions we have
		unless ( $skip ) {
			foreach my $func ( @$setupFuncs ) {
				if ( exists $func->{func} ) {
					eval { $func->{func}( $test ) };
				} else {
					eval { $func->{test}( $test ) };
				}

				if ( $@ ) {
					# Handle an explicit skipAll in a setup function
					if ( ref $@ eq 'SKIPALL' ) {
						print "ok # skip: ${$@}\n";
						$skip = ${$@};
						next TEST;
					} else {
						print STDERR "Warning: Setup failed: $@\n";
						print( "ok # skip: Setup failed ($@)\n" ), $skip = ${$@}
							if $AutoskipFailedSetup;
					}
				}
			}
		}

		# Print the test header and skip if we're skipping
		print ++$testCount, ". $test->{name}: " unless $runningUnderTestHarness;
		print( "ok # skip $skip\n" ), next TEST if $skip;

		# Run the actual test
		eval {
			$test->{test}();
		};

		if ( $@ ) {
			if ( ref $@ eq 'SKIPONE' ) {
				print "ok # skip: ${$@}\n";
			} elsif ( ref $@ eq 'SKIPALL' ) {
				print "ok # skip: ${$@}\n";
				$skip = ${$@};
			} else {
				push @failures, "$test->{name}: $@";
			}

			next TEST;
		}
		print "ok\n";

		# Run teardown functions
		foreach my $func ( @$teardownFuncs ) {
			if ( exists $func->{func} ) {
				eval { $func->{func}( $test ) };
			} else {
				eval { $func->{test}( $test ) };
			}

			print STDERR "Warning: Teardown failed: $@\n" if $@;
		}
	}

	print "$succeedCount out of $assertCount assertions passed.\n"
		unless $runningUnderTestHarness;

	return @failures;
}


### (PROTECTED) FUNCTION: _prepSuite( @tests )
### Split the specified array of test hashrefs into three arrays: setupFuncs,
### tests, and teardownFuncs. Return references to the three arrays.
sub _prepSuite {
	my @testSuite = @_;

	my ( @setupFuncs, @teardownFuncs );

	# Scan the test suite for setup and teardown, splicing them off into the
	# appropriate array if found
  SCAN: for ( my $i = 0 ; $i <= $#testSuite ; $i++ ) {
		last SCAN unless @testSuite;

		if ( $testSuite[$i]->{name} =~ m{^set[^a-z]?up$}i ) {
			push @setupFuncs, splice( @testSuite, $i, 1 );
			redo SCAN;
		}

		elsif ( $testSuite[$i]->{name} =~ m{^tear[^a-z]?down$}i ) {
			push @teardownFuncs, splice( @testSuite, $i, 1 );
			redo SCAN;
		}
	}

	return ( \@setupFuncs, \@testSuite, \@teardownFuncs );
}



1;


###	AUTOGENERATED DOCUMENTATION FOLLOWS

=head1 FUNCTIONS

=over 4

=item I<AutoskipFailedSetup( $trueOrFalse )>

If set to a true value, any failed setup functions will cause the test to be
skipped instead of running.

=item I<runTests( @testSuite )>

Run the tests in the specified testSuite, generating output appropriate for
the harness under which it is running. The testSuite should consist of one
or more hashrefs of the following form:

=back

=head2 Assertion Functions

=over 4

=item I<assert( $value[, $failureMessage] )>

Die with a failure message if the specified value is not true. If the
optional failureMessage is not given, one will be generated.

=item I<assertDefined( $value[, $failureMessage] )>

Die with a failure message if the specified value is undefined. If the
optional failureMessage is not given, one will be generated.

=item I<assertEquals( $wanted, $tested[, $failureMessage] )>

Die with a failure message if the specified wanted value doesn't equal
(stringwise) the specified tested value. If the optional failureMessage is
not given, one will be generated.

=item I<assertException( \&code[, $failureMessage] )>

Evaluate the specified I<coderef>, and die with a failure message if it does
not generate an exception. If the optional I<failureMessage> is not given, one
will be generated.

=item I<assertExceptionMatches( \&code, $regex[, $failureMessage] )>

Evaluate the specified I<coderef>, and die with a failure message if it does
not generate an exception which matches the specified I<regex>.  If the
optional I<failureMessage> is not given, one will be generated.

=item I<assertExceptionType( \&code, $type[, $failureMessage] )>

Evaluate the specified I<coderef>, and die with a failure message if it does
not generate an exception which is an object blessed into the specified
I<type> or one of its subclasses (ie., the exception must return true to
C<$exception->isa($type)>.  If the optional I<failureMessage> is not given, one
will be generated.

=item I<assertInstanceOf( $wantedClass, $testedValue[, $failureMessage] )>

Die with a failure message if the specified testedValue is not an instance
of the specified wantedClass. If the optional failureMessage is not given,
one will be generated.

=item I<assertKindOf( $wantedClass, $testedValue[, $failureMessage] )>

Die with a failure message if the specified testedValue is not an instance
of the specified wantedClass B<or> one of its derivatives. If the optional
failureMessage is not given, one will be generated.

=item I<assertMatches( $wantedRegexp, $testedValue[, $failureMessage] )>

Die with a failure message if the specified tested value doesn't match
the specified wanted regular expression. If the optional failureMessage is
not given, one will be generated.

=item I<assertNoException( \&code[, $failureMessage] )>

Evaluate the specified coderef, and die with a failure message if it
generates an exception. If the optional failureMessage is not given, one
will be generated.

=item I<assertNot( $value[, $failureMessage] )>

Die with a failure message if the specified value B<is> true. If the
optional failureMessage is not given, one will be generated.

=item I<assertNotRef( $testedValue[, $failureMessage] )>

Die with a failure message if the specified testedValue is a reference of
any kind. If the optional failureMessage is not given, one will be
generated.

=item I<assertRef( $wantedType, $testedValue[, $failureMessage] )>

Die with a failure message if the specified testedValue is not of the
specified wantedType. The wantedType can either be a ref-type like 'ARRAY'
or 'GLOB' or a package name for testing object classes.  If the optional
failureMessage is not given, one will be generated.

=item I<assertUndef( $value[, $failureMessage] )>

Die with a failure message if the specified value is defined. If the
optional failureMessage is not given, one will be generated.

=item I<fail( [$failureMessage] )>

Die with a failure message unconditionally. If the optional
I<failureMessage> is not given, a generic failure message will be used
instead.

=back

=head2 Skip Functions

=over 4

=item I<skipAll( [$message] )>

Skip all the remaining tests, optionally outputting a message as to why the
they were skipped.

=item I<skipOne( [$message] )>

Skip the rest of this test, optionally outputting a message as to why the
rest of the test was skipped.

=back

=cut

