# Simple make tasks for the Perl Executor toy
# Mark Peever, 2023-10-10
#

MKDIR=`which mkdir`
POD2MAN=`which pod2man`
PROVE=`which prove`

# Execute all the tests
test:
	${PROVE} -l

# There are no artifacts to make except man(1) pages
all: docs

# Remove generated artifacts
clean:
	rm -rf doc/

# Create man(1) pages from POD documentation
docs: man 
man: doc/Executor
doc/Executor:
	${MKDIR} -p doc/Executor
	${POD2MAN} lib/Executor/Executor.pm doc/Executor/Executor.3
	${POD2MAN} lib/Executor/Future.pm doc/Executor/Future.3




