*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

* Put program code here
    MOVE.W  D2,A2
    MOVE.L #5555,(A3)
    MOVE.L (A3),(A4)
    MOVE.B  #4,D3    
    NEG.B D1
    NEG.L D3
    NEG.W (A4)
    LEA  meh,A1   
    MOVEM.L (SP)+,D0-D7/A0-A6
    MOVEM.L D0-D7/A0-A7,-(SP)
    MOVEM.L D0-D7/A0-A7,$5435
    MOVEM.W D0-D7/A0-A7,$5435
    MOVEM.L D0-D7/A0-A7,-(A2)

    *First Nibble == 0000
    ORI     #2,D1
    BCLR    #4,D2
    CMP     #3,D0
    
    *Move Test Instructions
    MOVE.B  D1,D2
    MOVEA   A2,A3
    MOVEQ   #5,D4
  
    *Add Test Instructions
    ADD.L   D4,D0
    ADDA    A0,A1
    ADD.B   D0,D4 
    JSR break   
break
    RTS
meh   
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
