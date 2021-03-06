; Constants -------------------------------------------------------------------
POLYGON_BYTES               EQU     32
POLYGON_ATTR_BYTES          EQU     16
POLYGON_COUNT               EQU     19
POLYGON_COLLISION_BYTES     EQU     4 * 16 + 1
POLYGON_GIANT               EQU     4
POLYGON_LARGE               EQU     3
POLYGON_MEDIUM              EQU     2
POLYGON_SMALL               EQU     1


SECTION "PolygonRam",WRAM0[$C700]
polygonState:               DS      POLYGON_COUNT * POLYGON_BYTES + 1
polygonPalette:             DB
polygonDrawState:           DB
polygonGroup:               DB
polygonChanged:             DB


SECTION "CollisionRam",WRAM0[$CA00]
polygonCollisionGroups:     DS      POLYGON_COLLISION_BYTES


SECTION "PolygonBuffer",WRAM0[$CB00]
polygonOffscreenBuffer:     DS      1280


SECTION "PolygonVars",HRAM[$FF98]
paletteLightness:           DB
lineXI:                     DB
lineYI:                     DB
lineMask:                   DB
polygonOX:                  DB
polygonOY:                  DB
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
polygonFlags:               DB
