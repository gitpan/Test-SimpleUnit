#!/usr/bin/perl
##############################################################################

=head1 NAME

Test::SimpleUnit - Simplified Perl unit-testing framework

=head1 SYNOPSIS

  use Test::SimpleUnit qw{:functions};
  runTests(
    {name => "test1", test => sub {...}},
    {name => "testN", test => sub {...}}
  );

=head1 EXAMPLE

  use Test::SimpleUnit qw{:functions};
  
  # If a setup or teardown function fails, skip the rest of the tests
  Test::SimpleUnit::AutoskipFailedSetup( 1 );
  Test::SimpleUnit::AutoskipFailedTeardown( 1 );
  
  my $Instance;
  my $RequireWasOkay = 0;
  
  my @tests = (
    
    # Require the module
    {
      name => 'require',
      test => sub {
        
        # Make sure we can load the module to be tested.
        assertNoException { require MyClass };
        
        # Try to import some functions, generating a custom error message if it
        # fails.
        assertNoException { MyClass->import(':myfuncs') } "Failed to import :myfuncs";
        
        # Make sure calling 'import()' actually imported the functions
        assertRef 'CODE', *::myfunc{CODE};
        assertRef 'CODE', *::myotherfunc{CODE};
        
        # Set the flag to let the setup function know the module loaded okay
        $RequireWasOkay = 1;
      },
    },
    
    # Setup function (this will be run before any tests which follow)
    {
      name => 'setup',
      test => sub {
        # If the previous test didn't finish, it's untestable, so just skip the
        # rest of the tests
        skipAll "Module failed to load" unless $RequireWasOkay;
        $Instance = new MyClass;
      },
    },
    
    # Teardown function (this will be run after any tests which follow)
    {
      name => 'teardown',
      test => sub {
        undef $Instance;
      },
    },
    
    # Test the connect() and disconnect() methods
    {
      name => 'connect() and disconnect()',
      test => sub {
          my $rval;
          
          assertNoException { $rval = $Instance->connect };
          assert $rval, "Connect failed without error.";
          assertNoException { $Instance->disconnect };
      },
    },
    
    # One-time setup function -- overrides the previous setup, but is
    # immediately discarded after executing once.
    {
      name => 'setup',
      func => sub {
          MyClass::prepNetwork();
      },
    },
    
    # Now override the previous setup function with a new one that does
    # a connect() before each remaining test.
    {
      name => 'setup',
      test => sub {
          $Instance = new MyClass;
          $Instance->connect;
      },
    }
    
    # Same thing for teardown/disconnect()
    {
      name => 'teardown',
      test => sub {
        $Instance->disconnect;
        undef $Instance;
      },
    },
    
    ...
    
  );
  
  runTests( @testSuite );

=head1 DESCRIPTION

This is a simplified Perl unit-testing framework for creating unit tests to be
run either standalone or under Test::Harness.

=head2 Testing

Testing in Test::SimpleUnit is done by running a test suite, either via 'make
test', which uses the L<Test::Harness|Test::Harness> 'test' target written by
L<ExtUtils::MakeMaker|ExtUtils::MakeMaker>, or as a standalone script.

If errors occur while running tests via the 'make test' method, you can get more
verbose output about the test run by adding C<TEST_VERBOSE=1> to the end of the
C<make> invocation:

  $ make test TEST_VERBOSE=1

If you want to display only the messages caused by failing assertions, you can
add a C<VERBOSE=1> to the end of the C<make> invocation instead:

  $ make test VERBOSE=1

=head2 Test Suites

A test suite is one or more test cases, each of which tests a specific unit of
functionality.

=head2 Test Cases

A test case is a unit of testing which consists of one or more tests, combined
with setup and teardown functions that make the necessary preparations for
testing.

You may wish to split test cases up into separate files under a C<t/> directory
so they will run under a L<Test::Harness|Test::Harness>-style C<make test>.

=head2 Tests

A test is a hashref which contains two key-value pairs: a I<name> key with the
name of the test as the value, and a code reference under a I<test> key:

  {
    name => 'This is the name of the test',
    test => sub { ...testing code... }
  }

Each test's C<test> function can make one or more assertions by using the
L<Assertion Functions|/"Assertion Functions"> provided, or can indicate that it
or any trailing tests in the same test case should be skipped by calling one of
the provided L<Skip Functions|/"Skip Functions">.

=head2 Setup and Teardown Functions

If a test has the name 'setup' or 'teardown', it is run before or after each
test that follows it, respectively. A second or succeeding setup or teardown
function will supersede any function of the same type which preceded it. This
allows a test designer to change the setup function as the tests progress. See
the L<EXAMPLE|"EXAMPLE"> section for an example of how to use this.

If a test is preceeded by multiple new setup/teardown functions, the last one to
be specified is kept, and any others are discarded after being executed
once. This allows one to specify one-time setup and/or teardown functions at a
given point of testing.

The code reference value within a I<setup> or I<teardown> test case can
optionally be named C<func> instead of C<test> for clarity. If there are both
C<func> and C<test> key-value pairs in a I<setup> or I<teardown> case, the
C<test> pair is silently ignored.

=head2 Saving Test Data

If the test suite requires configuration, or some other data which should
persist between test cases, it can be dumped via Data::Dumper to a file with the
L<saveTestData()|/"Test Data Functions"> function. In succeeding tests, it can
be reloaded using the L<loadTestData()|/"Test Data Functions"> function.

=head1 REQUIRES

L<Carp|Carp>, L<Data::Compare|Data::Compare>, L<Data::Dumper|Data::Dumper>,
L<Exporter|Exporter>, L<Fcntl|Fcntl>, L<IO::File|IO::File>,
L<IO::Handle|IO::Handle>, L<Scalar::Util|Scalar::Util>

=head1 EXPORTS

Nothing by default.

This module exports several useful assertion functions for the following tags:

=over 4

=item B<:asserts>

L<assert|/"Assertion Functions">, L<assertNot|/"Assertion Functions">,
L<assertDefined|/"Assertion Functions">, L<assertUndef|/"Assertion Functions">,
L<assertNoException|/"Assertion Functions">, L<assertException|/"Assertion
Functions">, L<assertExceptionType|/"Assertion Functions">,
L<assertExceptionMatches|/"Assertion Functions">, L<assertEquals|/"Assertion
Functions">, L<assertMatches|/"Assertion Functions">, L<assertRef|/"Assertion
Functions">, L<assertNotRef|/"Assertion Functions">,
L<assertInstanceOf|/"Assertion Functions">, L<assertKindOf|/"Assertion
Functions">, L<fail|/"Assertion Functions">

=item B<:skips>

L<skipOne|/"Skip Functions">, L<skipAll|/"Skip Functions">

=item B<:testFunctions>

L<runTests|/"FUNCTIONS">

=item B<:testdata>

L<loadTestData|/"Test Data Functions">, L<saveTestData|/"Test Data Functions">

=item B<:functions>

All of the above.

=back

=head1 AUTHOR

Michael Granger E<lt>ged@FaerieMUD.orgE<gt>

Copyright (c) 1999-2003 The FaerieMUD Consortium. All rights reserved.

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
	$VERSION	= 1.21;
	$RCSID		= q$Id: SimpleUnit.pm,v 1.24 2003/01/15 21:44:46 deveiant Exp $;

	### Export functions
	use base qw{Exporter};
	use vars qw{@EXPORT @EXPORT_OK %EXPORT_TAGS};

	@EXPORT		= qw{};
	@EXPORT_OK	= qw{
					 &saveTestData
					 &loadTestData

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
		testdata		=> [@EXPORT_OK[ 0 .. 2 ]],
		asserts			=> [@EXPORT_OK[ 2 .. $#EXPORT_OK-3 ]],
		assertFunctions	=> [@EXPORT_OK[ 2 .. $#EXPORT_OK-3 ]], # Backwards-compatibility
		skips			=> [@EXPORT_OK[ $#EXPORT_OK-3 .. $#EXPORT_OK-1 ]],
		testFunctions	=> [$EXPORT_OK[ $#EXPORT_OK ]],
	   );

	# More readable constants
	use constant TRUE	=> 1;
	use constant FALSE	=> 0;

	# Load other modules
	use Data::Dumper	qw{};
	use Data::Compare	qw{Compare};
	use Scalar::Util	qw{blessed dualvar};
	use IO::Handle		qw{};
	use IO::File		qw{};
	use Fcntl			qw{O_CREAT O_RDONLY O_WRONLY O_TRUNC};
	use Carp			qw{croak confess};
}


#####################################################################
###	C L A S S   V A R I A B L E S
#####################################################################
our ( $AutoskipFailedSetup, $AutoskipFailedDataLoad, $AutoskipFailedTeardown,
	  $Debug, $DefaultOutputHandle, $OutputHandle, @Counters );

$AutoskipFailedSetup = FALSE;
$AutoskipFailedDataLoad = FALSE;
$AutoskipFailedTeardown = FALSE;
$Debug = FALSE;
$DefaultOutputHandle = IO::Handle->new_from_fd( fileno STDOUT, 'w' );
$OutputHandle = $DefaultOutputHandle;

@Counters = ();


### FUNCTION: AutoskipFailedSetup( $trueOrFalse )
### If set to a true value, any failed setup functions will cause the test to be
### skipped instead of running.
sub AutoskipFailedSetup {
	shift if @_ && $_[0] eq __PACKAGE__; # <- Backward compatibility
	$AutoskipFailedSetup = shift if @_;
	return $AutoskipFailedSetup;
}


### FUNCTION: AutoskipFailedDataLoad( $trueOrFalse )
### If set to a true value, any failure to reload test data via loadTestData()
### will cause the test to be skipped instead of running.
sub AutoskipFailedDataLoad {
	shift if @_ && $_[0] eq __PACKAGE__; # <- Backward compatibility
	$AutoskipFailedDataLoad = shift if @_;
	return $AutoskipFailedDataLoad;
}


### FUNCTION: AutoskipFailedTeardown( $trueOrFalse )
### If set to a true value, any failed teardown functions will cause the test to
### be skipped instead of running.
sub AutoskipFailedTeardown {
	shift if @_ && $_[0] eq __PACKAGE__; # <- Backward compatibility
	$AutoskipFailedTeardown = shift if @_;
	return $AutoskipFailedTeardown;
}


### FUNCTION: Debug( $trueOrFalse )
### If set to a true value, the test suite will be dumped to STDERR before
### running.
sub Debug {
	$Debug = shift if @_;
	print STDERR ">>> Turned debugging on.\n" if $Debug;
	return $Debug;
}


### FUNCTION: OutputHandle( $handle )
### Set the I<handle> that will be used to output test progress
### information. This can be used to run tests under Test::Harness without
### influencing the test result, such as when invoking runTests() from within an
### assertion. It defaults to STDOUT, which will be what it is restored to if it
### is called with no argument. The argument is tested for support for the
### 'print', 'flush', and 'printf' methods, and dies if it does not support
### them. This function is mostly to support self-testing.
sub OutputHandle {
	my $ofh = shift || $DefaultOutputHandle;
	croak( "Invalid output handle for test output ($OutputHandle)" )
		unless UNIVERSAL::can($ofh, 'print')
			&& UNIVERSAL::can($ofh, 'flush')
			&& UNIVERSAL::can($ofh, 'printf');
	$ofh->autoflush;
	$OutputHandle = $ofh;
}


### (PRIVATE) FUNCTION: _PushAssertionCounter()
### Add a pair of assertion counters to the stack. Assertion counters are used
### to count assertion runs/successes, and this adds a level in case of
### recursive runTests() calls.
sub _PushAssertionCounter {
	unshift @Counters, { run => 0, succeed => 0 };
}


### (PRIVATE) FUNCTION: _CountAssertion()
### Add 1 to the count of assertions run in the current counter frame.
sub _CountAssertion {
	croak( "No counter frames in the stack" )
		unless @Counters;
	$Counters[ 0 ]{run}++;
}


### (PRIVATE) FUNCTION: _CountSuccess()
### Add 1 to the count of successful assertions in the current counter frame.
sub _CountSuccess {
	croak( "No counter frames in the stack" )
		unless @Counters;
	$Counters[ 0 ]{succeed}++;
}

### (PRIVATE) FUNCTION: _PopAssertionCounter()
### Remove the current assertion counter, and return a list of the number of
### assertions run, and the number of assertions which succeeded.
sub _PopAssertionCounter {
	croak( "No counter frames in the stack" )
		unless @Counters;
	my $counterFrame = shift @Counters;
	return( $counterFrame->{run}, $counterFrame->{succeed} );
}


#####################################################################
###	F O R W A R D   D E C L A R A T I O N S
#####################################################################
sub saveTestData ($\%);
sub loadTestData ($);

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



#####################################################################
###	T E S T   D A T A   L O A D / S A V E   F U N C T I O N S
#####################################################################

### (TEST DATA) FUNCTION: saveTestData( $filename, %datahash )
### Save the key/value pairs in I<%datahash> to a file with the specified
### I<filename> for later loading via loadTestData().
sub saveTestData ($\%) {
	my ( $filename, $datahash ) = @_;

	my $data = Data::Dumper->new( [$datahash], [qw{datahash}] )
		or die "Couldn't create Data::Dumper object";
	my $datafile = IO::File->new( $filename, O_CREAT|O_WRONLY|O_TRUNC )
		or die "open: $filename: $!";
	my $dumped = $data->Indent(0)->Purity(1)->Terse(1)->Dumpxs;

	if ( $Debug ) {
		print STDERR "saveTestData: Saving dumped test data '$dumped'\n";
	}

	$datafile->printflush( $dumped );
	$datafile->close;

	return TRUE;
}


### (TEST DATA) FUNCTION: loadTestData( $filename )
### Load key/data pairs from a data file that was saved from previous
### tests. Returns a reference to a hash of data items.
sub loadTestData ($) {
	my $filename = shift;

	my $datafile = IO::File->new( $filename, O_RDONLY )
		or die "open: $filename: $!";
	my $dumped = join '', $datafile->getlines;

	if ( $Debug ) {
		print STDERR "loadTestData: Loading dumped test data '$dumped'\n";
	}

	my $data = eval $dumped;

	if ( $@ ) {
		my $message = "Error while evaluating dumped data: $@";
		$message = bless \$message, 'SKIPALL' if $AutoskipFailedDataLoad;
		die $message;
	}

	return $data;
}




#####################################################################
###	T E S T I N G   F U N C T I O N S
#####################################################################

### (ASSERTION) FUNCTION: assert( $value[, $failureMessage] )
### Die with a failure message if the specified value is not true. If the
### optional failureMessage is not given, one will be generated.
sub assert ($;$) {
	my ( $assert, $message ) = @_;

	Test::SimpleUnit::_CountAssertion();
	$message ||= defined $assert ? "$assert" : "(undef)";
	die( $message, "\n" ) unless $assert;
	Test::SimpleUnit::_CountSuccess();

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
### Die with a failure message if the specified wanted value doesn't equal the
### specified tested value. The comparison is done with Data::Compare, so
### arbitrarily complex data structures may be compared, as long as they contain
### no GLOB, CODE, or REF references. If the optional failureMessage is not
### given, one will be generated.
sub assertEquals ($$;$) {
	my ( $wanted, $tested, $message ) = @_;

	$message ||= sprintf( "Wanted '%s', got '%s' instead",
						  defined $wanted ? $wanted : "(undef)",
						  defined $tested ? $tested : "(undef)" );
	assert( Compare($wanted, $tested), $message );
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

	my $defaultMessage = sprintf( "Expected an instance of '%s', got a non-object ('%s')",
								  $wantedClass,
								  defined $testValue ? $testValue : "(undef)" );
	assert( blessed $testValue, $message || $defaultMessage );

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

	my $defaultMessage = sprintf( "Expected an instance of '%s' or a subclass, got a non-object ('%s')",
								  $wantedClass,
								  defined $testValue ? $testValue : "(undef)" );
	assert( blessed $testValue, $message || $defaultMessage );

	$message ||= sprintf( "Expected an instance of '%s' or a subclass, got an instance of '%s' instead",
						  $wantedClass,
						  blessed $testValue );
	assert( $testValue->isa($wantedClass), $message );
}


### (ASSERTION) FUNCTION: fail( [$failureMessage] )
### Die with a failure message unconditionally. If the optional
### I<failureMessage> is not given, a generic failure message will be used
### instead.
sub fail (;$) {
	my $message = shift || "Failed (no reason given)";
	Test::SimpleUnit::_CountAssertion();
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

	if ( $Debug ) {
		print STDERR Data::Dumper->Dumpxs( [$setupFuncs,$tests,$teardownFuncs],
										   [qw{setupFuncs tests teardownFuncs}] ), "\n";
	}

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
		$OutputHandle->print( "1..1\n" );
		$OutputHandle->print( "ok # skip: Empty test suite.\n" );
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
		$func,
	   );

	Test::SimpleUnit::_PushAssertionCounter();
	$runningUnderTestHarness = 1 if $ENV{HARNESS_ACTIVE};

	# Print the preamble and intialize some vars
	if ( $Debug ) {
		print STDERR Data::Dumper->Dumpxs( [$setupFuncs,$tests,$teardownFuncs],
										   [qw{setupFuncs tests teardownFuncs}] ), "\n";
		print STDERR "Scalar tests = ", scalar @$tests, "\n";
	}
	$OutputHandle->printf( "1..%d\n", scalar @$tests );
	$OutputHandle->flush;
	$testCount = 0;
	@failures = ();
	$skip = '';

	# If neither the VERBOSE nor TEST_VERBOSE vars were set, don't show STDERR
	unless ( $ENV{VERBOSE} || $ENV{TEST_VERBOSE} ) {
		open( STDERR, "+>/dev/null" );
	}


  TEST: foreach my $test ( @$tests ) {
		$testCount++;

		# Run the current setup function unless we're in skip mode, there aren't
		# any setup functions, or the earliest one occurs after the current test
		unless ( $skip || !@$setupFuncs || $setupFuncs->[0]{index} > $testCount - 1 ) {
			my @tossedFuncs = ();

			# Remove tests that will be superceded this turn...
		  SETUP: while ( @$setupFuncs > 1 && $setupFuncs->[1]{index} <= $testCount - 1 ) {
				printf STDERR ("Test '%s' superceded by '%s'\n",
							   $setupFuncs->[0]{name},
							   $setupFuncs->[1]{name});
				push @tossedFuncs, shift(@$setupFuncs);
				next SETUP;
			}

			# Get the function and execute it
			foreach my $setup ( @tossedFuncs, $setupFuncs->[0] ) {
				$func = $setup->{func} || $setup->{test};
				eval { $func->($test) };

				# If there was an error, handle any autoskipping
				if ( $@ ) {
					# Handle an explicit skipAll in a setup function
					if ( ref $@ eq 'SKIPALL' ) {
						$OutputHandle->print( "ok # skip: ${$@}\n" );
						$skip = ${$@};
						next TEST;
					} else {
						print STDERR "Warning: Setup failed: $@\n";
						$OutputHandle->print( "ok # skip: Setup failed ($@)\n" ), $skip = ${$@}
							if $AutoskipFailedSetup;
					}
				}

				# Remove a test which is superceded by the following one
				if ( @$setupFuncs > 1 && $setupFuncs->[1]{index} <= $testCount ) {
					if ( $Debug ) {
						printf STDERR ("Test '%s' succeeded by '%s'\n",
									   $func->{name},
									   $setupFuncs->[1]{name});
					}
					shift @$setupFuncs;
				}

			}
		}

		# Print the test header and skip if we're skipping
		$OutputHandle->print( $testCount, ". $test->{name}: " ) unless $runningUnderTestHarness;
		$OutputHandle->print( "ok # skip $skip\n" ), next TEST if $skip;

		# If the test doesn't have a 'test' key, or its not a coderef, skip it
		$OutputHandle->print( "ok # skip No test function\n" ), next TEST
			unless exists $test->{test};
		$OutputHandle->print( "ok # skip Test function is not a coderef\n" ), next TEST
			unless ref $test->{test} eq 'CODE';

		if ( $Debug ) {
			print STDERR "Output handle before eval = fd ", $OutputHandle->fileno, "\n";
		}

		# Run the actual test
		eval {
			$test->{test}();
		};

		if ( $Debug ) {
			print STDERR "Output handle after eval = fd ", $OutputHandle->fileno, "\n";
		}

		# If there was an exception, handle it. It's either a 'skip the rest',
		# 'skip this one', or a bonafide error
		if ( $@ ) {
			if ( ref $@ eq 'SKIPONE' ) {
				$OutputHandle->print( "ok # skip: ${$@}\n" );
			} elsif ( ref $@ eq 'SKIPALL' ) {
				$OutputHandle->print( "ok # skip: ${$@}\n" );
				$skip = ${$@};
			} else {
				push @failures, "$test->{name}: $@";
				$OutputHandle->print( "not ok # $@\n" );
			}
		} else {
			$OutputHandle->print( "ok\n" );
		}

		# Run the current teardown function unless we're in skip mode, there aren't
		# any teardown functions, or the earliest one occurs after the current test
		unless ( $skip || !@$teardownFuncs || $teardownFuncs->[0]{index} > $testCount - 1 ) {
			my @tossedFuncs = ();

			# Remove tests that will be superceded this turn...
		  TEARDOWN: while ( @$teardownFuncs > 1 && $teardownFuncs->[1]{index} <= $testCount - 1 ) {
				printf STDERR ("Test '%s' superceded by '%s'\n",
							   $teardownFuncs->[0]{name},
							   $teardownFuncs->[1]{name});
				push @tossedFuncs, shift(@$teardownFuncs);
				next TEARDOWN;
			}

			# Get the function and execute it
			foreach my $teardown ( @tossedFuncs, $teardownFuncs->[0] ) {
				$func = $teardown->{func} || $teardown->{test};
				eval { $func->($test) };

				# If there was an error, handle any autoskipping
				if ( $@ ) {
					# Handle an explicit skipAll in a teardown function
					if ( ref $@ eq 'SKIPALL' ) {
						$OutputHandle->print( "ok # skip: ${$@}\n" );
						$skip = ${$@};
						next TEST;
					} else {
						print STDERR "Warning: Teardown failed: $@\n";
						$OutputHandle->print( "ok # skip: Teardown failed ($@)\n" ), $skip = ${$@}
							if $AutoskipFailedTeardown;
					}
				}

				# Remove a test which is superceded by the following one
				if ( @$teardownFuncs > 1 && $teardownFuncs->[1]{index} <= $testCount ) {
					if ( $Debug ) {
						printf STDERR ("Test '%s' succeeded by '%s'\n",
									   $func->{name},
									   $teardownFuncs->[1]{name});
					}
					shift @$teardownFuncs;
				}

			}
		}
	}

	my ( $assertCount, $succeedCount ) = Test::SimpleUnit::_PopAssertionCounter();
	if ( $Debug ) {
		print STDERR "Assertion counter came back: $succeedCount/$assertCount\n";
	}
	$OutputHandle->print( "$succeedCount out of $assertCount assertions passed.\n" )
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
			$setupFuncs[ $#setupFuncs ]{index} = $i;
			redo SCAN;
		}

		elsif ( $testSuite[$i]->{name} =~ m{^tear[^a-z]?down$}i ) {
			push @teardownFuncs, splice( @testSuite, $i, 1 );
			$teardownFuncs[ $#teardownFuncs ]{index} = $i;
			redo SCAN;
		}
	}

	return ( \@setupFuncs, \@testSuite, \@teardownFuncs );
}



1;


###	AUTOGENERATED DOCUMENTATION FOLLOWS

=head1 FUNCTIONS

=over 4

=item I<AutoskipFailedDataLoad( $trueOrFalse )>

If set to a true value, any failure to reload test data via loadTestData()
will cause the test to be skipped instead of running.

=item I<AutoskipFailedSetup( $trueOrFalse )>

If set to a true value, any failed setup functions will cause the test to be
skipped instead of running.

=item I<AutoskipFailedTeardown( $trueOrFalse )>

If set to a true value, any failed teardown functions will cause the test to
be skipped instead of running.

=item I<Debug( $trueOrFalse )>

If set to a true value, the test suite will be dumped to STDERR before
running.

=item I<OutputHandle( $handle )>

Set the I<handle> that will be used to output test progress
information. This can be used to run tests under Test::Harness without
influencing the test result, such as when invoking runTests() from within an
assertion. It defaults to STDOUT, which will be what it is restored to if it
is called with no argument. The argument is tested for support for the
'print', 'flush', and 'printf' methods, and dies if it does not support
them. This function is mostly to support self-testing.

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

Die with a failure message if the specified wanted value doesn't equal the
specified tested value. The comparison is done with Data::Compare, so
arbitrarily complex data structures may be compared, as long as they contain
no GLOB, CODE, or REF references. If the optional failureMessage is not
given, one will be generated.

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

=head2 Private Functions

=over 4

=item I<_CountAssertion()>

Add 1 to the count of assertions run in the current counter frame.

=item I<_CountSuccess()>

Add 1 to the count of successful assertions in the current counter frame.

=item I<_PopAssertionCounter()>

Remove the current assertion counter, and return a list of the number of
assertions run, and the number of assertions which succeeded.

=item I<_PushAssertionCounter()>

Add a pair of assertion counters to the stack. Assertion counters are used
to count assertion runs/successes, and this adds a level in case of
recursive runTests() calls.

=back

=head2 Protected Functions

=over 4

=item I<_prepSuite( @tests )>

Split the specified array of test hashrefs into three arrays: setupFuncs,
tests, and teardownFuncs. Return references to the three arrays.

=item I<_runTests( \@setupFuncs, \@tests, \@teardownFuncs )>

Run the specified I<tests>, running any I<setupFuncs> before each one, and
any I<teardownFuncs> after each one.

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

=head2 Test Data Functions

=over 4

=item I<loadTestData( $filename )>

Load key/data pairs from a data file that was saved from previous
tests. Returns a reference to a hash of data items.

=item I<saveTestData( $filename, %datahash )>

Save the key/value pairs in I<%datahash> to a file with the specified
I<filename> for later loading via loadTestData().

=back

=cut

