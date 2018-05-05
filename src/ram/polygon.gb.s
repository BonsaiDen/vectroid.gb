; Constants -------------------------------------------------------------------
COLLISION_NONE              EQU $ff
COLLISION_ASTEROID          EQU 0
COLLISION_BULLET            EQU 1
COLLISION_SHIP              EQU 2

POLYGON_BYTES               EQU 21
POLYGON_COUNT               EQU 19
POLYGON_COLLISION_BYTES     EQU 3 * 8 * 4


SECTION "PolygonRam",WRAM0[$C100]
polygonState:              DS     POLYGON_COUNT * POLYGON_BYTES + 1
polygonStateEnd:           DB

SECTION "CollisionRam",WRAM0[$C300]
polygonCollisionGroups:    DS     POLYGON_COLLISION_BYTES


; TODO must be here since C4XX addresses are currently hardcoded in polygon_state_base:
SECTION "PolygonBuffer",WRAM0[$C400]
polygonOffscreenBuffer:    DS     1280
polygonDrawState:          DB
polygonHalfSize:           DB
polygonGroup:              DB


SECTION "RasterizerRam",HRAM[$FF9E]
lineXI:                    DB
lineYI:                    DB
polygonX:                  DB
polygonY:                  DB
polygonMX:                 DB
polygonMY:                 DB
polygonSize:               DB
polygonOffset:             DW
polygonRotation:           DB

