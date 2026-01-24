render: branchTo renderMode, \
            render_mode_static, \
            render_mode_menu, \
            render_mode_congratulations_screen, \
            render_mode_play_and_demo, \
            render_mode_pause, \
            render_mode_rocket, \
            render_mode_speed_test, \
            render_mode_level_menu, \
            render_mode_linecap_menu

.include "render_mode_level_menu.asm" ; no rts / jmp

render_mode_static:
        lda currentPpuCtrl
        and #$FC
        sta currentPpuCtrl
        jsr resetScroll
        rts

.include "render_mode_linecap.asm"
.include "render_mode_pause.asm"
.include "render_mode_congratulations_screen.asm"
.include "render_mode_rocket.asm"
.include "render_mode_speed_test.asm"
.include "render_mode_play_and_demo.asm"

.include "render_hz.asm"
.include "render_input_log.asm"
.include "render_score.asm"
.include "render_util.asm"
