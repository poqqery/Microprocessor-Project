#include <xc.inc>

global servoSetup, servoUpper, servoLower
extrn servoPosUpper, servoPosLower
psect	udata_acs
    counter:	ds 1
    pulse_length: ds 1
    pulseLower_length: ds 1
    pulseUpper_length: ds 1
psect	servo_code, class=CODE

servoSetup:
    
    clrf    TRISC   ; set PORTC to output
    clrf    LATC    ; set PORTC to 0
    clrf    TRISD   ; set PORTD to output
    clrf    LATD    ; set PORTD to 0
    ;mfer i know you're tryna change the clock, DO NOT CHANGE THE CLOCK
    movlw   11000110B	; set timer 0 to 8-bit using instruction clock (Fosc/4) with prescale of 12. This gives ~16 ms rollover
    movwf   T0CON, A	; 2MHz clock-rate
    
    bsf	    TMR0IE	; enable interrupts
    bsf	    GIE		; enable global interrupts
    
    movlw   0x22
    movwf   servoPosUpper
    movwf   servoPosLower
    return

servoUpper:
    setf    LATC	; set PORTC high
    call    pulseUpper	; wait for duty cycle
    clrf    LATC	; set PORTC low
    return

servoLower:
    setf    LATD	; set PORTD high
    call    pulseLower	; wait for 
    clrf    LATD	; set PORTD low
    return
    


pulseLower:			    ; raise the voltage for enough time to rotate the lower servo
    movff   servoPosLower, pulseLower_length, A
    pulseLower_loop:
	movf    TMR0L, W, A
	cpfslt  pulseLower_length
	bra	pulseLower_loop
    return

pulseUpper:			    ; raise the voltage for enough time to rotate the upper servo
    movff   servoPosUpper, pulseUpper_length, A
    pulseUpper_loop:
	movf    TMR0L, W, A
	subfwb	pulseLower_length, W ; set a different 0 time for the upper pulse
	cpfslt  pulseUpper_length
	bra	pulseUpper_loop
    return
    

    
delay:
    movlw   0xFF
    movwf   counter
    delay_loop:
	decfsz	counter
	bra delay_loop
    return
