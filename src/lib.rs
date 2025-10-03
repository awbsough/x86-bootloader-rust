#![no_std]
#![no_main]

use core::panic::PanicInfo;

const VGA_BUFFER: *mut u8 = 0xB8000 as *mut u8;
const VGA_WIDTH: usize = 80;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

// Delay function for animation timing
fn delay(count: u32) {
    for _ in 0..count {
        unsafe { core::arch::asm!("nop") };
    }
}

// Write string at specific row and column with color
fn write_at(row: usize, col: usize, s: &str, color: u8) {
    let offset = (row * VGA_WIDTH + col) * 2;
    for (i, byte) in s.bytes().enumerate() {
        unsafe {
            *VGA_BUFFER.add(offset + i * 2) = byte;
            *VGA_BUFFER.add(offset + i * 2 + 1) = color;
        }
    }
}

// Animate text appearing character by character
fn animate_text(row: usize, col: usize, s: &str, color: u8) {
    let offset = (row * VGA_WIDTH + col) * 2;
    for (i, byte) in s.bytes().enumerate() {
        unsafe {
            *VGA_BUFFER.add(offset + i * 2) = byte;
            *VGA_BUFFER.add(offset + i * 2 + 1) = color;
        }
        delay(5_000_000);  // Delay between characters
    }
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    // ASCII Art Rust Logo
    write_at(5, 25, "  ____           _   ", 0x0C);  // Red
    write_at(6, 25, " |  _ \\ _   _ __| |_ ", 0x0C);
    write_at(7, 25, " | |_) | | | / _` __|", 0x0C);
    write_at(8, 25, " |  _ <| |_| \\__ \\ |_", 0x0C);
    write_at(9, 25, " |_| \\_\\\\__,_|___/\\__|", 0x0C);

    delay(30_000_000);

    // Animated boot message
    animate_text(11, 20, "x86 Bootloader", 0x0F);  // White
    delay(10_000_000);

    animate_text(13, 15, "[*] Switching to Protected Mode... OK", 0x0A);  // Green
    delay(10_000_000);

    animate_text(14, 15, "[*] Loading Rust Kernel............ OK", 0x0A);
    delay(10_000_000);

    animate_text(15, 15, "[*] Initializing VGA Driver........ OK", 0x0A);
    delay(10_000_000);

    // Final message with color gradient
    write_at(18, 22, "Boot Complete!", 0x0E);  // Yellow

    delay(20_000_000);

    // Fun ending
    write_at(20, 18, "Written in Rust + Assembly", 0x09);  // Blue

    loop {}
}
