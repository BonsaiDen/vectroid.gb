; Constants -------------------------------------------------------------------
POLYGON_BYTES               EQU 22
POLYGON_COUNT               EQU 19
POLYGON_COLLISION_BYTES     EQU 3 * 8 * 4
POLYGON_GIANT               EQU 4
POLYGON_LARGE               EQU 3
POLYGON_MEDIUM              EQU 2
POLYGON_SMALL               EQU 1


SECTION "PolygonRam",WRAM0[$C800]
polygonState:               DS     POLYGON_COUNT * POLYGON_BYTES + 1
polygonPalette:             DB
polygonDrawState:           DB
polygonGroup:               DB


SECTION "CollisionRam",WRAM0[$CA00]
polygonCollisionGroups:     DS     POLYGON_COLLISION_BYTES


SECTION "PolygonBuffer",WRAM0[$CB00]
polygonOffscreenBuffer:     DS     1280


SECTION "PolygonVars",HRAM[$FF98]
lineXI:                     DB
lineYI:                     DB
polygonX:                   DB
polygonY:                   DB
polygonMX:                  DB
polygonMY:                  DB
polygonDataA:               DB
polygonDataB:               DB
polygonSize:                DB
polygonOffset:              DW
polygonRotation:            DB
polygonHalfSize:            DB
polygonIndex:               DB
