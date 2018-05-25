; Main Game Logic -------------------------------------------------------------
SECTION "GameLogic",ROM0

; Initialization --------------------------------------------------------------
game_init:

    call    init_bg
    call    menu_init
    call    polygon_init
    call    sound_enable

    ; update palette on next vblank
    ldxa    [paletteUpdated],1

    ; init polygon data
    call    game_title
    ;call    game_over
    ret

; Main Loop -------------------------------------------------------------------
game_start:
    ldxa    [gameMode],GAME_MODE_PLAY
    call    game_score_reset
    call    screen_init
    call    polygon_init
    call    ship_init
    call    asteroid_init
    call    sound_enable
    call    menu_play_init
    ret

game_title:
    call    screen_init
    call    ship_init
    call    polygon_init
    call    asteroid_init
    call    menu_game_title_init
    ret

game_over:
    call    menu_game_over_init
    ret

game_timer:
    call    screen_shake_timer
    ret

game_loop:
    ld      a,[gameMode]
    cp      GAME_MODE_PAUSE
    jr      z,.paused
    cp      GAME_MODE_TITLE
    jr      z,.paused

    call    asteroid_launch
    call    asteroid_queue
    call    polygon_update
    call    ship_fire_bullet
    call    ship_fire_thrust
    call    ship_special_update

.paused:
    call    menu_play_update
    ret

game_score_increase:; a = increase
    ld      b,a

    ; schedule points redraw
    ld      a,1
    ld      [forceUIUpdate],a
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

