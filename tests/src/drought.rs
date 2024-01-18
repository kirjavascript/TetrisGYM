use crate::{labels, util, block};

pub fn print_probabilities() {
    let mut emu = util::emulator(None);
    let rng_seed = labels::get("rng_seed");
    let drought_modifier = labels::get("droughtModifier");
    let next_rng = labels::get("pickRandomTetrimino");

    emu.memory.iram_raw[labels::get("practiseType") as usize] = labels::get("MODE_DROUGHT") as u8;

    for modifier in 0..19 {
        emu.memory.iram_raw[drought_modifier as usize] = modifier;

        let seed = 0x8988;
        emu.memory.iram_raw[(rng_seed + 0) as usize] = (seed >> 8) as _;
        emu.memory.iram_raw[(rng_seed + 1) as usize] = seed as u8;

        let mut longbars = 0;
        let mut total = 0;

        for _ in 0..100000 {
            emu.registers.pc = next_rng;

            util::run_to_return(&mut emu, false);

            let block: block::Block = emu.memory.iram_raw[labels::get("spawnID") as usize].into();

            if block == block::Block::I {
                longbars += 1;
            }

            total += 1;
        }
        println!(
            "{} longbar%: {:.2}",
            "0123456789ABCDEFGHI".as_bytes()[modifier as usize] as char,
            (longbars as f64 / total as f64) * 100.
        );
    }
}
