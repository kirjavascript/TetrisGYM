tetris_obj := main.o tetris-ram.o tetris.o
cc65Path := tools/cc65/bin

MD5 := md5sum -c

tetris.nes: tetris.o main.o tetris-ram.o

tetris:= tetris.nes

.PHONY: clean compare

.SUFFIXES:

CAFLAGS = -g
LDFLAGS =

%.o: %.asm
		$(cc65Path)/ca65 $(CAFLAGS) --create-dep $@.d $< -o $@

%: %.cfg
		$(cc65Path)/ld65 $(LDFLAGS) -Ln $(basename $@).lbl --dbgfile $(basename $@).dbg -o $@ -C $< $(filter %.o,$^)
		
		
compare: $(tetris)
		@$(MD5) tetris.md5
		

clean:
	rm -f  $(tetris_obj) $(tetris) *.d tetris.dbg tetris.lbl 
	
	