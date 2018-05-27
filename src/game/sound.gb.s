SECTION "SoundLogic",ROM0


; General Sound Functions -----------------------------------------------------
; -----------------------------------------------------------------------------
sound_enable:

    ; enable sound circuits
    ld      a,%10000000
    ld      [$ff26],a

    ; enable both speakers and set to maximum volume
    ld      a,%1111_1111
    ld      [$ff24],a

    ; output all channels to both speakers
    ld      a,%1111_1111
    ld      [$ff25],a

    ret

sound_effect_confirm:
    channelOne(4, 0, 7, 1, 2, 7, 0, $F, $05F0, 1)
    ret

sound_effect_cancel:
    channelOne(4, 1, 7, 1, 2, 7, 0, $F, $05F0, 1)
    ret

sound_effect_select:
    channelOne(2, 0, 7, 0, 2, 7, 0, $F, $0540, 1)
    ret

sound_effect_pause:
    channelOne(2, 0, 6, 1, 2, 7, 0, $F, $0200, 1)
    ret

sound_effect_unpause:
    channelOne(3, 0, 7, 1, 2, 7, 0, $F, $04E0, 1)
    ret

sound_effect_bullet:
    ;channelOne(4, 1, 3, $10, 2, 0, 0, $F, $0710, 1)
    channelOne(4, 1, 3, $10, 2, 1, 0, $F, $0730, 1)
    ;channelThree($0730, 1)
    ret

sound_effect_thrust:
    channelFour($00, 3, 0, $8, 4, 0, 3, 0)
    ret

sound_effect_impact:
    ; TODO use channel two instead?
    ; TODO or only play when bullet effect is not active?
    ;channelOne(1, 1, 3, $2F, 1, 7, 0, $F, $06B0, 1)
    channelTwo($34, 2, 1, 0, $D, $0310, 1)
    ret

sound_effect_impact_heavy:
    ; TODO use channel two instead?
    ; TODO or only play when bullet effect is not active?
    ;channelOne(1, 1, 2, $2F, 2, 7, 0, $F, $0770, 1)
    channelTwo($3B, 2, 1, 0, $8, $0700, 1)
    ret

sound_effect_ship_destroy:
    channelFour($00, 7, 0, $F, 4, 0, 6, 0)
    ret

sound_effect_shield_damage:
    channelFour(00, 3, 0, $F, 3, 1, 5, 0)
    ret

sound_effect_break:
    ; TODO have a actual sound engine with playback priority and other stuff
    ; TODO so we can remove this hack
    ld      a,[playerShield]
    cp      0
    ret     z

    call    math_random
    bit     3,a
    jr      nz,.four
    bit     2,a
    jr      nz,.three
    bit     1,a
    jr      nz,.two

.one:
    channelFour($2A, 2, 0, $F, 4, 0, 6, 0)
    ret
.two:
    channelFour($2A, 2, 0, $F, 5, 0, 6, 0)
    ret
.three:
    channelFour($2A, 2, 0, $F, 4, 1, 7, 0)
    ret
.four:
    channelFour($2A, 2, 0, $F, 5, 1, 7, 0)
    ret


MACRO channelOne(@sweepShift, @sweepDir, @sweepTime, @length, @dutyCycle, @envSweep, @envDir, @envInVol, @frequency, @timed)
    ld      a,(@sweepTime << 4) | (@sweepDir << 3) | @sweepShift
    ld      [$ff10],a
    ld      a,(@dutyCycle << 6) | @length
    ld      [$ff11],a
    ld      a,(@envInVol << 4) | (@envDir << 3) | @envSweep
    ld      [$ff12],a
    ld      a,@frequency & $ff
    ld      [$ff13],a
    ld      a,(@frequency >> 8) | (@timed << 6) | $80
    ld      [$ff14],a
ENDMACRO

MACRO channelTwo(@length, @dutyCycle, @envSweep, @envDir, @envInVol, @frequency, @timed)
    ld      a,(@dutyCycle << 6) | @length
    ld      [$ff16],a
    ld      a,(@envInVol << 4) | (@envDir << 3) | @envSweep
    ld      [$ff17],a
    ld      a,@frequency & $ff
    ld      [$ff18],a
    ld      a,((@frequency >> 8) & %0000_0111) | (@timed << 6) | $80
    ld      [$ff19],a
ENDMACRO

MACRO channelFour(@length, @envSweep, @envDir, @envInVol, @ratio, @step, @shift, @timed)
    ld      a,@length
    ld      [$ff20],a
    ld      a,(@envInVol << 4) | (@envDir << 3) | @envSweep
    ld      [$ff21],a
    ld      a,(@shift << 4) | @step << 3 | @ratio
    ld      [$ff22],a
    ld      a,(@timed << 6) | $80
    ld      [$ff23],a
ENDMACRO

MACRO channelThree(@frequency, @timed)

    ; master enable
    ld      a,$80
    ld      [$ff1A],a

    ; volume
    ld      a,%0110_0000
    ld      [$ff1C],a

    ld      a,$90
    ld      [$ff1B],a

    ld      a,@frequency & $ff
    ld      [$ff1D],a

    ld      a,((@frequency >> 8) & %0000_0111) | (@timed << 6) | $80
    ld      [$ff1E],a
ENDMACRO

