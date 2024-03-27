use crate::{input, labels, util};
use rusticnes_core::nes::NesState;

pub fn test() {
    let mut emu = util::emulator(None);

    for _ in 0..4 {
        emu.run_until_vblank();
    }

    let hz_flag = labels::get("hzFlag") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;

    // turn on hz display
    emu.memory.iram_raw[hz_flag] = 1;
    // trick game into thinking it should start an a-type run
    emu.memory.iram_raw[level_number] = 29;
    emu.memory.iram_raw[game_mode] = 4;
    emu.registers.pc = main_loop;

    // wait for piece to become active
    util::run_n_vblanks(&mut emu, 5);
    // test left input sequence with delay of 5
    run_input_string(&mut emu, ".....L.L..L.L.");
    assert_hz_display(&mut emu, HzSpeed(25, 75), 4, 5, Dir::Left);

    // wait a little, then test right input sequence
    util::run_n_vblanks(&mut emu, 5);
    run_input_string(&mut emu, "R....R.R.");
    assert_hz_display(&mut emu, HzSpeed(17, 17), 3, 5, Dir::Right);
    // make piece fall immediately so emulation takes less time
    run_input_string(&mut emu, "D");
    // fall 18 rows, then 3 frames before the 10-frame entry delay finishes
    util::run_n_vblanks(&mut emu, 18+10-3);
    run_input_string(&mut emu, "R.R.R.R.R.");
    assert_hz_display(&mut emu, HzSpeed(30, 5), 3, 1, Dir::Right);
    // TODO: have tests for -2 and -1 entry delay too.
    // each negative entry delay should have its own test because they all
    // need to be handled specifically in separate branches
}

// note:
fn run_input_string(emu: &mut NesState, inputs: &str) {
    for button in inputs.chars() {
        let controller_data = match button {
            'L' => input::LEFT,
            'R' => input::RIGHT,
            'D' => input::DOWN,
            'U' => input::UP,
            'A' => input::A,
            'B' => input::B,
            'S' => input::START,
            'T' => input::SELECT,
            '.' => 0,
            _ => panic!("character '{}' cannot be used as controller input", button),
        };
        util::set_controller(emu, controller_data);
        emu.run_until_vblank();
    }
    util::set_controller(emu, 0);
}

#[derive(PartialEq)]
struct HzSpeed (u8, u8);

enum Dir {
    Left,
    Right,
}

fn assert_hz_display(emu: &mut NesState, speed: HzSpeed, tap: u8, dly: i8, dir: Dir) {
    assert_speed(emu, speed);
    assert_tap_count(emu, tap);
    assert_tap_delay(emu, dly);
    assert_tap_dir(emu, dir);
}

fn assert_speed(emu: &mut NesState, speed: HzSpeed) {
    const HZ_ADDR: u16 = 0x21A3;
    let int_part = 10 * emu.mapper.debug_read_ppu(HZ_ADDR).unwrap()
        + emu.mapper.debug_read_ppu(HZ_ADDR+1).unwrap();
    let frac_part = 10 * emu.mapper.debug_read_ppu(HZ_ADDR+3).unwrap()
        + emu.mapper.debug_read_ppu(HZ_ADDR+4).unwrap();
    assert!(speed == HzSpeed(int_part, frac_part));
}

fn assert_tap_count(emu: &mut NesState, tap: u8) {
    const TAP_COUNT_ADDR: u16 = 0x2228;
    assert!(tap == emu.mapper.debug_read_ppu(TAP_COUNT_ADDR).unwrap());
}

fn assert_tap_delay(emu: &mut NesState, dly: i8) {
    const DELAY_ADDR: u16 = 0x2267;
    // sign of delay value
    let measured_sign = emu.mapper.debug_read_ppu(DELAY_ADDR).unwrap();
    if dly < 0 {
        assert!(measured_sign == 0x24);
    } else {
        assert!(measured_sign == 0xFF);
    }
    // magnitude
    let measured_abs = emu.mapper.debug_read_ppu(DELAY_ADDR+1).unwrap();
    assert!(measured_abs == dly.unsigned_abs());
}

fn assert_tap_dir(emu: &mut NesState, dir: Dir) {
    const DIR_ADDR: u16 = 0x22A8;
    let measured_dir = emu.mapper.debug_read_ppu(DIR_ADDR).unwrap();
    match dir {
        Dir::Left => assert!(measured_dir == 0xD7),
        Dir::Right => assert!(measured_dir == 0xD6),
    }
}
