CONFIG  XINST = OFF            ; Extended Instruction Set (Disabled)

#include <xc.inc>

extrn servoSetup, servoLower, servoUpper
extrn measure, photo_res, photo_setup
extrn gradient, findGradient, findPosUpper, findPosLower, servoPosUpper, servoPosLower, findPosPD
extrn UART_Setup, UART_Transmit_Byte
psect udata_acs
interrupt_counter: ds 1
transmission_bool:  ds 1
psect code, abs
rst:	org 0x0000
	goto start

int_hi: org 0x0008
	goto checkInterrupt

start:
    call servoSetup		    ; set up code for the servos and the photodiode measurements
    call photo_setup
    call UART_Setup
    
    movlw   0x00		    ; set up the counters for servo pulsing and transmission - interrupts trigger too frequently, and we cannot use a different clock since that makes UART unintelligible
    movwf   interrupt_counter	    
    movwf   transmission_bool
    
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
	movlw	0x00
	cpfsgt	interrupt_counter
	bra	send_data
	incf	interrupt_counter
	retfie	f
	send_data:			; this branch sends the position of the upper servo out via UART
	    incf	interrupt_counter
	    movlw   0xFF
	    cpfseq  transmission_bool
	    bra	    send_upper
	    bra	    send_lower
	    send_upper:
		movf    servoPosUpper, W, A
		call UART_Transmit_Byte
		movlw	0xFF
		movwf	transmission_bool
		retfie f
	    send_lower:
		movf    servoPosLower, W, A
		call UART_Transmit_Byte
		movlw	0x00
		movwf	transmission_bool
		retfie f
    servo_interrupt:			; send a pulse to the servos
	call photo_main			; measure the gradient to adjust servo positions
	call servoLower			; pulse the lower servo
	call servoUpper			; pulse the upper servo
	clrf    interrupt_counter
	retfie  f	    ; fast return
    
photo_main:
    call measure
    ;call findPosPD
    return


	
end rst