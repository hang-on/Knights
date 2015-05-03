; --------------------------------------------------------------
; DATA
; --------------------------------------------------------------
; Initial values for the 11 vdp registers.

RegisterInitValues:
           .db %00100110   ; reg. 0, display and interrupt mode.
                           ; bit 4 = line interrupt (disabled).
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

           Arthur_Palette:
           .include "Arthur_Palette.inc"
           ArthurStanding_TileBlock:
           .include "ArthurStanding_TileBlock.inc"

           ArthurStanding_SATPackage:
           .db 27 ; amount of hwsprites
           .db 88 ; y-offset
           .db 8  ; x-offset
           ; now all the vpos, reverse order
           .db 80 80 80 80 72 72 72 72 64 64 64 64 56 56 56 48 48 48
           .db 40 40 40 40 32 32 24 16 8
           ; all the hpos, reverse order
           .db 24 16 8 0 24 16 8 0 24 16 8 0 24 16 8 24 16 8
           .db 24 16 8 0 16 8 8 8 8


           ArthurWalking1_TileBlock:
           .include "ArthurWalking1_TileBlock.inc"

           ArthurWalking1_SATPackage:
           .db 25 ; amount of hwsprites
           .db 1 ; y-offset
           .db 1 ; x-offset
           ; now all the vpos, reverse order
           .db 48 48 48 48 40 40 40 40 32 32 32 32 24 24 24 24
           .db 16 16 16 16 8 8 8 0 0
           ; all the hpos, reverse order
           .db 24 16 8 0 24 16 8 0 24 16 8 0 24 16 8 0
           .db 24 16 8 0 16 8 0 16 8
