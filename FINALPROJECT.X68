*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR  EQU $0D
LF  EQU $0A

test_start  EQU $00002000
test_end    EQU $00002003
    
    ORG    $1000
START:                  ; first instruction of program
    
        LEA     startMessage, A1
        MOVE.B  #14, D0
        TRAP    #15
    
        MOVE.B  #4, D0
        TRAP    #15
        MOVE.L  D1, D2
    
        LEA     endMessage, A1
        MOVE.B  #14, D0
        TRAP    #15
    
        MOVE.B  #4, D0
        TRAP    #15
    
        MOVEA.L test_start, A2
        CMP.L   #$323C654A, A2
        BEQ     INVALID
        BRA     ENDPROG
    
INVALID LEA     testMatch, A1
        MOVE.B  #14, D0
        TRAP    #15 
        

ENDPROG    

    SIMHALT             ; halt simulator

startMessage    DC.B 'Give Starting Address (in hex): ', 0
endMessage      DC.B 'Give Ending Address(in hex): ', 0
testMatch       DC.B 'MOVE.B    $654A, D1', 0   


    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
