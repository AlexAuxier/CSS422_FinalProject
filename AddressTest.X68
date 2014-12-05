*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR  EQU $0D
LF  EQU $0A    
    ORG    $1000
START:                  ; first instruction of program

        LEA     startingMessage, A1
        MOVE.B  #14, D0
        TRAP    #15    
    
        MOVE.B  #2, D0
        TRAP    #15
    
        JSR     Address
        MOVEA.L D2, A0
        
        LEA     endingMessage, A1
        MOVE.B  #14, D0
        TRAP    #15    
    
        MOVE.B  #2, D0
        TRAP    #15
    
        JSR     Address
        MOVEA.L D2, A2    
    
Address MOVEM.L D3-D7/A2-A6, -(SP)
        CLR     D2
        CLR     D3
        CMP.B   #4, D1
        BEQ     subLOOP
        CMP.B   #8, D1
        BEQ     subLOOP
        BRA     invalid        
        
subLOOP ROR     #4, D4
        MOVE.B  D4, D2
        CLR     D4
        CLR     D5
        CMP.B   D1, D3
        BEQ     endLOOP
        ADD.W   #2, D3
        ROL.L   #8, D2
        
bytLOOP ROL     #4, D4
        
        CMP.B   #$30, (A1)
        BEQ     hZero 
        CMP.B   #$31, (A1)
        BEQ     hOne
        CMP.B   #$32, (A1)
        BEQ     hTwo
        CMP.B   #$33, (A1)
        BEQ     hThree
        CMP.B   #$34, (A1)
        BEQ     hFour
        CMP.B   #$35, (A1)
        BEQ     hFive
        CMP.B   #$36, (A1)
        BEQ     hSix
        CMP.B   #$37, (A1)
        BEQ     hSeven
        CMP.B   #$38, (A1)
        BEQ     hEight
        CMP.B   #$39, (A1)
        BEQ     hNine
        CMP.B   #$41, (A1)
        BEQ     hA
        CMP.B   #$42, (A1)
        BEQ     hB
        CMP.B   #$43, (A1)
        BEQ     hC
        CMP.B   #$44, (A1)
        BEQ     hD
        CMP.B   #$45, (A1)
        BEQ     hE
        CMP.B   #$46, (A1)
        BEQ     hF 
        BRA     invalid      
hZero   MOVE.B  #$00, D4
        BRA     nextH
hOne    MOVE.B  #$10, D4
        BRA     nextH
hTwo    MOVE.B  #$20, D4
        BRA     nextH
hThree  MOVE.B  #$30, D4
        BRA     nextH
hFour   MOVE.B  #$40, D4
        BRA     nextH
hFive   MOVE.B  #$50, D4
        BRA     nextH
hSix    MOVE.B  #$60, D4
        BRA     nextH
hSeven  MOVE.B  #$70, D4
        BRA     nextH
hEight  MOVE.B  #$80, D4
        BRA     nextH
hNine   MOVE.B  #$90, D4
        BRA     nextH
hA      MOVE.B  #$A0, D4
        BRA     nextH
hB      MOVE.B  #$B0, D4
        BRA     nextH
hC      MOVE.B  #$C0, D4
        BRA     nextH
hD      MOVE.B  #$D0, D4
        BRA     nextH
hE      MOVE.B  #$E0, D4
        BRA     nextH
hF      MOVE.B  #$F0, D4

nextH   MOVE.B  (A1)+, D0
        ADD     #1, D5
        CMP.B   #2, D5
        BEQ     subLOOP
        BRA     bytLOOP
        
invalid MOVE.B  #9,D0
        TRAP    #15
   
endLOOP MOVEM.L  (SP)+, D3-D7/A2-A6
        RTS
    
    SIMHALT             ; halt simulator

startingMessage DC.B    'Enter Starting Address (in hex): ', 0
endingMessage   DC.B    'Enter Ending Address (in hex): ', 0


    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
