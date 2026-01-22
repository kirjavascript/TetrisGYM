use rustico_core::nes::NesState;

use crate::{ util, labels, playfield};

const TETRIS_READY: &str = r##"#
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
##### ####
##### ####
##### ####
##### ####"##;

const TETRIS_READY_FULL: &str = r##"##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####"##;

const TETRIS_FULL_AFTER: &str = r##"



##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####
##### ####"##;

const TEST1_AFTER: &str = r##"



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

const TEST2_AFTER: &str = r##"

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
#   ##
##### ####
##### ####"##;


const TETRIS_READY_PC: &str = r##"














##### ####
##### ####
##### ####
##### ####"##;


const BLANK_BOARD: &str = r##"


















"##;

pub fn test() {
    let mut emu = util::emulator(None);
    let mut max_stage: u32;
    let mut max_drop: u32;
    let mut stage_cycles: u32;
    let mut drop_cycles: u32;

    (max_stage, max_drop) = test_harddropped_piece(&mut emu, TETRIS_READY, TEST1_AFTER, 0x11);

    (stage_cycles, drop_cycles) = test_harddropped_piece(&mut emu, TETRIS_READY, TEST2_AFTER, 0xF);
    max_stage = if stage_cycles > max_stage { stage_cycles } else { max_stage };
    max_drop = if drop_cycles > max_drop { drop_cycles } else { max_drop };

    (stage_cycles, drop_cycles) = test_harddropped_piece(&mut emu, TETRIS_READY_PC, BLANK_BOARD, 0x11);
    max_stage = if stage_cycles > max_stage { stage_cycles } else { max_stage };
    max_drop = if drop_cycles > max_drop { drop_cycles } else { max_drop };

    (stage_cycles, drop_cycles) = test_harddropped_piece(&mut emu, TETRIS_READY_FULL, TETRIS_FULL_AFTER, 0x11);
    max_stage = if stage_cycles > max_stage { stage_cycles } else { max_stage };
    max_drop = if drop_cycles > max_drop { drop_cycles } else { max_drop };

    println!("Hard Drop max stage cycles: {}", max_stage);
    println!("Hard Drop max drop cycles: {}", max_drop);

    }

fn test_harddropped_piece(emu: &mut NesState, start: &str, finish: &str, piece: u8 ) -> (u32,u32) {
    emu.reset();

    for _ in 0..3 { emu.run_until_vblank(); }

    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;
    let practise_type = labels::get("practiseType") as usize;
    let mode_harddrop = labels::get("MODE_HARDDROP") as u8;
    let button_up = labels::get("BUTTON_UP") as u8;
    let newly_pressed_buttons = labels::get("newlyPressedButtons") as usize;
    let active_tetrimino = labels::get("playState_playerControlsActiveTetrimino");
    let stage_sprite = labels::get("stageSpriteForCurrentPiece");

    emu.memory.iram_raw[practise_type] = mode_harddrop;
    emu.memory.iram_raw[game_mode] = 4;
    emu.memory.iram_raw[level_number] = 18;
    emu.registers.pc = main_loop;
    emu.memory.iram_raw[labels::get("playfieldAddr") as usize + 1] = 4;

    playfield::clear(emu);
    util::run_n_vblanks(emu, 7);
    playfield::set_str(emu, start);

    emu.memory.iram_raw[labels::get("playState") as usize] = 1;
    emu.memory.iram_raw[labels::get("currentPiece") as usize] = piece;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0;

    // stage ghost piece
    let temp_pc = emu.registers.pc;
    let temp_tick = emu.cpu.tick;
    emu.registers.pc = stage_sprite;
    let stage_cycles = util::cycles_to_return(emu);
    emu.registers.pc = temp_pc;
    emu.cpu.tick = temp_tick;

    util::run_n_vblanks(emu, 1);

    emu.memory.iram_raw[labels::get("playState") as usize] = 1;
    emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
    emu.memory.iram_raw[labels::get("currentPiece") as usize] = piece;
    emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
    emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x0;
    emu.memory.iram_raw[labels::get("vramRow") as usize] = 0x20;
    emu.memory.iram_raw[newly_pressed_buttons] = button_up;

    // hard drop and count cycles
    emu.registers.pc = active_tetrimino;
    let drop_cycles = util::cycles_to_return(emu);

    assert_eq!(finish, playfield::get_str(emu));

    return (stage_cycles, drop_cycles);
}
