use rusticnes_core::nes::NesState;
use rusticnes_core::{ cartridge, opcodes, opcode_info };
use crate::labels;

pub fn emulator(rom: Option<&[u8]>) -> NesState {
    let rom = rom.unwrap_or(include_bytes!("../../tetris.nes"));
    let mut emu = NesState::new(Box::new(cartridge::mapper_from_file(rom)).unwrap());

    emu.power_on();

    emu
}

pub fn run_to_return(emu: &mut NesState) {
    opcodes::push(emu, 0);
    opcodes::push(emu, 0);

    loop {
        print_step(emu);

        if emu.registers.pc < 3 {
            break;
        }
    }
}

pub fn print_step(emu: &mut NesState) {
    if let Some(label) = labels::from_addr(emu.registers.pc) {
        println!("{}:", label);
    }

    print!("{:x} ", emu.registers.pc);

    emu.step();

    println!("{}", opcode_info::disassemble_instruction(emu.cpu.opcode, 0, 0).0);
}
