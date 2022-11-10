package Executor::Executor;

use Executor::Future;

=head1 SYNOPSIS

B<This module> defines an Executor that executes tasks in parallel.

=head1 AUTHOR

Mark Peever (mpeever@gmail.com)

=cut

our $VERSION = '0.0.1';
use constant DEFAULT_SIZE => 5;
use Moose;

has 'size' => ( is => 'ro',
		isa => 'Int',
		default => sub { DEFAULT_SIZE }
		);

has 'queue' => ( is => 'ro',
		 isa => 'ArrayRef',
		 traits => ['Array'],
		 handles => {
			     enqueue => 'unshift',
			     dequeue => 'pop',
			     queue_size => 'count'
			     },
		 default => sub { [] }
	       );

has 'pids' => ( is => 'ro',
	        isa => 'HashRef',
		traits => ['Hash'],
		handles => {
			    all_futures => 'keys',
			    add_future => 'set',
			    get_future => 'get',
			    remove_future => 'delete',
			    is_empty => 'is_empty'
			   },
	        default => sub { {} }
	      );

after 'remove_future' => sub {
  my $self = shift;
  if ($self->queue_size and $self->all_futures <= $self->size) {
    my $future = $self->dequeue();
    $self->_execute($future);
  }
};

=head1 METHODS

=over 8

=item B<_execute($future)>

B<Private> method to submit Future object for actual execution.

Update the provided Future object with filehandle and pid on success.

=cut

sub _execute {
  my $self = shift;
  my $future = shift;

  # Don't execute if our pool is full
  return if $self->all_futures >= $self->size;

  my $pid = open( my $fh, '-|');

  # TODO - clean up this error handling code
  die unless defined($pid);
  
  if ($pid) { # Parent 
    $future->pid($pid);
    $future->fh($fh);
    $self->add_future($pid, $future);
  }

  else { # Child 
    my $result = $future->callable->();
    print STDOUT $result;
    exit 0;
  }
}

=item B<submit($function_ref)>

Submit a function reference for [later] execution.

=cut

sub submit {
  my $self = shift;
  my $code = shift;

  my $future = Executor::Future->new( { executor => $self,
					callable => $code }
				    );
  $self->_execute($future);

  unless ($future->pid) { # code is NOT executing, queue for later execution
    $self->enqueue($future);
  }

  return $future;
}

=back

=cut
 
no Moose;

return $VERSION;
