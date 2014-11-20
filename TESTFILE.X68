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
    
    *First Nibble == 0000
    ORI     #testData,D1
    BCLR    #4,D2
    CMP     #testData,D0
    
    *Move Test Instructions
    MOVE.B  D1,D2
    MOVEA   A2,A3
    MOVEQ   #testData,D4
  
    *Add Test Instructions
    ADD.L   D4,D0
    ADDA    A0,A1
    ADD.B   D0,D4

    SIMHALT             ; halt simulator

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
