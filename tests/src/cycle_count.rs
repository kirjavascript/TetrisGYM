use crate::{util, score, labels, playfield};
use rusticnes_core::nes::NesState;

pub fn count_cycles() {
    let mut emu = util::emulator(None);

    let completed_lines = labels::get("completedLines") as usize;
    let add_points = labels::get("addPointsRaw");
    let level_number = labels::get("levelNumber") as usize;

    let mut score = move |score: u32, lines: u8, level: u8| {
        score::set(&mut emu, score);
        emu.registers.pc = add_points;
        emu.memory.iram_raw[completed_lines] = lines;
        emu.memory.iram_raw[level_number] = level;
        util::cycles_to_return(&mut emu)
    };

    let mut highest = 0;

    // check every linecount on every level
    for level in 0..=255 {
        for lines in 0..=4 {
            let count = score(999999, lines, level);

            if count > highest {
                highest = count;
            }
        }
    }

    println!("scoring routine most cycles: {}", highest);

    use crate::video;

    // check clock cycles frames in each mode

    let mut emu = util::emulator(None);
    let mut view = video::Video::new();

    for _ in 0..3 { emu.run_until_vblank(); }

    let practise_type = labels::get("practiseType") as usize;
    let game_mode = labels::get("gameMode") as usize;
    let main_loop = labels::get("mainLoop");
    let level_number = labels::get("levelNumber") as usize;


    emu.memory.iram_raw[practise_type] = labels::get("MODE_TRANSITION") as _;
    emu.memory.iram_raw[level_number] = 18;
    emu.memory.iram_raw[game_mode] = 4;
    emu.registers.pc = main_loop;

    for _ in 0..5 { emu.run_until_vblank(); }

    let (mut highest, mut level, mut lines) = (0, 0, 0);

    for _ in 0..10 {

        for line in 0..5 {
            emu.memory.iram_raw[labels::get("currentPiece") as usize] = 0x11;
            emu.memory.iram_raw[labels::get("tetriminoX") as usize] = 0x5;
            emu.memory.iram_raw[labels::get("tetriminoY") as usize] = 0x11;
            emu.memory.iram_raw[labels::get("autorepeatY") as usize] = 0;
            emu.memory.iram_raw[labels::get("vramRow") as usize] = 0;

            playfield::clear(&mut emu);

            playfield::set_str(&mut emu, match line {
                0 => "",
                1 => "##### ####",
                2 => "##### ####\n##### ####",
                3 => "##### ####\n##### ####\n##### ####",
                4 => "##### ####\n##### ####\n##### ####\n##### ####",
                _ => unreachable!("line"),
            });

            emu.run_until_vblank();

            for _ in 0..[44, 47, 47, 46, 45][line] {

                let cycles = cycles_to_hblank(&mut emu);

                if cycles > highest {
                    highest = cycles;
                    level = emu.memory.iram_raw[level_number];
                    lines = line;
                }

                println!("{}/{} ({} {})", highest, cycles, lines, level);

                // std::thread::sleep(std::time::Duration::from_millis(50));

            }

                emu.ppu.render_ntsc(video::WIDTH);
                view.update(&emu.ppu.filtered_screen);

        }
    }

    // println!("{:#?}", (highest, level, lines));


    loop {}

}

fn cycles_to_hblank(emu: &mut NesState) -> u32 {
    let nmi_wait_start = labels::get("nmiWaitStart");
    let nmi_wait_end = labels::get("nmiWaitEnd");
    let mut cycles = 0;
    let mut done = false;

    while emu.ppu.current_scanline == 242 {
        emu.cycle();
        if !done {
            cycles += 1;
            if emu.registers.pc >= nmi_wait_start && emu.registers.pc <= nmi_wait_end {
                done = true
            }
        }
        let mut i = 0;
        while emu.cpu.tick >= 1 && i < 10 {
            emu.cycle();
            if !done {
                cycles += 1;
                if emu.registers.pc >= nmi_wait_start && emu.registers.pc <= nmi_wait_end {
                    done = true
                }
            }
            i += 1;
        }
        if emu.ppu.current_frame != emu.last_frame {
            emu.event_tracker.swap_buffers();
            emu.last_frame = emu.ppu.current_frame;
        }
    }
    while emu.ppu.current_scanline != 242 {
        emu.cycle();
        if !done {
            cycles += 1;
            if emu.registers.pc >= nmi_wait_start && emu.registers.pc <= nmi_wait_end {
                done = true
            }
        }
        let mut i = 0;
        while emu.cpu.tick >= 1 && i < 10 {
            emu.cycle();
            if !done {
                cycles += 1;
                if emu.registers.pc >= nmi_wait_start && emu.registers.pc <= nmi_wait_end {
                    done = true
                }
            }
            i += 1;
        }
        if emu.ppu.current_frame != emu.last_frame {
            emu.event_tracker.swap_buffers();
            emu.last_frame = emu.ppu.current_frame;
        }
    }

    cycles
}
