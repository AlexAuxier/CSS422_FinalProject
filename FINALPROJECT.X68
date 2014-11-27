*-----------------------------------------------------------
* Title      :
* Written by :  Abdul Hakim, David Trinh, Alexander Auxier
* Date       :
* Description:
*-----------------------------------------------------------
CR          EQU     $0D     
LF          EQU     $0A
  
test_start  EQU     $00002000   ; defined starting address
test_end    EQU     $00002005   ; defined ending address
     
zero        EQU     $00         ; defined hex value 0
one         EQU     $01         ; defined hex value 1 
two         EQU     $02         ; defined hex value 2
three       EQU     $03         ; defined hex value 3
four        EQU     $04         ; defined hex value 4
five        EQU     $05         ; defined hex value 5
six         EQU     $06         ; defined hex value 6
seven       EQU     $07
eight       EQU     $08         ; defined hex value 8
nine        EQU     $09         ; defined hex value 9
eleven      EQU     $0B         ; defined hex value 11
twelve      EQU     $0C         ; defined hex value 12
thirteen    EQU     $0D         ; defined hex value 13
fourteen    EQU     $0E         ; defined hex value 14

s1B         EQU     %0000       ; byte size 1 
s1W         EQU     %0001       ; word size 1
s1L         EQU     %0010       ; long size 1

s2W         EQU     %0000       ; word size 2
s2L         EQU     %0001       ; long size 2

s3B         EQU     %0001       ; byte size 3
s3W         EQU     %0011       ; word size 3
s3L         EQU     %0010       ; long size 3

addMatchDn  EQU     %0000       ; Address Mode Data Register
addMatchAn  EQU     %0001       ; Address Mode Address Register
addMatchAd  EQU     %0010       ; Address Mode Address
addMatchPi  EQU     %0011       ; Address Mode with PostIncrement
addMatchPd  EQU     %0100       ; Address Mode with PreDecrement
addMatchDi  EQU     %0111       ; Address Mode for Word, Long, or Immediate 

reg0        EQU     %0000       ; register 0
reg1        EQU     %0001       ; register 1
reg2        EQU     %0010       ; register 2
reg3        EQU     %0011       ; register 3
reg4        EQU     %0100       ; register 4
reg5        EQU     %0101       ; register 5
reg6        EQU     %0110       ; register 6
reg7        EQU     %0111       ; register 7

firstNib    EQU     $F0
secNib      EQU     $0F
             
            ORG    $1000
START:                                  ; first instruction of program
      
        MOVEA.L     #test_start, A0     ; load starting address
        MOVEA.L     #test_end, A2       ; load ending address
          
LOOP    CLR         D1                  ; clear out D1
        CLR         D2                  ; clear out D2
        CMPA.L      A2, A0              ; compare starting and ending addresses
        BGT         endProg             ; if A0 > A1, we've finished, end program
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

braZero CLR         D2                  ; first nibble is 0, 3 opcodes are possible 
        MOVE.B      D1, D2              ; clear out D2 and copy D1 back in
        AND.B       $0F, D2             ; set first nibble to 0
 
        CMP.B       #zero, D2           ; compare second nibble to 0
        BEQ         opORI               ; branch to ORI method
        CMP.B       #twelve, D2         ; compare second nibble to 12
        BEQ         opCMPI              ; branch to CMPI method
        CMP.B       #one,D2             ; Test for static BCLR
        BEQ         opStatBCLR          ; branch to BCLR
        CMP.B       #eight,D2           ; Test for static BCLR
        BEQ         opBCLR
        BRA         printInvalid
        
        
braOne  BRA         opMOVEB             ; we know that there is only one opcode that is MOVE.B

braTwo  ; there are two opCodes available, MOVE.L, or MOVEA.L

braThree ; there are two opCodes available, MOVE.W, or MOVEA.W

braFour CLR         D2                  ; first nibble is 4, 5 opcodes are possible 
        MOVE.B      D1, D2              ; clear out D2 and copy D1 back in
        AND.B       $0F, D2             ; set first nibble to 0
 
        CMP.B       #four, D2           ; compare second nibble to 4
        BEQ         opNEG               ; branch to NEG method
        CMP.B       #fourteen, D2       ; compare second nibble to E
        BEQ         opRTSJSR            ; branch to JSR or RTS method
        BRA         opMOVEMLEA          ; otherwise, branch to MOVEM or LEA method

braFive BRA         opSUBQ              ; we know that there is only one opcode that is SUBQ

braSix  CLR         D2                  ; first nibble is 6, 5 opcodes are possible 
        MOVE.B      D1, D2              ; clear out D2 and copy D1 back in
        AND.B       $0F, D2             ; set first nibble to 0
 
        CMP.B       #zero, D2           ; compare second nibble to 0
        BEQ         opBRA               ; branch to BRA method
        CMP.B       #five, D2           ; compare second nibble to 5
        BEQ         opBCS               ; branch to BCS method
        CMP.B       #eight, D2          ; compare second nibble to 8
        BEQ         opBVC               ; branch to BCS method
        CMP.B       #twelve, D2         ; compare second nibble to 12
        BEQ         opBGE               ; branch to BGE method
        BRA         opBLT               ; otherwise, branch to BLT method

braEight    ; there are two opCodes available DIVS, or OR

braNine BRA         opSUB               ; we know that there is only one opcode that is SUB

braEleven   ; there are two opCodes available EOR, or CMP

braTwelve   BRA     opMULS              ; we know that there is only one opcode that is MULS    
  
braThirteen ; there are two opCodes available ADD, or ADDA

braFourteen CLR         D2                  ; first nibble is E, 5 opcodes are possible 
            MOVE.B      D1, D2              ; clear out D2 and copy D1 back in
            AND.B       $0F, D2             ; set first nibble to 0
 
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
            BRA         opROL               ; otherwise, branch to ROL method

opORI   LEA         ORImatch, A1        ; we know that the opcode will be ORI, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        MOVE.B      (A0)+, D1
        MOVE.B      D1,D2               ; copy data over
        ASR         #6,D2               ; shifts 6 bits over to read just the size        
        CMP.B       #zero,D2
        BEQ         opORIB
        CMP.B       #one,D2
        BEQ         opORIW
        CMP.B       #two,D2
        BEQ         opORIL
        
        BRA         printInvalid
        
opORIB  LEA         dispByte, A1        ; Display byte
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         space, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        MOVE.B      D1,D2
        ASR         #three,D2
        AND         #seven,D2
        CLR         D3        
        MOVE.B      D1,D3
        AND         #seven,D3
        
        CLR         D1
        MOVE.W      (A0)+, D1
        
        LEA         hashTag, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        MOVE.B      #3, D0
        TRAP        #15
        
        LEA         comma, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         printEA
        
        LEA        	newLine, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP
        
        
opORIW  LEA         dispByte, A1        ; Display byte
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         space, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        MOVE.B      D1,D2
        ASR         #three,D2
        AND         #seven,D2
        CLR         D3        
        MOVE.B      D1,D3
        AND         #seven,D3
        
        CLR         D1
        MOVE.W      (A0)+, D1
        
        LEA         hashTag, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        MOVE.B      #3, D0
        TRAP        #15
        
        LEA         comma, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         printEA
        
        LEA        	newLine, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP
     
opORIL  LEA         dispByte, A1        ; Display byte
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         space, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        MOVE.B      D1,D2
        ASR         #three,D2
        AND         #seven,D2
        CLR         D3        
        MOVE.B      D1,D3
        AND         #seven,D3
        
        CLR         D1
        MOVE.L      (A0)+, D1
        
        LEA         hashTag, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        MOVE.B      #3, D0
        TRAP        #15
        
        LEA         comma, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         printEA
        
        LEA        	newLine, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP
         
opCMPI  LEA         CMPImatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
                
        MOVE.B      (A0)+, D1
        MOVE.B      D1,D2               ; copy data over
        ASR         #6,D2               ; shifts 6 bits over to read just the size        
        MOVE        D2,D3               ; store size into D3
        CLR         D2
        
        MOVE.B      D1,D2               ; Reload D2 with the same byte to get mode
        ASL         #two,D2             ; Moving two bits over to isolate and remove the size
        MOVE.B      D2,D4               ; Move the mode and register to D4 and leave the size
        CLR         D2                  ; Clear out data register
        MOVE.B      D4,D2               ; Put data back into D2 with just the mode and register
        ASR         #five,D2            ; Shift the register out to get just the mode
        MOVE.B      D2,D4               ; Store mode into D4
        CLR         D2
        
        MOVE.B      D1,D2               ; Getting the EA register
        ASL         #five,D2
        MOVE.B      D2,D5               ; Move just the register into D5
        CLR         D2                  ; Clearing D2 to put data back
        MOVE.B      D5,D2               ; Putting back the register
        ASR         #five,D2            ; Shifting bits in order to read the register
        MOVE.B      D2,D5               ; Store register into D5
        
        BRA         LOOP                ; go back to the loop



opBCLR          LEA         BCLRmatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
                MOVE.B      #14, D0             ; command for trap call to display message
                TRAP        #15                 ; trap call
                
                ASR         #one,D2             ; Shift to the right to remove the 1
                MOVE.B      D2,D3               ; Store register into D3
                
                CLR         D2
                MOVE.B      (A0)+,D1
                MOVE.B      D1,D2
                ASR         #two,D2             ; Shift two bits over in order to put mode into the first nibble
                AND         #secNib,D2          ; Clear first nibble
                ASR         #one,D2             ; shift to remove register and have just the mode
                MOVE.B      D2,D4               ; Move mode into D4
                CLR         D2
                
                MOVE.B      D1,D2               ; Move data back into D2 to retrieve the register
                ASL         #one,D2             ; shift one to the left to move node to other nibble
                AND         #secNib,D2          ; Clear other nibble
                ASR         #one,D2             ; Move register back 
                MOVE.B      D2,D5               ; Store EA register
                

                CLR         D2                
        
opStatBCLR      LEA         BCLRmatch, A1       ; we know that the opcode will be BCLR, so load A1 to print message
                MOVE.B      #14, D0             ; command for trap call to display message
                TRAP        #15                 ; trap call
                
                CLR         D2
                MOVE.B      (A0)+,D1
                MOVE.B      D1,D2
                ASR         #two,D2             ; Shift two bits over in order to put mode into the first nibble
                AND         #secNib,D2          ; Clear first nibble
                ASR         #one,D2             ; shift to remove register and have just the mode
                MOVE.B      D2,D3               ; Move mode into D3
                CLR         D2
                
                MOVE.B      D1,D2               ; Move data back into D2 to retrieve the register
                ASL         #one,D2             ; shift one to the left to move node to other nibble
                AND         #secNib,D2          ; Clear other nibble
                ASR         #one,D2             ; Move register back 
                MOVE.B      D2,D4               ; Store register

                BRA         LOOP                ; go back to the loop
 
opMOVEB LEA         MOVEmatch, A1       ; we know that the opcode will be MOVE.B, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        LEA         dispByte, A1        ; display byte
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        LEA         space, A1           ; create spaces
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opNEG   LEA         NEGmatch, A1        ; we know that the opcode will be NEG, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opRTSJSR

opMOVEMLEA

opSUBQ  LEA         SUBQmatch, A1       ; we know that the opcode will be SUBQ, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opBRA   LEA         BRAmatch, A1        ; we know that the opcode will be BRA, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        LEA         space, A1           ; create spaces
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opBCS   LEA         BCSmatch, A1        ; we know that the opcode will be BCS, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opBVC   LEA         BVCmatch, A1        ; we know that the opcode will be BVC, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opBGE   LEA         BGEmatch, A1        ; we know that the opcode will be BGE, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opBLT   LEA         BLTmatch, A1        ; we know that the opcode will be BLT, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opSUB   LEA         SUBmatch, A1        ; we know that the opcode will be SUB, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opMULS  LEA         MULSmatch, A1       ; we know that the opcode will be MULS, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opASL   LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opASR   LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opLSL   LEA         LSLmatch, A1        ; we know that the opcode will be LSL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opLSR   LEA         LSRmatch, A1        ; we know that the opcode will be LSR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opROL   LEA         ROLmatch, A1        ; we know that the opcode will be ROL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

opROR   LEA         RORmatch, A1        ; we know that the opcode will be ROR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call


***********************************************************************************************************
*
* 											EA Print Check
*
***********************************************************************************************************
printEA 	MOVEM.L  D0-D7/A0-A6, -(SP)

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
        	BRA         invalid

***********************************************************************************************************
* Data Register        
pDataReg    CMP.B   #zero,D3
            BEQ     displayD0
            CMP.B   #one,D3
            BEQ     displayD1
            CMP.B   #two,D3
            BEQ     displayD2
            CMP.B   #three,D3
            BEQ     displayD3
            CMP.B   #four,D3
            BEQ     displayD4
            CMP.B   #five,D3
            BEQ     displayD5
            CMP.B   #six,D3
            BEQ     displayD6
            CMP.B   #seven,D3
            BEQ     displayD7
            
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
pAddrReg    CMP.B   #zero,D3
            BEQ     displayA0
            CMP.B   #one,D3
            BEQ     displayA1
            CMP.B   #two,D3
            BEQ     displayA2
            CMP.B   #three,D3
            BEQ     displayA3
            CMP.B   #four,D3
            BEQ     displayA4
            CMP.B   #five,D3
            BEQ     displayA5
            CMP.B   #six,D3
            BEQ     displayA6
            CMP.B   #seven,D3
            BEQ     displayA7
            
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
            
            CMP.B   #zero,D3
            BEQ     displayA0A
            CMP.B   #one,D3
            BEQ     displayA1A
            CMP.B   #two,D3
            BEQ     displayA2A
            CMP.B   #three,D3
            BEQ     displayA3A
            CMP.B   #four,D3
            BEQ     displayA4A
            CMP.B   #five,D3
            BEQ     displayA5A
            CMP.B   #six,D3
            BEQ     displayA6A
            CMP.B   #seven,D3
            BEQ     displayA7A
            
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
            
            CMP.B   #zero,D3
            BEQ     displayA0P
            CMP.B   #one,D3
            BEQ     displayA1P
            CMP.B   #two,D3
            BEQ     displayA2P
            CMP.B   #three,D3
            BEQ     displayA3P
            CMP.B   #four,D3
            BEQ     displayA4P
            CMP.B   #five,D3
            BEQ     displayA5P
            CMP.B   #six,D3
            BEQ     displayA6P
            CMP.B   #seven,D3
            BEQ     displayA7P
            
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

pAddrDec	LEA         dec, A1             ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
			LEA         opPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CMP.B   #zero,D3
            BEQ     displayA0D
            CMP.B   #one,D3
            BEQ     displayA1D
            CMP.B   #two,D3
            BEQ     displayA2D
            CMP.B   #three,D3
            BEQ     displayA3D
            CMP.B   #four,D3
            BEQ     displayA4D
            CMP.B   #five,D3
            BEQ     displayA5D
            CMP.B   #six,D3
            BEQ     displayA6D
            CMP.B   #seven,D3
            BEQ     displayA7D
            
displayA0D  LEA         dispA0, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine
            
displayA1D  LEA         dispA1, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA2D  LEA         dispA2, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA3D  LEA         dispA3, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA4D  LEA         dispA4, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA5D  LEA         dispA5, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA6D  LEA         dispA6, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine

displayA7D  LEA         dispA7, A1          ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            LEA         clPer, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            BRA         endSUB              ; go to the end of the subroutine


invalid

endSUB
        
        MOVEM.L  (SP)+, D0-D7/A0-A6
        RTS

***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************

printInvalid
endPROG    

    SIMHALT                             ; halt simulator

newLine     DC.B    ' ', CR, LF, 0
space       DC.B    '  ', 0

hashTag     DC.B    '#', 0
dispHex     DC.B    '$', 0
comma       DC.B    ',', 0

opPer       DC.B    '(', 0
clPer       DC.B    ')', 0
dec         DC.B    '-', 0
inc         DC.B    '+', 0

ORImatch    DC.B    'ORI', 0
CMPImatch   DC.B    'CMPI', 0
BCLRmatch   DC.B    'BCLR', 0
MOVEmatch   DC.B    'MOVE', 0
MOVEAmatch  DC.B    'MOVEA', 0
NEGmatch    DC.B    'NEG', 0
RTSmatch    DC.B    'RTS', 0
JSRmatch    DC.B    'JSR', 0
MOVEMmatch  DC.B    'MOVEM', 0
LEAmatch    DC.B    'LEA', 0
SUBQmatch   DC.B    'SUBQ', 0
BRAmatch    DC.B    'BRA', 0
BCSmatch    DC.B    'BCS', 0
BVCmatch    DC.B    'BVC', 0
BGEmatch    DC.B    'BGE', 0
BLTmatch    DC.B    'BLT', 0
DIVSmatch   DC.B    'DIVS', 0
ORmatch     DC.B    'OR', 0
SUBmatch    DC.B    'SUB', 0
EORmatch    DC.B    'EOR', 0
CMPmatch    DC.B    'CMP', 0
MULSmatch   DC.B    'MULS', 0
ADDmatch    DC.B    'ADD', 0
ADDAmatch   DC.B    'ADDA', 0
LSRmatch    DC.B    'LSR', 0
LSLmatch    DC.B    'LSL', 0
ASRmatch    DC.B    'ASR', 0
ASLmatch    DC.B    'ASL', 0
RORmatch    DC.B    'ROR', 0
ROLmatch    DC.B    'ROL', 0
 
dispByte    DC.B    '.B', 0
dispWord    DC.B    '.W', 0
dispLong    DC.B    '.L', 0

dispA0      DC.B    'A0', 0
dispA1      DC.B    'A1', 0
dispA2      DC.B    'A2', 0
dispA3      DC.B    'A3', 0
dispA4      DC.B    'A4', 0
dispA5      DC.B    'A5', 0
dispA6      DC.B    'A6', 0
dispA7      DC.B    'A7', 0

dispD0      DC.B    'D0', 0
dispD1      DC.B    'D1', 0
dispD2      DC.B    'D2', 0
dispD3      DC.B    'D3', 0
dispD4      DC.B    'D4', 0
dispD5      DC.B    'D5', 0
dispD6      DC.B    'D6', 0
dispD7      DC.B    'D7', 0  
           END    START                ; last line of source
           
           
           


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
