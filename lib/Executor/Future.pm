package Executor::Future;

=head1 NAME

Executor::Future - naive Future interface for Perl IPC to track parallelized child processes.

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

  my $pid = $future->pid;

  my $value = $future->value; # blocking call

=head1 DESCRIPTION

B<This module> defines a Future object to track task execution in an Executor.

=head1 AUTHOR

Mark Peever (mpeever@gmail.com)

=head2 METHODS

=over 8

=item B<callable>

Returns the callable code inside this Future.

=cut

has 'callable' => ( is => 'ro' );

=item B<pid>

Returns the PID associated with this Future's execution.

=cut

has 'pid' => ( is => 'rw',
	       isa => 'Int' );

=item B<fh>

Returns the filehandle associated with STDOUT of the child process.

=cut

has 'fh' => ( is => 'rw' );

=item B<executor>

Returns the Executor that owns this Future object.

=cut

has 'executor' => ( is => 'ro' );

=item B<complete>

Returns boolean indicating whether execution has completed.

=cut

has 'complete' => ( is => 'rw',
		    default => sub { 0 } );

around 'complete' => sub {
  my $original = shift;
  my $self = shift;

  return $self->$original(@_) unless @_;

  # Can't complete if we don't have a PID.
  return $self->$original() unless $self->pid;

  # we're marking this complete, so we'll remove it from the Executor
  $self->executor->remove_future($self->pid);

  $self->$original(@_);
};

=item B<value>

Return value of the wrapped callable code.
This is a blocking call, and will wait for a child PID to exit.

=cut

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

=back

=cut

no Moose;

return $VERSION;
