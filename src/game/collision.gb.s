SECTION "CollisionLogic",ROM0

collide_with_group:; polygonX, polygonY = x/y, d = group -> a=0 no collision, a=1 collision, de=data pointer of collided polygon

    ; TODO optimize
    ; get start pointer of collision group
    ld      a,d
    add     a; x2
    add     a; x4
    add     a; x8
    add     a; x16
    add     a; x32
    ld      l,a
    ld      h,polygonCollisionGroups >> 8

    ; max of 8 entries in the group
    ld      b,8
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

    ; calculate distance
    call    sqrt_length
    ld      c,a; store distance
    ld      a,[polygonHalfSize]

    add     e; a is now the combine half size
    sub     5; TODO set collision size individually

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

