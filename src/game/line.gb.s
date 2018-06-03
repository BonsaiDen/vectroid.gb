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

    ; calculate modulo for column
    ld      a,b
    and     %0000_0111
    ld      l,a
    ld      h,bit_table >> 8
    ld      a,[hl]
    ld      [lineMask],a

    ; load low byte of tile index table for the sprite
    ld      a,[polygonOffset + 1]
    ld      l,a

    ; y tile grid = py / 8
    ld      h,c
    srl     h
    srl     h
    srl     h

    ; calculate tile index to draw on = x + y * 4
    ; x tile grid = px / 8
    ld      a,b
    rrca    ; / 2
    rrca    ; / 4
    rrca    ; / 8
    and     %0001_1111; mask of wrapped bits

    ; + y * 4
    add     h
    add     h
    add     h
    add     h

    ; multiply by 2 and combine with base pointer address
    add     a
    add     l
    ld      l,a; load into low byte

    ; load high byte
    ld      a,[polygonOffset]
    adc     0; TODO still required?
    ld      h,a

    ; load vram tile address from index table of the sprite
    ld      a,[hli]
    ld      h,[hl]
    ld      l,a

    ; we now have the start of the tile in vram
    ; so we need to add the line offset
    ld      a,c
    and     %0000_0111
    add     a; x2 - since we only use 2 colors we can skip the "high bits" of each line
    add     l

    ; hl is now the final vram address of the line within the tile
    ld      l,a

    ; restore pixel mask
    ld      a,[lineMask]

    ; combine with old pixel row
    or      [hl]

    ; store combined row pixels back into vram
    ld      [hl],a

    pop     hl
ENDMACRO

