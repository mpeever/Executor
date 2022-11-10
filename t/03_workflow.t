#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use Test::More ;

use_ok( 'Executor::Executor' );

my $instance = Executor::Executor->new({size => 2});

ok($instance->is_empty);
ok(not $instance->queue_size);

my @test_data_lines = (<DATA>);
chomp(@test_data_lines);

my $test_data_text = join("\n", @test_data_lines);

my @tasks = (
	     sub { return 1 + 1},
	     sub { return 24 * 5 },
	     sub { return $test_data_text }
	    );

my @expected = (2,
		120,
		$test_data_text
	       );

my @futures = map { $instance->submit($_) } @tasks;

is($instance->all_futures, 2);
is($instance->queue_size, 1);

foreach my $future (@futures) {
  is_deeply($future->value, shift @expected);
}

ok($instance->is_empty);

done_testing();

#
# Pride and Prejudice, Chapter 1
# https://www.gutenberg.org/files/1342/1342-h/1342-h.htm#link2HCH0001
#
# Jane Austen provides excellent test data

__DATA__

 It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.

However little known the feelings or views of such a man may be on his first entering a neighbourhood, this truth is so well fixed in the minds of the surrounding families, that he is considered as the rightful property of some one or other of their daughters.

“My dear Mr. Bennet,” said his lady to him one day, “have you heard that Netherfield Park is let at last?”

Mr. Bennet replied that he had not.

“But it is,” returned she; “for Mrs. Long has just been here, and she told me all about it.”

Mr. Bennet made no answer.

“Do not you want to know who has taken it?” cried his wife impatiently.

“You want to tell me, and I have no objection to hearing it.”

This was invitation enough.

“Why, my dear, you must know, Mrs. Long says that Netherfield is taken by a young man of large fortune from the north of England; that he came down on Monday in a chaise and four to see the place, and was so much delighted with it that he agreed with Mr. Morris immediately; that he is to take possession before Michaelmas, and some of his servants are to be in the house by the end of next week.”

“What is his name?”

“Bingley.”

“Is he married or single?”

“Oh! single, my dear, to be sure! A single man of large fortune; four or five thousand a year. What a fine thing for our girls!”

“How so? how can it affect them?”

“My dear Mr. Bennet,” replied his wife, “how can you be so tiresome! You must know that I am thinking of his marrying one of them.”

“Is that his design in settling here?”

“Design! nonsense, how can you talk so! But it is very likely that he may fall in love with one of them, and therefore you must visit him as soon as he comes.”
  
