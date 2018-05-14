; ROM Definitions -------------------------------------------------------------
INCLUDE     "core/include/rom.inc"


; Catridge Information --------------------------------------------------------
CART_NAME           EQUS       "Vectroid"
CART_LICENSEE       EQUS       "BD"
CART_TYPE           EQU        ROM_MBC1
CART_ROM_SIZE       EQU        ROM_SIZE_32KBYTE
CART_RAM_SIZE       EQU        RAM_SIZE_0KBIT
CART_DEST           EQU        ROM_DEST_OTHER
CART_GBC_SUPPORT    EQU        ROM_GBC_SUPPORT_ENABLED


; Include Core Library --------------------------------------------------------
INCLUDE     "core/core.gb.s"


; Constants and Variables -----------------------------------------------------
INCLUDE     "ram/game.gb.s"
INCLUDE     "ram/asteroid.gb.s"
INCLUDE     "ram/polygon.gb.s"


; Main Game -------------------------------------------------------------------
INCLUDE     "game/game.gb.s"
INCLUDE     "game/math.gb.s"
INCLUDE     "game/ui.gb.s"
INCLUDE     "game/ship.gb.s"
INCLUDE     "game/asteroid.gb.s"
INCLUDE     "game/collision.gb.s"
INCLUDE     "game/line.gb.s"
INCLUDE     "game/polygon.gb.s"
INCLUDE     "game/base.gb.s"
INCLUDE     "game/palette.gb.s"
INCLUDE     "game/sound.gb.s"


; Data ------------------------------------------------------------------------
INCLUDE     "game/data/bank1.gb.s"

