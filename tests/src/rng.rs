use crate::{util, labels};
use std::collections::HashSet;

pub fn seeds() -> HashSet<u16> {
    let mut emu = util::emulator(None);
    let rng_seed = labels::get("rng_seed");
    let next_rng = labels::get("generateNextPseudorandomNumber");

    let mut seeds: HashSet<u16> = HashSet::new();

    let mut seed = 0x8988;

    loop {
        seeds.insert(seed);

        emu.memory.iram_raw[(rng_seed + 0) as usize] = (seed >> 8) as _;
        emu.memory.iram_raw[(rng_seed + 1) as usize] = seed as u8;

        emu.registers.x = rng_seed as u8;
        emu.registers.y = 0x2;
        emu.registers.pc = next_rng;

        util::run_to_return(&mut emu, false);

        seed =
            ((emu.memory.iram_raw[rng_seed as usize] as u16) << 8)
            + emu.memory.iram_raw[(rng_seed + 1) as usize] as u16;

        if seed == 0x8988 {
            break;
        }
    }

    seeds
}

pub fn test() {
    assert_eq!(
        seeds(),
        include_str!("./rng_seeds.txt")
            .split(',')
            .map(|s| s.trim().parse::<u16>().expect(s))
            .collect::<HashSet<_>>()
    );
}
