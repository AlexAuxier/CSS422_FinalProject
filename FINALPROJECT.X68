*-----------------------------------------------------------
* Title      :
* Written by :  Abdul Hakim, David Trinh, Alexander Auxier
* Date       :
* Description:
*-----------------------------------------------------------
CR          EQU     $0D
LF          EQU     $0A
  
test_start  EQU     $00002000
test_end    EQU     $00002005
     
zero        EQU     $0
one         EQU     $1
two         EQU     $2
three       EQU     $3
four        EQU     $4
five        EQU     $5
six         EQU     $6
eight       EQU     $8
nine        EQU     $9
eleven      EQU     $B
twelve      EQU     $C
thirteen    EQU     $D
fourteen    EQU     $E
             
            ORG    $1000
START:                                  ; first instruction of program
      
        MOVEA.L     #test_start, A0
        MOVEA.L     #test_end, A2
          
LOOP    CLR         D1
        CLR         D2
        MOVE.B      (A0)+, D1
        MOVE.B      D1, D2
        ASR.L       #four, D2
        
        CMP.B       #zero, D2
        BEQ         braZero
        CMP.B       #one, D2
        BEQ         braOne
        CMP.B       #two, D2
        BEQ         braTwo
        CMP.B       #three, D2
        BEQ         braThree
        CMP.B       #four, D2
        BEQ         braFour
        CMP.B       #five, D2
        BEQ         braFive
        CMP.B       #six, D2
        BEQ         braSix
        CMP.B       #eight, D2
        BEQ         braEight
        CMP.B       #nine, D2
        BEQ         braNine
        CMP.B       #eleven, D2
        BEQ         braEleven
        CMP.B       #twelve, D2
        BEQ         braTwelve
        CMP.B       #thirteen, D2
        BEQ         braThirteen
        CMP.B       #fourteen, D2
        BEQ         braFourteen  

braZero CLR         D2 
        MOVE.B      D1, D2
        AND.B       $0F, D2
 
        CMP.B       #zero, D2
        BEQ         braORI
        CMP.B       #twelve, D2
        BEQ         braCMPI
        BRA         braBCLR
        
braOne
braTwo
braThree
braFour
braFive
braSix
braEight
braNine
braEleven
braTwelve
braThirteen
braFourteen

braORI  LEA         ORImatch, A1
        MOVE.B      #14, D0
        TRAP        #15
      
        MOVE.B      (A0)+, D1
        MOVE.W      (A0)+, D1
        BRA         LOOP 
        
braCMPI
braBCLR
        
OPMOVE  *Lea
        *Move.B using a0+ and D0
        *Use and to check if LEA or MOVE
        *Jump to subroutine based on MOVE or LEA

 
ENDPROG    

    SIMHALT                             ; halt simulator

ORImatch    DC.B    'ORI', 0
CMPImatch   DC.B    'CMPI', 0
BCLRmatch   DC.B    'BCLR', 0
 
dispByte    DC.B    '.B  ', 0
dispWord    DC.B    '.W  ', 0
dispLong    DC.B    '.L  ', 0


           END    START                ; last line of source