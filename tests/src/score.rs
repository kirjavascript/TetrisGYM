use rusticnes_core::nes::NesState;
use crate::{labels, score, util};

pub fn set(emu: &mut NesState, score: u32) {
    let score_addr = labels::get("score");
    let binscore_addr = labels::get("binScore");
    let bcd_str = format!("{:08}", score);
    let bcd_a = i64::from_str_radix(&bcd_str[0..2], 16).unwrap();
    let bcd_b = i64::from_str_radix(&bcd_str[2..4], 16).unwrap();
    let bcd_c = i64::from_str_radix(&bcd_str[4..6], 16).unwrap();
    let bcd_d = i64::from_str_radix(&bcd_str[6..8], 16).unwrap();

    emu.memory.iram_raw[(score_addr + 3) as usize] = bcd_a as u8;
    emu.memory.iram_raw[(score_addr + 2) as usize] = bcd_b as u8;
    emu.memory.iram_raw[(score_addr + 1) as usize] = bcd_c as u8;
    emu.memory.iram_raw[score_addr as usize] = bcd_d as u8;
    emu.memory.iram_raw[binscore_addr as usize] = score as u8;
    emu.memory.iram_raw[(binscore_addr + 1) as usize] = (score >> 8) as u8;
    emu.memory.iram_raw[(binscore_addr + 2) as usize] = (score >> 16) as u8;
    emu.memory.iram_raw[(binscore_addr + 3) as usize] = (score >> 24) as u8;
}

pub fn get(emu: &mut NesState) -> u32 {
    let binscore_addr = labels::get("binScore");
    emu.memory.iram_raw[binscore_addr as usize] as u32
        + ((emu.memory.iram_raw[(binscore_addr + 1) as usize] as u32) << 8)
        + ((emu.memory.iram_raw[(binscore_addr + 2) as usize] as u32) << 16)
}

pub fn test() {
    let mut emu = util::emulator(None);

    let completed_lines = labels::get("completedLines") as usize;
    let add_points = labels::get("addPointsRaw");
    let level_number = labels::get("levelNumber") as usize;

    let mut score = move |score: u32, lines: u8, level: u8| {
        score::set(&mut emu, score);
        emu.registers.pc = add_points;
        emu.memory.iram_raw[completed_lines] = lines;
        emu.memory.iram_raw[level_number] = level;
        util::run_to_return(&mut emu, false);
        score::get(&mut emu)
    };

    // check every linecount on every level
    for level in 0..=255 {
        for lines in 0..=4 {
            assert_eq!(score(0, lines, level), score_impl(lines, level));
        }
    }

    // check tetris value from lots of scores
    for initial_score in 999499..=1000501 {
        assert_eq!(score(initial_score, 4, 18), initial_score + score_impl(4, 18));
    }
}

pub fn score_impl(lines: u8, level: u8) -> u32 {
    [0, 40, 100, 300, 1200][lines as usize] * (level as u32 + 1)
}

pub fn test_render() {
    let mut emu = util::emulator(None);

    let rendered_score = |emu: &mut NesState| {
        let vram_offset = emu.ppu.current_vram_address - 6;

        (vram_offset..vram_offset + 6)
            .map(|i| emu.ppu.read_byte(&mut *emu.mapper, i))
            .collect::<Vec<u8>>()
    };

    // check classic score rendering works

    for i in 0..1000 {
        let score = i * 100000;

        score::set(&mut emu, score);
        emu.registers.pc = labels::get("renderClassicScore");
        util::run_to_return(&mut emu, false);

        assert_eq!((i % 16) as u8, rendered_score(&mut emu)[0]);
    }

    // check letter score rendering works

    for i in 0..256 { // TODO: fix breaking at 25.5m
        let score = i * 100000;

        score::set(&mut emu, score);
        emu.registers.pc = labels::get("renderLettersScore");
        util::run_to_return(&mut emu, false);

        assert_eq!((i % 36) as u8, rendered_score(&mut emu)[0]);
    }

    // check score cap works

    for score in [8952432, 999999, 1000000, 1000010, 10000000, 100000000] {
        score::set(&mut emu, score);
        emu.registers.pc = labels::get("renderScoreCap");
        util::run_to_return(&mut emu, false);
        assert_eq!(vec![9, 9, 9, 9, 9, 9], rendered_score(&mut emu));
    }

    for score in [100000, 512345, 999998] {
        score::set(&mut emu, score);
        emu.registers.pc = labels::get("renderScoreCap");
        util::run_to_return(&mut emu, false);
        assert_ne!(vec![9, 9, 9, 9, 9, 9], rendered_score(&mut emu));
    }
}
