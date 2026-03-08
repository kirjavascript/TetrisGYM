use crate::{input, labels, util};

pub fn test() {
    const TEST_LENGTH: usize = 1000;
    // 265 is earliest frame that responds to start
    const START_FRAMES: [usize; 5] = [270, 280, 290, 300, TEST_LENGTH + 1];

    let rng_seed1 = labels::get("rng_seed") as usize;
    let rng_seed2 = (labels::get("rng_seed") + 1) as usize;
    let frame_counter1 = labels::get("frameCounter") as usize;
    let frame_counter2 = (labels::get("frameCounter") + 1) as usize;
    let game_mode = labels::get("gameMode") as usize;

    let mut og_rng1: u8;
    let mut og_rng2: u8;
    let mut og_fc1: u8;
    let mut og_fc2: u8;
    let mut og_gm: u8;

    let mut gym_rng1: u8;
    let mut gym_rng2: u8;
    let mut gym_fc1: u8;
    let mut gym_fc2: u8;
    let mut gym_gm: u8;

    let mut og = util::emulator(Some(util::OG_ROM));
    let mut gym = util::emulator(None);
    let mut start_idx = 0;
    let mut unset_buttons = false;

    for i in 0..=TEST_LENGTH {
        og.run_until_vblank();
        gym.run_until_vblank();
        if unset_buttons {
            util::set_controller_raw(&mut og, 0);
            util::set_controller_raw(&mut gym, 0);
            unset_buttons = false;
        }

        if i == START_FRAMES[start_idx] {
            start_idx += 1;
            util::set_controller_raw(&mut og, input::START);
            util::set_controller_raw(&mut gym, input::START);
            unset_buttons = true;
        }

        og_rng1 = og.memory.iram_raw[rng_seed1];
        og_rng2 = og.memory.iram_raw[rng_seed2];
        og_fc1 = og.memory.iram_raw[frame_counter1];
        og_fc2 = og.memory.iram_raw[frame_counter2];
        og_gm = og.memory.iram_raw[game_mode];

        gym_rng1 = gym.memory.iram_raw[rng_seed1];
        gym_rng2 = gym.memory.iram_raw[rng_seed2];
        gym_fc1 = gym.memory.iram_raw[frame_counter1];
        gym_fc2 = gym.memory.iram_raw[frame_counter2];
        gym_gm = gym.memory.iram_raw[game_mode];

        if (og_rng1 != gym_rng1)
            || (og_rng2 != gym_rng2)
            || (og_fc1 != gym_fc1)
            || (og_fc2 != gym_fc2)
            || (og_gm != gym_gm)
        {
            println!(
                "Expected:\n{:04} {:02X}{:02X} {:02X}{:02X} {:02X}",
                i, og_rng2, og_rng1, og_fc2, og_fc1, og_gm,
            );
            println!(
                "Actual:\n{:04} {:02X}{:02X} {:02X}{:02X} {:02X}",
                i, gym_rng2, gym_rng1, gym_fc2, gym_fc1, gym_gm,
            );
            panic!("tools/log.lua to generate log");
        }
    }
}
