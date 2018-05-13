SECTION "AsteroidLogic",ROM0

; Asteroid Logic --------------------------------------------------------------
asteroid_init:
    ldxa    [asteroidSmallAvailable],6
    ldxa    [asteroidMediumAvailable],2
    ldxa    [asteroidLargeAvailable],2
    ldxa    [asteroidQueueLength],0
    ret

asteroid_queue:
    ld      a,[asteroidQueueLength]
    cp      0
    ret     z
    ld      b,a; loop counter

    ld      a,[asteroidQueueDelay]
    dec     a
    ld      [asteroidQueueDelay],a
    cp      0
    ret     nz

    ld      hl,asteroidQueue
.next:
    push    bc

    ; configurable data
    ldxa    [polygonSize],[hli]
    ldxa    [polygonPalette],[hli]
    ldxa    [polygonDataA],[hli]
    ldxa    [polygonRotation],[hli]
    ldxa    [polygonX],[hli]
    ldxa    [polygonY],[hli]
    ldxa    [polygonMX],[hli]
    ldxa    [polygonMY],[hli]

    ; non-configurable data
    ldxa    [polygonGroup],COLLISION_ASTEROID

    push    hl

    ; load polygon hp
    ld      a,[polygonSize]
    dec     a
    ld      hl,_polygon_hp
    addw    hl,a
    ld      a,[hl]
    ld      [polygonDataB],a

    ; load polygon data for size
    ld      a,[polygonSize]
    dec     a
    add     a; x2
    ld      hl,_polygon_sizes
    addw    hl,a
    ld      a,[hli]
    ld      e,a
    ld      d,[hl]

    ld      bc,asteroid_update
    ld      a,[polygonSize]
    call    polygon_create

    pop     hl

    pop     bc
    dec     b
    jr      nz,.next

    xor     a
    ld      [asteroidQueueLength],a
    ret

asteroid_update:
    ld      a,[polygonDataB]
    cp      0
    jr      z,.destroy
    cp      128
    jr      nc,.destroy_collide

    ; only collide every other frame
    ld      a,[coreLoopCounter]
    and     %0000_0001
    jr      z,.rotate

    ; collide with other asteroids
    ld      d,COLLISION_ASTEROID
    ld      c,3
    call    collide_with_group
    cp      0
    jr      z,.rotate

    ; move de to size of other asteroid
    ld      a,[polygonSize]
    ld      b,a; current size
    inc     de
    inc     de
    inc     de
    inc     de
    ld      a,[de]; other size

    ; compare sizes
    cp      b
    ; ==
    jr      z,.destroy_both_asteroids
    ; <
    jr      nc,.destroy_this_asteroid
    ; >
    jr      .destroy_other_asteroid

    ; rotate asteroid
.rotate:
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

.ignore:
    ; avoid continoues split calls by restoring 1 hp to the asteroid
    ld      a,1
    ld      [polygonDataB],a
    ret

.destroy_other_asteroid:
    call    _destroy_other_asteroid
    ld      a,1
    ret

.destroy_both_asteroids:
    call    _destroy_other_asteroid

.destroy_this_asteroid:
    ld      a,$ff
    ld      [polygonDataB],a
    ld      a,1
    ret

.destroy:
    call    _asteroid_split
    jr      c,.ignore
    jr      .destroyed

.destroy_collide:
    call    _asteroid_split
    ; we can't ignore the destruction here and will just skip the creation
    ; of new asteroids

    ; increase available counter
.destroyed:
    ld      a,[polygonHalfSize]
    cp      $04
    jr      nz,.medium
    incx    [asteroidSmallAvailable]
    jr      .none

.medium:
    cp      $08
    jr      nz,.large
    incx    [asteroidMediumAvailable]
    jr      .none

.large:
    cp      $0C
    jr      nz,.none
    incx    [asteroidLargeAvailable]

.none:
    xor     a
    ret


_destroy_other_asteroid:
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de; hp
    ld      a,$ff
    ld      [de],a
    ret

_asteroid_split:; return 0 if actually split up
    ld      a,[polygonHalfSize]
    cp      $04
    jr      z,.small
    cp      $08
    jp      z,.medium
    cp      $0C
    jr      z,.large
    jr      .giant

.small: ;8x8
    ; no split
    xor     a
    ret

.giant:; 32x32

    ; split into 1x large and 1x medium
    ld      a,[asteroidLargeAvailable]
    cp      1
    jr      c,.giant_or

    ld      a,[asteroidMediumAvailable]
    cp      1
    jr      c,.giant_or

    decx    [asteroidLargeAvailable]
    decx    [asteroidMediumAvailable]

    ; create new asteroids
    ; TODO randomize things a bit
    call    _direction_vector
    add     ASTEROID_SPLIT_OFFSET
    ld      b,POLYGON_LARGE
    ld      c,ASTEROID_SPLIT_VELOCITY_LARGE
    ld      e,ASTEROID_SPLIT_DISTANCE_LARGE
    call    asteroid_create

    ld      a,d
    sub     ASTEROID_SPLIT_OFFSET
    ld      c,ASTEROID_SPLIT_VELOCITY_MEDIUM
    ld      e,ASTEROID_SPLIT_DISTANCE_MEDIUM
    ld      b,POLYGON_MEDIUM
    call    asteroid_create
    xor     a
    ret

    ; or
.giant_or:
    scf
    ret

    ; TODO setup

    ; split into 2x medium and 1x small
    ld      a,[asteroidMediumAvailable]
    cp      2
    ret     c

    ld      a,[asteroidSmallAvailable]
    cp      1
    ret     c

    decx    [asteroidMediumAvailable]
    decx    [asteroidMediumAvailable]
    decx    [asteroidSmallAvailable]

    ; TODO create asteroids
    xor     a
    ret

.large:; 24x24

    ; split into 2x medium
    ld      a,[asteroidMediumAvailable]
    cp      2
    jr      c,.large_or

    decx    [asteroidMediumAvailable]
    decx    [asteroidMediumAvailable]

    ; create new asteroids
    ; TODO randomize things a bit
    call    _direction_vector
    add     ASTEROID_SPLIT_OFFSET
    ld      b,POLYGON_MEDIUM
    ld      c,ASTEROID_SPLIT_VELOCITY_MEDIUM
    ld      e,ASTEROID_SPLIT_DISTANCE_MEDIUM
    ;call    asteroid_create

    ld      a,d
    sub     ASTEROID_SPLIT_OFFSET
    ld      b,POLYGON_MEDIUM
    call    asteroid_create
    xor     a
    ret

.large_or:
    ; split into 1x medium and 1x small
    ld      a,[asteroidMediumAvailable]
    cp      1
    ret     c

    ld      a,[asteroidSmallAvailable]
    cp      1
    ret     c

    decx    [asteroidMediumAvailable]
    decx    [asteroidSmallAvailable]

    ; create new asteroids
    ; TODO randomize things a bit
    call    _direction_vector
    add     ASTEROID_SPLIT_OFFSET
    ld      b,POLYGON_MEDIUM
    ld      c,ASTEROID_SPLIT_VELOCITY_MEDIUM
    ld      e,ASTEROID_SPLIT_DISTANCE_MEDIUM
    call    asteroid_create

    ld      a,d
    sub     ASTEROID_SPLIT_OFFSET
    ld      c,ASTEROID_SPLIT_VELOCITY_SMALL
    ld      e,ASTEROID_SPLIT_DISTANCE_SMALL
    ld      b,POLYGON_SMALL
    call    asteroid_create
    xor     a
    ret

.medium: ; 16x16
    ; split into 2x small
    ld      a,[asteroidSmallAvailable]
    cp      2
    ret     c

    decx    [asteroidSmallAvailable]
    decx    [asteroidSmallAvailable]

    ; create new asteroids
    ; TODO randomize things a bit
    call    _direction_vector
    add     ASTEROID_SPLIT_OFFSET
    ld      b,POLYGON_SMALL
    ld      c,ASTEROID_SPLIT_VELOCITY_SMALL
    ld      e,ASTEROID_SPLIT_DISTANCE_SMALL
    call    asteroid_create

    ld      a,d
    sub     ASTEROID_SPLIT_OFFSET
    ld      b,POLYGON_SMALL
    call    asteroid_create
    xor     a
    ret

_direction_vector:
    ldxa    b,[polygonMX]
    ldxa    c,[polygonMY]
    call    atan_2
    ld      d,a
    ret

; polygonX, polygonY must be set as the reference position
asteroid_create:; a = rotation, b=size, c = velocity, e = distance
    push    af
    push    bc
    push    de

    ; store rotation
    ld      d,a

    ; get pointer into queue
    ld      hl,asteroidQueue
    ld      a,[asteroidQueueLength]
    mul     a,8
    add     l
    ld      l,a

    push    bc

    ; Set Size
    ldxa    [hli],b

    ; Set palette
    ; TODO make configurable
    ldxa    [hli],PALETTE_ASTEROID

    ; Set random rotation speed
    call    math_random_signed
    cp      0
    jr      nz,.rotation
    call    math_random_signed

.rotation:
    ld      [hli],a

    ; Set random rotation
    call    math_random
    ld      [hli],a

    ; calculate offset from position
    push    hl
    call    angle_vector_16
    pop     hl

    ; add to position of parent asteroid
    ld      a,[polygonX]
    add     b
    ld      [hli],a

    ld      a,[polygonY]
    add     c
    ld      [hli],a
    pop     bc

    ; set mx/my from rotation and velocity
    ld      e,c
    push    hl
    call    angle_vector_16
    pop     hl
    ldxa    [hli],b
    ld      [hl],c

    ; increase queue count
    ld      a,[asteroidQueueLength]
    inc     a
    ld      [asteroidQueueLength],a

    ld      a,ASTEROID_QUEUE_DELAY
    ld      [asteroidQueueDelay],a

    pop     de
    pop     bc
    pop     af
    ret


; Asteroid Layout -------------------------------------------------------------
_polygon_sizes:
    DW      small_asteroid_polygon
    DW      medium_asteroid_polygon
    DW      large_asteroid_polygon
    DW      giant_asteroid_polygon

_polygon_hp:
    DB      2
    DB      8
    DB      15
    DB      40

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

