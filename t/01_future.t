#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use Test::More tests => 3;

use_ok( 'Executor::Future' );

my $instance = new_ok('Executor::Future');
can_ok($instance, qw/callable complete executor fh pid value/);
