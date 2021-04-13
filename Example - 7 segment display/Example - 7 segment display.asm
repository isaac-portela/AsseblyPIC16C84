; Example - 7 segment display
;--------------------------------

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

TC0		equ	0x10
TC1		equ	0x11
TC2		equ	0x12


;-------------------------------------------------------------------------------

org	0x00
	goto	init

;-------------------------------------------------------------------------------
; Init code
;-------------------------------------------------------------------------------
org	0x20

init	bsf	Status,RP0
	movlw	b'11100000'		;configure PortB
	movwf	TrisB
	movlw	b'00000000'		;configure PortA
	movwf	TrisA
	bcf	Status,RP0
	clrf	PortB
	bsf	PortB,4

;------------------------------------------------------------------------------
; Main loop
;------------------------------------------------------------------------------

main	incf	PortB,r
	movf	PortB,w
	sublw	0x1A
	btfsc	Status,z
	clrf	PortB
	bcf	PortB,4
	nop
	nop
	bsf	PortB,4
	call	delay
	goto 	main
	
;-----------------------------------------------------------------------------
delay
	movlw	0x02
	movwf	TC0
_1s_0	movlw	0xff
	movwf	TC1
_1s_1	movlw	0xff
	movwf	TC2
_1s_2	decfsz	TC2,r
	goto	_1s_2
	decfsz	TC1,r
	goto	_1s_1
	decfsz	TC0,r
	goto	_1s_0
	return



	end
