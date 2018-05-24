SECTION "AsteroidLogic",ROM0

; Asteroid Logic --------------------------------------------------------------
asteroid_init:
    ldxa    [asteroidSmallAvailable],ASTEROID_SMALL_MAX
    ldxa    [asteroidMediumAvailable],ASTEROID_MEDIUM_MAX
    ldxa    [asteroidLargeAvailable],ASTEROID_LARGE_MAX
    ldxa    [asteroidGiantAvailable],ASTEROID_GIANT_MAX
    ldxa    [asteroidQueueLength],0
    ldxa    [asteroidScreenCount],0
    ldxa    [asteroidLaunchTick],1
    ret

asteroid_launch:

    ; check if enabled
    ; TODO ifdef support in gbasm?
    ld      a,ASTEROID_ENABLED
    cp      1
    ret     nz

    ; timer
    ld      a,[coreTimerCounter]
    and     %0000_1110
    ret     nz

    ; 25% chance
    call    math_random
    cp      192; TODO variable to increase difficulty
    ret     c

    ; limit on screen count
    ld      a,[asteroidScreenCount]
    cp      ASTEROID_MAX_ON_SCREEN
    ret     nc

    ; ticks
    decx    [asteroidLaunchTick]
    cp      0
    ret     nz
    ldxa    [asteroidLaunchTick],12; TODO variable to increase difficulty

    ; choose side
    call    math_random
    cp      192
    jr      nc,.from_right
    cp      128
    jr      nc,.from_down
    cp      64
    jr      nc,.from_left

.from_up:
    ; set y to 0
    xor     a
    ld      [polygonY],a

    ; angle between 32-96
    ld      b,32
    jr      .top_bottom

.from_left:
    ; set x to 0
    ld      a,0
    ld      [polygonX],a

    ; angle between  224 - 32
    ld      b,224
    jr      .left_right

.from_down:
    ; set y to 176
    ld      a,176
    ld      [polygonY],a

    ; angle between  160 - 224
    ld      b,160
    jr      .top_bottom

.from_right:
    ; set x to 192
    ld      a,192
    ld      [polygonX],a

    ; angle between  96 - 160
    ld      b,96

.left_right:
    ; TODO double check these
    ; choose y between 32-128
    call    math_random
    and     %0101_1111
    add     32
    ld      [polygonY],a
    jr      .launch

.top_bottom:
    ; TODO double check these
    ; choose x between 32-144
    call    math_random
    and     %0110_1111
    add     32
    ld      [polygonX],a

.launch:

    ; set distance to 0
    ld      e,0

    ; set random velocity
    call    math_random
    and     ASTEROID_LAUNCH_MASK
    add     ASTEROID_LAUNCH_VELOCITY
    ld      c,a

    ; vary angle by 64
    call    math_random
    and     %0011_1111
    add     b
    ld      d,a; store angle

    ; randomize size
    call    math_random
    and     %0000_0011
    add     2
    and     %0000_0111
    cp      POLYGON_MEDIUM
    jr      z,.medium
    cp      POLYGON_LARGE
    jr      z,.large

.giant:
    ld      a,[asteroidGiantAvailable]
    cp      0
    ret     z

    ld      b,POLYGON_GIANT
    ld      a,d
    call    asteroid_create
    decx    [asteroidGiantAvailable]
    ret

.medium:
    ld      a,[asteroidMediumAvailable]
    cp      0
    ret     z

    ld      b,POLYGON_MEDIUM
    ld      a,d
    call    asteroid_create
    decx    [asteroidMediumAvailable]
    ret

.large:
    ld      a,[asteroidLargeAvailable]
    cp      0
    ret     z

    ld      b,POLYGON_LARGE
    ld      a,d
    call    asteroid_create
    decx    [asteroidLargeAvailable]
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
    ; TODO add more HP in case of gray/hard asteroid
    ld      hl,_asteroid_hp
    addw    hl,a
    ld      a,[hl]
    ld      [polygonDataB],a

    ; load polygon data for size
    call    math_random
    and     %0000_0001
    add     a; x2
    ld      b,a
    ld      a,[polygonSize]
    dec     a
    add     a; x2
    add     a; x4
    add     b

    ld      hl,_asteroid_polygons
    addw    hl,a
    ld      a,[hli]
    ld      e,a
    ld      d,[hl]

    ld      bc,asteroid_update
    ld      a,[polygonSize]
    call    polygon_create

    ; increase on screen count
    ld      a,[asteroidScreenCount]
    inc     a
    ld      [asteroidScreenCount],a

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
    ; TODO reduce further by matching with polygon index?
    ld      a,[coreLoopCounter]
    and     %0000_0001
    jr      z,.rotate

    ; collide with other asteroids
    ; TODO skip when inside border?
    ; need to use half size
    ld      d,COLLISION_ASTEROID
    ld      c,5; TODO adjust for different half-sizes?
    call    collide_with_group
    cp      0
    jr      z,.rotate

    ; move de to size of other asteroid
    ld      a,[polygonHalfSize]
    ld      b,a; current size
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
    ; distribute rotation updats over several frames
    ld      a,[polygonIndex]
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

    ; reduce asteroid hp a bit with every collision
    ld      a,[polygonDataB]
    ; TODO make damage dependend on the other asteroid size
    sub     2; TODO variable for asteroid impact damage
    jr      nc,.hp_above_zero
    jr      .destroy_this_asteroid

.hp_above_zero:
    ld      [polygonDataB],a
    ld      a,1
    ret

.destroy_both_asteroids:
    call    _destroy_other_asteroid

.destroy_this_asteroid:
    ld      a,$FF
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
    call    screen_shake_small
    incx    [asteroidSmallAvailable]
    jr      .done

.medium:
    cp      $08
    jr      nz,.large
    call    screen_shake_medium
    incx    [asteroidMediumAvailable]
    jr      .done

.large:
    cp      $0C
    jr      nz,.giant
    call    screen_shake_large
    incx    [asteroidLargeAvailable]
    jr      .done

.giant:
    cp      $10
    jr      nz,.done
    call    screen_shake_giant
    incx    [asteroidGiantAvailable]

.done:
    ; decrease screen count
    ld      a,[asteroidScreenCount]
    dec     a
    ld      [asteroidScreenCount],a

    call    sound_effect_break
    xor     a
    ret


_destroy_other_asteroid:
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de; hp
    ld      a,$FE
    ld      [de],a
    ret

_asteroid_split:; return 0 if actually split up
    ld      a,[polygonHalfSize]
    cp      $04
    jr      z,.small
    cp      $08
    jp      z,.medium
    cp      $0C
    jp      z,.large
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

    call    _direction_vector
    add     ASTEROID_SPLIT_OFFSET_THIRD
    ld      b,POLYGON_MEDIUM
    ld      c,ASTEROID_SPLIT_VELOCITY_MEDIUM
    ld      e,ASTEROID_SPLIT_DISTANCE_MEDIUM
    call    asteroid_create

    ld      a,d
    add     ASTEROID_SPLIT_OFFSET_THIRD
    add     ASTEROID_SPLIT_OFFSET_THIRD
    call    asteroid_create

    ld      a,d
    sub     ASTEROID_SPLIT_OFFSET_THIRD
    ld      c,ASTEROID_SPLIT_VELOCITY_SMALL
    ld      e,ASTEROID_SPLIT_DISTANCE_SMALL
    ld      b,POLYGON_SMALL
    call    asteroid_create
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
    call    _direction_vector
    add     ASTEROID_SPLIT_OFFSET
    ld      b,POLYGON_MEDIUM
    ld      c,ASTEROID_SPLIT_VELOCITY_MEDIUM
    ld      e,ASTEROID_SPLIT_DISTANCE_MEDIUM
    call    asteroid_create

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
    ; TODO get direction vector of other asteroid if polygonDataB is $fe
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
    push    de
    call    angle_vector_16
    pop     de
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
    push    bc
    call    math_random_signed_half; randomize rotation a bit
    add     d
    ld      d,a
    pop     bc

    ; set velocity
    call    math_random
    and     %0000_0111
    add     c
    ld      e,a
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
_asteroid_polygons:
    DW      small_asteroid_polygon_a
    DW      small_asteroid_polygon_b
    DW      medium_asteroid_polygon_a
    DW      medium_asteroid_polygon_b
    DW      large_asteroid_polygon_a
    DW      large_asteroid_polygon_b
    DW      giant_asteroid_polygon_a
    DW      giant_asteroid_polygon_b

_asteroid_hp:
    DB      2
    DB      8
    DB      15
    DB      32

asteroid_points:
    DB      50
    DB      100
    DB      150
    DB      250

small_asteroid_polygon_a:
    DB        0,3
    DB       32,2
    DB       96,3
    DB      156,2
    DB      220,3
    DB        0,3
    DB      $ff,$ff

small_asteroid_polygon_b:
    DB        0,2
    DB       25,3
    DB      126,3
    DB      176,2
    DB      240,3
    DB        0,2
    DB      $ff,$ff

medium_asteroid_polygon_a:
    DB        0,7
    DB       35,4
    DB       85,6
    DB      135,3
    DB      200,5
    DB      220,6
    DB        0,7
    DB      $ff,$ff

medium_asteroid_polygon_b:
    DB        0,6
    DB       15,3
    DB       55,6
    DB       95,7
    DB      130,5
    DB      190,5
    DB      230,7
    DB        0,6
    DB      $ff,$ff

large_asteroid_polygon_a:
    DB        0,11
    DB       35,10
    DB       85,11
    DB      105,10
    DB      135,11
    DB      200,7
    DB        0,11
    DB      $ff,$ff

large_asteroid_polygon_b:
    DB        0,11
    DB       35,9
    DB       85,7
    DB      135,10
    DB      200,8
    DB      230,10
    DB        0,11
    DB      $ff,$ff

giant_asteroid_polygon_a:
    DB        0,13
    DB       25,15
    DB       85,14
    DB      125,13
    DB      165,15
    DB      230,14
    DB        0,13
    DB      $ff,$ff

giant_asteroid_polygon_b:
    DB        0,15
    DB       65,13
    DB      105,14
    DB      155,15
    DB      205,12
    DB      240,12
    DB        0,15
    DB      $ff,$ff

