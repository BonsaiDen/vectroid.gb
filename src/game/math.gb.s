; Constants -------------------------------------------------------------------
SQRT_MAX_DISTANCE   EQU 32


SECTION "Math",ROM0
angle_vector_16_zero:; d = angle (column index), e = length -> bc = x/y
    ; guard against underflow
    xor     a
    cp      e
    jr      z,.zero

    ld      b,0
    jr      angle_offset

.zero:
    ld      bc,0
    ret

angle_vector_16:; d = angle (column index), e = length -> bc = x/y
    ld      b,0
    jr      angle_offset

angle_offset:; d = angle (column index), b = offset, e = length -> bc = x/y
    ; TODO optimize
    ; multiply by 64 to get length offset into table
    ld      h,0
    dec     e
    ld      l,e
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl
    ld      e,l

    ld      a,h
    add     angle_table >> 8
    ld      h,a

    call    _sine_lookup
    ld      c,a
    ld      l,e
    call    _cosine_lookup
    ld      b,a
    ret

_cosine_lookup:; h = row, d = angle (column index), b = offset, e = length -> a = value
    ld      a,64
    add     d
    ld      d,a

_sine_lookup:; h = row, d = angle (column index), b = offset, e = length -> a = value
    ld      a,d
    cp      192
    jr      nc,_quadrant_3
    cp      128
    jr      nc,_quadrant_2
    cp      64
    jr      nc,_quadrant_1

; 0 - 63
_quadrant_0:
    ld      a,l
    add     d
    ld      l,a
    ; positive value
    ld      a,b
    add     [hl]
    ret

; 64 - 127
_quadrant_1:
    ; invert angle direction
    ld      a,63
    sub     d
    add     64
    add     l
    ld      l,a

    ; positive value
    ld      a,[hl]
    add     b
    ret

; 128 - 191
_quadrant_2:
    ld      a,d
    sub     128
    add     l
    ld      l,a

    ; negative value
    ld      a,[hl]
    cpl
    inc     a
    add     b
    ret

; 192 - 255
_quadrant_3:
    ; invert angle direction
    ld      a,63
    sub     d
    add     192
    add     l
    ld      l,a

    ; negative value
    ld      a,[hl]
    cpl
    inc     a
    add     b
    ret


atan_2: ; bc = x/y -> d = angle 0-256 (0 - PI * 2)
    push    bc

    ; convert to positive length first
    ld      a,b
    cp      128
    jr      c,.positive_x
    cpl
    inc     a
    ld      b,a

.positive_x:
    ld      a,c
    cp      128
    jr      c,.positive_y
    cpl
    inc     a
    ld      c,a

.positive_y:
    ; limit x
    ld      a,b
    cp      31
    jr      c,.x_small
    ld      a,31
    ld      b,a
.x_small:

    ; limit y
    ld      a,c
    cp      31
    jr      c,.y_small
    ld      a,31
    ld      c,a
.y_small:

    ; y * 32
    ld      h,0
    ld      l,c
    add     hl,hl; 2
    add     hl,hl; 4
    add     hl,hl; 8
    add     hl,hl; 16
    add     hl,hl; 32

    ; + x
    addw    hl,b
    ld      a,atan2_table >> 8
    add     h
    ld      h,a

    ; load quadrant value
    ld      a,[hl]

    ; store quadrant angle into d
    ld      d,a

    ; restore original signed x/y
    pop     bc

    ; check if above the horizontal line
    ld      a,c
    cp      128
    jr      c,.quadrant_one_or_two

; 128 - 255
.quadrant_three_or_four:
    ld      a,b
    cp      128
    jr      c,.quadrant_four

; 128 - 192
.quadrant_three:
    ld      a,128
    add     d
    ret

; 192 - 255
.quadrant_four:
    ld      a,0
    sub     d
    ret

; 0 - 128
.quadrant_one_or_two:
    ld      a,b
    cp      128
    jr      c,.quadrant_one

    ; 64-128
.quadrant_two:
    ld      a,128
    sub     d
    ret

    ; 0-64
.quadrant_one:
    ld      a,d
    ret

sqrt_length:

    ; convert to positive length first
    ld      a,b
    cp      128
    jr      c,.positive_x
    cpl
    inc     a
    ld      b,a

.positive_x:
    ld      a,c
    cp      128
    jr      c,.positive_y
    cpl
    inc     a
    ld      c,a

.positive_y:
    ; limit x
    ld      a,b
    cp      SQRT_MAX_DISTANCE - 1
    jr      c,.x_small
    ; abort
    ld      a,SQRT_MAX_DISTANCE
    ret
.x_small:

    ; limit y
    ld      a,c
    cp      SQRT_MAX_DISTANCE - 1
    jr      c,.y_small
    ; abort
    ld      a,SQRT_MAX_DISTANCE
    ret
.y_small:

    ; lookup remainder length
    ; x * 32
    ld      h,0
    ld      l,b
    add     hl,hl; 2
    add     hl,hl; 4
    add     hl,hl; 8
    add     hl,hl; 16
    add     hl,hl; 32

    ; + y
    addw    hl,c
    ld      a,sqrt_table >> 8
    add     h
    ld      h,a

    ; load distance value
    ld      a,[hl]
    ret

