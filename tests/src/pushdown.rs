use crate::{labels, util, score};

pub fn test() {
    let mut emu = util::emulator(None);

    for pushdown in 2..15 {
        [0..1000, 24500..25500, 60000..65536].into_iter().for_each(|range| {
            for score in range {
                score::set(&mut emu, score);

                emu.registers.pc = labels::get("addPushDownPoints");
                emu.memory.iram_raw[labels::get("holdDownPoints") as usize] = pushdown;

                util::run_to_return(&mut emu, false);

                let reference = pushdown_impl(pushdown, score as u16) as u32;

                assert_eq!(reference, score::get(&mut emu) - score);
            }
        });
    }
}

// reference implementation - tested against the original game
fn pushdown_impl(pushdown: u8, score: u16) -> u16 {
    let ones = score % 10;
    let hundredths = score % 100;

    let mut added = ones + (pushdown as u16 - 1);

    if added & 0xF > 9 {
        added += 6;
    }

    let low = added & 0xF;
    let high = (added >> 4) * 10;

    if high + low + hundredths - ones <= 100 {
        high + low - ones
    } else {
        high - ones
    }
}
