use regex::Regex;
use rustico_core::nes::NesState;
use std::fs::read_to_string;
use std::fs::File;
use std::io::BufWriter;
use std::io::Result;
use std::io::Write;
use std::path::PathBuf;

use gag::Gag;

use crate::labels;
use crate::util;
use crate::video;

static EXTRA_FRAMES: usize = 10;
static FAILURE_LOG_FRAMES: usize = 100;
static COMPARE_BYTES: &[&str] = &[
    "rng_seed",
    "rng_seed_hi",
    "frameCounter",
    "frameCounterHi",
    "gameMode",
    "autorepeatX",
    "spawnCount",
];

pub fn compare(tasfile: &PathBuf, write: &bool, verbose: &bool, render: &bool) {
    // println!("{:?} {:?}", tasfile, write,);
    let tas_buttons = get_buttons_from_tasfile(tasfile, verbose);

    if *write {
        let (vanilla, gym) = run_tas_and_compare(&tas_buttons, verbose, &render);
        let _ = write_bytes_to_file(&get_new_filename(tasfile, "clean"), &vanilla);
        let _ = write_bytes_to_file(&get_new_filename(tasfile, "gym"), &gym);
    } else {
        let vanilla_logfile = get_new_filename(tasfile, "clean");
        let compare_bytes: Vec<u8> = read_bytes_from_file(&vanilla_logfile);
        compare_with_vanilla(&tas_buttons, &compare_bytes, &verbose, &render);
    }
}

struct OptionalVideo {
    video: Option<video::Video>,
}

impl OptionalVideo {
    fn new(render: &bool) -> Self {
        let video = if *render {
            Some(video::Video::new())
        } else {
            None
        };

        Self { video }
    }
    fn set_position(&mut self, x: isize, y: isize) {
        if let Some(video) = &mut self.video {
            video.window.set_position(x, y);
        }
    }
    fn render(&mut self, emu: &mut rustico_core::nes::NesState) {
        if let Some(video) = &mut self.video {
            video.render(emu);
        }
    }
}

fn read_bytes_from_file(filename: &PathBuf) -> Vec<u8> {
    let mut result = Vec::new();

    for line in read_to_string(filename).unwrap().lines() {
        for byte in line.split_whitespace() {
            result.push(u8::from_str_radix(byte, 16).unwrap())
        }
    }

    result
}

fn write_bytes_to_file(filename: &PathBuf, bytes: &Vec<u8>) -> Result<()> {
    let file = File::create(filename)?;
    let mut writer = BufWriter::new(file);

    for chunk in bytes.chunks(COMPARE_BYTES.len()) {
        for (i, b) in chunk.iter().enumerate() {
            if i > 0 {
                write!(writer, " ")?;
            }
            write!(writer, "{:02X}", b)?;
        }
        writeln!(writer)?;
    }
    Ok(())
}

fn get_new_filename(filename: &PathBuf, suffix: &str) -> PathBuf {
    let stem = filename.file_stem().unwrap();
    let mut name = stem.to_os_string();
    name.push(format!("-{}.log", suffix));
    filename.with_file_name(name)
}

fn extract_values_from_labels(emu: &mut NesState) -> Vec<u8> {
    let mut result: Vec<u8> = Vec::new();
    for label in COMPARE_BYTES {
        let addr = labels::get(label) as usize;
        let value = emu.memory.iram_raw[addr];
        result.push(value)
    }

    return result;
}

fn compare_with_vanilla(
    tas_buttons: &Vec<u8>,
    compare_bytes: &Vec<u8>,
    verbose: &bool,
    render: &bool,
) {
    let mut gym;
    {
        let _print_gag = Gag::stdout().unwrap();
        gym = util::emulator(None);
    }
    let mut ptr = 0;
    let mut view = OptionalVideo::new(render);
    for (i, buttons) in tas_buttons.into_iter().enumerate() {
        let expected = &compare_bytes[ptr..ptr + COMPARE_BYTES.len()];
        ptr += COMPARE_BYTES.len();
        let values = extract_values_from_labels(&mut gym);
        if expected != values {
            println!("Gym: {:?}", values);
            println!("Vog: {:?}", expected);
            panic!("Mismatch on line {}!", i + 1);
        }

        gym.run_until_vblank();
        util::set_controller_emu_native(&mut gym, *buttons);
        view.render(&mut gym);
    }
}
fn run_tas_and_compare(tas_buttons: &Vec<u8>, verbose: &bool, render: &bool) -> (Vec<u8>, Vec<u8>) {
    let mut og;
    let mut gym;
    {
        // suppress rustico's output when loading roms
        let _print_gag = Gag::stdout().unwrap();
        og = util::emulator(Some(util::OG_ROM));
        gym = util::emulator(None);
    }
    let mut og_bytes = Vec::new();
    let mut gym_bytes = Vec::new();
    let mut vanilla_view = OptionalVideo::new(render);
    let mut gym_view = OptionalVideo::new(render);
    let mut fail_frames: usize = 0;
    gym_view.set_position(512, 30);
    for buttons in tas_buttons.iter() {
        if fail_frames > FAILURE_LOG_FRAMES {
            break;
        }
        let gym_values = extract_values_from_labels(&mut gym);
        gym_bytes.extend(gym_values.clone());

        let og_values = extract_values_from_labels(&mut og);
        og_bytes.extend(og_values.clone());

        if gym_values.as_slice() != og_values.as_slice() {
            fail_frames += 1;
        }

        if *verbose {
            println!("OG: {:?}", og_values);
            println!("Gym: {:?}", gym_values);
        }

        og.run_until_vblank();
        gym.run_until_vblank();
        util::set_controller_emu_native(&mut og, *buttons);
        util::set_controller_emu_native(&mut gym, *buttons);
        vanilla_view.render(&mut og);
        gym_view.render(&mut gym);
    }

    return (og_bytes, gym_bytes);
}

fn get_buttons_from_tasfile(filename: &PathBuf, verbose: &bool) -> Vec<u8> {
    let contents = read_to_string(filename).expect("can't open tasfile");

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
        // helps line things up
        if i < 2 {
            continue;
        }
        let mut button: u8 = 0;
        if right == "R" {
            button |= 0x80 // input::RIGHT 0x01
        }
        if left == "L" {
            button |= 0x40 // input::LEFT 0x02
        }
        if down == "D" {
            button |= 0x20 // input::DOWN 0x04
        }
        if up == "U" {
            button |= 0x10 // input::UP 0x08
        }
        if start == "T" {
            button |= 0x08 // input::START 0x10
        }
        if select == "S" {
            button |= 0x04 // input::SELECT 0x20
        }
        if b == "B" {
            button |= 0x02 // input::B 0x40
        }
        if a == "A" {
            button |= 0x01 // input::A 0x80
        }
        tas_buttons.push(button);

        if *verbose {
            eprintln!(
                "{:?} {:?} {:?} {:?} {:?} {:?} {:?} {:?} {:08b}",
                right, left, down, up, start, select, a, b, button,
            );
        }
    }
    for _ in 0..EXTRA_FRAMES {
        tas_buttons.push(0);
    }
    return tas_buttons;
}
