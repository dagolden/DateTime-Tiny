package DateTime::Tiny;

=pod

=head1 NAME

DateTime::Tiny - A date object, with as little code as possible

=head1 SYNOPSIS

  # Create a date manually
  $christmas = DateTime::Tiny->new(
      year   => 2006,
      month  => 12,
      day    => 25,
      hour   => 10,
      minute => 45,
      second => 0,
      );
  
  # Show the current date
  my $now = DateTime::Tiny->now;
  print "Year   : " . $now->year   . "\n";
  print "Month  : " . $now->month  . "\n";
  print "Day    : " . $now->day    . "\n"; 
  print "Hour   : " . $now->hour   . "\n";
  print "Minute : " . $now->minute . "\n";
  print "Second : " . $now->second . "\n";

=head1 DESCRIPTION

B<DateTime::Tiny> is a most prominent member of the L<DateTime::Tiny>
suite of time modules.

It implements an extremely lightweight object that represents a datetime.

=head2 The Tiny Mandate

Many CPAN modules which provide the best implementation of a certain
concepts are very large. For some reason, this generally seems to be
about 3 megabyte of ram usage to load the module.

For a lot of the situations in which these large and comprehensive
implementations exist, some people will only need a small fraction of the
functionality, or only need this functionality in an ancillary role.

The aim of the Tiny modules is to implement an alternative to the large
module that implements a useful subset of their functionality, using as
little code as possible.

Typically, this means a module that implements between 50% and 80% of
the features of the larger module (although this is just a guideline),
but using only 100 kilobytes of code, which is about 1/30th of the larger
module.

=head2 The Concept of Tiny Date and Time

Due to the inherent complexity, Date and Time is intrinsically very
difficult to implement properly.

The arguably B<only> module to implement it completely correct is
L<DateTime>. However, to implement it properly L<DateTime> is quite slow
and requires 3-4 megabytes of memory to load.

The challenge in implementing a Tiny equivalent to DateTime is to do so
without making the functionality critically flawed, and to carefully
select the subset of functionality to implement.

If you look at where the main complexity and cost exists, you will find
that it is relatively cheap to represent a date or time as an object,
but much much more expensive to modify, manipulate or convert the object.

As a result, B<DateTime::Tiny> provides the functionality required to
represent a date as an object, to stringify the date and to parse it
back in, but does B<not> allow you to modify the dates.

The purpose of this is to allow for date object representations in
situations like log parsing and fast real-time type work.

The problem with this is that having no ability to modify date limits
the usefulness greatly.

To make up for this, B<if> you have L<DateTime> installed, any
B<DateTime::Tiny> module can be inflated into the equivalent L<DateTime>
as needing, loading L<DateTime> on the fly if necesary.

This is somewhat similar to DateTime::LazyInit, but unlike that module
B<DateTime::Tiny> is not modifiable.

For the purposes of date/time logic, all B<DateTime::Tiny> objects exist
in the "C" locale, and the "floating" time zone. This may be improved in
the future if a suitably tiny way of handling timezones is found.

When converting up to full L<DateTime> objects, these local and time
zone settings will be applied (although an ability is provided to
override this).

In addition, the implementation is strictly correct and is intended to
be very easily to sub-class for specific purposes of your own.

=head1 METHODS

In general, the intent is that the API be as close as possible to the
API for L<DateTime>. Except, of course, that this module implements
less of it.

=cut

use strict;
BEGIN {
	require 5.004;
	$DateTime::Tiny::VERSION = '1.04';
}
use overload 'bool' => sub () { 1 };
use overload '""'   => 'as_string';
use overload 'eq'   => sub { "$_[0]" eq "$_[1]" };
use overload 'ne'   => sub { "$_[0]" ne "$_[1]" };





#####################################################################
# Constructor and Accessors

=pod

=head2 new

  my $date = DateTime::Tiny->new(
      year   => 2006,
      month  => 12,
      day    => 31,
      hour   => 10,
      minute => 45,
      second => 32,
      );

The C<new> constructor creates a new B<DateTime::Tiny> object.

It takes six named params. C<day> should be the day of the month (1-31),
C<month> should be the month of the year (1-12), C<year> as a 4 digit year.
C<hour> should be the hour of the day (0-23), C<minute> should be the
minute of the hour (0-59) and C<second> should be the second of the
minute (0-59).

These are the only params accepted.

Returns a new B<DateTime::Tiny> object.

=cut

sub new {
	my $class = shift;
	bless { @_ }, $class;
}

=pod

=head2 now

  my $current_date = DateTime::Tiny->now;

The C<now> method creates a new date object for the current date.

The date created will be based on localtime, despite the fact that
the date is created in the floating time zone.

Returns a new B<DateTime::Tiny> object.

=cut

sub now {
	my @t = localtime time;
	shift->new(
		year   => $t[5] + 1900,
		month  => $t[4] + 1,
		day    => $t[3],
		hour   => $t[2],
		minute => $t[1],
		second => $t[0],
	);
}

=pod

=head2 year

The C<year> accessor returns the 4-digit year for the date.

=cut

sub year {
	defined $_[0]->{year} ? $_[0]->{year} : 1970;
}

=pod

=head2 month

The C<month> accessor returns the 1-12 month of the year for the date.

=cut

sub month {
	$_[0]->{month} || 1;
}

=pod

=head2 day

The C<day> accessor returns the 1-31 day of the month for the date.

=cut

sub day {
	$_[0]->{day} || 1;
}

=pod

=head2 hour

The C<hour> accessor returns the hour component of the time as
an integer from zero to twenty-three (0-23) in line with 24-hour
time.

=cut

sub hour {
	$_[0]->{hour} || 0;
}

=pod

=head2 minute

The C<minute> accessor returns the minute component of the time
as an integer from zero to fifty-nine (0-59).

=cut

sub minute {
	$_[0]->{minute} || 0;
}

=pod

=head2 second

The C<second> accessor returns the second component of the time
as an integer from zero to fifty-nine (0-59).

=cut

sub second {
	$_[0]->{second} || 0;
}

=pod

=head2 ymdhms

The C<ymdhms> method returns the most common and accurate stringified date
format, which returns in the form "2006-04-12".

=cut

sub ymdhms {
	sprintf( "%04u-%02u-%02uT%02u:%02u:%02u",
		$_[0]->year,
		$_[0]->month,
		$_[0]->day,
		$_[0]->hour,
		$_[0]->minute,
		$_[0]->second,
	);
}





#####################################################################
# Type Conversion

=pod

=head2 from_string

The C<from_string> method creates a new B<DateTime::Tiny> object from a string.

The string is expected to be an ISO 8601 time, with seperators.

  my $almost_midnight = DateTime::Tiny->from_string( '2006-12-20T23:59:59' );

Returns a new B<DateTime::Tiny> object, or throws an exception on error.

=cut

sub from_string {
	my $string = $_[1];
	unless ( defined $string and ! ref $string ) {
		Carp::croak("Did not provide a string to from_string");
	}
	unless ( $string =~ /^(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)$/ ) {
		Carp::croak("Invalid time format (does not match ISO 8601)");
	}
	$_[0]->new(
		year   => $1 + 0,
		month  => $2 + 0,
		day    => $3 + 0,
		hour   => $4 + 0,
		minute => $5 + 0,
		second => $6 + 0,
	);
}

=pod

=head2 as_string

The C<as_string> method converts the date to the default string, which
at present is the same as that returned by the C<ymd> method above.

This string matches the ISO 8601 standard for the encoding of a date as
a string.

=cut

sub as_string {
	$_[0]->ymdhms;
}

=pod

=head2 DateTime

The C<DateTime> method is used to create a L<DateTime> object
that is equivalent to the B<DateTime::Tiny> object, for use in
comversions and caluculations.

As mentioned earlier, the object will be set to the 'C' locate,
and the 'floating' time zone.

If installed, the L<DateTime> module will be loaded automatically.

Returns a L<DateTime> object, or throws an exception if L<DateTime>
is not installed on the current host.

=cut

sub DateTime {
	require DateTime;
	my $self = shift;
	DateTime->new(
		day       => $self->day,
		month     => $self->month,
		year      => $self->year,
		hour      => $self->hour,
		minute    => $self->minute,
		second    => $self->second,
		locale    => 'C',
		time_zone => 'floating',
		@_,
	);
}

1;

=pod

=head1 SUPPORT

Bugs should be reported via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DateTime-Tiny>

For other issues, or commercial enhancement or support, contact the author.

=head1 AUTHOR

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 SEE ALSO

L<DateTime>, L<Date::Tiny>, L<Time::Tiny>, L<Config::Tiny>, L<ali.as>

=head1 COPYRIGHT

Copyright 2006 - 2009 Adam Kennedy.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
