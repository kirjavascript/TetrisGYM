mod labels;
mod pushdown;
mod util;
mod block;
mod sps;

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
}

fn main() {
    let options = TestOptions::parse_args_default_or_exit();

    // run SPS tests
    if options.test {
        sps::test();
        println!("sps works!");
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

        for i in 0..options.sps_qty {
            print!("{:?}", blocks.next());
        }
    }

    // TODO: cycle counts for modes
}
