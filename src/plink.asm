.include "m168def.inc"

.org 0
rjmp RESET


RESET:
	ldi r16, LOW(RAMEND)				; Set stack pointer to top of RAM
	ldi r17, HIGH(RAMEND)
	out SPL, r16
	out SPH, r17

	ldi r16, (1<<PORTD5) | (1<<PORTD6)	; set port D5:6 pwm output direction
	out DDRD, r16

	;ldi r16, (1<<CS00)
	;out TCCR0B, r16

	;ldi r16, (1<<WGM00) | (1<<COM0A1)
	;out TCCR0A, r16

	;ldi r16, 0x80
	;out OCR0A, r16

	;ldi r16, 0xFF;(1<<PORTB3)
	;out DDRB, r16

	ldi r16, (1<<PORTB1)				; set port B1 pwm to output
	out DDRB, r16

	;ldi r16, (1<<PRTIM0) | (1<<PRTIM2) | (1<<PRADC)	; turn off power saving for DAC and PWM
	;com r16
	;sts PRR, r16

	ldi r16, (1<<CS00) | (1<<CS01) 		; set pwm 0 prescaler to clock/64
	out TCCR0B, r16						; and start PWM

	ldi r16, (1<<COM0A1) | (1<<WGM00) | (1<<COM0B1) ; Set phase correct PWM on both Port D outputs
	out TCCR0A, r16
	
	;ldi r16, (1<<COM2A1) | (1<<WGM20) | (1<<COM2B1)	; set phase correct PWM on port B output 3
	;sts TCCR2A, r16

	;ldi r16, (1<<CS20);(1<<CS22)					; set pwm 2 prescaler to clock/64
	;sts TCCR2B, r16

	ldi r16, (1<<COM1A1) | (1<<WGM10) | (1<<COM1B1)	; set phase correct PWM on timer 1
	sts TCCR1A, r16

	ldi r16, (1<<CS10) | (1<<CS11)					; set pwm 2 prescaler to clock/64
	sts TCCR1B, r16



	ldi r16, (1<<ADPS2) | (1<<ADPS1) | (1<<ADEN)	; set AD prescaler to clk/64 and enable
	sts ADCSRA, r16

	ldi r16, (1<<REFS0) | (1<<ADLAR)	; left shift ADR result, AVCC Vref, ADC input 0
	sts ADMUX, r16

	ldi r16, (1<<ADC0D) | (1<<ADC1D) | (1<<ADC2D)
	sts DIDR0, r16

	ldi r16, 0x80
	out OCR0A, r16

	ldi r16, 0x80
	out OCR0B, r16

	;ldi r16, 0x80
	;sts OCR2A, r16

	;ldi r16, 0x80
	;sts OCR2B, r16


	ldi r16, 0x80
	sts OCR1AL, r16

	;ldi r16, 0x80
	;sts OCR2B, r16

LOOP:

	; choose ADC input 0
	lds r16, ADMUX
	cbr r16, 0x0F
	sts ADMUX, r16

	call readadc			; read from input 0

	out OCR0A, r22			; store result in PWM channel 0A

	lds r16, ADMUX
	inc r16
	sts ADMUX, r16

	call readadc			; read from input 1

	out OCR0B, r22			; store result in PWM channel 0B

	lds r16, ADMUX
	inc r16
	sts ADMUX, r16

	call readadc			; read from input 2

	sts OCR1AL, r22			; store result in PWM channel 1A

	rjmp LOOP				


readadc:
	lds r16, ADCSRA			; start adc conversion
	ori r16, (1<<ADSC)
	sts ADCSRA, r16
waitadc:
	lds r16, ADCSRA			; wait for conversion to finish
	sbrc r16, ADSC
	rjmp waitadc

	lds r22, ADCH 			; store result in r22
	
	ret
