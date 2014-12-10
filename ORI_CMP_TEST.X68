*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
START:                  ; first instruction of program

* Put program code here
                ORI.B   #43,D2
                ORI.B   #52,D2
                ORI.B   #15,D2                
                ORI     #2,(A2)
                ORI.L   #99999996,(A2)

                ORI.W   #2638,D5
                ORI.L   #64 ,D1
    
    SIMHALT             ; halt simulator

* Put variables and constants here
                
    END    START        ; last line of source
                
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
