SECTION "PaletteLogic",ROM0
palette_init:
    ldxa    [paletteLightness],0
    call    palette_update
    ret

palette_update:; a = dark/light
    ld      b,a

    push    bc

    ld      c,PALETTE_BACKGROUND_COUNT
    ld      hl,_background_palettes
    ld      de,paletteBuffer
    call    _update_palette
    pop     bc

    ld      c,PALETTE_SPRITE_COUNT
    ld      de,paletteBuffer + PALETTE_BACKGROUND_COUNT * 4 * 2
    ld      hl,_sprite_palettes
    call    _update_palette

    ld      a,1
    ld      [paletteUpdated],a
    ret

palette_copy:
    ; only copy if we're still in vblank
    ld      a,[rLY]
    cp      90
    ret     c

    ; background setup
    ld      b,PALETTE_BACKGROUND_COUNT * 4
    ld      hl,paletteBuffer
    ld      de,$FF68

    ; background transfer
    ld      a,%10000000
    ld      [de],a
    inc     e
.loop_background:
    ld      a,[hli]
    ld      [de],a
    ld      a,[hli]
    ld      [de],a

    dec     b
    jr      nz,.loop_background

    ; sprite setup
    ld      b,PALETTE_SPRITE_COUNT * 4
    ld      hl,paletteBuffer + PALETTE_BACKGROUND_COUNT * 4 * 2
    ld      de,$FF6A

    ; sprite transfer
    ld      a,%10000000
    ld      [de],a
    inc     e
.loop_foreground:
    ld      a,[hli]
    ld      [de],a
    ld      a,[hli]
    ld      [de],a

    dec     b
    jr      nz,.loop_foreground

    ; reset update flag
    xor     a
    ld      [paletteUpdated],a
    ret

_update_palette:; b = dark/light, c = entry count, de = palette buffer, hl = palette data
    ; check if light mode
    ld      a,b
    cp      1
    jr      nz,.set

    ; light mode (offset by table length * 8)
    ld      a,c
    add     a
    add     a
    add     a
    addw    hl,a

.set:
    ; loop counter
    ld      b,c
.next_palette_entry:

    ; 2 bytes per color and 4 colors per palette entry
    ld      c,4
.next_color_byte:
    push    bc
    push    de

    ld      a,[paletteLightness]
    ld      d,a

    ; green byte
    ld      a,[hli]
    call    _mix_32
    rrc     a
    rrc     a
    rrc     a
    ld      e,a

    ; blue byte
    ld      a,[hli]
    call    _mix_32
    rlc     a
    rlc     a
    ld      b,a

    ; combine with green
    ld      a,e
    and     %0000_0011
    or      b
    ld      b,a

    ; red byte
    ld      a,[hli]
    call    _mix_32
    ld      c,a

    ; combine with green
    ld      a,e
    and     %1110_0000
    or      c
    ld      c,a

    ; load into palette memory
    pop     de

    ld      a,c
    ld      [de],a
    inc     de

    ld      a,b
    ld      [de],a
    inc     de

    pop     bc
    dec     c
    jr      nz,.next_color_byte

    dec     b
    jr      nz,.next_palette_entry
    ret

_mix_32:; a = value, d = addition
    bit     7,d
    jr      nz,.negative
    add     d
    cp      32
    ret     c
    ; limit to 31
    ld      a,31
    ret

.negative:
    add     d
    cp      32
    ret     c
    ; limit to 0
    xor     a
    ret

_background_palettes:
    ; Dark
    GBC_COLOR(0, 0, 16)
    GBC_COLOR(128, 128, 128)
    GBC_COLOR(192, 192, 192)
    GBC_COLOR(255, 255, 255)

    ; Light
    GBC_COLOR(128, 128, 128)
    GBC_COLOR(192, 192, 192)
    GBC_COLOR(128, 128, 128)
    GBC_COLOR(0, 0, 0)

_sprite_palettes:

    ; Asteroids (Dark)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(145, 97, 50)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Ship (Dark)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 0, 0)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 0, 0)

    ; Bullet (Dark)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 255, 0)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Thrust A (Dark)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 128, 128)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Thrust B (Dark)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 64, 0)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Effect Placeholer (Dark)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 255, 255)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Asteroids (Light)
._sprite_light:
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(106, 71, 36)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Ship (Light)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(192, 0, 0)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(192, 0, 0)

    ; Bullet (Light)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(220, 64, 0)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Thrust A (Light)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 128, 128)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Thrust B (Light)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 64, 0)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Effect Placeholer (Light)
    GBC_COLOR(255, 255, 255)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 255, 255)
    GBC_COLOR(255, 255, 255)


; Helpers ---------------------------------------------------------------------
MACRO GBC_COLOR(@r, @g, @b)
    DB (FLOOR(@g / 8) & 31)
    DB (FLOOR(@b / 8) & 31)
    DB (FLOOR(@r / 8) & 31)
ENDMACRO

