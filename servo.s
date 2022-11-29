#include <xc.inc>

global servoStep, checkInterrupt, servoSetup

psect	udata_acs
    counter:	ds 1
    pulse_length: ds 1
psect	servo_code, class=CODE

servoSetup:
    clrf    TRISC   ; set PORTD to output
    clrf    LATC   ; set PORTD to 0
    movlw   11000110B	; set timer 0 to 8-bit using instruction clock (Fosc/4) with prescale of 12. This gives ~16 ms rollover
    movwf   T0CON, A	; 2MHz clock-rate
    
    bsf	    TMR0IE	; enable interrupts
    bsf	    GIE		; enable global interrupts
    return

servoStep:
    return

checkInterrupt:
    btfss   TMR0IF  ; check interrupt flag
    retfie  f	    ; return if flag is not set
    setf    LATC    ; set PORTD to 1
    call    servo_pulse
    clrf    LATC    ; set PORTD to 0
    bcf	    TMR0IF
    retfie  f	    ; fast return

servo_pulse:	    ; raise the voltage for enough time to rotate the servo
    movlw   0x25    ; pulse length of 0x16 timer rotations sets the servo to level, 0x25 for 90 degrees
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
