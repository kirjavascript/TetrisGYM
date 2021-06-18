// node tools/freespace.js "$(realpath -m ./tetris.nes)"

free = 0;
qty = 0;
chunks = [];
count = (byte) => {
    if (byte === 0) {
        qty++;
    } else {
        if (qty > 0x10) {
            free += qty;
            chunks.push(qty);
        }
        qty = 0;
    }
};
[...require('fs').readFileSync(process.argv[2])].forEach((byte, i) => {

    if (i >= 0x8000) return;
    count(byte);
});
count(0xFF);

function bytes(input, places = 2) {
    const sizes = ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'];
    const LEN = sizes.length;
    let index = Math.floor(Math.log(input) / Math.log(1024));
    let val = input / (1024 ** index);
    let suffix = index < LEN ? sizes[index] : '?';
    return (`${index > 0 ? val.toFixed(places) : val}${suffix}B`);
}

console.log('~' + bytes(free) + ' of PRG_chunk1 free');
