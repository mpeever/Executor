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
	       isa => 'Int'
	     );

has 'fh' => ( is => 'rw' );

has 'executor' => ( is => 'ro' );

has 'value' => ( is => 'ro',
		 lazy => 1,
		 default => sub {
		   my $self = shift;
		   my $output = join("", (readline($self->fh)));
		   close($self->fh);
		   return $output;
		 }
	       );

after 'value' => sub {
  my $self = shift;
  $self->executor->remove_future($self->pid);
};

no Moose;

return $VERSION;
