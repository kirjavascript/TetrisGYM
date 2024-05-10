use crate::{labels, util};

pub fn test() {
    // check some hardcoded ram addresses are aligned
    assert_eq!(labels::get("stack"), 0x100);
    assert_eq!(labels::get("playfield"), 0x400);
    assert_eq!(labels::get("highscores"), 0x700);
    assert_eq!(labels::get("menuRAM"), 0x760);

    // check the right amount of menu ram exists
    let qty = labels::get("MODE_QUANTITY") as usize;
    let cfg = labels::get("menuConfigSizeLookup") as usize;

    let mut menu_options = 0;

    for i in 0..qty {
        if util::rom_data()[cfg + i - 0x8000] != 0 {
            menu_options += 1;
        }
    }

    assert_eq!(menu_options, labels::get("palFlag") + 1 - labels::get("menuVars"));
}
