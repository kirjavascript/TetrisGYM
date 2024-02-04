use crate::{util, labels, playfield};

pub fn test() {
    // check floor 0 doesnt burn lines

    let mut emu = util::emulator(None);

    for _ in 0..3 {
        emu.run_until_vblank();
    }

    let practise_type = labels::get("practiseType") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;

    // load floor 0

    emu.memory.iram_raw[practise_type] = labels::get("MODE_FLOOR") as _;
    emu.memory.iram_raw[level_number] = 18;
    emu.memory.iram_raw[game_mode] = 4;

    emu.registers.pc = main_loop;

    for _ in 0..5 {
        emu.run_until_vblank();
    }

    // setup a tetris

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x11;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x11;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;

    playfield::set_str(&mut emu,r##"
##### ####
##### ####
##### ####
##### ####"##);

    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

    for _ in 0..20 {
        emu.run_until_vblank();
    }

    assert_ne!(playfield::get(&mut emu, 0, 19), 0xEF);
}
