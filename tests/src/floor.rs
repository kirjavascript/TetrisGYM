use crate::{labels, playfield, util};

pub fn test() {
    test_teppoz();
    test_floor();
    test_floor_linecap(&true, "LINECAP_LEVEL");
    test_floor_linecap(&false, "LINECAP_LINES");
}

fn test_floor() {
    let mut emu = util::emulator(None);

    for _ in 0..5 {
        emu.run_until_vblank();
    }

    let practise_type = labels::get("practiseType") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;

    // load floor 4

    emu.memory.iram_raw[practise_type] = labels::get("MODE_TETRIS") as _;
    emu.memory.iram_raw[level_number] = 18;
    emu.memory.iram_raw[game_mode] = 4;
    emu.memory.iram_raw[labels::get("floorModifier") as usize] = 4;

    emu.registers.pc = main_loop;

    for _ in 0..10 {
        emu.run_until_vblank();
    }

    // check floor is height 4

    for i in 0..160 {
        assert_eq!(
            emu.memory.iram_raw[i + labels::get("playfield") as usize],
            0xEF
        );
    }

    for i in 160..200 {
        assert_ne!(
            emu.memory.iram_raw[i + labels::get("playfield") as usize],
            0xEF
        );
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

fn test_floor_linecap(sxtokl: &bool, linecap_when: &str) {
    let mut emu = util::emulator(None);

    for _ in 0..5 {
        emu.run_until_vblank();
    }

    let practise_type = labels::get("practiseType") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;

    emu.memory.iram_raw[practise_type] = labels::get("MODE_TETRIS") as u8;
    emu.memory.iram_raw[level_number] = 19;
    emu.memory.iram_raw[game_mode] = 4;

    emu.registers.pc = main_loop;

    for _ in 0..7 {
        emu.run_until_vblank();
    }
    if *sxtokl {
        emu.memory.iram_raw[labels::get("sxtoklFlag") as usize] = 1;
    }
    emu.memory.iram_raw[labels::get("linecapWhen") as usize] = (labels::get(linecap_when)) as u8;
    emu.memory.iram_raw[labels::get("linecapHow") as usize] =
        (labels::get("LINECAP_FLOOR") - 1) as u8;
    emu.memory.iram_raw[labels::get("linecapLines") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("linecapLinesBinHi") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("linecapLines") as usize + 1] = 0x10;
    emu.memory.iram_raw[labels::get("linecapLevel") as usize] = 20;
    // get some tetrises

    for _ in 0..4 {
        emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x11;
        emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
        emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x11;
        emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
        emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

        playfield::set_str(
            &mut emu,
            r##"
##### ####
##### ####
##### ####
##### ####"##,
        );

        for _ in 0..40 {
            emu.run_until_vblank();
        }
    }

    // check rows aren't pulled from the top in linecap floor mode
    for i in 0..40 {
        assert_eq!(
            emu.memory.iram_raw[i + labels::get("playfield") as usize],
            0xEF
        );
    }

    // check the floor is there
    assert_ne!(playfield::get(&mut emu, 0, 19), 0xEF);
    // but the row above isn't
    assert_eq!(playfield::get(&mut emu, 0, 18), 0xEF);
}

fn test_teppoz() {
    let mut emu = util::emulator(None);

    for _ in 0..5 {
        emu.run_until_vblank();
    }

    let practise_type = labels::get("practiseType") as usize;
    emu.memory.iram_raw[practise_type] = labels::get("MODE_TETRIS") as u8;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;

    // load floor 0

    emu.memory.iram_raw[level_number] = 18;
    emu.memory.iram_raw[game_mode] = 4;

    emu.registers.pc = main_loop;

    for _ in 0..5 {
        emu.run_until_vblank();
    }

    emu.memory.iram_raw[labels::get("teppozFlag") as usize] = 1;
    // setup a tetris

    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x11;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x11;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

    playfield::set_str(
        &mut emu,
        r##"
##### ####
##### ####
##### ####
##### ####"##,
    );

    for _ in 0..40 {
        emu.run_until_vblank();
    }

    // check floor 0 doesnt burn lines
    assert_ne!(playfield::get(&mut emu, 0, 19), 0xEF);
}
