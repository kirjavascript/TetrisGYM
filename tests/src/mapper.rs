use crate::{
    input,
    labels,
    playfield,
    util,
};
use rusticnes_core::nes::NesState;

pub fn get_expected_tilesets() -> (Vec<u8>, Vec<u8>) {

    // tilesets as ordered in the game
    let title_menu_tileset = include_bytes!("../../src/chr/title_menu_tileset.chr");
    let game_tileset = include_bytes!("../../src/chr/game_tileset.chr");
    let rocket_tileset = include_bytes!("../../src/chr/rocket_tileset.chr");
    let empty_tileset: Vec<u8> = vec![0; 0x1000];

    // cnrom limited to reading 8k banks, so pair tilesets accordingly
    let mut tileset1: Vec<u8> = vec![0; 0x2000];
    tileset1[..0x1000].copy_from_slice(title_menu_tileset);
    tileset1[0x1000..].copy_from_slice(game_tileset);

    let mut tileset2: Vec<u8> = vec![0; 0x2000];
    tileset2[..0x1000].copy_from_slice(rocket_tileset);
    tileset2[0x1000..].copy_from_slice(&empty_tileset);

    (tileset1, tileset2)
    }


pub fn get_current_tilesets(emu: &mut NesState) -> Vec<u8>{
    let mut current_tileset = vec![0; 0x2000];
    for i in 0..0x2000 {
        current_tileset[i] = emu.ppu.read_byte(&mut *emu.mapper, i as u16)
        }
        current_tileset
    }

pub fn get_tile_select(emu: &mut NesState) -> u8 {
    let bg_select = (emu.ppu.control & 0x10) >> 4;
    let sprite_select = (emu.ppu.control & 0x08) >> 3;
    // println!("Current PPU Control is {:08b}", emu.ppu.control);
    // println!("Current BG Select is {}", bg_select);
    // println!("Current Sprite Select is {}", sprite_select);

    // validate here that background and sprite tile selects match
    assert_eq!(bg_select, sprite_select);

    bg_select
}

pub fn test() {
    test_tilesets(None);
    let mut cnrom = util::ROM.to_vec();
    cnrom[6] |= 0x20;
    test_tilesets(Some(&cnrom));
}

pub fn test_tilesets(rom: Option<&[u8]>) {
    let mut emu = util::emulator(rom);
    // let mut view = video::Video::new();
    let (tileset1, tileset2) = get_expected_tilesets();

    for _ in 0..20 {
        emu.run_until_vblank();
        // view.render(&mut emu);
    }

    // test menu tileset is active
    let tile_select = get_tile_select(&mut emu);
    let current_tileset = get_current_tilesets(&mut emu);
    assert_eq!(tile_select, 0);
    assert_eq!(current_tileset, tileset1);

    // test game mode
    let practise_type = labels::get("practiseType") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;
    let score = labels::get("score") as usize;
    let tetris = labels::get("MODE_TETRIS") as usize;

    emu.memory.iram_raw[practise_type] = tetris as u8;
    emu.memory.iram_raw[level_number] = 18;
    emu.memory.iram_raw[game_mode] = 4;
    emu.registers.pc = main_loop;

    for _ in 0..20 {
        emu.run_until_vblank();
        // view.render(&mut emu);
    }

    let tile_select = get_tile_select(&mut emu);
    let current_tileset = get_current_tilesets(&mut emu);
    assert_eq!(tile_select, 1);
    assert_eq!(current_tileset, tileset1);

    // boot in qual: tileset2, select 0
    util::set_controller_raw(&mut emu, input::SELECT);
    emu.reset();
    for _ in 0..20 {
        emu.run_until_vblank();
        // view.render(&mut emu);
    }
    let tile_select = get_tile_select(&mut emu);
    let current_tileset = get_current_tilesets(&mut emu);
    assert_eq!(tile_select, 0);
    assert_eq!(current_tileset, tileset2);
    emu.p1_input = 0;

    // rocket screen: tileset2, select 0
    emu.memory.iram_raw[practise_type] = tetris as u8;
    emu.memory.iram_raw[level_number] = 12;
    emu.memory.iram_raw[game_mode] = 4;
    emu.registers.pc = main_loop;

    for _ in 0..20 {
        emu.run_until_vblank();
        // view.render(&mut emu);
    }
    emu.memory.iram_raw[score] = 0x99;
    emu.memory.iram_raw[score+1] = 0x99;
    emu.memory.iram_raw[score+2] = 0x99;
    playfield::set_str(&mut emu, r##"
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
##########
##########
##########
##########
##########"##);

    for _ in 0..750 {
        emu.run_until_vblank();
        // view.render(&mut emu);
    }

    let tile_select = get_tile_select(&mut emu);
    let current_tileset = get_current_tilesets(&mut emu);
    assert_eq!(tile_select, 0);
    assert_eq!(current_tileset, tileset2);


    util::set_controller_raw(&mut emu, input::START);
    emu.run_until_vblank();
    emu.run_until_vblank();
    emu.p1_input = 0;

    for _ in 0..30 {
        emu.run_until_vblank();
        // view.render(&mut emu);
    }

    let tile_select = get_tile_select(&mut emu);
    let current_tileset = get_current_tilesets(&mut emu);

    assert_eq!(tile_select, 0);
    assert_eq!(current_tileset, tileset1);
}
