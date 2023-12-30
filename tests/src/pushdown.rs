// reference implementation - tested against the original game
fn pushdown(pushdown: u8, score: u16) -> u16 {
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

    newscore + (score-hundredths) - score
}

use crate::{ labels, util };

pub fn test() {
    let mut emu = util::emulator(None);

    emu.registers.pc = labels::get(".addPushDownPoints");

    util::run_to_return(&mut emu);
}
