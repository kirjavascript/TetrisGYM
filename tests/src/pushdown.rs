use crate::{labels, util, score};

pub fn test() {
    let mut emu = util::emulator(None);

    for pushdown in 2..15 {
        [0..1000, 24500..25500].into_iter().for_each(|range| {
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
// may seem weird - designed to be translated to assembly
fn pushdown_impl(pushdown: u8, score: u16) -> u16 {
    let ones = score % 10;
    let hundredths = score % 100;
    let mut newscore = ones as u8 + (pushdown - 1);
    if newscore & 0xF > 9 {
        newscore += 6;
    }

    let low = (newscore & 0xF) as u16;
    let high = ((newscore & 0xF0) / 16 * 10) as u16;

    let mut newscore = high + (hundredths - ones);
    let nextscore = newscore + low;

    if nextscore <= 100 {
        newscore = nextscore;
    }

    newscore + (score - hundredths) - score
}
