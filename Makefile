tetris_obj := main.o tetris-ram.o tetris.o
cc65Path := tools/cc65/bin

# Manually list prerequisites that are generated. Non-generated files will
# automatically be computed.

tetris.nes: tetris.o main.o tetris-ram.o

tetris:= tetris.nes


# These are "true" phonies, and always execute something
.PHONY: clean

.SUFFIXES:

CAFLAGS = -g
LDFLAGS =

%.o: %.asm
		$(cc65Path)/ca65 $(CAFLAGS) --create-dep $@.d $< -o $@

%: %.cfg
		$(cc65Path)/ld65 $(LDFLAGS) -Ln $(basename $@).lbl --dbgfile $(basename $@).dbg -o $@ -C $< $(filter %.o,$^)



clean:
	rm -f  $(tetris_obj) $(tetris) *.d tetris.dbg tetris.lbl 



