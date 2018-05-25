SECTION "UILogic",ROM0

ui_draw:
    ld      a,[forceUIUpdate]
    cp      1
    jr      z,.update

    ; only draw ui every 15 frames
    ld      a,[coreLoopCounter16]
    and     %0000_1111
    ret     nz

.update:
    xor     a
    ld      [forceUIUpdate],a

    ; wait for hardware DMA to complete
    ld      a,[rHDMA5]
    and     %1000_0000
    ret     z

    ; source
    ld      a,uiOffscreenBuffer >> 8
    ld      [rHDMA1],a
    xor     a
    ld      [rHDMA2],a

    ; target
    ld      a,$98
    ld      [rHDMA3],a
    xor     a
    ld      [rHDMA4],a
    ld      a,%0010_0011; 35 + 1 * 16 = 576
    ld      [rHDMA5],a
    ret

ui_text:; bc = x/y, hl = data pointer
.next:
    ld      a,[hl]
    cp      0
    ret     z

    push    hl
    ld      e,a

    ; draw character
    ld      h,0
    ld      l,c
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl

    ld      a,h
    add     uiOffscreenBuffer >> 8
    ld      h,a

    ld      a,l
    add     b
    ld      l,a

    ld      d,text_table >> 8
    ld      a,text_table & $ff
    add     e
    ld      e,a
    ld      a,[de]

    ld      [hl],a
    pop     hl
    inc     hl
    inc     b
    jr      .next

ui_character:; bc = x/y, d = length, e = character
.next:

    ; draw character
    ld      h,0
    ld      l,c
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl

    ld      a,h
    add     uiOffscreenBuffer >> 8
    ld      h,a

    ld      a,l
    add     b
    ld      l,a

    ld      a,e
    ld      [hl],a
    inc     b

    dec     d
    jr      nz,.next
    ret


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
    add     uiOffscreenBuffer >> 8
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

