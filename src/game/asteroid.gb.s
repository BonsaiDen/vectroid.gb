SECTION "AsteroidLogic",ROM0

; Asteroid Logic --------------------------------------------------------------
asteroid_update:
    ld      a,[polygonDataB]
    cp      0
    jr      z,.destroy

    ld      a,[polygonDataA]
    and     %0000_0111
    ld      b,a
    ld      a,[coreLoopCounter]
    cp      b
    jr      nz,.skip

    ld      a,[polygonDataA]
    ld      b,a
    ld      a,[polygonRotation]
    add     b
    ld      [polygonRotation],a

.skip:
    ld      a,1
    ret

.destroy:
    call    _asteroid_split
    jr      nc,.skip
    xor     a
    ret


_asteroid_split:; return 0 if actually split up

    ; TODO randomize split velocity
    ; TODO calculate angle at +90 degrees and -90 degrees
        ; TODO +75/-75 instead?
        ; TODO or within range?

    ld      a,[polygonHalfSize]
    cp      $04
    jr      z,.small
    cp      $08
    jr      z,.medium
    cp      $0C
    jr      z,.large

.giant:; 32x32
    ; split into large and medium
    ld      a,POLYGON_LARGE
    ld      b,1
    call    polygon_available
    jr      nc,.giant_or

    ld      a,POLYGON_MEDIUM
    ld      b,1
    call    polygon_available
    jr      nc,.giant_or

    ; TODO
    scf
    ret

    ; or
.giant_or:
    ; split into 2 medium and 1 small
    ld      a,POLYGON_MEDIUM
    ld      b,2
    call    polygon_available
    ret     nc

    ld      a,POLYGON_SMALL
    ld      b,1
    call    polygon_available
    ret     nc

    ; TODO
    scf
    ret

.large:; 24x24
    ; split into two medium
    ld      a,POLYGON_MEDIUM
    ld      b,2
    call    polygon_available
    jr      nc,.large_or

    ; TODO
    scf
    ret

.large_or:
    ; split into medium and small
    ld      a,POLYGON_SMALL
    ld      b,1
    call    polygon_available
    ret     nc

    ld      a,POLYGON_MEDIUM
    ld      b,1
    call    polygon_available
    ret     nc

    ; TODO
    scf
    ret

.medium: ; 16x16
    ; split into two small
    ld      a,POLYGON_SMALL
    ld      b,2
    call    polygon_available
    ret     nc

    ld      a,[polygonRotation]
    add     64
    ld      b,POLYGON_SMALL
    ld      c,4; TODO way to low?
    ld      e,8
    call    _asteroid_create

    sub     128
    call    _asteroid_create

    scf
    ret

.small: ;8x8
    ; no split
    scf
    ret


_asteroid_create:; a = rotation, b=size, c = velocity, e = distance
    push    af
    push    bc
    push    de

    ; store rotation
    ld      d,a

    ; setup next pointer
    ld      hl,asteroidQueue
    ld      a,[asteroidQueueCount]
    mul     a,8
    add     l
    ld      l,a

    ; DB size
    ; DB palette
    ; DB rotation speed
    ; DB rotation
    ; DB x
    ; DB y
    ; DB mx
    ; DB my

    ; TODO get pointer into asteroid queue

    ; TODO set size

    ; TODO set palette

    ; TODO set random rotation
    call    math_random

    ; TODO set random rotation speed
    call    math_random_signed


    ; calculate offset from position
    push    bc
    call    angle_vector_16

    ; add to position of parent asteroid
    ld      a,[polygonX]
    add     b
    ; TODO set x

    ld      a,[polygonY]
    add     c
    ; TODO set y
    pop     bc

    ; set mx/my from rotation and velocity
    ld      e,c
    call    angle_vector_16
    ; TODO set mx/my

    ; increase queue count
    ld      a,[asteroidQueueCount]
    inc     a
    ld      [asteroidQueueCount],a

    pop     de
    pop     bc
    pop     af
    ret


; Asteroid Layout -------------------------------------------------------------
small_asteroid_polygon:
    DB      0; angle
    DB      3; length
    DB      32
    DB      2; length
    DB      96
    DB      3; length
    DB      156
    DB      2; length
    DB      220
    DB      3; length
    DB      0; angle
    DB      3; length
    DB      $ff,$ff

medium_asteroid_polygon:
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

large_asteroid_polygon:
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

giant_asteroid_polygon:
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

