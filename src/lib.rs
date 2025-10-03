#![no_std]
#![no_main]

use core::panic::PanicInfo;

const VGA_BUFFER: *mut u8 = 0xB8000 as *mut u8;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

fn print_string(s: &str) {
    let vga = VGA_BUFFER;

    // TODO(human): Implement the logic to write each character from string `s`
    // to VGA memory. Each character needs 2 bytes: the ASCII byte and a color byte.
    // Use color 0x0F (white text on black background).
    // Remember: VGA memory starts at `vga`, and you'll need unsafe code to write to raw pointers.
    for (i, byte) in s.bytes().enumerate() {
        unsafe {
            *vga.add(i * 2) = byte;
            *vga.add(i * 2 + 1) = 0x0F;
        }
    }
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    print_string("Hello from Rust!");
    loop {}
}
