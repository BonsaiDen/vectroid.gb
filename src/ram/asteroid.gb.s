; Constants -------------------------------------------------------------------
ASTEROID_QUEUE_DELAY            EQU 1

ASTEROID_SPLIT_OFFSET           EQU 32
ASTEROID_SPLIT_OFFSET_THIRD     EQU 64

ASTEROID_SPLIT_DISTANCE_SMALL   EQU 7
ASTEROID_SPLIT_DISTANCE_MEDIUM  EQU 13
ASTEROID_SPLIT_DISTANCE_LARGE   EQU 17

ASTEROID_SMALL_MAX              EQU 6
ASTEROID_MEDIUM_MAX             EQU 3
ASTEROID_LARGE_MAX              EQU 2
ASTEROID_GIANT_MAX              EQU 1

ASTEROID_ENABLED                EQU 1
ASTEROID_MAX                    EQU 12
ASTEROID_MAX_ON_SCREEN          EQU 10
ASTEROID_LAUNCH_RANDOM          EQU %0000_0111
ASTEROID_DESTROYED_BY_BULLET    EQU $FF
ASTEROID_DESTROYED_BY_OTHER     EQU $FE
ASTEROID_DESTROYED_BY_SHIP      EQU $FD


SECTION "AsteroidRam",WRAM0[$C500]
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
asteroidScreenCount:        DB
asteroidGiantAvailable:     DB
asteroidLargeAvailable:     DB
asteroidMediumAvailable:    DB
asteroidSmallAvailable:     DB

