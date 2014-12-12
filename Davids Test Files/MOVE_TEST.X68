*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program
S9
* Put program code here
    MOVEA.W  $352,A2
    MOVEA  $352,A2
    MOVEA.L $64435,A3
    MOVEA.W  A2,A1
    MOVEA  A2,A1
    MOVEA  A2,A1
    MOVEA  (A1),A5
    
    MOVEA.L  A3,A2
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
