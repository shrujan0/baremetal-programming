//we are not using std library, and no standard main fucntion
#![no_std]
#![no_main]

//to use raw pointers without safety check
use core::ptr;

//import linker symbols from linker file, using C interface
unsafe extern "C" {
    unsafe static mut _sdata: u32;
    unsafe static mut _edata: u32;
    unsafe static _sidata: u32;
    unsafe static mut _sbss: u32;
    unsafe static mut _ebss: u32;
    unsafe static _estack: u32;
}

//vector table
//#[repr(C)] the data is stored without padding like C struct
#[repr(C)]
pub struct VectorTable {
    pub initial_sp: &'static u32,
    pub reset_handler: unsafe extern "C" fn() -> !,
}

#[unsafe(link_section = ".isr_vector")]
#[unsafe(no_mangle)]
pub static ISR_VECTOR: VectorTable = VectorTable {
    initial_sp: unsafe { &_estack },
    reset_handler: Reset_Handler,
};

//reset handler
#[unsafe(no_mangle)]
pub unsafe extern "C" fn Reset_Handler() -> ! {
    let mut data_ram_ptr = ptr::addr_of_mut!(_sdata) as *mut u32;
    let data_ram_end = ptr::addr_of_mut!(_edata) as *mut u32;
    let mut data_flash_ptr = ptr::addr_of!(_sidata) as *const u32;

    while data_ram_ptr < data_ram_end {
        unsafe {
            ptr::write(data_ram_ptr, ptr::read(data_flash_ptr));
            data_ram_ptr = data_ram_ptr.add(1);
            data_flash_ptr = data_flash_ptr.add(1);
        }
    }

    let mut bss_ptr = ptr::addr_of_mut!(_sbss) as *mut u32;
    let bss_end = ptr::addr_of_mut!(_ebss) as *mut u32;

    while bss_ptr < bss_end {
        unsafe {
            ptr::write_volatile(bss_ptr,0);
            bss_ptr = bss_ptr.add(1);
        }
    }
    
    //run the main program
    main()
}

//register addresses
const RCC_AHB1ENR: *mut u32 = 0x40023830 as *mut u32;
const GPIOC_MODER: *mut u32 = 0x40020800 as *mut u32;
const GPIOC_ODR: *mut u32 = 0x40020814 as *mut u32;

fn main() -> ! {
    unsafe {
        //enable clock for GPIOC
        let mut ahb1enr = ptr::read_volatile(RCC_AHB1ENR);
        ahb1enr |= 1 << 2;
        ptr::write_volatile(RCC_AHB1ENR, ahb1enr);

        //set GPIOC as output
        let mut gpiocmoder = ptr::read_volatile(GPIOC_MODER);
        gpiocmoder &= !(1 << 27);
        gpiocmoder |= 1 << 26;
        ptr::write_volatile(GPIOC_MODER,gpiocmoder);
    }
    
    loop {
        //led off (setting 1 (high) turns led off in my board)
        unsafe {
            let mut gpioc_odr = ptr::read_volatile(GPIOC_ODR);
            gpioc_odr |= 1 << 13;
            ptr::write_volatile(GPIOC_ODR, gpioc_odr);
        }

        for _ in 0..1000000 {
            unsafe { core::arch::asm!("nop"); }
        }

        //led on
        unsafe {
            let mut gpioc_odr = ptr::read_volatile(GPIOC_ODR);
            gpioc_odr &= !(1 << 13);
            ptr::write_volatile(GPIOC_ODR, gpioc_odr);
        }

        for _ in 0..1000000 {
            unsafe { core::arch::asm!("nop"); }
        }
    }
}

//loop infinitely in case of program crash
#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}