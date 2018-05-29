SECTION "CollisionLogic",ROM0

collide_with_group:; polygonX, polygonY = x/y, c = collision distance offset, d = group -> a=0 no collision, a=1 collision, de=data pointer of collided polygon

    ; TODO optimize
    ; get start pointer of collision group
    ld      a,d
    add     a; x2
    add     a; x4
    add     a; x8
    add     a; x16
    add     a; x32
    add     a; x64
    ld      l,a
    ld      h,polygonCollisionGroups >> 8

    ldxa    [polygonOffset],c

    ; max of 8 entries in the group
    ld      b,16
.loop:
    ld      a,[hli]
    cp      $ff
    jr      z,.inactive

    push    hl
    push    bc

    ; load data pointer
    ld      d,[hl]
    inc     l
    ld      e,[hl]
    push    de

    ; load position from pointer
    ld      a,[de]; half size
    ld      l,a
    inc     de

    ld      a,[de]; y
    ld      c,a
    inc     de

    ld      a,[de]; x
    ld      b,a

    ; store half size
    ld      e,l

    ; get distance between bc/de into bc
    ld      a,[polygonX]
    sub     b
    ld      b,a

    ld      a,[polygonY]
    sub     c
    ld      c,a

    ; check if distance is 0
    ; (if so we assume that we're checking against the same polygon and skip it)
    cp      0; check y for 0 distance
    jr      nz,.check_distance

    ld      a,b ; check x for 0 distance
    cp      0
    jr      z,.no_collision

    ; calculate distance
.check_distance:
    call    sqrt_length
    cp      SQRT_MAX_DISTANCE; exit if maximum distance
    jr      z,.no_collision
    ld      c,a; store distance

    ; load distance offset
    ld      a,[polygonOffset]
    ld      d,a

    ld      a,[polygonHalfSize]
    add     e; a is now the combine half size

    ; ajust collision distance with offset
    sub     d

    ; distance < collisionSizeA + collisionSizeB - 4
    cp      c; compare with distance
    jr      nc,.collision

    ; restore pointers
.no_collision:
    pop     de
    pop     bc
    pop     hl

.inactive:
    inc     l
    inc     l
    inc     l

.next:
    dec     b
    jr      nz,.loop

    xor     a
    ret

.collision:
    pop     de; restore data pointer
    pop     bc
    pop     hl
    ld      a,1
    ret

collide_asteroid_placement:; polygonX, polygonY = x/y, c = collision distance offset, d = group -> a=0 no collision, a=1 collision, de=data pointer of collided polygon
    ld      d,COLLISION_ASTEROID
    ; TODO if this is too small then in some cases split asteroids might collide instantly with one another
    ld      c,7; TODO adjust for different half-sizes?
    call    collide_with_group
    cp      0
    jr      z,.no_collision

.avoid:
    ; compare size and ignore the collision if the other asteroid is either
    ; smaller or the same size as ours (meaning we still place the new asteroid)
    push    hl
    dec     hl
    ld      a,[hli]
    and     %0111_1111
    ld      c,a
    ld      a,[polygonSize]
    cp      c
    jr      nc,.ignore; ignore polygons <= the current size

    ; also ignore the collision in case the other asteroid is already destroyed
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de
    ld      a,[de]
    cp      128
    jr      nc,.ignore
    pop     hl

    ; if the other asteroid is still alive and bigger than out asteroid
    ; there's no need to place our one since it would get destroyed immediately
    ; after placement
    ld      a,1
    ret

.ignore:
    pop     hl

.no_collision:
    xor     a
    ret

