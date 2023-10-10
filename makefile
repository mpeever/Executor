# Simple make tasks for the Perl Executor toy
# Mark Peever, 2023-10-10
#

PROVE=`which prove`

test:
	${PROVE} -l
