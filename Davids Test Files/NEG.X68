*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

* Put program code here
    
    NEG.B D1
    NEG.L D3
    NEG.W (A4)
    NEG.B D1
    NEG.L D3
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
