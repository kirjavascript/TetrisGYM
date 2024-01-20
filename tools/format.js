const fs = require('fs');
const path = require('path');

function format(line) {
    return line.trimEnd().replace(/^\t+/, (_) => ' '.repeat(4 * _.length));
}

(function processFiles(directory) {
    const files = fs.readdirSync(directory);

    files.forEach(file => {
        const filePath = path.join(directory, file);
        const stat = fs.statSync(filePath);

        if (stat.isDirectory()) {
            processFiles(filePath);
        } else if (file.endsWith('.asm')) {
            const content = fs.readFileSync(filePath, 'utf8');
            fs.writeFileSync(filePath, content.split('\n').map(format).join('\n'));
        }
    });
})(process.cwd());
