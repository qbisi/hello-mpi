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
	@output=$$(mpirun -n 1 ./hello); \
	if [ "$$output" = "Hello world from processor localhost, rank 0 out of 1 processors" ]; then \
		echo "Check passed: Output is exactly 'Hello, World!'"; \
	else \
		echo "Check failed: Output was '$$output'"; \
		exit 1; \
	fi

install: hello
	install -D hello $(PREFIX)/bin/hello

# Phony targets
.PHONY: all clean check