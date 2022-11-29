CONFIG  XINST = OFF            ; Extended Instruction Set (Disabled)

#include <xc.inc>

extrn checkInterrupt, servoSetup
psect code, abs
rst:	org 0x0000
	goto start

int_hi: org 0x0008
	goto checkInterrupt

start:
    call servoSetup
    goto $
	
end rst