#include <xc.inc>

global servoStep, checkInterrupt, servoSetup

psect	udata_acs
    counter:	ds 1
psect	servo_code, class=CODE

servoSetup:
    clrf    TRISD   ; set PORTD to output
    clrf    LATD    ; set PORTD to 0
    movlw   10000000B	; set timer 0 to 16-bit/Fosc/4/256
    movwf   T0CON, A	; 2MHz clock-rate
    bsf	    TMR0IE	; enable interrupts
    bsf	    GIE		; enable global interrupts
    return

servoStep:
    return

checkInterrupt:
    btfss   TMR0IF  ; check interrupt flag
    retfie  f	    ; return if flag is not set
    retfie  f	    ; fast return
    
delay:
    movlw   0x0F
    movwf   counter
    delay_loop:
	decfsz	counter
	bra delay_loop
    return
