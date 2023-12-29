cc65 binaries built as WebAssembly for TetrisGYM

generated with emscripten 

```bash
emmake make ld65 CC=emcc CFLAGS="-O3 -Wall" -Isrc/common/ LD=emcc OBJDIR="" HOST_OBJEXTENSION=".o" LDFLAGS="-sEXPORTED_RUNTIME_METHODS=FS -s FORCE_FILESYSTEM=1 -lnodefs.js -lnoderawfs.js"
```

Original source: https://github.com/cc65/cc65
