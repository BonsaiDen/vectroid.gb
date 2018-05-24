; Main Game Logic -------------------------------------------------------------
SECTION "GameLogic",ROM0

; Initialization --------------------------------------------------------------
game_init:

    ; Clear background tiles
    call    init_bg
    call    clear_bg

    ; update palette on next vblank
    ldxa    [paletteUpdated],1

    xor     a
    ld      [debugDisplay],a

    ; game mode
    ldxa    [gameMode],GAME_MODE_PLAY
    call    game_score_reset

    ; load UI tiles
    ld      hl,DataUITiles
    ld      de,$8000
    call    core_decode_eom

    ; init polygon data
    call    game_reset
    ret

; Main Loop -------------------------------------------------------------------
game_reset:
    call    polygon_init
    call    ship_init
    call    asteroid_init
    call    sound_enable
    call    game_hud_init
    ret

game_loop:
    ld      a,[gameMode]
    cp      GAME_MODE_PAUSE
    jr      z,.paused

    call    asteroid_launch
    call    asteroid_queue
    call    polygon_update
    call    ship_fire_bullet
    call    ship_fire_thrust
    call    ship_special_update

.paused:
    call    game_hud_update
    ret

game_score_increase:; a = increase
    ld      b,a
.loop:
    ld      a,b
    cp      0
    ret     z

    cp      50
    jr      nc,.add_50

.remainder:
    ld      a,[playerScore]
    add     b
    ld      b,0
    jr      .overflow_check

.add_50:
    sub     50
    ld      b,a
    ld      a,[playerScore]
    add     50

.overflow_check:
    cp      100
    jr      nc,.overflow
    ld      [playerScore],a
    jr      .loop

.overflow:
    sub     100
    ld      [playerScore],a
    incx    [playerScore + 1]
    jr      .loop

game_score_reset:
    xor     a
    ld      [playerScore],a
    ld      [playerScore + 1],a
    ret

game_draw_vram:
    ; load / update palette
    ld      a,[paletteUpdated]
    cp      0
    jr      z,.draw_polygons

    ; update palette vram
    xor     a
    ld      [paletteUpdated],a
    call    load_palette_sp
    call    load_palette_bg

.draw_polygons:
    call    polygon_draw
    call    ui_draw
    ret

; HUD -------------------------------------------------------------------------
game_hud_init:
    ld      a,[debugDisplay]
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
    ret

.game:
    call    clear_bg
    ret

game_hud_update:
    ld      a,[coreInputOn]
    and     BUTTON_START
    cp      BUTTON_START
    jp      z,.toggle_pause

    ; check game mode
    ld      a,[gameMode]
    cp      GAME_MODE_OVER
    jp      z,.game_over
    cp      GAME_MODE_PLAY
    ret     nz

    ; toggle debgu
    ld      a,[coreInputOn]
    and     BUTTON_SELECT
    cp      BUTTON_SELECT
    jr      nz,.update

    ld      a,[debugDisplay]
    inc     a
    and     %0000_0001
    ld      [debugDisplay],a
    call    game_hud_init

    ; only update when active
.update:
    ; update ui only every 15 frames
    ld      a,[coreLoopCounter16]
    and     %0000_1111
    ret     z

    ld      a,[debugDisplay]
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

    ld      hl,uiOffscreenBuffer + $0D + 544
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a

    ; points
    ld      hl,uiOffscreenBuffer + $0D
    ld      [hl],$70
    ld      hl,uiOffscreenBuffer + $0E
    ld      [hl],$71

    ld      a,[playerScore + 1]
    ld      bc,$1100
    ld      de,$0300
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

    ld      hl,uiOffscreenBuffer + $0D
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a

    ; points
    ld      hl,uiOffscreenBuffer + $0D + 544
    ld      [hl],$70
    ld      hl,uiOffscreenBuffer + $0E + 544
    ld      [hl],$71

    ld      a,[playerScore + 1]
    ld      bc,$1111
    ld      de,$0300
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

    ; TODO points display
    ret

.game_over:
    ; update ui only every 15 frames
    ld      a,[coreLoopCounter16]
    and     %0000_1111
    ret     z

    ; TODO flash selected choice
    ; TODO draw underline under selected choice only
    ret

.toggle_pause:
    ld      a,[gameMode]
    cp      GAME_MODE_OVER
    jr      z,.game_over_select

    ; TODO pause toggle sound effect
    ; TODO need a simply sound effect queue system to play multiple notes
    ; TODO in succession
    cp      GAME_MODE_PAUSE
    jr      z,.unpause

    call    clear_bg
    ld      bc,$0009
    ld      hl,text_game_paused
    call    ui_text
    ldxa    [gameMode],GAME_MODE_PAUSE
    ret

.unpause:
    call    clear_bg
    ldxa    [gameMode],GAME_MODE_PLAY
    ret

.game_over_select:
    ldxa    [gameMode],GAME_MODE_PLAY
    call    game_reset
    ret

game_hud_over:
    ldxa    [gameMode],GAME_MODE_OVER
    call    clear_bg

    ld      bc,$0003
    ld      hl,text_game_over_0
    call    ui_text

    ld      bc,$0007
    ld      hl,text_game_over_1
    call    ui_text

    ; TODO display actual points
    ld      bc,$0009
    ld      hl,text_game_over_2
    call    ui_text

    ld      bc,$000B
    ld      hl,text_game_over_3
    call    ui_text

    ld      bc,$000E
    ld      hl,text_game_over_4
    call    ui_text
    ret


; Timer -----------------------------------------------------------------------
game_timer:
    ; ld      a,50
    ; call    game_score_increase
    ret


; Helper ----------------------------------------------------------------------
init_bg:
    ld      d,0
    ld      hl,$9800
    ld      bc,$400
    call    core_mem_set
    ret

clear_bg:
    ld      a,0
    ld      hl,uiOffscreenBuffer
    ld      bc,576
    call    core_mem_set
    ret


; Text Data -------------------------------------------------------------------
text_game_over_0:
    DS 16 "     GAME OVER!\0"
text_game_over_1:
    DS 18 "   Your Score was\0"
text_game_over_2:
    DS 14 "       000000\0"
text_game_over_3:
    DS 14 "       Points\0"
text_game_over_4:
    DS 16 "     Try again?\0"
text_game_over_yes:
    DS 4 "YES\0"
text_game_over_no:
    DS 3 "NO\0"

text_game_paused:
    DS 14 "       PAUSED\0"

text_debug_ui_one:
    DS 18 "S:X/6 M:X/3 L:X/2\0"

text_debug_ui_two:
    DS 12 "G:X/1 B:X/4\0"

text_debug_ui_three:
    DS 18 "X:XXX Y:XXX R:XXX\0"

