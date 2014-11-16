*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR  EQU $0D
LF  EQU $0A

test_start  EQU $00002000
test_end    EQU $00002005
   
noOp        EQU %0100111001110001    
    ORG    $1000
START:                  ; first instruction of program
      
        MOVEA.L #test_start, A0
        MOVEA.L #test_end, A2
        
LOOP    CMP.W   #noOp, (A0)+
        BEQ     NOPCODE
        CMPA.W  A2, A0
        BGT     ENDPROG 
        BRA     LOOP
    
NOPCODE LEA     testMatch, A1
        MOVE.B  #14, D0
        TRAP    #15
        BRA     LOOP 
        

ENDPROG    

    SIMHALT             ; halt simulator

testMatch       DC.B 'NOPCODE',CR,LF, 0   


    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
