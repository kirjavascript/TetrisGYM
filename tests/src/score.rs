use rusticnes_core::nes::NesState;
use crate::labels;

pub fn set(emu: &mut NesState, score: u32) {
    let score_addr = labels::get("score");
    let binscore_addr = labels::get("binScore");
    let bcd_str = format!("{:06}", score);
    let bcd_a = i64::from_str_radix(&bcd_str[0..2], 16).unwrap();
    let bcd_b = i64::from_str_radix(&bcd_str[2..4], 16).unwrap();
    let bcd_c = i64::from_str_radix(&bcd_str[4..6], 16).unwrap();

    emu.memory.iram_raw[(score_addr + 2) as usize] = bcd_a as u8;
    emu.memory.iram_raw[(score_addr + 1) as usize] = bcd_b as u8;
    emu.memory.iram_raw[score_addr as usize] = bcd_c as u8;
    emu.memory.iram_raw[binscore_addr as usize] = score as u8;
    emu.memory.iram_raw[(binscore_addr + 1) as usize] = (score >> 8) as u8;
    emu.memory.iram_raw[(binscore_addr + 2) as usize] = (score >> 16) as u8;
}

pub fn get(emu: &mut NesState) -> u32 {
    let binscore_addr = labels::get("binScore");
    emu.memory.iram_raw[binscore_addr as usize] as u32
        + ((emu.memory.iram_raw[(binscore_addr + 1) as usize] as u32) << 8)
        + ((emu.memory.iram_raw[(binscore_addr + 2) as usize] as u32) << 16)
}
