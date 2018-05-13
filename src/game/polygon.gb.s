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

; _polygon_available:; a = size, b = count -> carry if available
;     ld      [polygonSize],a
;     ld      hl,polygonState
;
; .loop:
;     ld      a,$ff
;     cp      [hl]; check for end marker
;     jp      z,.all_in_use
;
;     ; check for size match
;     ld      a,[polygonSize]
;     cp      [hl]
;     jp      nz,.used_or_other_size
;
;     ; decrement required
;     dec     b
;     jr      nz,.used_or_other_size
;
;     ; return available if required count is available
;     scf
;     ret
;
;     ; skip bytes
; .used_or_other_size:
;     addw    hl,POLYGON_BYTES
;     jp      .loop
;
; .all_in_use:
;     ccf
;     ret

    ; set polygonX, polygonY, polygonGroup, polygonRotation, polygonMX, polygonMY, polygonData first
polygon_create:; a = size, bc = update, de = data pointer -> a=1 created, a=no size spot available

    ld      [polygonSize],a
    ld      hl,polygonState

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
    ldxa    [hli],b
    ldxa    [hli],c

    ; data values
    ld      a,[polygonDataA]
    ld      [hli],a

    ld      a,[polygonDataB]
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
    ldxa    [hli],[polygonRotation]

    ; setup palette
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

    ; set old rotation to a different value to force initial update
    ld      a,[polygonRotation]
    inc     a
    ldxa    [hli],c

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

    push    hl

    ; load data vlaues
    ldxa    [polygonDataA],[hli]
    ldxa    [polygonDataB],[hli]

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

    ; if update left 0 in accumulator we deactive the polygon
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

    ; re-assign data so it can be used as a counter etc.
    ldxa    [hli],[polygonDataA]
    ldxa    [hli],[polygonDataB]

    ; b = my
    ldxa    [hli],[polygonMY]
    ld      b,a

    ; c = mx
    ldxa    [hli],[polygonMX]
    ld      c,a

    ; py += dy.my
    ld      d,[hl]
    push    hl
    addFixedSigned(polygonY, d, b, 176)
    addFixedSigned(polygonY, d, b, 176)
    addFixedSigned(polygonY, d, b, 176)
    addFixedSigned(polygonY, d, b, 176)
    pop     hl
    ldxa    [hli],d; store updated dy

    ; px += dx.mx
    ld      d,[hl]
    push    hl
    addFixedSigned(polygonX, d, c, 192)
    addFixedSigned(polygonX, d, c, 192)
    addFixedSigned(polygonX, d, c, 192)
    addFixedSigned(polygonX, d, c, 192)
    pop     hl
    ldxa    [hli],d; store updated dx

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


; Polygon Destroy -------------------------------------------------------------
polygon_destroy:

    ; disable active flag
    res     7,[hl]

    ; skip over other attributes
    addw    hl,13

    ; load sprite size
    ld      a,[hli]
    ld      d,a
    ld      a,[hli]; load sprite index
    ld      e,a
    addw    hl,6

    ; check collision pointer
    ;brk
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
    ;add     a; x8
    ;add     a; x16
    ;add     a; x32
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

    ; add priority bit
    ld      a,b
    or      %1000_0000
    ld      b,a

    ; setup sprite base
.no_collision:
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


; TODO fix indexing with macros defined above their invocation point
; TODO optimize
MACRO addFixedSigned(@major, @minor, @increase, @max)
add_fixed_signed:

    ; TODO we currently don't clear @minor in case the direction changed
    ld      l,@increase

    ; ignore if zero
    xor     a
    cp      @increase
    jr      z,.done

    ; check if increase is positive or negative
    ld      a,128
    cp      @increase
    jr      c,.negative

.positive:
    ; double speed so we get more "range" even though we only use 0-128 for M?
    sla     @increase
    sla     @increase
    ;sla     @increase

    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.done

    ; minor overflowed so increase major
    ld      a,[@major]
    inc     a
    ;inc     a TODO allow for higher speeds

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
    ; double speed so we get more "range" even though we only use 0-128 for M?
    sla     @increase
    sla     @increase
    ;sla     @increase

    ; subtract
    ld      a,@minor
    add     @increase
    ld      @minor,a
    jr      nc,.done

    ; minor underflowd so decrease major
    ld      a,[@major]
    dec     a
    ;dec     a TODO allow for higher speeds

    ; check if > @max
    cp      @max
    jr      c,.negative_no_wrap
    sub     256 - @max; wrap over to 176

.negative_no_wrap:
    ld      [@major],a
    jr      .done
.done:
    ld      @increase,l
ENDMACRO

