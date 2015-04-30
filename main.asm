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

; Organize variables:
           ; Variables are reset to 0 as part of the general memory 
           ; initialization.
           .enum $c000 export
           SATBuffer dsb 32 + 64
           FrameInterruptFlag db
           VDPStatus db
           Joystick1 db
           Joystick2 db

           Hub_GameState db
           Hub_Status db
           Hub_LoopCounter db
           Hub_Timer db

           .ende

; Libray of minor routines:
           .include "MinorRoutines.inc"

; sverx's PSG library:
           .include "PSGlib.inc"

; Beginning of ROM:
.bank 0 slot 0
.org 0
           di
           im 1
           ld sp,$dff0
           jp InitializeFramework

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
           ld b,7
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
           call Loader                                                        ;
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


           ; Load Arthur's tiles @ index 257.
           ld hl,$2020
           call PrepareVRAM
           ld hl,Arthur_Standing_Tiles
           ld bc,27 * 32
           call LoadVRAM

           ; Load playfield/background colors into bank 1.
           ;ld hl,$c000
           ;call PrepareVRAM
           ;ld hl,PlayfieldPalette
           ;ld bc,14
           ;call LoadVRAM

           ; Load sprite colors into bank 2.
           ld hl,$c010
           call PrepareVRAM
           ld hl,Arthur_Palette
           ld bc,12
           call LoadVRAM


           ret


_1:        ; Run level.
           ; Enable display.
           ld a,%11100000
           ld b,1
           call SetRegister
           
           ; Load 32 hwsprites' vertical positions.
           ld hl,$3f00
           call PrepareVRAM
           ld hl,SATBuffer
           call TurboLoad32

           ; Load 32 hwsprites' horizontal positions and charcodes.
           ld hl,$3f80
           call PrepareVRAM
           ld hl,SATBuffer+32
           call TurboLoad64

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
.section "Bank 1: Music, sfx and misc." free

SFX_Wall .incbin "Wall.psg"

IntergalacticTableTennis .incbin "IntergalacticTableTennis.psg"

ReleaseNotes:
           .db "Another take on this classic Capcom game."
           .db " Not so square!" 0


.ends


; -----------------------------------------------------------------------------
.bank 2 slot 2
.section "Bank 2: Data" free
           .include "Data.inc"
.ends

; -----------------------------------------------------------------------------
.bank 3 slot 2
.section "Unused bank" free

.ends
