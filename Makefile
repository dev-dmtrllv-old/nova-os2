OUT_DIR = out
INCL_DIR = include

ASM_BOOT_SRCS = $(wildcard boot/*.asm)
ASM_BOOT_INCL_FILES = $(wildcard boot/lib/*.asm)
ASM_BOOT_OBJS = $(patsubst src/%.asm,$(OUT_DIR)/boot/%.o,$(ASM_BOOT_SRCS))

OPTIMIZATION = -O2

TARGET = i686

C_FLAGS = -ffreestanding $(OPTIMIZATION) -g -m32 -Wall -Wextra -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -fno-common
CC = $(TARGET)-elf-gcc
CXX = $(TARGET)-elf-g++
LD = $(TARGET)-elf-ld
OBJCPY = $(TARGET)-elf-objcopy
LD_FLAGS = -nostdlib -nolibc -nostartfiles -nodefaultlibs -fno-common -ffreestanding $(OPTIMIZATION)

QEMU = qemu-system-x86_64
QEMU_FLAGS = -M pc -no-reboot -m 512M -monitor stdio

DISK_IMG = out/disk.img

.PHONY: build install-boot run

$(ASM_BOOT_SRCS): $(ASM_BOOT_INCL_FILES)

out/boot/%.o: boot/%.asm $(ASM_BOOT_SRCS) $(ASM_BOOT_INCL_FILES)
	@mkdir -p $(@D)
	nasm -f bin $< -iboot -o $@

test:
	echo $(ASM_BOOT_OBJS)

build: $(ASM_BOOT_OBJS)
	@./disk.sh
	@./install-boot.sh

run:
	$(MAKE) build
	$(QEMU) $(QEMU_FLAGS) -drive format=raw,file=$(DISK_IMG) 

debug:
	$(MAKE) build
	$(QEMU) $(QEMU_FLAGS) -drive format=raw,file=$(DISK_IMG) -s -S -no-shutdown

dump-fs1:
	xxd -l 0x10000 -o 0x10000 out/disk.img > fat1.dump

clear:
	make clean
	clear

clean:
	@rm -rf out
	@rm -rf *.mem
	@rm -rf *.dump
