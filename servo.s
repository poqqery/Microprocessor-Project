#include <xc.inc>

global checkInterrupt, servoSetup

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
    
checkInterrupt:
    btfss   TMR0IF  ; check interrupt flag
    retfie  f	    ; return if flag is not set
    call servoLower
    call servoUpper
    bcf	    TMR0IF
    retfie  f	    ; fast return

pulseLower:
    movlw   0x27
    movwf   pulseLower_length
    pulseLower_loop:
	movf    TMR0L, W, A
	cpfslt  pulseLower_length
	bra	pulseLower_loop
    return

pulseUpper:
    movlw   0x27
    movwf   pulseUpper_length
    pulseUpper_loop:
	movf    TMR0L, W, A
	subfwb	pulseLower_length, W ; set a different 0 time for the upper pulse
	cpfslt  pulseUpper_length
	bra	pulseUpper_loop
    return
    
servo_pulse:	    ; raise the voltage for enough time to rotate the servo
    movlw   0x28    ; pulse length of 0x16 timer rotations sets the servo to level, 0x25 for 90 degrees
    movwf   pulse_length
    pulse_loop:
	movf    TMR0L, W, A
	cpfslt  pulse_length
	bra	pulse_loop
    return
    
delay:
    movlw   0xFF
    movwf   counter
    delay_loop:
	decfsz	counter
	bra delay_loop
    return
