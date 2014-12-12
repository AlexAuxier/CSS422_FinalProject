*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $4000
START:                  ; first instruction of program

    MOVEA       $5550,A0
    MOVE.L      #$12345678, D0
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
    MOVEM.L (SP)+,D2-D5/A1-A3
    MOVEM.L D5/A2,-(SP)
    MOVEM.W D0-D7/A0-A7,$5435
    MOVEM.L D0-D7/A0-A7,-(A2)
    MOVEM.L (SP)+,D2-D5/A1-A3
    MOVEM.L D5/A2,-(SP)

    MOVEM.W D0-D7/A0-A7,$5435
    MOVEM.L D0-D7/A0-A7,-(A2)
    DIVS		D2,D1
    SUB.L		D3,D6
	CMP.B		#0,D1
	OR.B		D4,D2
	EOR.W		D2,D6
	BRA			foo
	
	SUBQ.W		#1,D2
	CMP.W		D3,D2
	BLT			baconLT
	BGE			banana

foo	
	
baconLT		

banana		
	

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
