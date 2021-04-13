
; set this define for the different hardware connection options

#define	TYPE	2		
		; value 1 for icepic test hardware ( 4 bit data only )
			;PortB 0  	E         - Enable
			;PortB 1  	RS        - Select
			;PortD 2        R/_W      - Read / not write
			;PortB 0 - 3    D4 - D7   - Data bits
		; value 2 for standard pic16f84 ( 4 or eight bit data )
			;PortA 0  	E         - Enable
			;PortA 1  	RS        - Select
			;PortA 2        R/_W      - Read / not write
			;PortB 0 - 7    D0 - D7   - Data bits

; set this define to the number of data bits for each transfer ( 4 or 8 )

#define	DATABT	4


; Control bits

	if	TYPE == 1
        #DEFINE RS      0X06,5                  ; Port B Bit 5 - DISPLAY CONTROL RS   
        #DEFINE E       0X06,4                  ; Port B Bit 4 - DISPLAY CONTROL E   
        #DEFINE RW      0X08,0                  ; Port D Bit 0 - DISPLAY CONTROL R/_W   
	endif
	if	TYPE == 2
        #DEFINE RS      0X05,1                  ; Port B Bit 5 - DISPLAY CONTROL RS   
        #DEFINE E       0X05,0                  ; Port B Bit 4 - DISPLAY CONTROL E   
        #DEFINE RW      0X05,2                  ; Port D Bit 0 - DISPLAY CONTROL R/_W   
	endif

r		equ	0x01
w		equ	0x00
c		equ	0x00
dc		equ	0x01
z		equ	0x02
RP0		equ	0x05

; Special function register in Bank 0
INDF		equ	0x00
TMR0		equ	0x01
PCL		equ	0x02		; PC lo byte
Status		equ	0x03
FSR		equ	0x04
PortA		equ	0x05
PortB		equ	0x06
PortC		equ	0x07
PortD		equ	0x08
PCLATH		equ	0x0A		; PC hi byte
Intcon		equ	0x0B


; Special function register in Bank 1
OptionR		equ	0x01
TrisA		equ	0x05
TrisB		equ	0x06
TrisC		equ	0x07
TrisD		equ	0x08

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
;;
;       OPTION REGISTER BITS
        #DEFINE PS0     0X01,0                  ;P1 - PRESCALER SELECT VALUES
        #DEFINE PS1     0X01,1                  ;      ''
        #DEFINE PS2     0X01,2                  ;      ''
        #DEFINE PSA     0X01,3                  ;P1 - PRESCALER ASSIGNMENT 
        #DEFINE RTE     0X01,4                  ;P1 - TMR0 EDGE (WHEN EXTERNL)
        #DEFINE RTS     0X01,5                  ;P1 - TMR0 SOURCE
        #DEFINE INTEDG  0X01,6                  ;P1 - B0 INTERRUPT EDGE  
        #DEFINE RBPU    0X01,7                  ;P1 - PORTB WEAK PULL UPS


        #DEFINE INDEX   0030                    ;PAGE 0  STRING LOWER ADDRESS
        #DEFINE TMPW    0031                    ;PAGE 0  TEMP W STORE FOR DISP.
        #DEFINE DELAY0  0032                    ;PAGE 0  DELAY LOOP COUNTER
        #DEFINE DELAY1  0033                    ;PAGE 0  DELAY LOOP COUNTER
        #DEFINE DELAY2  0034                    ;PAGE 0  DELAY LOOP COUNTER
	#define DELAY3  0035
        #DEFINE OFSET   0036                    ;PAGE 0  STRING CHR. OFFSET
	#DEFINE FSTCH   0037
	#DEFINE NXTCH	0038
	#DEFINE CCNT	0039
	#DEFINE	MYOPTS  003A			; used for my occasional flags
	#define RSSAVE  0x3a,0                  ;Saved RS setting ( 0 or 1 )
	#define SMSG	0x3a,1			; slow message o/p
	#DEFINE RXD	003B
	#define	TCNT	003C
;-----------------------------------------------------------------------------
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

;SET UP PORT I/O AND OPTION REGISTER CONTENTS

init    bsf     RPAGE                           ;SET PAGE 1
;
        movlw   B'00000000'                     ;SET A TO ALL OUTPUT
        movwf   TrisA                           
        movlw   B'00000000'                     ;SET B TO ALL OUTPUT
        movwf   TrisB
	if	TYPE == 1
        movlw   B'00000000'                     ;SET C TO ALL OUTPUT
        movwf   TrisC
        movlw   B'00000000'                     ;SET D TO ALL OUTPUT
        movwf   TrisD
	endif
;
        bsf     RBPU                            ;DISABLE PortB PULL UPS
        bsf     INTEDG                          ;SET B0 INT ON RISING EDGE
        bcf     RTS                             ;TIMER COUNTS INT CLOCK    
        bcf     RTE                             ;LOW-HIGH INT EDGE (UNUSED)
        bcf     PSA                             ;ASSIGN PRESCALER TO TIMER
        bsf     PS0                             ;SET UP PRESCALER TO /256
        bsf     PS1                             ;           ''
        bsf     PS2                             ;           ''
;
        bcf     RPAGE                           ;BACK TO PAGE 0

;                            PAGE 1
;*****************************************************************************
;
;SET UP OPENING DISPLAY
;
;Before writing to the display it must be set up for 4 bit operation by 
;sending the string of code in subroutine 'INILCD'.
;
;Opening display is located starting at 03 00 hex in the ROM area
;INDEX is loaded with the lower start byte.
;
;
	bcf	RW				; clear R/_W line
        call    INILCD                          ;INITIALISE LCD
	bcf	SMSG
        movlw   0X00                            ;LOAD DATA STRING POINTER
        movwf   INDEX                           ;FOR LOWER ADDRESS BYTE
        call    MESGE                           ;DISPLAY FIRST MESSAGE
        call    PAUSE3                          ;LONG PAUSE
;---------------------------------------------------------------------------------------
; CGRAM demo
;---------------------------------------------------------------------------------------
	movlw	0x40				; set cgram address
	call	CONT1

	movlw	0x11
	call	CONT2
	movlw	0x0a
	call	CONT2
	movlw	0x1F
	call	CONT2
	movlw	0x04
	call	CONT2
	movlw	0x1F
	call	CONT2
	movlw	0x04
	call	CONT2
	movlw	0x04
	call	CONT2
	movlw	0x00
	call	CONT2

	movlw	0xff
	call	CONT2
	movlw	0xff
	call	CONT2
	movlw	0xff
	call	CONT2
	movlw	0x00
	call	CONT2
	movlw	0x00
	call	CONT2
	movlw	0x00
	call	CONT2
	movlw	0x00
	call	CONT2
	movlw	0x00
	call	CONT2


	movlw	0x1f
	call	CONT2
	movlw	0x1f
	call	CONT2
	movlw	0x1f
	call	CONT2
	movlw	0x11
	call	CONT2
	movlw	0x11
	call	CONT2
	movlw	0x1f
	call	CONT2
	movlw	0x1f
	call	CONT2
	movlw	0x1f
	call	CONT2

	movlw	0x11
	call	CONT2
	movlw	0x11
	call	CONT2
	movlw	0xff
	call	CONT2
	movlw	0x00
	call	CONT2
	movlw	0x00
	call	CONT2
	movlw	0x00
	call	CONT2
	movlw	0x00
	call	CONT2
	movlw	0x00
	call	CONT2

	movlw	0x04
	call	CONT2
	movlw	0x02
	call	CONT2
	movlw	0x11
	call	CONT2
	movlw	0x07
	call	CONT2
	movlw	0x11
	call	CONT2
	movlw	0x02
	call	CONT2
	movlw	0x04
	call	CONT2
	movlw	0x00
	call	CONT2

	movlw	0x11
	call	CONT2
	movlw	0x00
	call	CONT2
	movlw	0x04
	call	CONT2
	movlw	0x04
	call	CONT2
	movlw	0x15
	call	CONT2
	movlw	0x0a
	call	CONT2
	movlw	0x04
	call	CONT2
	movlw	0x00
	call	CONT2

	movlw	0x80				; set dram address
	call	CONT1


	movlw   0x01                            ;clear display
        call    CONT1                           ;
	movlw	0x66
	movwf	INDEX
        call    MESGE                           ;DISPLAY MESSAGE
        call    PAUSE3                          ;LONG PAUSE
;-----------------------------------------------------------------------------------------------
; 5 x 10 demo
;-----------------------------------------------------------------------------------------------
	movlw   0x01                            ;clear display
        call    CONT1                           ;
	if	DATABT == 4
	movlw   0x24                            ;function set for 4 bit option
	else
	movlw	0x34				;function set for 8 bit option
	endif
	call	CONT1
	movlw	0x0F
	call	CONT1 
	movlw	0x76
	movwf	INDEX
        call    MESGE                           ;DISPLAY MESSAGE
	movlw	0xe2
	call	CONT2
	movlw	0xe4
	call	CONT2
	movlw	0xe6
	call	CONT2
	movlw	0xe7
	call	CONT2
	movlw	0xea
	call	CONT2
	movlw	0xf0
	call	CONT2
	movlw	0xf1
	call	CONT2
	movlw	0xf9
	call	CONT2
	movlw	0xff
	call	CONT2
	movlw	' '
	call	CONT2

        call    PAUSE3                          ;LONG PAUSE

	if	DATABT == 4
	movlw   0x28                            ;function set for 4 bit option
	else
	movlw	0x38				;function set for 8 bit option
	endif
	call	CONT1
;----------------------------------------------------------------------------------
; movement demo
;----------------------------------------------------------------------------------
	movlw   0x01                            ;clear display
        call    CONT1                           ;
	movlw   0x90                            ;cursor to row 0 col 16
        call    CONT1                           ;
	movlw	'H'
	call	CONT2
	movlw	'e'
	call	CONT2
	movlw	'l'
	call	CONT2
	movlw	'l'
	call	CONT2
	movlw	'o'
	call	CONT2

	MOVLW   8                                
        MOVWF   TCNT                            
shft1	MOVLW   0x18                            ;Shift display right
        CALL    CONT1                          
        CALL    PAUSE2
        DECFSZ  TCNT, 1                         ;DECREMENT COUNT
        GOTO    shft1                           ;AND LOOP UNTIL IT IS ZERO

	movlw   0xC8                            ;cursor to row 1 col 8
        call    CONT1                           ;

	movlw   0x0F                            ;cursor on and blink
        call    CONT1                           ;


	bsf	SMSG
        movlw   0X34                            ;LOAD DATA STRING POINTER
        movwf   OFSET                           ;FOR LOWER ADDRESS BYTE
        call    MESGE1                          ;DISPLAY MESSAGE

	movlw   0x07                            ; shift display on input
        call    CONT1                           ;

	movlw	44
	movwf	OFSET
	call	MESGE1
 
	movlw   0xC0                            ;cursor to row 1 col 8
        call    CONT1                           
	movlw	56
	movwf	OFSET
	call	MESGE1

	call	PAUSE3

	movlw   0x06                            ; shift cursor on input
        call    CONT1                           ;
	movlw   0x0C                            ;cursor off
        call    CONT1                           ;

;------------------------------------------------------------------------------
; Main loop
;------------------------------------------------------------------------------

main 	movlw   0x01                            ;clear display
        call    CONT1                           ;
	bcf	SMSG
	movlw   0X21                             
        movwf   INDEX				 
	call	MESGE   
displ1	movlw	0x00
	movwf	FSTCH				; initialise first character
displ2	movlw	0x10				; initialise character count
	movwf	CCNT
	movlw   0xC0                            ;set cursor to row 1 col 0
        call    CONT1                          
	movf	FSTCH,0
	movwf	NXTCH				; set next character
displ3	movf	NXTCH,0
	call	CONT2
	incf	NXTCH,1
	decfsz	CCNT,1
	goto	displ3
	incf	FSTCH,1
	call	PAUSE1
	movlw	0xff
	subwf	FSTCH,0
	btfsc	ZERO
	goto	displ1
	call	PAUSE2
	goto 	displ2
	
;-----------------------------------------------------------------------------
; Wait for busy flag to clear
;-----------------------------------------------------------------------------

wbusy	bsf     RPAGE                           ;SET PAGE 1
	if	TYPE == 1
        movlw   B'00001111'                     ;SET 
	endif
	if	TYPE == 2
	if	DATABT == 4
        movlw   B'11110000'                     ;SET 
	else
	movlw	B'11111111'
	endif
	endif
        movwf   TrisB
	bcf	RPAGE   
	bsf	RW
	bcf	RS
wbusy1	bsf	E
	call	PAUSE
	movf	PortB,0
	if	DATABT == 4
	if	TYPE == 1
	andlw	0x0f
	movwf	RXD
	swapf	RXD,1
	endif
	if	TYPE == 2
	andlw	0xF0
	movwf	RXD
	endif
	bcf	E
	call	PAUSE
	bsf	E
	call	PAUSE
	movf	PortB,0
	if	TYPE == 1
	andlw	0x0f
	iorwf	RXD,1
	endif
	if	TYPE == 2
	andlw	0xf0
	swapf	RXD,1
	iorwf	RXD,1
	swapf	RXD,1
	endif
	else
	movwf	RXD
	endif
	bcf	E
	call	PAUSE
	btfsc   RXD,7			
        goto    wbusy1
	bcf	RW

	bsf     RPAGE                           ;SET PAGE 1
        movlw   B'00000000'                     ;SET 
        movwf   TrisB
	bcf	RPAGE   
	return

;-------------------------------------------------------------------------------
; Waiters
;-------------------------------------------------------------------------------

PAUSE3  movlw   0x18                            
        movwf   DELAY3                        
DEL3LP  call    PAUSE2                       
        decfsz  DELAY3, 1                    
        goto    DEL3LP                      
        return
;
	if	TYPE == 1
PAUSE2  movlw   0xf0                            
	endif
	if	TYPE == 2
PAUSE2	movlw	0x40
	endif
        movwf   DELAY2                          
DEL2LP  call    PAUSE1                        
        decfsz  DELAY2, 1                   
        goto    DEL2LP                      
;
PAUSE1  movlw   0x40                            ;MOVE SET UP PAUSE DELAY
        movwf   DELAY1                          ;TO DELAY1 REGISTER
DEL1LP  call    PAUSE                           ;call SECOND LOOP
        decfsz  DELAY1, 1                       ;DECREMENT SAMPLE PULSE COUNT
        goto    DEL1LP                          ;AND LOOP UNTIL IT IS ZERO
        return
;
PAUSE   movlw   0x20                            ;MOVE SET UP PAUSE DELAY
  
        movwf   DELAY0                          ;TO DELAY0 REGISTER
DELLP   decfsz  DELAY0, 1                       ;DECREMENT SAMPLE PULSE COUNT
        goto    DELLP                           ;AND LOOP UNTIL IT IS ZERO
        return             
;-----------------------------------------------------------------------------------
; Initialise the lcd
;-----------------------------------------------------------------------------------
INILCD  movlw   0x33                            ;
        call    CONT5
;
        movlw   0x32                            ;
        call    CONT5
;                      
	if	DATABT == 4
	movlw   0x28                            ;function set for 4 bit option
	else
	movlw	0x38				;function set for 8 bit option
	endif
        call    CONT4                           ;8or4 bit mode 2 lines in 4 bit data mode
;
        movlw   0x06                            ;entry mode set
        call    CONT1                           ;cursor increments on write
;
        movlw   0x0C                            ;display on off 
        call    CONT1                           ;display on, cursor off, blink on
;
        movlw   0x01                            ;clear display
        call    CONT1                           ;move cursor to home

        return

;----------------------------------------------------------------------------
; Send binary value in W as a display digit
;----------------------------------------------------------------------------
CONT2D  addlw   0X30
;
;----------------------------------------------------------------------------
; Send byte in W as data
;----------------------------------------------------------------------------
CONT2   bsf     RS                              ;SET RS HIGH
	goto	CONT1A				; output the data


;--------------------------------------------------------------------------
; Send 8 BIT data in W to lcd as a command
;--------------------------------------------------------------------------
CONT1   bcf     RS                              ;SET RS TO ZERO 
CONT1A  bcf     E                               ;AND E
	if	DATABT == 8
        movwf   PortB                           ;WRITE DATA TO PortB
        call    PAUSE  
        bsf     E                               ;SET E HIGH
        call    PAUSE
        bcf     E                               ;FALLING E LATCHES DATA
        call    wbusy                           ;DELAY 

        return                                  ;BACK FROM SUBROUTINE
	else
	goto	CONT4A
	endif
;------------------------------------------------------------------------
; Send contents of W as data assuming 4 bit mode
;-------------------------------------------------------------------------
CONT4   bcf     RS                              ;SET RS TO ZERO 
        bcf     E                               ;AND E
CONT4A  movwf   TMPW                            ;MOVE W TO TEMP STORE

	bcf	RSSAVE
	btfsc	RS				; j if RS clear
	BSF	RSSAVE				; else set RSSAVE
	movf	TMPW,0
	if	TYPE == 1
        swapf   TMPW,0                          ;PUT MSB TO D0-3 IN W
        andlw   0X0F                            ;MASK UPPER BITS
	endif
	if	TYPE == 2
	andlw	0xF0
	endif
        movwf   PortB                           ;WRITE DATA TO PortB
	btfsc	RSSAVE
	bsf	RS				; cause it might be in PortB
        call    PAUSE  
        bsf     E                               ;SET E HIGH
        call    PAUSE
        bcf     E                               ;FALLING E LATCHES DATA
        call    PAUSE                           ;DELAY 
;
	if	TYPE == 1
        movf    TMPW,0                          ;PUT LSB TO D0-3
        andlw   0X0F                            ;MASK UPPER BITS
	endif
	if	TYPE == 2
	swapf	TMPW,0
	andlw	0xf0
	endif
        movwf   PortB                           ;WRITE DATA TO PortB
	btfsc	RSSAVE
	bsf	RS				; cause RS might be in PortB
        call    PAUSE  
        bsf     E                               ;SET E HIGH
        call    PAUSE
        bcf     E                               ;FALLING E LATCHES DATA
        call    wbusy                           ;DELAY 

        return                                  ;BACK FROM SUBROUTINE

;----------------------------------------------------------------------------------------------------
; Send contents of W as data in initialise phase ( no busy flag check - just wait )
;----------------------------------------------------------------------------------------------------
CONT5   bcf     RS                              ;SET RS TO ZERO 
        bcf     E                               ;AND E
        movwf   TMPW                            ;MOVE W TO TEMP STORE
	if	TYPE == 1
        swapf   TMPW,0                          ;PUT MSB TO D0-3 IN W
        andlw   0X0F                            ;MASK UPPER BITS
	endif
	if	TYPE == 2
	andlw	0xF0
	endif
        movwf   PortB                           ;WRITE DATA TO PortB
        call    PAUSE  
        bsf     E                               ;SET E HIGH
        call    PAUSE
        bcf     E                               ;FALLING E LATCHES DATA
        call    PAUSE                           ;DELAY 
;
        movf    TMPW,0                          ;PUT LSB TO D0-3
	if	TYPE == 1
        movf    TMPW,0                          ;PUT LSB TO D0-3
        andlw   0X0F                            ;MASK UPPER BITS
	endif
	if	TYPE == 2
	swapf	TMPW,0
	andlw	0xf0
	endif
;
        movwf   PortB                           ;WRITE DATA TO PortB
        call    PAUSE  
        bsf     E                               ;SET E HIGH
        call    PAUSE
        bcf     E                               ;FALLING E LATCHES DATA
        call    PAUSE                           ;DELAY 

        return                                  ;BACK FROM SUBROUTINE


;-----------------------------------------------------------------------------
; Send Alphanumeric string pointed by index
;-----------------------------------------------------------------------------
MESGE   movlw	0x02                            ;cursor home
        call    CONT1                           ;without clearing display
;
        movf    INDEX, 0                        ;LOAD START POINTER
        movwf   OFSET                           ;TO TABLE OFFSET REGISTER
MESGE1  call    DIGIT                           ;GET DIGIT FROM TABLE INTO W
        incf    OFSET,1                         ;STEP ON TO NEXT DATA BYTE
        movwf   TMPW                            ;HOLD W VALUE FOR E O M TEST
        xorlw   0X0A                            ;IS VALUE END OF MESSAGE CODE?
        btfsc   ZERO                            ;IF SO ZERO WILL BE SET
        return                                  ;SO return
;
        movf    TMPW,0                          ;RELOAD W WITH DIGIT 
        xorlw   0X0D                            ;IS VALUE END OF LINE?
        btfsc   ZERO                            ;IF SO ZERO WILL BE SET
        goto    NEWLIN                          ;SET CURSOR FOR NEW LINE
;
        movf    TMPW,0                          ;RELOAD W WITH DIGIT 
        call    CONT2                           ;WRITE TO DISPLAY
	btfsc	SMSG
	call	PAUSE2
        goto    MESGE1                          ;AND LOOP 
;
NEWLIN  movlw   0xC0                            ;SET CURSOR TO NEWLINE
        call    CONT1                           ;BY SENDING INSTRUCTION C0 
        call    PAUSE1                          ;
        goto    MESGE1
;
;-------------------------------------------------------------------------------------
; Digit must be at a fixed address to ensure the lookup works
;-------------------------------------------------------------------------------------
	org	02fC
DIGIT   movlw   3	                        ;LOAD UPPER BYTE ADDRESS
        movwf   PCLATH                          ;TO PC UPPER BYTE REGISTER
        movf    OFSET, 0                        ;GET TABLE OFFSET 
        addwf   PCL,1                           ;AND ADD TO PC LOWER 8 BITS
;
;       THE SUBROUTINE 'DIGIT' MUST BE LOCATED AS SHOWN
;       IN ORDER TO ALLOW THE 'TABLE LOOK UP' FUNCTION TO TAKE PLACE
;
;The PC (program counter) is loaded with the table address from UBBYT and 
;OFFSET and so execution jumps to that address, and returns with the data
;following the retlw instruction 
;Note thet the addresses are shown in hex, but the individual characters are 
;numbered sequentially in decimal. 
;
;                                             
        retlw   'L'                           
        retlw   ' '                        
        retlw   'C'                        
        retlw   ' '                     
        retlw   'D'                       
        retlw   ' '                     
        retlw   'C'                   
        retlw   'o'                    
        retlw   'm'                     
        retlw   'p'                     
        retlw   'o'                     
        retlw   'n'                    
        retlw   'e'                           
        retlw   'n'                           
        retlw   't'                           
        retlw   ' '                         
        retlw   0X0D                         
        retlw   'D'                            
        retlw   'e'                             
        retlw   'm'                            
        retlw   'o'                          
        retlw   ' '                          
        retlw   'p'                             
        retlw   'r'                            
        retlw   'o'                             
        retlw   'g'                             
        retlw   'r'                         
        retlw   'a'                         
        retlw   'm'                        
        retlw   ' '                        
        retlw   ' '                          
        retlw   ' '                        
        retlw   0X0A                         
;
        retlw   'S'                          
        retlw   'h'                         
        retlw   'o'                         
        retlw   'w'                          
        retlw   ' '                           
        retlw   'C'                         
        retlw   'h'                        
        retlw   'a'                         
        retlw   'r'                          
        retlw   'a'                           
        retlw   'c'                      
        retlw   't'                      
        retlw   'e'                          
        retlw   'r'                            
        retlw   's'                            
        retlw   ' '                          
        retlw   0X0D                         
        retlw   ' '                         
        retlw   0X0A                         
;
        retlw   ' '                           
        retlw   ' '                           
        retlw   ' '                         
        retlw   ' '                          
        retlw   ' '                          
        retlw   ' '                          
        retlw   ' '                          
        retlw   ' '                          
        retlw   'H'                           
        retlw   'e'                          
        retlw   'l'                           
        retlw   'l'                        
        retlw   'o'                           
        retlw   ' '                          
        retlw   ' '                           
        retlw   0X0A                        
;
        retlw   'i'                          
        retlw   's'                       
        retlw   ' '                          
        retlw   't'                         
        retlw   'h'                         
        retlw   'e'                         
        retlw   'r'                         
        retlw   'e'                           
        retlw   ' '                          
        retlw   'a'                          
        retlw   'n'                         
        retlw   'y'                           
        retlw   'b'                           
        retlw   'o'                          
        retlw   'd'                           
        retlw   'y'                            
        retlw   ' '                      
        retlw   0X0A           
;              
        retlw   'o'                             
        retlw   'u'                            
        retlw   't'                           
        retlw   ' '                           
        retlw   't'                          
        retlw   'h'                         
        retlw   'e'                         
        retlw   'r'                           
        retlw   'e'                            
        retlw   ' '                         
        retlw   '?'                         
        retlw   ' '                           
        retlw   ':'                        
        retlw   '-'                         
        retlw   ')'                            
        retlw   0X0A                         

        retlw   'G'                          
        retlw   'r'                         
        retlw   'a'                         
        retlw   'p'                        
        retlw   'h'                          
        retlw   'i'                         
        retlw   'c'                          
        retlw   's'                         
        retlw   ' '                         
	retlw	0
	retlw	1
	retlw	2
	retlw	3
	retlw	4
	retlw	5
        retlw   0X0A                         
;
        retlw   '5'                         
        retlw   'x'                           
        retlw   '1'                     
        retlw   '0'                            
        retlw   ' '                            
        retlw   0X0A                           

	end
