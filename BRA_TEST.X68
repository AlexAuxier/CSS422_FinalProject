*-----------------------------------------------------------
* Title      : BRA Test File
* Written by : Alexander Auxier
* Date       : 2014-12-4
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
	BRA			codeEND

codeEND    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
