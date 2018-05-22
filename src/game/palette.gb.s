load_palette_bg:; a = dark/light
    ld      hl,_background_palettes
    ld      de,$ff68
    call    _load_palette
    ret

load_palette_sp:; a = dark/light
    ld      hl,_sprite_palettes
    ld      de,$ff6A
    call    _load_palette
    ret

_load_palette:; a = dark/light, de = palette memory, hl = palette data
    ; store
    ld      b,a

    ; start transfer
    ld      a,%10000000
    ld      [de],a
    inc     de

    ; load entry count
    ld      a,[hli]
    ld      c,a

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

    ; 2 bytes per color and 4 colors per palette entry, so 8 bytes
    ld      c,8
.next_color_byte:

    ; wait for vblank
    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4          ; ----+

    ; load into palette mem
    ld      a,[hli]
    ld      [de],a
    dec     c
    jr      nz,.next_color_byte

    dec     b
    jr      nz,.next_palette_entry
    ret

_background_palettes:
    DB      1
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
    DB      6

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
    DB  (((FLOOR(@b / 8) & 31) << 10) | ((FLOOR(@g / 8) & 31) << 5) | (FLOOR(@r / 8) & 31)) & $ff
    DB  (((FLOOR(@b / 8) & 31) << 10) | ((FLOOR(@g / 8) & 31) << 5) | (FLOOR(@r / 8) & 31)) >> 8
ENDMACRO

