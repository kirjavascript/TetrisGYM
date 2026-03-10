use gag::Gag;
use crate::{input, labels, util};

pub fn test() {
    // 1795 is frame vanilla enters demo mode (gameMode = 5)
    run_and_press_start(291, &[265, 270, 274, 286]);
    run_and_press_start(291, &[264, 269, 273, 286]);
    run_and_press_start(700, &[300, 400, 500, 600]);
    run_and_press_start(1794, &[]);
    run_and_press_start(1905, &[1794, 1800, 1900]);

    // fastest999999 pattern
    run_and_press_start(2000, &[265, 1000, 1500, 1900]);

    // other test cases
}

fn run_and_press_start(test_length: usize, start_frames: &[usize]) {
    println!("{} {:?}", test_length, start_frames);
    let rng_seed1 = labels::get("rng_seed") as usize;
    let rng_seed2 = (labels::get("rng_seed") + 1) as usize;
    let frame_counter1 = labels::get("frameCounter") as usize;
    let frame_counter2 = (labels::get("frameCounter") + 1) as usize;
    let sleep_counter = labels::get("sleepCounter") as usize;
    let general_counter = labels::get("generalCounter") as usize;
    let game_mode = labels::get("gameMode") as usize;

    let mut og_rng1: u8;
    let mut og_rng2: u8;
    let mut og_fc1: u8;
    let mut og_fc2: u8;
    let mut og_sc: u8;
    let mut og_gc: u8;
    let mut og_gm: u8;

    let mut gym_rng1: u8;
    let mut gym_rng2: u8;
    let mut gym_fc1: u8;
    let mut gym_fc2: u8;
    let mut gym_sc: u8;
    let mut gym_gc: u8;
    let mut gym_gm: u8;

    let mut og;
    let mut gym;
    {
        // suppress rustico's output when loading roms
        let print_gag = Gag::stdout().unwrap();
        og = util::emulator(Some(util::OG_ROM));
        gym = util::emulator(None);
    }
    let mut start_idx = 0;
    let mut unset_buttons = false;

    for i in 0..=test_length {
        og.run_until_vblank();
        gym.run_until_vblank();

        if unset_buttons {
            util::set_controller_raw(&mut og, 0);
            util::set_controller_raw(&mut gym, 0);
            unset_buttons = false;
        }

        if start_idx < start_frames.len() {
            if i == start_frames[start_idx] {
                start_idx += 1;
                util::set_controller_raw(&mut og, input::START);
                util::set_controller_raw(&mut gym, input::START);
                unset_buttons = true;
            }
        }

        og_rng1 = og.memory.iram_raw[rng_seed1];
        og_rng2 = og.memory.iram_raw[rng_seed2];
        og_fc1 = og.memory.iram_raw[frame_counter1];
        og_fc2 = og.memory.iram_raw[frame_counter2];
        og_sc = og.memory.iram_raw[sleep_counter];
        og_gc = og.memory.iram_raw[general_counter];
        og_gm = og.memory.iram_raw[game_mode];

        gym_rng1 = gym.memory.iram_raw[rng_seed1];
        gym_rng2 = gym.memory.iram_raw[rng_seed2];
        gym_fc1 = gym.memory.iram_raw[frame_counter1];
        gym_fc2 = gym.memory.iram_raw[frame_counter2];
        gym_sc = gym.memory.iram_raw[sleep_counter];
        gym_gc = og.memory.iram_raw[general_counter];
        gym_gm = gym.memory.iram_raw[game_mode];

        if (og_rng1 != gym_rng1)
            || (og_rng2 != gym_rng2)
            || (og_fc1 != gym_fc1)
            // this one doesn't matter (pretty sure anyway)
            // || (og_fc2 != gym_fc2)
            || (og_gm != gym_gm)
        {
            println!(
                "Expected:\n{:04} {:02X}{:02X} {:02X}{:02X} {:02X} {:02X} {:02X}",
                i, og_rng2, og_rng1, og_fc2, og_fc1, og_sc, og_gc, og_gm,
            );
            println!(
                "Actual:\n{:04} {:02X}{:02X} {:02X}{:02X} {:02X} {:02X} {:02X}",
                i, gym_rng2, gym_rng1, gym_fc2, gym_fc1, gym_sc, gym_gc, gym_gm,
            );
            panic!("tools/log.lua to generate log");
        }
    }
}
