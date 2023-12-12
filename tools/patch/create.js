const { MarcFile, createBPSFromFiles } = require('./bps.js');
const fs = require('fs');
const { join: pathJoin } = require('path');

const [, , param0, param1, param2] = process.argv;

const cwd = process.cwd();

const patch = createBPSFromFiles(
    new MarcFile(pathJoin(cwd, param0)),
    new MarcFile(pathJoin(cwd, param1)),
    true,
).export('')._u8array;

fs.writeFileSync(pathJoin(cwd, param2), patch);
