*-----------------------------------------------------------
* Title      :  68K DECOMPILER
* Written by :  Abdul Hakim, David Trinh, Alexander Auxier
* Date       :  11/26/2014
* Description:  Decompiles certain opCodes loaded into defined locations
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
        CMPA.L      A0, A2              ; compare starting and ending addresses
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

braZero CLR         D2                  ; first nibble is 0, 3 opcodes are possible 
        MOVE.B      D1, D2              ; clear out D2 and copy D1 back in
        AND.B       $0F, D2             ; set first nibble to 0
 
        CMP.B       #zero, D2           ; compare second nibble to 0
        BEQ         opORI               ; branch to ORI method
        CMP.B       #twelve, D2         ; compare second nibble to 12
        BEQ         opCMPI              ; branch to CMPI method
        BRA         opBCLR              ; otherwise, branch to BCLR method
        
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
        BRA         LOOP                ; go back to the loop
        
opCMPI  LEA         CMPImatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
        BRA         LOOP                ; go back to the loop

opBCLR  LEA         BCLRmatch, A1       ; we know that the opcode will be CMPI, so load A1 to print message
        MOVE.B      #14, D0             ; command for trap call to display message
        TRAP        #15                 ; trap call
        
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

endPROG    

    SIMHALT                             ; halt simulator

newLine     DC.B    ' ', CR, LF, 0
space       DC.B    '  ', 0

hashTag     DC.B    '#', 0
dispHex     DC.B    '$', 0

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
