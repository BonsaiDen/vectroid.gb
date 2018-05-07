SECTION "UILogic",ROM0

ui_number_right_aligned:; a = number, bc = x/y, d = fill width, e = fill tile index
    ld      l,a

.next_digit:
    push    de

    ; get mod 10
    ld      a,l
    call    a_mod_10
    call    _digit

    ; subtract remainder
    ld      a,l
    sub     d
    inc     a
    ld      l,a
    cp      0
    jr      z,.skip

    ; divide by 10
    ld      e,l
    call    e_div_10
    ld      l,h
    ld      a,l

.skip:
    pop     de
    dec     d; reduce remaining width
    ret     z; exit if completely filled

    dec     b; shift next draw to the right

    ; exit if no more digit is required
    cp      0
    jr      nz,.next_digit

    ; fill remaining digites
.fill:
    ld      a,e
    push    de
    call    _digit
    pop     de
    dec     b; shift next draw to the right
    dec     d; reduce remaining width
    jr      nz,.fill
    ret

_digit: ; a = digit, bc=x/y
    push    hl
    inc     a
    ld      d,a

    ; draw digit
    ld      h,0
    ld      l,c
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl

    ld      a,h
    add     $98
    ld      h,a

    ld      a,l
    add     b
    ld      l,a

    ld      [hl],d
    pop     hl
    ret

a_mod_10:; e % 10 -> h
    ld     de,$05A0

.loop:
    sub    e
    jr     nc,@+3
    add    e
    srl    e
    dec    d
    jr     nz,.loop
    ret

e_div_10:; e / 10 -> h
     ld d,0
     ld h,d
     ld l,e
     add hl,hl
     add hl,de
     add hl,hl
     add hl,hl
     add hl,de
     add hl,hl
     ret

