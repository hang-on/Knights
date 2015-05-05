; --------------------------------------------------------------
; DATA
; --------------------------------------------------------------
; Initial values for the 11 vdp registers.

RegisterInitValues:
           .db %00100110   ; reg. 0, display and interrupt mode.
                           ; bit 3 = shift sprites to the left (disabled).
                           ; 4 = line interrupt (disabled).
                           ; 5 = blank left column (enabled).
                           ; 6 = hori. scroll inhibit (disabled).
                           ; 7 = vert. scroll inhibit (disabled).

           .db %10100000   ; reg. 1, display and interrupt mode.
                           ; bit 0 = zoomed sprites (disabled).
                           ; 1 = 8 x 16 sprites (disabled).
                           ; 5 = frame interrupt (enabled).
                           ; 6 = display (blanked).

           .db $ff         ; reg. 2, name table address.
                           ; $ff = name table at $3800.

           .db $ff         ; reg. 3, n.a.
                           ; always set it to $ff.

           .db $ff         ; reg. 4, n.a.
                           ; always set it to $ff.

           .db $ff         ; reg. 5, sprite attribute table.
                           ; $ff = sprite attrib. table at $3F00.

           .db $ff         ; reg. 6, sprite tile address.
                           ; $ff = sprite tiles in bank 2.

           .db %11110011   ; reg. 7, border color.
                           ; set to color 3 in bank 2.

           .db $00         ; reg. 8, horizontal scroll value = 0.

           .db $00         ; reg. 9, vertical scroll value = 0.

           .db $ff         ; reg. 10, raster line interrupt.
                           ; turn off line int. requests.

; Arthur sprite assets:

           SpritePalette:
           .include "Arthur\ArthurPalette.inc"
           
/*
Frame data block format
   Offset  y,x is the coordinate pair used to determine where the top left 
           corner of the layout grid will be placed, relative to the object 
           (i.e. the player).

           Offset values of 0,0 will make the top left corner of the
           frame layout grid = object (y,x). It is named "Offset" because
           every time the sprite is drawn, it is drawn at some offset to the
           actual game object  it represents. This enables fine per pixel
           control over where the sprite is drawn. Frames of a sequence
           can be aligned to each other, even though the sprite in each frame
           is placed differently.

           The values of Offset x,y will be *subtracted* from the object's 
           x,y, in order to determine where to put the grid's top left corner.

           If the sprite is representing the player object...
           By adjusting the offset, you can fine tune where the sprite will be
           drawn in relation to the player (y,x). This way the sprite center
           can be aligned to player y,x, if desired.

   Layout  is an 8 byte (64 bit) table/grid. Each byte corresponds to a row of
           possible hwsprite positions, and each bit corresponds to a column
           of a given row. The layout thus maps out how the individual
           hwsprites, that make up the total sprite, are positioned on the
           grid which is offset from the object (y,x) by Sprites_Offset (y,x).

           The layout is also referred to as the grid, or the layout grid.

   TileBlock is the BMP2Tile-processed block of tiles. The tiles are organized
           so that the top leftmost hwsprite (in the layout) will get tile 0,
           the next hwsprite to the right will get tile 1, and so on,
           downwards, from left to right.... If i.e. four bits are set in the
           layout, you must make sure to also have 4 tiles in the tileblock.
*/


; Arthur walking data block -----------------------------------------------
           ArthurWalking_Frame0_Offset:
           .db 00 00
           ArthurWalking_Frame0_Layout:
           .db %01100000
           .db %11100000
           .db %11110000
           .db %11110000
           .db %11110000
           .db %11110000
           .db %11110000
           .db %00000000
           ArthurWalking_Frame0_Tiles:
           .include "Arthur\ArthurWalking_Frame0_Tiles.inc"

           ArthurWalking_Frame1_Offset:
           .db 00 00
           ArthurWalking_Frame1_Layout:
           .db %01100000
           .db %11100000
           .db %11100000
           .db %11110000
           .db %11111000
           .db %11000000
           .db %11000000
           .db %00000000
           ArthurWalking_Frame1_Tiles:
           .include "Arthur\ArthurWalking_Frame1_Tiles.inc"

; -----------------------------------------------------------------------------


