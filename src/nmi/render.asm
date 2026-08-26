.enum
RENDER_DISABLE
RENDER_IDLE
RENDER_CONGRATS
RENDER_PLAY
RENDER_PAUSE
RENDER_ROCKET
RENDER_SPEED_TEST
RENDER_LEVEL_MENU
RENDER_PLAYFIELD
RENDER_TOPROWS
RENDER_QUEUE
.endenum

render: branchTo renderMode, \
            render_mode_disable, \
            render_mode_idle, \
            render_mode_congratulations_screen, \
            render_mode_play_and_demo, \
            render_mode_pause, \
            render_mode_rocket, \
            render_mode_speed_test, \
            render_mode_level_menu, \
            render_mode_dump_playfield, \
            render_mode_top_rows, \
            render_mode_queue

.include "render_mode_level_menu.asm" ; no rts / jmp

render_mode_idle:
render_mode_disable:
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
