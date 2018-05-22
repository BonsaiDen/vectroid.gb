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

    ; load UI tiles
    ld      hl,DataUITiles
    ld      de,$8000
    call    core_decode_eom

    ; init polygon data
    call    polygon_init
    call    ship_init
    call    asteroid_init
    call    sound_enable
    call    game_hud_init
    ret

; Main Loop -------------------------------------------------------------------
game_loop:
    call    asteroid_launch
    call    asteroid_queue
    call    polygon_update
    call    ship_fire_bullet
    call    ship_fire_thrust
    call    ship_out_of_bounds
    call    game_hud_update
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
    ;ld      bc,$0000
    ;ld      hl,text_hud_shield
    ;call    ui_text
    ret

game_hud_update:

    ; TODO render into off-screen buffer
    ; TODO copy in hblanks?
    ld      a,[coreInputOn]
    and     BUTTON_START
    cp      BUTTON_START
    jr      nz,.update

    ; toggle
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
    ; TODO check playerY and switch hud position around
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


; Timer -----------------------------------------------------------------------
game_timer:
    incx    [playerShield]
    ret

text_hud_shield:
    DS 5 "SHLD\0"

text_debug_ui_one:
    DS 18 "S:X/6 M:X/3 L:X/2\0"

text_debug_ui_two:
    DS 12 "G:X/1 B:X/4\0"

text_debug_ui_three:
    DS 18 "X:XXX Y:XXX R:XXX\0"

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

