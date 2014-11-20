*-----------------------------------------------------------
* Title      : BCLR Test File
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
testData        EQU     $B

                ORG     $2000
START:

                ORI     #testData,D1
                BCLR    #4, D

                SIMHALT

                END    START


*~Font name~Courier Neqqw~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
