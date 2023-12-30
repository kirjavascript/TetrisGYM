use std::collections::HashMap;
use std::sync::OnceLock;

fn parse_debug_line(line: &str) -> (String, u16) {
    let pairs: Vec<&str> = line.split(',').collect();

    let mut name = String::new();
    let mut val = 0;

    for pair in pairs {
        let key_val: Vec<&str> = pair.split('=').collect();
        if key_val.len() == 2 {
            let key = key_val[0].trim();
            let value = key_val[1].trim();

            match key {
                "name" => name = value.trim_matches('"').to_string(),
                "val" => {
                    if let Ok(hex_value) = u16::from_str_radix(value.trim_start_matches("0x"), 16) {
                        val = hex_value;
                    }
                }
                _ => {}
            }
        }
    }

    (name, val)
}

fn labels() -> &'static HashMap<String, u16> {
    static LABELS: OnceLock<HashMap<String, u16>> = OnceLock::new();
    LABELS.get_or_init(|| {
        let text = include_str!("../../tetris.dbg");
        let mut labels: HashMap<String, u16> = HashMap::new();

        for line in text.lines() {
            let (name, val) = parse_debug_line(line);

            if !name.is_empty() {
                labels.insert(name, val);
            }
        }

        labels
    })
}

fn addrs() -> &'static HashMap<u16, String> {
    static LABELS: OnceLock<HashMap<u16, String>> = OnceLock::new();
    LABELS.get_or_init(|| {
        let text = include_str!("../../tetris.dbg");
        let mut labels: HashMap<u16, String> = HashMap::new();

        for line in text.lines() {
            let (name, val) = parse_debug_line(line);

            if !name.is_empty() {
                labels.insert(val, name);
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
