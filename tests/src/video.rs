use minifb::{Window, WindowOptions};

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

    pub fn update(&mut self, screen: &Vec<u32>) {
        self.window.update_with_buffer(screen, WIDTH, HEIGHT).unwrap();
    }
}
