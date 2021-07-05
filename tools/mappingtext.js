{
    const paletteLine = 0;
    const tileOffset = 0;
    const text = [...'on'.toUpperCase()];
    const byte = num => '$' + num.toString(16).padStart(2,0);
    const char = ch => ch.charCodeAt(0) + tileOffset - 55;
    const chunk = (n,o) => 0 in(n=[...n])?[n.splice(0,o),...chunk(n,o)]:n;
    const result = text.map((ch, i) => [0, char(ch), paletteLine, (i*8)].map(byte));

    console.log(chunk(result, 2).map(d => '        .byte   ' + d.join`,`).join`\n`);
    console.log('        .byte   $FF')
}
