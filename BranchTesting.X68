*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

* Put program code here
			MOVE.B	#0,D0

			BRA			dispOne
	
dispOne		MOVE.B		#4,D1
			CMP.B		#1,D1
			BGE			banana
			
banana		CMP.B		#5,D1
			BLT			baconLettuceTomato
			
baconLettuceTomato
			BVC			endPoint


endPoint

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
