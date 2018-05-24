; Constants -------------------------------------------------------------------
SCROLL_BORDER               EQU 16

THRUST_DELAY                EQU 4
TRHUST_ACTIVE               EQU 10
BULLET_DELAY                EQU 5
BULLET_ACTIVE               EQU 48
BULLET_SPEED                EQU 32
SHIP_MAX_SPEED              EQU 31
SHIP_TURN_SPEED             EQU 3
SHIP_ACCELERATION           EQU 3

COLLISION_NONE              EQU $ff
COLLISION_ASTEROID          EQU 0
COLLISION_BULLET            EQU 1
COLLISION_SHIP              EQU 2

IFRAME_COUNT                EQU 90
SHIELD_DAMAGE_SMALL         EQU 8
SHIELD_DAMAGE_MEDIUM        EQU 16

PALETTE_ASTEROID            EQU 0
PALETTE_SHIP                EQU 1
PALETTE_BULLET              EQU 2
PALETTE_THRUST_A            EQU 3
PALETTE_THRUST_B            EQU 4
PALETTE_EFFECT              EQU 5

GAME_MODE_TITLE             EQU 0
GAME_MODE_PLAY              EQU 1
GAME_MODE_OVER              EQU 2
GAME_MODE_PAUSE             EQU 3


; OAM -------------------------------------------------------------------------
SECTION "OAM",WRAM0[$C000]
DS                          160


; Game ------------------------------------------------------------------------
SECTION "GameRam",WRAM0[$C0A0]
debugDisplay:               DB
screenShakeStrength:        DB
screenShakeTicks:           DB
gameMode:                   DB
paletteUpdated:             DB
bulletRotation:             DB
shipWithinBorder:           DB
bulletX:                    DB
bulletY:                    DB
bulletFired:                DB
bulletDelay:                DB
bulletCount:                DB
thrustType:                 DB
thrustDelay:                DB
playerRotation:             DB
thrustActive:               DB
playerIFrames:              DB
playerShield:               DB
playerX:                    DB
playerY:                    DB
playerScore:                DS 2

SECTION "UiRam",WRAM0[$C100]
uiOffscreenBuffer:          DS 576

