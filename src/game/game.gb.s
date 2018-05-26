; Main Game Logic -------------------------------------------------------------
SECTION "GameLogic",ROM0

; Initialization --------------------------------------------------------------
game_init:

    call    init_bg
    call    menu_init
    call    polygon_init
    call    screen_init
    call    sound_enable
    call    palette_init

    ; setup title
    xor     a
    ld      [gameDelay],a
    call    game_title_run
    ret


; Main Loop -------------------------------------------------------------------
game_play:
    ldxa    [gameDelay],24
    ldxa    [gameModeNext],GAME_MODE_PLAY
    call    screen_flash_out
    ret

game_title:
    ldxa    [gameDelay],24
    ldxa    [gameModeNext],GAME_MODE_TITLE
    call    screen_flash_out
    ret

game_over:
    ld      a,1
    ld      [forceUIUpdate],a
    call    clear_bg
    ldxa    [gameDelay],200
    ldxa    [gameModeNext],GAME_MODE_OVER
    ret

game_play_run:
    call    screen_flash_in
    ldxa    [gameMode],GAME_MODE_PLAY
    call    game_score_reset
    call    screen_reset
    call    polygon_init
    call    ship_init
    call    asteroid_init
    call    sound_enable
    call    menu_play_init
    ret

game_title_run:
    call    screen_flash_in
    call    screen_reset
    call    ship_init
    call    polygon_init
    call    asteroid_init
    call    menu_game_title_init
    ret

game_over_run:
    call    menu_game_over_init
    ret

game_timer:
    call    screen_shake_timer
    ret

game_loop:

    ; handle transitions
    call    screen_flash_update
    ld      a,[gameDelay]
    cp      0
    jr      z,.handle_mode

    ; ignore inputs during delay
    xor     a
    ld      [coreInputOn],a

    ld      a,[gameDelay]
    dec     a
    ld      [gameDelay],a
    cp      0
    jr      nz,.handle_mode

    ; switch game mode
    ld      a,[gameModeNext]
    cp      GAME_MODE_TITLE
    call    z,game_title_run
    cp      GAME_MODE_PLAY
    call    z,game_play_run
    cp      GAME_MODE_OVER
    call    z,game_over_run

.handle_mode:
    ld      a,[gameMode]
    cp      GAME_MODE_PAUSE
    jr      z,.paused

    cp      GAME_MODE_TITLE
    jr      z,.title

    call    asteroid_launch
    call    asteroid_queue
    call    polygon_update
    call    ship_fire_bullet
    call    ship_fire_thrust
    call    ship_special_update

    ld      a,[gameMode]
    cp      GAME_MODE_OVER
    jr      z,.game_over

    call    menu_play_update
    ret

.game_over:
    call    menu_game_over_update
    ret

.title:
    call    polygon_update
    call    menu_game_title_update
    ret

.paused:
    call    menu_play_update
    ret

game_score_increase:; a = increase
    ld      b,a
    cp      0
    ret     z

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
    cp      100
    jr      nc,.overflow_2
    jr      .loop

.overflow_2:
    xor     a
    ld      [playerScore + 1],a
    incx    [playerScore + 2]
    sub     100
    jr      nc,.overflow_3
    jr      .loop

.overflow_3:
    ldxa    [playerScore + 2],99
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
    call    palette_copy
    ret

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

