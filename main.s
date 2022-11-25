#include <xc.inc>

extrn servoStep, checkInterrupt, servoSetup
psect code, abs
rst:	org 0x0000
	goto start

int_hi: org 0x0008
	goto checkInterrupt

start:
    goto $
	
end rst