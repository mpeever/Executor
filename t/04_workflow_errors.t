#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use Test::More;

use_ok( 'Executor::Executor' );

# Create a single-thread Executor to test error/exception handling.
my $instance = Executor::Executor->new({size => 1});

ok($instance->is_empty);
ok(not $instance->queue_size);

# Submit a task we know will fail
my $future = $instance->submit( sub { return 12 / 0 });

ok($future->value =~ m/Illegal/);

done_testing();



