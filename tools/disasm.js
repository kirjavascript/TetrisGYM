const { writeFileSync, readFileSync } = require("fs");

buffer = [];
segments = {};

const dbgfile = readFileSync("tetris.dbg").toString().split(/\n/);

kvsplit = (line) => {
    [_, section, line] = line.match(/(\S+)\s+(\S+)/);
    line = line.trim().split(/,/);
    result = {};
    line.forEach((kv) => (([k, v] = kv.split(/=/)), (result[k] = v)));
    return result;
};

dbgfile
    .filter((l) => l.match(/^seg.*/))
    .forEach((l) => {
        kvs = kvsplit(l);
        segments[eval(kvs.name)] = {
            id: +kvs.id,
            name: eval(kvs.name),
            start: eval(kvs.start),
            size: eval(kvs.size),
            romOffset: eval(kvs.ooffs || "0"),
        };
    });

const listfile = readFileSync("tetris.lst").toString().split(/\n/);
const rom = readFileSync("tetris.nes");

segment = segments["ZEROPAGE"];
listfile.forEach((l, lineNo) => {
    if (l.match(/.*\.bss/)) segment = segments.BSS;
    if ((m = l.match(/\.segment\s+"(\w+)"/))) segment = segments[m[1]];

    offset = parseInt(l.slice(0, 6), 16);
    if (!isNaN(offset) && lineNo > 3) {
        bytecode = l.slice(11, 23);
        bytecode = bytecode.replace(/xx/g, "  ");
        slices = [
            bytecode.slice(0, 2),
            bytecode.slice(3, 5),
            bytecode.slice(6, 8),
        ];
        for (i = 0; i < slices.length; i++) {
            if (slices[i] === "rr") {
                slices[i] = rom[offset + segment.romOffset + i]
                    .toString(16)
                    .padStart(2, "0")
                    .toUpperCase();
            }
        }
        address =
            bytecode.trim() || l.match(/\.res/)
                ? (offset + segment.start)
                      .toString(16)
                      .padStart(4, "0")
                      .toUpperCase()
                : "    ";
        buffer.push(
            `${address} ${slices.join(" ").padEnd(2)} ${bytecode.slice(9)} ${l.slice(23)}`.trimEnd(),
        );
    } else {
        buffer.push(l);
    }
});

writeFileSync("tetris.txt", [...buffer].join("\n").trimEnd() + "\n");
