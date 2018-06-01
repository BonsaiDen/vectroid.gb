SECTION "SoundLogic",ROM0

; Sound Effects ---------------------------------------------------------------
sound_effect_confirm:
    play_effect(effect_confirm, SOUND_PRIORITY_LOW)
    ret

sound_effect_cancel:
    play_effect(effect_cancel, SOUND_PRIORITY_LOW)
    ret

sound_effect_select:
    play_effect(effect_select, SOUND_PRIORITY_LOW)
    ret

sound_effect_pause:
    play_effect(effect_pause, SOUND_PRIORITY_LOW)
    ret

sound_effect_unpause:
    play_effect(effect_unpause, SOUND_PRIORITY_LOW)
    ret

sound_effect_bullet:
    call    math_random
    bit     3,a
    jr      nz,.four
    bit     2,a
    jr      nz,.three
    bit     1,a
    jr      nz,.two

.one:
    play_effect(effect_bullet_1, SOUND_PRIORITY_MEDIUM)
    ret
.two:
    play_effect(effect_bullet_2, SOUND_PRIORITY_MEDIUM)
    ret
.three:
    play_effect(effect_bullet_3, SOUND_PRIORITY_MEDIUM)
    ret
.four:
    play_effect(effect_bullet_4, SOUND_PRIORITY_MEDIUM)
    ret

sound_effect_thrust:
    play_effect(effect_thrust, SOUND_PRIORITY_LOW)
    ret

sound_effect_impact:
    play_effect(effect_impact, SOUND_PRIORITY_LOW)
    ret

sound_effect_impact_heavy:
    play_effect(effect_impact_heavy, SOUND_PRIORITY_LOW)
    ret

sound_effect_ship_destroy:
    play_effect(effect_ship_destroy, SOUND_PRIORITY_HIGH)
    ret

sound_effect_shield_damage:
    play_effect(effect_shield_damage, SOUND_PRIORITY_HIGH)
    ret

sound_effect_break:
    call    math_random
    bit     3,a
    jr      nz,.four
    bit     2,a
    jr      nz,.three
    bit     1,a
    jr      nz,.two

.one:
    play_effect(effect_break_1, SOUND_PRIORITY_MEDIUM)
    ret
.two:
    play_effect(effect_break_2, SOUND_PRIORITY_MEDIUM)
    ret
.three:
    play_effect(effect_break_3, SOUND_PRIORITY_MEDIUM)
    ret
.four:
    play_effect(effect_break_4, SOUND_PRIORITY_MEDIUM)
    ret


; General Sound Functions -----------------------------------------------------
; -----------------------------------------------------------------------------
sound_init:

    ; enable sound circuits
    ld      a,%10000000
    ld      [$ff26],a

    ; enable both speakers and set to maximum volume
    ld      a,%1111_1111
    ld      [$ff24],a

    ; output all channels to both speakers
    ld      a,%1111_1111
    ld      [$ff25],a

    call    sound_reset
    ret

sound_reset:
    xor     a
    ld      [soundFrames],a
    ld      [soundFrames + 1],a
    ;ld      [soundFrames + 2],a
    ld      [soundFrames + 3],a
    ld      [soundPriority],a
    ld      [soundPriority + 1],a
    ;ld      [soundPriority + 2],a
    ld      [soundPriority + 3],a
    ret

sound_update:
    ; decrease frame counters
.channel_one:
    ld      a,[soundFrames]
    cp      0
    jr      z,.channel_two
    dec     a
    ld      [soundFrames],a

.channel_two:
    ld      a,[soundFrames + 1]
    cp      0
    jr      z,.channel_four
    dec     a
    ld      [soundFrames + 1],a

.channel_four:
    ld      a,[soundFrames + 3]
    cp      0
    ret     z
    dec     a
    ld      [soundFrames + 3],a
    ret

sound_play:; a = priority, de = data pointer
    push    hl
    push    bc

    ; store priority
    ld      c,a

    ; load channel
    ld      a,[de]
    ld      b,a

    ; check if channel frames are at zero
    ld      hl,soundFrames
    ld      a,l
    add     b
    ld      l,a
    ld      a,[hl]
    cp      0
    jr      z,.play

    ; now check if desired priority is higher or equal than current playing priority
    ld      a,l
    add     4
    ld      l,a
    ld      a,[hl]
    dec     a; >=
    cp      c
    jr      nc,.done; if priority is smaller than the currently playing one don't play the new sound

    ; play sound on channel
.play:

    ; store new priority
    ld      hl,soundPriority
    ld      a,l
    add     b
    ld      l,a
    ld      [hl],c

    ; go back to soundFrames
    ld      a,l
    sub     4
    ld      l,a

    ; store new length
    inc     de
    ld      a,[de]
    ld      [hl],a
    inc     de

    ; select channel
    ld      a,b
    cp      0
    jr      z,.channel_one
    cp      1
    jr      z,.channel_two

.channel_four:
    inc     de; skip unused

    ld      a,[de]
    ld      [$ff20],a
    inc     de

    ld      a,[de]
    ld      [$ff21],a
    inc     de

    ld      a,[de]
    ld      [$ff22],a
    inc     de

    ld      a,[de]
    ld      [$ff23],a
    jr      .done

.channel_two:
    inc     de; skip unused
    ld      a,[de]
    ld      [$ff16],a
    inc     de
    ld      a,[de]
    ld      [$ff17],a
    inc     de
    ld      a,[de]
    ld      [$ff18],a
    inc     de
    ld      a,[de]
    ld      [$ff19],a
    jr      .done

.channel_one:
    ld      a,[de]
    ld      [$ff10],a
    inc     de
    ld      a,[de]
    ld      [$ff11],a
    inc     de
    ld      a,[de]
    ld      [$ff12],a
    inc     de
    ld      a,[de]
    ld      [$ff13],a
    inc     de
    ld      a,[de]
    ld      [$ff14],a

.done:
    pop     bc
    pop     hl
    ret


; Sound Length Calculation
; ------------------------
; Loop
    ; EnvDir = 0 (Dec)
        ; x = (InitVol - 1) * (EnvStepTime * (1 / 64)) seconds
; Timed
    ; (64 - SoundLength) * (1 / 256) seconds
effect_confirm:
    effectOne(4, 0, 7, 1, 2, 7, 0, $F, $05F0, 1)

effect_cancel:
    effectOne(4, 1, 7, 1, 2, 7, 0, $F, $05F0, 1)

effect_select:
    effectOne(2, 0, 7, 0, 2, 7, 0, $F, $0540, 1)

effect_pause:
    effectOne(2, 0, 6, 1, 2, 7, 0, $F, $0200, 1)

effect_unpause:
    effectOne(3, 0, 7, 1, 2, 7, 0, $F, $04E0, 1)

effect_bullet_1:
    effectOne(4, 1, 3, $10, 2, 1, 0, $C, $0724, 1)

effect_bullet_2:
    effectOne(4, 1, 3, $10, 2, 1, 0, $C, $0728, 1)

effect_bullet_3:
    effectOne(4, 1, 3, $10, 2, 1, 0, $C, $0730, 1)

effect_bullet_4:
    effectOne(4, 1, 3, $10, 2, 1, 0, $C, $0734, 1)

effect_thrust:
    effectFour($00, 3, 0, $8, 4, 0, 3, 0)

effect_impact:
    effectTwo($34, 2, 1, 0, $D, $0310, 1)

effect_impact_heavy:
    effectTwo($3B, 2, 1, 0, $8, $0700, 1)

effect_ship_destroy:
    effectFour($00, 7, 0, $F, 4, 0, 6, 0)

effect_shield_damage:
    effectFour($00, 3, 0, $F, 3, 1, 5, 0)

effect_break_1:
    effectFour($00, 2, 0, $F, 4, 0, 6, 0)

effect_break_2:
    effectFour($00, 2, 0, $F, 5, 0, 6, 0)

effect_break_3:
    effectFour($00, 2, 0, $F, 4, 1, 7, 0)

effect_break_4:
    effectFour($00, 2, 0, $F, 5, 1, 7, 0)

MACRO play_effect(@pointer, @priority)
    push    de
    ld      a,@priority
    ld      de,@pointer
    call    sound_play
    pop     de
ENDMACRO

MACRO effectOne(@sweepShift, @sweepDir, @sweepTime, @length, @dutyCycle, @envSweep, @envDir, @envInVol, @frequency, @timed)
    ; channel
    DB      0
    ; length in frames
    DB      (@timed == 1 && CEIL((64 - @length) * (1 / 256) / (1 / 60))) + (@timed == 0 && CEIL((@envInVol - 1) * (@envSweep * (1 / 64) / (1 / 60))))
    DB      (@sweepTime << 4) | (@sweepDir << 3) | @sweepShift
    DB      (@dutyCycle << 6) | @length

    DB      (@envInVol << 4) | (@envDir << 3) | @envSweep
    DB      @frequency & $ff
    DB      (@frequency >> 8) | (@timed << 6) | $80
    ; padding
    DB      0
ENDMACRO

MACRO effectTwo(@length, @dutyCycle, @envSweep, @envDir, @envInVol, @frequency, @timed)
    ; channel
    DB      1
    ; length in frames
    DB      (@timed == 1 && CEIL((64 - @length) * (1 / 256) / (1 / 60))) + (@timed == 0 && CEIL((@envInVol - 1) * (@envSweep * (1 / 64) / (1 / 60))))
    ; unused
    DB      0
    DB      (@dutyCycle << 6) | @length

    DB      (@envInVol << 4) | (@envDir << 3) | @envSweep
    DB      @frequency & $ff
    DB      ((@frequency >> 8) & %0000_0111) | (@timed << 6) | $80
    ; padding
    DB      0
ENDMACRO

MACRO effectFour(@length, @envSweep, @envDir, @envInVol, @ratio, @step, @shift, @timed)
    ; channel
    DB      3
    ; length in frames
    DB      (@timed == 1 && CEIL((64 - @length) * (1 / 256) / (1 / 60))) + (@timed == 0 && CEIL((@envInVol - 1) * (@envSweep * (1 / 64) / (1 / 60))))
    ; unused
    DB      0
    DB      @length

    DB      (@envInVol << 4) | (@envDir << 3) | @envSweep
    DB      (@shift << 4) | @step << 3 | @ratio
    DB      (@timed << 6) | $80
    ; padding
    DB      0
ENDMACRO

