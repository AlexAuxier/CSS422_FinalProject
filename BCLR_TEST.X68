*-----------------------------------------------------------
* Title      : BCLR Test File
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
testData        EQU     $B

                ORG     $2000
START:
                BCLR    #4, D4

                SIMHALT

                END    START





*~Font name~Courier Neqqw~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
