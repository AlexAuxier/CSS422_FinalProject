*-----------------------------------------------------------
* Title      : OR Test File
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

* Put program code here
	MOVE.B		#1,D1
	MOVE.B		#2,D2
	
	OR.B		D1,D2
	
	
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
