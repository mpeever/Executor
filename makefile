# Simple make tasks for the Perl Executor toy
# Mark Peever, 2023-10-10
#

MKDIR=`which mkdir`
POD2MAN=`which pod2man`
PROVE=`which prove`

clean:
	rm -rf doc/

test:
	${PROVE} -l

documents:
	${MKDIR} -p doc/Executor
	${POD2MAN} lib/Executor/Executor.pm doc/Executor/Executor.3
	${POD2MAN} lib/Executor/Future.pm doc/Executor/Future.3

documentation: documents

