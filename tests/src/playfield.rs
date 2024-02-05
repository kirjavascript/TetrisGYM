use rusticnes_core::nes::NesState;
use crate::labels;

pub fn set(emu: &mut NesState, x: u16, y: u16, value: u8) {
    let index = ((y * 10) + x) + labels::get("playfield");
    emu.memory.iram_raw[index as usize] = value;
}

pub fn get(emu: &NesState, x: u16, y: u16) -> u8 {
    let index = ((y * 10) + x) + labels::get("playfield");
    emu.memory.iram_raw[index as usize]
}

pub fn clear(emu: &mut NesState) {
    for y in 0..20 {
        for x in 0..10 {
            self::set(emu, x, y, 0xEF);
        }
    }
}

pub fn set_str(emu: &mut NesState, playfield: &str) {
    set_str_inner(emu, playfield, false);
}

#[allow(dead_code)]
pub fn set_str_top(emu: &mut NesState, playfield: &str) {
    set_str_inner(emu, playfield, true);
}

fn set_str_inner(emu: &mut NesState, playfield: &str, top: bool) {
    let rows = playfield.trim_start_matches('\n').split("\n").collect::<Vec<_>>();
    let offset = if top {
        0
    } else {
        20 - rows.len() as u16
    };
    rows.iter().enumerate().for_each(|(y, line)| {
        line.chars().enumerate().for_each(|(x, ch)| {
            self::set(emu, x as _, offset + y as u16, if ch == '#' { 0x7b } else { 0xef });
        });
    });

}

#[allow(dead_code)]
pub fn get_str(emu: &NesState) -> String {
    let mut s = String::new();
    for y in 0..20 {
        let mut line = String::new();
        for x in 0..10 {
            line.push_str(if self::get(emu, x, y) == 0xEF { " " } else { "#" });
        }
        s.push_str(line.trim_end());
        if y != 19 {
            s.push_str("\n");
        }
    }

    s
}
