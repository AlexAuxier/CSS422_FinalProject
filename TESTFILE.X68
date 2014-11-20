*-----------------------------------------------------------
* Title      : Final Project Test File
* Written by : Abdul Hakim, David Trinh, Alexander Auxier
* Date       : 11/10/2014
* Description: Test code for final project
*-----------------------------------------------------------

testData    EQU     $B

    ORG    $2000
START:                  ; first instruction of program

    NOP
    NOP
    NOP
    
    *BRA1 Instructions
    ORI     #testData,D1
    BCLR    #4,D2
    CMP     #testData,D0

    SIMHALT             ; halt simulator

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
