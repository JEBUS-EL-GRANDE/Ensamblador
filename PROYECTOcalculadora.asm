;#################################################################################### 
;#################################################################################### 
;####################################################################################                
                                                                                  ;##
TITLE CALCULADORA ARITMETICA EN ASM                                               ;##
.MODEL small                                                                      ;##
.STACK                                                                            ;##
.DATA                                                                             ;##
                                                                                  ;##
welcome db "Bienvenido >> $"                                                      ;##
inputName db "Ingresa tu nombre >> $"                                             ;##
string db 100,?,10 DUP(" ")                                                       ;##
menu db "Menu de la calculadora$"                                                 ;##
msuma db "1. SUMA$"                                                               ;##
mresta db "2. RESTA$"                                                             ;##
mmultiplicacion db "3. MULTIPLICACION$"                                           ;##
mdivision db "4. DIVISION$"                                                       ;##
msalir db "5. SALIR$"                                                             ;##
melige db "INGRESA TU OPCION >>> $"                                               ;##
opcion dw ?                                                                       ;##
m1 db "Ingresa el primer numero >> $"                                             ;##                   
m2 db "Ingresa el segundo numero >> $"                                            ;##
bye db " Hasta la vista B-) $"                                                    ;##
ms db "<< Opcion Suma >> $"                                                       ;##
mr db "<< Opcion Resta >> $"                                                      ;##
mm db "<< Opcion Multiplicacion >> $"                                             ;##
md db "<< Opcion Division >> $"                                                   ;##
mrr db "El resultado es  >>$"                                                     ;##
merr db "Ingresa un numero diferente de cero.$"                                   ;##
z1 dw 0                                                                           ;##
n2 dd 0                                                                           ;##
n3 dd 0                                                                           ;##
n4 dw 0                                                                           ;##
n5 dw 0                                                                           ;##
n6 dw 0                                                                           ;##
NC dw 0                                                                           ;##
NCD db 0                                                                          ;##
resultado dw 0                                                                    ;##
z2 db 0                                                                           ;##
z3 db 0                                                                           ;##
z4 db 0                                                                           ;##
z5 db 0                                                                           ;##
z6 db 0                                                                           ;##
mc db "Pulsa cualquier tecla para continuar ...$"                                 ;##
mreturn db "Deseas volver al menu ? $"                                            ;##
yes db "1. SI$"                                                                   ;##
no db "2 NO$"                                                                     ;##
xp db 05H                                                                         ;##
yp db 14H                                                                         ;##
;####################################################################################
;####################################################################################
;####################################################################################           
.CODE  

MAIN PROC ;INCIO

MOV AX,@DATA
MOV DS,AX
    CALL STYLE 
    CALL POINTPOSITION 
    LEA DX,inputName
    MOV AH,09h
    INT 21h     
    MOV DX, OFFSET string ;Obtiene y guarda la cadena
    MOV AH, 0ah           ;mueve la funcion 0ah para capturar la cadena
    INT 21h               
    
MENUOPC:
  
    MOV opcion,0
    MOV resultado,0
    CALL CLEARSCREEN
    ADD xp,02H
    CALL POINTPOSITION    
    LEA DX, welcome
    MOV AH,09h
    INT 21h
    MOV BL,string[1]           ;Movemos el primer byte de la cadena
    MOV string[BX+2],"$"       ;Sumamos el byte guardado + 2 para desplazarse al final
    MOV DX, OFFSET string + 2  ;Sumamos + 2 para tomar los 2 bytes primeros
    MOV AH, 09h
    INT 21h 
    LEA DX, menu
    MOV AH,09H
    ADD xp,02H
    CALL POINTPOSITION
    ADD xp,02H
    LEA DX, msuma
    MOV AH,09H
    INT 21h  
    CALL POINTPOSITION
    ADD xp,02H
    LEA DX, mresta
    MOV AH,09H
    INT 21h  
    CALL POINTPOSITION
    ADD xp,02H
    LEA DX, mmultiplicacion
    MOV AH,09H 
    INT 21h    
    CALL POINTPOSITION
    ADD xp,02H
    LEA DX, mdivision
    MOV AH,09H
    INT 21h
    CALL POINTPOSITION 
    ADD xp,02H
    LEA DX, msalir
    MOV AH,09H
    INT 21h 
    CALL POINTPOSITION
    ADD xp,02H
    LEA DX, melige
    MOV AH,09H
    INT 21h
    MOV AH,01H
    INT 21H  
    SUB AX,304
    MOV opcion,AX
    CALL OPERATION 
     
MAIN ENDP   

;-------------------------------------------------------------- [*MAIN]  

INPUTS PROC  
    
    ADD xp,02H 
    CALL POINTPOSITION
    LEA DX, m1
    MOV AH,09h
    INT 21h
    CALL INPUTN   
    
NC2:  
    MOV AX,0
    MOV AX,NC 
    MOV resultado,AX
    MOV opcion,5   
    ADD xp,02H             
    CALL POINTPOSITION 
    LEA DX, m2
    MOV AH,09h
    INT 21h
    CALL INPUTN    
    RET
    
INPUTS ENDP         

;--------------------------------------------------------------  [INPUTS]

INPUTN:

    MOV AH,01H
    INT 21H      
    SUB AX,304
    MOV n2,AX
  
    MOV AH,01H
    INT 21H
    SUB AX,304
    MOV n3,AX
    
    MOV AH,01H
    INT 21H
    SUB AX,304
    MOV n4,AX
    
    MOV AH,01H
    INT 21H
    SUB AX,304
    MOV n5,AX
    
    MOV AH,01H
    INT 21H
    SUB AX,304
    MOV n6,AX

    CALL JOINN
    RET
   
;-------------------------------------------------------------- {INPUTN:}  
JOINN:

    Mn2:  
    
        XOR AX,AX 
        CMP n2,0
        JZ Mn3 
        JL Mn3 
        MOV AX,0
        MOV AX,n2
        MOV BX,10000
        MUL BX
        MOV n2,0
        MOV n2,AX ;n2 ya tiene el numero convertido * 10000
    
    Mn3:   
    
        XOR AX,AX 
        CMP n3,0
        JZ Mn4
        MOV AX,00
        MOV AX,n3
        MOV BX,1000
        MUL BX
        MOV n3,0
        MOV n3,AX ;n3 ya tiene el numero convertido * 1000
    
    Mn4:
    
        XOR AX,AX 
        CMP n4,0
        JZ Mn5
        MOV AX,00
        MOV AX,n4
        MOV BX,100
        MUL BX
        MOV n4,0
        MOV n4,AX ;n4 ya tiene el numero convertido * 100
    
    Mn5:
    
        XOR AX,AX 
        CMP n5,0
        JZ assembler
        MOV AX,00
        MOV AX,n5
        MOV BX,10
        MUL BX
        MOV n5,0
        MOV n5,AX ;n5 ya tiene el numero convertido * 10  
        
    assembler:
    
        XOR AX,AX

        MOV AX,n2
        MOV NC,0 
        CMP n2,0
        JL  pastTon3
        ADD NC,AX
        MOV AX,0  
        
    pastTon3:        

        MOV AX,n3
        ADD NC,AX
        MOV AX,0
        
        MOV AX,n4
        ADD NC,AX
        MOV AX,0
        
        MOV AX,n5
        ADD NC,AX
        MOV AX,0  
        
        MOV AX,n6
        ADD NC,AX   ;65535 numero maximo   
        XOR AX,AX
        MOV AX,n2     
        CMP n2,0
        JL  convertNegative
        
        MOV n2,0
        MOV n3,0
        MOV n4,0
        MOV n5,0
        MOV n6,0  
        
        RET  
        
convertNegative: 
     
       MOV AX,n2
       ADD n2,2  
       
       MOV AX,0
       MOV AX,n2
       MOV BX,NC
       MUL BX   

       MOV NC,0
       MOV NC,AX
       RET

;--------------------------------------------------------------  [JOINN:]

CLEARSCREEN PROC   
                      
    MOV xp,03H
    MOV AH,0FH
    INT 10H
    MOV AH,0
    INT 10H  
    RET
    
CLEARSCREEN ENDP        
;_________________________________________________________________  [CLEARSCREEN]

STYLE PROC NEAR
      ;  25 rows & 80 columns
            MOV AX,0600H
            MOV BH,00AH 
            MOV CX,000H
            MOV DX,484FH
            INT 10H
            RET      
            
STYLE ENDP
    
;-------------------------------------------------------------- [STYLE]

STYLEERR PROC NEAR
      ;  25 rows & 80 columns
            MOV AX,0600H
            MOV BH,004H 
            MOV CX,000H
            MOV DX,484FH
            INT 10H
            RET      
            
STYLEERR ENDP
;--------------------------------------------------------------  [STYLEERR]
POINTPOSITION PROC  
    
    MOV AH,02H 
    MOV BH,00H  
    MOV DH,xp
    MOV DL,yp
    INT 10H     
    RET        
    
POINTPOSITION ENDP   

;-------------------------------------------------------------- [POINTPOSITION]

OPERATION PROC 
       
    CMP opcion,1
    JZ SUMA 
    JL MENUOPC   
    CMP opcion,2 
    JZ RESTA
    CMP opcion,3    
    JZ MULT
    CMP opcion,4 
    JZ DIVI
    CMP opcion,5 
    JZ exit 
    JG MENUOPC
    
OPERATION ENDP 
;--------------------------------------------------------------  [OPERATION]
SUMA PROC 
     
    CALL CLEARSCREEN 
    CALL POINTPOSITION    
    LEA DX, ms
    MOV AH,09h
    INT 21h   
    S2: 
    CALL INPUTS   
    MOV AX,NC 
    ADD resultado,AX     
    ADD xp,02H
    CALL POINTPOSITION   
    MOV AH,9
    LEA DX, mrr
    INT 21h 
    CALL CONVERTN
    CALL CLEARSCREEN
    CALL TRYAGAIN 
    
SUMA ENDP
;--------------------------------------------------------------  [SUMA]
RESTA PROC 
    
    CALL CLEARSCREEN 
    CALL POINTPOSITION        
    LEA DX, mr
    MOV AH,09h
    INT 21h  
    CALL POINTPOSITION 
    R2:    
    CALL INPUTS      
    MOV AX,NC 
    SUB resultado,AX
    ADD xp,02H
    CALL POINTPOSITION 
    MOV AH,9
    LEA DX, mrr
    INT 21h 
    CALL CONVERTN
    CALL CLEARSCREEN
    CALL TRYAGAIN
    
RESTA ENDP
;-------------------------------------------------------------- [RESTA]
MULT PROC   
    
    CALL CLEARSCREEN 
    CALL POINTPOSITION    
    LEA DX, mm
    MOV AH,09h
    INT 21h   
    ML2: 
    CALL INPUTS 
    MOV AX,0
    MOV AX,NC
    MOV BX,resultado 
    MUL BX   
    MOV resultado,0
    MOV resultado, AX   
    ADD xp,02H
    CALL POINTPOSITION 
    MOV AH,9
    LEA DX, mrr
    INT 21h 
    CALL CONVERTN
    CALL CLEARSCREEN
    CALL TRYAGAIN
    
MULT ENDP
;--------------------------------------------------------------  [MULT]
DIVI PROC
    
    CALL CLEARSCREEN 
    CALL POINTPOSITION   
    LEA DX, md
    MOV AH,09h
    INT 21h   
    D2: 
    CALL INPUTS 
    XOR DX,DX
    MOV AX, resultado
    MOV BX, NC  
    CMP NC,0
    JZ ZEROERR
    DIV BX  
    MOV resultado,0
    MOV resultado, AX  
    ADD xp,02H
    CALL POINTPOSITION  
    MOV AH,9
    LEA DX, mrr
    INT 21h 
    CALL CONVERTN
    CALL CLEARSCREEN
    CALL TRYAGAIN
    
DIVI ENDP

;--------------------------------------------------------------  [DIVI]

ZEROERR PROC
           
    CALL CLEARSCREEN 
    CALL POINTPOSITION 
    CALL STYLEERR      
    MOV AH,9
    LEA DX,merr
    INT 21h 
    ADD xp,03H
    CALL POINTPOSITION 
    MOV AH,9
    LEA DX,mc
    INT 21h
    MOV AH,01H
    INT 21H
    MOV opcion,4 
    MOV NC,0  
    MOV resultado,0
    CMP resultado,0 
    CALL STYLE
    JZ OPERATION
        
ZEROERR ENDP

;--------------------------------------------------------------  [ZEROERR]
                                                               
CONVERTN PROC  
    
    XOR DX,DX
    MOV AX, resultado 
    MOV BX, 10
    DIV BX  
    MOV resultado,0
    MOV resultado, AX
    MOV z6,DL
    CMP resultado,0
    JZ PRINT  
    
    XOR DX,DX
    MOV AX,0  
    MOV AX, resultado 
    MOV BX,10
    DIV BX   
    MOV resultado,0
    MOV resultado, AX
    MOV z5,DL
    CMP resultado,0
    JZ PRINT  
    
    XOR DX,DX 
    MOV AX,0  
    MOV AX, resultado 
    MOV BX, 10
    DIV BX    
    MOV resultado,0
    MOV resultado, AX
    MOV z4,DL
    CMP resultado,0
    JZ PRINT 
    
    XOR DX,DX
    MOV AX,0  
    MOV AX, resultado 
    MOV BX, 10
    DIV BX       
    MOV resultado,0
    MOV resultado, AX
    MOV z3,DL
    CMP resultado,0
    JZ PRINT 
    
    XOR DX,DX
    MOV AX,0  
    MOV AX, resultado 
    MOV BX, 10
    DIV BX 
    MOV resultado,0
    MOV resultado, AX
    MOV z2,DL    
     
PRINT:
    
    MOV DL,z2 
    ADD DL,48 
    MOV AH,2
    INT 21h  
    
    MOV DL,0
    MOV DL,z3 
    ADD DL,48 
    MOV AH,2
    INT 21h  
     
    MOV DL,0
    MOV DL,z4 
    ADD DL,48 
    MOV AH,2
    INT 21h    
    
    MOV DL,0
    MOV DL,z5 
    ADD DL,48 
    MOV AH,2
    INT 21h 
     
    MOV DL,0   
    MOV DL,z6 
    ADD DL,48 
    MOV AH,2
    INT 21h
    
    ADD xp,02H
    CALL POINTPOSITION 
    
    MOV AH,9
    LEA DX,mc
    INT 21h 
    
    MOV AH,01H
    INT 21H  
    
    RET  
    
            ; 15250 /10, res=0, coc=1525  
            ; 1525 /10, res=5, coc=152
            ; 152 /10, res=2, coc=15 
            ; 15 /10, res=5, coc=1  
            ; 1 /10, res=1, coc=0  
                           
    
CONVERTN ENDP                                                               
;-------------------------------------------------------------- [CONVERTN]

TRYAGAIN PROC
  
    CALL CLEARSCREEN 
    CALL POINTPOSITION
    MOV AX,0
    MOV AH,9
    LEA DX,mreturn
    INT 21h 
    ADD xp,02H
    CALL POINTPOSITION 
    MOV AH,9
    LEA DX,yes
    INT 21h  
    ADD xp,02H
    CALL POINTPOSITION 
    MOV AH,9
    LEA DX,no
    INT 21h 
    ADD xp,02H
    CALL POINTPOSITION 
    MOV AH,9
    LEA DX,melige
    INT 21h 
    
    MOV AH,01H
    INT 21H 
    SUB AX,304
    MOV z1,AX
     
    CMP z1,1 
    JL TRYAGAIN
    JZ MENUOPC 
    
    CMP z1,2
    JG TRYAGAIN 
    JZ exit
    
TRYAGAIN ENDP 
;-------------------------------------------------------------- [TRYAGAIN]  

exit:        

 CALL CLEARSCREEN
 LEA DX,bye
 MOV AH,09h
 INT 21h   

.EXIT

END 

;Made by Carlos Trejo
