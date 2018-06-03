; Constants -------------------------------------------------------------------
SCROLL_BORDER               EQU 16

THRUST_DELAY                EQU 4
TRHUST_ACTIVE               EQU 10
BULLET_DELAY                EQU 5
BULLET_ACTIVE               EQU 48
BULLET_SPEED                EQU 32
BULLET_COLLISION_RANGE      EQU 4
BULLET_DAMAGE               EQU 3

SHIP_MAX_SPEED              EQU 31
SHIP_TURN_SPEED             EQU 3
SHIP_ACCELERATION           EQU 3

COLLISION_NONE              EQU $ff
COLLISION_ASTEROID          EQU 0
;COLLISION_BULLET            EQU 1
;COLLISION_SHIP              EQU 2

SCREEN_BORDER_TOP           EQU 11
SCREEN_BORDER_RIGHT         EQU 182
SCREEN_BORDER_BOTTOM        EQU 164
SCREEN_BORDER_LEFT          EQU 11

IFRAME_COUNT                EQU 90
SHIELD_DAMAGE_SMALL         EQU 8
SHIELD_DAMAGE_MEDIUM        EQU 16

PALETTE_ASTEROID            EQU 0 | %0001_0000
PALETTE_ASTEROID_HEAVY      EQU 1
PALETTE_SHIP                EQU 2
PALETTE_BULLET              EQU 3
PALETTE_THRUST_A            EQU 4 | %0001_0000
PALETTE_THRUST_B            EQU 5

GAME_MODE_TITLE             EQU 0
GAME_MODE_PLAY              EQU 1
GAME_MODE_OVER              EQU 2
GAME_MODE_PAUSE             EQU 3

PALETTE_BACKGROUND_COUNT    EQU 1
PALETTE_SPRITE_COUNT        EQU 6

SOUND_PRIORITY_LOW          EQU 1
SOUND_PRIORITY_MEDIUM       EQU 2
SOUND_PRIORITY_HIGH         EQU 3

; OAM -------------------------------------------------------------------------
SECTION "OAM",WRAM0[$C000]
DS                          160


; Game ------------------------------------------------------------------------
SECTION "GameRam",WRAM0[$C0A0]
screenShakeStrength:        DB
screenShakeTicks:           DB
screenFlashPointer:         DW
menuDebug:                  DB
menuButton:                 DB
soundFrames:                DS 4
soundPriority:              DS 4
gameDelay:                  DB
gameModeNext:               DB
gameMode:                   DB
uiUpdate:                   DB
uiPosition:                 DB
uiClear:                    DB
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
playerScore:                DS 3

SECTION "PaletteRam",WRAM0[$C100]
paletteBuffer:              DS (PALETTE_BACKGROUND_COUNT + PALETTE_SPRITE_COUNT) * 4 * 2

SECTION "UiRam",WRAM0[$C200]
uiOffscreenBuffer:          DS 576

