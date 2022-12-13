#include <xc.inc>

extrn photo_res

global gradient, findGradient, servoPosUpper, servoPosLower, findPosUpper, findPosLower
    
psect udata_acs
gradient:	ds 1
servoPosUpper:	ds 1
servoPosLower:	ds 1
psect calc_code, class=CODE

findGradient:
    ; FSR1 should be pointed at high byte of first photodiode in pair - high byte before low byte in file registers
    ; FSR2 should be pointed at high byte of second photodiode in pair - high byte before low byte in file registers
    movf    INDF1, W, A		    ; load high byte for comparison
    cpfseq  INDF2		    ; checks if low byte comparison to determine gradient direction is necessary - also gets rid of unecessary subtraction for actual gradient calc.
    bra	    bytes_different
    ; do low byte comparison
    movf    PREINC1, W, A	    ; point at low byte and then perform comparison between the diode values
    cpfseq  PREINC2
    bra	    bytes_different	    ; the code for low_bytes_different would be the exact same since FSRs are pointed there - currently only doing comparison not math
    movlw   0x01
    movwf   gradient
    return
    bytes_different:
	cpfsgt	INDF2
	bra	byte_less
	bra	byte_greater
    byte_greater:		    ; find the gradient difference using the high byte - currently just finds the direction of the gradient
	movlw	0x02
	movwf	gradient
	return
    byte_less:			    ; find the gradient difference using the high byte - currently just finds the direction of the gradient
	movlw	0x00
	movwf	gradient
	return


findPosUpper:
    movlw   0x01		    ; load in value for equal gradient - if higher, adjust up, if lower adjust down
    cpfseq  gradient
    bra	    adjustUpperPos
    return
    adjustUpperPos:	
	cpfsgt	gradient
	bra	moveUpperDown
	bra	moveUpperUp
    moveUpperUp:
	movlw	0x95		    ; limit position to prevent overextension
	cpfsgt	servoPosUpper
	incf	servoPosUpper
	return
    moveUpperDown:
	movlw	0x60		    ; limit position to prevent underextension and self destruction
	cpfslt	servoPosUpper
	decf	servoPosUpper
	return

findPosLower:			    ; same code as for upper servo, with different movement range limits
    movlw   0x01
    cpfseq  gradient
    bra	    adjustLowerPos
    return
    adjustLowerPos:
	cpfsgt	gradient
	bra	moveLowerDown
	bra	moveLowerUp
    moveLowerUp:
	movlw	0xA0
	cpfsgt	servoPosLower
	incf	servoPosLower
	return
    moveLowerDown:
	movlw	0x20
	cpfslt	servoPosLower
	decf	servoPosLower
	return