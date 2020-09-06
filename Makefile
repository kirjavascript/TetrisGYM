tetris_obj := main.o tetris-ram.o tetris.o

MD5 := md5sum -c

CA65 := /usr/bin/ca65
LD65 := /usr/bin/ld65
nesChrEncode := python tools/nes_chr_encode.py

tetris.nes: tetris.o main.o tetris-ram.o

tetris:= tetris.nes

.SUFFIXES:
.SECONDEXPANSION:
.PRECIOUS:
.SECONDARY:
.PHONY: clean compare tools


CAFLAGS = -l *.lst -g
LDFLAGS =

compare: $(tetris)
		@$(MD5) tetris.md5
clean:
	rm -f  $(tetris_obj) $(tetris) *.d tetris.dbg tetris.lbl gfx/*.chr
	$(MAKE) clean -C tools/cTools/

tools:
	$(MAKE) -C tools/cTools/

# Build tools when building the rom.
# This has to happen before the rules are processed, since that's when scan_includes is run.
ifeq (,$(filter clean tools/cTools/,$(MAKECMDGOALS)))
$(info $(shell $(MAKE) -C tools/cTools/))
endif


%.o: dep = $(shell tools/cTools/scan_includes $(@D)/$*.asm)
$(tetris_obj): %.o: %.asm $$(dep)
		$(CA65) $(CAFLAGS) $*.asm -o $@

%: %.cfg
		$(LD65) $(LDFLAGS) -Ln $(basename $@).lbl --dbgfile $(basename $@).dbg -o $@ -C $< $(tetris_obj)



%.chr: %.png
		$(nesChrEncode) $< $@
