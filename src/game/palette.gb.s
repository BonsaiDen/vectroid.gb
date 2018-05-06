load_palette_bg:
    ld      hl,_background_palettes
    ld      de,$ff68
    call    _load_palette
    ret

load_palette_sp:
    ld      hl,_sprite_palettes
    ld      de,$ff6A
    call    _load_palette
    ret

_load_palette:; de = palette memory, hl = palette data

    ; start transfer
    ld      a,%10000000
    ld      [de],a
    inc     de

    ; load entry count
    ld      a,[hli]

    ; loop counter
    ld      b,a
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
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(128, 128, 128)
    GBC_COLOR(192, 192, 192)
    GBC_COLOR(255, 255, 255)

_sprite_palettes:
    DB      5

    ; Asteroids
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(145, 97, 50)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Ship
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(255, 0, 0)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Unused
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 255, 255)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Unused
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 255, 0)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)

    ; Unused
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 255)
    GBC_COLOR(0, 0, 0)
    GBC_COLOR(0, 0, 0)


; Helpers ---------------------------------------------------------------------
MACRO GBC_COLOR(@r, @g, @b)
    DB  (((FLOOR(@b / 8) & 31) << 10) | ((FLOOR(@g / 8) & 31) << 5) | (FLOOR(@r / 8) & 31)) & $ff
    DB  (((FLOOR(@b / 8) & 31) << 10) | ((FLOOR(@g / 8) & 31) << 5) | (FLOOR(@r / 8) & 31)) >> 8
ENDMACRO

