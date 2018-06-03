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

polygon_disable_type:; de = update pointer to disable
    ld      hl,polygonState

.loop:
    ld      a,$ff
    cp      [hl]; check for end marker
    ret     z

    inc     hl

    ; load update pointer
    ld      b,[hl]
    inc     hl
    ld      c,[hl]

    ; back to active flag
    dec     hl
    dec     hl

    ; compare update routine
    ld      a,b
    cp      d
    jr      nz,.skip
    ld      a,c
    cp      e
    jr      nz,.skip

    push    hl
    push    de
    call    polygon_destroy
    pop     de
    pop     hl

    ; skip bytes
.skip:
    addw    hl,POLYGON_BYTES
    jp      .loop

    ; set polygonX, polygonY, polygonGroup, polygonRotation, polygonMX, polygonMY, polygonData first
polygon_create:; a = size, bc = update, de = data pointer -> a=1 created, a=no size spot available

    ld      [polygonSize],a
    ld      hl,polygonState

    ; redraw flag
    xor     a
    ld      [polygonChanged],a

    ; find unused polygon of the desired size
.loop:
    ld      a,$ff
    cp      [hl]; check for end marker
    jp      z,.all_in_use

    ; check for size match
    ld      a,[polygonSize]
    cp      [hl]
    jp      nz,.used_or_other_size

    or      %1000_0000; set active flag
    ld      [hli],a

    ; set update routine
    ld      a,[hl]
    cp      b
    jr      z,.hi_unchanged

    ld      a,1
    ld      [polygonChanged],a
    ldxa    [hli],b
    jr      .hi_changed

.hi_unchanged:
    inc     hl

.hi_changed:
    ld      a,[hl]
    cp      c
    jr      z,.lo_unchanged

    ld      a,1
    ld      [polygonChanged],a
    ldxa    [hli],c
    jr      .lo_changed

.lo_unchanged:
    inc     hl

.lo_changed:
    ; data values
    ld      a,[polygonDataA]
    ld      [hli],a

    ld      a,[polygonDataB]
    ld      [hli],a

    ; flags
    ld      a,[polygonFlags]
    ld      [hli],a

    ; reset momentum and delta
    ld      a,[polygonMY]
    ld      [hli],a

    ld      a,[polygonMX]
    ld      [hli],a
    xor     a
    ld      [hli],a
    ld      [hli],a

    ; store half-size pointer
    ld      b,h
    ld      c,l

    ; skip half width
    ld      a,[hli]
    ld      [polygonHalfSize],a

    ; set x
    ldxa    [hli],[polygonY]

    ; set y
    ldxa    [hli],[polygonX]

    ; set rotation
    ld      a,[polygonRotation]
    cp      [hl]
    jr      z,.rot_unchanged

    ld      a,1
    ld      [polygonChanged],a
    ldxa    [hli],[polygonRotation]
    jr      .rot_changed

.rot_unchanged:
    inc     hl

.rot_changed:

    ; update polygon data pointer
    push    hl
    addw    hl,7

    ; high byte
    ld      a,[hl]
    cp      d
    jr      z,.hi_up_unchanged
    ld      a,1
    ld      [polygonChanged],a
    ldxa    [hli],d
    jr      .hi_up_changed
.hi_up_unchanged:
    inc     hl
.hi_up_changed:

    ; low byte
    ld      a,[hl]
    cp      e
    jr      z,.lo_up_unchanged
    ld      a,1
    ld      [polygonChanged],a
    ld      [hl],e
.lo_up_unchanged:

    ; store point to polygon collision index
    inc     hl
    ld      d,h
    ld      e,l
    pop     hl

    ; setup sprite palette
    push    bc
    push    de
    ldxa    b,[polygonPalette]
    ldxa    d,[hli]
    ldxa    e,[hli]
    push    hl
    call    _set_sprite_palette
    pop     hl
    pop     de
    pop     bc

    ; set redraw flag
    ld      a,[polygonChanged]
    ld      [hli],a

    ; add to collision group
.collision:
    ld      a,[polygonGroup]
    cp      $ff; no collision
    jr      z,.no_collision

    ; 64 bytes per group (4x16)
    add     a; x2
    add     a; x4
    add     a; x8
    add     a; x16
    add     a; x32
    add     a; x64
    ld      l,a
    ld      h,polygonCollisionGroups >> 8

    ; FIXME This doesn't guard against overflow if more than 8 polygons are
    ; created per collision group
.next:
    ld      a,[hl]
    cp      $ff
    jr      nz,.collision_slot_in_used

    ; store size
    ldxa    [hli],[polygonSize]

    ; store data pointer
    ldxa    [hli],b
    ldxa    [hli],c

    ; store half size
    ld      a,[polygonHalfSize]
    ld      [hl],a

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
    jp      .loop

.all_in_use:
    xor     a
    ret


; Polygon Update --------------------------------------------------------------
polygon_update:

    ; update polygons
    ldxa    [polygonIndex],0
    ld      hl,polygonState

.loop:
    push    hl
    call    update_polygon
    pop     hl
    incx    [polygonIndex]

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

    push    hl

    ; load data values
    ldxa    [polygonDataA],[hli]
    ldxa    [polygonDataB],[hli]

    ; load flags
    ldxa    [polygonFlags],[hli]

    ; skip momentum and delta
    ldxa    [polygonMY],[hli]
    ldxa    [polygonMX],[hli]
    inc     hl; skip dy
    inc     hl; skip dx
    ldxa    [polygonHalfSize],[hli]
    ldxa    [polygonY],[hli]
    ldxa    [polygonX],[hli]
    ld      a,[hl]; load current rotation
    ld      [polygonRotation],a

    ; call update routine
    ld      h,b
    ld      l,c
    call    _update_polygon
    pop     hl

    ; if update left 0 in accumulator we deactivated the polygon
    cp      0
    jr      nz,.update_momentum

.disable:
    ; back to active flag
    dec     hl
    dec     hl
    dec     hl
    call    polygon_destroy
    ret

.update_momentum:
    cp      2
    jp      z,.stop_momentum

    ; re-assign data so it can be used as a counter etc.
    ldxa    [hli],[polygonDataA]
    ldxa    [hli],[polygonDataB]
    inc     hl

    ; b = my
    ldxa    [hli],[polygonMY]
    ld      b,a

    ; c = mx
    ldxa    [hli],[polygonMX]
    ld      c,a

    ; py += dy.my
    ld      d,[hl]
    push    hl
    ld      hl,polygonY
    addFixedSigned(d, b, 176, 177)
    pop     hl
    ldxa    [hli],d; store updated dy

    ; px += dx.mx
    ld      d,[hl]
    push    hl
    ld      hl,polygonX
    addFixedSigned(d, c, 192, 193)
    pop     hl
    ldxa    [hli],d; store updated dx
    jr      .update_sprite

.stop_momentum:
    ; re-assign data so it can be used as a counter etc.
    ldxa    [hli],[polygonDataA]
    ldxa    [hli],[polygonDataB]
    inc     hl

    ; reset mx/my/dx/dy
    xor     a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a
    ld      [hli],a

    ; TODO Only call when needed
    ; TODO the position update is ~900 cycles in the worst case
.update_sprite:

    ; load half size
    ld      a,[hli]
    ld      d,a
    ld      [polygonHalfSize],a

    ; update sprite position
    ldxa    c,[polygonOY]
    ldxa    [hli],[polygonY]

    ; offset for sprite rendering
    sub     d
    add     16
    sub     SCROLL_BORDER
    add     c
    ld      b,a

    ldxa    c,[polygonOX]
    ldxa    [hli],[polygonX]

    ; offset for sprite rendering
    sub     d
    add     8
    sub     SCROLL_BORDER
    add     c
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
    ld      d,a; store current polygon rotation
    ld      [hli],a
    inc     hl; skip over size
    inc     hl; skip over sprite index

    ; check for force redraw flag
    ld      a,[hli]; load redraw flag
    cp      1
    jr      z,.redraw

    ; check if rotation changed
    ld      a,[hl]
    cp      d
    ret     z

    ; update old angle with new angle
.redraw:
    ; store redraw flag pointer + 1
    push    hl

    ; store current rotation into old rotation
    ld      a,d
    ld      [hli],a

    ; load tile clear count
    ld      a,[hli]
    ld      b,a

    ; load source in offscreen buffer
    ldxa    [polygonOffset + 1],[hli]
    ld      c,a
    ldxa    [polygonOffset],[hli]

    ; prepare to clear offscreen buffer
    push    hl
    ld      h,a
    ld      l,c

    ; TODO optimize
    ; load base tile address
    ld      a,[hli]
    ld      h,[hl]
    ld      l,a

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
    dec     b
    jr      nz,.clear
    pop     hl

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

    ; TODO allow variant without offset
    ld      a,[polygonHalfSize]
    ld      b,a
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
    jr      z,.done

    ; store data pointer
    push    hl

    ; setup previous point for DE down below
    push    bc

    ; TODO allow variant without offset
    ld      a,[polygonHalfSize]
    ld      b,a

    ; calculate current point
    call    angle_offset; d = angle, e = length
    pop     de; get point that was set up

    push    bc
    call    line_two
    pop     bc

    ; restore data pointer
    pop     hl
    jr      .loop

.done:
    ; mark as changed
    pop     hl
    dec     hl
    ld      a,2
    ld      [hl],a
    ret

_update_polygon:
    jp      [hl]


; Polygon Destroy -------------------------------------------------------------
polygon_destroy:

    ; disable active flag
    res     7,[hl]

    ; skip over other attributes
    addw    hl,POLYGON_ATTR_BYTES

    ; load sprite size
    ld      a,[hli]
    ld      d,a
    ld      a,[hli]; load sprite index
    ld      e,a
    addw    hl,7

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
    ld      c,a
    ld      b,polygonCollisionGroups >> 8

    ; mark slot as unused
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

_set_sprite_palette:; b = palette index, d = sprite size, e = sprite index

    ; determine palette mode
    ld      a,[coreColorEnabled]
    cp      0
    jr      z,.dmg

    ; color gameboy
    ld      a,b
    and     %0000_1111
    or      %1000_0000
    ld      b,a
    jr      .init

.dmg:
    ld      a,b
    and     %0001_0000
    or      %1000_0000
    ld      b,a

    ; setup sprite base
.init:
    ld      h,$C0
    ld      a,e
    add     a; x2
    add     a; x4
    ld      l,a;

    ; set palette
.one:
    ld      a,b
    inc     l
    inc     l
    inc     l
    ld      [hli],a

    ; one complete
    ld      a,d
    cp      0
    ret     z

.two:
    ld      a,b
    inc     l
    inc     l
    inc     l
    ld      [hli],a

    ; two complete
    ld      a,d
    cp      $10
    ret     z

.three:
    ld      a,d
    cp      $30
    jr      z,.four

    ld      a,b
    inc     l
    inc     l
    inc     l
    ld      [hli],a

    inc     l
    inc     l
    inc     l
    ld      [hli],a

    inc     l
    inc     l
    inc     l
    ld      [hli],a

    inc     l
    inc     l
    inc     l
    ld      [hl],a
    ret

.four:
    ld      a,b
    inc     l
    inc     l
    inc     l
    ld      [hli],a

    inc     l
    inc     l
    inc     l
    ld      [hli],a

    inc     l
    inc     l
    inc     l
    ld      [hli],a

    inc     l
    inc     l
    inc     l
    ld      [hli],a

    inc     l
    inc     l
    inc     l
    ld      [hli],a

    inc     l
    inc     l
    inc     l
    ld      [hl],a
    ret


; Polygon Drawing -------------------------------------------------------------
polygon_draw:
    ld      a,[coreColorEnabled]
    cp      0
    jr      z,polygon_draw_dmg

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

    ; DMG support
polygon_draw_dmg:
    ldxa    [polygonIndex],0
    ld      hl,polygonState

.loop:
    ld      a,$ff
    cp      [hl]; check for end marker
    ret     z

    ; check if active
    push    hl
    ld      a,[hl]
    and     %1000_0000
    cp      0
    jp      z,.skip

    ; skip intermediate bytes
    addw    hl,16

    ; load redraw flag
    ld      a,[hl]
    cp      2
    jr      nz,.skip

    ; reset redraw flag
    xor     a
    ld      [hli],a
    inc     hl; skip old rotation

    ld      a,[hli]; load tile clear count
    ld      b,a

    ; load source in offscreen buffer
    ld      a,[hli]
    ld      e,a
    ld      a,[hl]
    ld      h,a
    ld      l,e
    ld      a,[hli]
    ld      h,[hl]
    ld      l,a

    ; calculate vram target
    ld      a,($8800 - polygonOffscreenBuffer) >> 8
    add     h
    ld      d,a
    ld      e,l

.copy:
    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4
    ld      a,[hli]
    ld      [de],a
    inc     l
    inc     e
    inc     e

    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4
    ld      a,[hli]
    ld      [de],a
    inc     l
    inc     e
    inc     e

    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4
    ld      a,[hli]
    ld      [de],a
    inc     l
    inc     e
    inc     e

    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4
    ld      a,[hli]
    ld      [de],a
    inc     l
    inc     e
    inc     e

    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4
    ld      a,[hli]
    ld      [de],a
    inc     l
    inc     e
    inc     e

    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4
    ld      a,[hli]
    ld      [de],a
    inc     l
    inc     e
    inc     e

.copy_4:
    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4
    ld      a,[hli]
    ld      [de],a
    inc     l
    inc     e
    inc     e

    ld      a,[rSTAT]       ; <---+
    and     STATF_BUSY      ;     |
    jr      nz,@-4
    ld      a,[hli]
    ld      [de],a
    inc     hl
    inc     e
    inc     de
    dec     b
    jr      nz,.copy

    ; skip bytes
.skip:
    pop     hl
    addw    hl,POLYGON_BYTES
    incx    [polygonIndex]
    jp      .loop
    ret

MACRO addFixedSigned(@minor, @increase, @max, @min)
add_fixed_signed:

    ; check if increase is positive or negative
    bit     7,@increase
    jr      nz,.negative

.positive:
    sla     @increase

.positive_one:
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.positive_two

    ; minor overflowed so increase major
    inc     [hl]

.positive_two:
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.positive_three

    ; minor overflowed so increase major
    inc     [hl]

.positive_three:
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.positive_four

    ; minor overflowed so increase major
    inc     [hl]

.positive_four:
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.positive_check

    ; minor overflowed so increase major
    inc     [hl]

    ; check if > @max
.positive_check:
    ld      a,[hl]
    cp      @max
    jr      c,.done
    add     256 - @max; wrap over to 0
    ld      [hl],a
    jr      .done

.negative:
    ; invert
    ld      a,@increase
    cpl
    inc     a
    ld      @increase,a
    sla     @increase

    ; subtract
.negative_one:
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.negative_two

    ; minor underflowd so decrease major
    dec     [hl]

.negative_two:
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.negative_three

    ; minor underflowd so decrease major
    dec     [hl]

.negative_three:
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.negative_four

    ; minor underflowd so decrease major
    dec     [hl]

.negative_four:
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.negative_check

    ; minor underflowed, so decrease major
    dec     [hl]

    ; check if < 0
.negative_check:
    ld      a,[hl]
    cp      @min
    jr      c,.done
    sub     256 - @max; wrap over to 176
    ld      [hl],a

.done:
ENDMACRO

MACRO createPolygon(@size, @group, @palette, @x, @y, @r, @data, @update)

    ; rotation speed stuff
    call    math_random_signed
    ld      [polygonDataA],a

    ; asteroid hp
    ld      a,8
    ld      [polygonDataB],a

    xor     a
    ld      [polygonFlags],a
    ld      [polygonMX],a
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

