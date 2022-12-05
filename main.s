CONFIG  XINST = OFF            ; Extended Instruction Set (Disabled)

#include <xc.inc>

extrn checkInterrupt, servoSetup, measure, photo_res, photo_setup
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
	bra photo_loop
	
end rst