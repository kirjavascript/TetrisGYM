use rustico_core::nes::NesState;

use crate::{labels, playfield, util};

const CRUNCH_F: &str = r##"###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###
###    ###"##;

const CRUNCH_D: &str = r##"###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #
###      #"##;

const CRUNCH_7: &str = r##"#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###
#      ###"##;

const CRUNCH_5: &str = r##"#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #
#        #"##;

const CRUNCH_4: &str = r##"#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#"##;

const CRUNCH_1: &str = r##"         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #
         #"##;

const CRUNCH_0: &str = r##"


















"##;

pub fn test() {
    let mut emu = util::emulator(None);
    test_crunch(&mut emu, CRUNCH_0, 0, 0);
    test_crunch(&mut emu, CRUNCH_1, 0, 1);
    test_crunch(&mut emu, CRUNCH_4, 1, 0);
    test_crunch(&mut emu, CRUNCH_5, 1, 1);
    test_crunch(&mut emu, CRUNCH_7, 1, 3);
    test_crunch(&mut emu, CRUNCH_D, 3, 1);
    test_crunch(&mut emu, CRUNCH_F, 3, 3);
}

fn test_crunch(emu: &mut NesState, expected_playfield: &str, crunch_left_setting: u8, crunch_right_setting: u8) {
    emu.reset();

    for _ in 0..5 {
        emu.run_until_vblank();
    }

    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;
    let practise_type = labels::get("practiseType") as usize;
    let mode_tetris = labels::get("MODE_TETRIS") as u8;
    let crunch_left = labels::get("crunchLeftModifier") as usize;
    let crunch_right = labels::get("crunchRightModifier") as usize;
    let allegro = labels::get("allegro") as usize;
    let lines = labels::get("lines") as usize;

    emu.memory.iram_raw[practise_type] = mode_tetris;
    emu.memory.iram_raw[level_number] = 0; // intentionally slow
    emu.memory.iram_raw[game_mode] = 4;
    emu.memory.iram_raw[crunch_left] = crunch_left_setting;
    emu.memory.iram_raw[crunch_right] = crunch_right_setting;
    emu.memory.iram_raw[lines] = 0;
    emu.registers.pc = main_loop;
    playfield::clear(emu);
    for _ in 0..9 {
        emu.run_until_vblank();
    }

    // validate initialized
    assert_eq!(expected_playfield, playfield::get_str(emu));

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x12;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x12;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

    // skip lock tetrimino and setup a tetris to be cleared
    emu.memory.iram_raw[labels::get("playState") as usize] = 3;
    for block in 0x4a0..0x4c8 {
        emu.memory.iram_raw[block as usize] = 0x7b;
    }

    // cycle through remainder of entry delay and animation
    for _ in 0..32 {
        emu.run_until_vblank();
    }

    // validate tetris was scored and playfield looks the same
    assert_eq!(emu.memory.iram_raw[lines], 4);
    assert_eq!(expected_playfield, playfield::get_str(emu));

    // validate allegro not set
    assert_eq!(emu.memory.iram_raw[allegro], 0);
}
