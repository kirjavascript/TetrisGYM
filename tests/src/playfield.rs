use rusticnes_core::nes::NesState;
use crate::{labels};

pub fn set(emu: &mut NesState, x: u16, y: u16, value: u8) {
    let index = ((y * 10) + x) + labels::get("playfield");
    emu.memory.iram_raw[index as usize] = value;
}

pub fn get(emu: &mut NesState, x: u16, y: u16) -> u8 {
    let index = ((y * 10) + x) + labels::get("playfield");
    emu.memory.iram_raw[index as usize]
}

#[allow(dead_code)]
pub fn clear(emu: &mut NesState) {
    for line in 0..20 {
        self::fill_line(emu, line);
    }
}

#[allow(dead_code)]
pub fn fill_line(emu: &mut NesState, y: u16) {
    for x in 0..10 {
        self::set(emu, x, y, labels::get("BLOCK_TILES") as _);
    }
}

pub fn set_str(emu: &mut NesState, playfield: &str) {
    let rows = playfield.trim_start_matches('\n').split("\n").collect::<Vec<_>>();
    let offset = 20 - rows.len() as u16;
    rows.iter().enumerate().for_each(|(y, line)| {
        line.chars().enumerate().for_each(|(x, ch)| {
            self::set(emu, x as _, offset + y as u16, if ch == '#' { 0x7b } else { 0xef });
        });
    });
}

#[allow(dead_code)]
pub fn get_str(emu: &mut NesState) -> String {
    let mut s = String::new();
    for y in 0..20 {
        for x in 0..10 {
            s.push_str(if self::get(emu, x, y) == 0xEF { " " } else { "#" });
        }
        s.push_str("\n");
    }

    s
}
