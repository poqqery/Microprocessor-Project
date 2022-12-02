#include <xc.inc>
    
extrn	ADC_Setup, ADC_Read

global	photo_res

psect	udata_acs
diode_number:	ds 1
counter:    ds 1
photo_res:  ds 8

psect	photo_meas, class = CODE

photo_setup:
    call ADC_Setup
    movlw   0x04
    movwf   diode_number
    
measure:
    movff   diode_number, counter, A
    lfsr    0, photo_res
    movlw	0x00			; load 0 into W for counter comparison later; this should reduce runtime.
    measure_loop:
	call ADC_Read
	decf	counter
	movff   ADRESH, POSTINC0, A
	movff   ADRESL, POSTINC0, A
	cpfseq	counter
	bra measure_loop
return


