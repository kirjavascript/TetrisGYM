use rusticnes_core::nes::NesState;

use crate::{util, labels, playfield};

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
    test_crunch(&mut emu, CRUNCH_0, 0x0);
    test_crunch(&mut emu, CRUNCH_1, 0x1);
    test_crunch(&mut emu, CRUNCH_4, 0x4);
    test_crunch(&mut emu, CRUNCH_5, 0x5);
    test_crunch(&mut emu, CRUNCH_7, 0x7);
    test_crunch(&mut emu, CRUNCH_D, 0xD);
    test_crunch(&mut emu, CRUNCH_F, 0xF);
    }


fn test_crunch(emu: &mut NesState, expected_playfield: &str, crunch_setting: u8) {
    emu.reset();

    for _ in 0..3 { emu.run_until_vblank(); }

    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;
    let practise_type = labels::get("practiseType") as usize;
    let mode_crunch = labels::get("MODE_CRUNCH") as u8;
    let crunch_modifier = labels::get("crunchModifier") as usize;
    let allegro = labels::get("allegro") as usize;
    let lines = labels::get("lines") as usize;

    emu.memory.iram_raw[practise_type] = mode_crunch;
    emu.memory.iram_raw[level_number] = 0; // intentionally slow
    emu.memory.iram_raw[game_mode] = 4;
    emu.memory.iram_raw[crunch_modifier] = crunch_setting;
    emu.memory.iram_raw[lines] = 0;
    emu.registers.pc = main_loop;
    playfield::clear(emu);
    for _ in 0..9 { emu.run_until_vblank(); }


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
        };

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
