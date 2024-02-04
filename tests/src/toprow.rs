use crate::{util, labels, playfield};

pub fn test() {
    let mut emu = util::emulator(None);

    for _ in 0..3 { emu.run_until_vblank(); }

    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;

    emu.memory.iram_raw[level_number] = 18;
    emu.memory.iram_raw[game_mode] = 4;
    emu.registers.pc = main_loop;

    for _ in 0..5 { emu.run_until_vblank(); }

    // 4 lines

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x11;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

    playfield::set_str(&mut emu, r##"
##### ####
##### ####
##### ####
##### ####
     #










###### ###
#  # # # #
## # # # #
#  # # # #
#  ### ###"##);

    for _ in 0..55 {
        emu.run_until_vblank();
    }

    assert_eq!(r##"



##########
     #










###### ###
#  # # # #
## # # # #
#  # # # #"##, playfield::get_str(&emu));

    // 3 lines

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x11;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

    playfield::clear(&mut emu);
    playfield::set_str(&mut emu, r##"
##### ####
##### ####
##### ####
     #











###### ###
#  # # # #
## # # # #
#  # # # #
#  ### ###"##);

    for _ in 0..50 {
        emu.run_until_vblank();
    }

    assert_eq!(r##"



     #











###### ###
#  # # # #
## # # # #
#  # # # #"##, playfield::get_str(&emu));

    // 2 lines

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x2;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

    playfield::clear(&mut emu);
    playfield::set_str(&mut emu, r##"
####   ###
##### ####
     #












###### ###
#  # # # #
## # # # #
#  # # # #
#  ### ###"##);

    for _ in 0..40 {
        emu.run_until_vblank();
    }

    assert_eq!(r##"


     #












###### ###
#  # # # #
## # # # #
#  # # # #"##, playfield::get_str(&emu));

    // 1 line

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x12;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

    playfield::clear(&mut emu);
    playfield::set_str(&mut emu, r##"
###    ###
     #













###### ###
#  # # # #
## # # # #
#  # # # #
#  ### ###"##);

    for _ in 0..41 {
        emu.run_until_vblank();
    }

    assert_eq!(r##"

     #













###### ###
#  # # # #
## # # # #
#  # # # #"##, playfield::get_str(&emu));

    // normal burn

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x2;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

    playfield::clear(&mut emu);
    playfield::set_str(&mut emu, r##"
# ##   # #
##### ####
     #  #



#

    #


       #



###### ###
#  # # # #
## # # # #
#  # # # #
#  ### ###"##);

    for _ in 0..39 {
        emu.run_until_vblank();
    }

    assert_eq!(r##"
# ###### #
     #  #



#

    #


       #



###### ###
#  # # # #
## # # # #
#  # # # #
#  ### ###"##, playfield::get_str(&emu));
}
