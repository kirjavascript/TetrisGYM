mod labels;
mod util;
mod pushdown;

use gumdrop::Options;

#[derive(Debug, Options)]
struct TestOptions {
    help: bool,
    #[options(help="run tests")]
    test: bool,
}

fn main() {
    let options = TestOptions::parse_args_default_or_exit();

    if options.test {
        pushdown::test();
        println!("pushdown works!");
    }

    let mut emu = util::emulator(None);

    emu.memory.iram_raw[labels::get("practiseType") as usize] = labels::get("MODE_SEED") as u8;

}
