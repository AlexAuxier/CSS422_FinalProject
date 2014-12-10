*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

* Put program code here

    MOVE.L #5555,(A3)
    MOVE.L (A3),(A4)
    MOVE.B  #4,D3
    MOVE.W  D2,A2
    MOVE.W  #1536,A2
    MOVEM.L (SP)+,D2-D5/A1-A3
    MOVEM.L D5/A2,-(SP)
    MOVEM.W D0-D7/A0-A7,$5435
    MOVEM.L D0-D7/A0-A7,-(A2)

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



    





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
