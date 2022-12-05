#include <xc.inc>
    
extrn	ADC_Setup, ADC_Read, select_pin0, pinShiftUp

global	photo_res, photo_setup, measure

psect	udata_acs
diode_number:	ds 1
counter:    ds 1
photo_res:  ds 8

psect	photo_meas, class = CODE

photo_setup:
    call ADC_Setup
    movlw   0x04
    movwf   diode_number
    return
    
measure:
    clrf    counter, A
    lfsr    0, photo_res
    movf    diode_number, W, A			; load diode number into W for comparison in loop
    call select_pin0
    measure_loop:
	call ADC_Read
	incf	counter
	movff   ADRESH, POSTINC0, A
	movff   ADRESL, POSTINC0, A
	call pinShiftUp
	cpfseq	counter
	bra measure_loop
return


