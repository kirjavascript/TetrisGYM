function konamiComp(_buffer) {
    const buffer = Array.from(_buffer);
    const compressed = [];

    for (let i = 0; i < buffer.length;) {
        const byte = buffer[i];

        // count extra dupes
        let peek = 0;
        for (;byte ==buffer[i+1+peek];peek++);
        const count = Math.min(peek + 1, 0x80);

        if (peek > 0) {
            compressed.push([count, byte]);
            i+= count;
        } else {
            // we have already peeked the next byte and know it's not a double
            // so start checking from there
            const start = i + 1;
            const nextDouble = buffer.slice(start, start + 0x7F)
                .findIndex((d,i,a)=>d==a[i+1]);

            const count = Math.min(nextDouble === -1
                ? buffer.length - i
                : nextDouble + 1, 0x7F);

            compressed.push([0x80 + count, buffer.slice(i, count + i)]);
            i += count;
        }

    }

    compressed.push(0xFF);

    const flat = compressed.flat(Infinity);

    console.log(`compressed ${buffer.length} -> ${flat.length}`);

    return flat;
}
