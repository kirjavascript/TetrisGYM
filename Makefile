tetris_obj := main.o tetris-ram.o tetris.o
cc65Path := tools/cc65

MD5 := md5sum -c

CA65 := $(cc65Path)/bin/ca65
LD65 := $(cc65Path)/bin/ld65

tetris.nes: tetris.o main.o tetris-ram.o

tetris:= tetris.nes

.PHONY: clean compare

.SUFFIXES:

CAFLAGS =
LDFLAGS =

%.o: %.asm
		$(CA65) $^ -o $@

%: %.cfg
		$(LD65) $(LDFLAGS) -Ln $(basename $@).lbl --dbgfile $(basename $@).dbg -o $@ -C $< $(filter %.o,$^)
		
		
compare: $(tetris)
		@$(MD5) tetris.md5
		

clean:
	rm -f  $(tetris_obj) $(tetris) *.d tetris.dbg tetris.lbl 
	
	