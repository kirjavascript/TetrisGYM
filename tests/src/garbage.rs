use crate::{util, labels, playfield, video};

pub fn test_garbage4_crash() {
    let mut emu = util::emulator(None);
    let mut view = video::Video::new();

    let main_loop = labels::get("mainLoop");
    let practise_type = labels::get("practiseType") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let level_number = labels::get("levelNumber") as usize;
    let gmod = labels::get("garbageModifier") as usize;
    let mode = labels::get("MODE_GARBAGE") as u8;

    // spend a few frames bootstrapping
    for _ in 0..3 {
        emu.run_until_vblank();
    }

    emu.memory.iram_raw[practise_type] = mode;
    emu.memory.iram_raw[game_mode] = 4;
    emu.memory.iram_raw[level_number] = 18;
    emu.memory.iram_raw[gmod] = 4;
    emu.registers.pc = main_loop;

    for _ in 0..11 {
        emu.run_until_vblank();
    }

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x11;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("rng_seed") as usize] = 0xBE;
    emu.memory.iram_raw[(labels::get("rng_seed") as usize) + 1] = 0x83;

    playfield::set_str(&mut emu, r##"
#####  ###
#####  ###
###### ###
###### ###
##########
##########
##########
##########
##########
##########
##########
##########
##########
##########
##########
##########
##########
##########
##########
##########"##);

    for _ in 0..40 {
        emu.run_until_vblank();
        view.render(&mut emu);
    }

    assert_ne!(emu.cpu.opcode, 18);
}
