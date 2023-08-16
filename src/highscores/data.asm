hPATStart := $2103
hPATInc := $80

highScorePpuAddrTable:
        .dbyt   hPATStart,hPATStart+(hPATInc*1),hPATStart+(hPATInc*2),hPATStart+(hPATInc*3),hPATStart+(hPATInc*4)
highScoreCharToTile:
        .byte   $FF,$0A,$0B,$0C,$0D,$0E,$0F,$10
        .byte   $11,$12,$13,$14,$15,$16,$17,$18
        .byte   $19,$1A,$1B,$1C,$1D,$1E,$1F,$20
        .byte   $21,$22,$23,$00,$01,$02,$03,$04
        .byte   $05,$06,$07,$08,$09,$25,$4F,$5E
        .byte   $5F,$6E,$6F,$52,$55,$24
highScoreCharSize := $2E
