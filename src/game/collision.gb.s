SECTION "CollisionLogic",ROM0

collision_init:
    ld      hl,polygon_collision_base
    ld      de,polygonCollisionGroups
    ld      bc,POLYGON_COLLISION_BYTES
    call    core_mem_cpy
    ret

collide_with_asteroid:; polygonX, polygonY = x/y, c = collision distance offset, d = group -> a=0 no collision, a=1 collision, de=data pointer of collided polygon
    ld      hl,polygonCollisionGroups
    ldxa    [polygonOffset],c
.loop:
    ld      a,[hli]
    cp      $ff
    jr      z,.inactive

    ; check for end of collision group
    cp      0
    ret     z

    push    hl

    ; load data pointer
    ld      d,[hl]
    inc     l
    ld      e,[hl]
    push    de

    ; load position from data pointer
    ld      a,[de]; half size
    ld      l,a
    inc     e

    ld      a,[de]; y
    ld      c,a
    inc     e

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
    pop     hl

.inactive:
    inc     l
    inc     l
    inc     l
    jr      .loop

.collision:
    pop     de; restore data pointer
    pop     hl
    ld      a,1
    ret

collide_asteroid_placement:; polygonX, polygonY = x/y, c = collision distance offset, d = group -> a=0 no collision, a=1 collision, de=data pointer of collided polygon
    ; TODO if this is too small then in some cases split asteroids might collide instantly with one another
    ; TODO 7 seems to be the absolute minimum
    ld      c,7; TODO adjust for different half-sizes?
    call    collide_with_asteroid
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
    dec     e
    dec     e
    dec     e
    dec     e
    dec     e
    dec     e
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

