; Main Game Logic -------------------------------------------------------------
SECTION "ShipLogic",ROM0

THRUST_DELAY        EQU  4
TRHUST_ACTIVE       EQU  10
BULLET_DELAY        EQU  5
BULLET_ACTIVE       EQU  48
BULLET_SPEED        EQU  16
SHIP_MAX_SPEED      EQU  15


; Logic -----------------------------------------------------------------------
ship_fire_thrust:
    ld      a,[thrustActive]
    cp      0
    ret     z

    dec     a
    ld      [thrustActive],a

    ; limit thrust frequency
    ld      a,[thrustDelay]
    cp      0
    jr      z,.thrust_ready
    dec     a
    ld      [thrustDelay],a
    ret

.thrust_ready:
    xor     a
    ld      [polygonMX],a
    ld      [polygonMY],a

    ldxa    [thrustDelay],THRUST_DELAY

    ldxa    [polygonGroup],COLLISION_NONE
    ldxa    [polygonDataA],THRUST_DELAY - 1
    ld      bc,thrust_update

    ; toggle between thrust polygons
    ld      a,[thrustType]
    xor     1
    ld      [thrustType],a
    cp      0
    jr      z,.type_a
    ldxa    [polygonPalette],PALETTE_THRUST_A
    ld      de,thrust_polygon_b
    jr      .create

.type_a:
    ldxa    [polygonPalette],PALETTE_THRUST_B
    ld      de,thrust_polygon_a

.create:
    ld      a,[thrustRotation]
    add     128
    ld      [polygonRotation],a

    ld      a,POLYGON_SMALL; size
    call    polygon_create

    ret

ship_fire_bullet:
    ld      a,[bulletFired]
    cp      0
    ret     z

    ld      a,[bulletCount]
    cp      4
    jr      c,.create
    ret

.create:
    inc     a
    ld      [bulletCount],a

    ; movement vecotr
    ldxa    d,[bulletRotation]
    ld      e,BULLET_SPEED
    call    angle_vector_16
    sla     b
    sla     c
    ldxa    [polygonMX],b
    ldxa    [polygonMY],c

    ; position offset
    ldxa    d,[bulletRotation]
    ld      e,6
    call    angle_vector_16
    ld      a,[bulletX]
    add     b
    ld      [polygonX],a
    ld      a,[bulletY]
    add     c
    ld      [polygonY],a

    ldxa    [polygonPalette],PALETTE_BULLET
    ldxa    [polygonGroup],COLLISION_BULLET
    ldxa    [polygonRotation],[bulletRotation]
    ldxa    [polygonDataA],BULLET_ACTIVE
    ld      de,bullet_polygon
    ld      bc,bullet_update
    ld      a,1; size
    call    polygon_create
    call    sound_effect_bullet
    xor     a
    ld      [bulletFired],a
    ret

ship_init:
    ; reset player ship variables
    xor     a
    ld      [bulletFired],a
    ld      [bulletDelay],a
    ld      [bulletCount],a
    ld      [thrustDelay],a
    ld      [thrustType],a
    ld      [thrustActive],a

    createPolygon(2,     COLLISION_SHIP,     PALETTE_SHIP,  80,  72, 192,           ship_polygon, ship_update)
    ret


ship_update:

    ; Rotation Controls
    ld      a,[coreInput]
    and     BUTTON_LEFT
    cp      BUTTON_LEFT
    jr      nz,.no_left
    ld      a,[polygonRotation]
    sub     3
    ld      [polygonRotation],a
.no_left:
    ld      a,[coreInput]
    and     BUTTON_RIGHT
    cp      BUTTON_RIGHT
    jr      nz,.no_right
    ld      a,[polygonRotation]
    add     3
    ld      [polygonRotation],a
.no_right:

    ; Acceleration
    ld      a,[coreInput]
    and     BUTTON_A
    cp      BUTTON_A
    jr      nz,.no_acceleration

    ldxa    [thrustActive],TRHUST_ACTIVE

    ; Sound Effect only once per button press
    ld      a,[coreInputOn]
    and     BUTTON_A
    cp      BUTTON_A
    jr      nz,.pressed
    call    sound_effect_thrust

.pressed:
    ld      a,[coreLoopCounter]
    and     %0000_0010
    jr      z,.no_acceleration

    ; calculate ax/ay from angle
    ldxa    d,[polygonRotation]
    ld      e,2
    call    angle_vector_16; bc = ax/ay

    ; add to mx/my
    ld      a,[polygonMX]
    add     b
    ld      b,a

    ld      a,[polygonMY]
    add     c
    ld      c,a

    ; calculate movement angle
    call    atan_2
    ld      d,a

    ; bc=cx/cy
    ; calculate magnitude
    call    sqrt_length
    cp      SHIP_MAX_SPEED
    jr      c,.smaller
    ld      a,SHIP_MAX_SPEED; limit to max speed
    cp      0
    jr      z,.stop

.smaller:
    ; calculate new MX/MY
    ld      e,a
    ; TODO support 32
    call    angle_vector_16
    ldxa    [polygonMX],b
    ldxa    [polygonMY],c
    jr      .no_acceleration

.stop:
    xor     a
    ld      [polygonMX],a
    ld      [polygonMY],a
    jr      .no_acceleration

.no_acceleration:

    ld      a,[coreLoopCounter]
    and     %0000_0001
    jr      z,.no_bullet

    ; limit shot frequency
    ld      a,[bulletDelay]
    cp      0
    jr      z,.bullet_ready
    dec     a
    ld      [bulletDelay],a
    jr      .no_bullet

    ; shooting
.bullet_ready:
    ld      a,[coreInput]
    and     BUTTON_B
    cp      BUTTON_B
    jr      nz,.no_bullet

    ; check if outside of screen bounds
    call    _within_border
    cp      1
    jr      z,.no_bullet

    ; set bullet spawn location
    ldxa    [bulletX],[polygonX]
    ldxa    [bulletY],[polygonY]
    ldxa    [bulletRotation],[polygonRotation]

    ; set up limit
    ldxa    [bulletDelay],BULLET_DELAY
    ldxa    [bulletFired],1

.no_bullet:
    ; copy thrust location
    ldxa    [thrustX],[polygonX]
    ldxa    [thrustY],[polygonY]
    ldxa    [thrustRotation],[polygonRotation]
    ld      a,1
    ret

_within_border:
    ld      a,[polygonX]
    cp      12; TODO variable
    jr      c,.within
    cp      178; TODO variable
    jr      nc,.within

    ld      a,[polygonY]
    cp      12; TODO variable
    jr      c,.within
    cp      162; TODO variable
    jr      nc,.within
    xor     a
    ret

.within:
    ld      a,1
    ret

; Bullets ---------------------------------------------------------------------
bullet_update:
    ld      a,[polygonDataA]
    dec     a
    cp      0
    jr      z,.destroy
    ld      [polygonDataA],a

    ld      d,COLLISION_ASTEROID
    ld      c,4; TODO variable
    call    collide_with_group
    cp      1
    jr      z,.collide

    ld      a,1
    ret

.collide:

    ; DE points to half size of polygon, so we need to go 5 back to DataB
    dec     de
    dec     de
    dec     de
    dec     de
    dec     de

    ; reduce asteroid hp
    ld      a,[de]
    sub     3; TODO variable for bullet damage
    jr      nc,.hp_above_zero
    xor     a

.hp_above_zero:
    ld      [de],a
    call    sound_effect_impact

    ; reduce global bullet count
.destroy:
    ld      a,[bulletCount]
    dec     a
    ld      [bulletCount],a
    xor     a
    ret


; Thrust ----------------------------------------------------------------------
thrust_update:
    ld      a,[polygonDataA]
    dec     a
    cp      0
    jr      z,.destroy
    ld      [polygonDataA],a

.place:

    ; calculate offset
    ld      a,[thrustRotation]
    ld      d,a
    ld      e,7
    call    angle_vector_16

    ld      a,[thrustX]
    sub     b
    ld      [polygonX],a

    ld      a,[thrustY]
    sub     c
    ld      [polygonY],a

    ld      a,[thrustRotation]
    add     128
    ld      [polygonRotation],a

    ld      a,1
    ret

.destroy:
    xor     a
    ret


; Layout ----------------------------------------------------------------------
bullet_polygon:
    DB      0; angle
    DB      1; length
    DB      42
    DB      1; length
    DB      42 * 2
    DB      1; length
    DB      42 * 3
    DB      1; length
    DB      42 * 4
    DB      1; length
    DB      42 * 5
    DB      1; length
    DB      0; angle
    DB      1; length
    DB      $ff,$ff

ship_polygon:
    DB      0; angle
    DB      5; length
    DB      85 + 15; angle
    DB      5; length
    DB      85 + 85 - 15; angle
    DB      5; length
    DB      0; angle
    DB      5; length
    DB      $ff,$ff

thrust_polygon_a:
    DB      0; angle
    DB      1; length
    DB      85 + 15; angle
    DB      3; length
    DB      85 + 85 - 15; angle
    DB      3; length
    DB      0; angle
    DB      1; length
    DB      $ff,$ff

thrust_polygon_b:
    DB      0; angle
    DB      3; length
    DB      85 + 15; angle
    DB      3; length
    DB      85 + 85 - 15; angle
    DB      3; length
    DB      0; angle
    DB      3; length
    DB      $ff,$ff

