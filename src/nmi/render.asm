renderRTSJumpHi:
    .byte >(render_mode_static-1)
    .byte >(render_mode_menu-1)
    .byte >(render_mode_congratulations_screen-1)
    .byte >(render_mode_play_and_demo-1)
    .byte >(render_mode_pause-1)
    .byte >(render_mode_rocket-1)
    .byte >(render_mode_speed_test-1)
    .byte >(render_mode_level_menu-1)
    .byte >(render_mode_linecap_menu-1)

renderRTSJumpLo:
    .byte <(render_mode_static-1)
    .byte <(render_mode_menu-1)
    .byte <(render_mode_congratulations_screen-1)
    .byte <(render_mode_play_and_demo-1)
    .byte <(render_mode_pause-1)
    .byte <(render_mode_rocket-1)
    .byte <(render_mode_speed_test-1)
    .byte <(render_mode_level_menu-1)
    .byte <(render_mode_linecap_menu-1)

render:
        ldx renderMode
        lda renderRTSJumpHi,x
        pha
        lda renderRTSJumpLo,x
        pha
        rts

; render: lda renderMode
;         jsr switch_s_plus_2a
;         .addr   render_mode_static
;         .addr   render_mode_menu
;         .addr   render_mode_congratulations_screen
;         .addr   render_mode_play_and_demo
;         .addr   render_mode_pause
;         .addr   render_mode_rocket
;         .addr   render_mode_speed_test
;         .addr   render_mode_level_menu
;         .addr   render_mode_linecap_menu

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
