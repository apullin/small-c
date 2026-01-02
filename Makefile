CC ?= gcc-15
CFLAGS ?= -std=c11 -O0
CFLAGS += -Wno-return-type -Wno-deprecated-non-prototype -Wno-deprecated-declarations

TARGET = small-c-gcc
SRC = SMALL-C-gcc.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)

.PHONY: all clean
