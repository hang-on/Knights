; --------------------------------------------------------------
.section "Prepare VRAM" free
; --------------------------------------------------------------
; PREPARE VRAM.
; Set up vdp to recieve data at vram address in HL.
PrepareVRAM:
           push af
           ld a,l
           out ($bf),a
           ld a,h
           or $40
           out ($bf),a
           pop af
           ret
.ends

; --------------------------------------------------------------
.section "Load VRAM" free
; --------------------------------------------------------------
; LOAD VRAM.
; Load BC amount of bytes from data source pointed to by HL.
; Tip: Prepare VRAM before calling.
LoadVRAM:
           ld a,(hl)
           out ($be),a
           inc hl
           dec bc
           ld a,c
           or b
           jp nz,LoadVRAM
           ret
.ends

; --------------------------------------------------------------
.section "Fill memory" free
; --------------------------------------------------------------
; FILL MEMORY.
; Overwrite a chunk of memory with a specified byte value.
; HL = base address, BC = area size, A = fill byte.
FillMemory:
           ld (hl),a
           ld d,h
           ld e,l
           inc de
           dec bc
           ld a,b
           or c
           ret z
           ldir
           ret
.ends

; --------------------------------------------------------------
.section "Set VDP Register" free
; --------------------------------------------------------------
; SET VDP REGISTER.
; Write to target register.
; A = byte to be loaded into vdp register.
; B = target register 0-10.
SetRegister:
           out ($bf),a
           ld a,$80
           or b
           out ($bf),a
           ret
.ends

; --------------------------------------------------------------
.section "Get Vector" free
; --------------------------------------------------------------
; GET VECTOR.
; Vector table based switch-like control structure.
; A = expression, DE = vector table (word-sized vectors).
; Return vector in HL for a jp (hl) opcode.
GetVector:
           sla a
           ld h,0
           ld l,a
           add hl,de
           ld a,(hl)
           inc hl
           ld h,(hl)
           ld l,a
           ret
.ends

; --------------------------------------------------------------
.section "Wait for frame interrupt" free
; --------------------------------------------------------------
; WAIT FOR FRAME INTERRUPT.
; This will wait exclusively for the frame interrupt.
; Unlike the 'halt' opcode.
WaitForFrameInterrupt:
           ld a,(FrameInterruptFlag)
           or a
           jp z,WaitForFrameInterrupt
           xor a
           ld (FrameInterruptFlag),a
           ret
.ends

; --------------------------------------------------------------
.section "Point DE to value in HL" free
; --------------------------------------------------------------
; The 16-bit value in HL is copied LSB to DE. This makes it possible to point 
; HL to an address, and then 'save' this pointer in the ram location that is
; DE.
CopyHL2DE:
           ld a,l
           ld (de),a
           ld a,h
           inc de
           ld (de),a
           ret
.ends
; --------------------------------------------------------------
.section "Read Joysticks" free
; --------------------------------------------------------------
; READ JOYSTICKS.
; Read the two joystick ports (port $dc and $dd) into ram.

ReadJoysticks:
           in a,$dc
           ld (Joystick1),a
           in a,$dd
           ld (Joystick2),a
           ret
.ends



