*-----------------------------------------------------------
* Title      : ORI Test File
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
testData        EQU     $B

                ORG     $4000
START:

                ORI     #2,(A2)
                ORI.L  #99999996,(A2)


                SIMHALT

                END    START





*~Font name~Courier Neqqw~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
