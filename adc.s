#include <xc.inc>
    
global ADC_Setup, ADC_Read


psect	adc_code, class = CODE

ADC_Setup:
    bsf	TRISA, PORTA_RA0_POSN, A    ; set pin A0 to analogue channel 0
    movlb   0x0F
    bsf	ANSEL0			    ; set pin at analogue channel 0 to analogue input
    movlb   0x00
    movlw   0x01
    movwf   ADCON0, A
    movlw   0x30
    movwf   ADCON1, A
    movlw   0xF6
    movwf   ADCON2, A
    return

ADC_Read:
    bsf	    GO			    ; start conversion by setting GO bit in ADCON0
    adc_loop:
	btfsc	GO		    ; check to see if finished
	bra adc_loop
	return

end
	

