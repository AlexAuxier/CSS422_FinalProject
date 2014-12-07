*-----------------------------------------------------------
* Title      :
* Written by :  Abdul Hakim, David Trinh, Alexander Auxier
* Date       :
* Description:
*-----------------------------------------------------------
CR          EQU     $0D     
LF          EQU     $0A
     
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
      
        LEA     startingMessage, A1
        MOVE.B  #14, D0
        TRAP    #15    
    
        MOVE.B  #2, D0
        TRAP    #15
    
        JSR     Address
        MOVEA.L D2, A0
        
        LEA     endingMessage, A1
        MOVE.B  #14, D0
        TRAP    #15    
    
        MOVE.B  #2, D0
        TRAP    #15
    
        JSR     Address
        MOVEA.L D2, A2
        
        LEA     newline, A1
        MOVE.B  #14, D0
        TRAP    #15 
          
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
        AND.B       #secNib, D2         ; set first nibble to 0
 
        CMP.B       #zero, D2           ; compare second nibble to 0
        BEQ         opORI               ; branch to ORI method
        CMP.B       #twelve, D2         ; compare second nibble to 12
        BEQ         opCMPI              ; branch to CMPI method
        CMP.B       #eight,D2           ; Test for static BCLR
        BEQ         opBCLR
        AND         #one,D2            ; Sets all bits to 0 except for first bit if it is 1
        CMP.B       #one,D2          ; if it is one then there is a chance it is dynamic BCLR
        BEQ         opDynBCLR
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

braTwelve   BRA         opMULS              ; we know that there is only one opcode that is MULS    
  
braThirteen ASL         #eight, D1          ; we need the whole word to compare between add and adda, so move over the current byte 
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
             
braFourteen ASL.W       #eight,D1           ; we need the whole word to compare between add and adda, so move over the current byte
            MOVE.B      (A0)+, D1           ; load the remaining byte to D1
            
            CLR         D2                  ; clear D2
            MOVE.W      D1, D2              ; copy opcode to D2
            ASR         #six, D2            ; shift the bits right to get size
            AND         #03,D2
        
            CMP.B       #three, D2          ; if the size is three, we are shifting memory
            BEQ         memShifts           ; go to memory shift
            BRA         regShifts           ; else go to register shift

memShifts   CLR         D2             
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
            
regShifts   CMP.B       #zero, D2           ; if size is 0, we are shifting a byte
            BEQ         memSB               ; branch to register shift byte
            CMP.B       #one, D2            ; if size is 1, we are shifting a word
            BEQ         memSW               ; branch to register shift word
            CMP.B       #two, D2            ; if size is 1, we are shifting a long
            BEQ         memSL               ; branch to register shift long
            BRA         printInvalid        ; otherwise, invalid

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
        
        
opORIW  LEA         dispWord, A1        ; Display byte
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
     
opORIL  LEA         dispLong, A1        ; Display byte
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
        CMP.B       #zero,D2
        BEQ         opCMPIB
        CMP.B       #one,D2
        BEQ         opCMPIW
        CMP.B       #two,D2
        BEQ         opCMPIL
        
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

opCMPIB LEA         dispByte, A1        ; Display byte
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

opCMPIW LEA         dispWord, A1        ; Display byte
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

opCMPIL LEA         dispLong, A1        ; Display byte
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

opBCLR          LEA         BCLRmatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
                MOVE.B      #14, D0             ; command for trap call to display message
                TRAP        #15                 ; trap call

                LEA         space, A1           ; Display space
                MOVE.B      #14, D0             ; command for trap call to display message
                TRAP        #15                 ; trap call
                
                CLR         D2
                MOVE.B      (A0)+, D1
                MOVE.B      D1,D2               ; copy data over
                ASR         #three,D2           ; Shift to the right to remove register
                AND         #seven,D2           ; Sets other bits to 0 and leave Mode the same
                
                CLR         D3                  ; Clear D3 so we can move D1 in
                MOVE.B      D1,D3               ; Move othr byte in
                AND         #seven,D3           ; Set everything besides register to 0
                
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
                
                MOVE.B      #zero,D2                
                JSR         printEA
                
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
                

                JSR         printEA
        
                LEA        	newLine, A1           ; Display space
                MOVE.B      #14, D0             ; command for trap call to display message
                TRAP        #15                 ; trap call            


                BRA         LOOP                ; go back to the loop
 
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
        
        CLR          D1
        CLR          D2
        MOVE.B      (A0)+,D1            ; Copy byte into D1
        MOVE.B      D1,D2
        ASR         #6,D2               ; Shifts source mode and register out to get destination mode
        ADD         D2,D4               ; Adds the remaining bits to D4
        
        CLR         D2
        MOVE.B      D1,D2               ; Copy new byte over to D2
        ASR         #three,D2           ; Shift source register out
        AND         #seven,D2           ; Set everything to 0 except for the mode
        
        CLR         D3
        MOVE.B      D1,D3
        AND         #seven,D3
        
        JSR         printEA
        
        LEA         comma, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D4,D2
        MOVE.B      D5,D3
        
        JSR         printEA
        
        
        LEA        	newLine, A1           ; Display space
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
        
            CLR          D1
            CLR          D2
            MOVE.B      (A0)+,D1            ; Copy byte into D1
            MOVE.B      D1,D2
            ASR         #6,D2               ; Shifts source mode and register out to get destination mode
            ADD         D2,D4               ; Adds the remaining bits to D4
        
            CMP         #one,D4             ; Check if it is MOVEA
            BEQ         opMOVEAL            ; If it is, branch off
            
            LEA         MOVEmatch, A1       ; we know that the opcode will be MOVE.L OR MOVEA.L, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
            
            
            LEA         dispLong,A1
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         space, A1           ; create spaces
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            CLR         D2
            MOVE.B      D1,D2               ; Copy new byte over to D2
            ASR         #three,D2           ; Shift source register out
            AND         #seven,D2           ; Set everything to 0 except for the mode
        
            CLR         D3
            MOVE.B      D1,D3
            AND         #seven,D3
            
            CLR         D1                  ; Clear D1
            
            JSR         printEA
            
            LEA         comma, A1           ; Display comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            CLR         D2
            CLR         D3
            MOVE.B      D4,D2
            MOVE.B      D5,D3
            

            
            JSR         printEA
        
        
            LEA        	newLine, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            


            BRA         LOOP                ; go back to the loop
            
opMOVEAL

            LEA         MOVEAmatch,A1
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         dispLong,A1
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            

            LEA         space, A1           ; create spaces
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2
            MOVE.B      D1,D2               ; Copy new byte over to D2
            ASR         #three,D2           ; Shift source register out
            AND         #seven,D2           ; Set everything to 0 except for the mode
        
            CLR         D3
            MOVE.B      D1,D3
            AND         #seven,D3
            
            CLR         D1                  ; Clear D1
            
            
            JSR         printEA
            
            LEA         comma, A1           ; Display comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

            CLR         D2
            CLR         D3
            MOVE.B      D4,D2
            MOVE.B      D5,D3
        
            JSR         printEA
        
        
            LEA        	newLine, A1           ; Display space
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
        
            CLR          D1
            CLR          D2
            MOVE.B      (A0)+,D1            ; Copy byte into D1
            MOVE.B      D1,D2
            ASR         #6,D2               ; Shifts source mode and register out to get destination mode
            ADD         D2,D4               ; Adds the remaining bits to D4
        
            CMP         #one,D4             ; Check if it is MOVEA
            BEQ         opMOVEAW            ; If it is, branch off
            
            LEA         MOVEmatch, A1       ; we know that the opcode will be MOVE.L OR MOVEA.L, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
            
            LEA         dispWord,A1
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         space, A1           ; create spaces
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            CLR         D2
            MOVE.B      D1,D2               ; Copy new byte over to D2
            ASR         #three,D2           ; Shift source register out
            AND         #seven,D2           ; Set everything to 0 except for the mode
        
            CLR         D3
            MOVE.B      D1,D3
            AND         #seven,D3
            
            CLR         D1                  ; Clear D1
            
            JSR         printEA
            
            LEA         comma, A1           ; Display comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
            CLR         D2
            CLR         D3
            MOVE.B      D4,D2
            MOVE.B      D5,D3
            

            
            JSR         printEA
        
        
            LEA        	newLine, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            


            BRA         LOOP                ; go back to the loop
opMOVEAW  
            LEA         MOVEAmatch,A1
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         dispWord,A1
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            

            LEA         space, A1           ; create spaces
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2
            MOVE.B      D1,D2               ; Copy new byte over to D2
            ASR         #three,D2           ; Shift source register out
            AND         #seven,D2           ; Set everything to 0 except for the mode
        
            CLR         D3
            MOVE.B      D1,D3
            AND         #seven,D3
            
            CLR         D1                  ; Clear D1
            
            
            JSR         printEA
            
            LEA         comma, A1           ; Display comma
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call

            CLR         D2
            CLR         D3
            MOVE.B      D4,D2
            MOVE.B      D5,D3
        
            JSR         printEA
        
        
            LEA        	newLine, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call            


            BRA         LOOP                ; go back to the loop

opNEG   
            LEA         NEGmatch, A1        ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
        
        
            MOVE.B      (A0)+, D1
            MOVE.B      D1,D2               ; copy data over
            ASR         #six,D2
            
            CMP         #zero,D2
            BEQ         opNEGB
            CMP         #one,D2
            BEQ         opNEGW
            CMP         #two,D2
            BEQ         opNEGL
            BRA         invalid
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
            
            CLR         D3
            MOVE        D1,D3
            AND         #seven,D3
        
            JSR         printEA
                
            LEA        	newLine, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
        
            BRA         LOOP
                

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
        
            CLR         D3
            MOVE        D1,D3
            AND         #seven,D3
        
            JSR         printEA
                    
            LEA        	newLine, A1         ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
        
            BRA         LOOP
        

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
        
            CLR         D3
            MOVE        D1,D3
            AND         #seven,D3
        
            JSR         printEA
            
            LEA        	newLine, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
        
            BRA         LOOP

opRTSJSR
        
            MOVE.B      (A0)+, D1
            
            MOVE.B      D1,D2               ; copy data over
            CMP         #117,D2
            BEQ         opRTS
            
            ASR         #six,D2             ; Moving bits over to check if it matches the two static bits in JSR
            CMP         #two,D2             ; Checking if it is JSR
            BEQ         opJSR               ; It is equal, so branch off to opJSR

            BRA         invalid

opJSR
                      
            LEA         JSRMatch, A1       ; we know that the opcode will be JSR, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA         space, A1           ; we know that the opcode will be NEG, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            CLR         D2
            CLR         D3
            
            MOVE.B      D1,D2
            ASR         #three,D2
            AND         #seven,D2
            
            MOVE.B      D1,D3
            AND         #seven,D3
            
            JSR         printEA
            
            LEA        	newLine, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call  
            
            BRA         loop            
opRTS

            LEA         RTSMatch, A1       ; we know that the opcode will be RTS, so load A1 to print message
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call
            
            LEA        	newLine, A1           ; Display space
            MOVE.B      #14, D0             ; command for trap call to display message
            TRAP        #15                 ; trap call 
            
            BRA         loop

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
        LEA         space, A1           ; create spaces
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        ASL         #eight, D1
        MOVE.B      (A0)+, D1
        
        CLR         D2
        CLR         D3
        MOVE.B      D1, D2
        ASR         #three, D2
        AND         #seven, D2
        MOVE.B      D1, D3
        AND         #seven, D3
        
        JSR         printEA
        
        LEA         comma, A1           ; create comma
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        CLR         D2
        CLR         D3
        MOVE.W      D1, D3
        ASR         #eight, D3
        ASR         #one, D3
        AND         #seven, D3

        JSR         printEA
        
        LEA         newLine, A1           ; create new line
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP
        
opADDB  LEA         ADDmatch, A1       ; we know that the opcode will be MULS, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         dispByte, A1        ; display byte
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        LEA         space, A1           ; create spaces
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1, D2
        ASR         #three, D2
        AND         #seven, D2
        MOVE.B      D1, D3
        AND         #seven, D3
        
        JSR         printEA
        
        LEA         comma, A1           ; create comma
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        CLR         D2
        CLR         D3
        MOVE.W      D1, D3
        ASR         #eight, D3
        ASR         #one, D3
        AND         #seven, D3

        JSR         printEA
        
        LEA         newLine, A1           ; create new line
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP
        
opADDW  LEA         ADDmatch, A1       ; we know that the opcode will be MULS, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; display word
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        LEA         space, A1           ; create spaces
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1, D2
        ASR         #three, D2
        AND         #seven, D2
        MOVE.B      D1, D3
        AND         #seven, D3
        
        JSR         printEA
        
        LEA         comma, A1           ; create comma
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        CLR         D2
        CLR         D3
        MOVE.W      D1, D3
        ASR         #eight, D3
        ASR         #one, D3
        AND         #seven, D3

        JSR         printEA
        
        LEA         newLine, A1           ; create new line
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP
        
opADDL  LEA         ADDmatch, A1       ; we know that the opcode will be MULS, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         dispLong, A1        ; display long
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        LEA         space, A1           ; create spaces
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1, D2
        ASR         #three, D2
        AND         #seven, D2
        MOVE.B      D1, D3
        AND         #seven, D3
        
        JSR         printEA
        
        LEA         comma, A1           ; create comma
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        CLR         D2
        CLR         D3
        MOVE.W      D1, D3
        ASR         #eight, D3
        ASR         #one, D3
        AND         #seven, D3

        JSR         printEA
        
        LEA         newLine, A1           ; create new line
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP

opADDAW LEA         ADDAmatch, A1       ; we know that the opcode will be MULS, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         dispWord, A1        ; display word
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        LEA         space, A1           ; create spaces
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1, D2
        ASR         #three, D2
        AND         #seven, D2
        MOVE.B      D1, D3
        AND         #seven, D3
        
        JSR         printEA
        
        LEA         comma, A1           ; create comma
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        CLR         D2
        CLR         D3
        MOVE.B      #one, D2
        MOVE.W      D1, D3
        ASR         #eight, D3
        ASR         #one, D3
        AND         #seven, D3

        JSR         printEA
        
        LEA         newLine, A1           ; create new line
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP

opADDAL LEA         ADDAmatch, A1       ; we know that the opcode will be MULS, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; display long
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        LEA         space, A1           ; create spaces
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1, D2
        ASR         #three, D2
        AND         #seven, D2
        MOVE.B      D1, D3
        AND         #seven, D3
        
        JSR         printEA
        
        LEA         comma, A1           ; create comma
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        CLR         D2
        CLR         D3
        MOVE.B      #one, D2
        MOVE.W      D1, D3
        ASR         #eight, D3
        ASR         #one, D3
        AND         #seven, D3

        JSR         printEA
        
        LEA         newLine, A1           ; create new line
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP
        
opASL   LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         dispWord, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         space, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1,D2
        MOVE.B      D1,D3
        
        ASR.B       #three, D2
        AND         #seven, D2
        AND         #seven, D3        
        
        JSR         printEA
        
        LEA        	newLine, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP

opASR   LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         dispWord, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         space, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1,D2
        MOVE.B      D1,D3
        
        ASR.B       #three, D2
        AND         #seven, D2
        AND         #seven, D3        
        
        JSR         printEA
        
        LEA        	newLine, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP

opLSL   LEA         LSLmatch, A1        ; we know that the opcode will be LSL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         dispWord, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         space, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1,D2
        MOVE.B      D1,D3
        
        ASR.B       #three, D2
        AND         #seven, D2
        AND         #seven, D3        
        
        JSR         printEA
        
        LEA        	newLine, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP

opLSR   LEA         LSRmatch, A1        ; we know that the opcode will be LSR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         dispWord, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         space, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1,D2
        MOVE.B      D1,D3
        
        ASR.B       #three, D2
        AND         #seven, D2
        AND         #seven, D3        
        
        JSR         printEA
        
        LEA        	newLine, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP

opROL   LEA         ROLmatch, A1        ; we know that the opcode will be ROL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         dispWord, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         space, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1,D2
        MOVE.B      D1,D3
        
        ASR.B       #three, D2
        AND         #seven, D2
        AND         #seven, D3        
        
        JSR         printEA
        
        LEA        	newLine, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP

opROR   LEA         RORmatch, A1        ; we know that the opcode will be ROR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         dispWord, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         space, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1,D2
        MOVE.B      D1,D3
        
        ASR.B       #three, D2
        AND         #seven, D2
        AND         #seven, D3        
        
        JSR         printEA
        
        LEA        	newLine, A1           ; Display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP
        
memSB   CLR         D2
        MOVE.B      D1,D2
        ASR         #three, D2
        
        AND         #$07, D2
        
        CMP.B       #zero, D2
        BEQ         opASBI
        CMP.B       #four, D2
        BEQ         opASBR
        CMP.B       #one, D2
        BEQ         opLSBI
        CMP.B       #five, D2
        BEQ         opLSBR
        CMP.B       #three, D2
        BEQ         opROBI
        CMP.B       #seven, D2
        BEQ         opROBR
        BRA         printInvalid
        
opASBI  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opASRBI
        CMP.B       #one, D2
        BEQ         opASLBI
        BRA         printInvalid
        
opASRBI LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opASLBI LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opASBR  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opASRBR
        CMP.B       #one, D2
        BEQ         opASLBR
        BRA         printInvalid 
        
opASRBR LEA         ASRmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

opASLBR LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

opLSBI  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opLSRBI
        CMP.B       #one, D2
        BEQ         opLSLBI
        BRA         printInvalid 
        
opLSRBI LEA         LSRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP


opLSLBI LEA         LSLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP


opLSBR  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opLSRBR
        CMP.B       #one, D2
        BEQ         opLSLBR
        BRA         printInvalid 
        
opLSRBR LEA         LSRmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP
        
opLSLBR LEA         LSLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP



opROBI  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opRORBI
        CMP.B       #one, D2
        BEQ         opROLBI
        BRA         printInvalid 
        
opRORBI LEA         RORmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opROLBI LEA         ROLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opROBR  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opRORBR
        CMP.B       #one, D2
        BEQ         opROLBR
        BRA         printInvalid     
        
opRORBR LEA         RORmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

opROLBR LEA         ROLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispByte, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP       

memSW   CLR         D2
        MOVE.B      D1,D2
        ASR         #three, D2
        
        AND         #$07, D2
        
        CMP.B       #zero, D2
        BEQ         opASWI
        CMP.B       #four, D2
        BEQ         opASWR
        CMP.B       #one, D2
        BEQ         opLSWI
        CMP.B       #five, D2
        BEQ         opLSWR
        CMP.B       #three, D2
        BEQ         opROWI
        CMP.B       #seven, D2
        BEQ         opROWR
        BRA         printInvalid
        
opASWI  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opASRWI
        CMP.B       #one, D2
        BEQ         opASLWI
        BRA         printInvalid
        
opASRWI LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opASLWI LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opASWR  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opASRWR
        CMP.B       #one, D2
        BEQ         opASLWR
        BRA         printInvalid 
        
opASRWR LEA         ASRmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

opASLWR LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

opLSWI  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opLSRWI
        CMP.B       #one, D2
        BEQ         opLSLWI
        BRA         printInvalid 
        
opLSRWI LEA         LSRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP


opLSLWI LEA         LSLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP


opLSWR  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opLSRWR
        CMP.B       #one, D2
        BEQ         opLSLWR
        BRA         printInvalid 
        
opLSRWR LEA         LSRmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP
        
opLSLWR LEA         LSLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP



opROWI  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opRORWI
        CMP.B       #one, D2
        BEQ         opROLWI
        BRA         printInvalid 
        
opRORWI LEA         RORmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opROLWI LEA         ROLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opROWR  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opRORWR
        CMP.B       #one, D2
        BEQ         opROLWR
        BRA         printInvalid     
        
opRORWR LEA         RORmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

opROLWR LEA         ROLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispWord, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

memSL   CLR         D2
        MOVE.B      D1,D2
        ASR         #three, D2
        
        AND         #$07, D2
        
        CMP.B       #zero, D2
        BEQ         opASLI
        CMP.B       #four, D2
        BEQ         opASLR
        CMP.B       #one, D2
        BEQ         opLSLI
        CMP.B       #five, D2
        BEQ         opLSLR
        CMP.B       #three, D2
        BEQ         opROLI
        CMP.B       #seven, D2
        BEQ         opROLR
        BRA         printInvalid
        
opASLI  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opASRLI
        CMP.B       #one, D2
        BEQ         opASLLI
        BRA         printInvalid
        
opASRLI LEA         ASRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opASLLI LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opASLR  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opASRLR
        CMP.B       #one, D2
        BEQ         opASLLR
        BRA         printInvalid 
        
opASRLR LEA         ASRmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

opASLLR LEA         ASLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

opLSLI  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opLSRLI
        CMP.B       #one, D2
        BEQ         opLSLLI
        BRA         printInvalid 
        
opLSRLI LEA         LSRmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP


opLSLLI LEA         LSLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP


opLSLR  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opLSRLR
        CMP.B       #one, D2
        BEQ         opLSLLR
        BRA         printInvalid 
        
opLSRLR LEA         LSRmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP
        
opLSLLR LEA         LSLmatch, A1        ; we know that the opcode will be ASL, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP



opROLI  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opRORLI
        CMP.B       #one, D2
        BEQ         opROLLI
        BRA         printInvalid 
        
opRORLI LEA         RORmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opROLLI LEA         ROLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntImm
        
        BRA         LOOP

opROLR  CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        AND         #$01, D2
    
        CMP.B       #zero, D2
        BEQ         opRORLR
        CMP.B       #one, D2
        BEQ         opROLLR
        BRA         printInvalid     
        
opRORLR LEA         RORmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP

opROLLR LEA         ROLmatch, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call

        LEA         dispLong, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        JSR         PrntReg
        
        BRA         LOOP
* The following subroutine displays the immediate number to shift and the data register that is being shifted. 
* This subroutine calls two printing immediate subroutine first, the the ea print subroutine.        
PrntImm MOVEM.L D0-D7/A1-A6, -(SP)
        
        LEA         space, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        LEA         hashTag, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        MOVE.W      D1, D2
        ASR         #eight, D2
        ASR         #one, D2
        AND         #$07, D2
        
        JSR         MemShiftImm
        
        LEA         comma, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1,D3
        AND         #$07, D3
        
        JSR         printEA
        
        LEA         newLine, A1        ; we know that the opcode will be ASR, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        MOVEM.L  (SP)+, D0-D7/A1-A6
        RTS
* The following subroutine determines the correct data register to display, and sets the values of D2 and D3 accordingly to display the data register.
* after setting the values, it calls another subroutine to actually display the data register.        
PrntReg MOVEM.L D0-D7/A1-A6, -(SP)
        
        LEA         space, A1           ; display space
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.W      D1, D3
        ASR         #eight, D3
        ASR         #one, D3
        AND         #$07, D3
        
        JSR         printEA
        
        LEA         comma, A1           ; display comma
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        CLR         D2
        CLR         D3
        MOVE.B      D1,D3
        AND         #$07, D3
        
        JSR         printEA
        
        LEA         newLine, A1         ; newline
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        MOVEM.L  (SP)+, D0-D7/A1-A6
        RTS
* The following subroutine is used to display the number between 1-8 for the bit vount for the shift/rotate opcode
* It displays it by storing the appropriate number in D1 and running trap task 3.        
MemShiftImm     MOVEM.L D0-D7/A1-A6, -(SP)      ;caller saved data
                CLR     D1
                
                MOVE.B  D2, D1
                CMP.B   #zero, D1
                BEQ     displayEight
                
                MOVE.B  #3, D0
                TRAP    #15
                BRA     endSubroutine
                
displayEight    MOVE.B  #$08, D1
                MOVE.B  #3, D0
                TRAP    #15                
endSubroutine
                MOVEM.L  (SP)+, D0-D7/A1-A6     ; recall data
                RTS                             ; Return to main routine
        

***********************************************************************************************************
*
* 											EA Print Check
*
***********************************************************************************************************
printEA 	MOVEM.L  D0-D7/A1-A6, -(SP)

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
***********************************************************************************************************
* Display Hex

pHex        CMP.B       #zero, D3
            BEQ         AbsShort
            CMP.B       #one, D3
            BEQ         AbsLong
            CMP.B       #four, D3
            BEQ         DispImm
            
AbsShort    LEA         opPer, A1           ; Display space
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
            
AbsLong     LEA         opPer, A1           ; Display space
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

DispImm     LEA         hashTag, A1         ; Display space
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

            BRA         endSub
invalid

endSUB
        
            MOVEM.L  (SP)+, D0-D7/A1-A6
            RTS

***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************

*this subroutine displays hex code stored in D1. It displays based on the number of 
*It displays based on the number of hex to display which is stored in D0. If it is a
*long or word to display, it will figure out the ascii character and add $37 if it
*is a letter, and $30 if its a number. It will then load the character into D1 and 
*display it via trap task 6 and loop however many times is needed, 4 or 8. If a word
*needs to be displayed, it will roll the bits over so that, the hex are shifted by a word.
outHex      MOVEM.L D0-D7/A1-A6, -(SP)
            CLR     D3
            CLR     D4
            MOVE.B  D0, D4
            MOVE.L  D1, D3
            CMP.B   #4, D0
            BEQ     moveOver
            BRA     dispLOOP
            
moveOver    ROL.L   #8,D3
            ROL.L   #8,D3
            
dispLOOP    CMP.B   #0, D4
            BEQ     endDispSub
            ROL.L   #4, D3
            CLR     D5
            MOVE.B  D3, D5 
            AND.L   #$0F, D5
            CMP.B   #10, D5
            BLT     DLnine
            BRA     DLetters
            
DLnine      ADD     #$30, D5
            CLR     D1
            MOVE.B  D5, D1
            CLR     D0
            MOVE.B  #6, D0
            TRAP    #15
            SUB     #1, D4
            BRA     dispLOOP  
 
DLetters    ADD     #$37, D5
            CLR     D1
            MOVE.B  D5, D1
            CLR     D0
            MOVE.B  #6, D0
            TRAP    #15
            SUB     #1, D4
            BRA     dispLOOP        

endDispSub  MOVEM.L  (SP)+, D0-D7/A1-A6
            RTS

*the following subroutine gets the string address from the user
*and converts it to Hex for a starting/ending address. it is done 
*by checking each byte at address A1, and converting it from ascii to 
*hex number. If the user enters an invalid character string, the
*program will have a simhalt.
Address MOVEM.L D3-D7/A2-A6, -(SP)
        CLR     D2
        CLR     D3
        CMP.B   #4, D1
        BEQ     subLOOP
        CMP.B   #8, D1
        BEQ     subLOOP
        BRA     ADDinvalid        
        
subLOOP ROR     #4, D4
        MOVE.B  D4, D2
        CLR     D4
        CLR     D5
        CMP.B   D1, D3
        BEQ     endLOOP
        ADD.W   #2, D3
        ROL.L   #8, D2
        
bytLOOP ROL     #4, D4
        
        CMP.B   #$30, (A1)
        BEQ     hZero 
        CMP.B   #$31, (A1)
        BEQ     hOne
        CMP.B   #$32, (A1)
        BEQ     hTwo
        CMP.B   #$33, (A1)
        BEQ     hThree
        CMP.B   #$34, (A1)
        BEQ     hFour
        CMP.B   #$35, (A1)
        BEQ     hFive
        CMP.B   #$36, (A1)
        BEQ     hSix
        CMP.B   #$37, (A1)
        BEQ     hSeven
        CMP.B   #$38, (A1)
        BEQ     hEight
        CMP.B   #$39, (A1)
        BEQ     hNine
        CMP.B   #$41, (A1)
        BEQ     hA
        CMP.B   #$42, (A1)
        BEQ     hB
        CMP.B   #$43, (A1)
        BEQ     hC
        CMP.B   #$44, (A1)
        BEQ     hD
        CMP.B   #$45, (A1)
        BEQ     hE
        CMP.B   #$46, (A1)
        BEQ     hF 
        BRA     invalid      
hZero   MOVE.B  #$00, D4
        BRA     nextH
hOne    MOVE.B  #$10, D4
        BRA     nextH
hTwo    MOVE.B  #$20, D4
        BRA     nextH
hThree  MOVE.B  #$30, D4
        BRA     nextH
hFour   MOVE.B  #$40, D4
        BRA     nextH
hFive   MOVE.B  #$50, D4
        BRA     nextH
hSix    MOVE.B  #$60, D4
        BRA     nextH
hSeven  MOVE.B  #$70, D4
        BRA     nextH
hEight  MOVE.B  #$80, D4
        BRA     nextH
hNine   MOVE.B  #$90, D4
        BRA     nextH
hA      MOVE.B  #$A0, D4
        BRA     nextH
hB      MOVE.B  #$B0, D4
        BRA     nextH
hC      MOVE.B  #$C0, D4
        BRA     nextH
hD      MOVE.B  #$D0, D4
        BRA     nextH
hE      MOVE.B  #$E0, D4
        BRA     nextH
hF      MOVE.B  #$F0, D4

nextH   MOVE.B  (A1)+, D0
        ADD     #1, D5
        CMP.B   #2, D5
        BEQ     subLOOP
        BRA     bytLOOP
        
ADDinvalid  MOVE.B  #9,D0
            TRAP    #15
   
endLOOP MOVEM.L  (SP)+, D3-D7/A2-A6
        RTS

printInvalid
endPROG    

    SIMHALT                             ; halt simulator

startingMessage DC.B    'Enter Starting Address (in hex): ', 0
endingMessage   DC.B    'Enter Ending Address (in hex): ', 0

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

dispD       DC.B    'D',0
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
