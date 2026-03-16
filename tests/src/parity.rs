use regex::Regex;
use std::fs;
use std::path::PathBuf;
use rustico_core::nes::NesState;

use gag::Gag;

use crate::{input, labels, util, video};

// const COMPARE_BYTES: usize = 5;

fn get_buttons_from_tasfile(filename: &PathBuf) -> Vec<u8> {
    let contents = fs::read_to_string(filename).expect("can't open tasfile");

    // let reader = BufReader::new(file);
    let mut tas_buttons: Vec<u8> = Vec::new();
    let tas_line =
        //     RLDUTSBA
        Regex::new(r"(?m)^\|0\|([R.])([L.])([D.])([U.])([T.])([S.])([B.])([A.])\|\|\|").unwrap();

    for (i, (_, [right, left, down, up, start, select, b, a])) in tas_line
        .captures_iter(&contents)
        .map(|c| c.extract())
        .enumerate()
    {
        if i < 2 {
            continue;
        }
        let mut button: u8 = 0;
        if right == "R" {
            button |= 0x80 // input::RIGHT; // 0x01
        }
        if left == "L" {
            button |= 0x40 // input::LEFT; // 0x02
        }
        if down == "D" {
            button |= 0x20 // input::DOWN; // 0x04
        }
        if up == "U" {
            button |= 0x10 // input::UP; // 0x08
        }
        if start == "T" {
            button |= 0x08 // input::START; // 0x10
        }
        if select == "S" {
            button |= 0x04 // input::SELECT; // 0x20
        }
        if b == "B" {
            button |= 0x02 // input::B; // 0x40
        }
        if a == "A" {
            button |= 0x01 // input::A; // 0x80
        }
        tas_buttons.push(button);
        // println!(
        //     "{:?} {:?} {:?} {:?} {:?} {:?} {:?} {:?} {:08b}",
        //     right, left, down, up, start, select, a, b, button,
        // );
    }
    return tas_buttons;
}
//
// struct LoggedGameState {
//     logs: Vec<u8>,
//     state: usize,
// }
//
// impl LoggedGameState {
//     fn new(filename: &Path) -> Self {
//         let file = File::open(filename).unwrap();
//         let reader = BufReader::new(file);
//
//         let mut values: Vec<u8> = Vec::new();
//
//         for line in reader.lines() {
//             let line = line.expect("REASON");
//             line.split_whitespace()
//                 .map(|num| values.push(u8::from_str_radix(num, 16).unwrap()));
//
//             println!("{:?}", values);
//         }
//
//         let abc: Vec<u8> = vec![1, 2, 3, 4, 5];
//         Self {
//             logs: abc,
//             state: 0,
//         }
//     }
// }
//
// impl Iterator for LoggedGameState {
//     type Item = [u8; 5];
//     fn next(&mut self) -> Option<[u8; COMPARE_BYTES]> {
//         if self.state > 100 {
//             return None;
//         }
//
//         self.state += 1;
//
//         Some([1, 2, 3, 4, 5])
//     }
// }

pub fn compare(tasfile: &PathBuf, write: &bool) {
    // println!("{:?} {:?}", tasfile, write,);
    let tas_buttons = get_buttons_from_tasfile(tasfile);
    // run_and_press_start(frames, &start_frames, &vanilla_log, &gym_log, &write);
    run_and_press_start(&tas_buttons);
}
static LABELS: &[&str] = &[
    "rng_seed",
    "rng_seed_hi",
    "frameCounter",
    "frameCounterHi",
    "sleepCounter",
    "generalCounter",
    "gameMode",
];

fn get_labels_from_emu(emu: &mut NesState) -> Vec<u8> {

    let mut result: Vec<u8> = Vec::new();
    for label in LABELS {
        let addr = labels::get(label) as usize;
        let value = emu.memory.iram_raw[addr];
        result.push(value)
    }

    return result

}




fn run_and_press_start(
    tas_buttons: &Vec<u8>,
    // test_length: usize,
    // start_frames: &Vec<usize>,
    //
    // vanilla_log: &String,
    // gym_log: &String,
    // write: &bool,
) {
    // if vanilla_log == "" {
    //     panic!("vanilla logfile is required")
    // }
    //
    // println!("{} {:?}", test_length, start_frames);
    //

    let mut og;
    let mut gym;
    {
        // suppress rustico's output when loading roms
        let print_gag = Gag::stdout().unwrap();
        og = util::emulator(Some(util::OG_ROM));
        gym = util::emulator(None);
    }
    let mut view = video::Video::new();
    let mut vview = video::Video::new();

    for (i, buttons) in tas_buttons.iter().enumerate() {
        // if i > 300 {
        //     println!("Pausing! Press enter to continue...");
        //
        //     let mut buffer = String::new();
        //
        //     std::io::stdin()
        //         .read_line(&mut buffer)
        //         .expect("Failed to read line");
        //     return;
        // }
        let frame_no: usize = i;

        let gym_labels = get_labels_from_emu(&mut gym);
        let og_labels = get_labels_from_emu(&mut og);
        println!("Gym: {:?}", gym_labels);
        println!("OG: {:?}", og_labels);

        // println!(
        //     "{:02X} {:02X} {:02X} {:02X} {:02X}",
        //     og_rng2, og_rng1, og_fc2, og_fc1, og_gm,
        // );
        // if (og_rng1 != gym_rng1) || (og_rng2 != gym_rng2) || (og_fc1 != gym_fc1)
        // || gym_gm != og_gm
        // {
        //     println!(
        //         "Expected: {:04} {:02X} {:02X} {:02X} {:02X} {:02X}",
        //         frame_no, og_rng2, og_rng1, og_fc2, og_fc1, og_gm,
        //     );
        //     println!(
        //         "Actual: {:04} {:02X} {:02X} {:02X} {:02X} {:02X}",
        //         frame_no, gym_rng2, gym_rng1, gym_fc2, gym_fc1, gym_gm,
        //     );
        //     panic!("tools/log.lua to generate log");
        // }
        og.run_until_vblank();
        gym.run_until_vblank();
        util::set_controller_emu_native(&mut og, *buttons);
        util::set_controller_emu_native(&mut gym, *buttons);
        view.render(&mut gym);
        vview.render(&mut og);
    }
}
