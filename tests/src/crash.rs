use crate::{util, video, playfield};

pub fn fuzz() {
    let mut emu = util::emulator(Some(util::OG_ROM));

    emu.reset();

    util::run_n_vblanks(&mut emu, 8);

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
    let push_down = 0x4F;
    let p1_push_down = 0x6F;
    let render_flags = 0xA3;
    let clear_count = 0xD8;
    let play_state = 0x48;
    let p1_play_state = 0x68;

    emu.memory.iram_raw[game_mode] = 4;
    emu.registers.pc = main_loop;

    util::run_n_vblanks(&mut emu, 7);

    emu.memory.iram_raw[level_number] = 154;
    emu.memory.iram_raw[p1_level_number] = 154;
    emu.memory.iram_raw[lines] = 0x89;
    emu.memory.iram_raw[lines+1] = 0xE;
    emu.memory.iram_raw[p1_lines] = 0x89;
    emu.memory.iram_raw[p1_lines+1] = 0xE;
    emu.memory.iram_raw[p1_score] = 0x99;
    emu.memory.iram_raw[p1_score+1] = 0x99;
    emu.memory.iram_raw[p1_score+2] = 0x99;
    emu.memory.iram_raw[score] = 0x99;
    emu.memory.iram_raw[score+1] = 0x99;
    emu.memory.iram_raw[score+2] = 0x99;

    emu.memory.iram_raw[render_flags] = 7;

    util::run_n_vblanks(&mut emu, 1);

    // playfield::clear(&mut emu);

    playfield::set_str_addr(&mut emu, 0x400, match 1 {
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
    // emu.memory.iram_raw[push_down] = 8;
    // emu.memory.iram_raw[p1_push_down] = 8;
    // emu.memory.iram_raw[clear_count] = 9;
    // emu.memory.iram_raw[clear_count+1] = 5;
    // emu.memory.iram_raw[clear_count+2] = 5;
    // emu.memory.iram_raw[clear_count+3] = 5;

    // set framecounter, vramrow

    for _ in 0..30 {
        if emu.memory.iram_raw[play_state] == 5 || emu.memory.iram_raw[p1_play_state] == 5 {
            break;
        }

        let address = ((emu.registers.s) as u16) + 0x0100;
        let address1 = ((emu.registers.s) as u16) + 0x0101;


    println!("{}", emu.registers.pc);
        emu.memory.iram_raw[0x100..0x200].iter().for_each(|b| {
            print!("{:x} ", b);
        });
        println!("");
    print!("{:x} ", emu.memory.iram_raw[address as usize]);
    println!("{:x}", emu.memory.iram_raw[address1 as usize]);
    println!("{:x}", emu.registers.s);
    println!("{}", emu.ppu.current_scanline);
        emu.run_until_vblank();
    }

    println!("{}", emu.registers.pc);

    video::preview(&mut emu);


    println!("{}", emu.memory.iram_raw[p1_push_down]);

    // uncrash by replacing the PC
}
