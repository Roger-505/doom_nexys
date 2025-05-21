CC = gcc
COMMON_DIR=../common
CFLAGS = -g -m32 -Wall -funsigned-char -I$(COMMON_DIR) -I./src
LDFLAGS = -m32 -L/usr/X11R6/lib
LIBS = -lXext -lX11 -lm

# Running doom
EXE=doom-linux-x11
BIN_EXE=bin/$(EXE)

CFLAGS += \
	-DNORMALUNIX \
	-DLINUX \
	-DDEBUG \
	-DRANGECHECK \
	-DSNDSERV \
	$(NULL)

include $(COMMON_DIR)/sources.mk

SOURCES_doom_arch = \
	i_main.c \
	i_net.c \
	i_sound.c \
	i_system.c \
	i_video.c \
	$(NULL)

OBJS += $(addprefix objs/, \
	$(SRC_doom:.c=.o) \
	$(addprefix src/, $(SOURCES_doom_arch:.c=.o)) \
)

all: $(BIN_EXE)

bin/doom-linux-x11: $(OBJS) | bin
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -rf objs bin

# Compilation rules
objs/%.o: %.c | objs
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: $(COMMON_DIR)/%.c | objs
	$(CC) $(CFLAGS) -c -o $@ $<

objs/src/%.o: src/%.c | objs
	$(CC) $(CFLAGS) -c -o $@ $<

objs:
	mkdir -p objs/src

bin:
	mkdir -p bin

help:
	@echo "Makefile targets for Doom Linux X11 port"
	@echo "----------------------------------------"
	@echo "Targets:"
	@echo "  all           Build the Doom executable"
	@echo "  clean         Remove all build artifacts"
	@echo "  run           Launch Doom inside Xephyr with a selectable resolution"
	@echo "  kill_xephyr   Kill any running Xephyr server"
	@echo
	@echo "Usage:"
	@echo "  make run SIZE=small   # Run Doom at 320x240"
	@echo "  make run SIZE=medium  # Run Doom at 640x480 (default)"
	@echo "  make run SIZE=big     # Run Doom at 960x720"
	@echo
	@echo "Examples:"
	@echo "  make clean all"
	@echo "  make clean all run SIZE=big"

WAD_FILE=*wad
DISPLAY_NUM=:2
SIZE ?= medium

# Map SIZE to resolution and flag
ifeq ($(SIZE),small)
    RESOLUTION := 320x200x8
    RES_FLAG := -1
else ifeq ($(SIZE),medium)
    RESOLUTION := 640x400x8
    RES_FLAG := -2
else ifeq ($(SIZE),big)
    RESOLUTION := 960x600x8
    RES_FLAG := -3
else
    $(error Unknown SIZE value '$(SIZE)'. Use small, medium, or big)
endif

run:
	@sudo pkill Xephyr || true
	@echo "Starting Xephyr on display $(DISPLAY_NUM) with resolution $(RESOLUTION)"
	sudo -E bash -c "Xephyr $(DISPLAY_NUM) -ac -screen $(RESOLUTION) &"
	@echo "Running $(EXE) with flag $(RES_FLAG) and WAD $(WAD_FILE)"
	@cp data/$(WAD_FILE) ./bin
	@cd bin && DISPLAY=$(DISPLAY_NUM) ./$(EXE) $(RES_FLAG) $(WAD_FILE)
	@sudo pkill Xephyr || true

.PHONY: all clean run objs bin objs/src kill_xephyr run help
# To run Doom on linux X11
# make clean all run
