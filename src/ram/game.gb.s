; Constants -------------------------------------------------------------------
SCROLL_BORDER               EQU 16
ASTEROID_MAX                EQU 12
ASTEROID_LAUNCH_VELOCITY    EQU 4
ASTEROID_LAUNCH_MASK        EQU %0000_0111

COLLISION_NONE              EQU $ff
COLLISION_ASTEROID          EQU 0
COLLISION_BULLET            EQU 1
COLLISION_SHIP              EQU 2

PALETTE_ASTEROID            EQU 0
PALETTE_SHIP                EQU 1
PALETTE_BULLET              EQU 2
PALETTE_THRUST_A            EQU 3
PALETTE_THRUST_B            EQU 4
PALETTE_EFFECT              EQU 5


; OAM -------------------------------------------------------------------------
SECTION "OAM",WRAM0[$C000]
DS                          160


; Game ------------------------------------------------------------------------
SECTION "GameRam",WRAM0[$C0A0]
debugDisplay:               DB
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

SECTION "UiRam",WRAM0[$C100]
uiOffscreenBuffer:          DS 576

