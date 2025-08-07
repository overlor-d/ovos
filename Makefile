.PHONY: all boot run clean stat signature

all: run

boot:
	mkdir -p iso/boot
	nasm -f bin stage1.asm -o stage1.bin
	nasm -f bin stage2.asm -o stage2.bin

	# Vérifie que stage2.bin ne dépasse pas 64 secteurs (65024 octets)
	@test `stat --format="%s" stage2.bin` -le 65024 || (echo "stage2.bin dépasse 64 secteurs (64 Ko max)"; exit 1)

	cat stage1.bin stage2.bin ./modules/kernel.bin > iso/boot/boot.img

	# Vérifie que stage1.bin fait bien 512 octets (1 secteur)
	@test `stat --format="%s" stage1.bin` -eq 512 || (echo "stage1.bin doit faire exactement 512 octets"; exit 1)

	# Vérifie la signature BIOS à la fin de stage1.bin
	@test "`od -An -t x1 -j 510 -N 2 stage1.bin | tr -d ' ' | tr -d '\n'`" = "55aa" || (echo "Signature boot manquante dans stage1.bin"; exit 1)

	@echo "boot.img est valide (stage1 + stage2 + kernel)"

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
