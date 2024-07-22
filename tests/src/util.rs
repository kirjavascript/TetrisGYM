use rusticnes_core::nes::NesState;
use rusticnes_core::{ cartridge, opcodes, opcode_info };
use crate::{input, labels};

pub static ROM: &'static [u8] = include_bytes!("../../tetris.nes");

pub fn rom_data() -> &'static [u8] {
    &ROM[0x10..]
}

pub fn emulator(rom: Option<&[u8]>) -> NesState {
    let rom = rom.unwrap_or(ROM);
    let mut emu = NesState::new(Box::new(cartridge::mapper_from_file(rom)).unwrap());

    emu.power_on();

    emu
}

pub fn run_n_vblanks(emu: &mut NesState, n: usize) {
    for _ in 0..n {
        emu.run_until_vblank();
    }
}

// emu.p1_input inverts the traditional bit assignments for the controller
// (e.g. 0x01 corresponds to A) to more accurately emulate how bits are read
// in.
pub fn set_controller_raw(emu: &mut NesState, buttons: u8) {
    let mut flipped_buttons = 0u8;
    for i in 0..8 {
        flipped_buttons |= ((buttons >> i) & 1) << (7-i);
    }
    emu.p1_input = flipped_buttons;
}

pub fn set_controller(emu: &mut NesState, button: char) {
    set_controller_raw(emu, match button {
        'L' => input::LEFT,
        'R' => input::RIGHT,
        'D' => input::DOWN,
        'U' => input::UP,
        'A' => input::A,
        'B' => input::B,
        'S' => input::START,
        'T' => input::SELECT,
        '.' => 0,
        _ => panic!("character '{}' cannot be used as controller input", button),
    });
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

pub fn cycles_to_vblank(emu: &mut NesState) -> u32 {
    let vblank = labels::get("verticalBlankingInterval") as usize;
    let mut cycles = 0;
    let mut done = false;

    while emu.ppu.current_scanline == 242 {
        emu.cycle();
        if !done {
            cycles += 1;
            if emu.memory.iram_raw[vblank] == 1 {
                done = true;
            }
        }
        let mut i = 0;
        while emu.cpu.tick >= 1 && i < 10 {
            emu.cycle();
            if !done {
                cycles += 1;
                if emu.memory.iram_raw[vblank] == 1 {
                    done = true;
                }
            }
            i += 1;
        }
        if emu.ppu.current_frame != emu.last_frame {
            emu.event_tracker.swap_buffers();
            emu.last_frame = emu.ppu.current_frame;
        }
    }
    emu.memory.iram_raw[vblank] = 1;
    done = false;
    while emu.ppu.current_scanline != 242 {
        emu.cycle();
        if !done {
            cycles += 1;
            if emu.memory.iram_raw[vblank] == 0 {
                done = true;
            }
        }
        let mut i = 0;
        while emu.cpu.tick >= 1 && i < 10 {
            emu.cycle();
            if !done {
                cycles += 1;
                if emu.memory.iram_raw[vblank] == 0 {
                    done = true;
                }
            }
            i += 1;
        }
        if emu.ppu.current_frame != emu.last_frame {
            emu.event_tracker.swap_buffers();
            emu.last_frame = emu.ppu.current_frame;
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
