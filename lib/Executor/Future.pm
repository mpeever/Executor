package Executor::Future;

our $VERSION = '0.0.1';

use Moose;

=head1 SYNOPSIS

B<This module> defines a Future object to track task execution in an Executor.

=head1 AUTHOR

Mark Peever (mpeever@gmail.com)

=cut

has 'callable' => ( is => 'ro' );

has 'pid' => ( is => 'rw',
	       isa => 'Int' );

has 'fh' => ( is => 'rw' );

has 'executor' => ( is => 'ro' );

has 'complete' => ( is => 'rw',
		    default => sub { 0 } );

around 'complete' => sub {
  my $original = shift;
  my $self = shift;
  my $value = shift;

  return $self->$original($value) unless $value;

  # Can't complete if we don't have a PID.
  return $self->$original() unless $self->pid;

  # we're marking this complete, so we'll remove it from the Executor
  $self->executor->remove_future($self->pid);

  $self->$original($value);
};

has 'value' => ( is => 'ro',
		 lazy => 1,
		 default => sub {
		   my $self = shift;
		   my $output = join("", (readline($self->fh)));
		   close($self->fh);
		   return $output;
		 });

after 'value' => sub {
  my $self = shift;
  $self->complete(1);
};

no Moose;

return $VERSION;
