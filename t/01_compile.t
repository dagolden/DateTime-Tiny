#!/usr/bin/perl

# Tests that DateTime::Tiny compiles

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;	
}

use Test::More tests => 2;

ok( $] >= 5.004, "Your perl is new enough" );
use_ok( 'DateTime::Tiny' );
