*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

        MOVE.L      #$0056ABCD, D1
        MOVE.B      #8, D0
    
        JSR         dispHexWrd
        BRA         DONE
    
dispHexWrd  CLR     D3
            CLR     D4
            MOVE.B  D0, D4
            MOVE.L  D1, D3
            CMP.B   #4, D0
            BEQ     moveOver
            BRA     dispLOOP
            
moveOver    ROL.L   #8,D3
            ROL.L   #8,D3
            
dispLOOP    CMP.B   #0, D4
            BEQ     endDispSub
            ROL.L   #4, D3
            CLR     D5
            MOVE.B  D3, D5 
            AND.L   #$0F, D5
            CMP.B   #10, D5
            BLT     DLnine
            BRA     DLetters
            
DLnine      ADD     #$30, D5
            CLR     D1
            MOVE.B  D5, D1
            CLR     D0
            MOVE.B  #6, D0
            TRAP    #15
            SUB     #1, D4
            BRA     dispLOOP  
 
DLetters    ADD     #$37, D5
            CLR     D1
            MOVE.B  D5, D1
            CLR     D0
            MOVE.B  #6, D0
            TRAP    #15
            SUB     #1, D4
            BRA     dispLOOP        

endDispSub  RTS

DONE 

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
