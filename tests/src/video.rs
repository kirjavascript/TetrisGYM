use rusticnes_core::nes::NesState;
use minifb::{Window, WindowOptions, Key, KeyRepeat};

pub const WIDTH: usize = 256;
pub const HEIGHT: usize = 240;

pub struct Video {
    pub window: Window,
}

impl Video {
    pub fn new() -> Self {
        let mut window = Window::new(
            "video",
            WIDTH,
            HEIGHT,
            WindowOptions::default(),
        )
            .unwrap_or_else(|e| { panic!("{}", e); });

        window.set_position(20, 30);

        Self {
            window
        }
    }

    pub fn render(&mut self, emu: &mut NesState) {
        emu.ppu.render_ntsc(WIDTH);
        self.window.update_with_buffer(&emu.ppu.filtered_screen, WIDTH, HEIGHT).unwrap();
    }
}

/// debug helper for showing the current visual state.
/// hotkeys: 'q' closes window, 's' steps by a frame
#[allow(dead_code)]
pub fn preview(emu: &mut NesState) {
    let mut view = Video::new();
    view.window.set_key_repeat_rate(0.1);
    loop {
        if !view.window.is_open() {
            break;
        }
        if view.window.is_key_pressed(Key::Q, KeyRepeat::No) {
            break;
        }
        if view.window.is_key_pressed(Key::S, KeyRepeat::Yes) {
            emu.run_until_vblank();
        }
        view.render(emu);
    }
}
