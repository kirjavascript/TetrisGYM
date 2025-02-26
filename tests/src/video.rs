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
/// hotkeys: 'q' closes window, 's' steps by a frame, 'p' toggles autoplay
#[allow(dead_code)]
pub fn preview(emu: &mut NesState) {
    preview_base(emu, false);
}

/// debug viewer with keyboard input
#[allow(dead_code)]
pub fn preview_input(emu: &mut NesState) {
    preview_base(emu, true);
}

fn preview_base(emu: &mut NesState, has_input: bool) {
    let mut view = Video::new();
    let mut running = false;
    view.window.set_key_repeat_rate(0.1);
    view.window.set_target_fps(60);

    loop {
        if has_input {
            use crate::input::*;
            let mut buttons = 0;

            if view.window.is_key_down(Key::Up) { buttons |= UP; }
            if view.window.is_key_down(Key::Down) { buttons |= DOWN; }
            if view.window.is_key_down(Key::Left) { buttons |= LEFT; }
            if view.window.is_key_down(Key::Right) { buttons |= RIGHT; }
            if view.window.is_key_down(Key::V) { buttons |= START; }
            if view.window.is_key_down(Key::C) { buttons |= SELECT; }
            if view.window.is_key_down(Key::X) { buttons |= A; }
            if view.window.is_key_down(Key::Z) { buttons |= B; }

            crate::util::set_controller_raw(emu, buttons);
        }

        if !view.window.is_open() {
            break;
        }
        if view.window.is_key_pressed(Key::Q, KeyRepeat::No) {
            break;
        }
        if view.window.is_key_pressed(Key::P, KeyRepeat::No) {
            running = !running;
        }
        if running || view.window.is_key_pressed(Key::S, KeyRepeat::Yes) {
            emu.run_until_vblank();
        }

        view.render(emu);
    }
}
