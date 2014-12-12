								   
    ****       ****  *******     ****    ***      ***
    ****       **** *******    ********  ***     ***
	*****     ***** ***		  ***    *** ***    ***
	******   ****** ***  	  ***    *** ***   ***
	******* *******	***	       ********  ***  ***
	*************** *******		******   ********
	****  ***  **** ********   ********  ***  ***
	****   *   **** ***   *** ***    *** ***   ***
	****       ****	***   *** ***    *** ***    ***
	****       ****	***   ***  ********  ***     ***
	****       ****  *******	 ****    ***      ***
	
			*********          ********** ****       ****
			***********      *********    ****       ****
			***    *****   *********      *****     *****
			***      **** ********        ******   ******
			***       *** ************    ******* *******
			***       *** *************** ***************
			***       ***    ************ ****  ***  ****
			***      ***         ******** ****   *   ****
			***    *****       ********   ****       ****
			***********      *********    ****       ****
			*********     **********      ****       ****
		
*-----------------------------------------------------------
* Title      :	Motorola 68k Instruction Dissassembler (DSM)
* Written by :  Abdul Hakim, David Trinh, Alexander Auxier
* Date       :	2014-12-11
* Description:	Stuff happens
*-----------------------------------------------------------
CR          EQU     $0D     
LF          EQU     $0A
     
zero        EQU     $00         			; defined hex value 0
one         EQU     $01         			; defined hex value 1 
two         EQU     $02         			; defined hex value 2
three       EQU     $03         			; defined hex value 3
four        EQU     $04         			; defined hex value 4
five        EQU     $05         			; defined hex value 5
six         EQU     $06         			; defined hex value 6
seven       EQU     $07						; defined hex value 7
eight       EQU     $08        				; defined hex value 8
nine        EQU     $09         			; defined hex value 9
eleven      EQU     $0B         			; defined hex value 11
twelve      EQU     $0C         			; defined hex value 12
thirteen    EQU     $0D         			; defined hex value 13
fourteen    EQU     $0E         			; defined hex value 14

mask0       EQU     %00000000
mask1       EQU     %00000001
mask2       EQU     %00000010
mask3       EQU     %00000100
mask4       EQU     %00001000
mask5       EQU     %00010000
mask6       EQU     %00100000
mask7       EQU     %01000000
mask8       EQU     %10000000

maskA       EQU     %00000101
maskB       EQU     %00001010
maskC       EQU     %00010100
maskD       EQU     %00101000
maskE       EQU     %01010000
maskF       EQU     %10100000

firstNib    EQU     $F0
secNib      EQU     $0F
             
            ORG    $1000
START: 
***********************************************************************************************************
*
*               	Dissassembler Start
*
***********************************************************************************************************
			; Dissassemble Start, obtain addr range
			JSR         displayStart   
			
			LEA     	startingMessage, A1
			MOVE.B  	#14, D0
			TRAP    	#15    
		
			MOVE.B  	#2, D0
			TRAP    	#15
    
			JSR     	Address
			MOVEA.L 	D2, A0
		
			LEA     	endingMessage, A1
			MOVE.B  	#14, D0
			TRAP    	#15    
    
			MOVE.B  	#2, D0
			TRAP    	#15
    
			JSR     	Address
			MOVEA.L		D2, A2
        
			LEA     	newline, A1
			MOVE.B  	#14, D0
			TRAP    	#15 
          
***********************************************************************************************************
*
*               	Control Loop
*
*		This loop cycles and branches our code by the first nibble of OPCODE binary
*
***********************************************************************************************************
		  
LOOP    	CLR         D1                  ; clear out D1
			CLR         D2                  ; clear out D2
			CMPA.L      A2, A0              ; compare starting and ending addresses
			BGT         endProg             ; if A0 > A1, we've finished, end program
			MOVEA       A0,A3
			MOVE.B      (A0)+, D1           ; load byte to D1 and increment A0 to next byte
			MOVE.B      D1, D2              ; copy byte to D2 for manipulation
			ASR.L       #four, D2           ; get first nibble in D2
        
			CMP.B       #zero, D2           ; compare with 0
			BEQ         braZero             ; branch out to zero method
			CMP.B       #one, D2            ; compare with 1
			BEQ         braOne              ; branch out to one method
			CMP.B       #two, D2            ; compare with 2    
			BEQ         braTwo              ; branch out to two method
			CMP.B       #three, D2          ; compare with 3
			BEQ         braThree            ; branch out to three method
			CMP.B       #four, D2           ; compare with 4
			BEQ         braFour             ; branch out to four method
			CMP.B       #five, D2           ; compare with 5
			BEQ         braFive             ; branch out to five method
			CMP.B       #six, D2            ; compare with 6
			BEQ         braSix              ; branch out to six method
			CMP.B       #eight, D2          ; compare with 8
			BEQ         braEight            ; branch out to eight method
			CMP.B       #nine, D2           ; compare with 9
			BEQ         braNine             ; branch out to nine method
			CMP.B       #eleven, D2         ; compare with 11
			BEQ         braEleven           ; branch out to eleven method
			CMP.B       #twelve, D2         ; compare with 12
			BEQ         braTwelve           ; branch out to twelve method
			CMP.B       #thirteen, D2       ; compare with 13
			BEQ         braThirteen         ; branch out to thirteen method
			CMP.B       #fourteen, D2       ; compare with 14
			BEQ         braFourteen         ; branch out to fourteen method
			BRA         loop

***********************************************************************************************************
*
*               	Nibble Branch Section
*
*		This section decides which nibble goes to the corresponding opcode
*
***********************************************************************************************************	
		
braZero 	
			CLR         D2                  ; first nibble is 0, 3 opcodes are possible 
			MOVE.B      D1, D2              ; clear out D2 and copy D1 back in
			AND.B       #secNib, D2         ; set first nibble to 0

			CMP.B       #zero, D2           ; compare second nibble to 0
			BEQ         opORI               ; branch to ORI method
			CMP.B       #twelve, D2         ; compare second nibble to 12
			BEQ         opCMPI              ; branch to CMPI method
			CMP.B       #eight,D2           ; Test for static BCLR
			BEQ         opBCLR
			AND         #one,D2            	; Sets all bits to 0 except for first bit if it is 1
			CMP.B       #one,D2          	; if it is one then there is a chance it is dynamic BCLR
			BEQ         opDynBCLR
			BRA         printInvalid
        
braOne  	
			BRA         opMOVEB             ; we know that there is only one opcode that is MOVE.B

braTwo  	
			BRA         opMOVEL             ; there are two opCodes available, MOVE.L, or MOVEA.L

braThree                                	; there are two opCodes available, MOVE.W, or MOVEA.W
			BRA         opMOVEW

braFour 	CLR         D2                  ; first nibble is 4, 5 opcodes are possible 
			MOVE.B      D1, D2              ; clear out D2 and copy D1 back in
			AND.B       #secNib, D2         ; set first nibble to 0
 
			CMP.B       #four, D2           ; compare second nibble to 4
			BEQ         opNEG               ; branch to NEG method
			CMP.B       #fourteen, D2       ; compare second nibble to E
			BEQ         opRTSJSR            ; branch to JSR or RTS method
			BRA         opMOVEMLEA          ; otherwise, branch to MOVEM or LEA method

braFive 	
			BRA         opSUBQ              ; we know that there is only one opcode that is SUBQ

braSix  	
			CLR         D2                  ; first nibble is 6, 5 opcodes are possible 
			MOVE.B      D1, D2              ; clear out D2 and copy D1 back in
			AND.B       #$0F, D2             ; set first nibble to 0
 
			CMP.B       #zero, D2           ; compare second nibble to 0
			BEQ         opBRA               ; branch to BRA method
			CMP.B       #five, D2           ; compare second nibble to 5
			BEQ         opBCS               ; branch to BCS method
			CMP.B       #eight, D2          ; compare second nibble to 8
			BEQ         opBVC               ; branch to BCS method
			CMP.B       #twelve, D2         ; compare second nibble to 12
			BEQ         opBGE               ; branch to BGE method
			CMP.B		#thirteen,D2		; compare second nibble to 13
			BEQ         opBLT               ; branch to BLT method
			BRA			printInvalid		; found an un-supported opcode

braEight                                	; there are two opCodes available DIVS, or OR
            CLR     	D2					; clear D2 for use
            ASL     	#8,D1				; Shift by eight 
            MOVE.B  	(A0)+,D1			; Move the instruction byte into D1
            MOVE.W  	D1,D2				; Load D2 with the word from D1
            ASR     	#six,D2				; Shift by 6 to find second nibble
            AND     	#$07,D2				; AND by 7 to remove unwanted bits
            CMP.B   	#seven,D2			; Compare second nibble to 7
            BEQ     	opDIVS              ; If bits 8 - 6 are equal to 7, we have DIVS
            BRA     	opOR                ; else opcode is OR

braNine 	
			BRA			opSUB               ; we know that there is only one opcode that is SUB

braEleven                               	; there are two opCodes available EOR, or CMP
            CLR     	D2					; clear D2 for use
            ASL     	#8,D1				; Shift by eight for
            MOVE.B  	(A0)+,D1			; Re-load the instruction byte into D1
            MOVE.W  	D1,D2				; Move the word into D2 for the comparison
            ASR     	#six,D2				; Shift by 6 to find second nibble
            AND     	#$07,D2				; AND by 7 to remove unwanted bits
            CMP.B   	#three,D2			; Compare second nibble to 3
            BLT     	opCMP               ; If opmode bits are less than 3, we have CMP
            BGT     	opEOR               ; Else its EOR

braTwelve   
			BRA			opMULS              ; we know that there is only one opcode that is MULS    
  
braThirteen 
			ASL         #eight, D1          ; we need the whole word to compare between add and adda, so move over the current byte 
            MOVE.B      (A0)+, D1           ; load the remaining byte to D1
            
            CLR         D2                  ; clear D2
            MOVE.W      D1, D2              ; copy opcode to D2
            ASR         #six, D2            ; shift the bits right to get size and type
            AND         #seven,D2           ; clear out all but first 3 bits
            
            CMP.B       #zero,D2            ; compare 0 to D2
            BEQ         opADDB              ; we know its ADDB
            CMP.B       #one, D2            ; compare 1 to D2
            BEQ         opADDW              ; we know its ADDW
            CMP.B       #two, D2            ; compare 2 to D2
            BEQ         opADDL              ; we know its ADDL
            CMP.B       #three, D2          ; compare 3 to D2
            BEQ         opADDAW             ; we know its ADDAW
            CMP.B       #four, D2           ; compare 4 to D2
            BEQ         opADDB              ; we know its ADDB
            CMP.B       #five, D2           ; compare 5 to D2
            BEQ         opADDW              ; we know its ADDW
            CMP.B       #six, D2            ; compare 6 to D2
            BEQ         opADDL              ; we know its ADDL
            CMP.B       #seven, D2          ; compare 7 to D2
            BEQ         opADDAL             ; we know its ADDAL
            BRA         printInvalid        ; invalid opcode
             
braFourteen 
			ASL.W       #eight,D1           ; we need the whole word to compare between add and adda, so move over the current byte
            MOVE.B      (A0)+, D1           ; load the remaining byte to D1
            
            CLR         D2                  ; clear D2
            MOVE.W      D1, D2              ; copy opcode to D2
            ASR         #six, D2            ; shift the bits right to get size
            AND         #03,D2
        
            CMP.B       #three, D2          ; if the size is three, we are shifting memory
            BEQ         memShifts           ; go to memory shift
            BRA         regShifts           ; else go to register shift

memShifts   
			CLR         D2             
            MOVE.W      D1, D2              ; clear out D2 and copy D1 back in
            ASR.L       #eight,D2           ; move to get first byte back
            AND         #secNib, D2         ; set first nibble to 0
 
            CMP.B       #zero, D2           ; compare second nibble to 0
            BEQ         opASR               ; branch to ASR method
            CMP.B       #one, D2            ; compare second nibble to 1
            BEQ         opASL               ; branch to ASL method
            CMP.B       #two, D2            ; compare second nibble to 2
            BEQ         opLSR               ; branch to LSR method
            CMP.B       #three, D2          ; compare second nibble to 3
            BEQ         opLSL               ; branch to LSL method
            CMP.B       #six, D2            ; compare second nibble to 6
            BEQ         opROR               ; branch to ROR method
            CMP.B       #seven, D2          ; compare second nibble to 7
            BEQ         opROL               ; branch to ROL method
            BRA         printInvalid        ; otherwise, invalid
            
regShifts   
			CMP.B       #zero, D2           ; if size is 0, we are shifting a byte
            BEQ         memSB               ; branch to register shift byte
            CMP.B       #one, D2            ; if size is 1, we are shifting a word
            BEQ         memSW               ; branch to register shift word
            CMP.B       #two, D2            ; if size is 1, we are shifting a long
            BEQ         memSL               ; branch to register shift long
            BRA         printInvalid        ; otherwise, invalid
			
***********************************************************************************************************
*
*               	ORI OPCODE
*       ORI starts out with size branching. Will compare sizes and branch to appropriate size.
*       Once size is found, code will print out ORI and continue to find mode and register and print it out
*
***********************************************************************************************************

opORI   	
			MOVE.B      (A0)+, D1
			MOVE.B      D1,D2               ; copy data over
			ASR         #6,D2               ; shifts 6 bits over to read just the size        
			CMP.B       #zero,D2            ; Size is 0, must be byte
			BEQ         opORIB              ; Branch to ORIB to print and deal with the byte
			CMP.B       #one,D2             ; Compare size to one
			BEQ         opORIW              ; If size is one, then ORI is dealing with a word.
			CMP.B       #two,D2             ; Compare size to two
			BEQ         opORIL              ; If size is two then move onto deal with long in opORIL
        
			BRA         printInvalid        ; None matches, invalid code. Branch off.
        
opORIB  	
			LEA         ORImatch, A1        ; we know that the opcode will be ORI, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			
			LEA         dispByte, A1        ; Display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D4                  ; Clear D4 to use as temporary register for destination mode
			MOVE.B      D1,D4               ; Move byte over to D4 to use
			ASR         #three,D4           ; Moves out insignifcant bits to find mode
			AND         #seven,D4           ; Clear other bits besides mode
			CLR         D5                  ; Use D5 as temporary register for destination regsiter
			MOVE.B      D1,D5               ; Move data over to isolate mode
			AND         #seven,D5           ; Isolate the mode
        
			CLR         D3                  ; Clear D3 to move register into it
			CLR         D2                  ; Clear D2 to move mode into it
			MOVE.B      #four,D3            ; Set values to be used in printEA
			MOVE.B      #seven,D2           ; Set values to be used in printEA
    
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         comma, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2                  ; Clear out D2 to move destination mode in
			CLR         D3                  ; Clear out D3 to move destintion register in
			MOVE.B      D4,D2               ; Move destination mode into D2 to be used in print EA
			MOVE.B      D5,D3               ; Move destination register into D3 to be used in printEA
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         newLine, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits
        
opORIW  	
            MOVE        A3,A1
            MOVE.B      #14,D0
            TRAP        #15
            
			LEA         ORImatch, A1        ; we know that the opcode will be ORI, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			
			LEA         dispWord, A1        ; Display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D4                  ; Clear D4 to use as temporary register for destination mode
			MOVE.B      D1,D4               ; Move byte over to D4 to use
			ASR         #three,D4           ; Moves out insignifcant bits to find mode
			AND         #seven,D4           ; Clear other bits besides mode
			CLR         D5                  ; Use D5 as temporary register for destination regsiter
			MOVE.B      D1,D5               ; Move data over to isolate mode
			AND         #seven,D5           ; Isolate the mode
        
			CLR         D3                  ; Clear D3 to move register into it
			CLR         D2                  ; Clear D2 to move mode into it
			MOVE.B      #four,D3            ; Set values to be used in printEA
			MOVE.B      #seven,D2           ; Set values to be used in printEA
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         comma, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2                  ; Clear out D2 to move destination mode in
			CLR         D3                  ; Clear out D3 to move destintion register in
			MOVE.B      D4,D2               ; Move destination mode into D2 to be used in print EA
			MOVE.B      D5,D3               ; Move destination register into D3 to be used in printEA
                
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         newLine, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits
     
opORIL  	
			LEA         ORImatch, A1        ; we know that the opcode will be ORI, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			
			LEA         dispLong, A1        ; Display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D4                  ; Clear D4 to use as temporary register for destination mode
			MOVE.B      D1,D4               ; Move byte over to D4 to use
			ASR         #three,D4           ; Moves out insignifcant bits to find mode
			AND         #seven,D4           ; Clear other bits besides mode
			CLR         D5                  ; Use D5 as temporary register for destination regsiter
			MOVE.B      D1,D5               ; Move data over to isolate mode
			AND         #seven,D5           ; Isolate the mode
        
			CLR         D3                  ; Clear D3 to move register into it
			CLR         D2                  ; Clear D2 to move mode into it
			MOVE.B      #four,D3            ; Set values to be used in printEA
			MOVE.B      #seven,D2           ; Set values to be used in printEA
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			CLR         D2                  ; Clear out D2 to move destination mode in
			CLR         D3                  ; Clear out D3 to move destintion register in
			MOVE.B      D4,D2               ; Move destination mode into D2 to be used in print EA
			MOVE.B      D5,D3               ; Move destination register into D3 to be used in printEA
        
			LEA         comma, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         newLine, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits
        
***********************************************************************************************************
*
*               	CMPI OPCODE
*		This section is dedicated to the compare (CMPI) instruction. Its determined in the control loop
*		that the first nibble is 0 for CMPI, and the second nibble is 12.
*		The type of CMPI, or the opmode, is used to determined what we output to our console next.
*		From that point, we load the correct size/opmode, and then route to the EA subroutine to output
*		EA related register information.
*		The process for finding the operand register info (EA info) is similar for all opmodes.
*
***********************************************************************************************************
		
opCMPI           
			MOVE.B      (A0)+, D1
			MOVE.B      D1,D2               ; copy data over
			ASR         #6,D2               ; shifts 6 bits over to read just the size        
			CMP.B       #zero,D2            ; Check if size is 0 which is byte
			BEQ         opCMPIB             ; Moves to CMPIB if it is 0
			CMP.B       #one,D2             ; Check if size is 0 which is word
			BEQ         opCMPIW             ; Branch to CMPIW
			CMP.B       #two,D2             ; Check if size is 2 which is long
			BEQ         opCMPIL             ; Branch to CMPIL
			BRA         invalid             ; Size is invalid, therefore code is invalid.

opCMPIB 
			LEA         CMPImatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispByte, A1        ; Display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D4                  ; Clear D4 to use as temporary register for destination mode
			MOVE.B      D1,D4               ; Move byte over to D4 to use
			ASR         #three,D4           ; Moves out insignifcant bits to find mode
			AND         #seven,D4           ; Clear other bits besides mode
			CLR         D5                  ; Use D5 as temporary register for destination regsiter
			MOVE.B      D1,D5               ; Move data over to isolate mode
			AND         #seven,D5           ; Isolate the mode
        
			CLR         D3                  ; Clear D3 to move register into it
			CLR         D2                  ; Clear D2 to move mode into it
			MOVE.B      #four,D3            ; Set values to be used in printEA
			MOVE.B      #seven,D2           ; Set values to be used in printEA  
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
            
			LEA         comma, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2                  ; Clear out D2 to move destination mode in
			CLR         D3                  ; Clear out D3 to move destintion register in
			MOVE.B      D4,D2               ; Move destination mode into D2 to be used in print EA
			MOVE.B      D5,D3               ; Move destination register into D3 to be used in printEA    
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         newLine, A1        	; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits

opCMPIW 
			LEA         CMPImatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispWord, A1        ; Display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D4                  ; Clear D4 to use as temporary register for destination mode
			MOVE.B      D1,D4               ; Move byte over to D4 to use
			ASR         #three,D4           ; Moves out insignifcant bits to find mode
			AND         #seven,D4           ; Clear other bits besides mode
			CLR         D5                  ; Use D5 as temporary register for destination regsiter
			MOVE.B      D1,D5               ; Move data over to isolate mode
			AND         #seven,D5           ; Isolate the mode
        
			CLR         D3                  ; Clear D3 to move register into it
			CLR         D2                  ; Clear D2 to move mode into it
			MOVE.B      #four,D3            ; Set values to be used in printEA
			MOVE.B      #seven,D2           ; Set values to be used in printEA      
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         hashTag, A1         ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			MOVE.B      #3, D0              ; Move 3 into D0 to output
			TRAP        #15                 ; Use TRAP #15 to output the immediate data
        
			LEA         comma, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			CLR         D2                  ; Clear out D2 to move destination mode in
			CLR         D3                  ; Clear out D3 to move destintion register in
			MOVE.B      D4,D2               ; Move destination mode into D2 to be used in print EA
			MOVE.B      D5,D3               ; Move destination register into D3 to be used in printEA    
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         newLine, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits

opCMPIL 
			LEA         CMPImatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispLong, A1        ; Display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			
			CLR         D4                  ; Clear D4 to use as temporary register for destination mode
			MOVE.B      D1,D4               ; Move byte over to D4 to use
			ASR         #three,D4           ; Moves out insignifcant bits to find mode
			AND         #seven,D4           ; Clear other bits besides mode
			CLR         D5                  ; Use D5 as temporary register for destination regsiter
			MOVE.B      D1,D5               ; Move data over to isolate mode
			AND         #seven,D5           ; Isolate the mode
        
			CLR         D3                  ; Clear D3 to move register into it
			CLR         D2                  ; Clear D2 to move mode into it
			MOVE.B      #four,D3            ; Set values to be used in printEA
			MOVE.B      #seven,D2           ; Set values to be used in printEA  
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         comma, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2                  ; Clear out D2 to move destination mode in
			CLR         D3                  ; Clear out D3 to move destintion register in
			MOVE.B      D4,D2               ; Move destination mode into D2 to be used in print EA
			MOVE.B      D5,D3               ; Move destination register into D3 to be used in printEA                
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         newLine, A1         ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits
		
***********************************************************************************************************
*
*               	BCLR OPCODE
*		This section is dedicated to the compare BCLR instruction. The first nibble is 0 and the second
*       nibble is 2. Once both checks are passed then code goes to print BCLR and its EA.
*		
***********************************************************************************************************

opBCLR		
			LEA         BCLRmatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
                
            CLR         D2                  ; Clear data register
            MOVE.B      (A0)+, D1           ; Move byte over to D1 to be used
            MOVE.B      D1,D2               ; copy data over
            ASR         #three,D2           ; Shift to the right to remove register
            AND         #seven,D2           ; Sets other bits to 0 and leave Mode the same
                
            CLR         D3                  ; Clear D3 so we can move D1 in
            MOVE.B      D1,D3               ; Move othr byte in
            AND         #seven,D3           ; Set everything besides register to 0
               
            CLR         D1                  ; Clear out data register
            MOVE.W      (A0)+, D1           ; Take in next nibble that contains data
               
                
            LEA         hashTag, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            MOVE.B      #3, D0
            TRAP        #15
        
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
                
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
            LEA         newLine, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
                
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits   
        
opDynBCLR       
            CLR         D1
            MOVE.B      (A0)+,D1            ; Copy second byte in
            MOVE.B      D1,D3               ; Will use D4 to store in the source register
            ASR         #one,D3             ; Shift register over to the end
            AND         #seven,D3           ; Change all bits except for the register to 0. Source Register is now in D4
                
            MOVE.B      D1,D2
            ASR         #six,D2             ; Removing mode and register to check BCLR bits
            CMP         #two,D2             ; Checking the static bits to make sure it is BCLR
            BNE         printInvalid        ; If not equal, than this is not BCLR or any other mode we're dealing with

                
            LEA         BCLRmatch, A1       ; we now know that the opcode will be BCLR, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
                
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
                
            MOVE.B      #zero,D2            ; Move 0 into D2 to print out data register in printEA   
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
                
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
              
            CLR         D2
            MOVE.B      D1,D2               ; Using D2 to store EA mode
            ASR         #three,D2           ; Remove/shift the register out
            AND         #seven,D2           ; Change all bits except for the mode bits to 0
                
            CLR         D3                  ; Clearing D3 to avoid mashing data
            MOVE.B      D1,D3               ; Moving byte into D3. Using D3 to store EA register
            AND         #seven,D3           ; Change all bits except for register bits to 0
            
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            


            BRA         LOOP                ; go back to the loop	
				
***********************************************************************************************************
*
*               	MOVE OPCODE
*					MOVEA OPCODE
*       This section of code is dedication to MOVE and MOVEA opcode instructions. MOVEA is determined by
*       its static bits at 8, 7, and 6. Once those static bits are confirmed, the code branches off to 
*       MOVEA, else it continues into MOVE.
*
***********************************************************************************************************
 
opMOVEB 
			LEA         MOVEmatch, A1       ; we know that the opcode will be MOVE.B, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			LEA         space, A1           ; create spaces
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
        
			CLR         D5                  ; Clear D5
			MOVE.B      D1,D5               ; Copying byte over to D5. Will use D5 to store destination Register
			ASR         #one,D5             ; shifted mode out. Register is now stored into D5
			AND         #seven,D5
        
			CLR         D4                  ; Clear out D4
			MOVE.B      D1,D4               ; Copy byte over to store destination mode
			AND         #one,D4             ; Set all the other bits to 0, leave the bit for the destination mode alone.
        
			CLR          D1                 ; Clear data register
			CLR          D2                 ; Clear data register
			MOVE.B      (A0)+,D1            ; Copy byte into D1
			MOVE.B      D1,D2
			ASR         #6,D2               ; Shifts source mode and register out to get destination mode
			ADD         D2,D4               ; Adds the remaining bits to D4
        
			CLR         D2                  ; Clear data register
			MOVE.B      D1,D2               ; Copy new byte over to D2
			ASR         #three,D2           ; Shift source register out
			AND         #seven,D2           ; Set everything to 0 except for the mode
        
			CLR         D3                  ; Clear Data register 3
			MOVE.B      D1,D3               ; Moves byte over to D3 to find the register
			AND         #seven,D3           ; Sets up everything to 0 except for the register bits
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         comma, A1           ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2                  ; Clear data register
			CLR         D3                  ; Clear data register
			MOVE.B      D4,D2               ; Moves EA mode into D2 to use printEA
			MOVE.B      D5,D3               ; Moves register to D3 to be used in printEA
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
			LEA         newLine, A1         ; Display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call            

			BRA         LOOP                ; go back to the loop
        
opMOVEL     
            CLR         D5                  ; Clear D5
            MOVE.B      D1,D5               ; Copying byte over to D5. Will use D5 to store destination Register
            ASR         #one,D5             ; shifted mode out. Register is now stored into D5
            AND         #seven,D5
        
            CLR         D4                  ; Clear out D4
            MOVE.B      D1,D4               ; Copy byte over to store destination mode
            AND         #one,D4             ; Set all the other bits to 0, leave the bit for the destination mode alone.
        
            CLR          D1                 ; Clear data register
            CLR          D2                 ; Clear data register
            MOVE.B      (A0)+,D1            ; Copy byte into D1
            MOVE.B      D1,D2
            ASR         #6,D2               ; Shifts source mode and register out to get destination mode
            ADD         D2,D4               ; Adds the remaining bits to D4
        
            CMP         #one,D4             ; Check if it is MOVEA
            BEQ         opMOVEAL            ; If it is, branch off
            
            LEA         MOVEmatch, A1       ; we know that the opcode will be MOVE.L OR MOVEA.L, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
            
            LEA         dispLong,A1         ; Prints out L to display a long
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         space, A1           ; create spaces
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            CLR         D2                  ; Clear data register
            MOVE.B      D1,D2               ; Copy new byte over to D2
            ASR         #three,D2           ; Shift source register out
            AND         #seven,D2           ; Set everything to 0 except for the mode
        
			CLR         D3                  ; Clear Data register 3
			MOVE.B      D1,D3               ; Moves byte over to D3 to find the register
			AND         #seven,D3           ; Sets up everything to 0 except for the register bits      
            
            CLR         D6                  ; Clear data register
            MOVE.B      #1,D6               ; Moves 1 into D6 to be used in printEA to display long
            JSR         printEA             ; Prints out EA
            CLR         D6
            
            LEA         comma, A1           ; Display comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
			CLR         D2                  ; Clear data register            
			CLR         D3                  ; Clear data register
			MOVE.B      D4,D2               ; Moves EA mode into D2 to use printEA
			MOVE.B      D5,D3               ; Moves register to D3 to be used in printEA
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address

            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            

            BRA         LOOP                ; go back to the loop
            
opMOVEAL
            LEA         MOVEAmatch,A1       ; MOVEA has been determined. Print out MOVEA
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         dispLong,A1         ; Prints out L
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            

            LEA         space, A1           ; create spaces
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2                  ; Clear data register
            MOVE.B      D1,D2               ; Copy new byte over to D2
            ASR         #three,D2           ; Shift source register out
            AND         #seven,D2           ; Set everything to 0 except for the mode
        
			CLR         D3                  ; Clear Data register 3
			MOVE.B      D1,D3               ; Moves byte over to D3 to find the register
			AND         #seven,D3           ; Sets up everything to 0 except for the register bits    
            
            CLR         D1                  ; Clear D1
			
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
            
            LEA         comma, A1           ; Display comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

			CLR         D2                  ; Clear data register
			CLR         D3                  ; Clear data register
			MOVE.B      D4,D2               ; Moves EA mode into D2 to use printEA
			MOVE.B      D5,D3               ; Moves register to D3 to be used in printEA
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            

            BRA         LOOP                ; go back to the loop

opMOVEW
            CLR         D5                  ; Clear D5
            MOVE.B      D1,D5               ; Copying byte over to D5. Will use D5 to store destination Register
            ASR         #one,D5             ; shifted mode out. Register is now stored into D5
            AND         #seven,D5
        
            CLR         D4                  ; Clear out D4
            MOVE.B      D1,D4               ; Copy byte over to store destination mode
            AND         #one,D4             ; Set all the other bits to 0, leave the bit for the destination mode alone.
        
            CLR          D1                 ; Clear data register
            CLR          D2                 ; Clear data register
            MOVE.B      (A0)+,D1            ; Copy byte into D1
            MOVE.B      D1,D2
            ASR         #6,D2               ; Shifts source mode and register out to get destination mode
            ADD         D2,D4               ; Adds the remaining bits to D4
        
            CMP         #one,D4             ; Check if it is MOVEA
            BEQ         opMOVEAW            ; If it is, branch off
            
            LEA         MOVEmatch, A1       ; we know that the opcode will be MOVE.L OR MOVEA.L, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
            
            LEA         dispWord,A1         ; Prints out a W after the opcode
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         space, A1           ; create spaces
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            CLR         D2
            MOVE.B      D1,D2               ; Copy new byte over to D2
            ASR         #three,D2           ; Shift source register out
            AND         #seven,D2           ; Set everything to 0 except for the mode
        
			CLR         D3                  ; Clear Data register 3
			MOVE.B      D1,D3               ; Moves byte over to D3 to find the register
			AND         #seven,D3           ; Sets up everything to 0 except for the register bits  
            
            CLR         D1                  ; Clear D1
            
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
            
            LEA         comma, A1           ; Display comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
			CLR         D2                  ; Clear data register 
			CLR         D3                  ; Clear data register
			MOVE.B      D4,D2               ; Moves EA mode into D2 to use printEA
			MOVE.B      D5,D3               ; Moves register to D3 to be used in printEA
            JSR         printEA
        
            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            

            BRA         LOOP                ; go back to the loop
			
opMOVEAW  
            LEA         MOVEAmatch,A1       ; Prints out MOVEA
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
                
            LEA         dispWord,A1         ; Prints out W
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         space, A1           ; create spaces
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2                  ; Clear data register
            MOVE.B      D1,D2               ; Copy new byte over to D2
            ASR         #three,D2           ; Shift source register out
            AND         #seven,D2           ; Set everything to 0 except for the mode
        
			CLR         D3                  ; Clear Data register 3
			MOVE.B      D1,D3               ; Moves byte over to D3 to find the register
			AND         #seven,D3           ; Sets up everything to 0 except for the register bits  
            
            CLR         D1                  ; Clear D1      
            
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
            
            LEA         comma, A1           ; Display comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

			CLR         D2                  ; Clear data register
			CLR         D3                  ; Clear data register
			MOVE.B      D4,D2               ; Moves EA mode into D2 to use printEA
			MOVE.B      D5,D3               ; Moves register to D3 to be used in printEA
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
        
            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            

            BRA         LOOP                ; go back to the loop

***********************************************************************************************************
*
*               	NEG OPCODE
*       This section is dedicated to the NEG opmode instruction. NEG is determined by the first and
*       the second nibble. The first nibble is 4 and the second nibble is equal to 0. Once that has been
*       determined. NEG is printed out.
***********************************************************************************************************

opNEG   
            LEA         NEGmatch, A1        ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
        
            MOVE.B      (A0)+, D1           ; Move data into D1 for use 
            MOVE.B      D1,D2               ; copy data over
            ASR         #six,D2             ; Moves six bits over to read the size
            
            CMP         #zero,D2            ; Compare size
            BEQ         opNEGB              ; Branch to NEG if size is byte
            CMP         #one,D2             ; Compare size with one, 
            BEQ         opNEGW              ; If equal, size is a word. Branch to NEGW
            CMP         #two,D2             ; Compare size with two
            BEQ         opNEGL              ; If size is two, NEG size is long. Branch to NEGL
            BRA         invalid             ; If size is neither, code is invalid. Branch to deal with invalid code.
			
opNEGB
            LEA         dispByte, A1        ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            LEA         space, A1           ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            CLR         D2                  ; Clear Data register 2
            MOVE        D1,D2               ; Move byte into D2
            ASR         #three,D2           ; Shift mode into place and moves mode into place
            AND         #seven,D2           ; Stores mode
            
			CLR         D3                  ; Clear Data register 3
			MOVE.B      D1,D3               ; Moves byte over to D3 to find the register
			AND         #seven,D3           ; Sets up everything to 0 except for the register bits  
			
            JSR         printEA
                
            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
        
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits

opNEGL
            LEA         dispLong, A1        ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

            LEA         space, A1           ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
                
            CLR         D2                  ; Clear Data register 2
            MOVE        D1,D2               ; Move byte into D2
            ASR         #three,D2           ; Shift mode into place and moves mode into place
            AND         #seven,D2           ; Stores mode
        
			CLR         D3                  ; Clear Data register 3
			MOVE.B      D1,D3               ; Moves byte over to D3 to find the register
			AND         #seven,D3           ; Sets up everything to 0 except for the register bits  
        
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
                    
            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
        
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits

opNEGW
            LEA         dispWord, A1        ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            LEA         space, A1           ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
                
            CLR         D2                  ; Clear Data register 2
            MOVE        D1,D2               ; Move byte into D2
            ASR         #three,D2           ; Shift mode into place and moves mode into place
            AND         #seven,D2           ; Stores mode
        
			CLR         D3                  ; Clear Data register 3
			MOVE.B      D1,D3               ; Moves byte over to D3 to find the register
			AND         #seven,D3           ; Sets up everything to 0 except for the register bits  
        
            JSR         printEA
            
            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
        
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits
			
***********************************************************************************************************
*
*               	RTS_JSR Helper Function
*       Compare byte with static bits from JSR and RTS. If data is not equal to either, then data is
*       considered an invalid opcode and branches off to invalid.
*
***********************************************************************************************************

opRTSJSR
            MOVE.B      (A0)+, D1           ; Move byte into D1 and increment.
            
            MOVE.B      D1,D2               ; copy data over
            CMP         #117,D2             ; 117 is the decimal value of RTS.
            BEQ         opRTS               ; If equal, branch to RTS to print out.
            
            ASR         #six,D2             ; Moving bits over to check if it matches the two static bits in JSR
            CMP         #two,D2             ; Checking if it is JSR
            BEQ         opJSR               ; It is equal, so branch off to opJSR

            BRA         invalid             ; Branch to invalid to deal with invalid data.
			
***********************************************************************************************************
*
*               	JSR OPCODE
*       This section is dedicated to the JSR opmode instruction. JSR is determined by the 9 static bits.
*       Once the bits have matched the disassembled code, the code passes through and prints out JSR along
*       with its EA.               
*
***********************************************************************************************************

opJSR
            LEA         JSRMatch, A1       	; we know that the opcode will be JSR, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         space, A1           ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2                  ; Clearing data register 
            CLR         D3                  ; Clearing data register 
            
            MOVE.B      D1,D2               ; Move D1 data to D2 to find the EA mode
            ASR         #three,D2           ; Move mode over to the end in order to read
            AND         #seven,D2           ; Set every bit to 0 except for mode bits
            
            CLR         D3
            MOVE.B      D1,D3               ; Move bits over to D3 to find register
            AND         #seven,D3           ; Sets every bit to 0 except for register bits
            
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
            
            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
            
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits

***********************************************************************************************************
*
*               	RTS OPCODE
*       Function prints out RTS. Does not need to check in here as it is done beforehand. Branches back
*       into loop afterwards.
*
***********************************************************************************************************

opRTS
            LEA         RTSMatch, A1       	; we know that the opcode will be RTS, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call 
            
            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits
			
***********************************************************************************************************
*
*               	MOVEM_LEA OPCODE
*       This part of the code is used to branch to either MOVEM or LEA depending on the second nibble.
*
***********************************************************************************************************

opMOVEMLEA
            CLR         D2                  ; Clear D2
            MOVE.B      D1,D2               ; Copy byte over
            AND         #secNib,D2          ; Check only the second nibble
            CMP         #twelve,D2          ; Compare the second nibble to twelve
            BEQ         opMOVEM             ; If it is twelve, then it is MOVEM
            CMP         #eight,D2           ; Compare the second nibble to eight
            BEQ         opMOVEM             ; If it is eight, then it is also MOVEM
            BRA         opLEA               ; Otherwise branch to OPLEA and check for invalid in there
            
***********************************************************************************************************
*
*               	MOVEM OPCODE
*       MOVEM has 7 static bits. Before anything is done, static bits are checked and the dr field is stored
*       into D6 to be used later on for specific branching. After the static bits have confirmed this is
*       indeed MOVEM that is being disassembled, the code will print out MOVEM and goes into the subroutine
*       to print out the data and address registers.
*
***********************************************************************************************************

opMOVEM            
            CLR         D6                  ; Clearing D4 to store dr field
            MOVE.B      D1,D6               ; Moving byte to find dr field
            ASR         #two,D6             ; Moving dr field to readable spot
            AND         #one,D6             ; seting everything except dr to 0

            CLR         D1  
            MOVE.B      (A0)+, D1           ; Taking in next byte
            
            CLR         D5
            MOVE.B      D1,D5               ; Using D6 to check if this is indeed MOVEM
            ASR         #seven,D5
            AND         #one,D5
            CMP         #one,D5             ; This bit should be one if this is MOVEM
            BNE         invalid             ; If this is not 1 then this is not moveM
            CLR         D5
            
            LEA         MOVEMMatch, A1       ; we know that the opcode will be MOVEM, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clearing D5 to store size
            MOVE.B      D1,D5               ; Moving byte that contains bit for size
            ASR         #six,D5            	; Moving size bit to the very right to read
            AND         #one,D5             ; Isolating the one bit for size
            
            CLR         D2                  ; Clear Data register 2
            MOVE        D1,D2               ; Move byte into D2
            ASR         #three,D2           ; Shift mode into place and moves mode into place
            AND         #seven,D2           ; Stores mode
            
            CLR         D3                  ; Storing EA register into D3
            MOVE.B      D1,D3               ; Move bits over to D3 to find register
            AND         #seven,D3           ; Sets every bit to 0 except for register bits
            
            JSR         MOVEMBRA            ; Jumps to subroutine that prints out the data and address registers
            
            CMP         #three,D2           ; Checks if this is post increment
            BEQ         skipPrintEA         ; If it is, skipping printing EA again, because it is printed already in JSR
            
            LEA         comma, A1           ; Display comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
            
            LEA         newline, A1        	; we know that the opcode will be MOVEM, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            

            BRA         loop                ; Branch back to outer most loop that finds the first four bits

skipPrintEA 
            LEA         newline, A1         ; Prints out new line or carraige return
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            

            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits
			
***********************************************************************************************************
*
*               LEA OPCODE
*
*		This section is dedicated to the LEA opcode. This is determined that the first nibble is 4 nibbles as
*       well as the three static nibbles on 8,7, and 6. Once both have been checked, the code prints out
*       LEA and goes on to print its effective address.
*
***********************************************************************************************************

opLEA
            CLR         D4                  ; Clearing space for source register
            MOVE.B      D1,D4               ; Moving byte to isolate register
            ASR         #one,D4
            AND         #seven,D4           ; Isolated register

            CLR         D5                  ; Clearing D5 to check if bits match LEA static bits
            MOVE.B      D1,D5               ; Stores destination register in temporary data register for later use
            AND         #one,D5             ; Setting all other bits to one except for mode register
            ASL         #two,D5             ; Shifts the two register bits over to correct spot
            
            MOVE.B      (A0)+, D1           ; Taking in next byte
            
            MOVE.B      D1,D6               
            ASR         #six,D6             ; Shifts 6 bits over to move register
            ADD         D6,D5               ; Add the remaining bits to the register
            CLR         D6                  ; Clear out the temporary register

            CMP         #seven,D5           ; Checks the seven static bits to see if it is LEA
            BNE         invalid             ; If it is not equal then this is not LEA
            
            LEA         LEAmatch, A1        ; we know that the opcode will be LEA, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            

            LEA         space, A1         	; we know that the opcode will be MOVEM, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            
            
            CLR         D2                  ; Clear Data register 2
            MOVE        D1,D2               ; Move byte into D2
            ASR         #three,D2           ; Shift mode into place and moves mode into place
            AND         #seven,D2           ; Stores mode
            
            CLR         D3
            MOVE.B      D1,D3               ; Move bits over to D3 to find register
            AND         #seven,D3           ; Sets every bit to 0 except for register bits
            
            JSR         printEA             ; Jump to sub routine printEA to print out the effective address
            
            LEA         comma, A1        	; we know that the opcode will be MOVEM, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            
            
            
            CLR         D3                  ; Clears D3 to move effective address into it
            MOVE.B      D4,D3               ; Moves data with EA register
            MOVE.B      #one,D2             ; Puts 1 into D2 to print an An within printEA
            
            JSR         printEA             ; Prints out source address
            
            LEA         newline, A1         ; Prints new line
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

            BRA         LOOP                ; Branch back to outer most loop that finds the first four bits                 

***********************************************************************************************************
*
*               	OR OPCODE
*
*		This section is dedicated to the OR opcode. This is determined that the first nibble is 8, and the
*		second nibble is not 7 (or we would have DIVS), we must have OR.
*		OR is varied by the operand direction. We have and EA to Dn, and DN to EA operation.
*		These operand directions determine our opmode, which we use to disassemble.
*
***********************************************************************************************************
			
opOR       									; Assumed we found OR, begin disassemble
			LEA         ORmatch,A1			; Output OR to the IO console
            MOVE.B      #14,D0				; Use trap 14
            TRAP        #15					; Halt for IO
			
			ASL			#eight,D1			; Shift D1 by eight to find opmode
			MOVE.B		D1,D2				; Load D2 with the resulting byte
            
            ; These are for EA to Dn direction
            CMP.B       #zero,D2			; Check for a byte
            BEQ         opORB               ; Byte in opmode
            CMP.B       #one,D2				; Check for a word
            BEQ         opORW               ; Word in opmode
            CMP.B       #two,D2				; Check for a long
            BEQ         opORL               ; Long in opmode
            
            ; These are for Dn to EA direction
            CMP.B       #four,D2			; Check for a byte
            BEQ         opORB               ; Byte in opmode
            CMP.B       #five,D2			; Check for a word
            BEQ         opORW               ; Word in opmode
            CMP.B       #six,D2				; Check for a long
            BEQ         opORL               ; Long in opmode
            
opORB       								; Byte determined, find operands from here
			LEA         dispByte,A1			; Display our byte info
            MOVE.B      #14,D0				; Trap #14 for our IO
            TRAP        #15					; Halt for IO
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            

            MOVE.B      D1,D2				; Load D2 again with the byte in D1
            ASR         #3,D2				; Shift by 3 for finding 1 operand
            AND         #$07,D2				; AND by 7 to remove extras
            MOVE.B      D1,D3				; Load D3 with more necessary EA info
            AND         #$07,D3				; AND by 7 to remove extra bits
            JSR         printEA         	; Determines the "left" operand register
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; Clear D2 for use
			MOVE.W      D1,D3				; Move our word into D3 for EA use
            ASR         #eight,D3			; Shift by 8 to isolate EA info
            ASR         #one,D3				; We need additional shift, so total shifts is by 9
            AND         #$07,D3				; AND to remove extra data
            JSR         printEA				; Redirect to EA subroutine to find EA operand info
            
            LEA         newLine,A1			; Prime a new line for the next instruction
            MOVE.B      #14,D0				; Send it to the console
            TRAP        #15					; IO halt here
            
            BRA         LOOP				; Return to control loop to find additional instructions
            
            
opORW       								; Word opmode has been found
			LEA         dispWord,A1			; Display our word info
            MOVE.B      #14,D0				; Trap #14 for our IO
            TRAP        #15					; Halt for IO
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            

            MOVE.B      D1,D2				; Load D2 again with the byte in D1
            ASR         #3,D2				; Shift by 3 for finding 1 operand
            AND         #$07,D2				; AND by 7 to remove extras
            MOVE.B      D1,D3				; Load D3 with more necessary EA info
            AND         #$07,D3				; AND by 7 to remove extra bits
            JSR         printEA         	; Determines the "left" operand register
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; Clear D2 for use
			MOVE.W      D1,D3				; Move our word into D3 for EA use
            ASR         #eight,D3			; Shift by 8 to isolate EA info
            ASR         #one,D3				; We need additional shift, so total shifts is by 9
            AND         #$07,D3				; AND to remove extra data
            JSR         printEA				; Redirect to EA subroutine to find EA operand info
            
            LEA         newLine,A1			; Prime a new line for the next instruction
            MOVE.B      #14,D0				; Send it to the console
            TRAP        #15					; IO halt here
            
            BRA         LOOP				; Return to control loop to find additional instructions
            
opORL       								; Long value has been found for OR
			LEA         dispLong,A1			; Display our long info
            MOVE.B      #14,D0				; Trap #14 for our IO
            TRAP        #15					; Halt for IO
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            

            MOVE.B      D1,D2				; Load D2 again with the byte in D1
            ASR         #3,D2				; Shift by 3 for finding 1 operand
            AND         #$07,D2				; AND by 7 to remove extras
            MOVE.B      D1,D3				; Load D3 with more necessary EA info
            AND         #$07,D3				; AND by 7 to remove extra bits
            JSR         printEA         	; Determines the "left" operand register
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; Clear D2 for use
			MOVE.W      D1,D3				; Move our word into D3 for EA use
            ASR         #eight,D3			; Shift by 8 to isolate EA info
            ASR         #one,D3				; We need additional shift, so total shifts is by 9
            AND         #$07,D3				; AND to remove extra data
            JSR         printEA				; Redirect to EA subroutine to find EA operand info
            
            LEA         newLine,A1			; Prime a new line for the next instruction
            MOVE.B      #14,D0				; Send it to the console
            TRAP        #15					; IO halt here
            
            BRA         LOOP				; Return to control loop to find additional instructions
			
***********************************************************************************************************
*
*               	DIVS OPCODE
*
*		This section is dedicate to the DIVS instruction, which is determined by a 8 in the first nibble
*		and a 7 in the second nibble of the instruction.
*		DIVSL is not supported, so the following code only accounts for the case of DIVS, which is short
*		instead of a long
*
***********************************************************************************************************

opDIVS      								; Second nibble determined that the instruction was DIVS
			LEA     	DIVSmatch,A1		; Load DIVS into A1 for output console
            MOVE.B  	#14,D0				; Get trap task #14 for IO
            TRAP    	#15					; Trap call to halt
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap to halt
            
            MOVE.B      D1,D2				; Move our byte from D1 to D2 to manipulate
            ASR         #3,D2				; Shift by 3 to find register
            AND         #$07,D2				; AND by 7 to clear unnecessary bits
            MOVE.B      D1,D3				; Load the byte into D3 for EA comparison
            AND         #$07,D3				; AND by 7 to clear unnecessary bits
            JSR         printEA				; Call our EA subroutine to obtain EA bits from instruction
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap to halt call
            
            CLR         D2					; Clear old data from D2 to avoid errors
            MOVE.W      D1,D3				; Move word into D3 for EA subroutine
            ASR         #eight,D3			; Shift by 8 to find to find the remaining EA components
            ASR         #one,D3				; Additional shift by 1 to get proper bits
            AND         #$07,D3				; AND to clear unwanted bits
            JSR         printEA				; Obtain other operand info
            
            LEA         newLine,A1			; Prepare new line for next instruction
            MOVE.B      #14,D0				; Utilize trap task 14
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to control loop
            
**********************************************************************************************************
*
*               	EOR OPCODE
*
*		This sectioon is dedicated to the EOR opcode. We determine this with an 11 in the first nibble, and
*		a value higher than 3 in the second nibble.
*		The opmode fields is used to differ this instruction from CMP.
*		Dissassembly acquires opmode field info, which is similar to size, and to different EA related
*		operands.
*
***********************************************************************************************************

opEOR       								; We found EOR, begin disassembly
			LEA         EORmatch,A1			; Load A1 with our EOR output
            MOVE.B      #14,D0				; Prime trap task #14
            TRAP        #15					; Halt for IO
            
            CLR         D2					; Clear D2 for use again
            
            MOVE.B      D1,D2				; Move byte used in D1 to D2 for opmode check
            ASR         #seven,D2           ; Move bits 7 places over to find opmode
            AND         #$07,D2				; AND by 7 to clear extra bits
            CMP.B       #five,D2			; Check for a byte in opmode
            BLT         opEORB              ; Byte in opmode
            CMP.B       #five,D2			; Check for a word in opmode
            BEQ         opEORW              ; Word in opmode
            CMP.B       #five,D2			; Check for a long in opmode
            BGT         opEORL              ; Long in opmode
            
opEORB      								; Determine instruction is a byte operation
			LEA         dispByte,A1			; Send out the byte info for the instruction
            MOVE.B      #14,D0				; Utilize trap task 14
            TRAP        #15					; Halt for IO
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call to halt
            
            CLR         D2					; Clear D2 again for use
            CLR         D3					; Remove anything from D3
            MOVE.W      D1,D3				; Move word to D3 to find an operand
            ASR         #eight,D3			; Shift by eight to ensure correct portion of instruction
            ASR         #one,D3				; Needs to be shifted by an additional 1
            AND         #$07,D3				; Clear extra bits 
            JSR         printEA				; Use EA subroutine to print operand
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; Clear D2 again
            CLR         D3					; Clear D3 again
            MOVE.B      D1,D2				; Move the byte value in D1 to D2 for EA use
            ASR         #three,D2			; Shift by 3 to find EA info
			AND         #seven,D2			; AND by 7 to remove extra bits
            MOVE.B      D1,D3				; Move byte value from D1 into D3
            AND         #$07,D3				; AND by 7 for EA subroutine
            JSR         printEA         	; Determines remained operand EA info to print
            
            LEA         newLine,A1			; Print new line for next instruction
            MOVE.B      #14,D0				; Use trap 14 to output to console
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to control loop
             
opEORW      								; Word opmode has been determined
			LEA         dispWord,A1			; Send out the word info for the instruction
            MOVE.B      #14,D0				; Utilize trap task 14
            TRAP        #15					; Halt for IO
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call to halt
            
            CLR         D2					; Clear D2 again for use
            CLR         D3					; Remove anything from D3
            MOVE.W      D1,D3				; Move word to D3 to find an operand
            ASR         #eight,D3			; Shift by eight to ensure correct portion of instruction
            ASR         #one,D3				; Needs to be shifted by an additional 1
            AND         #$07,D3				; Clear extra bits 
            JSR         printEA				; Use EA subroutine to print operand
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; Clear D2 again
            CLR         D3					; Clear D3 again
            MOVE.B      D1,D2				; Move the byte value in D1 to D2 for EA use
            ASR         #three,D2			; Shift by 3 to find EA info
			AND         #seven,D2			; AND by 7 to remove extra bits
            MOVE.B      D1,D3				; Move byte value from D1 into D3
            AND         #$07,D3				; AND by 7 for EA subroutine
            JSR         printEA         	; Determines remained operand EA info to print
            
            LEA         newLine,A1			; Print new line for next instruction
            MOVE.B      #14,D0				; Use trap 14 to output to console
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to control loop
            
opEORL     									; Long has been determined
			LEA         dispLong,A1			; Send out the long word info for the instruction
            MOVE.B      #14,D0				; Utilize trap task 14
            TRAP        #15					; Halt for IO
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call to halt
            
            CLR         D2					; Clear D2 again for use
            CLR         D3					; Remove anything from D3
            MOVE.W      D1,D3				; Move word to D3 to find an operand
            ASR         #eight,D3			; Shift by eight to ensure correct portion of instruction
            ASR         #one,D3				; Needs to be shifted by an additional 1
            AND         #$07,D3				; Clear extra bits 
            JSR         printEA				; Use EA subroutine to print operand
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; Clear D2 again
            CLR         D3					; Clear D3 again
            MOVE.B      D1,D2				; Move the byte value in D1 to D2 for EA use
            ASR         #three,D2			; Shift by 3 to find EA info
			AND         #seven,D2			; AND by 7 to remove extra bits
            MOVE.B      D1,D3				; Move byte value from D1 into D3
            AND         #$07,D3				; AND by 7 for EA subroutine
            JSR         printEA         	; Determines remained operand EA info to print
            
            LEA         newLine,A1			; Print new line for next instruction
            MOVE.B      #14,D0				; Use trap 14 to output to console
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to the control loop

***********************************************************************************************************
*
*               	CMP OPCODE
*
*		This section is dedicated to the compare (CMP) instruction. Its determined in the control loop
*		that the first nibble is 11 for CMP, and the second nibble is 3.
*		The type of CMP, or the opmode, is used to determined what we output to our console next.
*		From that point, we load the correct size/opmode, and then route to the EA subroutine to output
*		EA related register information.
*		The process for finding the operand register info (EA info) is similar for all opmodes.
*
***********************************************************************************************************

opCMP       
			LEA         CMPmatch,A1			; We determined that the opcode is CMP, output to console
            MOVE.B      #14,D0				; Getting trap task #14 ready
            TRAP        #15					; Trap 15 call for IO
            
            CLR         D2					; D2 should be cleared for use later
            
            MOVE.B      D1,D2				; Get the next byte to manipulate
            ASR         #six,D2         	; Move bits 7 places over to find opmode
            AND         #$07,D2				; AND by 7 allows us to compare properly on which opmode we need
            CMP.B       #zero,D2			; Compare to zero to see if we have a byte
            BEQ         opCMPB              ; Byte in opmode
            CMP.B       #one,D2				; Compare to one to see if we have a word
            BEQ         opCMPW              ; Word in opmode
            CMP.B       #two,D2				; Compare to two to see if we have a long
            BEQ         opCMPL              ; Long in opmode
            
            BRA         printInvalid        ; Incorrect input

opCMPB      								; Known we have CMP.B, find and output operands
			LEA         dispByte,A1			; Output the byte component of the instruction
            MOVE.B      #14,D0				; Trap task #14 for console out
            TRAP        #15					; Halt for console out
            
            LEA         space, A1           ; Display space for operands
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; Console out/halt
            
            MOVE.B      D1,D2				; Move the byte for manipulation to D2
            ASR         #3,D2				; Shift right by 3 to find left operand register
            AND         #$07,D2				; AND for comparison later
            MOVE.B      D1,D3				; Move the byte to D3 for use in our EA subroutine
            AND         #$07,D3				; AND for comparison in subroutine
            JSR         printEA         	; Use our EA subroutine to determine the left operand register
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; D2 needs to be cleared for use later
            MOVE.W      D1,D3				; Move the entire word in D3 for shifting
            ASR         #eight,D3			; Shift right by 8 to get EA bits from instruction
            ASR         #one,D3				; Shift right once more to move the bits all the way
            AND         #$07,D3				; AND by 7 to clear unnecessary bits
            JSR         printEA				; EA subroutine call to get remaining operand sent to the console
            
            LEA         newLine,A1			; Prime A1 with our new line to output
            MOVE.B      #14,D0				; Prime new line for next instruction
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to control loop for next disassembly
            
opCMPW      								; Known we have CMP.W, find and output operands
			LEA         dispWord,A1			; Output the byte component of the instruction
            MOVE.B      #14,D0				; Trap task #14 for console out
            TRAP        #15					; Halt for console out
            
            LEA         space, A1           ; Display space for operands
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; Console out/halt
            
            MOVE.B      D1,D2				; Move the byte for manipulation to D2
            ASR         #3,D2				; Shift right by 3 to find left operand register
            AND         #$07,D2				; AND for comparison later
            MOVE.B      D1,D3				; Move the byte to D3 for use in our EA subroutine
            AND         #$07,D3				; AND for comparison in subroutine
            JSR         printEA         	; Use our EA subroutine to determine the left operand register
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; D2 needs to be cleared for use later
            MOVE.W      D1,D3				; Move the entire word in D3 for shifting
            ASR         #eight,D3			; Shift right by 8 to get EA bits from instruction
            ASR         #one,D3				; Shift right once more to move the bits all the way
            AND         #$07,D3				; AND by 7 to clear unnecessary bits
            JSR         printEA				; EA subroutine call to get remaining operand sent to the console
            
            LEA         newLine,A1			; Prime A1 with our new line to output
            MOVE.B      #14,D0				; Prime new line for next instruction
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to control loop for next disassembly

opCMPL      								; Known we have CMP.L, find and output operands
			LEA         dispLong,A1			; Output the byte component of the instruction
            MOVE.B      #14,D0				; Trap task #14 for console out
            TRAP        #15					; Halt for console out
            
            LEA         space, A1           ; Display space for operands
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; Console out/halt
            
            MOVE.B      D1,D2				; Move the byte for manipulation to D2
            ASR         #3,D2				; Shift right by 3 to find left operand register
            AND         #$07,D2				; AND for comparison later
            MOVE.B      D1,D3				; Move the byte to D3 for use in our EA subroutine
            AND         #$07,D3				; AND for comparison in subroutine
            JSR         printEA         	; Use our EA subroutine to determine the left operand register
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; D2 needs to be cleared for use later
            MOVE.W      D1,D3				; Move the entire word in D3 for shifting
            ASR         #eight,D3			; Shift right by 8 to get EA bits from instruction
            ASR         #one,D3				; Shift right once more to move the bits all the way
            AND         #$07,D3				; AND by 7 to clear unnecessary bits
            JSR         printEA				; EA subroutine call to get remaining operand sent to the console
            
            LEA         newLine,A1			; Prime A1 with our new line to output
            MOVE.B      #14,D0				; Prime new line for next instruction
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to control loop for next disassembly

***********************************************************************************************************
*
*               	SUB OPCODE
*
*		This section is dedicated to disassembling the SUB opcode. We assume that the first nibble being 9
*		leads us to the SUB opcode.
*		SUB is differed by a operand direction, that being Dn - EA or EA - Dn.
*		These directions are deteremined as an opmode, and doubles up for each byte, long, and word mode.
*
***********************************************************************************************************

opSUB       								; We assume we found SUB, begin SUB disassemble
			LEA         SUBmatch, A1        ; Load A1 to print SUB found message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call to halt
        
        
            ASL         #eight,D1			; Shift D1 to by 8 to find opmode
            MOVE.B      (A0)+,D1			; Reload instruction
            CLR         D2					; Ensure D2 is clear
            
            MOVE.W      D1,D2				; Load our word into D2 to manipulate
            ASR         #six,D2         	; Move bits 7 places over to find opmode
            AND         #seven,D2			; AND by 7 to remove extra bits
            
            ; These are for Dn - EA
            CMP.B       #zero,D2			; Check for byte
            BEQ         opSUBB              ; Byte in opmode
            CMP.B       #one,D2				; Check for word
            BEQ         opSUBW              ; Word in opmode
            CMP.B       #two,D2				; Check for long
            BEQ         opSUBL              ; Long in opmode
            
            ; These are for EA - Dn
            CMP.B       #four,D2			; Check for byte
            BEQ         opSUBB              ; Byte in opmode
            CMP.B       #five,D2			; Check for word
            BEQ         opSUBW              ; Word in opmode
            CMP.B       #six,D2				; Check for long
            BEQ         opSUBL              ; Long in opmode
            
opSUBB      								; Byte has been found, find operands
			LEA         dispByte,A1			; Output the byte info to the console
            MOVE.B      #14,D0				; Use trap task 14 for IO
            TRAP        #15					; Halt for IO
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call         
            
            MOVE.B      D1,D2				; Load D2 with our D1 byte
            ASR         #3,D2				; Shift by 3 to find an operand
            AND         #$07,D2				; AND by 7 to remove extra bits
            MOVE.W      D1,D3				; Load D3 with our word in D1
            AND         #$07,D3				; AND by 7 to remove extra bits
            JSR         printEA         	; Use EA subroutine to find an operand
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; Empty D2 for use again
            MOVE.W      D1,D3				; Load the word again into D3
            ASR         #eight,D3			; Shift by 8 to find other operand
            ASR         #one,D3				; Requires an additional shift
            AND         #$07,D3				; AND by 7 to remove extra bits
            JSR         printEA				; EA subroutine finds our remaining operand
            
            LEA         newLine,A1			; Ready console with newline
            MOVE.B      #14,D0				; Trap 14 for output
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to control loop
            
opSUBW      								; Word has been found, find operands
			LEA         dispWord,A1			; Output the word info to the console
            MOVE.B      #14,D0				; Use trap task 14 for IO
            TRAP        #15					; Halt for IO
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call         
            
            MOVE.B      D1,D2				; Load D2 with our D1 byte
            ASR         #3,D2				; Shift by 3 to find an operand
            AND         #$07,D2				; AND by 7 to remove extra bits
            MOVE.W      D1,D3				; Load D3 with our word in D1
            AND         #$07,D3				; AND by 7 to remove extra bits
            JSR         printEA         	; Use EA subroutine to find an operand
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; Empty D2 for use again
            MOVE.W      D1,D3				; Load the word again into D3
            ASR         #eight,D3			; Shift by 8 to find other operand
            ASR         #one,D3				; Requires an additional shift
            AND         #$07,D3				; AND by 7 to remove extra bits
            JSR         printEA				; EA subroutine finds our remaining operand
            
            LEA         newLine,A1			; Ready console with newline
            MOVE.B      #14,D0				; Trap 14 for output
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to control loop
            
opSUBL      								; Long has been found, find operands
			LEA         dispLong,A1			; Output the long info to the console
            MOVE.B      #14,D0				; Use trap task 14 for IO
            TRAP        #15					; Halt for IO
            
            LEA         space, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call         
            
            MOVE.B      D1,D2				; Load D2 with our D1 byte
            ASR         #3,D2				; Shift by 3 to find an operand
            AND         #$07,D2				; AND by 7 to remove extra bits
            MOVE.W      D1,D3				; Load D3 with our word in D1
            AND         #$07,D3				; AND by 7 to remove extra bits
            JSR         printEA         	; Use EA subroutine to find an operand
            
            LEA         comma, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2					; Empty D2 for use again
            MOVE.W      D1,D3				; Load the word again into D3
            ASR         #eight,D3			; Shift by 8 to find other operand
            ASR         #one,D3				; Requires an additional shift
            AND         #$07,D3				; AND by 7 to remove extra bits
            JSR         printEA				; EA subroutine finds our remaining operand
            
            LEA         newLine,A1			; Ready console with newline
            MOVE.B      #14,D0				; Trap 14 for output
            TRAP        #15					; Halt for IO
            
            BRA         LOOP				; Return to control loop
            
***********************************************************************************************************
*
*               	BRA OPCODE
*		
*		This section is dedicated to the BRA opcode, which is determined by having six in the first
*		nibble of the instruction, and zero in the second nibble.
*
***********************************************************************************************************
            
opBRA   	
			LEA         BRAmatch, A1		; we know that the opcode will be BRA, so load A1 to print message
			MOVE.B      #14, D0             ; Prime trap task #14 for output
			TRAP        #15                 ; trap call to output BRA
        
			CLR         D2					; Data register to needs to be cleared for use again
			CLR         D3					; Data register to needs to be cleared for use again

			LEA         space,A1			; output a space for the IO console
			MOVE.B      #14,D0				; Prime trap task #14 for the output
			TRAP        #15					; Call trap #15 with number 14 for our IO
        
			MOVE.B      #seven,D2			; We know we need to move seven due to the nature of BRA in 68k
			MOVE.B      (A0)+,D1			; Move the byte we stored for use from our addr register to D1
			JSR         printEA				; this method handles the displacement hex values
        
			LEA         newLine, A1         ; create new line for the IO console
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call ready console for next instruction

			BRA         LOOP				; return back to our control loop to find next instruction
        
***********************************************************************************************************
*
*					Bcc OPCODES
*
*		This section is dedicated to the conditional branching opcode. There are varying second nibble
*		values, documented below, with the correspond cc code.
*		BCC is similar to BRA, so we handle it in the same manner.
*
*		Supported cc condition codes:
*			>Carry Clear 		= CS		second nibble == 5
*			>Overflow Set 		= VC		second nibble == 8
*			>Greater or EqualGE	= GE		second nibble == 12
*			>Less Than 			= LT		second nibble == 13
*
***********************************************************************************************************
* CS Conition Code

opBCS   	
			LEA         BCSmatch, A1        ; we know that the opcode will be BCS, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; Data register to needs to be cleared for use again
			CLR         D3					; Data register to needs to be cleared for use again

			LEA         space,A1			; output a space for the IO console
			MOVE.B      #14,D0				; Prime trap task #14 for the output
			TRAP        #15					; Call trap #15 with number 14 for our IO
        
			MOVE.B      #seven,D2			; We know we need to move seven due to the nature of BRA in 68k
			MOVE.B      (A0)+,D1			; Move the byte we stored for use from our addr register to D1
			JSR         printEA				; this method handles the displacement hex values
        
			LEA         newLine, A1         ; create new line for the IO console
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call ready console for next instruction
			
			BRA			LOOP				; return to the control loop for next instruction

***********************************************************************************************************
* VC Condition Code

opBVC   	
			LEA         BVCmatch, A1        ; we know that the opcode will be BVC, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; Data register to needs to be cleared for use again
			CLR         D3					; Data register to needs to be cleared for use again

			LEA         space,A1			; output a space for the IO console
			MOVE.B      #14,D0				; Prime trap task #14 for the output
			TRAP        #15					; Call trap #15 with number 14 for our IO
        
			MOVE.B      #seven,D2			; We know we need to move seven due to the nature of BRA in 68k
			MOVE.B      (A0)+,D1			; Move the byte we stored for use from our addr register to D1
			JSR         printEA				; this method handles the displacement hex values
        
			LEA         newLine, A1         ; create new line for the IO console
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call ready console for next instruction
			
			BRA			LOOP				; return to the control loop for next instruction

***********************************************************************************************************
* GE Conidtion Code		
		
opBGE   	
			LEA         BGEmatch, A1        ; we know that the opcode will be BGE, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; Data register to needs to be cleared for use again
			CLR         D3					; Data register to needs to be cleared for use again

			LEA         space,A1			; output a space for the IO console
			MOVE.B      #14,D0				; Prime trap task #14 for the output
			TRAP        #15					; Call trap #15 with number 14 for our IO
        
			MOVE.B      #seven,D2			; We know we need to move seven due to the nature of BRA in 68k
			MOVE.B      (A0)+,D1			; Move the byte we stored for use from our addr register to D1
			JSR         printEA				; this method handles the displacement hex values
        
			LEA         newLine, A1         ; create new line for the IO console
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call ready console for next instruction
			
			BRA			LOOP				; return to the control loop for next instruction

***********************************************************************************************************
* LT Conditions Code		
		
opBLT   
			LEA         BLTmatch, A1        ; we know that the opcode will be BLT, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; Data register to needs to be cleared for use again
			CLR         D3					; Data register to needs to be cleared for use again

			LEA         space,A1			; output a space for the IO console
			MOVE.B      #14,D0				; Prime trap task #14 for the output
			TRAP        #15					; Call trap #15 with number 14 for our IO
        
			MOVE.B      #seven,D2			; We know we need to move seven due to the nature of BRA in 68k
			MOVE.B      (A0)+,D1			; Move the byte we stored for use from our addr register to D1
			JSR         printEA				; this method handles the displacement hex values
        
			LEA         newLine, A1         ; create new line for the IO console
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call ready console for next instruction
			
			BRA			LOOP				; return to the control loop for next instruction
        
***********************************************************************************************************
*
*               SUBQ OPCODE
*
*		This section is for disassembling the SUBQ instruction, which is determined by a 5 in the first
*		nibble.
*		We assume there is only 1 opcode with 5 in the first nibble.
*		SUBQ utilizes immediate data, so we use an alternate subroutine for operand output.
*		The size field is used to branch to the subvariants of SUBQ, which we determine before hitting the
*		final subroutines.
*
***********************************************************************************************************

opSUBQ      								; Assumed that we found SUBQ, begin disassemble
            LEA         SUBQmatch, A1       ; Send out SUBQ message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call to halt
            
			ASL			#eight,D1			; Shift by 8 to find size bits
			MOVE.B		(A0)+,D1			; Reload D1
            MOVE.B      D1,D2				; Move data in D2 to alter later
            ASR         #seven,D2           ; Move bits 7 places over to find size
            AND         #$07,D2				; AND by 7 to remove uneeded bits
            
            ; Find size bits
            CMP.B       #zero,D2			; Check for a byte
            BEQ         opSUBQB             ; Byte in size
            CMP.B       #one,D2				; Check for a word
            BEQ         opSUBQW             ; Word in size
            CMP.B       #two,D2				; Check for a long
            BEQ         opSUBQL             ; Long in size
            
opSUBQB     								; Found a byte in size, prepare for JSR
			LEA         dispByte,A1			; Display the byte in the console
            MOVE.B      #14,D0				; Trap task 14 for IO
            TRAP        #15 				; Halt for IO
          
            JSR         PrntImm				; Call immediate data subroutine to handle SUBQ operands
            
            BRA         LOOP				; Return to control loop
            
opSUBQW     								; Found a word in size, prepare for JSR
			LEA         dispWord,A1			; Display the word in the console
            MOVE.B      #14,D0				; Trap task 14 for IO
            TRAP        #15 				; Halt for IO
          
            JSR         PrntImm				; Call immediate data subroutine to handle SUBQ operands
            
            BRA         LOOP				; Return to control loop
            
opSUBQL     								; Found a long in size, prepare for JSR
			LEA         dispLong,A1			; Display the long in the console
            MOVE.B      #14,D0				; Trap task 14 for IO
            TRAP        #15 				; Halt for IO
          
			CLR         D6					; In the long size case, we need to ensure D6 is clear for the JSR call
            MOVE.B      #1,D6				; Needed to ensure proper immediate data is output to the console
		  
            JSR         PrntImm				; Call immediate data subroutine to handle SUBQ operands
            
            BRA         LOOP				; Return to control loop
     	
***********************************************************************************************************
*
*					MULS OPCODE
*
***********************************************************************************************************

opMULS  
			LEA         MULSmatch, A1       ; we know that the opcode will be MULS, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			LEA         space, A1           ; create spaces
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			ASL         #eight, D1 			; move D1 over by a byte
			MOVE.B      (A0)+, D1 			; copy the next byte into D1
        
			CLR         D2 					; clear D2
			CLR         D3 					; clear D3
			MOVE.B      D1, D2 				; copy the byte from D1 to D2
			ASR         #three, D2 			; shift D2 by 3 bits to get source mode
			AND         #seven, D2 			; and D2 to get only first 3 bits
			MOVE.B      D1, D3 				; copy D1 byte to D3
			AND         #seven, D3 			; and D3 to get first 3 bits also known as register
        
			JSR         printEA 			; jump to printEA
        
			LEA         comma, A1           ; create comma
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			CLR         D2 					; clear D2 since we know mode should be data register
			CLR         D3 					; clear D3
			MOVE.W      D1, D3 				; Move D1 word to D3
			ASR         #eight, D3 			; shift D3 by 8 bits
			ASR         #one, D3 			; shift D3 by 1 bit
			AND         #seven, D3 			; and D3 to get first 3 bits which are the register

			JSR         printEA 			; jump to printEA
        
			LEA         newLine, A1         ; create new line
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP 				; branch back to LOOP

***********************************************************************************************************
*
*					ADD OPCODE
*
***********************************************************************************************************	  

opADDB  
			LEA         ADDmatch, A1        ; we know that the opcode will be ADD, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			LEA         space, A1           ; create spaces
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2 					; clear D2
			CLR         D3 					; clear D3
			MOVE.B      D1, D2 				; copy the byte from D1 to D2
			ASR         #three, D2 			; shift D2 by 3 bits to get source mode
			AND         #seven, D2 			; and D2 to get only first 3 bits
			MOVE.B      D1, D3 				; copy D1 byte to D3
			AND         #seven, D3 			; and D3 to get first 3 bits also known as register
        
			JSR         printEA 			; jump to printEA
        
			LEA         comma, A1           ; create comma
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			CLR         D2 					; clear D2 since we know mode should be data register
			CLR         D3 					; clear D3
			MOVE.W      D1, D3 				; Move D1 word to D3
			ASR         #eight, D3 			; shift D3 by 8 bits
			ASR         #one, D3 			; shift D3 by 1 bit
			AND         #seven, D3 			; and D3 to get first 3 bits which are the register

			JSR         printEA 			; jump to printEA
        
			LEA         newLine, A1         ; create new line
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP 				; branch back to LOOP
        
opADDW  
			LEA         ADDmatch, A1        ; we know that the opcode will be ADD, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			LEA         space, A1           ; create spaces
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2 					; clear D2
			CLR         D3 					; clear D3
			MOVE.B      D1, D2 				; copy the byte from D1 to D2
			ASR         #three, D2 			; shift D2 by 3 bits to get source mode
			AND         #seven, D2 			; and D2 to get only first 3 bits
			MOVE.B      D1, D3 				; copy D1 byte to D3
			AND         #seven, D3 			; and D3 to get first 3 bits also known as register
        
			JSR         printEA 			; jump to printEA
        
			LEA         comma, A1           ; create comma
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			CLR         D2 					; clear D2 since we know mode should be data register
			CLR         D3 					; clear D3
			MOVE.W      D1, D3 				; Move D1 word to D3
			ASR         #eight, D3 			; shift D3 by 8 bits
			ASR         #one, D3 			; shift D3 by 1 bit
			AND         #seven, D3 			; and D3 to get first 3 bits which are the register

			JSR         printEA 			; jump to printEA
        
			LEA         newLine, A1         ; create new line
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP 				; branch back to LOOP
        
opADDL  
			LEA         ADDmatch, A1        ; we know that the opcode will be ADD, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			LEA         space, A1           ; create spaces
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2 					; clear D2
			CLR         D3 					; clear D3
			MOVE.B      D1, D2 				; copy the byte from D1 to D2
			ASR         #three, D2 			; shift D2 by 3 bits to get source mode
			AND         #seven, D2 			; and D2 to get only first 3 bits
			MOVE.B      D1, D3 				; copy D1 byte to D3
			AND         #seven, D3 			; and D3 to get first 3 bits also known as register
        
			CLR         D6					; Clear D6
			MOVE.B      #1, D6				; move 1 to D6 in case source is printing immediate
        
			JSR         printEA				; jump to printEA
			CLR         D6					; clear D6
        
			LEA         comma, A1           ; create comma
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			CLR         D2 					; clear D2 since we know mode should be data register
			CLR         D3 					; clear D3
			MOVE.W      D1, D3 				; Move D1 word to D3
			ASR         #eight, D3 			; shift D3 by 8 bits
			ASR         #one, D3 			; shift D3 by 1 bit
			AND         #seven, D3 			; and D3 to get first 3 bits which are the register

			JSR         printEA 			; jump to printEA
        
			LEA         newLine, A1         ; create new line
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP 				; branch back to LOOP

***********************************************************************************************************
*
*					ADDA OPCODE
*
***********************************************************************************************************	

opADDAW 
			LEA         ADDAmatch, A1       ; we know that the opcode will be ADDA, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			LEA         space, A1           ; create spaces
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2 					; clear D2
			CLR         D3 					; clear D3
			MOVE.B      D1, D2 				; copy the byte from D1 to D2
			ASR         #three, D2 			; shift D2 by 3 bits to get source mode
			AND         #seven, D2 			; and D2 to get only first 3 bits
			MOVE.B      D1, D3 				; copy D1 byte to D3
			AND         #seven, D3 			; and D3 to get first 3 bits also known as register
        
			JSR         printEA 			; jump to printEA 
        
			LEA         comma, A1           ; create comma
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			CLR         D2 					; clear D2 since we know mode should be data register
			CLR         D3 					; clear D3
			MOVE.B      #one, D2			; move 1 to D2 since mode should be address
			MOVE.W      D1, D3 				; Move D1 word to D3
			ASR         #eight, D3 			; shift D3 by 8 bits
			ASR         #one, D3 			; shift D3 by 1 bit
			AND         #seven, D3 			; and D3 to get first 3 bits which are the register

			JSR         printEA 			; jump to printEA
        
			LEA         newLine, A1         ; create new line
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP 				; branch back to LOOP

opADDAL 
			LEA         ADDAmatch, A1       ; we know that the opcode will be ADDA, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			LEA         space, A1           ; create spaces
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2 					; clear D2
			CLR         D3 					; clear D3
			MOVE.B      D1, D2 				; copy the byte from D1 to D2
			ASR         #three, D2 			; shift D2 by 3 bits to get source mode
			AND         #seven, D2 			; and D2 to get only first 3 bits
			MOVE.B      D1, D3 				; copy D1 byte to D3
			AND         #seven, D3 			; and D3 to get first 3 bits also known as register
        
			JSR         printEA 			; jump to printEA 
        
			LEA         comma, A1           ; create comma
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			CLR         D2 					; clear D2 since we know mode should be data register
			CLR         D3 					; clear D3
			MOVE.B      #one, D2			; move 1 to D2 since mode should be address
			MOVE.W      D1, D3 				; Move D1 word to D3
			ASR         #eight, D3 			; shift D3 by 8 bits
			ASR         #one, D3 			; shift D3 by 1 bit
			AND         #seven, D3 			; and D3 to get first 3 bits which are the register

			JSR         printEA 			; jump to printEA
        
			LEA         newLine, A1         ; create new line
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP 				; branch back to LOOP
        
***********************************************************************************************************
*
*						Shifting OPCODES
*
***********************************************************************************************************

opASL   	
			LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; display space 
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; clear D2
			CLR         D3					; clear D3
			MOVE.B      D1,D2				; move byte from D1 to D2
			MOVE.B      D1,D3				; move byte from D1 to D3
        
			ASR.B       #three, D2 			; shift D2 by 3 bits to get mode
			AND         #seven, D2			; and D2 by 3 bits to get first 3 bits
			AND         #seven, D3        	; and D3 by 3 bits to get first 3 bits for register
        
			JSR         printEA				; jump to printEA
        
			LEA        	newLine, A1         ; Display newLine
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP				; branch back to LOOP

opASR   
			LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; display space 
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; clear D2
			CLR         D3					; clear D3
			MOVE.B      D1,D2				; move byte from D1 to D2
			MOVE.B      D1,D3				; move byte from D1 to D3
        
			ASR.B       #three, D2 			; shift D2 by 3 bits to get mode
			AND         #seven, D2			; and D2 by 3 bits to get first 3 bits
			AND         #seven, D3        	; and D3 by 3 bits to get first 3 bits for register
        
			JSR         printEA				; jump to printEA
        
			LEA        	newLine, A1         ; Display newLine
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP				; branch back to LOOP

opLSL   	
			LEA         LSLmatch, A1        ; we know that the opcode will be LSL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			
			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; display space 
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; clear D2
			CLR         D3					; clear D3
			MOVE.B      D1,D2				; move byte from D1 to D2
			MOVE.B      D1,D3				; move byte from D1 to D3
        
			ASR.B       #three, D2 			; shift D2 by 3 bits to get mode
			AND         #seven, D2			; and D2 by 3 bits to get first 3 bits
			AND         #seven, D3        	; and D3 by 3 bits to get first 3 bits for register
        
			JSR         printEA				; jump to printEA
        
			LEA        	newLine, A1         ; Display newLine
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP				; branch back to LOOP

opLSR   
			LEA         LSRmatch, A1        ; we know that the opcode will be LSR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; display space 
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; clear D2
			CLR         D3					; clear D3
			MOVE.B      D1,D2				; move byte from D1 to D2
			MOVE.B      D1,D3				; move byte from D1 to D3
        
			ASR.B       #three, D2 			; shift D2 by 3 bits to get mode
			AND         #seven, D2			; and D2 by 3 bits to get first 3 bits
			AND         #seven, D3        	; and D3 by 3 bits to get first 3 bits for register
        
			JSR         printEA				; jump to printEA
        
			LEA        	newLine, A1         ; Display newLine
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP				; branch back to LOOP

opROL   
			LEA         ROLmatch, A1        ; we know that the opcode will be ROL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; display space 
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; clear D2
			CLR         D3					; clear D3
			MOVE.B      D1,D2				; move byte from D1 to D2
			MOVE.B      D1,D3				; move byte from D1 to D3
        
			ASR.B       #three, D2 			; shift D2 by 3 bits to get mode
			AND         #seven, D2			; and D2 by 3 bits to get first 3 bits
			AND         #seven, D3        	; and D3 by 3 bits to get first 3 bits for register
        
			JSR         printEA				; jump to printEA
        
			LEA        	newLine, A1         ; Display newLine
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP				; branch back to LOOP

opROR   
			LEA         RORmatch, A1        ; we know that the opcode will be ROR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			LEA         space, A1           ; display space 
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; clear D2
			CLR         D3					; clear D3
			MOVE.B      D1,D2				; move byte from D1 to D2
			MOVE.B      D1,D3				; move byte from D1 to D3
        
			ASR.B       #three, D2 			; shift D2 by 3 bits to get mode
			AND         #seven, D2			; and D2 by 3 bits to get first 3 bits
			AND         #seven, D3        	; and D3 by 3 bits to get first 3 bits for register
        
			JSR         printEA				; jump to printEA
        
			LEA        	newLine, A1         ; Display newLine
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			BRA         LOOP				; branch back to LOOP
        
memSB   	
			CLR         D2					; clear D2
			MOVE.B      D1,D2				; move D1 to D2
			ASR         #three, D2			; shift D2 by 3 bits to get i/r
			
			AND         #$07, D2			; and D2 by 3 bits 
        
			CMP.B       #zero, D2			; compare 0 to D2
			BEQ         opASBI				; if true, branch to ASBI for immediate
			CMP.B       #four, D2			; compare 4 to D2 
			BEQ         opASBR				; if true, branch to ASBR for register
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opLSBI				; if true, branch to LSBI for immediate
			CMP.B       #five, D2			; compare 5 to D2
			BEQ         opLSBR				; if true, branch to LSBR for register
			CMP.B       #three, D2			; compare 3 to D2
			BEQ         opROBI				; if true, branch to ROBI for immediate
			CMP.B       #seven, D2			; compare 7 to D2
			BEQ         opROBR				; if true, branch to ROBR for register
			BRA         printInvalid		; otherwise invalid
        
opASBI  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2
			BEQ         opASRBI				; if true, branch to ASRBI for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opASLBI				; if true, branch to ASLBI for left
			BRA         printInvalid		; otherwise invalid
        
opASRBI 
			LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
		
			BRA         LOOP				; branch back to LOOP

opASLBI 
			LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
		
			BRA         LOOP				; branch back to LOOP

opASBR  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opASRBR				; if true, branch to ASRBR for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opASLBR				; if true, branch to ASLBR for left
			BRA         printInvalid 		; otherwise invalid
        
opASRBR 
			LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opASLBR 
			LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opLSBI  	
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opLSRBI				; if true, branch to LSRBI for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opLSLBI				; if true, branch to LSLBI for left
			BRA         printInvalid 		; otherwise invalid
        
opLSRBI 
			LEA         LSRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
		
			BRA         LOOP				; branch back to LOOP
			
opLSLBI 	
			LEA         LSLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
		
			BRA         LOOP				; branch back to LOOP

opLSBR  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opLSRBR				; if true, branch to LSRBR for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opLSLBR				; if true, branch to LSLBR for left
			BRA         printInvalid 		; otherwise invalid
        
opLSRBR 
			LEA         LSRmatch, A1        ; we know that the opcode will be LSR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP
        
opLSLBR 	
			LEA         LSLmatch, A1        ; we know that the opcode will be LSL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP
			
opROBI  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2
			BEQ         opRORBI				; if true, branch to RORBI for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opROLBI				; if true, branch to ROLBI for left
			BRA         printInvalid		; otherwise invalid
        
opRORBI 
			LEA         RORmatch, A1        ; we know that the opcode will be ROR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
		
			BRA         LOOP				; branch back to LOOP

opROLBI 
			LEA         ROLmatch, A1        ; we know that the opcode will be ROL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
		
			BRA         LOOP				; branch back to LOOP

opROBR  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opRORBR				; if true, branch to RORBR for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opROLBR				; if true, branch to ROLBR for left
			BRA         printInvalid 		; otherwise invalid    
        
opRORBR 
			LEA         RORmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opROLBR 
			LEA         ROLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispByte, A1        ; display byte
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP       

memSW   
			CLR         D2					; clear D2
			MOVE.B      D1,D2				; move D1 to D2
			ASR         #three, D2			; shift D2 by 3 bits to get i/r
			
			AND         #$07, D2			; and D2 by 3 bits 
        
			CMP.B       #zero, D2			; compare 0 to D2
			BEQ         opASWI				; if true, branch to ASWI for immediate
			CMP.B       #four, D2			; compare 4 to D2 
			BEQ         opASWR				; if true, branch to ASWR for register
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opLSWI				; if true, branch to LSWI for immediate
			CMP.B       #five, D2			; compare 5 to D2
			BEQ         opLSWR				; if true, branch to LSWR for register
			CMP.B       #three, D2			; compare 3 to D2
			BEQ         opROWI				; if true, branch to ROWI for immediate
			CMP.B       #seven, D2			; compare 7 to D2
			BEQ         opROWR				; if true, branch to ROWR for register
			BRA         printInvalid		; otherwise invalid
        
opASWI  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2
			BEQ         opASRWI				; if true, branch to ASRWI for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opASLWI				; if true, branch to ASLWI for left
			BRA         printInvalid		; otherwise invalid
        
opASRWI 
			LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP

opASLWI 
			LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP

opASWR  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opASRWR				; if true, branch to ASRWR for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opASLWR				; if true, branch to ASLWR for left
			BRA         printInvalid 		; otherwise invalid
        
opASRWR 	
			LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opASLWR 	
			LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opLSWI  	
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opLSRWI				; if true, branch to LSRWI for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opLSLWI				; if true, branch to LSLWI for left
			BRA         printInvalid 		; otherwise invalid 
        
opLSRWI 
			LEA         LSRmatch, A1        ; we know that the opcode will be LSR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
	
			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP
			
opLSLWI 
			LEA         LSLmatch, A1        ; we know that the opcode will be LSL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP
			
opLSWR  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opLSRWR				; if true, branch to LSRWR for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opLSLWR				; if true, branch to LSLWR for left
			BRA         printInvalid 		; otherwise invalid
        
opLSRWR 
			LEA         LSRmatch, A1        ; we know that the opcode will be LSR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP
        
opLSLWR 
			LEA         LSLmatch, A1        ; we know that the opcode will be LSL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opROWI  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2
			BEQ         opRORWI				; if true, branch to RORWI for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opROLWI				; if true, branch to ROLWI for left
			BRA         printInvalid		; otherwise invalid
        
opRORWI 
			LEA         RORmatch, A1        ; we know that the opcode will be ROR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP

opROLWI 	
			LEA         ROLmatch, A1        ; we know that the opcode will be ROL, so load A1 to print message
        
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP

opROWR  	
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opRORWR				; if true, branch to RORWR for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opROLWR				; if true, branch to ROLWR for left
			BRA         printInvalid 		; otherwise invalid     
        
opRORWR 
			LEA         RORmatch, A1        ; we know that the opcode will be ROR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
	
			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opROLWR 
			LEA         ROLmatch, A1        ; we know that the opcode will be ROL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispWord, A1        ; display word
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

memSL   
			CLR         D2					; clear D2
			MOVE.B      D1,D2				; move D1 to D2
			ASR         #three, D2			; shift D2 by 3 bits to get i/r
			
			AND         #$07, D2			; and D2 by 3 bits 
        
			CMP.B       #zero, D2			; compare 0 to D2
			BEQ         opASLI				; if true, branch to ASLI for immediate
			CMP.B       #four, D2			; compare 4 to D2 
			BEQ         opASLR				; if true, branch to ASLR for register
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opLSLI				; if true, branch to LSLI for immediate
			CMP.B       #five, D2			; compare 5 to D2
			BEQ         opLSLR				; if true, branch to LSLR for register
			CMP.B       #three, D2			; compare 3 to D2
			BEQ         opROLI				; if true, branch to ROLI for immediate
			CMP.B       #seven, D2			; compare 7 to D2
			BEQ         opROLR				; if true, branch to ROLR for register
			BRA         printInvalid		; otherwise invalid
        
opASLI  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2
			BEQ         opASRLI				; if true, branch to ASRLI for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opASLLI				; if true, branch to ASLLI for left
			BRA         printInvalid		; otherwise invalid
        
opASRLI 
			LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP

opASLLI 
			LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP

opASLR  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opASRLR				; if true, branch to ASRLR for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opASLLR				; if true, branch to ASLLR for left
			BRA         printInvalid 		; otherwise invalid 
        
opASRLR 
			LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opASLLR 
			LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opLSLI  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opLSRLI				; if true, branch to LSRLI for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opLSLLI				; if true, branch to LSLLI for left
			BRA         printInvalid 		; otherwise invalid  
        
opLSRLI 
			LEA         LSRmatch, A1        ; we know that the opcode will be LSR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP


opLSLLI 
			LEA         LSLmatch, A1        ; we know that the opcode will be LSL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP

opLSLR  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opLSRLR				; if true, branch to LSRLR for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opLSLLR				; if true, branch to LSLLR for left
			BRA         printInvalid 		; otherwise invalid
        
opLSRLR 
			LEA         LSRmatch, A1        ; we know that the opcode will be LSR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP
        
opLSLLR 
			LEA         LSLmatch, A1        ; we know that the opcode will be LSL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP
			
opROLI  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2
			BEQ         opRORLI				; if true, branch to RORLI for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opROLLI				; if true, branch to ROLLI for left
			BRA         printInvalid		; otherwise invalid
        
opRORLI 
			LEA         RORmatch, A1        ; we know that the opcode will be ROR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP

opROLLI 
			LEA         ROLmatch, A1        ; we know that the opcode will be ROL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntImm				; jump to PrntImm
        
			BRA         LOOP				; branch back to LOOP

opROLR  
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 over by 8 bits 
			AND         #$01, D2			; and D2 by 1 bit to get direction
    
			CMP.B       #zero, D2			; compare 0 to D2 
			BEQ         opRORLR				; if true, branch to RORLR for right
			CMP.B       #one, D2			; compare 1 to D2
			BEQ         opROLLR				; if true, branch to ROLLR for left
			BRA         printInvalid 		; otherwise invalid     
        
opRORLR 
			LEA         RORmatch, A1        ; we know that the opcode will be ROR, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call

			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP

opROLLR 	
			LEA         ROLmatch, A1        ; we know that the opcode will be ROL, so load A1 to print message
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
	
			LEA         dispLong, A1        ; display long
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			JSR         PrntReg				; jump to PrntReg
        
			BRA         LOOP				; branch back to LOOP
		
***********************************************************************************************************
*						Immediate Data Subroutine Part 1
*
* The following subroutine displays the immediate number to shift and the data register that is being shifted. 
* This subroutine calls two printing immediate subroutine first, the the ea print subroutine.        
*
***********************************************************************************************************

PrntImm 
			MOVEM.L 	D0-D7/A1-A6, -(SP)	; callee saved registers
			
			LEA         space, A1        	; display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			
			LEA         hashTag, A1        	; display #
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
			
			CLR         D2					; clear D2
			MOVE.W      D1, D2				; move word from D1 to D2
			ASR         #eight, D2			; shift D2 by 8 bits
			ASR         #one, D2			; shift D2 by one bit
			AND         #$07, D2			; and D2 to get just first 3 bits
        
			JSR         MemShiftImm			; jump to MemShiftImm
        
			LEA         comma, A1        	; display comma
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; clear D2 since destination mode must be data register
			CLR         D3					; clear D3 to get register
			MOVE.B      D1,D3				; move byte from D1 to D3
			AND         #$07, D3			; and D3 to get first 3 bits only
        
			JSR         printEA				; jump to printEA
        
			LEA         newLine, A1        	; create new line
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			MOVEM.L  	(SP)+, D0-D7/A1-A6	; pop saved registers from stack
			RTS								; return
			
***********************************************************************************************************
*
*						Shifting Helping Function
*
* The following subroutine determines the correct data register to display, and sets the values of D2 and 
*		D3 accordingly to display the data register.
* after setting the values, it calls another subroutine to actually display the data register.        
*
***********************************************************************************************************

PrntReg 	
			MOVEM.L 	D0-D7/A1-A6, -(SP)	; callee saved
        
			LEA         space, A1           ; display space
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR         D2					; clear D2
			CLR         D3					; clear D3
			MOVE.W      D1, D3				; move word from D1 to D3
			ASR         #eight, D3			; shift D3 by 8 bits
			ASR         #one, D3			; shift D3 by 1 bit
			AND         #$07, D3			; and D3 to get first 3 bits only
        
			JSR         printEA
        
			LEA         comma, A1           ; display comma
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			CLR        	D2					; clear D2
			CLR         D3					; clear D3
			MOVE.B      D1,D3				; move byte from D1 to D3
			AND         #$07, D3			; and D3 to get first 3 bits only
        
			JSR         printEA				; jump to printEA
        
			LEA         newLine, A1         ; newline
			MOVE.B      #14, D0             ; command for trap call to display message
			TRAP        #15                 ; trap call
        
			MOVEM.L  	(SP)+, D0-D7/A1-A6	; pop saved registers from stack
			RTS								; return

***********************************************************************************************************
*
*						Immediate Data Subroutine Part 2
*
* The following subroutine is used to display the number between 1-8 for the bit vount for the shift/rotate opcode
* It displays it by storing the appropriate number in D1 and running trap task 3.
*
***********************************************************************************************************

MemShiftImm		
			MOVEM.L 	D0-D7/A1-A6, -(SP)	; caller saved data
            CLR     	D1					; clear D1
               
            MOVE.B  	D2, D1				; move byte from D2 to D1
            CMP.B   	#zero, D1			; compare 0 to D1
            BEQ     	displayEight		; if true, branch to displayEight
                
            MOVE.B  	#3, D0				; trap task command to display decimal
            TRAP    	#15					; trap call
            BRA     	endSubroutine		; branch to endSubroutine
                
displayEight    
			MOVE.B  	#$08, D1			; move 8 to D1
            MOVE.B  	#3, D0				; trap task command to display decimal
            TRAP    	#15                	; trap call
			
endSubroutine
            MOVEM.L  	(SP)+, D0-D7/A1-A6  ; pop saved registers from stack
            RTS                             ; return
        
***********************************************************************************************************
*
* 						EA Print Subroutine
*
***********************************************************************************************************

printEA 	
			MOVEM.L  D0-D7/A1-A6, -(SP)

        	CMP.B       #zero, D2
	        BEQ         pDataReg
    	    CMP.B       #one, D2
       		BEQ         pAddrReg
        	CMP.B       #two, D2
        	BEQ         pAddrDir
        	CMP.B       #three, D2
	        BEQ         pAddrPost
    	    CMP.B       #four, D2
        	BEQ         pAddrDec
        	CMP.B       #seven, D2
        	BEQ         pHex
        	BRA         invalid

***********************************************************************************************************
* Data Register        
pDataReg    
			CMP.B   	#zero,D3
            BEQ     	displayD0
            CMP.B   	#one,D3
            BEQ     	displayD1
            CMP.B   	#two,D3
            BEQ     	displayD2
            CMP.B   	#three,D3
            BEQ     	displayD3
            CMP.B   	#four,D3
            BEQ     	displayD4
            CMP.B   	#five,D3
            BEQ     	displayD5
            CMP.B   	#six,D3
            BEQ     	displayD6
            CMP.B   	#seven,D3
            BEQ     	displayD7
            
displayD0   LEA         dispD0, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine
            
displayD1   LEA         dispD1, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayD2   LEA         dispD2, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayD3   LEA         dispD3, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayD4   LEA         dispD4, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayD5   LEA         dispD5, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayD6   LEA         dispD6, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayD7   LEA         dispD7, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine
			
***********************************************************************************************************
* Address Register

pAddrReg    CMP.B   	#zero,D3
            BEQ     	displayA0
            CMP.B   	#one,D3
            BEQ     	displayA1
            CMP.B   	#two,D3
            BEQ     	displayA2
            CMP.B   	#three,D3
            BEQ     	displayA3
            CMP.B   	#four,D3
            BEQ     	displayA4
            CMP.B   	#five,D3
            BEQ     	displayA5
            CMP.B   	#six,D3
            BEQ    		displayA6
            CMP.B   	#seven,D3
            BEQ     	displayA7
            
displayA0   LEA         dispA0, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine
            
displayA1   LEA         dispA1, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA2   LEA         dispA2, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA3   LEA         dispA3, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA4   LEA         dispA4, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA5   LEA         dispA5, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA6   LEA         dispA6, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA7   LEA         dispA7, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

***********************************************************************************************************
* Address Register Direct

pAddrDir    LEA         opPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CMP.B   	#zero,D3
            BEQ     	displayA0A
            CMP.B   	#one,D3
            BEQ     	displayA1A
            CMP.B   	#two,D3
            BEQ     	displayA2A
            CMP.B   	#three,D3
            BEQ     	displayA3A
            CMP.B   	#four,D3
            BEQ     	displayA4A
            CMP.B   	#five,D3
            BEQ     	displayA5A
            CMP.B   	#six,D3
            BEQ     	displayA6A
            CMP.B   	#seven,D3
            BEQ     	displayA7A
            
displayA0A  LEA         dispA0, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine
            
displayA1A  LEA         dispA1, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA2A  LEA         dispA2, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA3A  LEA         dispA3, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA4A  LEA         dispA4, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA5A  LEA         dispA5, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA6A  LEA         dispA6, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA7A  LEA         dispA7, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine
            
***********************************************************************************************************
* Addr Postincrement
            
pAddrPost	LEA         opPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CMP.B   	#zero,D3
            BEQ     	displayA0P
            CMP.B   	#one,D3
            BEQ     	displayA1P
            CMP.B   	#two,D3
            BEQ     	displayA2P
            CMP.B   	#three,D3
            BEQ     	displayA3P
            CMP.B   	#four,D3
            BEQ     	displayA4P
            CMP.B   	#five,D3
            BEQ     	displayA5P
            CMP.B   	#six,D3
            BEQ     	displayA6P
            CMP.B   	#seven,D3
            BEQ     	displayA7P
            
displayA0P  LEA         dispA0, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         inc, A1           	; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine
            
displayA1P  LEA         dispA1, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         inc, A1           	; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA2P  LEA         dispA2, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         inc, A1           	; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA3P  LEA         dispA3, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         inc, A1           	; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA4P  LEA         dispA4, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         inc, A1           	; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA5P  LEA         dispA5, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         inc, A1           	; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA6P  LEA         dispA6, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         inc, A1           	; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA7P  LEA         dispA7, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         inc, A1           	; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

***********************************************************************************************************
* Addr Postdecrement

pAddrDec	
			LEA         dec, A1             ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
			LEA         opPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CMP.B   	#zero,D3
            BEQ     	displayA0D
            CMP.B   	#one,D3
            BEQ     	displayA1D
            CMP.B   	#two,D3
            BEQ     	displayA2D
            CMP.B   	#three,D3
            BEQ     	displayA3D
            CMP.B   	#four,D3
            BEQ     	displayA4D
            CMP.B   	#five,D3
            BEQ     	displayA5D
            CMP.B  		#six,D3
            BEQ     	displayA6D
            CMP.B   	#seven,D3
            BEQ     	displayA7D
            
displayA0D  
			LEA         dispA0, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine
            
displayA1D  
			LEA         dispA1, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA2D  
			LEA         dispA2, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA3D  
			LEA         dispA3, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA4D  
			LEA         dispA4, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA5D  
			LEA         dispA5, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA6D  
			LEA         dispA6, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA7D  
			LEA         dispA7, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

***********************************************************************************************************
* Display Hex

pHex        
			CMP.B       #zero, D3
            BEQ         AbsShort
            CMP.B       #one, D3
            BEQ         AbsLong
            CMP.B       #four, D3
            BEQ         DispImm
            
AbsShort    
			LEA         opPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         dispHex, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D1
            MOVE.W      (A0)+, D1
            CLR         D0
            MOVE.B      #4, D0
            
            JSR         outHex
            
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            BRA         endSub
            
AbsLong     
			LEA         opPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         dispHex, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D1
            MOVE.L      (A0)+, D1
            CLR         D0
            MOVE.B      #8, D0
            
            JSR         outHex
            
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            BRA         endSub

DispImm     
			LEA         hashTag, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

            LEA         dispHex, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CMP.B       #1,D6
            BEQ         ImmLong
            
            CLR         D1
            MOVE.W      (A0)+, D1
            CLR         D0
            MOVE.B      #4, D0
            JSR         outHex
            BRA         LongSkip
            
ImmLong     
			CLR         D1
            MOVE.L      (A0)+, D1
            CLR         D0
            MOVE.B      #8, D0
            JSR         outHex             

LongSkip
            BRA         endSub

invalid
			BRA			printInvalid

endSUB        
            MOVEM.L  	(SP)+, D0-D7/A1-A6
            RTS

***********************************************************************************************************
*
*						MOVEM Helper Function
*       This function is dedicated to printing out the address and data register for MOVEM. The 
*       function starts by identifying the size and then identifying the dr field. If the dr field
*       is 1, then the program goes to print before print out the address and data register for MOVEM. If dr
*       field is zero, program goes to print out the address and data register before printing out the
*       post increment or immediate data.
*
***********************************************************************************************************

MOVEMBRA    
			MOVEM.L 	D0-D7/A1-A6, -(SP)  ; Branches off depending on size bit
            CMP     	#zero,D5            ; Checks the size to see if it word
            BEQ      	MOVEMW              ; Branches if it is equal to word
            CMP      	#one, D5            ; Compares bits to long.
            BEQ      	MOVEML              ; Branches if it is equal to long size.
            BRA         printInvalid        ; Is invalid if it is not equal to either
            
MOVEMW     
            LEA         dispWord, A1        ; Prints a W to symbolize word
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

            LEA         space, A1           ; Print a space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            BRA         CheckDR

MOVEML   
            LEA         dispLong, A1        ; we know that the opcode will be MOVEML, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

            LEA         space, A1           ; Print a space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
         

            BRA         CheckDR             ; Branch to CheckDR

CheckDR     
            MOVE.W      (A0)+, D1           ; Taking in next word
            CMP         #zero,D6            ; Check if dr is 0, then print out data/address first
            BEQ         printRegMem         ; branch to printRegMem
            CMP         #one,D6             ; dr field is one, must print stack pointer first
            BEQ         printStack          ; Go to print stack pointer
            BRA         invalid             ; Go to invalid if equal to neither
            
printStack 
            JSR         printEA             ; Prints out the stack pointer
            
            LEA         comma,A1            ; Prints out comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            
            BRA         printRegMem
           
printRegMem 
            CLR         D4                  ; Using D4 to store predecrement mode addresses
            MOVE.B      D1,D4               ; Stores bits for D0-D7
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move bits containing information on filled data to D5
            AND         #mask1,D5           ; Use a bit mask to mask every bit except for the first bit
            CMP         #mask1,D5           ; Check if certain bit is 1 or 0
            BEQ         DataReg0            ; If comparison matches, then data register that is being put on stack starts her
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move bits containing information on filled data to D5
            AND         #mask2,D5           ; Use a bit mask to mask every bit except for the second bit
            CMP         #mask2,D5           ; Check if certain bit is 1 or 0
            BEQ         DataReg1            ; If comparison matches, then data register that is being put on stack starts here

            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move bits containing information on filled data to D5
            AND         #mask3,D5           ; Use a bit mask to mask every bit except for the third bit
            CMP         #mask3,D5           ; Check if certain bit is 1 or 0
            BEQ         DataReg2            ; If comparison matches, then data register that is being put on stack starts her
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move bits containing information on filled data to D5
            AND         #mask4,D5           ; Use a bit mask to mask every bit except for the fourth
            CMP         #mask4,D5           ; Check if certain bit is 1 or 0
            BEQ         DataReg3            ; If comparison matches, then data register that is being put on stack starts her
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move bits containing information on filled address/data to D5
            AND         #mask5,D5           ; Use a bit mask to mask every bit except for the fifth bit
            CMP         #mask5,D5           ; Check if certain bit is 1 or 0
            BEQ         DataReg4            ; If comparison matches, then data register that is being put on stack starts her

            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move bits containing information on filled address/data to D5
            AND         #mask6,D5           ; Use a bit mask to mask every bit except for the sixth bit
            CMP         #mask6,D5           ; Check if certain bit is 1 or 0
            BEQ         DataReg5            ; If comparison matches, then data register that is being put on stack starts her

            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move bits containing information on filled address/data to D5
            AND         #mask7,D5           ; Use a bit mask to mask every bit except for the seventh
            CMP         #mask7,D5           ; Check if certain bit is 1 or 0
            BEQ         DataReg6            ; If comparison matches, then data register that is being put on stack starts her

            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move bits containing information on filled address/data to D5
            AND         #mask8,D5           ; Use a bit mask to mask every bit except for the seventh
            CMP         #mask8,D5           ; Check if certain bit is 1 or 0
            BEQ         DataReg7            ; If comparison matches, then only D7 is being used
            
            BRA         invalid             ; If comaparisons fail then this is not MOVEM. Branch out.
            
DataReg0
            LEA         dispD0, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #mask2,D5           ; Uses mask to check for valid after current bit
            CMP         #mask2,D5           ; Check if there are anymore data registers used
            BEQ         Reg0Cont            ; Continues to check for last register used if so
            BRA         printMem            ; Else it will continue on to print the address/memory
			
Reg0Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         DataReg1            ; Found starting register move on to find ending register

DataReg1
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #maskA,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskA,D5           ; Check if there are bits before and after current masked bit
            BEQ         DataReg2            ; Branch to skip printing until the end register is found
            
            LEA         dispD1, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #mask3,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask3,D5           ; Checking if next bit is use
            BEQ         Reg1Cont            ; Continues to check for last register used if so
            BRA         printMem            ; Else it will continue on to print the address/memory
			
Reg1Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         DataReg2            ; Found starting register move on to find ending registe

DataReg2
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #maskB,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskB,D5           ; Check if there are bits before and after current masked bit
            BEQ         DataReg3            ; If there are bits before and after, skip to next register to find ending
            
            
            LEA         dispD2, A1          ; Output D2
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #mask4,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask4,D5           ; Checking if next bit is used
            BEQ         Reg2Cont            ; Continues to check for last register used if so
            BRA         printMem            ; Else it will continue on to print the address/memory
			
Reg2Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         DataReg3            ; Found starting register move on to find ending registe

DataReg3
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #maskC,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskC,D5           ; Check if there are bits before and after current masked bit
            BEQ         DataReg4            ; If there are bits before and after, skip to next register to find ending
    
            
            LEA         dispD3, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #mask5,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask5,D5
            BEQ         Reg3Cont            ; Continues to check for last register used if so
            BRA         printMem            ; Else it will continue on to print the address/memory
			
Reg3Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         DataReg4            ; Found starting register move on to find ending registe

DataReg4
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #maskD,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskD,D5           ; Check if there are bits before and after current masked bit
            BEQ         DataReg5            ; If there are bits before and after, skip to next register to find ending
            
            LEA         dispD4, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #mask6,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask6,D5           ; Checking if next bit is use
            BEQ         Reg4Cont            ; Continues to check for last register used if so
            BRA         printMem            ; Else it will continue on to print the address/memory
			
Reg4Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         DataReg5            ; Found starting register move on to find ending registe

DataReg5
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #maskE,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskE,D5           ; Check if there are bits before and after current masked bit
            BEQ         DataReg6            ; If there are bits before and after, skip to next register to find ending
            
            LEA         dispD5, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #mask7,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask7,D5           ; Checking if next bit is use
            BEQ         Reg5Cont            ; Continues to check for last register used if so
            BRA         printMem            ; Else it will continue on to print the address/memory
			
Reg5Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         DataReg7            ; Found starting register move on to find ending registe

DataReg6
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #maskF,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskF,D5           ; Check if there are bits before and after current masked bit
            BEQ         DataReg7            ; If there are bits before and after, skip to next register to find ending

            LEA         dispD6, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #mask8,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask8,D5           ; Checking if next bit is use
            BEQ         Reg6Cont            ; Continues to check for last register used if so
            BRA         printMem            ; Else it will continue on to print the address/memory
			
Reg6Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         DataReg7            ; Found starting register move on to find ending registe

DataReg7    
            LEA         dispD7, A1          ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         printMem            ; Last check, branch to print out the address register     
			
printMem                                    ; Made this function in order to reuse if DR is 1
            BRA         printMemNow         ; Branch out to printMemNow
			
printMemNow                           
            LEA         slash, A1           ; Display slash
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
         
            CLR         D4                  ; Using D4 to store predecrement mode addresses
            MOVE.W      D1,D4               ; Stores bits for D0-D7
            ASR         #eight,D4           ; Rotate to the right, to create space for next byte
            
            CLR         D5                  ; Clear space
            MOVE.B      D4,D5               ; Move bits containing information on used data register to D5
            AND         #mask1,D5           ; Use a bit mask to mask every bit except for the first bit
            CMP         #mask1,D5           ; Check if certain bit is 1 or 0
            BEQ         AddrReg0            ; If comparison matches, then address register that is being put on stack starts here
            
            CLR         D5                  ; Clear data register 
            MOVE.B      D4,D5               ; Move bits containing information on used data register to D5
            AND         #mask2,D5           ; Use a bit mask to mask every bit except for the second bit
            CMP         #mask2,D5           ; Check if certain bit is 1 or 0
            BEQ         AddrReg1            ; If comparison matches, then address register that is being put on stack starts here

            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move bits containing information on used data register to D5
            AND         #mask3,D5           ; Use a bit mask to mask every bit except for the third
            CMP         #mask3,D5           ; Check if certain bit is 1 or 0
            BEQ         AddrReg2            ; If comparison matches, then address register that is being put on stack starts here         
            
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move bits containing information on used data register to D5
            AND         #mask4,D5           ; Use a bit mask to mask every bit except for the fourth bit
            CMP         #mask4,D5           ; Check if certain bit is 1 or 0
            BEQ         AddrReg3            ; If comparison matches, then address register that is being put on stack starts here     
                
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move bits containing information on used data register to D5
            AND         #mask5,D5           ; Use a bit mask to mask every bit except for the fifth bit
            CMP         #mask5,D5           ; Check if certain bit is 1 or 0
            BEQ         AddrReg4            ; If comparison matches, then address register that is being put on stack starts here

            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move bits containing information on used data register to D5
            AND         #mask6,D5           ; Use a bit mask to mask every bit except for the sixth bit
            CMP         #mask6,D5           ; Check if certain bit is 1 or 0
            BEQ         AddrReg5            ; If comparison matches, then address register that is being put on stack starts here

            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move bits containing information on used data register to D5
            AND         #mask7,D5           ; Use a bit mask to mask every bit except for the seventh bit
            CMP         #mask7,D5           ; Check if certain bit is 1 or 0
            BEQ         AddrReg6            ; If comparison matches, then address register that is being put on stack starts here

            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move bits containing information on used data register to D5
            AND         #mask8,D5           ; Use a bit mask to mask every bit except for the last bit
            CMP         #mask8,D5           ; Check if certain bit is 1 or 0
            BEQ         AddrReg7            ; If comparison matches, then address register that is being put on stack starts here
			
AddrReg0

            LEA         dispA0, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D1,D5               ; Move byte to D5 for comparisons
            AND         #mask2,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask2,D5           ; Checking if next bit is use
            BEQ         Addr0Cont           ; Continues to check for last register used if so
            BRA         endMOVE             ; Last register has been found. Branch to subroutine to RTS
			
Addr0Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         AddrReg1            ; Branch to second address

AddrReg1
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #maskA,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskA,D5           ; Check if there are bits before and after current masked bit
            BEQ         AddrReg2            ; Skip print and move to next address to check if it the last address used
            
            LEA         dispA1, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #mask3,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask3,D5           ; Checking if next bit is use
            BEQ         Addr1Cont           ; Continues to check for last register used if so
            BRA         endMOVE             ; Last register has been found. Branch to subroutine to RTS
			
Addr1Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         AddrReg2            ; Skip print and move to next address to check if it the last address used    

AddrReg2
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #maskB,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskB,D5           ; Check if there are bits before and after current masked bit
            BEQ         AddrReg3            ; If there are bits before and after, skip to next register to find ending

            
            LEA         dispA2, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #mask4,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask4,D5           ; Checking if next bit is use
            BEQ         Addr2Cont           ; Continues to check for last register used if so
            BRA         endMOVE             ; Last register has been found. Branch to subroutine to RTS
			
Addr2Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         AddrReg3            ; Skip print and move to next address to check if it the last address used

AddrReg3
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #maskC,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskC,D5           ; Check if there are bits before and after current masked bit
            BEQ         AddrReg4            ; If there are bits before and after, skip to next register to find ending
            
            LEA         dispA3, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #mask5,D5           ; Bitmasking to check if next bit is used or not  
            CMP         #mask5,D5           ; Checking if next bit is use
            BEQ         Addr3Cont           ; Continues to check for last register used if so
            BRA         endMOVE             ; Last register has been found. Branch to subroutine to RTS
			
Addr3Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         AddrReg4

AddrReg4
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #maskD,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskD,D5           ; Check if there are bits before and after current masked bit
            BEQ         AddrReg5            ; If there are bits before and after, skip to next register to find ending
            
            LEA         dispA4, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #mask6,D5           ; Bitmasking to check if next bit is used or not 
            CMP         #mask6,D5           ; Checking if next bit is use
            BEQ         Addr4Cont           ; Continues to check for last register used if so
            BRA         endMOVE             ; Last register has been found. Branch to subroutine to RTS
			
Addr4Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         AddrReg5
AddrReg5
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #maskE,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskE,D5           ; Check if there are bits before and after current masked bit
            BEQ         AddrReg6            ; If there are bits before and after, skip to next register to find ending
            
            LEA         dispA5, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #mask7,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask7,D5           ; Checking if next bit is use
            BEQ         Addr5Cont           ; Continues to check for last register used if so
            BRA         endMOVE             ; Last register has been found. Branch to subroutine to RTS
			
Addr5Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         AddrReg7

AddrReg6
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #maskF,D5           ; Uses mask to check for valid bits before and after current bit
            CMP         #maskF,D5           ; Check if there are bits before and after current masked bit
            BEQ         AddrReg7            ; If there are bits before and after, skip to next register to find ending

            LEA         dispA6, A1          ; Output string D0
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D5                  ; Clear data register
            MOVE.B      D4,D5               ; Move byte to D5 for comparisons
            AND         #mask8,D5           ; Bitmasking to check if next bit is used or not
            CMP         #mask8,D5           ; Checking if next bit is use
            BEQ         Addr6Cont           ; Continues to check for last register used if so
            BRA         endMOVE             ; Last register has been found. Branch to subroutine to RTS
			
Addr6Cont        
            LEA         dec, A1             ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         AddrReg7            ; Skip print and move to next address to check if it the last address used

AddrReg7    
            LEA         dispA7, A1          ; Output -
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call        
            BRA         endMOVE             ; Skip print and move to next address to check if it the last address used
        
endMOVE
            MOVEM.L  (SP)+, D0-D7/A1-A6     ; Pops all data and address register off the stack
            RTS
endMove1                                    ; Used if MOVEM has DR is 1
            MOVEM.L  (SP)+, D0-D7/A1-A6
            RTS
***********************************************************************************************************
*
*						Hex Decode
*
*this subroutine displays hex code stored in D1. It displays based on the number of 
*It displays based on the number of hex to display which is stored in D0. If it is a
*long or word to display, it will figure out the ascii character and add $37 if it
*is a letter, and $30 if its a number. It will then load the character into D1 and 
*display it via trap task 6 and loop however many times is needed, 4 or 8. If a word
*needs to be displayed, it will roll the bits over so that, the hex are shifted by a word.
*
***********************************************************************************************************

outHex      
			MOVEM.L 	D0-D7/A1-A6, -(SP)
            CLR     	D3
            CLR     	D4
            MOVE.B  	D0, D4
            MOVE.L  	D1, D3
            CMP.B   	#4, D0
            BEQ     	moveOver
            BRA     	dispLOOP
            
moveOver    
			ROL.L   	#8,D3
            ROL.L   	#8,D3
            
dispLOOP    
			CMP.B   	#0, D4
            BEQ     	endDispSub
            ROL.L   	#4, D3
            CLR     	D5
            MOVE.B  	D3, D5 
            AND.L   	#$0F, D5
            CMP.B   	#10, D5
            BLT     	DLnine
            BRA     	DLetters
            
DLnine      
			ADD     	#$30, D5
            CLR     	D1
            MOVE.B  	D5, D1
            CLR     	D0
            MOVE.B  	#6, D0
            TRAP    	#15
            SUB     	#1, D4
            BRA     	dispLOOP  
 
DLetters    
			ADD     	#$37, D5
            CLR     	D1
            MOVE.B  	D5, D1
            CLR     	D0
            MOVE.B  	#6, D0
            TRAP    	#15
            SUB     	#1, D4
            BRA     	dispLOOP        

endDispSub  
			MOVEM.L  	(SP)+, D0-D7/A1-A6
            RTS

			
***********************************************************************************************************
*
*						IO Subroutine
*
*
*	the following subroutine gets the string address from the user
*	and converts it to Hex for a starting/ending address. it is done 
*	by checking each byte at address A1, and converting it from ascii to 
*	hex number. If the user enters an invalid character string, the
*	program will have a simhalt.
*
***********************************************************************************************************


Address                       			    
			MOVEM.L 	D3-D7/A2-A6, -(SP)

Retry   	
			CLR     	D2
			CLR     	D3
			CMP.B  		#4, D1
			BEQ     	subLOOP
			CMP.B  		#8, D1
			BEQ     	subLOOP
			BRA     	ADDinvalid        
        
subLOOP 	
			ROR     	#4, D4
			MOVE.B  	D4, D2
			CLR     	D4
			CLR     	D5
			CMP.B   	D1, D3
			BEQ     	endLOOP
			ADD.W   	#2, D3
			ROL.L   	#8, D2
        
bytLOOP 	
			ROL     	#4, D4
        
			CMP.B   	#$30, (A1)
			BEQ     	hZero 
			CMP.B   	#$31, (A1)
			BEQ    		hOne
			CMP.B   	#$32, (A1)
			BEQ     	hTwo
			CMP.B   	#$33, (A1)
			BEQ     	hThree
			CMP.B   	#$34, (A1)
			BEQ     	hFour
			CMP.B   	#$35, (A1)
			BEQ     	hFive
			CMP.B   	#$36, (A1)
			BEQ     	hSix
			CMP.B   	#$37, (A1)
			BEQ     	hSeven
			CMP.B   	#$38, (A1)
			BEQ     	hEight
			CMP.B   	#$39, (A1)
			BEQ    		hNine
			CMP.B   	#$41, (A1)
			BEQ     	hA
			CMP.B   	#$42, (A1)
			BEQ     	hB
			CMP.B   	#$43, (A1)
			BEQ     	hC
			CMP.B   	#$44, (A1)
			BEQ     	hD
			CMP.B   	#$45, (A1)
			BEQ     	hE
			CMP.B   	#$46, (A1)
			BEQ     	hF 
			
			BRA     	invalid 
			
hZero   	
			MOVE.B  	#$00, D4
			BRA     	nextH
			
hOne    	
			MOVE.B  	#$10, D4
			BRA     	nextH
hTwo    	
			MOVE.B  	#$20, D4
			BRA     	nextH
			
hThree  	
			MOVE.B 		#$30, D4
			BRA     	nextH
			
hFour   	MOVE.B  	#$40, D4
			BRA     	nextH
			
hFive   	
			MOVE.B  	#$50, D4
			BRA     	nextH
			
hSix    	
			MOVE.B  	#$60, D4
			BRA     	nextH
			
hSeven  	
			MOVE.B  	#$70, D4
			BRA     	nextH
			
hEight  	
			MOVE.B  	#$80, D4
			BRA     	nextH
			
hNine   	
			MOVE.B  	#$90, D4
			BRA     	nextH
		
hA      	
			MOVE.B  	#$A0, D4
			BRA     	nextH
			
hB      	
			MOVE.B  	#$B0, D4
			BRA    		nextH
			
hC      	
			MOVE.B  	#$C0, D4
			BRA     	nextH
			
hD      	
			MOVE.B  	#$D0, D4
			BRA     	nextH
			
hE      	
			MOVE.B  	#$E0, D4
			BRA     	nextH
			
hF      	
			MOVE.B  	#$F0, D4
			BRA			nextH

nextH   	
			MOVE.B  	(A1)+, D0
			ADD     	#1, D5
			CMP.B   	#2, D5
			BEQ     	subLOOP
			BRA     	bytLOOP
        
ADDinvalid  
			LEA     	errorMessage, A1
            MOVE.B  	#14, D0
            TRAP    	#15    
    
            MOVE.B  	#2, D0
            TRAP    	#15

            BRA     	Retry
   
endLOOP 	
			MOVEM.L  	(SP)+, D3-D7/A2-A6
			RTS

printInvalid
			MOVE.B  	(A0)+,D1
			BRA     	LOOP

endPROG    

    SIMHALT                             ; halt simulator

***********************************************************************************************************
*
*						IO Strings
*			
*		This section holds all of the various strings to output to the console.
*
***********************************************************************************************************
displayStart
			MOVEM.L 	D0-D7/A0-A7, -(SP)
			
            LEA         Title,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            MOVEM.L  	(SP)+, D3-D7/A2-A6
            RTS
            
Title    	
            DC.B       '****       ****  *******     ****    ***      ***',CR,LF
            DC.B       '****       **** *******    ********  ***     ***',CR,LF
            DC.B       '*****     ***** ***       ***    *** ***    ***',CR,LF
            DC.B       '******   ****** ***       ***    *** ***   ***',CR,LF
            DC.B       '******* ******* ***        ********  ***  ***',CR,LF
            DC.B       '*************** *******     ******   ********',CR,LF
            DC.B       '****  ***  **** ********   ********  ***  ***',CR,LF
            DC.B       '****   *   **** ***   *** ***    *** ***   ***',CR,LF 
            DC.B       '****       **** ***   *** ***    *** ***    ***',CR,LF
            DC.B       '****       **** ***   ***  ********  ***     ***',CR,LF
            DC.B       '****       ****  *******	 ****    ***      ***',CR,LF
	
            DC.B       			'       *********          ********** ****       ****',CR,LF
            DC.B       			'       ***********      *********    ****       ****',CR,LF
            DC.B       			'       ***    *****   *********      *****     *****',CR,LF
            DC.B       			'       ***      **** ********        ******   ******',CR,LF
            DC.B       			'       ***       *** ************    ******* *******',CR,LF
            DC.B       			'       ***       *** *************** ***************',CR,LF
            DC.B       			'       ***       ***    ************ ****  ***  ****',CR,LF
            DC.B       			'       ***      ***         ******** ****   *   ****',CR,LF
            DC.B       			'       ***    *****       ********   ****       ****',CR,LF
            DC.B       			'       ***********      *********    ****       ****',CR,LF
            DC.B   			    '       *********     **********      ****       ****',CR,LF


startingMessage DC.B    'Enter Starting Address (in hex): ', 0
endingMessage   DC.B    'Enter Ending Address (in hex): ', 0
errorMessage    DC.B    'Incorrect Address, try again: ', 0

newLine     	DC.B    ' ', CR, LF, 0
space       	DC.B    '  ', 0

hashTag     	DC.B    '#', 0
dispHex     	DC.B    '$', 0
comma       	DC.B    ',', 0

opPer       	DC.B    '(', 0
clPer       	DC.B    ')', 0
dec         	DC.B    '-', 0
inc         	DC.B    '+', 0

ORImatch    	DC.B    'ORI', 0
CMPImatch   	DC.B    'CMPI', 0
BCLRmatch   	DC.B    'BCLR', 0
MOVEmatch   	DC.B    'MOVE', 0
MOVEAmatch  	DC.B    'MOVEA', 0
NEGmatch    	DC.B    'NEG', 0
RTSmatch    	DC.B    'RTS', 0
JSRmatch    	DC.B    'JSR', 0
MOVEMmatch  	DC.B    'MOVEM', 0
LEAmatch    	DC.B    'LEA', 0
SUBQmatch   	DC.B    'SUBQ', 0
BRAmatch    	DC.B    'BRA', 0
BCSmatch    	DC.B    'BCS', 0
BVCmatch    	DC.B    'BVC', 0
BGEmatch    	DC.B    'BGE', 0
BLTmatch    	DC.B    'BLT', 0
DIVSmatch   	DC.B    'DIVS', 0
ORmatch     	DC.B    'OR', 0
SUBmatch    	DC.B    'SUB', 0
EORmatch    	DC.B    'EOR', 0
CMPmatch    	DC.B    'CMP', 0
MULSmatch   	DC.B    'MULS', 0
ADDmatch    	DC.B    'ADD', 0
ADDAmatch   	DC.B    'ADDA', 0
LSRmatch    	DC.B    'LSR', 0
LSLmatch    	DC.B    'LSL', 0
ASRmatch    	DC.B    'ASR', 0
ASLmatch    	DC.B    'ASL', 0
RORmatch    	DC.B    'ROR', 0
ROLmatch    	DC.B    'ROL', 0

slash       	DC.B    '/', 0
stack       	DC.B    '(SP)', 0
 
dispByte    	DC.B    '.B', 0
dispWord    	DC.B    '.W', 0
dispLong    	DC.B    '.L', 0

dispA0      	DC.B    'A0', 0
dispA1      	DC.B    'A1', 0
dispA2      	DC.B    'A2', 0
dispA3      	DC.B    'A3', 0
dispA4      	DC.B    'A4', 0
dispA5      	DC.B    'A5', 0
dispA6      	DC.B    'A6', 0
dispA7      	DC.B    'A7', 0

dispD       	DC.B    'D',0
dispD0      	DC.B    'D0', 0
dispD1      	DC.B    'D1', 0
dispD2      	DC.B    'D2', 0
dispD3      	DC.B    'D3', 0
dispD4      	DC.B    'D4', 0
dispD5      	DC.B    'D5', 0
dispD6      	DC.B    'D6', 0
dispD7      	DC.B    'D7', 0 
 
           END    START                ; last line of source




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
