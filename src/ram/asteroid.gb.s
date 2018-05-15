; Constants -------------------------------------------------------------------
ASTEROID_QUEUE_DELAY            EQU 1

ASTEROID_SPLIT_OFFSET           EQU 32
ASTEROID_SPLIT_OFFSET_THIRD     EQU 64
ASTEROID_SPLIT_VELOCITY_SMALL   EQU 14
ASTEROID_SPLIT_VELOCITY_MEDIUM  EQU 10
ASTEROID_SPLIT_VELOCITY_LARGE   EQU 6

ASTEROID_SPLIT_DISTANCE_SMALL   EQU 6
ASTEROID_SPLIT_DISTANCE_MEDIUM  EQU 10
ASTEROID_SPLIT_DISTANCE_LARGE   EQU 14

ASTEROID_SMALL_MAX              EQU 6
ASTEROID_MEDIUM_MAX             EQU 3
ASTEROID_LARGE_MAX              EQU 2
ASTEROID_GIANT_MAX              EQU 1

SECTION "AsteroidRam",WRAM0[$C700]
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
asteroidLaunchTick:         DB
asteroidQueueLength:        DB
asteroidQueueDelay:         DB
asteroidGiantAvailable:     DB
asteroidLargeAvailable:     DB
asteroidMediumAvailable:    DB
asteroidSmallAvailable:     DB
