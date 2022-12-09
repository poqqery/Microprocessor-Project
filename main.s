CONFIG  XINST = OFF            ; Extended Instruction Set (Disabled)

#include <xc.inc>

extrn servoSetup, servoLower, servoUpper
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
    goto $

checkInterrupt:
    btfss   TMR0IF  ; check interrupt flag
    retfie  f	    ; return if flag is not set
    call servoLower
    call servoUpper
    call photo_loop
    bcf	    TMR0IF
    retfie  f	    ; fast return
    
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
    return
	
end rst