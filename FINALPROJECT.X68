
*-----------------------------------------------------------
* Title      :
* Written by :  Abdul Hakim, David Trinh, Alexander Auxier
* Date       :
* Description:
*-----------------------------------------------------------
CR          EQU     $0D
LF          EQU     $0A

test_start  EQU     $00002000
test_end    EQU     $00002005
   
noOp        EQU     %0100111001110001 *NOP Binary Format

;WIP
opMOVEB     EQU     %0001
opMOVEW     EQU     %0011
opMOVEL     EQU     %0010

opADDs      EQU     %1101
*opADD       EQU     %1101             *ADD first 4 bits
*opADDA      EQU     %1101  *Skip register and look at opMode, either 011 (word) or 111 (Long)

opSUB       EQU     %1001
opSUB_Q     EQU     %0101
opMULS     EQU     %1100


opMDL       EQU     %0100
*opMOVE_M    EQU     %0100  *1
*opDIVS_L    EQU     %0100       *110001, 3bit mode, 3bit register
*opLEA       EQU     %0100  *??? 111

opDIVOR
*opDIVS_W   EQU     %1000       *3bit register, 111, 3bit, 3bit mode 3bit register 
*opOR        EQU     %1000     *Remainder: 3bits register, 3bits opmode, 3 EAmode, 3 EAregister


opNEG       EQU     %01000100

opSHIFT     EQU     %1110
*opLSL       EQU     %1110       *Remainder: 3bits count/register, 1 for left, 2 bits for size, 01, 3bits for register
-     EQU     %1110       *Remainder: 3bits count/register, 0 for right, 2 bits for size, 1bit count register, 11, 3 register


opEORCMP    EQU     %1011       *
*opEOR       EQU     %1011       *Remainder: 3bits register, 3bits opmode, 3 EAmode, 3 EAregister
*opCMP       EQU     %1011       *Remainder: 3bits register, 3 opMode, Effective Addres: 3bit mode, 3bit register

opZERO      EQU     %0000
*opCMPI      EQU     %00001100       *Remainder: 1100, 2bit size, Effective Address: 3bit mode, 3bit register
*opBCLR      EQU     %0000       *Remainder: 3bits register, 110, Effective Address: 3 mode, 3 register
*opORI       EQU     %0000 *Remaining 8bits: 2 - size, 3 EAmode, 3 EAregister

opBRA       EQU     %0110
*opBCC       EQU     %0110       *Remainder: 4bit condition, 8bit displacement
*opBRA       EQU     %0110       *Remainder: 0000, 8bit displacement

*opRTS       EQU     %0100       *111001110101
*opJSR       EQU     %0100       *Remainder: 111010, Effective Address: 3bit mode, 3bit register

firstNib    EQU     $F0
secondNib   EQU     $0F
\
           
            ORG    $1000
START:                                  ; first instruction of program
      
        MOVEA.L     #test_start, A0
        MOVEA.L     #test_end, A2
        
LOOP    MOVE.B      (A0)+, D0
        MOVE.B      D0, D1
        AND.B       #firstNib, D1
        CMP.B       #opZero, D1
        BEQ         ZERO
        
ZERO    MOVE.B      D0, D1
        AND.B       #SecondNib, D1
        CMP.B       opZero, D1
        BEQ         ORI
        
ORI     
        
        
        

        
        
    
NOPCODE LEA         testMatch, A1
        MOVE.B      #14, D0
        TRAP        #15
        BRA         LOOP 
        
        
OPMOVE  *Lea
        *Move.B using a0+ and D0
        *Use and to check if LEA or MOVE
        *Jump to subroutine based on MOVE or LEA
        

ENDPROG    

    SIMHALT                             ; halt simulator

testMatch   DC.B    'NOPCODE',CR,LF, 0   
testNum     DC.B    0000


            END    START                ; last line of source





*


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
