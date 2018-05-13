; Constants -------------------------------------------------------------------
SCROLL_BORDER                   EQU 16
ASTEROID_MAX                    EQU 12

COLLISION_NONE                  EQU $ff
COLLISION_ASTEROID              EQU 0
COLLISION_BULLET                EQU 1
COLLISION_SHIP                  EQU 2

PALETTE_ASTEROID                EQU 0
PALETTE_SHIP                    EQU 1
PALETTE_BULLET                  EQU 2
PALETTE_THRUST_A                EQU 3
PALETTE_THRUST_B                EQU 4
PALETTE_EFFECT                  EQU 5

ASTEROID_QUEUE_DELAY            EQU 2

ASTEROID_SPLIT_OFFSET           EQU 32
ASTEROID_SPLIT_VELOCITY_SMALL   EQU 14
ASTEROID_SPLIT_VELOCITY_MEDIUM  EQU 10
ASTEROID_SPLIT_VELOCITY_LARGE   EQU 6

ASTEROID_SPLIT_DISTANCE_SMALL   EQU 6
ASTEROID_SPLIT_DISTANCE_MEDIUM  EQU 10
ASTEROID_SPLIT_DISTANCE_LARGE   EQU 14

; OAM -------------------------------------------------------------------------
SECTION "OAM",WRAM0[$C000]
DS                          160


; Game ------------------------------------------------------------------------
SECTION "GameRam",WRAM0[$C0A0]
paletteUpdated:             DB
bulletRotation:             DB
bulletX:                    DB
bulletY:                    DB
bulletFired:                DB
bulletDelay:                DB
bulletCount:                DB
thrustType:                 DB
thrustDelay:                DB
thrustRotation:             DB
thrustActive:               DB
thrustX:                    DB
thrustY:                    DB
testCounter:                DB

SECTION "AsteroidRam",WRAM0[$C100]
asteroidQueue:              DS ASTEROID_MAX * 8
                            ; size
                            ; palette
                            ; rotation speed DataA
                            ; rotation
                            ; x
                            ; y
                            ; mx
                            ; my
asteroidCount:              DB
asteroidQueueLength:        DB
asteroidQueueDelay:         DB
asteroidLargeAvailable:     DB; 2
asteroidMediumAvailable:    DB; 2
asteroidSmallAvailable:     DB; 6

