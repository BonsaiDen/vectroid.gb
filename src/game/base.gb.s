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

    ; bullets
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00

    ; ships
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00
    DB      $ff,$00,$00,$00

polygon_state_base:; POLYGON_BYTES bytes per polygon

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $08; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $10; Sprite Size
    DB      $00; Sprite index
    DB      $00; Old Rotation
    DB      $04; Tile Clear Count
    DW      polygonOffscreenBuffer + $0000; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $08; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $10; Sprite Size
    DB      $02; Sprite index
    DB      $00; Old Rotation
    DB      $04; Sprite count
    DW      polygonOffscreenBuffer + $0040; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $08; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $10; Sprite Size
    DB      $04; Sprite index
    DB      $00; Old Rotation
    DB      $04; Tilecount
    DW      polygonOffscreenBuffer + $0080; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $08; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $10; Sprite Size
    DB      $06; Sprite index
    DB      $00; Old Rotation
    DB      $04; Tile Clear Count
    DW      polygonOffscreenBuffer + $00C0; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 1
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $08; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $0100; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 2
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $09; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $0120; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 3
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0A; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $0140; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 4
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0B; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $0160; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 5
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0C; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $0180; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 6
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0D; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $01A0; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 7
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0E; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $01C0; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 8
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $0F; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $01E0; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 9
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $10; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $0200; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 10
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $11; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $0220; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 11
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $12; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $0240; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 12
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $04; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $00; Sprite Size
    DB      $13; Sprite index
    DB      $00; Old Rotation
    DB      $01; Tile Clear Count
    DW      polygonOffscreenBuffer + $0260; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 3x3
    DB      %0000_0011; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $0C; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $20; Sprite Size
    DB      $14; Sprite index
    DB      $00; Old Rotation
    DB      $0B; Tile Clear Count
    DW      polygonOffscreenBuffer + $0280; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 3x3
    DB      %0000_0011; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $0C; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $20; Sprite Size
    DB      $1A; Sprite index
    DB      $00; Old Rotation
    DB      $0B; Tile Clear Count
    DW      polygonOffscreenBuffer + $0340; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 4x4
    DB      %0000_0100; active / size
    DW      $ffff; Update routine
    DB      $00; Data
    DB      $00; Data
    DB      $00; MX
    DB      $00; MY
    DB      $00; PX
    DB      $00; PY
    DB      $10; Sprite half width
    DB      $20; Y
    DB      $20; X
    DB      $00; Rotation
    DB      $30; Sprite Size
    DB      $20; Sprite index
    DB      $00; Old Rotation
    DB      $10; Tile Clear Count
    DW      polygonOffscreenBuffer + $0400; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; end marker
    DB      $ff

