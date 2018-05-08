; Constants -------------------------------------------------------------------
POLYGON_BYTES               EQU 22
POLYGON_COUNT               EQU 19
POLYGON_COLLISION_BYTES     EQU 3 * 8 * 4


SECTION "PolygonRam",WRAM0[$C100]
polygonState:              DS     POLYGON_COUNT * POLYGON_BYTES + 1
polygonPalette:            DB
polygonDrawState:          DB
polygonGroup:              DB

SECTION "CollisionRam",WRAM0[$C300]
polygonCollisionGroups:    DS     POLYGON_COLLISION_BYTES


; TODO must be here since C4XX addresses are currently hardcoded in polygon_state_base:
SECTION "PolygonBuffer",WRAM0[$C400]
polygonOffscreenBuffer:    DS     1280


SECTION "PolygonVars",HRAM[$FF9B]
lineXI:                    DB
lineYI:                    DB
polygonX:                  DB
polygonY:                  DB
polygonMX:                 DB
polygonMY:                 DB
polygonDataA:              DB
polygonDataB:              DB
polygonSize:               DB
polygonOffset:             DW
polygonRotation:           DB
polygonHalfSize:           DB

