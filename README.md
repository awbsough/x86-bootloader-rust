# x86 Bootloader in Rust

A bare-metal x86 bootloader written in Rust and assembly that boots from BIOS, transitions from 16-bit real mode to 32-bit protected mode, and displays "Hello from Rust!" on the screen.

## What It Does

1. **Stage 1 (Assembly)**: BIOS loads the 512-byte boot sector, which:
   - Clears the screen
   - Loads additional sectors from disk using BIOS interrupt 0x13
   - Sets up a Global Descriptor Table (GDT)
   - Switches the CPU from 16-bit real mode to 32-bit protected mode

2. **Stage 2 (Rust)**: Executes `no_std` Rust code that:
   - Writes directly to VGA text memory at `0xB8000`
   - Displays text without any operating system

## Technical Details

- **Target**: i686 (32-bit x86)
- **Boot Method**: BIOS legacy boot
- **Memory Layout**:
  - `0x7C00`: Boot sector (512 bytes)
  - `0x7E00`: Rust code loaded from disk
  - `0xB8000`: VGA text buffer
  - `0x90000`: Stack

## Prerequisites

- Rust nightly toolchain
- NASM assembler
- QEMU emulator (for testing)

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install nightly and components
rustup toolchain install nightly
rustup component add rust-src llvm-tools-preview --toolchain nightly
cargo install cargo-binutils

# Install NASM and QEMU
brew install nasm qemu
```

## Building

```bash
./build-integrated.sh
```

This will:
1. Compile the Rust library
2. Assemble the boot sector
3. Link them together
4. Create a bootable disk image (`bootloader.bin`)

## Running

```bash
qemu-system-i386 -drive format=raw,file=bootloader.bin
```

You should see "Hello from Rust!" displayed on the screen.

## Project Structure

```
.
├── boot.asm              # 16-bit assembly bootloader (stage 1)
├── src/lib.rs            # Rust bootloader code (stage 2)
├── i686-bootloader.json  # Custom target specification
├── linker-combined.ld    # Linker script for memory layout
└── build-integrated.sh   # Build script
```

## Learning Resources

- [OSDev Wiki](https://wiki.osdev.org/) - Operating system development
- [Writing an OS in Rust](https://os.phil-opp.com/) - Philipp Oppermann's blog series
- [Intel® 64 and IA-32 Architectures Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

## License

MIT
