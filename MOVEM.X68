*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

* Put program code here

    
    MOVEM.L (SP)+,D2-D5/A1-A3
    MOVEM.L D5/A2,-(SP)
    MOVEM.L D1-D3/A5,$5435
    MOVEM.W D0-D7/A0-A7,$5435
    MOVEM.L D0-D7/A0-A7,-(A2)

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
