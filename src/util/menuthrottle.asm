menuThrottle: ; add DAS-like movement to the menu
        sta menuThrottleTmp
        lda newlyPressedButtons_player1
        and menuThrottleTmp
        bne menuThrottleNew
        lda heldButtons_player1
        and menuThrottleTmp
        beq @endThrottle
        dec menuMoveThrottle
        beq menuThrottleContinue
@endThrottle:
        lda #0
        rts

menuThrottleStart := $10
menuThrottleRepeat := $4
menuThrottleNew:
        lda #menuThrottleStart
        sta menuMoveThrottle
        rts
menuThrottleContinue:
        lda #menuThrottleRepeat
        sta menuMoveThrottle
        rts
