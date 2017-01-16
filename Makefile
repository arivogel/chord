###########################################################################
# General C compiler parameters
###########################################################################

# We shall use gcc to compile C code
CC = gcc
# Use C99; print all warnings, and treat all warnings as errors
CFLAGS = -Wall -Werror -I../include/

# Command to invoke clint
CLINT = python clint.py

# Targets to compile
TARGETS = src/main

###########################################################################
# List of targets and C source files
###########################################################################

# List of C source files needed to compile our target.
CSOURCES = src/main.c src/node.c

# Translate our list of C source files into a list of object files.
# These object files will be linked together to ultimately compile our
# target.
OBJECTS = $(CSOURCES:.c=.o)


###########################################################################
# Make rules
###########################################################################

all : $(TARGETS)


# Each C source file will have a corresponding file of prerequisites.
# Include the prerequisites for each of our C source files.
-include $(CSOURCES:.c=.d)

# This rule generates a file of prerequisites (i.e., a makefile)
# called name.d from a C source file called name.c.
%.d : %.c
	@set -e; rm -f $@; \
	$(CC) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

# Default rule for compiling an object file from a C source file.
%.o : %.c
	$(CC) $(CFLAGS) -c $< $(LDFLAGS)

# Clean the directory of generated files 
clean :
	rm -rf *.o *.d* $(TARGETS) *~ src/*.o src/*.d

###########################################################################
# Make rules for running tests
###########################################################################

TESTSDIR = tests
RUNTEST = ./run_tests.py

.PHONY : tests clean_tests test_prepush

# Make the results file for a specified test file
$(TESTSDIR)/%.results : $(TESTSDIR)/%.csv $(TARGETS)
	$(RUNTEST) $(RUNTESTFLAGS) $<

# Run all tests
tests : $(TARGETS)
	$(RUNTEST) $(RUNTESTFLAGS) $(TESTSDIR)/*.csv

# Clean the test directory of generated files
clean_tests :
	rm -rf $(TESTSDIR)/*.results $(TESTSDIR)/*~

# Basic tests to be run before pushing to the repository
test_prepush : clean $(TARGETS)
	@if [ `stat --printf="%s" ./count_primes` -gt 1048576 ]; then \
		echo "ERROR: Executable size exceeds 1MB limit."; exit 2; \
	fi
	$(CLINT) *.c *.h 
# You can add your own tests here, if you want them to run whenever
# you git push.
#       $(RUNTEST) $(TESTSDIR)/basictests.csv
