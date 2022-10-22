nmi:    pha
        txa
        pha
        tya
        pha
        lda #$00
        sta oamStagingLength
        jsr render
        dec sleepCounter
        lda sleepCounter
        cmp #$FF
        bne @jumpOverIncrement
        inc sleepCounter
@jumpOverIncrement:
        jsr copyOamStagingToOam
        lda frameCounter
        clc
        adc #$01
        sta frameCounter
        lda #$00
        adc frameCounter+1
        sta frameCounter+1
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        jsr copyCurrentScrollAndCtrlToPPU
        lda #$01
        sta verticalBlankingInterval
        jsr pollControllerButtons
        pla
        tay
        pla
        tax
        pla
irq:    rti

render: lda renderMode
        jsr switch_s_plus_2a
        .addr   render_mode_static
        .addr   render_mode_scroll
        .addr   render_mode_congratulations_screen
        .addr   render_mode_play_and_demo
        .addr   render_mode_pause
        .addr   render_mode_rocket
        .addr   render_mode_speed_test
        .addr   render_mode_level_menu
        .addr   render_mode_linecap_menu
