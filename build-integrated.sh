#!/bin/bash
set -e

echo "==> Building integrated Rust + Assembly bootloader..."

# Step 1: Build Rust code
echo "[1/6] Compiling Rust code..."
cargo +nightly build --release

# Step 2: Assemble boot.asm to object file
echo "[2/6] Assembling boot.asm..."
nasm -f elf32 boot.asm -o boot.o

# Step 3: Link assembly and Rust together
echo "[3/6] Linking boot.o with Rust..."
rust-lld -flavor gnu -m elf_i386 -T linker-combined.ld -o bootloader.elf \
    boot.o \
    target/i686-bootloader/release/libx86_bootloader.a

# Step 4: Extract raw binary
echo "[4/6] Extracting raw binary..."
rust-objcopy --binary-architecture=i386 -O binary bootloader.elf bootloader-raw.bin

# Step 5: Create proper boot sector (pad to 510 bytes + add signature)
echo "[5/6] Creating boot image..."
# Take first 510 bytes (or pad if smaller)
dd if=bootloader-raw.bin of=bootloader.bin bs=510 count=1 conv=sync 2>/dev/null
# Add boot signature
echo -en '\x55\xAA' >> bootloader.bin
# Append the rest of the code (Rust part)
dd if=bootloader-raw.bin of=bootloader.bin bs=1 skip=512 seek=512 2>/dev/null || true

echo "[6/6] Done!"
ls -lh bootloader.bin
echo "Boot image created: bootloader.bin"
echo "Run with: qemu-system-i386 -drive format=raw,file=bootloader.bin"
