; VBlank Handler --------------------------------------------------------------
core_vblank_handler:

    di
    push    af
    push    bc
    push    de
    push    hl

    call    game_draw_vram

    ; just copy sprites in case no room update was required
    call    $ff80

    ; Set vblank flag, this will cause the core loop to run the game loop once
.done:
    ld      a,1
    ld      [coreVBlankDone],a

    pop     hl
    pop     de
    pop     bc
    pop     af

    reti

