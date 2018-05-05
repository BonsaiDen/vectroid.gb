SECTION "Math",ROM0
angle_offset:; d = angle (column index), e = length -> bc = x/y

    dec     e; table starts at 1
    ld      l,d; index into column

    ; sine
    ld      h,e; index into row
    ld      bc,angle_table; add base
    add     hl,bc; pointer
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


atan2: ; bc = y/x -> a angle 0-256 (0 - PI * 2)
    push   hl
    ld     hl,atan2_table

    ; (x + 8) * 16
    ld     a,c
    add    8

    add    a
    add    a
    add    a
    add    a

    ; + (y + 8)
    add    b
    add    8
    ld     l,a
    ld     a,[hl]
    pop    hl
    ret


length: ; bc = dy/dx -> a = sqrt(dx * dx + dy * dy)
    ; TODO
    ret

