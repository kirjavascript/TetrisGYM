use std::collections::HashMap;
use std::sync::OnceLock;

fn labels() -> &'static HashMap<String, u16> {
    static LABELS: OnceLock<HashMap<String, u16>> = OnceLock::new();
    LABELS.get_or_init(|| {
        let text = include_str!("../../tetris.lbl");
        let mut labels: HashMap<String, u16> = HashMap::new();

        for line in text.lines() {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 2 {
                if let Ok(hex_value) = u16::from_str_radix(parts[1], 16) {
                    labels.insert(parts[2].to_string(), hex_value);
                }
            }
        }

        labels
    })
}

fn addrs() -> &'static HashMap<u16, String> {
    static LABELS: OnceLock<HashMap<u16, String>> = OnceLock::new();
    LABELS.get_or_init(|| {
        let text = include_str!("../../tetris.lbl");
        let mut labels: HashMap<u16, String> = HashMap::new();

        for line in text.lines() {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 2 {
                if let Ok(hex_value) = u16::from_str_radix(parts[1], 16) {
                    labels.insert(hex_value, parts[2].to_string());
                }
            }
        }

        labels
    })
}

pub fn get(label: &str) -> u16 {
    *labels().get(label).expect(&format!("label {} not found", label))
}

pub fn from_addr(addr: u16) -> Option<&'static String> {
    addrs().get(&addr)
}
