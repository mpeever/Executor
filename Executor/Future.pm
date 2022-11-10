package Executor::Future;

=head1 synopsis

B<This module> defines a Future object to track task execution in an Executor.

=head1 author

Mark Peever (mpeever@gmail.com)

=cut

our $VERSION = '0.0.1';

use constant DEFAULT_TIMEOUT => 5;
use Moose;

has 'pid' => ( is => 'ro',
	       isa => 'Int'
	     );

has 'stdout' => ( is => 'ro' );
has 'stdin' => ( is => 'ro' );

=head1 METHODS

=over 8

=item B<get([$timeout])>

Get the return value of executed code.

If C<$timeout> isn't provided, use DEFAULT_TIMEOUT as the default.

=cut

sub get {
  my $self = shift;
  my $tmeout = shift or DEFAULT_TIMEOUT;

  return
}
  

return $VERSION;
