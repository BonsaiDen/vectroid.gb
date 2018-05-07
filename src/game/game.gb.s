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

    ; load UI tiles
    ld      hl,DataUITiles
    ld      de,$8000
    call    core_decode_eom

    ; setup test tiles
    ld      d,0
    ld      hl,$9800
    ld      bc,$400
    call    core_vram_set

    ; init polygon data
    call    polygon_init

    createPolygon(2,     COLLISION_SHIP,     PALETTE_SHIP,  64,  96, 128,           ship_polygon, ship_update)
    createPolygon(2, COLLISION_ASTEROID, PALETTE_ASTEROID, 128,  96,  64, small_asteroid_polygon, asteroid_update)
    createPolygon(2, COLLISION_ASTEROID, PALETTE_ASTEROID,  96,  64, 128, small_asteroid_polygon, asteroid_update)
    createPolygon(2, COLLISION_ASTEROID, PALETTE_ASTEROID,  64,  64, 192, small_asteroid_polygon, asteroid_update)
    createPolygon(3, COLLISION_ASTEROID, PALETTE_ASTEROID, 112,  24,   0,       asteroid_polygon, asteroid_update)
    createPolygon(3, COLLISION_ASTEROID, PALETTE_ASTEROID, 112, 112,   0,       asteroid_polygon, asteroid_update)
    createPolygon(4, COLLISION_ASTEROID, PALETTE_ASTEROID,  24,  24,  50,   big_asteroid_polygon, asteroid_update)

    ;createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 64 + 7, 96,   0,         thrust_polygon_a, thrust_update)
    ;createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 32, 120,   0,          effect_polygon, effect_update)
    ;createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 48, 120,   0,          effect_polygon, effect_update)
    ;createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 64, 120,   0,          effect_polygon, effect_update)
    ;createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 80, 120,   0,          effect_polygon, effect_update)
    ;createPolygon(1,     COLLISION_NONE,   PALETTE_EFFECT, 96, 120,   0,          effect_polygon, effect_update)

    ;createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 16, 64,   $D7,          bullet_polygon, bullet_update)
    ;createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 32, 140,   0,          bullet_polygon, bullet_update)
    ;createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 48, 140,   0,          bullet_polygon, bullet_update)
    ;createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 64, 140,   0,          bullet_polygon, bullet_update)

    ;createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 80,  16,   0,          bullet_polygon, bullet_update)
    ;createPolygon(1,   COLLISION_BULLET,   PALETTE_BULLET, 96,   8,   0,          bullet_polygon, bullet_update)
    ret


; Main Loop -------------------------------------------------------------------
game_loop:
    call    polygon_update
    call    ship_fire_bullet
    call    ship_fire_thrust
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

    ; debug test print
    ld      a,[polygonState + 11]
    ld      bc,$1300
    ld      de,$05FF
    call    ui_number_right_aligned

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

small_asteroid_polygon:
    DB      0; angle
    DB      7; length

    DB      35; angle
    DB      4; length

    DB      85; angle
    DB      6; length

    DB      135; angle
    DB      3; length

    DB      200; angle
    DB      5; length

    DB      220; angle
    DB      6; length

    DB      0; angle
    DB      7; length
    DB      $ff,$ff

asteroid_polygon:
    DB      0; angle
    DB      11; length
    DB      35; angle
    DB      10; length
    DB      85; angle
    DB      11; length
    DB      135; angle
    DB      11; length
    DB      200; angle
    DB      7; length
    DB      0; angle
    DB      11; length
    DB      $ff,$ff

big_asteroid_polygon:
    DB      0; angle
    DB      13; length
    DB      25; angle
    DB      15; length
    DB      85; angle
    DB      14; length
    DB      125; angle
    DB      13; length
    DB      165; angle
    DB      15; length
    DB      230; angle
    DB      14; length
    DB      0; angle
    DB      13; length
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

asteroid_update:
    ld      a,[polygonData]
    and     %0000_0111
    ld      b,a
    ld      a,[coreLoopCounter]
    cp      b
    jr      nz,.skip

    ld      a,[polygonData]
    ld      b,a
    ld      a,[polygonRotation]
    add     b
    ld      [polygonRotation],a

.skip:
    ld      a,1
    ret


MACRO createPolygon(@size, @group, @palette, @x, @y, @r, @data, @update)

    call    math_random_signed
    ld      [polygonData],a

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

