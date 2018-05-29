SECTION "MenuLogic",ROM0

menu_init:
    xor     a
    ld      [menuDebug],a
    ld      [menuButton],a
    call    clear_bg

    ld      hl,DataUITiles
    ld      de,$8000
    call    core_decode_eom
    ret

menu_play_init:
    ld      a,[menuDebug]
    cp      0
    jr      z,.game

.debug:

    call    clear_bg
    ld      bc,$0000
    ld      hl,text_debug_ui_one
    call    ui_text

    ld      bc,$0001
    ld      hl,text_debug_ui_two
    call    ui_text

    ld      bc,$0011
    ld      hl,text_debug_ui_three
    call    ui_text
    jr      .done

.game:
    call    clear_bg

.done:
    ldxa    [rSCX],0
    ld      a,1
    ld      [forceUIUpdate],a
    call    menu_play_render
    ret

menu_play_update:

    ; toggle debug
    ld      a,[coreInputOn]
    and     BUTTON_SELECT
    cp      BUTTON_SELECT
    jr      nz,.update

    ld      a,[menuDebug]
    inc     a
    and     %0000_0001
    ld      [menuDebug],a
    call    menu_play_init

.update:
    ld      a,[coreInputOn]
    and     BUTTON_START
    cp      BUTTON_START
    jp      z,.toggle_pause

    ld      a,[gameMode]
    cp      GAME_MODE_PAUSE
    ret     z

    ; only update ui only every 15 frames
    ld      a,[coreLoopCounter16]
    and     %0000_1111
    ret     nz

    call    menu_play_render
    ret

.toggle_pause:
    ld      a,[gameMode]
    cp      GAME_MODE_PAUSE
    jr      z,.unpause

    ld      a,1
    ld      [forceUIUpdate],a
    call    sound_effect_pause
    call    clear_bg

    ld      bc,$0009
    ld      hl,text_game_paused
    call    ui_text
    ldxa    [gameMode],GAME_MODE_PAUSE
    ret

.unpause:
    ld      a,1
    ld      [forceUIUpdate],a
    call    sound_effect_unpause
    call    clear_bg
    ldxa    [gameMode],GAME_MODE_PLAY
    call    menu_play_render
    ret


menu_play_render:
    ld      a,[menuDebug]
    cp      0
    jr      z,.game

    ; asteroid counts
.debug:
    ld      a,[asteroidSmallAvailable]
    cpl
    inc     a
    add     ASTEROID_SMALL_MAX
    ld      bc,$0200
    ld      de,$01FF
    call    ui_number_right_aligned

    ld      a,[asteroidMediumAvailable]
    cpl
    inc     a
    add     ASTEROID_MEDIUM_MAX
    ld      bc,$0800
    ld      de,$01FF
    call    ui_number_right_aligned

    ld      a,[asteroidLargeAvailable]
    cpl
    inc     a
    add     ASTEROID_LARGE_MAX
    ld      bc,$0E00
    ld      de,$01FF
    call    ui_number_right_aligned

    ld      a,[asteroidGiantAvailable]
    cpl
    inc     a
    add     ASTEROID_GIANT_MAX
    ld      bc,$0201
    ld      de,$01FF
    call    ui_number_right_aligned

    ; bullet counts
    ld      a,[bulletCount]
    ld      bc,$0801
    ld      de,$01FF
    call    ui_number_right_aligned

    ; player information
    ld      a,[polygonState + 11]
    ld      bc,$0411
    ld      de,$03FF
    call    ui_number_right_aligned

    ld      a,[polygonState + 10]
    ld      bc,$0A11
    ld      de,$03FF
    call    ui_number_right_aligned

    ld      a,[polygonState + 12]
    ld      bc,$1011
    ld      de,$03FF
    call    ui_number_right_aligned
    ret

.game:
    ; check if destroyed
    ld      a,[playerShield]
    cp      0
    ret     z

    ; check playerY and switch hud position around
    ld      a,[playerY]
    cp      80
    jr      c,.bottom

.top:
    ld      hl,uiOffscreenBuffer + $00 + 544
    xor     a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a

    ld      hl,uiOffscreenBuffer + $0C + 544
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a

    ; points
    ld      hl,uiOffscreenBuffer + $0C
    ld      [hl],$70
    ld      hl,uiOffscreenBuffer + $0D
    ld      [hl],$71

    ld      a,[playerScore + 2]
    ld      bc,$0F00
    ld      de,$0200
    call    ui_number_right_aligned

    ld      a,[playerScore + 1]
    ld      bc,$1100
    ld      de,$0200
    call    ui_number_right_aligned

    ld      a,[playerScore]
    ld      bc,$1300
    ld      de,$0200
    call    ui_number_right_aligned

    ; right / left
    ld      hl,uiOffscreenBuffer + $0A
    ld      [hl],$6F
    ld      hl,uiOffscreenBuffer + $00
    jr      .bar

.bottom:
    ld      hl,uiOffscreenBuffer + $00
    xor     a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a

    ld      hl,uiOffscreenBuffer + $0C
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a

    ; points
    ld      hl,uiOffscreenBuffer + $0C + 544
    ld      [hl],$70
    ld      hl,uiOffscreenBuffer + $0D + 544
    ld      [hl],$71

    ld      a,[playerScore + 2]
    ld      bc,$0F11
    ld      de,$0200
    call    ui_number_right_aligned

    ld      a,[playerScore + 1]
    ld      bc,$1111
    ld      de,$0200
    call    ui_number_right_aligned

    ld      a,[playerScore]
    ld      bc,$1311
    ld      de,$0200
    call    ui_number_right_aligned

    ; right / left
    ld      hl,uiOffscreenBuffer + $0A + 544
    ld      [hl],$6F
    ld      hl,uiOffscreenBuffer + $00 + 544

.bar:
    ld      [hl],$68
    inc     hl
    ld      [hl],$69
    inc     hl

    ; fill shield gauge
    ldxa    c,[playerShield]
    ld      b,8

.loop:
    ld      a,c
    cp      8
    jr      nc,.full
    srl     a
    add     a,$6A
    jr      .next

.full:
    ld      a,$6E

.next:
    ld      [hli],a

    ; reduce remaining shield to draw
    ld      a,c
    sub     8
    jr      nc,.above_0
    xor     a

.above_0:
    ld      c,a
    dec     b
    jr      nz,.loop
    ret

; GAME OVER -------------------------------------------------------------------
menu_game_over_init:
    xor     a
    ld      [menuButton],a

    ldxa    [gameMode],GAME_MODE_OVER
    call    clear_bg

    ld      bc,$0003
    ld      hl,text_game_over_0
    call    ui_text

    ld      bc,$0006
    ld      hl,text_game_over_1
    call    ui_text

    ld      a,[playerScore + 2]
    ld      bc,$0808
    ld      de,$0200
    call    ui_number_right_aligned

    ld      a,[playerScore + 1]
    ld      bc,$0A08
    ld      de,$0200
    call    ui_number_right_aligned

    ld      a,[playerScore]
    ld      bc,$0C08
    ld      de,$0200
    call    ui_number_right_aligned

    ld      bc,$000A
    ld      hl,text_game_over_3
    call    ui_text

    ld      bc,$000D
    ld      hl,text_game_over_4
    call    ui_text

    ld      bc,$000F
    ld      hl,text_game_over_5
    call    ui_text
    ret

menu_game_over_update:
    ld      a,[coreInputOn]
    cp      BUTTON_START
    jr      z,.select_button
    cp      BUTTON_A
    jr      z,.select_button
    cp      BUTTON_LEFT
    jr      nz,.right
    xor     a
    ld      [menuButton],a
    call    sound_effect_select
    jr      .blink

.right:
    ld      a,[coreInputOn]
    cp      BUTTON_RIGHT
    jr      nz,.blink
    ld      a,1
    ld      [menuButton],a
    call    sound_effect_select

.blink:
    ; update ui only every 15 frames
    ld      a,[coreLoopCounter16]
    cp      8
    jr      c,.off
    ld      hl,$1000
    jr      .update

.off:
    ld      hl,$0000

.update:
    ld      a,1
    ld      [forceUIUpdate],a

    ld      a,[menuButton]
    cp      1
    jr      z,.right_button

    ld      bc,$0610
    ld      de,$0300
    ld      e,h
    push    hl
    call    ui_character
    pop     hl

    ld      bc,$0C10
    ld      de,$0200
    ld      e,l
    call    ui_character
    ret

.right_button:
    ld      bc,$0610
    ld      de,$0300
    ld      e,l
    push    hl
    call    ui_character
    pop     hl

    ld      bc,$0C10
    ld      de,$0200
    ld      e,h
    call    ui_character
    ret

.select_button:
    ld      a,[menuButton]
    cp      0
    jr      z,.restart
    call    sound_effect_cancel
    call    game_title
    ret

.restart:
    call    sound_effect_confirm
    call    game_play
    ret


; GAME TITLE ------------------------------------------------------------------
menu_game_title_init:
    xor     a
    ld      [menuButton],a

    ldxa    [rSCX],4

    ldxa    [gameMode],GAME_MODE_TITLE
    call    clear_bg

    call    ship_title

    ld      bc,$0002
    ld      hl,text_game_title_0
    call    ui_text

    ld      bc,$000D
    ld      hl,text_game_title_1
    call    ui_text

    ; ld      bc,$000F
    ; ld      hl,text_game_title_2
    ; call    ui_text
    ret

menu_game_title_update:
    ld      a,[coreInputOn]
    cp      BUTTON_START
    jr      z,.start
    cp      BUTTON_A
    jr      z,.start
    cp      BUTTON_UP
    jr      z,.up
    cp      BUTTON_DOWN
    jr      z,.down

    ; update ui only every 15 frames
    ld      a,[coreLoopCounter16]
    cp      8
    jr      c,.off
    ld      hl,$1000
    jr      .update

.off:
    ld      hl,$0000

.update:
    ld      a,1
    ld      [forceUIUpdate],a

    ld      bc,$050E
    ld      de,$0B00
    ld      e,h
    call    ui_character
    ret

.start:
    xor     a
    ld      [coreInputOn],a
    call    sound_effect_confirm
    call    game_play
    ret

.up:
    call    sound_effect_break
    ret

.down:
    call    sound_effect_ship_destroy
    ret

; Text Data -------------------------------------------------------------------
text_game_title_0:
    DS 20 "   -- VECTROIDS --\0"
text_game_title_1:
    DS 17 "     Press Start\0"
text_game_title_2:
    DS 16 "     Highscores\0"

text_game_over_0:
    DS 16 "     GAME OVER!\0"
text_game_over_1:
    DS 18 "   Your Score was\0"
text_game_over_3:
    DS 14 "       Points\0"
text_game_over_4:
    DS 16 "     Try again?\0"
text_game_over_5:
    DS 16 "      YES   NO\0"

text_game_paused:
    DS 14 "       PAUSED\0"

text_debug_ui_one:
    DS 18 "S:X/6 M:X/3 L:X/2\0"

text_debug_ui_two:
    DS 12 "G:X/1 B:X/4\0"

text_debug_ui_three:
    DS 18 "X:XXX Y:XXX R:XXX\0"

