Targets = %q(
      .byte $0,$0,$0,$0
      .byte $68,$1,$4B,$0 ; 1
      .byte $F8,$2,$6E,$0 ; 2
      .byte $7E,$4,$9A,$0 ; 3
      .byte $E6,$5,$E5,$0 ; 4
      .byte $6C,$7,$12,$1 ; 5
      .byte $CA,$8,$67,$1 ; 6
      .byte $5A,$A,$89,$1 ; 7
      .byte $B8,$B,$DE,$1 ; 8
      .byte $3E,$D,$B,$2 ; 9
      .byte $F2,$E,$A,$2 ; A
      .byte $2C,$10,$83,$2 ; B
      .byte $94,$11,$CD,$2 ; C
      .byte $38,$13,$DC,$2 ; D
      .byte $B4,$14,$13,$3 ; E
      .byte $08,$16,$72,$3
)
  .scan(/\$(.+),\$(.+),\$(.+),\$([0-9A-F]+)( |$)/i)
  .map.with_index { |a, i|
    [
      i.to_s(16).upcase,
      (a[1].to_i(16) << 8) + a[0].to_i(16),
      (a[3].to_i(16) << 8) + a[2].to_i(16)
    ]
  }

def print_pace(threshold, target, range, step = 1)
  _, base, mult = Targets[target]

  for i in range
    index = i * step
    if index <= threshold
      points = base
    else
      points = base + (((index-threshold) / (230.0-threshold)) * mult)
    end

    # print "
    #   T: #{target.to_s(16).upcase}\
    #   L: #{index}\
    #   M: #{points.floor}\
    #   P: #{(points * index).floor}\
    # "

    print "| #{target.to_s(16).upcase} | #{(points * index).floor} |\n"
  end
end

# pp targets

for target in 0..0xF
  print_pace 110, target, 130..130, 1
end

# print_pace 110, 0xA, 1..23, 10
