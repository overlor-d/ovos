.PHONY: all boot run clean stat signature

all: run

boot:
	mkdir -p iso/boot
	nasm -f bin stage1.asm -o stage1.bin
	nasm -f bin stage2.asm -o stage2.bin
	cat stage1.bin stage2.bin > iso/boot/boot.img
	@test `stat --format="%s" stage1.bin` -eq 512 || (echo "boot.img doit faire 512 octets"; exit 1)
	@test "`od -An -t x1 -j 510 -N 2 stage1.bin | tr -d ' ' | tr -d '\n'`" = "55aa" || (echo "Signature boot manquante"; exit 1)
	@echo "boot.img est valide"

run: boot
	qemu-system-x86_64 \
	-drive file=./iso/boot/boot.img,format=raw,index=0,media=disk \
	-m 512M \
	-boot c

debug : boot
	qemu-system-x86_64 \
	-machine type=pc,accel=tcg \
	-drive file=./iso/boot/boot.img,format=raw,if=ide \
	-m 512M \
	-s -S \
	-boot c

clean:
	rm -f ovos.iso
	rm -rf iso/
	rm -f stage1.bin stage2.bin

stat:
	@echo "Taille du fichier boot.img :"
	@stat --format="%s" iso/boot/boot.img

signature:
	@echo "Signature du boot.img (attendue : 55aa) :"
	@od -An -t x1 -j 510 -N 2 stage1.bin | tr -d " " | tr -d "\n"

kernel:
	x86_64-elf-gcc -ffreestanding -m64 -c mdoules/kernel.c -o kernel.o
