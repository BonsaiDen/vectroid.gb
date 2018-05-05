; Main Game Logic -------------------------------------------------------------
SECTION "GameLogic",ROM0

; Initialization --------------------------------------------------------------
game_init:

    ; setup background tile palette
    ld      a,%00000011
    ld      [corePaletteBG],a; load a into the memory pointed to by rBGP

    ; set sprite palette 0
    ld      a,%11110011  ; 3 = black      2 = light gray  1 = white  0 = transparent
    ld      [corePaletteSprite0],a

    ; set sprite palette 1
    ld      a,%00000000  ; 3 = dark gray  2 = light gray  1 = white  0 = transparent
    ld      [corePaletteSprite1],a

    ; mark palettes as changed
    ld      a,$01
    ld      [corePaletteChanged],a

    ; setup scroll border
    ld      a,SCROLL_BORDER
    ld      [rSCY],a
    ld      [rSCX],a

    ; setup test tiles
    ld      d,0
    ld      hl,$9800
    ld      bc,$400
    call    core_vram_set

    ; init polygon data
    call    polygon_init

    createPolygon(2,     COLLISION_SHIP,  64,  96,   0,         ship_polygon, ship_update)
    createPolygon(2,     COLLISION_SHIP, 128,  96,  64,         ship_polygon, ship_update_slow)
    createPolygon(2,     COLLISION_SHIP,  96,  64, 128,         ship_polygon, ship_update_slow)
    createPolygon(2,     COLLISION_SHIP,  64,  64, 192,         ship_polygon, ship_update_slow)
    createPolygon(3, COLLISION_ASTEROID, 112,  24,   0,     asteroid_polygon, asteroid_update)
    createPolygon(3, COLLISION_ASTEROID, 112, 112,   0,     asteroid_polygon, asteroid_update)
    createPolygon(4, COLLISION_ASTEROID,  24,  24,  50, big_asteroid_polygon, big_asteroid_update)

    createPolygon(1,     COLLISION_NONE, 16, 120,   0,        effect_polygon, effect_update)
    createPolygon(1,     COLLISION_NONE, 32, 120,   0,        effect_polygon, effect_update)
    createPolygon(1,     COLLISION_NONE, 48, 120,   0,        effect_polygon, effect_update)
    createPolygon(1,     COLLISION_NONE, 64, 120,   0,        effect_polygon, effect_update)
    createPolygon(1,     COLLISION_NONE, 80, 120,   0,        effect_polygon, effect_update)
    createPolygon(1,     COLLISION_NONE, 96, 120,   0,        effect_polygon, effect_update)

    createPolygon(1,   COLLISION_BULLET, 16, 140,   0,        bullet_polygon, bullet_update)
    createPolygon(1,   COLLISION_BULLET, 32, 140,   0,        bullet_polygon, bullet_update)
    createPolygon(1,   COLLISION_BULLET, 48, 140,   0,        bullet_polygon, bullet_update)
    createPolygon(1,   COLLISION_BULLET, 64, 140,   0,        bullet_polygon, bullet_update)

    createPolygon(1,   COLLISION_BULLET, 80,  16,   0,        bullet_polygon, bullet_update)
    createPolygon(1,   COLLISION_BULLET, 96,   8,   0,        bullet_polygon, bullet_update)
    ret

; Main Loop -------------------------------------------------------------------
game_loop:
    call    polygon_update
    ret

; Timer -----------------------------------------------------------------------
game_timer:
    ld      a,[testRotate]
    inc     a
    ld      [testRotate],a
    ret

game_draw_vram:
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

bullet_polygon:
    DB      0; angle
    DB      2; length
    DB      42
    DB      2; length
    DB      42 * 2
    DB      2; length
    DB      42 * 3
    DB      2; length
    DB      42 * 4
    DB      2; length
    DB      42 * 5
    DB      2; length
    DB      0; angle
    DB      2; length
    DB      $ff,$ff

ship_polygon:
    DB      0; angle
    DB      7; length
    DB      85 + 15; angle
    DB      7; length
    DB      85 + 85 - 15; angle
    DB      7; length
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
    DB      165; angle
    DB      15; length
    DB      230; angle
    DB      10; length
    DB      0; angle
    DB      13; length
    DB      $ff,$ff

ship_update:
    ld      a,[coreLoopCounter]
    and     %0000_0001
    jr      nz,.skip
    ;ld      a,-40
    ;ld      [polygonMX],a
    ld      a,[polygonRotation]
    inc     a
    inc     a
    ld      [polygonRotation],a
.skip:
    ld      a,1
    ret

ship_update_slow:
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

bullet_update:
    ld      a,125
    ld      [polygonMX],a
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
    ld      a,[coreLoopCounter]
    cp      %0000_0110
    jr      nz,.skip
    ld      a,[polygonRotation]
    inc     a
    inc     a
    inc     a
    inc     a
    ld      [polygonRotation],a
    cp      128
    jr      nc,.destroy

.skip:
    ld      a,1
    ret
.destroy:
    xor     a
    ret

big_asteroid_update:
    ld      a,[coreLoopCounter]
    cp      %0000_0111
    jr      nz,.skip
    ld      a,[polygonRotation]
    inc     a
    inc     a
    inc     a
    inc     a
    ld      [polygonRotation],a
.skip:
    ld      a,1
    ret

MACRO createPolygon(@size, @group, @x, @y, @r, @data, @update)
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

