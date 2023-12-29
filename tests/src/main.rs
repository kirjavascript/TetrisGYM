use rusticnes_core::nes::NesState;
use rusticnes_core::cartridge;

mod labels;

fn main() {
    let rom = include_bytes!("../../tetris.nes");
    let mut emu = NesState::new(Box::new(cartridge::mapper_from_file(rom)).unwrap());

    emu.registers.pc = labels::get(".addPushDownPoints");

    // set pc
    // set stackpointer to something absurd
}
