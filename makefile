# Variables
CC = mpicc         # Compiler
CFLAGS = -Wall     # Compiler flags
PREFIX =  

# Targets
all: hello         # Default target

hello: hello.o
	$(CC) $(CFLAGS) -o hello hello.o

hello.o: hello.c
	$(CC) $(CFLAGS) -c hello.c

clean:
	rm -f hello hello.o

check: hello
	mpirun -n 1 ./hello | grep "Hello world"

install: hello
	install -D hello $(PREFIX)/bin/hello

# Phony targets
.PHONY: all clean check