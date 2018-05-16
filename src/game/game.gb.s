; Main Game Logic -------------------------------------------------------------
SECTION "GameLogic",ROM0

; Initialization --------------------------------------------------------------
game_init:

    ; update palette on next vblank
    ldxa    [paletteUpdated],1

    ld      a,1
    ld      [debugDisplay],a

    ; load UI tiles
    ld      hl,DataUITiles
    ld      de,$8000
    call    core_decode_eom

    ; Clear background tiles
    call    clear_bg

    ; init polygon data
    call    polygon_init
    call    ship_init
    call    asteroid_init
    call    sound_enable
    call    game_debug_init

    ret

; Main Loop -------------------------------------------------------------------
game_loop:
    call    asteroid_launch
    call    asteroid_queue
    call    polygon_update
    call    ship_fire_bullet
    call    ship_fire_thrust
    call    game_debug
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

game_debug:
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
    call    game_debug_init

    ; only update when active
.update:
    ld      a,[debugDisplay]
    cp      0
    ret     z

    ; update ui only every 7 frames
    ld      a,[coreLoopCounter]
    and     %0000_0111
    ret     z

    ; asteroid counts
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


    ; clear if de-activated
game_debug_init:
    ld      a,[debugDisplay]
    cp      0
    jr      z,.deactivate

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

.deactivate:
    call    clear_bg
    ret


; Timer -----------------------------------------------------------------------
game_timer:
    ret

text_debug_ui_one:
    DS 18 "S:X/6 M:X/3 L:X/2\0"

text_debug_ui_two:
    DS 12 "G:X/1 B:X/4\0"

text_debug_ui_three:
    DS 18 "X:XXX Y:XXX R:XXX\0"

clear_bg:
    ld      d,0
    ld      hl,$9800
    ld      bc,$400
    call    core_vram_set
    ret

