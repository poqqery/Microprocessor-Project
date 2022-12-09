#include <xc.inc>
    
global ADC_Setup, ADC_Read, select_pin0, pinShiftUp


psect	adc_code, class = CODE

ADC_Setup:
    setf    TRISA		    ; set port A to input
    movlb   0x0F
    setf    ANCON0
    movlb   0x00
    movlw   0x01
    movwf   ADCON0, A
    movlw   00110000B		    ; use 2.048 voltage reference
    movwf   ADCON1, A
    movlw   11110110B		    ; right justified outputs, set clock and acquisition times to Fosc/64
    movwf   ADCON2, A
    return

select_pin0:
    movlw   00000001B
    movwf   ADCON0, A
    return
select_pin1:
    movlw   00000101B
    movwf   ADCON0, A
    return
select_pin2:
    movlw   00001001B
    movwf   ADCON0, A
    return
select_pin3:
    movlw   00001101B
    movwf   ADCON0, A
    return
pinShiftUp:
    movlw   0x04	;increment 4s place in ADCON0
    addwf   ADCON0, F
    return
    
ADC_Read:
    bsf	    GO			    ; start conversion by setting GO bit in ADCON0
    adc_loop:
	btfsc	GO		    ; check to see if finished
	bra adc_loop
	return

end
	

