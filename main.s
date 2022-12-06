CONFIG  XINST = OFF            ; Extended Instruction Set (Disabled)

#include <xc.inc>

extrn checkInterrupt, servoSetup
extrn measure, photo_res, photo_setup
extrn gradient, findGradient, findPosUpper, findPosLower
psect code, abs
rst:	org 0x0000
	goto start

int_hi: org 0x0008
	goto checkInterrupt

start:
    call servoSetup 
    call photo_setup
    photo_loop:
	call measure
	lfsr	1, photo_res
	lfsr	2, photo_res + 2
	call findGradient
	call findPosUpper		; changes servo position variable - servo adjusts automatically due to interrupts
	lfsr	1, photo_res + 4
	lfsr	2, photo_res + 6
	call findGradient
	call findPosLower
	bra photo_loop
	
end rst