use minifb::{Window, WindowOptions};

const WIDTH: usize = 256;
const HEIGHT: usize = 240;

pub struct Video {
    pub window: Window,
}

impl Video {
    pub fn new() -> Self {
        let window = Window::new(
            "video",
            WIDTH,
            HEIGHT,
            WindowOptions::default(),
        )
            .unwrap_or_else(|e| { panic!("{}", e); });

        Self {
            window
        }
    }

    pub fn update(&mut self, screen: &Vec<u32>) {
        self.window.update_with_buffer(screen, WIDTH, HEIGHT).unwrap();
    }
}
