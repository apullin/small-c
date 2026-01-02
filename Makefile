CC = gcc-15
CFLAGS ?= -std=c11 -O0
CFLAGS += -Wno-return-type -Wno-deprecated-non-prototype -Wno-deprecated-declarations

TARGET = small-c-gcc
SRC = SMALL-C-gcc.c
OBJS = SMALL-C-gcc.o sys.o
EXAMPLES := $(sort $(wildcard examples/*.c))
TEST_OUT := examples/out

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(TARGET) $(OBJS)

tests: $(TARGET)
	@mkdir -p $(TEST_OUT)
	@set -e; \
	for src in $(EXAMPLES); do \
		base=$$(basename "$$src" .c); \
		out="$(TEST_OUT)/$$base.asm"; \
		./small-c.sh -o "$$out" "$$src"; \
	done

.PHONY: all clean tests
