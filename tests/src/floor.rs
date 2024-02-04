use crate::{util, labels, playfield};

pub fn test() {
    test_floor();
    test_floor_linecap();
    test_floor0();
}

fn test_floor() {
    let mut emu = util::emulator(None);

    for _ in 0..3 {
        emu.run_until_vblank();
    }

    let practise_type = labels::get("practiseType") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;

    // load floor 4

    emu.memory.iram_raw[practise_type] = labels::get("MODE_FLOOR") as _;
    emu.memory.iram_raw[level_number] = 18;
    emu.memory.iram_raw[game_mode] = 4;
    emu.memory.iram_raw[labels::get("floorModifier") as usize] = 4;

    emu.registers.pc = main_loop;

    for _ in 0..10 {
        emu.run_until_vblank();
    }

    // check floor is height 4

    for i in 0..160 {
        assert_eq!(emu.memory.iram_raw[i + labels::get("playfield") as usize], 0xEF);
    }

    for i in 160..200 {
        assert_ne!(emu.memory.iram_raw[i + labels::get("playfield") as usize], 0xEF);
    }

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x12;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0f;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;

    for _ in 0..20 {
        emu.run_until_vblank();
    }

    // check flat line doesnt burn anything
    assert_ne!(playfield::get(&mut emu, 0, 19), 0xEF);
}

fn test_floor_linecap() {
    let mut emu = util::emulator(None);

    for _ in 0..3 { emu.run_until_vblank(); }

    let practise_type = labels::get("practiseType") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;

    emu.memory.iram_raw[practise_type] = labels::get("MODE_TRANSITION") as _;
    emu.memory.iram_raw[level_number] = 19;
    emu.memory.iram_raw[game_mode] = 4;

    emu.memory.iram_raw[labels::get("linecapFlag") as usize] = 1;
    emu.memory.iram_raw[labels::get("linecapHow") as usize] = labels::get("LINECAP_FLOOR") as u8 - 1;
    emu.memory.iram_raw[labels::get("linecapLevel") as usize] = 20;

    emu.registers.pc = main_loop;

    for _ in 0..5 { emu.run_until_vblank(); }

    // get some tetrises

    for _ in 0..4 {

        emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x11;
        emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
        emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x11;
        emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
        emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

        playfield::set_str(&mut emu, r##"
##### ####
##### ####
##### ####
##### ####"##);

        for _ in 0..40 { emu.run_until_vblank(); }
    }

    // check rows aren't pulled from the top in linecap floor mode
    for i in 0..40 {
        assert_eq!(emu.memory.iram_raw[i + labels::get("playfield") as usize], 0xEF);
    }

    // check the floor is there
    assert_ne!(playfield::get(&mut emu, 0, 19), 0xEF);
    // but the row above isn't
    assert_eq!(playfield::get(&mut emu, 0, 18), 0xEF);
}

fn test_floor0() {
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

    for _ in 0..5 { emu.run_until_vblank(); }

    // setup a tetris

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x11;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x11;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

    playfield::set_str(&mut emu, r##"
##### ####
##### ####
##### ####
##### ####"##);

    for _ in 0..40 { emu.run_until_vblank(); }

    // check floor 0 doesnt burn lines
    assert_ne!(playfield::get(&mut emu, 0, 19), 0xEF);
}
