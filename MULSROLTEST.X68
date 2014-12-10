*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

    MOVEA       $5555,A0
    ADDA        #$4AAA, A0
    ADDA.L      (A1)+, A3
    MULS        #55, D0
    MULS.W      $100, D0  
    NEG.B       D1
    NEG.L       D3
    MULS        D2, D5
    ADD.B       $44, D0
    ASL         (A0)
    LSL         ($AAAA).L
    ROR         (A2)+
    ASR.B       #7,D3
    LSL.L       D6,D4
    ROL.W       #$7,D0
    ADD.L       $0400A314,D1
     

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
