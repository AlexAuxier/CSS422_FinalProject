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
        BRA         opBCLR              ; otherwise, branch to BCLR method; I think we should fix this, there are other posibilities
        
braOne
braTwo
braThree
braFour
braFive
braSix
braEight
braNine
braEleven
braTwelve
braThirteen
braFourteen

opORI   LEA         ORImatch, A1        ; we know that the opcode will be ORI, so load A1 to print message
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

opORI0

         
opCMPI  LEA         CMPImatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
                
        BRA         LOOP                ; go back to the loop



opBCLR  LEA         BCLRmatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP                ; go back to the loop
 
endPROG    

    SIMHALT                             ; halt simulator

newLine     DC.B    ' ', CR, LF, 0

ORImatch    DC.B    'ORI', 0
CMPImatch   DC.B    'CMPI', 0
BCLRmatch   DC.B    'BCLR', 0
 
dispByte    DC.B    '.B  ', 0
dispWord    DC.B    '.W  ', 0
dispLong    DC.B    '.L  ', 0

dispA0      DC.B    'A0', 0
dispA1      DC.B    'A1', 0
dispA2      DC.B    'A2', 0
dispA3      DC.B    'A3', 0
dispA4      DC.B    'A4', 0
dispA5      DC.B    'A5', 0
dispA6      DC.B    'A6', 0
dispA7      DC.B    'A7', 0


           END    START                ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
