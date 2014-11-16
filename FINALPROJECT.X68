
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
opMOVE_M    EQU     %01001
opADD       EQU     %1101             *ADD first 4 bits
*opADDA      EQU     %1101  *Skip register and look at opMode, either 011 (word) or 111 (Long)
opSUB       EQU     %1001
opSUB_Q     EQU     %0101
*opMULS     EQU     %1100 *??? 111
*opDIVS_W   EQU     %1000 *??? 111 (Word)
*opDIVS_L   EQU     %0100110001
opLEA       EQU     %0100 *??? 111
opOR        EQU     %1000     *Remainder: 3bits register, 3bits opmode, 3 EAmode, 3 EAregister
opORI       EQU     %00000000 *Remaining 8bits: 2 - size, 3 EAmode, 3 EAregister
opEOR       EQU     %1011     *Remainder: 3bits register, 3bits opmode, 3 EAmode, 3 EAregister
opNEG       EQU     %01000100
opLSL       EQU     %1110       *Remainder: 3bits count/register, 1 for left, 2 bits for size, 01, 3bits for register
opLSR       EQU     %1110       *Remainder: 3bits count/register, 0 for right, 2 bits for size, 01, 3bits for register
opASR       EQU     %1110       *Remainder: 3bits count/register, 0 for right, 2 bits for size, 1bit count register, 00, 3 register

           
            ORG    $1000
START:                                  ; first instruction of program
      
        MOVEA.L     #test_start, A0
        MOVEA.L     #test_end, A2
        
LOOP    CMP.W       #noOp, (A0)+
        BEQ         NOPCODE
        CMPA.W      A2, A0
        BGT         ENDPROG 
        BRA         LOOP
    
NOPCODE LEA         testMatch, A1
        MOVE.B      #14, D0
        TRAP        #15
        BRA         LOOP 
        
        
OPMOVE       
        

ENDPROG    

    SIMHALT                             ; halt simulator

testMatch   DC.B    'NOPCODE',CR,LF, 0   


            END    START                ; last line of source





*
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
