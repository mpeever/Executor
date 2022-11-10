#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use Test::More tests => 7;

use_ok( 'Executor::Executor' );

my $instance = new_ok('Executor::Executor');
can_ok($instance, qw/all_futures 
		     add_future 
		     enqueue
		     dequeue
		     queue_size
		     get_future
		     is_empty
		     pids
		     queue
		     remove_future
		     size
		     submit/);

ok($instance->is_empty);

my $future = $instance->submit(sub { return 1 + 1 });
ok(not($instance->is_empty()));
isa_ok($future, 'Executor::Future');

my $expected = 2;
my $result = $future->value();
is($result, 2);
