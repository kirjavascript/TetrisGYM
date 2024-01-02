mod labels;
mod pushdown;
mod util;
mod block;

use gumdrop::Options;

#[derive(Debug, Options)]
struct TestOptions {
    help: bool,
    #[options(help = "run tests")]
    test: bool,
}

fn main() {
    let options = TestOptions::parse_args_default_or_exit();

    if options.test {
        pushdown::test();
        println!("pushdown works!");
    }

    let mut emu = util::emulator(None);

    let seed_0 = 0x88;
    let seed_1 = 0x88;
    let seed_2 = 0x88;

    emu.memory.iram_raw[(labels::get("set_seed_input") + 0) as usize] = seed_0;
    emu.memory.iram_raw[(labels::get("set_seed") + 0) as usize] = seed_0;
    emu.memory.iram_raw[(labels::get("set_seed_input") + 1) as usize] = seed_1;
    emu.memory.iram_raw[(labels::get("set_seed") + 1) as usize] = seed_1;
    emu.memory.iram_raw[(labels::get("set_seed_input") + 2) as usize] = seed_2;
    emu.memory.iram_raw[(labels::get("set_seed") + 2) as usize] = seed_2;


    for i in 0..12 {
        emu.registers.pc = labels::get("pickTetriminoSeed");
        util::run_to_return(&mut emu, false);

        let block: block::Block = emu.memory.iram_raw[labels::get("spawnID") as usize].into();

        println!("{:#?}", block);
    }
}
