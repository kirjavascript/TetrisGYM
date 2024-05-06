use rusticnes_core::nes::NesState;
use rusticnes_core::{ cartridge, opcodes, opcode_info };
use crate::labels;

pub fn emulator(rom: Option<&[u8]>) -> NesState {
    let rom = rom.unwrap_or(include_bytes!("../../tetris.nes"));
    let mut emu = NesState::new(Box::new(cartridge::mapper_from_file(rom)).unwrap());

    emu.power_on();

    emu
}

pub fn run_to_return(emu: &mut NesState, print: bool) {
    opcodes::push(emu, 0);
    opcodes::push(emu, 0);

    loop {
        if print {
            print_step(emu);
        } else {
            emu.step();
        }

        if emu.registers.pc < 3 {
            break;
        }
    }
}

pub fn cycles_to_return(emu: &mut NesState) -> u32 {
    opcodes::push(emu, 0);
    opcodes::push(emu, 0);

    let mut cycles = 0;

    loop {
        cycles += 1;
        emu.cycle();

        if emu.registers.pc < 3 {
            break;
        }
    }

    cycles
}

pub fn print_step(emu: &mut NesState) {
    if let Some(label) = labels::from_addr(emu.registers.pc) {
        println!("{}:", label);
    }

    print!("{:x} ", emu.registers.pc);

    emu.step();

    println!("{}", opcode_info::disassemble_instruction(emu.cpu.opcode, 0, 0).0);
}

pub const fn _ppu_addr_to_xy(ppu_addr: u16) -> (u8, u8) {
    const SCREEN_WIDTH: u16 = 256 / 8;
    const SCREEN_HEIGHT: u16 = 240 / 8;

    let base_address = ppu_addr & 0x2C00;

    let (base_x, base_y) = match base_address {
        0x2000 => (0, 0),
        0x2400 => (1, 0),
        0x2800 => (0, 1),
        0x2C00 => (1, 1),
        _ => panic!("Invalid PPU address"),
    };

    let offset = ppu_addr - base_address;

    let x = base_x * SCREEN_WIDTH + (offset % 32);
    let y = base_y * SCREEN_HEIGHT + (offset / 32);

    (x as _, y as _)
}

pub const fn _xy_to_ppu_addr(x: u16, y: u16) -> u16 {
    const SCREEN_WIDTH: u16 = 256 / 8;
    const SCREEN_HEIGHT: u16 = 240 / 8;

    let offset = (y * 32) + x;

    let base_address = match (x / SCREEN_WIDTH, y / SCREEN_HEIGHT) {
        (0, 0) => 0x2000,
        (1, 0) => 0x2400,
        (0, 1) => 0x2800,
        (1, 1) => 0x2C00,
        _ => panic!("Invalid (x, y) position"),
    };

    base_address + offset
}
