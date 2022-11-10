package Executor::Future;

=head1 synopsis

B<This module> defines a Future object to track task execution in an Executor.

=head1 author

Mark Peever (mpeever@gmail.com)

=cut

our $VERSION = '0.0.1';

use Moose;

has 'pid' => ( is => 'ro',
	       isa => 'Int'
	     );

has 'fh' => ( is => 'ro' );

has 'exector' => ( is => 'ro' );

has 'value' => ( is => 'ro',
		 lazy => 1,
		 default => sub {
		   my $self = shift;
		   my $filehandle = $self->fh;
		   my $output = join("\n", (<$filehandle>));
		   close $filehandle;
		   return $output;
		 } );


no Moose;

return $VERSION;
