#!Makefile

C_SOURCES = $(shell find . -name "*.c")
C_OBJECTS = $(patsubst %.c, %.o, $(C_SOURCES))

S_SOURCES = $(shell find . -name "*.s")
S_OBJECTS = $(patsubst %.s, %.o, $(S_SOURCES))

CC = gcc
LD = ld
ASM = nasm

C_FLAGS = -c -Wall -m32 -ggdb -gstabs+ -nostdinc -fno-pic -fno-builtin -fno-stack-protector -I include
LD_FLAGS = -T scripts/Kernel.ld -m elf_i386 -nostdlib
ASM_FLAGS = -f elf -g -F stabs

all: $(S_OBJECTS) $(C_OBJECTS) link update_image

.c.o:
	@echo compile .c files $< ...
	$(CC) $(C_FLAGS) $< -o $@

.s.o:
	@echo compile .s files $< ...
	$(ASM) $(ASM_FLAGS) $<
	
link:
	@echo link kernel files ...
	$(LD) $(LD_FLAGS) $(S_OBJECTS) $(C_OBJECTS) -o zm_kernel

.PHONY:update_image
update_image:
	sudo mount floppy.img /mnt/kernel
	sudo cp zm_kernel /mnt/kernel/zm_kernel
	sleep 1
	sudo umount /mnt/kernel

.PHONY:mount_image
mount_image:
	sudo mount floopy.img /mnt/kernel

.PHONY:umount_image
umount_image:
	sudo umount /mnt/kernel


.PHONY:qemu
qemu:
	qemu  -fda floopy.img -boot a

.PHONY:debug
debug:
	qemu -S -s fda floopy.image -boot a &
	sleep 1
	dgdb -x tools/gdbinit

