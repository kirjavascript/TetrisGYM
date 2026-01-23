use crate::{labels, playfield, util};

/// makes sure nmi exits quickly enough
pub fn test() {
    let mut emu = util::emulator(None);

    let main_loop = labels::get("mainLoop");
    let game_mode = labels::get("gameMode") as usize;
    let level_number = labels::get("levelNumber") as usize;
    let nmi_label = labels::get("nmi");
    let hz_flag = labels::get("hzFlag") as usize;
    let render_flags = labels::get("renderFlags") as usize;

    // spend a few frames bootstrapping
    for _ in 0..3 {
        emu.run_until_vblank();
    }

    // copied setup from garbage.rs
    emu.memory.iram_raw[hz_flag] = 1;
    emu.memory.iram_raw[game_mode] = 4;
    emu.memory.iram_raw[level_number] = 18;
    emu.registers.pc = main_loop;

    for _ in 0..11 {
        emu.run_until_vblank();
    }

    // sets up a triple in the top of the board
    emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x0F; // L piece
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x6;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;

    playfield::set_str(&mut emu, r##"
#####  ###
#####  ###
###### ###
###### ###
######### 
######### 
######### 
######### 
######### 
######### 
######### 
######### 
######### 
######### 
######### 
######### 
######### 
######### 
######### 
######### "##);

    for _ in 0..50 {
        // loop until pc is at the instruction after the jsr copyOamStagingToOam
        while emu.registers.pc != labels::get("@jumpOverIncrement") + 3 {
            emu.step();
            if emu.ppu.current_scanline == 261 {
                panic!("render took too long!");
            }
        }
        // cannot render hz on the same frame score/lines are updated
        let state = emu.memory.iram_raw[labels::get("playState") as usize];
        if state != 5 {
            emu.memory.iram_raw[render_flags] |= 0x10;
        }
        emu.run_until_vblank();
    }
}
