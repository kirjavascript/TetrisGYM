use rusticnes_core::nes::NesState;
use crate::{labels, util, block};

pub struct SPS {
    emu: NesState,
}

impl SPS {
    pub fn new() -> Self {
        Self {
            emu: util::emulator(None),
        }
    }

    pub fn set_input(&mut self, seed: (u8, u8, u8)) {
        self.emu.memory.iram_raw[(labels::get("set_seed_input") + 0) as usize] = seed.0;
        self.emu.memory.iram_raw[(labels::get("set_seed") + 0) as usize] = seed.0;
        self.emu.memory.iram_raw[(labels::get("set_seed_input") + 1) as usize] = seed.1;
        self.emu.memory.iram_raw[(labels::get("set_seed") + 1) as usize] = seed.1;
        self.emu.memory.iram_raw[(labels::get("set_seed_input") + 2) as usize] = seed.2;
        self.emu.memory.iram_raw[(labels::get("set_seed") + 2) as usize] = seed.2;
    }

    pub fn next(&mut self) -> block::Block {
        self.emu.registers.pc = labels::get("pickTetriminoSeed");

        util::run_to_return(&mut self.emu, false);

        self.emu.memory.iram_raw[labels::get("spawnID") as usize].into()
    }
}
