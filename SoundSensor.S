#include <xc.h>  
.section .text
.global SoundSensor
    
; Code from the ATmega328P datasheet and course textbook were modified to create this project. 
; Credit goes to their respective authors.
; Atmel. ?ATmega328P Datasheet.? 2015. Atmel. Manual.
; Mazidi, Muhammad Ali, et al. The AVR Microcontroller and Embedded Systems: Using Assembly and C. MicroDigitalEd, 2017.
; Written by Jarod Anjelo Lustre. Fall 2022.
    
SoundSensor:
    cbi _SFR_IO_ADDR(PORTD), 4
    sbi _SFR_IO_ADDR(DDRD), 4
    ldi r16, 0x42		;0x62 = 01100010, 0x42 = 01000010 (ADMUX)
    sts ADMUX, r16		;set ADMUX to accept input from sound sensor
    ldi r16, 0x87
    sts ADCSRA, r16		;initialize ADCSRA
    
USART_Init:			;init USART in MSPI mode (master SPI)
		
    ldi r18, (1<<TXEN0)		;Enable transmitter.
    sts UCSR0B,r18
				;Set baud rate.
    ldi r16, (1<<UCSZ01)|(1<<UCSZ00) ;async 8-bit data, 1 stop bit
    sts UCSR0C, r16
    ldi r16, 103		;103 -> 9600 baud rate for 8MHz CLK when U2X bit = 1
    sts UBRR0L, r16		;IMPORTANT: The Baud Rate must be set after the transmitter is enabled!

READ_ADC:
    ldi r16, 0x87|(1<<ADSC) 
    sts ADCSRA, r16		;start the ADC conversion by setting the ADSC bit to 1

KEEP_POLLING:
    lds r16, ADCSRA
    sbrs r16, ADIF		;loop until ADIF bit is 1 (skip if bit in reg is set)
    rjmp KEEP_POLLING
    lds r18, ADCL		;store contents of ADC LOW in r18 (always read ADC low first) 
    lds r19, ADCH		;store contents of ADC HIGH in r19 
    sts adcLo, r18		;store adc low
    sts adcHi, r19		;store adc high
    
    ;if ADC value >= 512 (0b1000000000)
    ;turn on LED
    cpi r19, 2			;compare ADCH value with 2
    brlt polling_else		;branch if ADCH is lower than 2(0b10)
    rjmp SET_LED		;if statement passes, set LED
    
polling_else:
    cbi _SFR_IO_ADDR(PORTD), 4  ;else keep it off
    rjmp READ_ADC	        ;keep reading ADC
    
SET_LED:
    sbi _SFR_IO_ADDR(PORTD), 4
    rcall NOISE_WARNING
    rcall TIMER1_DELAY
    rcall TIMER1_DELAY		;delay 2 seconds
    clr r19			;clear register
set_led_cont:
    rjmp READ_ADC


TIMER1_DELAY:
    ldi r20, 0x00
    sts TCNT1H, r20
    sts TCNT1L, r20		
    ldi r20, hi8(31250-1)	;1s delay, XTAL = 8Mhz. 31250 clock cycles for clk/256
    sts OCR1AH, r20		
    ldi r20, lo8(31250-1)
    sts OCR1AL, r20
    
    ldi r20, 0x00
    sts TCCR1A, r20
    ldi r20, 0x4		;set normal mode with 256 prescaler
    sts TCCR1B, r20		;responsible for mode setting
    
AGAIN:
    sbis _SFR_IO_ADDR(TIFR1), OCF1A
    rjmp AGAIN
    ldi r19, 0
    sts TCCR1B, r19
    sts TCCR1A, r19		;stop timer
    ldi r19, 0
    ldi r20, 1<<OCF1A
    out _SFR_IO_ADDR(TIFR1), r20 ;clear OCF1A flag
    ret

USART_Transfer:			
    lds r16, UCSR0A		;is data buffer empty?
    sbrs r16, UDRE0		;if yes, loop; if no, store a new value
    rjmp USART_Transfer
    sts UDR0,r26		;Put data (r26) into buffer, sends the data
    ret

NOISE_WARNING:			;Warning message
    ldi r26, 'P'
    rcall USART_Transfer    
    ldi r26, 'O'
    rcall USART_Transfer
    ldi r26, 'T'
    rcall USART_Transfer
    ldi r26, 'E'
    rcall USART_Transfer
    ldi r26, 'N'
    rcall USART_Transfer
    ldi r26, 'T'
    rcall USART_Transfer
    ldi r26, 'I'
    rcall USART_Transfer
    ldi r26, 'A'
    rcall USART_Transfer
    ldi r26, 'L'
    rcall USART_Transfer
    ldi r26, 'L'
    rcall USART_Transfer
    ldi r26, 'Y'
    rcall USART_Transfer
    ldi r26, ' '
    rcall USART_Transfer
    ldi r26, 'D'
    rcall USART_Transfer
    ldi r26, 'A'
    rcall USART_Transfer
    ldi r26, 'N'
    rcall USART_Transfer
    ldi r26, 'G'
    rcall USART_Transfer
    ldi r26, 'E'
    rcall USART_Transfer
    ldi r26, 'R'
    rcall USART_Transfer
    ldi r26, 'O'
    rcall USART_Transfer
    ldi r26, 'U'
    rcall USART_Transfer
    ldi r26, 'S'
    rcall USART_Transfer
    ldi r26, ' '
    rcall USART_Transfer
    ldi r26, 'N'
    rcall USART_Transfer
    ldi r26, 'O'
    rcall USART_Transfer
    ldi r26, 'I'
    rcall USART_Transfer
    ldi r26, 'S'
    rcall USART_Transfer
    ldi r26, 'E'
    rcall USART_Transfer
    ldi r26, ' '
    rcall USART_Transfer
    ldi r26, 'D'
    rcall USART_Transfer
    ldi r26, 'E'
    rcall USART_Transfer
    ldi r26, 'T'
    rcall USART_Transfer
    ldi r26, 'E'
    rcall USART_Transfer
    ldi r26, 'C'
    rcall USART_Transfer
    ldi r26, 'T'
    rcall USART_Transfer
    ldi r26, 'E'
    rcall USART_Transfer
    ldi r26, 'D'
    rcall USART_Transfer
    ldi r26, '\n'
    rcall USART_Transfer
    ret
ret

     
.end
    
    