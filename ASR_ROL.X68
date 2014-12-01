*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

* Put program code here
    ASL     (A0)
    LSL     ($AAAA).L
    ROR     (A2)+
    ASR.B   #4,D3
    LSL.L   D6,D4
    ROL.W   #$7,D0

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
