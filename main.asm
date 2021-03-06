; Setup the SDSC tag, including correct chekcsum:
           .sdsctag 0.1, "Knights", ReleaseNotes, "Anders S. Jensen"

; Organize read only memory:
           ; Three rom slots a' 16K. Assume standard Sega mapper with
           ; bankswitching in slot 2.
           .memorymap
           defaultslot 0
           slotsize $4000
           slot 0 $0000
           slot 1 $4000
           slot 2 $8000
           slotsize $2000 ; RAM
           slot 3 $c000
           .endme

           ; Make a 64K rom
           .rombankmap
           bankstotal 4
           banksize $4000
           banks 4
           .endro

; Define constants:
            ; For outiblock calls.
           .equ OUTI_32 $4300-32*2 ; end of block - 32 x outi (2 bytes each).
           .equ OUTI_64 $4300-64*2 ; end of block - 64 x outi (2 bytes each).

; Organize variables:
           ; Variables are reset to 0 as part of the general memory
           ; initialization.
           .enum $c000 export
           SATBuffer dsb 32 + 64

           FrameInterruptFlag db
           VDPStatus db
           Joystick1 db
           Joystick2 db

           Arthur_State db
           Arthur_X db
           Arthur_Y db
           Arthur_FrameNumber db
           Arthur_TilePointer dw
           Arthur_Timer db
           Arthur_GridX db
           Arthur_GridY db
           Arthur_Status db

           Hub_GameState db
           Hub_Status db
           Hub_LoopCounter db
           Hub_Timer db

           .ende

; Libray of minor routines:
           .include "SupportLibraries\MinorRoutines.inc"

; sverx's PSG library:
           .include "SupportLibraries\PSGlib.inc"

; Beginning of ROM:
.bank 0 slot 0
.org 0
           di
           im 1
           ld sp,$dff0
           jp InitializeFramework

.orga $0020
; Prepare vram at HL (to be called with rst):
           ld a,l
           out ($bf),a
           ld a,h
           or $40
           out ($bf),a
           ret             ; whew, tight! One spare byte up to int. handler.

.orga $0038
; Frame interrupt handler:
           ex af,af'
           in a,$bf
           ld (VDPStatus),a
           ld a,1
           ld (FrameInterruptFlag),a
           ex af,af'
           ei
           ret

.orga $0066
; Pause interrupt handler:
           retn


; -----------------------------------------------------------------------------
.section "Memory initialization" free
InitializeFramework:
           ; Overwrite 4K of RAM with zeroes.
           ld hl,$c000
           ld bc,$1000
           ld a,0
           call FillMemory

           ; Use the initialized ram to clean all of vram.
           ld hl,$0000
           call PrepareVRAM
           ld b,4
-          push bc
           ld hl,$c000
           ld bc,$1000
           call LoadVRAM
           pop bc
           djnz -

           ; Initialize the VDP registers:
           ld hl,RegisterInitValues
           ld b,11
           ld c,$80
-          ld a,(hl)
           out ($bf),a
           ld a,c
           out ($bf),a
           inc hl
           inc c
           djnz -

           ; Set the border color.
           ld a,%11110001
           ld b,2
           call SetRegister

           ; Start main loop in state 0.
           ld a,0
           ld (Hub_GameState),a

           call PSGInit

           ei
           jp MainLoop
.ends

; -----------------------------------------------------------------------------
.section "Main Loop" free                                                     ;
; -----------------------------------------------------------------------------
MainLoop:                                                                     ;
           call WaitForFrameInterrupt                                         ;
           call Loader
           call Arthur                                                        ;
           call Hub                                                           ;                                                               ;
           call PSGSFXFrame                                                   ;
           call PSGFrame                                                      ;
           jp MainLoop                                                        ;
.ends                                                                         ;
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
.section "Loader" free
; -----------------------------------------------------------------------------
Loader:
           ; Switch according to game state.
           ld a,(Hub_GameState)
           ld de,_SwitchVectors
           call GetVector
           jp (hl)

_0:        ; Initialize level.
           ; Disable display.
           ld a,%10100000
           ld b,1
           call SetRegister

           ; Load sprite colors into bank 2.
           ld hl,$c010
           rst $20
           ld hl,SpritePalette
           ld bc,2
           call LoadVRAM

           ret

_1:        ; Run level.
           ; See if Arthur wants us to load some new tiles.
           ld a,(Arthur_Status)
           bit 0,a
           jp z,+
           ; Load request from Arthur! Prepare vram for new Arthur tiles.
           ld hl,$2020     ; Arthur's 12 tiles are @ 257-269 in the bank.
           rst $20         ; Prepare VRAM at index 257.
           ; Setup HL to point to the relevant block of tiles to load.
           ld ix,Arthur_TilePointer
           ld h,(ix+1)
           ld l,(ix+0)
           ld c,$be
           call OutiBlock ; Invoke the full, swirling fast outiblock.
        +:
           ; Load 32 hwsprites' vertical positions.
           ld hl,$3f00
           rst $20
           ld hl,SATBuffer
           ld c,$be
           call OUTI_32

           ; Load 32 hwsprites' horizontal positions and charcodes.
           ld hl,$3f80
           rst $20
           ld hl,SATBuffer+32
           ld c,$be
           call OUTI_64

           ; Enable display.
           ld a,%11100000
           ld b,1
           call SetRegister

           ret

_2:
_3:
_4:
_5:
_6:
_7:
_8:

           _SwitchVectors: .dw _0 _1 _2 _3 _4 _5 _6 _7 _8
.ends

; -----------------------------------------------------------------------------
.section "Arthur" free
; -----------------------------------------------------------------------------
Arthur:
           ; Switch according to game state.
           ld a,(Hub_GameState)
           ld de,_SwitchVectors
           call GetVector
           jp (hl)

_0:        ; Initialize level.
           ; Place Arthur sprite on default location.
           ld a,100
           ld (Arthur_X),a
           ld (Arthur_Y),a

           ret

_1:        ; Run level.

           ; Toggle the status flags.
           ld a,(Arthur_Status)
           and %11111110   ; reset Loader flag.
           ld (Arthur_Status),a
           
           ; Reset ArthurState to Standing.
           xor a
           ld (Arthur_State),a

           ; Update Arthur's x,y coordinates, based on joystick input.
           ld a,(Joystick1)
           bit 2,a
           jp nz,+
           ld hl,Arthur_X
           dec (hl)
           scf
        +: bit 3,a
           jp nz,+
           ld hl,Arthur_X
           inc (hl)
           scf
        +: bit 0,a
           jp nz,+
           ld hl,Arthur_Y
           dec (hl)
           scf
        +: bit 1,a
           jp nz,+
           ld hl,Arthur_Y
           inc (hl)
           scf
        +:
           ; If Arthur has moved, carry flag is set, and we update Arthur's 
           ; state variable in ram (Arthur_State).
           jp nc,+
           ld a,1
           ld (Arthur_State),a
         +:
         
           ; Temporary! Do only proceed if Arthur moves...
           ld a,(Arthur_State)
           cp 0
           ret z


           ; Clear SAT buffer
           ld hl,SATBuffer
           ld bc,32+64
           ld a,0
           call FillMemory

           ; Check Arthur's timer.
           ld a,(Arthur_Timer)
           inc a
           cp 10
           jp nz,++
           ld a,(Arthur_FrameNumber)
           cp 3
           jp nz, +
           ld a,$ff
        +: ; Timer expired - set new frame number, and signal to Loader.
           inc a
           ld (Arthur_FrameNumber),a
           ld a,(Arthur_Status)
           set 0,a
           ld (Arthur_Status),a
           xor a
           ; Put updated timer value back into variable.
       ++: ld (Arthur_Timer),a

           ; Switch according to frame number
           ld a,(Arthur_FrameNumber)
           ld de,_ArthurFrames
           call GetVector
           jp (hl)

_WalkingRight_Frame0:
           ld hl,ArthurWalking_Frame0_Tiles
           ld de,Arthur_TilePointer
           call CopyHL2DE
           ld hl,ArthurWalking_Frame0_Offset
           jp _EndFrame

_WalkingRight_Frame1:
           ld hl,ArthurWalking_Frame1_Tiles
           ld de,Arthur_TilePointer
           call CopyHL2DE
           ld hl,ArthurWalking_Frame1_Offset
           jp _EndFrame

_WalkingRight_Frame2:
           ld hl,ArthurWalking_Frame2_Tiles
           ld de,Arthur_TilePointer
           call CopyHL2DE
           ld hl,ArthurWalking_Frame2_Offset
           jp _EndFrame

_WalkingRight_Frame3:
           ld hl,ArthurWalking_Frame3_Tiles
           ld de,Arthur_TilePointer
           call CopyHL2DE
           ld hl,ArthurWalking_Frame3_Offset
           jp _EndFrame

_EndFrame:
           ; HL points to the frame's data block, so we need to load Arthur's
           ; coordinates into DE (UpdateArthur expects this, along with HL).
           ld a,(Arthur_X)
           ld d,a
           ld a,(Arthur_Y)
           ld e,a
           call UpdateArthur

           ret
_2:
_3:
_4:
_5:
_6:
_7:
_8:

           ret
           _SwitchVectors: .dw _0 _1 _2 _3 _4 _5 _6 _7 _8
           _ArthurFrames: .dw _WalkingRight_Frame0 _WalkingRight_Frame1
                          .dw _WalkingRight_Frame2 _WalkingRight_Frame3
UpdateArthur:
           ; Update the sprite representing a game object (i.e. the player).
           ; HL = pointer to frame data block (offsets, layout, tiles).
           ; D = Object X position (i.e. Player_X), E = Object Y position.

           ; 1: Set the x,y coordinates of the layout grid top left corner.
           ; The grid is offset from the object's x,y coordinates.

           ld b,(hl)
           ld a,d
           sub b
           ld (Arthur_GridX),a
           inc hl
           ld b,(hl)
           ld a,e
           sub b
           ld (Arthur_GridY),a

           ; 2: Push cell numbers to the stack.
           ; Parse the layout table for the given frame, and push the cell
           ; number to the stack every time we come across a cell that will
           ; recieve a hwprite. When we are done, we thus know how many
           ; hwsprites we need to process in step 3.
           inc hl          ; point HL to frame layout
           ld e,0          ; Cell counter.
           ld d,0          ; Hwsprite counter.
           ld c,0          ; Row counter.
       --: ld b,8          ; Column counter.
           ld a,(hl)       ; Load row into A.
        -: rlca            ; Rotate next bit into carry.
           jp nc,+         ; If not set, skip forward.
           inc d           ; Else if set, then increment hwsprite counter,
           push de         ; and push current value of cell counter to stack.
        +: inc e           ; Increment cell counter.
           djnz -          ; Repeat for all 8 columns in the this row.
           inc hl          ; Point to next row.
           inc c           ; Increment row counter.
           bit 3,c         ; Check if this row is 0-7 (layout table height).
           jp z,--         ; If so, go back and parse this row.

           ; 3) Put the sprite's hwsprites in the buffer.
           ; Pop active cells from the stack, and convert each cell number to
           ; y,x coordinates. Put these into the SATBuffer, along with char
           ; codes corresponding to tiles already loaded into vram.
           ld b,d          ; amount of hwsprites identified (and thus amount of pushes).
           ld ix,SATBuffer ; vertical positions.
           ld iy,SATBuffer+32; horizontal positions and char codes.
        -: pop de
           sla e           ; Multiply by two - grid elements are y,x pairs.
           ld hl,OffsetGrid ; Point to offset grid lookup table.
           ld d,0          ; Clear most significant byte, so we can get our
           add hl,de       ; table element by adding HL and DE.
           push hl         ; Preserve table element pointer on the stack.
           ld a,(hl)       ; Read layout grid vpos value into A.
           ld hl,Arthur_GridY ; Apply the frame y-offset.
           add a,(hl)
           ld (ix+0),a     ; Write final vpos value to SAT buffer.
           inc ix          ; Increment pointer to SATBuffer vertcal positions.
           pop hl          ; Retrieve table element pointer.
           inc hl          ; Increment it, so it points to the x-coordinate.
           ld a,(hl)       ; Read this x-coordinate, and
           ld hl,Arthur_GridX ; apply the frame's horizontal offset.
           add a,(hl)
           ld (iy+0),a     ; Write final hpos value to SAT buffer.
           ld (iy+1),b     ; Write the charcode to the SAT buffer.
           inc iy          ; Increment pointer by two.
           inc iy
           djnz -          ; Do this for all the hwsprites identified in
                           ; step 2.
           ret


.ends


; -----------------------------------------------------------------------------
.section "Hub" free
; -----------------------------------------------------------------------------
Hub:       ; Increment loop counter at every loop.
           ld hl,Hub_LoopCounter
           inc (hl)

           ; Decrement timer if it is non-zero, and player 1 is
           ; not pressing start.
           ld a,(Hub_Timer)
           cp 0
           jp z,+
           ld a,(Joystick1)
           bit 4,a
           jp z,+
           ld hl,Hub_Timer
           dec (hl)
+
           ; Read joystick port into ram.
           call ReadJoysticks

           ; Switch according to current game state.
           ld a,(Hub_GameState)
           ld de,_SwitchVectors
           call GetVector
           jp (hl)

_0:        ; State 0:
           ld a,1
           ld (Hub_GameState),a
           ret

_1:        ; State 1:
           ret

_2:
_3:
_4:
_5:
_6:
_7:
_8:

           _SwitchVectors: .dw _0 _1 _2 _3 _4 _5 _6 _7 _8
.ends


; -----------------------------------------------------------------------------
.bank 1 slot 1
.orga $4000
OutiBlock:
           .rept 12*32     ; 384 bytes (12 tiles / 6 full name table rows).
           outi
           .endr
           ret


.section "Bank 1: Music, sfx and misc." free

; Pre-computed (vpos,hpos) offset values to be used with frame layout tables,
; so that hwsprites can get their SAT y,x positions from their layout table
; cell number in a snap. A lookup table.
           OffsetGrid:
           .db 0 0 0 8 0 16 0 24 0 32 0 40 0 48 0 56
           .db 8 0 8 8 8 16 8 24 8 32 8 40 8 48 8 56
           .db 16 0 16 8 16 16 16 24 16 32 16 40 16 48 16 56
           .db 24 0 24 8 24 16 24 24 24 32 24 40 24 48 24 56
           .db 32 0 32 8 32 16 32 24 32 32 32 40 32 48 32 56
           .db 40 0 40 8 40 16 40 24 40 32 40 40 40 48 40 56
           .db 48 0 48 8 48 16 48 24 48 32 48 40 48 48 48 56
           .db 56 0 56 8 56 16 56 24 56 32 56 40 56 48 56 56

; Sound effects and music:
           SFX_Wall: .incbin "Sfx\Wall.psg"
           Intergalactic: .incbin "Music\Intergalactic.psg"

ReleaseNotes:
           .db "Another take on this classic Capcom game. "
           .db "Not so square!" 0


.ends


; -----------------------------------------------------------------------------
.bank 2 slot 2
.section "Bank 2: Data" free
           .include "Bank2Data.inc"
.ends

; -----------------------------------------------------------------------------
.bank 3 slot 2
.section "Unused bank" free

.ends
