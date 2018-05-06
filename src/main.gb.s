; ROM Definitions -------------------------------------------------------------
INCLUDE     "core/include/rom.inc"


; Catridge Information --------------------------------------------------------
CART_NAME           EQUS       "Vectroid"
CART_LICENSEE       EQUS       "BD"
CART_TYPE           EQU        ROM_MBC1_RAM_BAT
CART_ROM_SIZE       EQU        ROM_SIZE_32KBYTE
CART_RAM_SIZE       EQU        RAM_SIZE_16KBIT
CART_DEST           EQU        ROM_DEST_OTHER
CART_GBC_SUPPORT    EQU        ROM_GBC_SUPPORT_ENABLED


; Include Core Library --------------------------------------------------------
INCLUDE     "core/core.gb.s"


; Constants and Variables -----------------------------------------------------
INCLUDE     "ram/game.gb.s"
INCLUDE     "ram/polygon.gb.s"


; Main Game -------------------------------------------------------------------
INCLUDE     "game/game.gb.s"
INCLUDE     "game/math.gb.s"
INCLUDE     "game/line.gb.s"
INCLUDE     "game/polygon.gb.s"
INCLUDE     "game/base.gb.s"
INCLUDE     "game/palette.gb.s"


; Data ------------------------------------------------------------------------
INCLUDE     "game/data/bank1.gb.s"

