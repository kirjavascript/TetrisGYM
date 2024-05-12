use crate::labels;

pub fn test() {
    // check some hardcoded ram addresses are aligned
    assert_eq!(labels::get("stack"), 0x100);
    assert_eq!(labels::get("playfield"), 0x400);
    assert_eq!(labels::get("highscores"), 0x700);
    assert_eq!(labels::get("menuRAM"), 0x760);

    println!("{:x}", labels::get("LINECAP_HOW_STRING_OFFSET"));
}
