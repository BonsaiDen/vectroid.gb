SECTION "ScreenLogic",ROM0

screen_init:
    xor     a
    ld      [polygonOX],a
    ld      [polygonOY],a
    ld      [screenShakeTicks],a
    ld      [screenShakeStrength],a
    ret

screen_shake:; a = duration in seconds / 8, b = strength
    ld      [screenShakeTicks],a
    ld      a,b
    ld      [screenShakeStrength],a
    ret

screen_shake_small:
    ld      a,6
    ld      b,1
    call    screen_shake
    ret

screen_shake_medium:
    ld      a,7
    ld      b,1
    call    screen_shake
    ret

screen_shake_large:
    ld      a,7
    ld      b,3
    call    screen_shake
    ret

screen_shake_giant:
    ld      a,9
    ld      b,3
    call    screen_shake
    ret

screen_shake_ship:
    ld      a,20
    ld      b,3
    call    screen_shake
    ret

screen_flash_timer:
    ;ld      a,[paletteLightness]
    ;add     3
    ;and     %0001_1111
    ;ld      [paletteLightness],a
    ;call    palette_update
    ret

screen_shake_timer:
    ld      a,[screenShakeTicks]
    cp      0
    ret     z

    ; decrease tick
    dec     a
    ld      [screenShakeTicks],a
    cp      0
    jr      z,.reset

    call    _random_screen_offset
    ld      [polygonOX],a

    call    _random_screen_offset
    ld      [polygonOY],a
    ret

.reset:
    ld      [polygonOX],a
    ld      [polygonOY],a
    ret

_random_screen_offset:
    ld      a,[screenShakeStrength]
    ld      b,a
    call    math_random
    bit     5,a
    jr      z,.negative

.positive:
    and     b
    ret

.negative:
    and     b
    cpl
    inc     a
    ret

