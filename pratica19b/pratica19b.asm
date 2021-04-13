; Template file for PIC16F84 (pic16f84 template.asm)
;		 ________
;		|	 |
; 	      <-| A0  B0 |-< 
; 	      <-| A1  B1 |-< 
; 	      <-| A2  B2 |-< 
;	      <-| A3  B3 |-<
;	      <-| A4  B4 |-< 
;		|     B5 |-<
;		|     B6 |-<
;		|     B7 |-<
;		|________|
;

r		equ	0x01
w		equ	0x00

c		equ	0x00
dc		equ	0x01
z		equ	0x02
RP0		equ	0x05

; Special function register in Bank 0
INDF		equ	0x00
TMR0		equ	0x01
Status		equ	0x03
FSR		equ	0x04
PortA		equ	0x05
PortB		equ	0x06
Intcon		equ	0x0B

; Special function register in Bank 1
OptionR		equ	0x01
TrisA		equ	0x05
TrisB		equ	0x06

; Interrupt bits
GIE		equ	7	;Global Interrupt enabled/disable
INTE		equ	4	;RB0 interrupten enabled/disable
INTF		equ	1	;RB0 interrupten has occured
T0IE		equ	5	;TMR0 int enabled/disable
T0IF		equ	2	;TMR0 int has occured

; EEPROM registers
EEcon1		equ	0x08	;EEPROM control register 1
EEcon2		equ	0x09	;EEPROM control register 1
EEdata		equ	0x08	;EEPROM data register
EEadr		equ	0x09	;EEPROM address register

; EEProm bits
RD		equ	0x00
WR		equ	0x01
WREN		equ	0x02

; File registers
w_temp		equ	0x0C	; register used in interrupt handling
status_temp	equ	0x0D



;-------------------------------------------------------------------------------

org	0x00
	goto	init

;-------------------------------------------------------------------------------
; Interrupt handling
;-------------------------------------------------------------------------------
org	0x04

push	movwf	w_temp			;save w & status 
	swapf	Status,W
	movwf	status_temp
	

pop	swapf	status_temp,W		; restore w & status
	movwf	Status
	swapf	w_temp, r
	swapf	w_temp, W
	retfie


;-------------------------------------------------------------------------------
; Init code
;-------------------------------------------------------------------------------
org	0x20

init	bsf	Status,RP0
	movlw	b'11100000'		;configure PortB
	movwf	TrisB
	movlw	b'00011111'		;configure PortA
	movwf	TrisA
	bcf	Status,RP0

	goto	main

;------------------------------------------------------------------------------
; Main loop
;------------------------------------------------------------------------------

main	
	bcf PortB, 4
	movlw 0x00

	btfsc PortA, 1
	movlw 0x01
	
	btfsc PortA, 2
	movlw 0x02

	btfsc PortA, 3
	movlw 0x03

	btfsc PortA, 4
	movlw 0x04
	
	movwf PortB

	bsf PortB, 4
	

	goto 	main
	
;-----------------------------------------------------------------------------

	end
