mod block;
mod input;
mod labels;
mod pushdown;
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
    foo: bool,
}

fn main() {
    let options = TestOptions::parse_args_default_or_exit();

    if options.foo {
        let mut emu = util::emulator(None);
        let mut view = video::Video::new();

        // spend a few frames bootstrapping
        for _ in 0..3 { emu.run_until_vblank(); }

        emu.memory.iram_raw[labels::get("practiseType") as usize] = labels::get("MODE_TYPEB") as _;
        emu.memory.iram_raw[labels::get("gameMode") as usize] = 4;
        emu.memory.iram_raw[labels::get("levelNumber") as usize] = 18;
        emu.memory.iram_raw[labels::get("typeBModifier") as usize] = 5;
        let label = labels::get("mainLoop");
        rusticnes_core::opcodes::push(&mut emu, (label >> 8) as u8);
        rusticnes_core::opcodes::push(&mut emu, label as u8);

        loop {
            emu.run_until_vblank();
            emu.ppu.render_ntsc(256);
            view.update(&emu.ppu.filtered_screen);
        }
    }

    // TODO: cycle counts for modes

    // run tests
    if options.test {
        sps::test();
        println!("sps is the same!");
        pushdown::test();
        println!("pushdown works!");
    }

    // print SPS sequences
    if options.sps_qty > 0 {
        let mut blocks = sps::SPS::new();

        blocks.set_input((
            ((options.sps_seed >> 16) & 0xFF) as u8,
            ((options.sps_seed >> 8) & 0xFF) as u8,
            (options.sps_seed& 0xFF) as u8,
        ));

        for _ in 0..options.sps_qty {
            print!("{:?}", blocks.next());
        }
        println!("");
    }
}
