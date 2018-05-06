; Constants -------------------------------------------------------------------
SCROLL_BORDER               EQU 16

COLLISION_NONE              EQU $ff
COLLISION_ASTEROID          EQU 0
COLLISION_BULLET            EQU 1
COLLISION_SHIP              EQU 2

PALETTE_ASTEROID            EQU 0
PALETTE_SHIP                EQU 1
PALETTE_BULLET              EQU 2
PALETTE_EFFECT              EQU 3


; OAM -------------------------------------------------------------------------
SECTION "OAM",WRAM0[$C000]
DS                          160


; Game ------------------------------------------------------------------------
SECTION "GameRam",WRAM0[$C0A0]
paletteUpdated:             DB
testRotate:                 DB

