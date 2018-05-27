SECTION "ScreenLogic",ROM0

screen_init:
    ld      a,$FF
    ld      [screenFlashPointer],a
    ld      [screenFlashPointer + 1],a
    call    screen_reset
    ret

screen_reset:
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

screen_flash_out:
    ld      hl,_screen_flash_out
    ldxa    [screenFlashPointer],h
    ldxa    [screenFlashPointer + 1],l
    ret

screen_flash_in:
    ld      hl,_screen_flash_in
    ldxa    [screenFlashPointer],h
    ldxa    [screenFlashPointer + 1],l
    ret

screen_flash_explosion_tiny:
    ; ignore if already flashing
    ld      a,[screenFlashPointer]
    cp      $FF
    ret     nz

    ld      hl,_screen_flash_explosion_tiny
    ldxa    [screenFlashPointer],h
    ldxa    [screenFlashPointer + 1],l
    ret

screen_flash_explosion_ship:
    ld      hl,_screen_flash_explosion_ship
    ldxa    [screenFlashPointer],h
    ldxa    [screenFlashPointer + 1],l
    ret

_screen_flash_explosion_ship:
    DB      8,15,24,32,32,32,32,32,32,32,32
    DB      31,27,24,22,19,17,15,13,11,9,7,5,3,1,0
    DB      $FF

_screen_flash_explosion_tiny:
    DB      2,5,9
    DB      5,2,0
    DB      $FF

_screen_flash_out:
    DB      0,-4,-10,-14,-22,-32
    DB      $FF

_screen_flash_in:
    DB      -32,-22,-14,-10,-4,0
    DB      $FF

screen_flash_update:

    ; only update every other frame
    ld      a,[coreLoopCounter16]
    and     %0000_0001
    ret     z

    ; check for active flash point
    ld      a,[screenFlashPointer]
    cp      $FF
    ret     z

    ; load pointer
    ld      h,a
    ld      a,[screenFlashPointer + 1]
    ld      l,a

    ; load data value
    ld      a,[hl]
    cp      $FF
    jr      z,.done

    ld      [paletteLightness],a

    ; update pointer
    inc     hl
    ldxa    [screenFlashPointer],h
    ldxa    [screenFlashPointer + 1],l

    call    palette_update
    ret

.done:
    ld      a,$FF
    ld      [screenFlashPointer],a
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

