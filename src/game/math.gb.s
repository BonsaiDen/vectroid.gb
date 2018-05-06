SECTION "Math",ROM0
angle_offset:; d = angle (column index), e = length -> bc = x/y
    ; offset with polygon drawing in mind
    dec     e; table starts at 1
    ld      l,d; index into column

    ; sine
    ld      a,angle_table >> 8
    add     e; index into row
    ld      h,a
    ld      a,[polygonHalfSize]
    add     [hl]; lookup sin() * length
    ld      c,a

    ; cosine
    ld      a,l; shift column
    add     64; offset by PI * 0.5
    ld      l,a
    ld      a,[polygonHalfSize]
    add     [hl]; lookup sin() * length
    ld      b,a
    ret

angle_vector_256:; d = angle (column index), e = length -> bc = x/y

    ; divide e by 16
    push    de
    div     e,16

    ; load last entry
    ld      h,(angle_table + 256 * 15) >> 8
    ld      l,d; index into column

    ; load maximum sine
    ld      c,[hl]

    ; load maximum cosine
    ld      a,l
    add     64; offset by PI * 0.5
    ld      l,a
    ld      b,[hl]

    ; multiply c by e
    xor     a
    cp      c
    jr      z,.c_done

    ld      d,e
.mul_c:
    add     c
    dec     d
    jr      nz,.mul_c

.c_done:
    ld      c,a

    ; multiply b by e
    xor     a
    cp      b
    jr      z,.b_done
    ld      d,e
.mul_b:
    add     b
    dec     d
    jr      nz,.mul_b

.b_done:
    ld      b,a

    pop     de

    ; bc now contains the bigger part of the vector, we now need to calculate the remainder and add it
    push    bc; store bigger part
    ld      a,e
    and     %0000_1111
    ld      e,a
    inc     a
    call    angle_vector_16
    pop     hl; restore previous vector into hl

    ld      a,h
    add     b
    ld      b,a

    ld      a,l
    add     c
    ld      c,a

    ret

angle_vector_16:; d = angle (column index), e = length -> bc = x/y

    ld      l,d; index into column
    dec     e; table starts at 1

    ; sine
    ld      h,e; index into row
    ld      bc,angle_table; add base
    add     hl,bc; pointer
    ld      c,[hl]; lookup sin() * length % 16

    ; cosine
    ld      a,l; shift column
    add     64; offset by PI * 0.5
    ld      l,a
    ld      b,[hl]; lookup sin() * length
    ret

; TODO increase to 32x32
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
    cp      15
    jr      c,.x_small
    ld      a,15
    ld      b,a
.x_small:

    ; limit y
    ld      a,c
    cp      15
    jr      c,.y_small
    ld      a,15
    ld      c,a
.y_small:

    ; lookup quadrant angle
    ld      hl,atan2_table

    ; y * 16
    ld      a,c
    add     a
    add     a
    add     a
    add     a

    ; + x
    add     b
    ld      l,a
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

; TODO increase to 32x32
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
    cp      15
    jr      c,.x_small
    ; abort
    ld      a,16
    ret
.x_small:

    ; limit y
    ld      a,c
    cp      15
    jr      c,.y_small
    ; abort
    ld      a,16
    ret
.y_small:

    ; lookup remainder length
    ; x * 16
    ld      a,b
    add     a
    add     a
    add     a
    add     a

    ; + y
    add     c
    ld      h,sqrt_table >> 8
    ld      l,a
    ld      a,[hl]
    ret

