SECTION "PolygonBaseData",ROM0

polygon_sprite_base:
    ; 0-3. 2x2
    DB      0,0,$80,0
    DB      0,0,$82,0
    DB      0,0,$84,0
    DB      0,0,$86,0
    DB      0,0,$88,0
    DB      0,0,$8A,0
    DB      0,0,$8C,0
    DB      0,0,$8E,0

    ; 4-15. 1x1
    DB      0,0,$90,0
    DB      0,0,$92,0
    DB      0,0,$94,0
    DB      0,0,$96,0

    DB      0,0,$98,0
    DB      0,0,$9A,0
    DB      0,0,$9C,0
    DB      0,0,$9E,0

    DB      0,0,$A0,0
    DB      0,0,$A2,0
    DB      0,0,$A4,0
    DB      0,0,$A6,0

    ; 16-17. 3x3
    DB      0,0,$A8,0
    DB      0,0,$AA,0
    DB      0,0,$AC,0
    DB      0,0,$AE,0

    DB      0,0,$B0,0
    DB      0,0,$B2,0
    DB      0,0,$B4,0
    DB      0,0,$B6,0

    DB      0,0,$B8,0
    DB      0,0,$BA,0
    DB      0,0,$BC,0
    DB      0,0,$BE,0

    ; 18
    DB      0,0,$C0,0
    DB      0,0,$C2,0
    DB      0,0,$C4,0
    DB      0,0,$C6,0
    DB      0,0,$C8,0
    DB      0,0,$CA,0
    DB      0,0,$CC,0
    DB      0,0,$CE,0

polygon_collision_base:
    ; group/y-attr-pointer/??

    ; asteroids
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00

    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $00

polygon_state_base:; POLYGON_BYTES bytes per polygon

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $08; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $10; Sprite Size
    DB      $00; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $04; Tile Clear Count
    DW      polygon_sprite_1
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $08; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $10; Sprite Size
    DB      $02; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $04; Sprite count
    DW      polygon_sprite_2
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $08; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $10; Sprite Size
    DB      $04; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $04; Tilecount
    DW      polygon_sprite_3
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $08; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $10; Sprite Size
    DB      $06; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $04; Tile Clear Count
    DW      polygon_sprite_4
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 1
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $08; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_5
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 2
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $09; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_6
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 3
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0A; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_7
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 4
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0B; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_8
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 5
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0C; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_9
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 6
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0D; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_10
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 7
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0E; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_11
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 8
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0F; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_12
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 9
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $10; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_13
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 10
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $11; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_14
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 11
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $12; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_15
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 1x1 12
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $13; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygon_sprite_16
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 3x3
    DB      %0000_0011; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $0C; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $20; Sprite Size
    DB      $14; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $0B; Tile Clear Count
    DW      polygon_sprite_17
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 3x3
    DB      %0000_0011; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $0C; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $20; Sprite Size
    DB      $1A; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $0B; Tile Clear Count
    DW      polygon_sprite_18
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; 4x4
    DB      %0000_0100; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $10; Sprite half width
    DB      $20; Y
    DB      $20; X
    DW      $FF
    DB      $00; Rotation
    DB      $30; Sprite Size
    DB      $20; Sprite index
    DB      $55; Redraw Flag
    DB      $00; Old Rotation
    DB      $10; Tile Clear Count
    DW      polygon_sprite_19
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA
    DB      $55
    DB      $AA

    ; end marker
    DB      $FF

SECTION "PolygonTileData",ROM0
polygon_sprite_1:
    sprite_two(polygonOffscreenBuffer + $0000)

polygon_sprite_2:
    sprite_two(polygonOffscreenBuffer + $0040)

polygon_sprite_3:
    sprite_two(polygonOffscreenBuffer + $0080)

polygon_sprite_4:
    sprite_two(polygonOffscreenBuffer + $00C0)

polygon_sprite_5:
    sprite_one(polygonOffscreenBuffer + $0100)

polygon_sprite_6:
    sprite_one(polygonOffscreenBuffer + $0120)

polygon_sprite_7:
    sprite_one(polygonOffscreenBuffer + $0140)

polygon_sprite_8:
    sprite_one(polygonOffscreenBuffer + $0160)

polygon_sprite_9:
    sprite_one(polygonOffscreenBuffer + $0180)

polygon_sprite_10:
    sprite_one(polygonOffscreenBuffer + $01A0)

polygon_sprite_11:
    sprite_one(polygonOffscreenBuffer + $01C0)

polygon_sprite_12:
    sprite_one(polygonOffscreenBuffer + $01E0)

polygon_sprite_13:
    sprite_one(polygonOffscreenBuffer + $0200)

polygon_sprite_14:
    sprite_one(polygonOffscreenBuffer + $0220)

polygon_sprite_15:
    sprite_one(polygonOffscreenBuffer + $0240)

polygon_sprite_16:
    sprite_one(polygonOffscreenBuffer + $0260)

polygon_sprite_17:
    sprite_three(polygonOffscreenBuffer + $0280)

polygon_sprite_18:
    sprite_three(polygonOffscreenBuffer + $0340)

polygon_sprite_19:
    sprite_four(polygonOffscreenBuffer + $0400)

MACRO sprite_one(@base)
    DW      @base
    DW      @base
    DW      @base
    DW      @base
ENDMACRO

MACRO sprite_two(@base)
    DW      @base
    DW      @base + 2 * 16
    DW      @base
    DW      @base

    DW      @base + 1 * 16
    DW      @base + 3 * 16
    DW      @base
    DW      @base
ENDMACRO

MACRO sprite_three(@base)
    DW      @base
    DW      @base +  2 * 16
    DW      @base +  4 * 16
    DW      @base

    DW      @base +  1 * 16
    DW      @base +  3 * 16
    DW      @base +  5 * 16
    DW      @base

    DW      @base +  6 * 16
    DW      @base +  8 * 16
    DW      @base + 10 * 16
    DW      @base
ENDMACRO

MACRO sprite_four(@base)
    DW      @base
    DW      @base +  2 * 16
    DW      @base +  4 * 16
    DW      @base +  6 * 16

    DW      @base +  1 * 16
    DW      @base +  3 * 16
    DW      @base +  5 * 16
    DW      @base +  7 * 16

    DW      @base +  8 * 16
    DW      @base + 10 * 16
    DW      @base + 12 * 16
    DW      @base + 14 * 16

    DW      @base +  9 * 16
    DW      @base + 11 * 16
    DW      @base + 13 * 16
    DW      @base + 15 * 16
ENDMACRO

