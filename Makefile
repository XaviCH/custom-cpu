

.PHONY: all clean test

test:
	make -C test

all: test

clean:
	make -C test clean