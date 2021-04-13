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

;       STATUS REGISTER BITS
        #DEFINE CARRY   0X03,0                   ;CARRY FLAG
        #DEFINE DCARRY  0X03,1                   ;DECIMAL CARRY FLAG
        #DEFINE ZERO    0X03,2                   ;ZERO FLAG
        #DEFINE RPAGE   0X03,5                   ;REGISTER PAGE SELECT

        #DEFINE COL     0030                    

	#DEFINE ROW     0031
        #DEFINE DELAY0  0032                    ;PAGE 0  DELAY LOOP COUNTER
        #DEFINE DELAY1  0033                    ;PAGE 0  DELAY LOOP COUNTER
        #DEFINE DELAY2  0034                    ;PAGE 0  DELAY LOOP COUNTER
	#DEFINE	RESULT	0035

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
	movlw	b'11110000'		;configure PortB
	movwf	TrisB
	movlw	b'00000000'		;configure PortA
	movwf	TrisA
	bcf	Status,RP0

	goto	main

;------------------------------------------------------------------------------
; Main loop
;------------------------------------------------------------------------------

main	nop

	movlw	0x01
	movwf	PortB
	movwf	ROW
;	call	PAUSE
	swapf	PortB,0
	andlw	0x07
	btfss	ZERO
	goto	hit

	movlw	0x02
	movwf	PortB
	incf	ROW
;	call	PAUSE
	swapf	PortB,0
	andlw	0x07
	btfss	ZERO
	goto	hit

	movlw	0x04
	movwf	PortB
	incf	ROW
;	call	PAUSE
	swapf	PortB,0
	andlw	0x07
	btfss	ZERO
	goto	hit

	movlw	0x08
	movwf	PortB
	incf	ROW
;	call	PAUSE
	swapf	PortB,0
	andlw	0x07
	btfss	ZERO
	goto	hit

	movlw	0x00
	movwf	PortB

	goto 	main

hit	movwf	COL
	decfsz	ROW
	goto	hit1
	goto	row1
hit1	decfsz	ROW
	goto	hit2
	goto	row2
hit2	decfsz	ROW
	goto	row4
	goto	row3
row4	btfss	COL,1
	goto	numnul
	clrf	RESULT
	goto	show
row3	btfsc	COL,0
	goto	num7
	btfsc	COL,1
	goto	num8
	movlw	0x09
	movwf	RESULT
	goto	show
num8	movlw	0x08
	movwf	RESULT
	goto	show
num7	movlw	0x07
	movwf	RESULT
	goto	show
row2	btfsc	COL,0
	goto	num4
	btfsc	COL,1
	goto	num5
	movlw	0x06
	movwf	RESULT
	goto	show
num5	movlw	0x05
	movwf	RESULT
	goto	show
num4	movlw	0x04
	movwf	RESULT
	goto	show
row1	btfsc	COL,0
	goto	num1
	btfsc	COL,1
	goto	num2
	movlw	0x03
	movwf	RESULT
	goto	show
num2	movlw	0x02
	movwf	RESULT
	goto	show
num1	movlw	0x01
	movwf	RESULT
	goto	show
numnul	movlw	0xff
	movwf	RESULT
	goto	main

show	movf	RESULT,0
	movwf	PortA
	bcf	PortA,4
	nop
	nop
	bsf	PortA,4
	goto	main

;
;PAUSE2 GIVES LONG DELAY BY LOOPING 40 TIMES callING PAUSE1 EACH TIME
;
PAUSE2	movlw	0x80
        movwf   DELAY2                          ;TO DELAY2 REGISTER
DEL2LP  call    PAUSE1                          ;call SECOND LOOP
        decfsz  DELAY2, 1                       ;DECREMENT SAMPLE PULSE COUNT
        goto    DEL2LP                          ;AND LOOP UNTIL IT IS ZERO
        return
;
;PAUSE1 GIVES MEDIUM DELAY BY LOOPING 80 TIMES callING PAUSE EACH TIME
;
PAUSE1  movlw   0x40                            ;MOVE SET UP PAUSE DELAY
        movwf   DELAY1                          ;TO DELAY1 REGISTER
DEL1LP  call    PAUSE                           ;call SECOND LOOP
        decfsz  DELAY1, 1                       ;DECREMENT SAMPLE PULSE COUNT
        goto    DEL1LP                          ;AND LOOP UNTIL IT IS ZERO
        return
;
;PAUSE GIVES SHORT DELAY BY LOOPING 80 TIMES
;
PAUSE   movlw   0x20                            ;MOVE SET UP PAUSE DELAY
  
        movwf   DELAY0                          ;TO DELAY0 REGISTER
DELLP   decfsz  DELAY0, 1                       ;DECREMENT SAMPLE PULSE COUNT
        goto    DELLP                           ;AND LOOP UNTIL IT IS ZERO
        return             
	
;-----------------------------------------------------------------------------

	end
