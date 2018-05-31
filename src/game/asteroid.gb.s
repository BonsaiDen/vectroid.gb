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
    ; choose y between 32-128
    call    math_random
    and     %0101_1111
    add     32
    ld      [polygonY],a
    jr      .launch

.top_bottom:
    ; choose x between 32-144
    call    math_random
    and     %0110_1111
    add     32
    ld      [polygonX],a

.launch:
    ; set distance to 0
    ld      e,0

    ; vary angle by 64
    call    math_random
    and     %0011_1111
    add     b
    ld      d,a; store angle

    ; chance for heavy asteroid to be spawned
    ld      a,[playerScore + 2]
    cp      0
    jr      nz,.max_heavy_chance
    ld      a,[playerScore + 1]
    jr      .heavy_chance

.max_heavy_chance:
    ld      a,99

.heavy_chance:
    div     a,4
    ld      hl,_asteroid_heavy_chance
    addw    hl,a
    call    math_random
    cp      [hl]
    jr      nc,.normal_type

.heavy_type:
    ld      a,1
    ld      [polygonFlags],a
    jr      .randomize_size

.normal_type:
    xor     a
    ld      [polygonFlags],a

    ; randomize size
.randomize_size:
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

    ; set heavy flag based on palette
    ld      a,[polygonPalette]
    and     %0000_0001
    ld      [polygonFlags],a
    ld      b,a

    ; load polygon hp
    ld      a,[polygonSize]
    dec     a
    add     a; multiply by two
    add     b; add heavy offset
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

    ; check for collisions and ignore placement if we would immediately collide
    ; with another, bigger asteroid
    push    af
    push    bc
    push    de

    call    collide_asteroid_placement
    cp      1
    jr      z,.skip

    pop     de
    pop     bc
    pop     af

    ; spawn if valid
    call    polygon_create

    ; increase on screen count
    ld      a,[asteroidScreenCount]
    inc     a
    ld      [asteroidScreenCount],a
    jr      .done

.skip:
    ; decrease counter if we didn't spawn the asteroid in the first place
    ld      a,[polygonSize]
    cp      POLYGON_SMALL
    jr      z,.small
    cp      POLYGON_MEDIUM
    jr      z,.medium
    cp      POLYGON_LARGE
    jr      z,.large

    decx    [asteroidGiantAvailable]
    jr      .skipped

.small:
    incx    [asteroidSmallAvailable]
    jr      .skipped

.medium:
    incx    [asteroidMediumAvailable]
    jr      .skipped

.large:
    incx    [asteroidLargeAvailable]

.skipped:
    pop     de
    pop     bc
    pop     af

.done:
    pop     hl
    pop     bc
    dec     b
    jp      nz,.next

    xor     a
    ld      [asteroidQueueLength],a
    ret

asteroid_update:
    ld      a,[polygonDataB]
    cp      0
    jr      z,.destroy
    cp      128
    jp      nc,.destroy_collide

    ; only collide every other frame
    ld      a,[coreLoopCounter]
    and     %0000_0010; TODO variable
    jr      z,.rotate

    ; collide with other asteroids
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
    ; skip rotation when on DMG hardware
    ld      a,[coreColorEnabled]
    cp      0
    jr      z,.skip

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

    ; divide by 4 and sub 1 to get index into damage table
    srl     b
    srl     b
    dec     b
    ld      de,_asteroid_asteroid_damage
    ld      a,b
    add     a
    add     c
    addw    de,a
    ld      a,[de]
    ld      b,a

    ; reduce asteroid hp a bit with every collision
    ld      a,[polygonDataB]
    sub     b
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

.points:
    ; calculate asteroid points index
    ld      a,[polygonFlags]
    and     %0000_0001
    ld      b,a
    ld      a,[polygonHalfSize]
    srl     a
    srl     a
    dec     a
    add     a; x2
    add     b; add heavy flag

    ; setup pointer to points
    ld      hl,asteroid_points
    add     a; x2
    addw    hl,a
    call    game_score_points
    jr      .destroyed

.destroy_collide:
    call    _asteroid_split

.destroyed:
    ld      a,[polygonHalfSize]
    cp      $04
    jr      nz,.medium
    call    screen_shake_small
    call    sound_effect_break
    incx    [asteroidSmallAvailable]
    jr      .done

.medium:
    cp      $08
    jr      nz,.large
    call    screen_shake_medium
    call    sound_effect_break
    incx    [asteroidMediumAvailable]
    jr      .done

.large:
    cp      $0C
    jr      nz,.giant
    call    screen_shake_large
    call    sound_effect_break
    incx    [asteroidLargeAvailable]
    jr      .done

.giant:
    ;cp      $10
    ;jr      nz,.sfx
    call    screen_shake_giant
    call    sound_effect_break
    incx    [asteroidGiantAvailable]

.done:
    ; check if destroyed by ship
    ld      a,[polygonDataB]
    cp      $FD
    jr      nz,.decrease; if not skip animation

    call    screen_shake_shield
    call    screen_flash_explosion_tiny
    call    sound_effect_shield_damage

    ; decrease screen count
.decrease:
    ld      a,[asteroidScreenCount]
    dec     a
    ld      [asteroidScreenCount],a

    xor     a
    ret

_destroy_other_asteroid:; -> b = half size, c = flags
    ; store half size
    ld      a,[de]
    ld      b,a
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de

    ; store flags
    ld      a,[de]
    and     %0000_0001
    ld      c,a
    dec     de; hp
    ld      a,$FE
    ld      [de],a
    ret

_asteroid_split:; return 0 if actually split up

    ; check for full queue
    ld      a,[asteroidQueueLength]
    cp      ASTEROID_MAX
    jr      nc,.full_queue

    ld      a,[polygonHalfSize]
    cp      $04
    jr      z,.small
    cp      $08
    jp      z,.medium
    cp      $0C
    jp      z,.large
    jr      .giant

.full_queue:
    scf
    ret

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
    ld      e,ASTEROID_SPLIT_DISTANCE_LARGE
    call    asteroid_create

    ld      a,d
    sub     ASTEROID_SPLIT_OFFSET
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
    ld      e,ASTEROID_SPLIT_DISTANCE_MEDIUM
    call    asteroid_create

    ld      a,d
    add     ASTEROID_SPLIT_OFFSET_THIRD
    add     ASTEROID_SPLIT_OFFSET_THIRD
    call    asteroid_create

    ld      a,d
    sub     ASTEROID_SPLIT_OFFSET_THIRD
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
    ld      e,ASTEROID_SPLIT_DISTANCE_MEDIUM
    call    asteroid_create

    ld      a,d
    sub     ASTEROID_SPLIT_OFFSET
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

    ; calculate velocity based on current score
    push    de
    ld      a,[playerScore + 2]
    cp      0
    jr      nz,.max_velocity
    ld      a,[playerScore + 1]
    jr      .velocity

.max_velocity:
    ld      a,99

.velocity:
    div     a,4
    ld      de,_asteroid_launch_velocity
    addw    de,a
    ld      a,[de]
    ld      c,a; store base velocity

    ; add random velocity
    call    math_random
    and     ASTEROID_LAUNCH_RANDOM

    ; combine with base
    add     c;
    ld      c,a

    ; combine with bonus speed for size
    ld      a,b
    dec     a
    ld      de,_asteroid_launch_velocity_bonus
    addw    de,a
    ld      a,[de]
    add     c
    ld      c,a

    ; limit to 40
    cp      40
    jr      c,.velocity_done
    ld      c,40

.velocity_done:
    pop     de

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
    ld      a,[polygonFlags]
    and     %0000_0001
    cp      1
    jr      z,.heavy
.normal:
    ldxa    [hli],PALETTE_ASTEROID
    jr      .rotation_speed

.heavy:
    ldxa    [hli],PALETTE_ASTEROID_HEAVY

    ; Set random rotation speed
.rotation_speed:
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
    call    angle_vector_16_zero
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
_asteroid_launch_velocity:
    DB      5
    DB      6
    DB      7
    DB      8
    DB      9
    DB      10
    DB      11
    DB      12

    DB      13
    DB      14
    DB      15
    DB      16
    DB      17
    DB      18
    DB      20
    DB      21

    DB      22
    DB      23
    DB      25
    DB      27
    DB      29
    DB      30
    DB      32
    DB      33

    DB      34
    DB      35

_asteroid_heavy_chance:
    DB      0
    DB      0
    DB      2
    DB      2
    DB      4
    DB      4
    DB      8
    DB      8

    DB      8
    DB      8
    DB      8
    DB      16
    DB      16
    DB      16
    DB      24
    DB      24

    DB      32
    DB      32
    DB      32
    DB      48
    DB      48
    DB      48
    DB      64
    DB      64

    DB      255
    DB      255

_asteroid_launch_velocity_bonus:
    DB      8
    DB      5
    DB      2
    DB      0

_asteroid_asteroid_damage:
    DB      2
    DB      4
    DB      4
    DB      8
    DB      8
    DB      16
    DB      16
    DB      32

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
    DB      4

    DB      8
    DB      13

    DB      15
    DB      24

    DB      32
    DB      48

asteroid_damage:
    DB      4
    DB      6

    DB      8
    DB      14

    DB      220
    DB      220

    DB      220
    DB      220

asteroid_points:
    ; small
    DB      0
    DB      1

    ; small hevay
    DB      50
    DB      1

    ; medium
    DB      0
    DB      2

    ; medium heavy
    DB      25
    DB      3

    ; large
    DB      50
    DB      3

    ; large heavy
    DB      0
    DB      5

    ; giant
    DB      0
    DB      5

    ; giant heavy
    DB      5
    DB      8

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
    DB       56,3
    DB      126,2
    DB      196,3
    DB        0,2
    DB      $ff,$ff

medium_asteroid_polygon_a:
    DB        0,7
    DB       35,4
    DB       85,6
    DB      135,3
    DB      200,5
    DB      240,6
    DB        0,7
    DB      $ff,$ff

medium_asteroid_polygon_b:
    DB        0,6
    DB       15,2
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
    DB      190,8
    DB      230,10
    DB        0,11
    DB      $ff,$ff

giant_asteroid_polygon_a:
    DB        0,13
    DB       30,15
    DB       85,14
    DB      125,13
    DB      165,15
    DB      230,14
    DB        0,13
    DB      $ff,$ff

giant_asteroid_polygon_b:
    DB        0,15
    DB       35,11
    DB       85,15
    DB      115,11
    DB      155,15
    DB      205,11
    DB      240,11
    DB        0,15
    DB      $ff,$ff

