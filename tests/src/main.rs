mod block;
mod drought;
mod input;
mod labels;
mod pushdown;
mod rng;
mod score;
mod sps;
mod util;
mod video;

use gumdrop::Options;

fn parse_hex(s: &str) -> Result<u32, std::num::ParseIntError> {
    u32::from_str_radix(s, 16)
}

#[derive(Debug, Options)]
struct TestOptions {
    help: bool,
    #[options(help = "run tests")]
    test: bool,
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

    // run tests
    if options.test {
        score::test();
        println!("score works!");
        score::test_render();
        println!("score rendering works!");
        pushdown::test();
        println!("pushdown works!");
        rng::test();
        println!("rng seeds are the same!");
        sps::test();
        println!("sps is the same!");
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

            emu.ppu.render_ntsc(video::WIDTH);
            view.update(&emu.ppu.filtered_screen);
        });
        loop {}
    }

}
