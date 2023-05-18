OUT_DIR = out
INCL_DIR = include

ASM_BOOT_SRCS = $(wildcard src/boot/*.asm)
ASM_BOOT_INCL_FILES = $(wildcard src/boot/lib/*.asm)
ASM_BOOT_OBJS = $(patsubst src/%.asm,$(OUT_DIR)/%.o,$(ASM_BOOT_SRCS))

OPTIMIZATION = -O0

TARGET = i686

C_FLAGS = -ffreestanding $(OPTIMIZATION) -g -m32 -Wall -Wextra -fno-use-cxa-atexit -fno-exceptions -fno-rtti -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -fno-common -I$(INCL_DIR)
CC = $(TARGET)-elf-g++
LD = $(TARGET)-elf-ld
OBJCPY = $(TARGET)-elf-objcopy
LD_FLAGS = -nostdlib -nolibc -nostartfiles -nodefaultlibs -fno-common -ffreestanding $(OPTIMIZATION)

QEMU = qemu-system-x86_64
QEMU_FLAGS = -M pc -no-reboot -m 512M -monitor stdio

DISK_IMG = out/disk.img

.PHONY: build install-boot run

$(ASM_BOOT_SRCS): $(ASM_BOOT_INCL_FILES)

out/boot/%.o: src/boot/%.asm $(ASM_BOOT_SRCS) $(ASM_BOOT_INCL_FILES)
	@mkdir -p $(@D)
	nasm -f bin $< -isrc/boot -o $@ $(NASM_DEFINES)

build: $(ASM_BOOT_OBJS)
	@./disk.sh
	@./install-boot.sh

run:
	$(MAKE) build
	$(QEMU) $(QEMU_FLAGS) -drive format=raw,file=$(DISK_IMG) 

debug:
	$(MAKE) build
	$(QEMU) $(QEMU_FLAGS) -drive format=raw,file=$(DISK_IMG) -s -S -no-shutdown

clear:
	make clean
	clear

clean:
	rm -rf out
	rm -rf $(DISK_IMG)
	rm -rf *.mem
