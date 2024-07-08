use crate::{block, labels, util};
use rusticnes_core::nes::NesState;

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
        self.emu.memory.iram_raw[labels::get("spawnID") as usize] = 0;
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

pub fn test() {
    let mut blocks = SPS::new();

    blocks.set_input((0x10, 0x10, 0x10));
    "ZJOTLTZJLZJSZISIJOLITJSILZJILITSISZOITIZSZJLLTIOZJZSZISIJZTIZJTSOJSJISJOOTSJTOTZSZTZSLTZTOTSIZJZIJIL".chars().for_each(|block| {
        assert_eq!(blocks.next(), block.into());
    });

    blocks.set_input((0x12, 0x34, 0x56));
    "ZTZIJIJOZTSOSZJZOSLIOIJIJSTZSTTJISSTOIZJITJOZJITSOSZSJLTISJOITTLSLJTZTZOZSLJTJZSLTSOTLOJLSJSJTJILOJS".chars().for_each(|block| {
        assert_eq!(blocks.next(), block.into());
    });

    blocks.set_input((0x87, 0xAB, 0x12));
    "OZIJSOTZSJTSTJZLOLJOJISOZOIOZJITILSSJZLOIJSTITLSOJILTSOOLZOOIJOZLTLSISIJIJTOLSIJILSLOLJLTOSOSLOIZSIS".chars().for_each(|block| {
        assert_eq!(blocks.next(), block.into());
    });

    blocks.set_input((0x13, 0x37, 0x02));
    "OJSTZSIOLSIJTSZILJZJJLZLISISJTLZTSZTJOJOSJSZLITJOIOTITILTOSTJSZTSOOIOJSIITLJOZSIOJOTZTLJLIOJLITSSLSLIJIIOLOISLZJLIJJTIZIJOJISLTIJTOTZIOILSTTLTZIZJSOLOZOZOLOTZTZOTZOSIOTJJTSIZSOLTOLIZSOZOTZISLJTSZLOISO".chars().for_each(|block| {
        assert_eq!(blocks.next(), block.into());
    });
}
