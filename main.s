CONFIG  XINST = OFF            ; Extended Instruction Set (Disabled)

#include <xc.inc>

extrn servoSetup, servoLower, servoUpper
extrn measure, photo_res, photo_setup
extrn gradient, findGradient, findPosUpper, findPosLower, servoPosUpper, servoPosLower
extrn UART_Setup, UART_Transmit_Byte
psect udata_acs
interrupt_counter: ds 1
transmission_counter: ds 1
psect code, abs
rst:	org 0x0000
	goto start

int_hi: org 0x0008
	goto checkInterrupt

start:
    call servoSetup		    ; set up code for the servos and the photodiode measurements
    call photo_setup
    
    movlw   0x00		    ; set up the counters for servo pulsing and transmission - interrupts trigger too frequently, and we cannot use a different clock since that makes UART unintelligible
    movwf   interrupt_counter	    
    movwf   transmission_counter
    call UART_Setup
    goto $

checkInterrupt:
    btfss   TMR0IF  ; check interrupt flag
    retfie  f	    ; return if flag is not set
    bcf	    TMR0IF  ; clear the timer interrupt flag for next time
    movlw   0x03		    ; check if enough interrupts have triggered for a servo pulse
    cpfseq  interrupt_counter
    bra no_servo_interrupt	    ; the UART triggers when there is no servo pulse to avoid using too much time in a single interrupt window
    bra	servo_interrupt
    no_servo_interrupt:
	incf	interrupt_counter
	movlw	0x60			; the UART sends data every 96th interrupt
	cpfseq	transmission_counter	; comparing how many interrupts have triggered since the last time data was sent
	bra send_data
	incf	transmission_counter
	retfie f
	send_data:			; this branch sends the position of the upper servo out via UART
	    movf    servoPosUpper, W, A
	    call UART_Transmit_Byte
	    clrf    transmission_counter    ; clear interrupts since last transmission
	    retfie f
    servo_interrupt:			; send a pulse to the servos
	call photo_main			; measure the gradient to adjust servo positions
	call servoLower			; pulse the lower servo
	call servoUpper			; pulse the upper servo
	clrf    interrupt_counter
	retfie  f	    ; fast return
    
photo_main:
    call measure
    lfsr	1, photo_res
    lfsr	2, photo_res + 2
    call findGradient
    call findPosUpper		; changes servo position variable - servo adjusts automatically due to interrupts
    lfsr	1, photo_res + 4
    lfsr	2, photo_res + 6
    call findGradient
    call findPosLower
    return

end rst