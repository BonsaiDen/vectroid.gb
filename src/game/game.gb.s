; Main Game Logic -------------------------------------------------------------
SECTION "GameLogic",ROM0

; Initialization --------------------------------------------------------------
game_init:

    ; update palette on next vblank
    ldxa    [paletteUpdated],1

    ; reset player ship variables
    xor     a
    ld      [bulletFired],a
    ld      [bulletDelay],a
    ld      [bulletCount],a
    ld      [thrustDelay],a
    ld      [thrustType],a
    ld      [thrustActive],a

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
    call    asteroid_init
    call    sound_enable
    call    game_debug_init

    ; Setup test polygons
    createPolygon(2,     COLLISION_SHIP,     PALETTE_SHIP,  64,  96, 128,           ship_polygon, ship_update)
    ; createPolygon(2, COLLISION_ASTEROID, PALETTE_ASTEROID, 128,  96,  64, medium_asteroid_polygon, asteroid_update)
    ; createPolygon(2, COLLISION_ASTEROID, PALETTE_ASTEROID,  96,  64, 128, medium_asteroid_polygon, asteroid_update)
    ; createPolygon(2, COLLISION_ASTEROID, PALETTE_ASTEROID,  64,  64, 192, medium_asteroid_polygon, asteroid_update)
    ; createPolygon(3, COLLISION_ASTEROID, PALETTE_ASTEROID, 112,  24,   0,       large_asteroid_polygon, asteroid_update)
    ; createPolygon(3, COLLISION_ASTEROID, PALETTE_ASTEROID, 112, 112,   0,       large_asteroid_polygon, asteroid_update)
    ; createPolygon(4, COLLISION_ASTEROID, PALETTE_ASTEROID,  24,  24,  50,   giant_asteroid_polygon, asteroid_update)

    ; setup test asteroid

    ; ldxa    [polygonX],40
    ; ldxa    [polygonY],80
    ; ld      a,50
    ; ld      b,POLYGON_GIANT
    ; ld      c,0
    ; ld      e,0
    ; call    asteroid_create

    ; ldxa    [polygonX],80
    ; ldxa    [polygonY],40
    ; ld      a,50
    ; ld      b,POLYGON_MEDIUM
    ; ld      c,0
    ; ld      e,0
    ; call    asteroid_create

    ; createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 64 + 7, 96,   0,         thrust_polygon_a, thrust_update)
    ; createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 32, 120,   0,          effect_polygon, effect_update)
    ; createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 48, 120,   0,          effect_polygon, effect_update)
    ; createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 64, 120,   0,          effect_polygon, effect_update)
    ; createPolygon(1,     COLLISION_ASTEROID,   PALETTE_ASTEROID, 80, 120,   0,          small_asteroid_polygon, asteroid_update)
    ; createPolygon(1,     COLLISION_ASTEROID,   PALETTE_ASTEROID, 96, 120,   0,          small_asteroid_polygon, asteroid_update)

    ; createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 16, 64,   $D7,          bullet_polygon, bullet_update)
    ; createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 32, 140,   0,          bullet_polygon, bullet_update)
    ; createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 48, 140,   0,          bullet_polygon, bullet_update)
    ; createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 64, 140,   0,          bullet_polygon, bullet_update)

    ; createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 80,  16,   0,          bullet_polygon, bullet_update)
    ; createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 96,   8,   0,          bullet_polygon, bullet_update)
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

; Main Loop -------------------------------------------------------------------
game_loop:
    call    asteroid_launch
    call    asteroid_queue
    call    polygon_update
    call    ship_fire_bullet
    call    ship_fire_thrust
    call    game_debug
    ret


game_debug:
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

    ; update ui only every 4 frames
    ld      a,[coreLoopCounter]
    and     %0000_0011
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
    ret

effect_polygon:
    DB      0; angle
    DB      3; length
    DB      64
    DB      3; length
    DB      128
    DB      3; length
    DB      192
    DB      3; length
    DB      0; angle
    DB      3; length
    DB      $ff,$ff

ship_other:
    ld      a,[coreLoopCounter]
    and     %0000_0011
    jr      nz,.skip
    ld      a,[polygonRotation]
    dec     a
    dec     a
    dec     a
    dec     a
    ld      [polygonRotation],a
.skip:
    ld      a,1
    ret

effect_update:
    call    math_random
    cp      64
    jr      nc,.skip
    ld      a,[polygonRotation]
    add     8
    ld      [polygonRotation],a
.skip:
    ld      a,1
    ret

MACRO createPolygon(@size, @group, @palette, @x, @y, @r, @data, @update)

    ; rotation speed stuff
    call    math_random_signed
    ld      [polygonDataA],a

    ; asteroid hp
    ld      a,8
    ld      [polygonDataB],a

    ;call    math_random_signed
    xor     a
    ld      [polygonMX],a
    ;call    math_random_signed
    ld      [polygonMY],a

    ld      a,@palette
    ld      [polygonPalette],a
    ld      a,@group
    ld      [polygonGroup],a
    ld      a,@x + SCROLL_BORDER
    ld      [polygonX],a
    ld      a,@y + SCROLL_BORDER
    ld      [polygonY],a
    ld      a,@r
    ld      [polygonRotation],a
    ld      de,@data
    ld      bc,@update
    ld      a,@size
    call    polygon_create
ENDMACRO

