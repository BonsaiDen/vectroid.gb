; Helpers ---------------------------------------------------------------------
MACRO GBC_COLOR(@r, @g, @b)
    DB  (((FLOOR(@b / 8) & 31) << 10) | ((FLOOR(@g / 8) & 31) << 5) | (FLOOR(@r / 8) & 31)) & $ff
    DB  (((FLOOR(@b / 8) & 31) << 10) | ((FLOOR(@g / 8) & 31) << 5) | (FLOOR(@r / 8) & 31)) >> 8
ENDMACRO

_gbc_palette:
    GBC_COLOR(255, 255, 255)
    GBC_COLOR(168, 240, 128)
    GBC_COLOR(72, 152, 120)
    GBC_COLOR(0, 0, 0)


screen_update_palette_color:

    ; set background palette
    ld      de,$ff69
    ld      a,%10000000
    ld      [$ff68],a
    ld      a,[corePaletteBG]
    call    _screen_update_color_palette_entry

    ; set sprite palettes
    ld      de,$ff6B
    ld      a,%10000000
    ld      [$ff6A],a

    ld      a,[corePaletteSprite0]
    call    _screen_update_color_palette_entry

    ld      a,[corePaletteSprite1]
    call    _screen_update_color_palette_entry

    ret


_screen_update_color_palette_entry:; a = color, de = palette target register

    ; store dmg palette value
    ld      c,a

    ; setup loop counter
    ld      b,4
.next:

    ; grab lower two bytes of c
    ld      a,c
    and     %00000011

    ; shift next two bytes in
    srl     c
    srl     c

    ; get pointer into color palette
    ld      hl,_gbc_palette

    ; 16 bit addition of a to hl
    add     a
    add     a,l
    ld      l,a
    adc     a,h
    sub     l
    ld      h,a

    ; wait for vblank
    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4          ; ----+

    ; load color byte and set palette entry
    ld      a,[hli]
    ld      [de],a

    ; wait for vblank
    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4          ; ----+

    ; load color byte and set palette entry
    ld      a,[hl]
    ld      [de],a

    dec     b
    jr      nz,.next
    ret

