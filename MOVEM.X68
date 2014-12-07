*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

* Put program code here

    
    MOVEM.L (SP)+,D0-D7/A0-A6
    MOVEM.L D0-D7/A0-A7,-(SP)
    MOVEM.L D0-D7/A0-A7,$5435
    MOVEM.W D0-D7/A0-A7,$5435
    MOVEM.L D0-D7/A0-A7,-(A2)

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
