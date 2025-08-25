#INCLUDE "P16F877A.INC"
__CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

CBLOCK 0X20
	TEMP
	preValue          
	temp
	test
	DCounter1 
	DCounter2 
	correctFlag1
	correctFlag2
	adc
	DCounter3
	DCounter4 
	DCounter5
	DCounter10
	DCounter11
	DCounter12
	countdown       ; countdown from 9
    current_answer  ; correct answer for problem
    problem_index   ; selected problem index (0-4)
    switch_input    ; player answer
    overflow
    flash
ENDC


	ORG 0X00
	GOTO MAIN
	
	ORG 0X04
	GOTO ISR

MAIN
	CLRF TEMP
	CLRF preValue          
	CLRF temp
	CLRF test
	CLRF DCounter1 
	CLRF DCounter2 
	CLRF correctFlag1
	CLRF correctFlag2
	CLRF adc
	CLRF DCounter3
	CLRF DCounter4 
	CLRF DCounter5
	CLRF countdown       
    CLRF current_answer  
    CLRF problem_index   
    CLRF switch_input
    CLRF flash
    banksel PORTA
    CLRF PORTA
    CLRF PORTB
    CLRF PORTE
    CLRF PORTC
    CLRF PORTD
	BANKSEL ADCON1 ; PORTE --> Analog to digital output 
	MOVLW 0X07
	MOVWF ADCON1
	BANKSEL TRISC
	CLRF TRISC
	BANKSEL TRISE
	CLRF TRISE ; 	RE ---> OUT
	BANKSEL PORTE
	clrf PORTC
	CLRF PORTE ;   LED ---> OFF
	BANKSEL TRISB
	MOVLW B'11110011' ;(RB7- RB4)--> INPUT / (RB1-RB0)-->INPUT    
	MOVWF TRISB
	BANKSEL TRISD
	CLRF TRISD
	call LCD_INIT
	call LCD_CLEAR
	movlw 0x80
	call send_cmd
	call DELAY_20MS
	movlw 'C'
	call send_char
	movlw 'H'
	call send_char
	movlw 'A'
	call send_char
	movlw 'L'
	call send_char
	movlw 'L'
	call send_char
	movlw 'E'
	call send_char
	movlw 'N'
	call send_char
	movlw 'G'
	call send_char
	movlw 'E'
	call send_char
	movlw '1'
	call send_char
wait
	btfss PORTB , 0 
	GOTO wait
	MOVF PORTB , w
	ANDLW B'11110000'; To read the value on RB7 to RB4 bits separately
	MOVWF TEMP
	swapf TEMP , f
	
	goto CHECK_PRIME_NUMBER  
	
	
	
	
CHECK_PRIME_NUMBER ; IF(X == X) XOR --> 0 --> Z = 1
	MOVF TEMP,W   ; IF(X != Y)	XOR --> ANY NUMBER --> Z = 1	
	XORLW .2      ;  4 bit (0000 - 1111) --> (0 - 15)--> is prime if(num >1 && num <= 15 && It can only be divided by 1 and itself )-->is one of(2,3,5,7,11,13) 
	BTFSC STATUS,Z				
	GOTO PRIME					
	MOVF TEMP,W 
	XORLW .3
	BTFSC STATUS,Z				
	GOTO PRIME					
	MOVF TEMP,W 
	XORLW .5
	BTFSC STATUS,Z					
	GOTO PRIME					
	MOVF TEMP,W 
	XORLW .7
	BTFSC STATUS,Z					
	GOTO PRIME				
	MOVF TEMP,W 
	XORLW .11
	BTFSC STATUS,Z					
	GOTO PRIME					
	MOVF TEMP,W 
	XORLW .13
	BTFSC STATUS,Z				
	GOTO PRIME
						
	BANKSEL PORTE 
	BCF PORTE,0 ; LED RE0 --> OFF
	BCF PORTE,1 ; LED RE1 --> OFF
	BCF PORTE,2 ; LED RE2 --> OFF
	MOVLW 0
	CALL DISPLAY ;DISPLAY (0110110) ON 7SEG
	banksel PORTC
	MOVWF PORTC
	CALL DELAY_1SEC
	CALL DELAY_1SEC
	CALL LCD_CLEAR
	goto CHALLENGE2


PRIME 
	BANKSEL PORTE 
	BSF PORTE,0    ; LED RE0 --> ON  
	BCF PORTE,1	   ; LED RE1 --> OFF		
	BCF PORTE,2    ; LED RE2 --> OFF
	INCF correctFlag1
	MOVLW 1
	CALL DISPLAY   ; DESPLAY P(0011000) ON 7SEG
	movwf PORTC
	CALL DELAY_1SEC
	CALL DELAY_1SEC
	CALL LCD_CLEAR
	BANKSEL PORTC
	CLRF PORTC
	goto CHALLENGE2
	
DISPLAY
	ADDWF PCL , F
	RETLW B'10110110'
	RETLW B'10001100'


SHOW_PROBLEM
;chooses the problem from the problem_index value
    MOVF problem_index, W
    ADDWF PCL, F
    GOTO PROB0
    GOTO PROB1
    GOTO PROB2
    GOTO PROB3
    GOTO PROB4
    
countlookup
;chooses which value will be on the 7 segment from the countdown value
	MOVF countdown , W
	ADDWF PCL , F
	nop
	RETLW b'11000000'
	RETLW b'11000000'
	RETLW b'11111001'
	RETLW b'11111001'
	RETLW B'10100100'
	RETLW B'10100100'
	RETLW B'10110000'
	RETLW B'10110000'
	RETLW B'10011001'
	RETLW B'10011001'
	RETLW B'10010010'
	RETLW B'10010010'
	RETLW B'10000010'
	RETLW B'10000010'
	RETLW B'11111000'
	RETLW B'11111000'
	RETLW B'10000000'
	RETLW B'10000000'
	RETLW B'10010000'
	RETLW B'10010000'
	
LOAD_ANSWER
;chooses the real answer of the problem using the problem_index
    MOVF problem_index, W
    ADDWF PCL, F
    RETLW .8 ; 5+3
    RETLW .7 ; 9-2
    RETLW .8 ; 4x2
    RETLW .4 ; 8/2
    RETLW .13 ; 6+7	

CHALLENGE2
	BTFSC PORTB , 0
	GOTO $-1
	Call Initial
	call LCD_CLEAR
	movlw 0x80
	call send_cmd
	call DELAY_20MS
	movlw 'C'
	call send_char
	movlw 'H'
	call send_char
	movlw 'A'
	call send_char
	movlw 'L'
	call send_char
	movlw 'L'
	call send_char
	movlw 'E'
	call send_char
	movlw 'N'
	call send_char
	movlw 'G'
	call send_char
	movlw 'E'
	call send_char
	movlw '2'
	call send_char


Main_Loop
	btfss PORTB , 0
	goto $-1
    banksel ADCON0
    bsf	ADCON0, GO
    
    banksel		PIR1
wait2	
	btfss		PIR1, ADIF
	goto		wait2
;	btfss ADRESH , 4
;	goto wait
   
   	bcf			PIR1, ADIF		
	banksel		ADRESH
	movf		ADRESH, W
	movwf		adc
   
	goto testValue				
	goto Main_Loop 		



testValue
	
	movlw d'25'
	movwf preValue ; this is the value that will be compared with the value Read by ADC
	
	movf preValue, w
	subwf adc, w
	movwf test
	
	btfss  STATUS, C	
	call editValue ; edit value of the difference is -ve (take the abs)
	
	
	movlw .52
	movwf temp 
	movf test,w
	subwf temp, w
	btfsc STATUS, C ; test <= 51  (in the same range)
	call correct
	call DELAY_1SEC
	movf correctFlag2, f ; this flag is set to exist the challenge
	btfss STATUS, Z
	goto CHALLENGE3
	
	; if it's not in the same range(check if it's so close at least)
	movlw .103 
	movwf temp
	movf test,w
	 
	subwf temp, w
	btfss STATUS, C ; test <= 102 
	goto CHALLENGE3
true
	call soClose 
	banksel PORTE
	bcf PORTE, 1
	nop	
	goto Main_Loop
	
 ; it it's not so close go back and read another value form the potentiometer 
	
	
editValue
	; take the abs value for the value if it is -ve

	movf test, w
	movwf temp
	movlw .256
	movwf test 
	movf temp, w
	subwf test, f
	
	return
	

exist ; end the challenge 
	CALL LCD_CLEAR
	goto MAIN
	
LCD_INIT
    call DELAY_1SEC     ; Wait for LCD power-on

    
    ; Repeat function set (required by some LCDs)
    movlw 0x38
    call send_cmd
    
    ; Display ON/OFF control
    movlw 0x0e        ; Display on, cursor off, blink off
    call send_cmd
    
    ; Clear display
    CALL LCD_CLEAR
    
    ; Entry mode set
    movlw 0x06        ; Increment cursor, no display shift
    call send_cmd
    call delay
    
    return


LCD_CLEAR
	MOVLW 0X01
	CALL send_cmd
	return

correct ;; turn on green led && display 'YOU ARE CORRECT'

	bsf correctFlag2, 1
		
	call LCD_CLEAR
	movlw 0x80
	call send_cmd
	call delay
	call delay
	call delay
	call delay
	movlw 'Y'
	call send_char
	movlw 'O'
	call send_char
	movlw 'U'
	call send_char
	movlw ' '
	call send_char
	movlw 'A'
	call send_char
	movlw 'R'
	call send_char
	movlw 'E'
	call send_char
	movlw ' '
	call send_char
	movlw 'C'
	call send_char
	movlw 'O'
	call send_char
	movlw 'R'
	call send_char
	movlw 'R'
	call send_char
	movlw 'E'
	call send_char
	movlw 'C'
	call send_char
	movlw 'T'
	call send_char
	movlw '!'
	call send_char

	banksel PORTE
	bsf PORTE, 1 

	return
		

soClose ; display 'YOU ARE SO CLOSE'
	
	CALL LCD_CLEAR
	movlw 0x80
	call send_cmd
	call delay
	call delay
	call delay
	call delay
	movlw 'Y'
	call send_char
	movlw 'O'
	call send_char
	movlw 'U'
	call send_char
	movlw ' '
	call send_char
	movlw 'A'
	call send_char
	movlw 'R'
	call send_char
	movlw 'E'
	call send_char
	movlw ' '
	call send_char
	movlw 'S'
	call send_char
	movlw 'O'
	call send_char
	movlw ' '
	call send_char
	movlw 'C'
	call send_char
	movlw 'L'
	call send_char
	movlw 'O'
	call send_char
	movlw 'S'
	call send_char
	movlw 'E'
	call send_char

	return

Initial	

    banksel ADCON1
	movlw 0b01001110
	movwf ADCON1
	
    banksel TRISA
    movlw B'00000001'
    movwf TRISA            ; Set PORTA as output
    banksel TRISD
    clrf TRISD            ; Set PORTD as output
    banksel TRISE
    clrf TRISE            ; Set PORTE as output
	BANKSEL TRISB 
	MOVLW B'00000011'
	MOVWF TRISB
		
	banksel ADCON0
	movlw 0b01000001
	movwf ADCON0

    banksel PORTA
    clrf PORTA
    clrf PORTD
    clrf PORTE
	CLRF PORTB

    
    return


send_char 
	banksel PORTD
    movwf PORTD 
    banksel PORTA      ; Send data
    bsf PORTB, 2       ; RS=1 (data)
    bsf PORTB, 3       ; E=1
    nop     
    nop           ; Pulse width > 450ns
    bcf PORTB, 3       ; E=0
    call delay         ; Wait for LCD to process
    return 

send_cmd
	banksel PORTD
    movwf PORTD 
    banksel PORTB       ; Send command
    bcf PORTB, 2       ; RS=0 (command)
    bsf PORTB, 3       ; E=1
    nop 
    nop               ; Pulse width > 450ns
    bcf PORTB, 3       ; E=0
    call delay        ; Wait for LCD to process
    return
	
delay
	MOVLW 0X7b
	MOVWF DCounter1
	MOVLW 0X07
	MOVWF DCounter2
LOOP
	DECFSZ DCounter1, 1
	GOTO LOOP
	DECFSZ DCounter2, 1
	GOTO LOOP
	nop
	return
	
DELAY_1SEC
	MOVLW 0Xac
	MOVWF DCounter3
	MOVLW 0X13
	MOVWF DCounter4
	MOVLW 0X06
	MOVWF DCounter5
LOOP2
	DECFSZ DCounter3, 1
	GOTO LOOP2
	DECFSZ DCounter4, 1
	GOTO LOOP2
	DECFSZ DCounter5, 1
	GOTO LOOP2
	NOP
	RETURN

	DELAY_20MS
    CALL delay
    CALL delay
    CALL delay
    CALL delay
    RETURN
   
DELAY_5SEC
	CALL DELAY_1SEC
	CALL DELAY_1SEC
	CALL DELAY_1SEC
	CALL DELAY_1SEC
	CALL DELAY_1SEC
	CALL DELAY_1SEC
	RETURN

	
CHALLENGE3
;Setting ADCON1 to have all DIGITAL pins
	btfsc PORTB , 0
	goto $-1
    BANKSEL ADCON1
    MOVLW 0x06
    MOVWF ADCON1

	banksel TRISA
    CLRF TRISA		;PORTA all OUTPUT
    MOVLW B'11110011'
    MOVWF TRISB		;TRISB all INPUT
    CLRF TRISC		;PORTC all OUTPUT
    CLRF TRISD		;PORTD all OUTPUT
    CLRF TRISE		;PORTE all OUTPUT


    BANKSEL PORTA
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    CLRF PORTE

;Initializing Timer 0	
    CALL LCD_WELCOME
    CALL TIMER0_INIT
    
;Waiting for the button to be pressed
    BTFSS PORTB , 0     
    GOTO $-1           
    
START_CHALLENGE
;after pressing the button it willcome here
	CALL TIMER1_INIT
	
;Initializing the timer that will show on the 7 segment Display
	MOVLW .20
    MOVWF countdown
    CALL SHOW_TIME

    CALL RANDOM_PROBLEM		;choosing the problem index randomly
    CALL LOAD_ANSWER		;getting the real answer
    movwf current_answer
    
    CALL LCD_CLEAR			; clearing LCD
    CALL DELAY_20MS
    GOTO SHOW_PROBLEM		;putting the problem chosen on the LCD
    
WAIT_LOOP
;this is to wait until the player gives his answer by pressing the 
;finish button or the Timer gets to 0
    BTFSC PORTB , 1
    GOTO CHECK_INPUT
    movlw 1					;subtracted 1 not 0 because the real value of the countdown is 10 not 9
    subwf countdown , w
    BTFSC STATUS, Z
    GOTO WRONG
    GOTO WAIT_LOOP

CHECK_INPUT
;this gets executed if the finish button got pressed , it checks the value entered
;by the user and put it in the switch_input variable and compare it with the real value
;stored in the current_answer variable
    MOVF PORTB, W
    ANDLW 0xF0
    MOVWF switch_input
    swapf switch_input , F

    MOVF current_answer, W
    SUBWF switch_input, W
    BTFSS STATUS, Z
    GOTO WRONG

;comes here if the answer is true

;stopping timer 1 so the timer do not keep counting after the finish button is pressed	
	BANKSEL T1CON
    BCF T1CON, TMR1ON
;lighting the green LEDS 
	BANKSEL PORTE
    BSF PORTE , 2
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    
    MOVF correctFlag1
    BTFSC STATUS , Z
    GOTO WRONG
    MOVF correctFlag2
    BTFSC STATUS , Z
    GOTO WRONG
    
    CALL LCD_CLEAR
    CALL DELAY_20MS
;showing the "YOU WIN! ESCAPE" string on the LCD
    CALL LCD_YOUWIN
    MOVLW .150
	MOVWF flash
    GOTO FLASH

FLASH
;FLASHING THE THREE LEDS AFTER WINNING
	BANKSEL PORTE
	BSF PORTE , 0
	BSF PORTE , 1
	BSF PORTE , 2
	CALL DELAY_20MS
	BCF PORTE , 0
	BCF PORTE , 1
	BCF PORTE , 2
	CALL DELAY_20MS
	DECFSZ flash ,F 
	GOTO FLASH
    GOTO END_CHALLENGE

WRONG
;stopping timer 1 so the timer do not keep counting after the finish button is pressed	
	BANKSEL T1CON
    BCF T1CON, TMR1ON
	CALL LCD_CLEAR
	call DELAY_20MS
;showing the "HARD LUCK" string on the LCD
    CALL LCD_HARDLUCK
	CALL DELAY_5SEC
    goto END_CHALLENGE

END_CHALLENGE
;turning off the green LEDS
    BCF PORTE , 0
    BCF PORTE , 1
    BCF PORTE , 2
    CALL LCD_CLEAR
;showing the welcome string again and going to the main loop so the user
; can restart the challenge
    CLRF PORTC
    goto MAIN

DELAY_200MS
	MOVLW 0Xb9
	MOVWF DCounter10
	MOVLW 0X04
	MOVWF DCounter11
	MOVLW 0X02
	MOVWF DCounter12
LOOP5
	DECFSZ DCounter10, 1
	GOTO LOOP5
	DECFSZ DCounter11, 1
	GOTO LOOP5
	DECFSZ DCounter12, 1
	GOTO LOOP5
	RETURN
	

ISR
;clearing the timer 0 interrupt flag
	 BANKSEL INTCON
     BTFSC INTCON, T0IF
     BCF INTCON , T0IF

;this is to make the countdown decrement every second if the timer1 overflowed	
    BANKSEL PIR1
    BTFSS PIR1, TMR1IF
    RETFIE
    BCF PIR1, TMR1IF
    movf countdown , w
	DECFSZ countdown , F
	goto SHOW
	
;here we stop timer1 because we dont want it to keep giving interrupts while the 
;countdown is already 0 and the challenge ended
	BANKSEL T1CON
    BCF T1CON, TMR1ON    ; Stop Timer1
    BANKSEL PIE1
    BCF PIE1, TMR1IE     ; Disable Timer1 interrupt
    RETFIE
SHOW
    CALL SHOW_TIME
    RETFIE
   
TIMER0_INIT
;initializing timer 0
	 BANKSEL OPTION_REG
	 MOVLW b'00000111'    ; Prescaler 1:256
	 MOVWF OPTION_REG
	 
	 BANKSEL INTCON
	 BSF INTCON, T0IE     ; Enable Timer0 interrupt
	 BCF INTCON, T0IF     ; Clear Timer0 interrupt flag
	 BSF INTCON, GIE      ; Global interrupt enable
	 RETURN  
	 
RANDOM_PROBLEM
;this routine takes the value stored in TMR0 register after timer 0 was started
;and AND it with 0000 0111 so we get the index to be from 0-7 then it checks if 
; bit 2 is 1 then it subtracts 3 from the value else it will keep the value as it is
;like that we will assure the index is from (0-4)
	MOVF TMR0, W
    ANDLW 0x07
    MOVWF problem_index
    movlw 3
    btfsc problem_index , 2
    subwf problem_index , F 
    BANKSEL INTCON
    BCF INTCON, T0IE		;turning timer 0 off because we dont need it anymore
    RETURN
    
TIMER1_INIT
;Initializing timer 1
    BANKSEL T1CON
    MOVLW b'00110001' ; Enable Timer1, 1:8 prescaler
    MOVWF T1CON
    
    BANKSEL PIR1
    BCF PIR1, TMR1IF  ; Clear timer 1 flag
    BANKSEL PIE1
    BSF PIE1, TMR1IE  ; Enable Timer1 interrupt
    BANKSEL INTCON
    BSF INTCON, PEIE  ; Peripheral interrupt enable
    BSF INTCON, GIE   ; Global interrupt enable
    RETURN
		

SHOW_TIME
;put the value of the countdown on PORTC so the 7-segment displays it
    call countlookup
    movwf PORTC
    call DELAY_20MS
    RETURN
	
LCD_WELCOME
;sending the 'START' string to the LCD
    CALL LCD_CLEAR
    MOVLW 0x80		; Set DDRAM address to 0x00 (start of line 1)
    CALL send_cmd
    call DELAY_20MS
    MOVLW 'C'
    CALL send_char
    MOVLW 'H'
    CALL send_char
    MOVLW 'A'
    CALL send_char
    MOVLW 'L'
    CALL send_char
    MOVLW 'L'
    CALL send_char
    MOVLW 'E'
    CALL send_char
    MOVLW 'N'
    CALL send_char
    MOVLW 'G'
    CALL send_char
    MOVLW 'E'
    CALL send_char
    MOVLW '3'
    CALL send_char
    RETURN

LCD_YOUWIN
;sending the 'YOU WIN! ESCAPE' string to the LCD
    CALL LCD_CLEAR
    MOVLW 0x80      ; Set DDRAM address to 0x00 (start of line 1)
	CALL send_cmd
	call DELAY_20MS
    MOVLW 'Y'
    CALL send_char
    MOVLW 'O'
    CALL send_char
    MOVLW 'U'
    CALL send_char
    MOVLW ' '
    CALL send_char
    MOVLW 'W'
    CALL send_char
    MOVLW 'I'
    CALL send_char
    MOVLW 'N'
    CALL send_char
    MOVLW '!'
    CALL send_char
    MOVLW ' '
    CALL send_char
    MOVLW 'E'
    CALL send_char
    MOVLW 's'
    CALL send_char
    MOVLW 'c'
    CALL send_char
    MOVLW 'a'
    CALL send_char
    MOVLW 'p'
    CALL send_char
    MOVLW 'e'
    CALL send_char
    
    BANKSEL PORTA 
    BSF PORTA , 1
    
    RETURN

LCD_HARDLUCK
;sending the 'Hard luck' string to the LCD
    CALL LCD_CLEAR
	MOVLW 0x80      ; Set DDRAM address to 0x00 (start of line 1)
	CALL send_cmd
	call DELAY_20MS
    MOVLW 'H'
    CALL send_char
    MOVLW 'a'
    CALL send_char
    MOVLW 'r'
    CALL send_char
    MOVLW 'd'
    CALL send_char
    MOVLW ' '
    CALL send_char
    MOVLW 'l'
    CALL send_char
    MOVLW 'u'
    CALL send_char
    MOVLW 'c'
    CALL send_char
    MOVLW 'k'
    CALL send_char
    RETURN

	
PROB0
;problem 1 : 5 + 3 =
	MOVLW 0x80      ; Set DDRAM address to 0x00 (start of line 1)
	CALL send_cmd
	call DELAY_20MS
    MOVLW '5'
    CALL send_char
    MOVLW '+'
    CALL send_char
    MOVLW '3'
    CALL send_char
    MOVLW '='
    CALL send_char
    GOTO WAIT_LOOP
PROB1
;problem 2 : 9 - 2 =
	MOVLW 0x80      ; Set DDRAM address to 0x00 (start of line 1)
	CALL send_cmd
	call DELAY_20MS
    MOVLW '9'
    CALL send_char
    MOVLW '-'
    CALL send_char
    MOVLW '2'
    CALL send_char
    MOVLW '='
    CALL send_char
    GOTO WAIT_LOOP
    
PROB2   
;problem 3 : 4 x 2 =   
	MOVLW 0x80      ; Set DDRAM address to 0x00 (start of line 1)
	CALL send_cmd
	call DELAY_20MS
    MOVLW '4'
    CALL send_char
    MOVLW 'x'
    CALL send_char
    MOVLW '2'
    CALL send_char
    MOVLW '='
    CALL send_char
    GOTO WAIT_LOOP
    
PROB3
;problem 4 : 8 / 2 =
	MOVLW 0x80      ; Set DDRAM address to 0x00 (start of line 1)
	CALL send_cmd
	call DELAY_20MS
    MOVLW '8'
    CALL send_char
    MOVLW '/'
    CALL send_char
    MOVLW '2'
    CALL send_char
    MOVLW '='
    CALL send_char
    GOTO WAIT_LOOP
    
PROB4
;problem 5 : 6 + 7 =
	MOVLW 0x80      ; Set DDRAM address to 0x00 (start of line 1)
	CALL send_cmd
	call DELAY_20MS
    MOVLW '6'
    CALL send_char
    MOVLW '+'
    CALL send_char
    MOVLW '7'
    CALL send_char
    MOVLW '='
    CALL send_char
    GOTO WAIT_LOOP

	

END