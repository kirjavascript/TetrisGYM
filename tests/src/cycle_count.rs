use crate::{util, score, labels};

pub fn count_cycles() {
    let mut emu = util::emulator(None);

    let completed_lines = labels::get("completedLines") as usize;
    let add_points = labels::get("addPointsRaw");
    let level_number = labels::get("levelNumber") as usize;

    let mut score = move |score: u32, lines: u8, level: u8| {
        score::set(&mut emu, score);
        emu.registers.pc = add_points;
        emu.memory.iram_raw[completed_lines] = lines;
        emu.memory.iram_raw[level_number] = level;
        util::cycles_to_return(&mut emu)
    };

    let mut highest = 0;

    // check every linecount on every level
    for level in 0..=255 {
        for lines in 0..=4 {
            let count = score(999999, lines, level);

            if count > highest {
                highest = count;
            }
        }
    }

    println!("scoring routine most cycles: {}", highest);
}
