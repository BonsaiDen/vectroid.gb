SECTION "UILogic",ROM0

ui_draw:
    ld      a,[uiUpdate]
    cp      0
    ret     z

    ; check if dmg
    ld      a,[coreColorEnabled]
    cp      0
    jr      z,ui_draw_dmg

    ; wait for hardware DMA to complete
    ld      a,[rHDMA5]
    and     %1000_0000
    ret     z

    ; check what to copy
    ld      a,[uiClear]
    cp      0
    jr      nz,.clear

    ; wait for render to complete (will set this to 1)
    ld      a,[uiUpdate]
    cp      1
    ret     nz

    xor     a
    ld      [uiUpdate],a

    ld      a,[uiPosition]
    cp      0
    jr      z,.full
    cp      1
    jr      z,.top

.bottom:
    ; source
    ld      a,uiOffscreenBuffer >> 8
    ld      [rHDMA1],a
    xor     a
    ld      [rHDMA2],a

    ; target
    ld      a,$9A
    ld      [rHDMA3],a
    ld      a,$20
    ld      [rHDMA4],a
    ld      a,%0000_0001
    ld      [rHDMA5],a
    ret

.top:
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
    ld      a,%0000_0001
    ld      [rHDMA5],a
    ret

.clear:
    xor     a
    ld      [uiClear],a

.full:
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

ui_draw_dmg:
    ; check what to copy
    ld      a,[uiClear]
    cp      2
    ret     z
    cp      0
    jp      nz,.clear

    ; wait for render to complete (will set this to 2)
    ld      a,[uiUpdate]
    cp      1
    ret     nz

    xor     a
    ld      [uiUpdate],a

    ld      a,[uiPosition]
    cp      0
    jp      z,.full
    cp      1
    jp      z,.top

.bottom:
    ld      hl,uiOffscreenBuffer
    ld      de,$9A20
    COPY_SCREEN_LINE()
    ret

.top:
    ld      hl,uiOffscreenBuffer
    ld      de,$9800
    COPY_SCREEN_LINE()
    ret

.clear:
    ld      a,2
    ld      [uiClear],a

.full:
    ; copy 18 lines
    ld      b,18
    ld      hl,uiOffscreenBuffer
    ld      de,$9800

.loop:
    COPY_SCREEN_LINE()
    addw    hl,12
    addw    de,12
    dec     b
    jr      nz,.loop

    xor     a
    ld      [uiClear],a
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


MACRO COPY_SCREEN_LINE()
_copy_screen_line:
    ld      c,10
.loop:
    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4

    ld      a,[hli]
    ld      [de],a
    inc     e

    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4
    ld      a,[hli]
    ld      [de],a
    inc     e

    dec     c
    jr      nz,.loop
ENDMACRO
