package Executor::Executor;

use Executor::Future;

=head1 SYNOPSIS

B<This module> defines an Executor that executes tasks in parallel.

=head1 AUTHOR

Mark Peever (mpeever@gmail.com)

=cut

our $VERSION = '0.0.1';

use constant DEFAULT_TIMEOUT => 30; # 30s timeout
use Moose;

# input queue for submitted jobs
has 'queue' => ( is => 'ro',
		 isa => 'ArrayRef',
		 default => sub { [] }
	       );

# collection of child pids
has 'pids' => ( is => 'ro',
		traits => ['Array'],
	        isa => 'ArrayRef[Int]',
		handles => {
			    all_pids => 'elements',
			    add_pid => 'unshift',
			    get_pid => 'get',
			    next_pid => 'pop'
			   },
	        default => sub { [] }
	      );

=head1 METHODS

=over 8

=item B<submit($function_ref, [$timeout])>

Submit a function reference for execution.

If C<$timeout> isn't provided, use DEFAULT_TIMEOUT as the default.

=cut

sub submit {
  my $self = shift;
  my $code = shift;
  my $timeout = shift || DEFAULT_TIMEOUT;

  my $pid = open( my $fh, '-|');

  # TODO - clean up this error handling code
  die unless defined($pid);
  
  if ($pid) { # Parent code
    $self->add_pid($pid);

    return Executor::Future->new({ pid => $pid,
				   executor => $self,
				   fh => $fh });
  }

  else { # Child code
    my $result = $code->();
    print STDOUT $result;
    exit 0;
  }
}

=back

=cut

 
no Moose;


return $VERSION;
