use crate::{labels, util};
use rusticnes_core::nes::NesState;

pub fn test() {
    test_standard();
    test_tspin();
}

fn test_standard() {
    let boot = || {
        let mut emu = util::emulator(None);

        util::run_n_vblanks(&mut emu, 4);

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

        emu
    };

    let mut emu = boot();
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
    // each negative entry delay should have its own test because they all
    // need to be handled specifically in separate branches
    util::run_n_vblanks(&mut emu, 18+10-3);
    run_input_string(&mut emu, "R.R.R.R.R.");
    assert_hz_display(&mut emu, HzSpeed(30, 5), 3, -3, Dir::Right);
    // -2 entry delay
    util::run_n_vblanks(&mut emu, 12+10-2);
    run_input_string(&mut emu, "LLL..L.L...L.");
    assert_hz_display(&mut emu, HzSpeed(20, 3), 3, -2, Dir::Left);
    // -1 entry delay
    util::run_n_vblanks(&mut emu, 7+12-1);
    run_input_string(&mut emu, "RR...R...R...R.R.");
    assert_hz_display(&mut emu, HzSpeed(18, 3), 4, -1, Dir::Right);
    // -4 entry delay shouldn't show up
    util::run_n_vblanks(&mut emu, 2+12-4);
    run_input_string(&mut emu, "L.....");
    assert_hz_display(&mut emu, HzSpeed(18, 3), 4, -1, Dir::Right);

    // check L+U etc is counted as a tap
    let mut emu = boot();
    {
        use crate::input::*;
        run_input_string(&mut emu, "LB.L.LL.");
        util::set_controller_raw(&mut emu, LEFT + UP);
        emu.run_until_vblank();
        emu.run_until_vblank();
        run_input_string(&mut emu, ".");
        util::set_controller_raw(&mut emu, LEFT + UP);
        emu.run_until_vblank();
        emu.run_until_vblank();
    }
    assert_hz_display(&mut emu, HzSpeed(21, 85), 5, 0, Dir::Left);
}

fn test_tspin() {
    let mut emu = util::emulator(None);

    for _ in 0..4 {
        emu.run_until_vblank();
    }

    let practise_type = labels::get("practiseType") as usize;
    let hz_flag = labels::get("hzFlag") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;

    // set to tspin mode
    emu.memory.iram_raw[practise_type] = labels::get("MODE_TSPINS") as _;
    // turn on hz display
    emu.memory.iram_raw[hz_flag] = 1;
    // trick game into thinking it should start an a-type run
    emu.memory.iram_raw[level_number] = 29;
    emu.memory.iram_raw[game_mode] = 4;
    emu.registers.pc = main_loop;

    // wait for piece to become active
    util::run_n_vblanks(&mut emu, 9);
    run_input_string(&mut emu, "DRB");
    util::run_n_vblanks(&mut emu, 14);
    // lock first tspin
    run_input_string(&mut emu, "A");
    util::run_n_vblanks(&mut emu, 43);
    run_input_string(&mut emu, "LLLL.");
    assert_hz_display(&mut emu, HzSpeed(0, 0), 1, -3, Dir::Right);
}

fn run_input_string(emu: &mut NesState, inputs: &str) {
    for button in inputs.chars() {
        util::set_controller(emu, button);
        emu.run_until_vblank();
    }
    util::set_controller(emu, '.');
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
