use crate::{labels, util};

const PALETTES: [[u8; 3]; 256] = [
    [48, 33, 18], // 0
    [48, 41, 26], // 1
    [48, 36, 20], // 2
    [48, 42, 18], // 3
    [48, 43, 21], // 4
    [48, 34, 43], // 5
    [48, 0, 22],  // 6
    [48, 5, 19],  // 7
    [48, 22, 18], // 8
    [48, 39, 22], // 9
    [48, 33, 18], // 10
    [48, 41, 26], // 11
    [48, 36, 20], // 12
    [48, 42, 18], // 13
    [48, 43, 21], // 14
    [48, 34, 43], // 15
    [48, 0, 22],  // 16
    [48, 5, 19],  // 17
    [48, 22, 18], // 18
    [48, 39, 22], // 19
    [48, 33, 18], // 20
    [48, 41, 26], // 21
    [48, 36, 20], // 22
    [48, 42, 18], // 23
    [48, 43, 21], // 24
    [48, 34, 43], // 25
    [48, 0, 22],  // 26
    [48, 5, 19],  // 27
    [48, 22, 18], // 28
    [48, 39, 22], // 29
    [48, 33, 18], // 30
    [48, 41, 26], // 31
    [48, 36, 20], // 32
    [48, 42, 18], // 33
    [48, 43, 21], // 34
    [48, 34, 43], // 35
    [48, 0, 22],  // 36
    [48, 5, 19],  // 37
    [48, 22, 18], // 38
    [48, 39, 22], // 39
    [48, 33, 18], // 40
    [48, 41, 26], // 41
    [48, 36, 20], // 42
    [48, 42, 18], // 43
    [48, 43, 21], // 44
    [48, 34, 43], // 45
    [48, 0, 22],  // 46
    [48, 5, 19],  // 47
    [48, 22, 18], // 48
    [48, 39, 22], // 49
    [48, 33, 18], // 50
    [48, 41, 26], // 51
    [48, 36, 20], // 52
    [48, 42, 18], // 53
    [48, 43, 21], // 54
    [48, 34, 43], // 55
    [48, 0, 22],  // 56
    [48, 5, 19],  // 57
    [48, 22, 18], // 58
    [48, 39, 22], // 59
    [48, 33, 18], // 60
    [48, 41, 26], // 61
    [48, 36, 20], // 62
    [48, 42, 18], // 63
    [48, 43, 21], // 64
    [48, 34, 43], // 65
    [48, 0, 22],  // 66
    [48, 5, 19],  // 67
    [48, 22, 18], // 68
    [48, 39, 22], // 69
    [48, 33, 18], // 70
    [48, 41, 26], // 71
    [48, 36, 20], // 72
    [48, 42, 18], // 73
    [48, 43, 21], // 74
    [48, 34, 43], // 75
    [48, 0, 22],  // 76
    [48, 5, 19],  // 77
    [48, 22, 18], // 78
    [48, 39, 22], // 79
    [48, 33, 18], // 80
    [48, 41, 26], // 81
    [48, 36, 20], // 82
    [48, 42, 18], // 83
    [48, 43, 21], // 84
    [48, 34, 43], // 85
    [48, 0, 22],  // 86
    [48, 5, 19],  // 87
    [48, 22, 18], // 88
    [48, 39, 22], // 89
    [48, 33, 18], // 90
    [48, 41, 26], // 91
    [48, 36, 20], // 92
    [48, 42, 18], // 93
    [48, 43, 21], // 94
    [48, 34, 43], // 95
    [48, 0, 22],  // 96
    [48, 5, 19],  // 97
    [48, 22, 18], // 98
    [48, 39, 22], // 99
    [48, 33, 18], // 100
    [48, 41, 26], // 101
    [48, 36, 20], // 102
    [48, 42, 18], // 103
    [48, 43, 21], // 104
    [48, 34, 43], // 105
    [48, 0, 22],  // 106
    [48, 5, 19],  // 107
    [48, 22, 18], // 108
    [48, 39, 22], // 109
    [48, 33, 18], // 110
    [48, 41, 26], // 111
    [48, 36, 20], // 112
    [48, 42, 18], // 113
    [48, 43, 21], // 114
    [48, 34, 43], // 115
    [48, 0, 22],  // 116
    [48, 5, 19],  // 117
    [48, 22, 18], // 118
    [48, 39, 22], // 119
    [48, 33, 18], // 120
    [48, 41, 26], // 121
    [48, 36, 20], // 122
    [48, 42, 18], // 123
    [48, 43, 21], // 124
    [48, 34, 43], // 125
    [48, 0, 22],  // 126
    [48, 5, 19],  // 127
    [48, 22, 18], // 128
    [48, 39, 22], // 129
    [48, 33, 18], // 130
    [48, 41, 26], // 131
    [48, 36, 20], // 132
    [48, 42, 18], // 133
    [48, 43, 21], // 134
    [48, 34, 43], // 135
    [48, 0, 22],  // 136
    [48, 5, 19],  // 137
    [38, 41, 37], // 138
    [9, 20, 48],  // 139
    [41, 32, 5],  // 140
    [38, 9, 37],  // 141
    [9, 20, 48],  // 142
    [41, 32, 5],  // 143
    [32, 37, 9],  // 144
    [32, 48, 22], // 145
    [62, 9, 1],   // 146
    [32, 37, 36], // 147
    [0, 16, 14],  // 148
    [36, 37, 55], // 149
    [37, 32, 43], // 150
    [5, 38, 12],  // 151
    [24, 37, 37], // 152
    [55, 16, 54], // 153
    [36, 9, 28],  // 154
    [48, 41, 0],  // 155
    [36, 5, 5],   // 156
    [1, 41, 1],   // 157
    [8, 41, 5],   // 158
    [0, 38, 63],  // 159
    [22, 25, 5],  // 160
    [32, 41, 25], // 161
    [62, 9, 1],   // 162
    [7, 37, 38],  // 163
    [63, 12, 38], // 164
    [32, 43, 24], // 165
    [63, 41, 0],  // 166
    [14, 32, 37], // 167
    [9, 5, 16],   // 168
    [38, 19, 38], // 169
    [61, 0, 31],  // 170
    [10, 10, 10], // 171
    [7, 42, 61],  // 172
    [25, 32, 32], // 173
    [25, 32, 38], // 174
    [37, 23, 24], // 175
    [26, 41, 7],  // 176
    [7, 48, 8],   // 177
    [61, 14, 25], // 178
    [25, 16, 28], // 179
    [23, 32, 2],  // 180
    [7, 43, 37],  // 181
    [41, 7, 24],  // 182
    [25, 9, 7],   // 183
    [6, 56, 41],  // 184
    [12, 42, 25], // 185
    [61, 14, 25], // 186
    [25, 32, 0],  // 187
    [0, 0, 1],    // 188
    [1, 1, 2],    // 189
    [3, 4, 4],    // 190
    [5, 5, 5],    // 191
    [48, 33, 18], // 192
    [48, 41, 26], // 193
    [48, 36, 20], // 194
    [48, 42, 18], // 195
    [48, 43, 21], // 196
    [48, 34, 43], // 197
    [48, 0, 22],  // 198
    [48, 5, 19],  // 199
    [48, 22, 18], // 200
    [48, 39, 22], // 201
    [38, 41, 37], // 202
    [9, 20, 48],  // 203
    [41, 32, 5],  // 204
    [38, 9, 37],  // 205
    [9, 20, 48],  // 206
    [41, 32, 5],  // 207
    [32, 37, 9],  // 208
    [32, 48, 22], // 209
    [62, 9, 1],   // 210
    [32, 37, 36], // 211
    [0, 16, 14],  // 212
    [36, 37, 55], // 213
    [37, 32, 43], // 214
    [5, 38, 12],  // 215
    [24, 37, 37], // 216
    [55, 16, 54], // 217
    [36, 9, 28],  // 218
    [48, 41, 0],  // 219
    [36, 5, 5],   // 220
    [1, 41, 1],   // 221
    [8, 41, 5],   // 222
    [0, 38, 63],  // 223
    [22, 25, 5],  // 224
    [32, 41, 25], // 225
    [62, 9, 1],   // 226
    [7, 37, 38],  // 227
    [63, 12, 38], // 228
    [32, 43, 24], // 229
    [63, 41, 0],  // 230
    [14, 32, 37], // 231
    [9, 5, 16],   // 232
    [38, 19, 38], // 233
    [61, 0, 31],  // 234
    [10, 10, 10], // 235
    [7, 42, 61],  // 236
    [25, 32, 32], // 237
    [25, 32, 38], // 238
    [37, 23, 24], // 239
    [26, 41, 7],  // 240
    [7, 48, 8],   // 241
    [61, 14, 25], // 242
    [25, 16, 28], // 243
    [23, 32, 2],  // 244
    [7, 43, 37],  // 245
    [41, 7, 24],  // 246
    [25, 9, 7],   // 247
    [6, 56, 41],  // 248
    [12, 42, 25], // 249
    [61, 14, 25], // 250
    [25, 32, 0],  // 251
    [0, 0, 1],    // 252
    [1, 1, 2],    // 253
    [3, 4, 4],    // 254
    [5, 5, 5],    // 255
];

pub fn test() {
    let mut emu = util::emulator(None);

    let main_loop = labels::get("mainLoop");
    let game_mode = labels::get("gameMode") as usize;
    let level_number = labels::get("levelNumber") as usize;
    let render_flags = labels::get("renderFlags") as usize;


    // spend a few frames bootstrapping
    for _ in 0..3 {
        emu.run_until_vblank();
    }

    emu.memory.iram_raw[game_mode] = 4;
    emu.registers.pc = main_loop;

    for _ in 0..11 {
        emu.run_until_vblank();
    }

    for level in 0..256 {
        emu.memory.iram_raw[level_number] = level as u8;
        emu.memory.iram_raw[render_flags] = labels::get("RENDER_LEVEL") as u8;
        emu.run_until_vblank();
        let bg_palette = &emu.ppu.palette[9..12];
        let sprite_palette = &emu.ppu.palette[25..28];
        assert_eq!(bg_palette, sprite_palette);
        assert_eq!(bg_palette, PALETTES[level]);
    }

    let pal_flag = labels::get("palFlag") as usize;
    emu.memory.iram_raw[pal_flag] = 1;

    for level in 0..256 {
        emu.memory.iram_raw[level_number] = level as u8;
        emu.memory.iram_raw[render_flags] = labels::get("RENDER_LEVEL") as u8;
        emu.run_until_vblank();
        let bg_palette = &emu.ppu.palette[9..12];
        let sprite_palette = &emu.ppu.palette[25..28];

        assert_eq!(bg_palette, sprite_palette);

        if level == 181 || level == 245 {
            assert_eq!(bg_palette, [0x21, 0x2b, 0x25]);
        } else {
            assert_eq!(bg_palette, PALETTES[level]);
        }
    }
}
