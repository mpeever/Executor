package Executor::Executor;

use Carp;
use Try::Tiny;

use constant DEFAULT_SIZE => 5;
use Executor::Future;

=head1 NAME

Executor::Executor - naive ExecutorService interface to Perl IPC to represent parallel execution as a ThreadPool.

=head1 VERSION

 0.0.2

=cut

our $VERSION = '0.0.2';

use Moose;

=head1 SYNOPSIS

  use Executor::Executor;
  use Executor::Future;

  my $executor = new Executor::Executor({size => 2});
  my $future = $executor->submit( sub { return 237 * 213 });

  my $value = $future->value(); # blocking call

=head1 DESCRIPTION

B<This module> defines an Executor that executes tasks in parallel.

B<Executor> provides no retry logic, and only minimal error handling for submitted code.
It simply maintains a queue of waiting tasks, and a Future mechanism to allow 
calling code to access the results of computation.

Waiting tasks are executed in order as earlier (executed) tasks are found to be complete.

This is loosely based on C<java.util.concurrent.*>

=head1 AUTHOR

Mark Peever (mpeever@gmail.com)

=head2 METHODS

=over 8

=item B<size>

Returns maximum number of executing processes.
This doesn't include the submission queue.

=cut

has 'size' => ( is => 'ro',
		isa => 'Int',
		default => sub { DEFAULT_SIZE });

=item B<queue>

Returns the submission queue for this Executor.

=cut

has 'queue' => ( is => 'ro',
		 isa => 'ArrayRef',
		 traits => ['Array'],
		 handles => {
			     enqueue => 'unshift',
			     dequeue => 'pop',
			     queue_size => 'count'
			     },
		 default => sub { [] });

=item B<pids>

Returns a Hash of PID => Future of [current] executing tasks.

=cut

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
	        default => sub { {} });

after 'remove_future' => sub {
  my $self = shift;
  if ($self->queue_size and $self->all_futures <= $self->size) {
    my $future = $self->dequeue();
    $self->_execute($future);
  }
};

=item B<_execute($future)>

B<Private> method to submit Future object for actual execution.

Update the provided Future object with filehandle and pid on success.

=cut

sub _execute {
  my $self = shift;
  my $future = shift;

  # Don't execute if our pool is full
  return if $self->all_futures >= $self->size;

  try {
    my $pid = open( my $fh, '-|');

    die "couldn't fork with open()" unless defined($pid);
  
    if ($pid) { # Parent 
      $future->pid($pid);
      $future->fh($fh);
      $self->add_future($pid, $future);
    }

    else { # Child
      # This is just plain ugly.
      # Try::Tiny won't let me nest try/catch blocks, so I have revert to old-skool Perl here.
      eval {
	my $result = $future->callable->();
	print STDOUT $result;
	exit 0;
      };

      if ($@) {
	chomp $@;
	print STDOUT $@;
      }
      exit 1;
    }
  } catch {
    carp "caught Exception attempting to fork a child process: $_";
  };
}

=item B<submit($function_ref)>

Submit a task reference for [later] execution.

The task is executed immediately, unless the current pid table is full.

Returns a Future object to track execution and retrieve return value.

=cut

sub submit {
  my $self = shift;
  my $code = shift;

  my $future = new Executor::Future({ executor => $self,
				      callable => $code });
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
