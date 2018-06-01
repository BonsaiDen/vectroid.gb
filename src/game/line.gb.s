SECTION "LineRender",ROM0

; Line Plotting ---------------------------------------------------------------
line_two:
    DELTA(b, d, h, lineXI)
    DELTA(c, e, l, lineYI)

    ; skip lines with length 0
    ld      a,h
    add     l; sets zero flag
    ret     z

    ; dy <= dx
    ld      a,l
    cp      h
    jr      nc,.plot_line_y

.plot_line_x:
    sla     l
    PLOT_LINE(b, d, c, h, l, e, lineXI, lineYI)
    ret

.plot_line_y:
    sla     h
    PLOT_LINE(c, e, b, l, h, d, lineYI, lineXI)
    ret

; Macros ----------------------------------------------------------------------
; -----------------------------------------------------------------------------
MACRO DELTA(@start, @end, @delta, @inc)
delta:
    ; dy = ey - sy
    ld      a,@end
    sub     @start
    jr      nc,.positive; dy < 0

    ; dy = -dy
    cpl
    inc     a
    ld      @delta,a; dy
    ld      a,-1
    jr      .negative

.positive:
    ld      @delta,a; dy
    ld      a,1

.negative:
    ld      [@inc],a

ENDMACRO


MACRO PLOT_LINE(@pos, @end, @second, @delta_one, @delta_two, @error, @i_one, @i_two)
plot_line:

    ; offset dy for fast / signed error comparison
    ld      a,128
    ld      @error,a; init error variable to 0 (+offset)
    add     @delta_one
    ld      @delta_one,a

.loop:
    PLOT_PIXEL()

    ; sy += yi
    ld      a,[@i_one]
    add     @pos
    ld      @pos,a

    ; error += dx * 2
    ld      a,@error
    add     @delta_two
    ld      @error,a

    ; error > dx + 128
    dec     a
    cp      @delta_one
    jr      c,.error_too_small

    ; sx += xi
.increase_second:
    ld      a,[@i_two]
    add     @second
    ld      @second,a

    ; error -= tdy * 2
    ld      a,@error
    sub     @delta_one
    sub     @delta_one
    add     1; same effect as adding 128 twice to correct for the dx offset
    ld      @error,a

.error_too_small:
    ; sy == ey
    ld      a,@pos
    cp      @end
    jr      nz,.loop

ENDMACRO

MACRO PLOT_PIXEL()
    push    hl
    push    bc

    ; copy px/py
    ld      l,b
    ld      h,c

    ; calculate x tile grid
    div     l,8

    ; calculate tile index
    ld      a,[polygonSize]
    add     tile_index_table & $ff

    ; += y / 8 * 4
    div     c,8
    add     c
    add     c
    add     c
    add     c
    add     l
    ld      l,a

    ; add relative y offset
    ld      a,h
    and     %0000_0111; we only set every other byte since we're only using 2 colors
    add     a; x2

    ; add base tile index
    ld      h,tile_index_table >> 8
    add     [hl]
    ld      c,a

    ; add polygon offset
    ld      a,[polygonOffset + 1]
    add     c
    ld      l,a

    ld      a,[polygonOffset]
    adc     0
    ld      h,a

    ; calculate x modulo for column
    ld      a,b
    and     %0000_0111

    ; load pixel pattern mask for row/column
    ; TODO move to HRAM and use ld a,[c] ?
    ld      b,bit_table >> 8
    ld      c,a
    ld      a,[bc]

    ; combine with old pixel row
    or      [hl]

    ; store combined row pixels back
    ld      [hl],a

    ; restore px/py
    pop     bc
    pop     hl
ENDMACRO

