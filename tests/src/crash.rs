use crate::{util, playfield};

// enum for crash type
// struct for crash params

#[derive(Debug)]
struct Params {
    cleared_lines: u8,
    pushdown: u8,
    lines: (u8, u8),
    level: u8,
    cycles: u8,
    clear_count: u8,
}

pub fn fuzz() {
    let mut emu = util::emulator(Some(util::OG_ROM));

    for cleared_lines in 0..=4 {
    for pushdown in 0..1 {
        let params = Params {
            cleared_lines,
            pushdown: if pushdown == 0 { 0 } else { 8 }, // 0 / 8
            level: 155,
            lines: get_lines(155),
            clear_count: 0,
            cycles: 0,
        };
        let result = check(&mut emu, &params);

        if result.is_some() {
            println!("crash @ {:?} {:?}", result.unwrap(), params);
        }

        }
    }
    }
}

fn get_lines(level: u8) -> (u8, u8) {
    let base_lines = 120;
    let extra_lines = (level as u16 - 18) * 10;
    let lines = base_lines + extra_lines;

    let hi = lines / 100;
    let lo = lines % 100;

    (hi as u8, to_bcd(lo as u8))
}

fn to_bcd(byte: u8) -> u8 {
    let high_nibble = (byte / 10) << 4;
    let low_nibble = byte % 10;
    high_nibble | low_nibble
}

fn check(emu: &mut util::NesState, params: &Params) -> Option<u16> {
    emu.reset();

    let p1_score = 0x73;
    let score = 0x53;
    let game_mode = 0xC0;
    let level_number = 0x44;
    let p1_level_number = 0x64;
    let lines = 0x50;
    let p1_lines = 0x70;
    let main_loop = 0x8138;
    let x = 0x40;
    let y = 0x41;
    let p1_x = 0x60;
    let p1_y = 0x61;
    let current_piece = 0x42;
    let p1_current_piece = 0x62;
    let auto_repeat_y = 0x4E;
    let p1_auto_repeat_y = 0x6E;
    let frame_counter = 0xB1;
    let vrow = 0x49;
    let p1_vrow = 0x69;
    let push_down = 0x4F;
    let p1_push_down = 0x6F;
    let render_flags = 0xA3;
    let clear_count = 0xD8;
    let p1_play_state = 0x68;
    let nnb = 0xDF;

    util::run_n_vblanks(emu, 8);

    emu.memory.iram_raw[game_mode] = 4;
    emu.registers.pc = main_loop;

    util::run_n_vblanks(emu, 7);

    emu.memory.iram_raw[level_number] = params.level;
    emu.memory.iram_raw[p1_level_number] = params.level;
    emu.memory.iram_raw[lines] = params.lines.1;
    emu.memory.iram_raw[lines+1] = params.lines.0;
    emu.memory.iram_raw[p1_lines] = params.lines.1;
    emu.memory.iram_raw[p1_lines+1] = params.lines.0;
    emu.memory.iram_raw[p1_score] = 0x99;
    emu.memory.iram_raw[p1_score+1] = 0x99;
    emu.memory.iram_raw[p1_score+2] = 0x99;
    emu.memory.iram_raw[score] = 0x99;
    emu.memory.iram_raw[score+1] = 0x99;
    emu.memory.iram_raw[score+2] = 0x99;

    emu.memory.iram_raw[render_flags] = 7;

    util::run_n_vblanks(emu, 1);

    // playfield::clear(&mut emu);

    playfield::set_str_addr(emu, 0x400, match params.cleared_lines {
        0 => "",
        1 => "##### ####",
        2 => "##### ####\n##### ####",
        3 => "##### ####\n##### ####\n##### ####",
        4 => "##### ####\n##### ####\n##### ####\n##### ####",
        _ => unreachable!("line"),
    });

    emu.memory.iram_raw[current_piece] = 0x11;
    emu.memory.iram_raw[p1_current_piece] = 0x11;
    emu.memory.iram_raw[x] = 0x5;
    emu.memory.iram_raw[y] = 0x12;
    emu.memory.iram_raw[p1_x] = 0x5;
    emu.memory.iram_raw[p1_y] = 0x12;
    emu.memory.iram_raw[auto_repeat_y] = 0;
    emu.memory.iram_raw[p1_auto_repeat_y] = 0;
    emu.memory.iram_raw[frame_counter] = 0;
    emu.memory.iram_raw[vrow] = 0;
    emu.memory.iram_raw[p1_vrow] = 0;
    emu.memory.iram_raw[push_down] = params.pushdown;
    emu.memory.iram_raw[p1_push_down] = params.pushdown;
    emu.memory.iram_raw[clear_count] = params.clear_count;
    emu.memory.iram_raw[clear_count+1] = params.clear_count;
    emu.memory.iram_raw[clear_count+2] = params.clear_count;
    emu.memory.iram_raw[clear_count+3] = params.clear_count;

    for _ in 0..params.cycles {
        emu.cycle();
    }

    util::run_n_vblanks(emu, 28);

    let result = loop {
        emu.cycle();

        if emu.registers.pc == 0xAc95 {
            // read 00-01 and see if it's a corrupted value (you can catch orange-blue by checking if $01 is $00 and reds by checking if $00-01 are (and these are in the order you would see in memory, not the actual jump destination) : 20 82, AA A9(not a crash), 2C 20, 82 AA(satan, not crash), A9 EF

            let tmp0 = emu.memory.iram_raw[0];
            let tmp1 = emu.memory.iram_raw[1];
            let tmp = ((tmp0 as u16) << 8) + tmp1 as u16;

            if tmp1 == 0 || tmp == 0x2082 || tmp == 0x2C20 || tmp == 0x82AA || tmp == 0xa9ef {
                break Some(tmp);
            }
        };

        if emu.memory.iram_raw[p1_play_state] == 1 {
            break None;
        }
    };

    return result;
}
