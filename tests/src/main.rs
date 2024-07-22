mod block;
mod cycle_count;
mod input;
mod labels;
mod playfield;
mod util;
mod video;

mod drought;
mod floor;
mod garbage;
mod mapper;
mod palettes;
mod pushdown;
mod rng;
mod score;
mod sps;
mod toprow;
mod tspins;
mod hz_display;
mod nmi;
mod constants;
mod patch;

use gumdrop::Options;

fn parse_hex(s: &str) -> Result<u32, std::num::ParseIntError> {
    u32::from_str_radix(s, 16)
}

#[derive(Debug, Options)]
struct TestOptions {
    help: bool,
    #[options(help = "run tests")]
    test: bool,
    #[options(help = "run single tests")]
    test_single: Option<String>,
    #[options(help = "count cycles")]
    cycles: bool,
    #[options(help = "set SPS seed", parse(try_from_str = "parse_hex"))]
    sps_seed: u32,
    #[options(help = "print SPS pieces")]
    sps_qty: u32,
    #[options(help = "list RNG seeds")]
    rng_seeds: bool,
    #[options(help = "list drought mode probabilities")]
    drought_probs: bool,
    foo: bool,
}

fn main() {
    let options = TestOptions::parse_args_default_or_exit();

    let tests: [(&str, fn()); 15] = [
        ("garbage4", garbage::test_garbage4_crash),
        ("floor", floor::test),
        ("tspins", tspins::test),
        ("top row bug", toprow::test),
        ("score", score::test),
        ("score_render", score::test_render),
        ("mapper", mapper::test),
        ("pushdown", pushdown::test),
        ("rng seeds", rng::test),
        ("sps", sps::test),
        ("palettes", palettes::test),
        ("hz_display", hz_display::test),
        ("nmi", nmi::test),
        ("constants", constants::test),
        ("patch", patch::test),
    ];

    // run tests
    if options.test {
        tests.iter().for_each(|(name, test)| {
            test();
            println!(">> {name} ✅");
        });
    }

    // run single test
    if let Some(name) = options.test_single {
        let found = tests.iter().find(|&test| test.0 == name);
        if let Some(test) = found {
            test.1();
            println!(">> {name} ✅");
        } else {
            println!("no such test {name}");
        }
    }

    // count cycles
    if options.cycles {
        cycle_count::count_cycles();
    }

    // print SPS sequences
    if options.sps_qty > 0 {
        let mut blocks = sps::SPS::new();

        blocks.set_input((
                ((options.sps_seed >> 16) & 0xFF) as u8,
                ((options.sps_seed >> 8) & 0xFF) as u8,
                (options.sps_seed & 0xFF) as u8,
        ));

        for _ in 0..options.sps_qty {
            print!("{:?}", blocks.next());
        }
        println!("");
    }

    if options.rng_seeds {
        println!("{:?}", rng::seeds());
    }

    if options.drought_probs {
        drought::print_probabilities();
    }

    // other stuff

    if options.foo {
        let mut emu = util::emulator(None);
        let mut view = video::Video::new();

        let rng_seed = labels::get("rng_seed") as usize;
        let main_loop = labels::get("mainLoop");
        let practise_type = labels::get("practiseType") as usize;
        let game_mode = labels::get("gameMode") as usize;
        let level_number = labels::get("levelNumber") as usize;
        let b_modifier = labels::get("typeBModifier") as usize;
        let mode_typeb = labels::get("MODE_TYPEB") as u8;

        rng::seeds().iter().for_each(|seed| {
            emu.reset();

            // spend a few frames bootstrapping
            for _ in 0..3 {
                emu.run_until_vblank();
            }

            emu.memory.iram_raw[practise_type] = mode_typeb;
            emu.memory.iram_raw[game_mode] = 4;
            emu.memory.iram_raw[level_number] = 18;
            emu.memory.iram_raw[b_modifier] = 5;

            emu.memory.iram_raw[rng_seed] = (seed >> 8) as u8;
            emu.memory.iram_raw[rng_seed + 1] = *seed as u8;

            rusticnes_core::opcodes::push(&mut emu, (main_loop >> 8) as u8);
            rusticnes_core::opcodes::push(&mut emu, main_loop as u8);

            for _ in 0..23 {
                emu.run_until_vblank();
            }

            view.render(&mut emu);
        });
        loop {}
    }

}
