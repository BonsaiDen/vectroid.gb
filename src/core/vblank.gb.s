; VBlank Handler --------------------------------------------------------------
core_vblank_handler:

    di
    push    af
    push    bc
    push    de
    push    hl

    call    $ff80
    call    game_draw_vram

    ; Set vblank flag, this will cause the core loop to run the game loop once
.done:
    ld      a,1
    ld      [coreVBlankDone],a

    pop     hl
    pop     de
    pop     bc
    pop     af

    reti

