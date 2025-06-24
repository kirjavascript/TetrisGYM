use crate::{util, labels, playfield};

pub fn test() {
    let mut emu = util::emulator(None);

    for _ in 0..4 {
        emu.run_until_vblank();
    }

    let practise_type = labels::get("practiseType") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;


    emu.memory.iram_raw[practise_type] = labels::get("MODE_TSPINS") as _;
    emu.memory.iram_raw[level_number] = 18;
    emu.memory.iram_raw[game_mode] = 4;

    emu.registers.pc = main_loop;

    for _ in 0..10 {
        emu.run_until_vblank();
    }

    let offset = |x, y| x + (y * 256);

    // check playfield
    assert_eq!(r##"
######  ##
#####   ##
###### ###
##########
    "##.trim(), playfield::get_str(&emu).trim());

    // check that correct tile is rendered
    assert_eq!(emu.ppu.read_byte(&mut *emu.mapper, 0x22CC), 0x7E);
    // check pixel is actually rendered
    assert_eq!(emu.ppu.screen[offset(96, 176) as usize], 0x30);
}
