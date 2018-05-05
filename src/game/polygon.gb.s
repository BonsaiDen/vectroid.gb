SECTION "PolygonRender",ROM0


; Routines --------------------------------------------------------------------
polygon_init:
    ld      hl,polygon_sprite_base
    ld      de,$C000
    ld      bc,$A0
    call    core_mem_cpy

    ld      hl,polygon_state_base
    ld      de,polygonState
    ld      bc,POLYGON_COUNT * POLYGON_BYTES + 1
    call    core_mem_cpy

    ld      hl,polygon_collision_base
    ld      de,polygonCollisionGroups
    ld      bc,POLYGON_COLLISION_BYTES
    call    core_mem_cpy
    ret

    ; set polygonX, polygonY, polygonGroup, polygonRotation first
polygon_create:; a = size, bc = update, de = data pointer -> a=1 created, a=no size spot available

    ld      [polygonSize],a
    ld      hl,polygonState

    ; find unused polygon of the desired size
.loop:
    ld      a,$ff
    cp      [hl]; check for end marker
    jr      z,.all_in_use

    ; check for size match
    ld      a,[polygonSize]
    cp      [hl]
    jr      nz,.used_or_other_size

    or      %1000_0000; set active flag
    ld      [hli],a

    ; set update routine
    ldxa    [hli],b
    ldxa    [hli],c

    ; skip index
    ; TODO setup
    inc     hl

    ; reset momentum and delta
    xor     a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a

    ; skip half width
    inc     hl

    ; store y-attr-pointer
    ld      b,h
    ld      c,l

    ; set x
    ldxa    [hli],[polygonY]

    ; set y
    ldxa    [hli],[polygonX]

    ; set rotation
    ldxa    [hli],[polygonRotation]

    inc     hl; skip size
    inc     hl; skip sprite

    ; set old rotation to a different value to force initial update
    inc     a
    ld      [hli],a

    inc     hl; skip tile count
    inc     hl; skip tile offset
    inc     hl

    ; set polygon data
    ldxa    [hli],d
    ldxa    [hli],e

    ; add to collision group
.collision:
    ld      a,[polygonGroup]
    cp      $ff; no collision
    jr      z,.no_collision

    ; store polygon data pointer
    ld      d,h
    ld      e,l

    ; 32 bytes per group (4x8)
    add     a; x2
    add     a; x4
    add     a; x8
    add     a; x16
    add     a; x32
    ld      l,a
    ld      h,polygonCollisionGroups >> 8

    ; FIXME This doesn't guard against overflow
.next:
    ld      a,[hl]
    cp      $ff
    jr      nz,.collision_slot_in_used

    ; store size
    ldxa    [hli],[polygonSize]

    ; store data pointer
    ldxa    [hli],b
    ldxa    [hli],c

    ; divide L by 4 to get collision index
    div     l,4
    ld      a,l

    ; store collision index on polygon
    ld      [de],a

    ; return success
.done:
    ld      a,1
    ret

.no_collision:
    ; reset collision index
    ld      a,$ff
    ld      [hl],a
    ld      a,1
    ret

.collision_slot_in_used:
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    jr      .next

    ; skip bytes
.used_or_other_size:
    addw    hl,POLYGON_BYTES
    jr      .loop

.all_in_use:
    xor     a
    ret


polygon_update:

    ; update polygons
    ld      hl,polygonState

.loop:
    push    hl
    call    update_polygon
    pop     hl

    ; skip bytes
    addw    hl,POLYGON_BYTES

    ; check for end marker
    ld      a,$ff
    cp      [hl]
    jr      nz,.loop
    ret

update_polygon:; hl = polygon state pointer
    ; check if active
    ld      a,[hli]
    and     %1000_0000
    cp      0
    ret     z

    ; load update address
    ldxa    b,[hli]; high byte
    ldxa    c,[hli]; low byte

    ; load position and rotation
    inc     hl; skip index
    push    hl

    ; skip momentum and delta
    ldxa    [polygonMY],[hli]
    ldxa    [polygonMX],[hli]
    inc     hl; skip dy
    inc     hl; skip dx
    inc     hl; skip half size
    ldxa    [polygonY],[hli]
    ldxa    [polygonX],[hli]
    ld      a,[hl]; load current rotation
    ld      [polygonRotation],a

    ; call update routine
    ld      h,b
    ld      l,c
    call    _update_polygon
    pop     hl

    ; if update left 0 in accumulator we deactive the polygon
    cp      0
    jr      nz,.update_momentum

.disable:
    ; back to active flag
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    push    hl
    call    polygon_destroy
    pop     hl
    ret

    ; update sprite position --------------------------------------------------
.update_momentum:

    ; b = my
    ldxa    [hli],[polygonMY]
    ld      b,a

    ; c = mx
    ldxa    [hli],[polygonMX]
    ld      c,a

    ; py += dy.my
    ld      d,[hl]
    addFixedSigned(polygonY, d, b, 160)
    ldxa    [hli],d; store updated dy

    ; px += dx.mx
    ld      d,[hl]
    addFixedSigned(polygonX, d, c, 176)
    ldxa    [hli],d; store updated dx

    ; TODO run collision detection only when changed

.update_sprite:

    ; load half size
    ld      a,[hli]
    ld      d,a
    ld      [polygonHalfSize],a

    ; update sprite position
    ldxa    [hli],[polygonY]

    ; offset for sprite rendering
    sub     d
    add     16
    sub     SCROLL_BORDER
    ld      b,a

    ldxa    [hli],[polygonX]

    ; offset for sprite rendering
    sub     d
    add     8
    sub     SCROLL_BORDER
    ld      c,a

    ; update sprites
    push    hl
    inc     hl; skip over rotation angle
    ld      a,[hli]; load size
    ld      [polygonSize],a
    ld      d,a
    ld      a,[hl]; load sprite index

    ; setup sprite base
    ld      h,$C0
    add     a; x2
    add     a; x4
    ld      l,a;

.one:
    ; set y 0,0
    ldxa    [hli],b

    ; set x 0,0
    ldxa    [hli],c

    ; one complete
    ld      a,d
    cp      0
    jr      z,.compare_rotation
    inc     l
    inc     l

.two:
    ; set y 1,0
    ldxa    [hli],b

    ; set x 1,0
    ld      a,c
    add     8
    ld      [hli],a

    ; two complete
    ld      a,d
    cp      $10
    jr      z,.compare_rotation
    inc     l
    inc     l

.three:
    ld      a,d
    cp      $30
    jr      z,.four

    ; set y 2,0
    ldxa    [hli],b

    ; set x 2,0
    ld      a,c
    add     16
    ld      [hli],a
    inc     l
    inc     l

    ; set y 0,1
    ld      a,b
    add     16
    ld      b,a
    ld      [hli],a

    ; set x 0,1
    ld      a,c
    ld      [hli],a
    inc     l
    inc     l

    ; set y 1,1
    ldxa    [hli],b

    ; set x 1,1
    ld      a,c
    add     8
    ld      [hli],a
    inc     l
    inc     l

    ; set y 2,1
    ldxa    [hli],b

    ; set x 2,1
    ld      a,c
    add     16
    ld      [hl],a
    jr      .compare_rotation

.four:
    ; set y 2,0
    ldxa    [hli],b

    ; set x 2,0
    ld      a,c
    add     16
    ld      [hli],a
    inc     l
    inc     l

    ; set y 3,0
    ldxa    [hli],b

    ; set x 3,0
    ld      a,c
    add     24
    ld      [hli],a
    inc     l
    inc     l

    ; set y 0,1
    ld      a,b
    add     16
    ld      b,a
    ld      [hli],a

    ; set x 0,1
    ld      a,c
    ld      [hli],a
    inc     l
    inc     l

    ; set y 1,1
    ldxa    [hli],b

    ; set x 1,1
    ld      a,c
    add     8
    ld      [hli],a
    inc     l
    inc     l

    ; set y 2,1
    ldxa    [hli],b

    ; set x 2,1
    ld      a,c
    add     16
    ld      [hli],a
    inc     l
    inc     l

    ; set y 3,1
    ldxa    [hli],b

    ; set x 3,1
    ld      a,c
    add     24
    ld      [hl],a

.compare_rotation:
    pop     hl

    ; Compare angles
    ld      a,[polygonRotation]
    ld      d,a; store poly rotation
    ld      [hli],a
    ld      b,a
    inc     hl; skip over size
    inc     hl; skip over sprite index
    ld      a,[hl]; load old rotation
    cp      b
    ret     z

    ; update old angle with new angle
    ld      a,d
    ld      [hli],a

    push    de
    ld      a,[hli]; load spritecount
    ld      d,a

    ; load source in offscreen buffer
    ldxa    [polygonOffset + 1],[hli]
    ld      e,a
    ldxa    [polygonOffset],[hli]

    ; prepare to clear offscreen buffer
    push    hl
    ld      h,a
    ld      l,e
    xor     a; clear

.clear:
    ld      [hli],a
    inc     l
    ld      [hli],a
    inc     l
    ld      [hli],a
    inc     l
    ld      [hli],a
    inc     l
    ld      [hli],a
    inc     l
    ld      [hli],a
    inc     l
    ld      [hli],a
    inc     l
    ld      [hli],a
    inc     hl
    dec     d
    jr      nz,.clear

    pop     hl
    pop     de

    ; load polygon data pointer into de
    ld      a,[hli]
    ld      l,[hl]
    ld      h,a

    ; first point
    ld      a,d; restore poly rotation
    add     [hl]
    inc     hl
    ld      d,a
    ldxa    e,[hli]

    push    hl
    call    angle_offset; d = angle, e = length
    pop     hl

.loop:
    ; next point
    ld      a,[polygonRotation]
    add     [hl]
    inc     hl
    ld      d,a
    ldxa    e,[hli]

    ; check for end marker
    cp      $ff
    ret     z

    ; store data pointer
    push    hl

    ; store previous point
    ld      h,b
    ld      l,c

    push    hl
    ; calculate current point
    call    angle_offset; d = angle, e = length
    pop     de

    push    bc
    call    line_two
    pop     bc

    ; restore data pointer
    pop     hl
    jr      .loop

_update_polygon:
    jp      [hl]


polygon_destroy:

    ; disable active flag
    res     7,[hl]

    ; skip over other attributes
    addw    hl,12

    ; load sprite size
    ld      a,[hli]
    ld      d,a
    ld      a,[hli]; load sprite index
    ld      e,a
    addw    hl,6

    ; check collision pointer
    ld      a,[hl]
    cp      $ff
    jr      z,.no_collision

    ; store and reset pointer
    ld      b,a
    ld      a,$ff
    ld      [hl],a

    ; reset collision slot
    ld      a,b
    add     a; x2
    add     a; x4
    add     a; x8
    add     a; x16
    add     a; x32
    ld      c,a
    ld      b,polygonCollisionGroups >> 8
    ld      a,$ff
    ld      [bc],a

    ; setup sprite base
.no_collision:
    ld      h,$C0
    ld      a,e
    add     a; x2
    add     a; x4
    ld      l,a;

    ; move sprites off screen
    xor     a
.one:
    ; set y 0,0
    ld      [hli],a

    ; set x 0,0
    ld      [hli],a

    ; one complete
    ld      a,d
    cp      0
    ret     z

    inc     l
    inc     l

.two:
    ; set y 1,0
    xor     a
    ld      [hli],a

    ; set x 1,0
    ld      [hli],a

    ; two complete
    ld      a,d
    cp      $10
    ret     z

    inc     l
    inc     l

.three:
    ld      a,d
    cp      $30
    jr      z,.four

    ; set y 2,0
    xor     a
    ld      [hli],a

    ; set x 2,0
    ld      [hli],a
    inc     l
    inc     l

    ; set y 0,1
    ld      [hli],a

    ; set x 0,1
    ld      [hli],a
    inc     l
    inc     l

    ; set y 1,1
    ld      [hli],a

    ; set x 1,1
    ld      [hli],a
    inc     l
    inc     l

    ; set y 2,1
    ld      [hli],a

    ; set x 2,1
    ld      [hl],a
    ret

.four:
    ; set y 2,0
    xor     a
    ld      [hli],a

    ; set x 2,0
    ld      [hli],a
    inc     l
    inc     l

    ; set y 3,0
    ld      [hli],a

    ; set x 3,0
    ld      [hli],a
    inc     l
    inc     l

    ; set y 0,1
    ld      [hli],a

    ; set x 0,1
    ld      [hli],a
    inc     l
    inc     l

    ; set y 1,1
    ld      [hli],a

    ; set x 1,1
    ld      [hli],a
    inc     l
    inc     l

    ; set y 2,1
    ld      [hli],a

    ; set x 2,1
    ld      [hli],a
    inc     l
    inc     l

    ; set y 3,1
    ld      [hli],a
    ld      [hl],a
    ret


polygon_draw:
    ; wait for hardware DMA to complete
    ld      a,[rHDMA5]
    and     %1000_0000
    ret     z

    ; source
    ld      a,polygonOffscreenBuffer >> 8
    ld      [rHDMA1],a
    xor     a
    ld      [rHDMA2],a

    ; target
    ld      a,$88
    ld      [rHDMA3],a
    xor     a
    ld      [rHDMA4],a
    ld      a,%0100_1111
    ld      [rHDMA5],a
    ret

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
    DB      $00; Index
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
    DW      $C400; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C440; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C480; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 2x2
    DB      %0000_0010; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C4C0; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 1
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C500; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 2
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C520; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 3
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C540; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 4
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C560; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 5
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C580; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 6
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C5A0; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 7
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C5C0; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 8
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C5E0; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 9
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C600; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 10
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C620; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 11
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C640; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 1x1 12
    DB      %0000_0001; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C660; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 3x3
    DB      %0000_0011; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C680; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 3x3
    DB      %0000_0011; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C740; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; 4x4
    DB      %0000_0100; active / size
    DW      $ffff; Update routine
    DB      $00; Index
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
    DW      $C800; Tilevram Offset
    DW      $FFFF; Polygon data
    DB      $FF; Collision Index

    ; end marker
    DB      $ff

; TODO fix indexing with macros defined above their invocation point
MACRO addFixedSigned(@major, @minor, @increase, @max)
add_fixed_signed:
    ; check if increase is positive or negative
    ld      a,128
    cp      @increase
    jr      c,.negative

.positive:
    sla     @increase
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.done

    ; minor overflowed so increase major
    ld      a,[@major]
    inc     a
    inc     a

    ; check if > @max
    cp      @max
    jr      c,.positive_no_wrap
    add     256 - @max; wrap over to 0

.positive_no_wrap:
    ld      [@major],a
    jr      .done

.negative:
    ; invert
    ld      a,@increase
    cpl
    inc     a
    ld      @increase,a
    sla     @increase

    ; subtract
    ld      a,@minor
    sub     @increase
    ld      @minor,a
    sub     128
    jr      nc,.done

    ; minor underflowd so decrease major
    ld      a,[@major]
    dec     a
    dec     a

    ; check if > @max
    cp      @max
    jr      c,.negative_no_wrap
    sub     256 - @max; wrap over to 176

.negative_no_wrap:
    ld      [@major],a
    jr      .done
.done:
ENDMACRO

