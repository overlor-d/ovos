.PHONY: all boot run clean stat signature

all: run

boot:
	mkdir -p iso/boot
	nasm -f bin boot.asm -o iso/boot/boot.img
	@test `stat --format="%s" iso/boot/boot.img` -eq 512 || (echo "boot.img doit faire 512 octets"; exit 1)
	@test "`xxd -p -s -2 iso/boot/boot.img`" = "55aa" || (echo "Signature boot manquante"; exit 1)
	@echo "boot.img est valide"

run: boot
	qemu-system-x86_64 \
	-machine type=pc,accel=tcg \
	-m 16M \
	-drive file=./iso/boot/boot.img,format=raw,if=ide \
	-no-reboot \
	-no-shutdown \
	-serial mon:stdio

debug : boot
	qemu-system-i386 \
	-machine type=pc,accel=tcg \
	-drive file=./iso/boot/boot.img,format=raw,if=ide \
	-no-reboot \
	-no-shutdown \
	-s -S \
	-vga std

clean:
	rm -f ovos.iso
	rm -rf iso/

stat:
	@echo "Taille du fichier boot.img :"
	@stat --format="%s" iso/boot/boot.img

signature:
	@echo "Signature du boot.img (attendue : 55aa) :"
	@xxd -p -s -2 iso/boot/boot.img
