#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use Test::More tests => 5;

use_ok( 'Executor::Executor' );

my $instance = new_ok('Executor::Executor');
can_ok($instance, qw/submit/);

my $future = $instance->submit(sub { return 1 + 1 });
isa_ok($future, 'Executor::Future');

my $expected = 2;
my $result = $future->value();
is($result, 2);
