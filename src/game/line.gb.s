SECTION "LineRender",ROM0

; Line Plotting ---------------------------------------------------------------
line_two:
    DELTA(b, d, h, lineXI)
    DELTA(c, e, l, lineYI)

    ; skip lines with length 0
    ld      a,h
    add     l
    cp      0
    ret     z

    ; dy <= dx
    ld      a,l
    cp      h
    jr      nc,.plot_line_y

.plot_line_x:
    PLOT_LINE(b, d, c, h, l, e, lineXI, lineYI)
    ret

.plot_line_y:
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
    add     $ff
    cpl
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

    ; hl = dx:dy, bc = sx:sy, de = error:ey
    ld      @error,128

    ; offset dy for fast, signed error comparison
    ld      a,@delta_one
    add     128
    ld      @delta_one,a

.loop:
    PLOT_PIXEL()

    ; sy += yi
    ld      a,[@i_one]
    add     @pos
    ld      @pos,a

    ; error += dx + dx
    ld      a,@error
    add     @delta_two
    add     @delta_two
    ld      @error,a

    ; error > dx + 128
    dec     a
    cp      @delta_one
    jr      c,.small_error
    ;jr      z,.small_error_y

    ; sx += xi
    ld      a,[@i_two]
    add     @second
    ld      @second,a

    ; error -= tdy
    ; error -= tdy + tdy
    ld      a,@error
    sub     @delta_one
    sub     @delta_one
    add     1; same effect as adding 128 twice to correct for the dx offset
    ld      @error,a

.small_error:
    ; sy == ey
    ld      a,@pos
    cp      @end
    jr      nz,.loop

ENDMACRO

MACRO PLOT_PIXEL()
    push    hl
    push    de
    push    bc

    ; copy original pixel y position
    ld      e,c

    ; calculate x tile grid
    div     b,8

    ; calculate y tile grid = y / 8 * 4
    div     c,8
    mul     c,4

    ; calculate tile index
    ld      a,[polygonSize]
    add     tile_index_table & $ff
    add     b
    add     c
    ld      h,tile_index_table >> 8
    ld      l,a

    ; add relative y offset
    ld      a,e
    and     %0000_0111
    add     a; x2
    add     [hl]; add base tile index
    ld      l,a

    ; and add tile base pointer
    ld      h,0
    ldxa    d,[polygonOffset]
    ldxa    e,[polygonOffset + 1]
    add     hl,de

    ; restore px
    pop     bc

    ; load correct bit mask for column
    ld      a,b
    and     %0000_0111
    ld      d,bit_table >> 8
    ld      e,a
    ld      a,[de]; load pixel bit mask

    ld      d,[hl]; read old pixel row
    or      d; combine with bit pixel plot mask
    ld      [hl],a; store combined row pixels back

    pop    de
    pop    hl
ENDMACRO

