;
; Hecho para procesadores 8086 para compilarlo en emu8086
	format MZ					; multi segmento
	use16 						; 16bits bin
	entry			main:start	; puntos de entrada para el exe
	stack			100h		;  tamano (256)
	include 'macro/proc32.inc'

;
; constantes
;
    PLAYER_NAME_SIZE    equ 33   ; 32 bytes para o nombre +1 para o $
    P1_CHAR             equ 0Ah  ; x
    P1_COLOR            equ 0Ah  ; blanco
    P2_CHAR             equ 0Ah  ; o    
    P2_COLOR            equ 0Ah  ; luz azul    
    GAME_TEXT_COLOR     equ 0Ah  ; luz verde  
    GAME_TEXT_SHADOW    equ 0Ah  ; gris oscuro        
    GAME_TEXT_SUCCESS   equ 0Ah  ; luz verde
    GAME_TEXT_ERRO      equ 0Ah  ; luz roja

	SYMBOL_LIGHT_SMILE	equ	01h
	SYMBOL_DARK_SMILE	equ	02h
	SYMBOL_HEART		equ 03h
	SYMBOL_DIAMOND		equ 04h
	SYMBOL_CLUBS		equ 05h
	SYMBOL_SPADES		equ 06h 
	SYMBOL_MALE			equ 0Ch
	SYMBOL_FEMALE		equ 0Bh
	SYMBOL_X			equ 78h
	SYMBOL_O			equ 6Fh

; estados del juego
    ST_MENU            equ 0h ; menu inicial
    ST_JOGANDO         equ 1h ; cuando estamos jugando
    ST_GAME_OVER       equ 2h ; cuando perdemos  
    ST_VITORIA         equ 3h  

segment text
; variables
    player_1            DB P1_CHAR, P1_COLOR, "Jugador 1                        $"
    player_2            DB P2_CHAR, P2_COLOR, "Jugador 2                        $"
    
    game_state          DB 0  ; 0 = menu, 1 = jugando, 2 = fin del juego
    current_player      DB 1      
    current_color       DB 0
    current_char        DB 0
    new_line            DB 13,10,"$" ; nueva linea de chars    
    game_over_message   DB "GAME OVER", 13, 10, "$"        
    str_game_divider    DB '-------------------------------------------------------------------------------$'
    str_game_header     DB '     [UNIVERSIDAD AUTONOMA GABRIEL RENE MORENO, FACULTAD INTEGRAL DEL CHACO]     $'
    grid                DB 9 DUP(0)  
    grid_buffer         DB '                                     |   |   ', 13, 10
                        DB '                                  ---+---+---', 13, 10
                        DB '                                     |   |   ', 13, 10
                        DB '                                  ---+---+---', 13, 10
                        DB '                                     |   |   ', 13, 10, '$'                                                
    str_player1_set_name  	DB 'Jugador 1, escribe tu nombre : $' 
    str_player2_set_name  	DB 'Jugador 2, escribe tu nombre : $' 
    str_player_set_color 	DB 'Elige tu color               : $'
    str_player_set_char  	DB 'Elige tu simbolo             : $'
	str_ftr_cores       	DB 'Colores   : 1.Blanco 2.Azul 3.Verde 4.Rojo$'
    str_ftr_simbolos     	DB 'Simbolos  : 1.', 01   ; sorriso claro
                                   DB ' 2.', 02    ; sorriso escuro
                                   DB ' 3.', 03    ; copa
                                   DB ' 4.', 04    ; gusano
                                   DB ' 5.', 05    ; paus
                                   DB ' 6.', 06    ; espadas
                                   DB ' 7.', 11    ; macho  
                                   DB ' 8.', 12    ; fêmea
                                   DB ' 9.x 0.o  $'
    
    str_ok              DB 'Muy bien!$'
    str_iniciando       DB 'Iniciando...$'
    str_type_position   DB ', Elige una posicion : $'
    str_vitoria         DB 'VICTORIA!!!', 13, 10
                        DB 'El jugador $' 
    str_votoria_suf     DB ' ha ganado!$' ; jugador ganador;
    str_game_over       DB 'Fin del juego!', 13, 10
                        DB 'TIE!$'   
    str_bye             DB ' $'              
  

segment main    

;  esta macro imprime un caracter en AL
;  posicion del cursor:
macro putc char {
	push    ax
	mov     al, byte char
	mov     ah, 0Eh
	int     10h     
	pop     ax
}


; dx = endereço do texto
; bx = cor 
; cx = o número de caracteres a colorir
macro print texto, tamanho, cor{
    mov     dx, word texto
    mov     cx, tamanho 
    mov     bx, cor    
    mov     ax, 0920h           ; AH= funcion de numero para espacio  
    int     10h                 ; INT 10h/AH=9 - Escribe el caracter y atribuye a la posicion del cursor
    int     21h                 ; INT 21h/AH=9 - Salida de una cadena a DS:DX, deberia terminar por '$'
}


start:    
; set segment registers
    mov     ax, text        ;  carga el segmento de datos de direcciones en ax
    mov     ds, ax          ; envia los datos al segmento
    
; enable mode 3h (16 colors 80 x 25)
; setup_screen 
    mov     ax, 1003h   
    mov     bx, 0
    int     10h    
    
    main_loop:  
        call    clear_screen
        call    draw_scene
        jmp     main_loop
          
    
    return_to_os:
        print   str_bye, 10, GAME_TEXT_COLOR      ; resetea el color de consola    
        
        mov     ax, 4C00h                       ; al = si devuelve = 0 ; no hay errores       
        
        ;call clear_screen ;limpiamos pantalla
        
        ;jmp ds_menu      ;llamamos al menu otra vez
        
        
        
        jmp main_loop  ;REPETICION DE JUGADA GANADORA
        int 16h
                     
        int     21h                             ;INT 21h / AH=4Ch -   devuelve el control del operador del sistema   
        
        ret
        
           
       
; envia el video al modo 03 
; apaga el buffer de la tecla
;   ah = 0 (envia el video al modo function)
;   al = 3 (modo de texto) 80 x 25 16 colores                                           
clear_screen:
    mov     ax, 0003h     
    int     10h         
    ret

                                        
; lee el teclado y devuelve el contenido en ah   
get_key:
    mov     ah, 1       
    int     21h    
    mov     ah, 0
    ret     

    
macro gotoXY linha, coluna{
    push    ax
    push    bx
    push    dx    
; configura parmetros de flujo 
    mov     ah, 02h    
    mov     bh, 0      
    mov     dh, coluna
    mov     dl, linha
    int     10h             ;datos de flujo         
; restaurando los registros
    pop     dx    
    pop     bx
    pop     ax
}


macro print_addr texto, position, tamanho, cor{
    mov     dx, texto
    add     dx, position  
    mov     cx, tamanho 
    mov     bx, cor    
    mov     ax, 0920h           ; AH=Funcion numero AL=Espacio del caracter  
    int     10h                 ; funcion del BIOS
    int     21h                 ; funcion del DOS
}


;
; el caracter debe estar registrado
;
proc print_char 	
    cmp     al, 0
    je      print_char_exit
    
    push    bx
    push    cx                 

    mov     ah, 9h              ; function 9h escribe el caracter y atribuye al cursor de posicion.        
    mov     bh, 0               ; numero de pagina
    mov     bl, [current_color] ; color atributo
    mov     cx, 1               ; number of ciclos para imprimir el char
    int     10h                 ; llama la funcion
                                
    pop     cx
    pop     bx
                
	print_char_exit:
    ret
endp

beep:
    push dx
    push ax
    
    mov dl, 07h
    mov ah, 2    
    int 21h
    
    pop ax
    pop dx
    
    ret
    
;
;  la ultima posicion del teclado y guarda en donde esta
; (deve ser un numero de 1 a 9)
; 
;macro
le_jogada:
	inicio:    
		call    get_key                    ; la jugada en ah
		cmp     al, 31h       
		jl      invalido                   ; o valor debe estar entre 1 y 9 (31h e 39h en ascii)
		cmp     al, 39h                    ; vamos validar con 2 cmp's
		jg      invalido
		
		sub     al, 31h                   ; convierte en ascii no indice o grid
		mov     si, grid                  ; carrega o endereço do grid em si        
		add     si, ax                    ; desloca di até a posição selecionada 	
		
		;  aqui tenemos un indice mas grande?   
		cmp     byte[ds:si], 0                  		
		jne     invalido    
		
		; configura el jogador
		cmp     [current_player], 1
		jne     set_p2_grid_char
		jmp     set_p1_grid_char

	set_p1_grid_char:
		mov     bl, [player_1+0]
		mov     [ds:si], bl                 ; guarda la jugada en la posicion de la  tabla            
		jmp     return
		
	set_p2_grid_char:    
		mov     bl, [player_2+0]
		mov     [ds:si], bl                 ; guarda la jugada en la posicion correta de la tabla        
		jmp     return
		
	invalido:
	   call beep        
	   call clear_last_char   
	   jmp  inicio

	return:
		ret

   
;
; selecciona un simbolo de la cinta de opciones
; los valores pueden ser de 0 a 9
; retorna en al
select_player_symbol:
	read_symbol:        
		call    get_key                 ; obtiene letra    
		cmp     al, 30h
		jl      invalid_symbol
		cmp     al, 39h
		jg      invalid_symbol     
		sub     al, 30h                  ; convierte a ascii em     		
		
;   el simbolo de seleccion es valido y ajustamos el codigo
; forma 1 a 6 esta lista ahora
		cmp		al, 0
		je		set_symbol_0
		cmp		al, 7
		je		set_symbol_male
		cmp		al, 8
		je		set_symbol_female
		cmp		al, 9
		je		set_symbol_x
		jmp 	invalid_symbol
		
	set_symbol_x:
		mov		al, SYMBOL_X
		jmp 	select_player_symbol_return
		
	set_symbol_0:		
		mov		al, SYMBOL_O
		jmp 	select_player_symbol_return
		
	set_symbol_male:
		mov		al, SYMBOL_MALE
		jmp 	select_player_symbol_return
		
	set_symbol_female:
		mov		al, SYMBOL_FEMALE		
		jmp 	select_player_symbol_return
		
	invalid_symbol:
		call    beep
		call    clear_last_char
		jmp     read_symbol
		
	select_player_symbol_return:
		ret
       
;
; selecina un color de la lista de opciones
; los valores posibles 1 a 4
;       
select_player_color:
	read_color:
		call    get_key
		cmp     al, 31h     ; 1
		jl      invalid_color
		cmp     al, 34h     ; 4
		jg      invalid_color
		
		sub     al, 30h
		ret
	invalid_color:
		call    beep
		call    clear_last_char
		jmp     read_color    

   
clear_last_char:
   putc    8                       ; espacio.
   putc    ' '                     ; limpia position.
   putc    8                       ; espacio otra vez.       
   ret


;***************************************************************
; esta macro define un procedimiento para obtener un $ terminado
; cadena para el usuario, recibe una cadena y la escribe al buffer
; a DS:DI, tamano del buffer in DX.
; el procedimiento se detiene al precionar enter
;***************************************************************              
get_string:
    PUSH    AX
    PUSH    CX
    PUSH    DI
    PUSH    DX
    
    MOV     CX, 0                   ; contador de caracteres    
    CMP     DX, 1                   ; el buffer es muy pequeño?
    JBE     empty_buffer            ;    
    DEC     DX                      ; reserva espacio    
    
    ;============================
    ;ciclo para obtener y procesar la tecla    
    wait_for_key:
    
    MOV     AH, 0                   ; obtiene la tecla presionada
    INT     16h    
    CMP     AL, 13                  ; 'devolvio' la tecla?
    JZ      exit
    
    CMP     AL, 8                   ; preciono espacio?
    JNE     add_to_buffer
    JCXZ    wait_for_key            ; nada que remover!
    DEC     CX
    DEC     DI
    putc    8                       ; espacio.
    putc    ' '                     ; limpia posicion.
    putc    8                       ; espacio de nuevo.
    JMP     wait_for_key
    
    add_to_buffer:    
            CMP     CX, DX          ; el buffer esta lleno?
            JAE     wait_for_key    ; si es asi espera por un espacio    
            MOV     [DI], AL
            INC     DI
            INC     CX            
            ; imprime la letra:
            MOV     AH, 0Eh
            INT     10h
    
    JMP     wait_for_key
    ;============================
    
    exit:    
    ; terminado por $:
    MOV     word[DI], '$'
        
    empty_buffer:    
    POP     DX
    POP     DI
    POP     CX
    POP     AX
    RET

	
;
; ajustar color de fondo del jugador 
; o jugardor
proc adjust_grid_color    
    mov     ch, [grid+bx] 
    cmp     ch, 0               ; compara el caractere de la tabla[bx] al ser impreso
    je      set_null            ;
    
    cmp     ch, [player_1+0]
    je      set_p1
    jmp     set_p2    
    
    set_null:    
    mov     [current_color], GAME_TEXT_COLOR
    jmp     adjust_grid_char_return        

    set_p1:    
    mov     cl, [player_1+1]     
    mov     [current_color], cl
    jmp     adjust_grid_char_return     
    
    
    set_p2:    
    mov     cl, [player_2+1]    
    mov     [current_color], cl    
    jmp     adjust_grid_char_return     
    
	adjust_grid_char_return:        
    ret    
endp    
    
;
; dibuja en la tabla
;
draw_grid:
		
	; 1. tabla  
		gotoXY  0, 4
		print grid_buffer, 370, GAME_TEXT_SHADOW

	; 2.  los nuevos espacios con mas jogadas realizadas        
		mov     [current_color], 0      ; cor em cl    
		mov     bx, 0
        
		; primera linea
		gotoXY  35, 4            
		call 	adjust_grid_color
		mov 	al, [grid+0] 
		call 	print_char 
		inc     bx

		gotoXY  39, 4    
		call 	adjust_grid_color
		mov 	al, [grid+1]
		call 	print_char 
		inc     bx
		
		gotoXY  43, 4
		call 	adjust_grid_color
		mov		al, [grid+2] 
		call	print_char 
		inc     bx
		
		; segunda linea
		gotoXY  35, 6
		call 	adjust_grid_color            
		mov		al, [grid+3] 
		call 	print_char 
		inc     bx

		gotoXY  39, 6
		call 	adjust_grid_color    
		mov		al, [grid+4]
		call	print_char 
		inc     bx
		
		gotoXY  43, 6
		call 	adjust_grid_color
		mov		al, [grid+5] 
		call	print_char 
		inc     bx
		
		; tercera linea
		gotoXY  35, 8
		call 	adjust_grid_color            
		mov		al, [grid+6]
		call 	print_char 
		inc     bx

		gotoXY  39, 8
		call 	adjust_grid_color    
		mov		al, [grid+7]
		call 	print_char
		inc     bx
		
		gotoXY  43, 8
		call 	adjust_grid_color
		mov		al, [grid+8]
		call	print_char
			
	done:                 
		ret                                             

; 
; transforma un color y  selecionada del menu
; el atributo de color lo retorna a al
;1 (blando)  -> F, 2 (azul) -> 9, 3 (verde) ->, A (verde2) - > C
color_to_attibute:
		cmp al, 1
		je  set_branco       
		cmp al, 2
		je  set_azul      
		cmp al, 3
		je  set_verde    
		cmp al, 4
		je  set_vermelho    
		jmp set_default    
	set_branco:
		mov al, 0fh
		ret    
	set_azul:
		mov al, 09h
		ret    
	set_verde:
		mov al, 0Ah
		ret
	set_vermelho:
		mov al, 0Ch
		ret
	set_default:    
		;cualquier seleccion retorna rango de color
		mov al, GAME_TEXT_COLOR    
		ret

;
;  chequea que no este vacia la tabla
; retona 1 o 0 en al
check_grid_is_full:
		cmp [grid+0], 0
		je  check_grid_is_full_retun_false
		cmp [grid+1], 0
		je  check_grid_is_full_retun_false
		cmp [grid+2], 0
		je  check_grid_is_full_retun_false    
		cmp [grid+3], 0
		je  check_grid_is_full_retun_false    
		cmp [grid+4], 0
		je  check_grid_is_full_retun_false
		cmp [grid+5], 0
		je  check_grid_is_full_retun_false
		cmp [grid+6], 0
		je  check_grid_is_full_retun_false    
		cmp [grid+7], 0
		je  check_grid_is_full_retun_false        
		cmp [grid+8], 0
		je  check_grid_is_full_retun_false
						
	check_grid_is_full_retun_true:
		mov al, 1
		ret    

	check_grid_is_full_retun_false:
		mov al, 0
		ret    


;    
;   verifica que los valores en ch, cl no son iguales
; retorna un booleano en al
chk_3:
	;primero checamos si todos estan vacios
		cmp     ch, 0
		jne     chk_3_begin
		cmp     cl, 0
		jne     chk_3_begin
		cmp     dh, 0
		jne     chk_3_begin   
		jmp     chk_3_return_false  ; los 3 valores son nulos
		
	chk_3_begin:    
		cmp     ch, cl
		jne     chk_3_return_false
				
		cmp     cl, dh
		je      chk_3_return_true
		
	chk_3_return_false:
		mov     al, 0
		ret

	chk_3_return_true:
		mov     al, 1
		ret
    
;
; Verifica en la tabla en todas las  horizontales, verticales
; retorna 1 en al si hay vencedor
;    
check_player_wins:
		cmp     [current_player], 1    
		je      set_curr_char_p1
		jmp     set_curr_char_p2    
		
	set_curr_char_p1:
		mov     al, [player_1+0]     ; 
		mov     [current_char], al    ; current_char =  jugador1 char
		jmp     check_grid

	set_curr_char_p2:
		mov     al, [player_2+0]     ; 
		mov     [current_char], al    ; current_char =  jugador2 char
	   
	check_grid:
	;horizontal_1:        
		mov     ch, [grid+0]
		mov     cl, [grid+1]
		mov     dh, [grid+2]    
		call    chk_3
		cmp     al, 1
		je      player_wins      
		
	;horizontal_2:
		mov     ch, [grid+3]
		mov     cl, [grid+4]
		mov     dh, [grid+5]    
		call    chk_3
		cmp     al, 1
		je      player_wins          
		
	;horizontal_3:
		mov     ch, [grid+6]
		mov     cl, [grid+7]
		mov     dh, [grid+8]    
		call    chk_3
		cmp     al, 1
		je      player_wins                

	;vertical_1:
		mov     ch, [grid+0]
		mov     cl, [grid+3]
		mov     dh, [grid+6]    
		call    chk_3
		cmp     al, 1
		je      player_wins                

	;vertical_2:
		mov     ch, [grid+1]
		mov     cl, [grid+4]
		mov     dh, [grid+7]    
		call    chk_3
		cmp     al, 1
		je      player_wins                
		
	;vertical_3:
		mov     ch, [grid+2]
		mov     cl, [grid+5]
		mov     dh, [grid+8]    
		call    chk_3
		cmp     al, 1
		je      player_wins                

	;diagonal_1:
		mov     ch, [grid+0]
		mov     cl, [grid+4]
		mov     dh, [grid+8]    
		call    chk_3
		cmp     al, 1
		je      player_wins                
		
	;diagonal_2:
		mov     ch, [grid+2]
		mov     cl, [grid+4]
		mov     dh, [grid+6]    
		call    chk_3
		cmp     al, 1
		je      player_wins                
		

	nobody_wins:
		mov     al, 0
		ret

	player_wins:
		mov     al, 1
		ret        
       

                    
;
; de acuerdo al estado en que se encuentra....
; 
;             
proc draw_scene
    ; imprimimos en el juego      
    gotoXY   0, 0  
    print    str_game_divider, 80, GAME_TEXT_COLOR
    gotoXY   0, 1
    print    str_game_header, 80, GAME_TEXT_COLOR
    gotoXY   0, 2
    print    str_game_divider, 80, GAME_TEXT_SHADOW

; dejamos diferentes dependiendo el estado
; estado del juego: 0 = menu, 1 = jugando, 2 = fin del juego    
    cmp     [game_state], ST_MENU
    je      ds_menu
    cmp     [game_state], ST_JOGANDO
    je      ds_jogando
    cmp     [game_state], ST_VITORIA
    je      ds_game_vitoria
    jmp     ds_game_over      
    
ds_menu:        
    gotoXY   0, 3
    print    str_ftr_simbolos, 80, GAME_TEXT_SHADOW
    gotoXY   0, 4
    print    str_ftr_cores,    80, GAME_TEXT_SHADOW
    gotoXY   0, 5
    print    str_game_divider, 80, GAME_TEXT_COLOR
    
; obtenemos informacion del jugador 1
    gotoXY   0, 7
    print    str_player1_set_name, 80, GAME_TEXT_COLOR
    
    lea     di, [player_1+2]        ;  verificamos el buffer del nombre del jugador 1
    mov     dx, PLAYER_NAME_SIZE    ; tamano del buffer del jugador
    call    get_string              ; leemos la cadena y sobreescribimos
    
    gotoXY  0, 8
    print   str_player_set_char, 0, GAME_TEXT_COLOR    
    call    select_player_symbol    ; sleciona un simbolo y lo guarda 
    mov     [player_1+0], al        ; guarda el primer byte del  (simbolo)
    
    gotoXY  0, 9
    print   str_player_set_color, 0, GAME_TEXT_COLOR
    call    select_player_color     ;  lee el color deacuerdo al teclado
    call    color_to_attibute       ; convierte el atributo del jugador 
    mov     [player_1+1], al        ; guarda el segundo byte del jugador
                
    gotoXY  0, 10
    print   str_ok, 3, GAME_TEXT_SUCCESS

; obtenemos informacion del segundo jugador
    gotoXY  0, 12                 
    print    str_player2_set_name, 80, GAME_TEXT_COLOR
    
    lea     di, [player_2+2]         ; buffer del jugador
    mov     dx, PLAYER_NAME_SIZE    ; tamano en buffer del nombre
    call    get_string              ;lee la cadena y sobreescribe el bufer
    
    gotoXY  0, 13
    print    str_player_set_char, 0, GAME_TEXT_COLOR
    call    select_player_symbol 
    mov     [player_2+0], al         ; guarda el primer byte del simbolo del jugador
    
    gotoXY  0, 14
    print   str_player_set_color, 0, GAME_TEXT_COLOR
    call    select_player_color     ; lee el color segun la tecla presionada
    call    color_to_attibute       ; convierte lo elegido a atributo de color
    mov     [player_2+1], al         ; guarda el segundo byte del color
    
    gotoXY  0, 15
    print   str_ok, 3, GAME_TEXT_SUCCESS    
    
    gotoXY  0, 17
    print   str_iniciando, 13, GAME_TEXT_SHADOW

   ;Finalmente, mudamos el estado del juego y retornamos para el loop principal        
    mov     [game_state], ST_JOGANDO        
    mov     [current_player], 1h        ; iniciar juego con el jugador 1
    jmp     ds_return    


; Algoritmo
; 1. dibujamos la tabla
; 2. capturamos el movimiento del jugador
; 3. verificamos ganador
; 4. mostramos ganador
ds_jogando:                              
    call    draw_grid
    gotoXY  10, 10                                               ; posiciona el cursor prompt
    cmp     [current_player], 1
    jne     dsj_player2
    
dsj_player1:                                                     ; imprime el prompt del jugador 1                           
    print_addr  player_1, 2, PLAYER_NAME_SIZE, GAME_TEXT_COLOR   ;
    print       str_type_position, 0, GAME_TEXT_COLOR            ;
    call        le_jogada   ;jugador1                            ; jugada del jugador 1                          
    jmp         ds_game_check
    
dsj_player2:                                                     ; imprime el prompt del jugador 2
    print_addr  player_2, 2, PLAYER_NAME_SIZE, GAME_TEXT_COLOR   ;
    print       str_type_position, 0, GAME_TEXT_COLOR            ;
    call        le_jogada   ;jugador2                            ; juega el  2           
    jmp         ds_game_check

; paso 3
ds_game_check:    
    call        check_player_wins     
    cmp         al, 1               ; hay un vencedor?    
    je          _player_win
    call        check_grid_is_full
    cmp         al, 1
    je          _empate
    jmp         ds_swap_players     
    
    _player_win:
        mov     [game_state], ST_VITORIA
        jmp     ds_return
        
    _empate:        
        mov     [game_state], ST_GAME_OVER
        jmp     ds_return

; paso 4
ds_swap_players:     
    cmp         [current_player], 1
    je          set_curr_player_2
    
    set_curr_player_1:    
    mov         [current_player], 1
    jmp         ds_return        
     
    set_curr_player_2:
    mov         [current_player], 2  
    jmp         ds_return        


ds_game_vitoria:
;tecla de victoria     
    call    draw_grid
    gotoXY  0, 10      
    print    str_game_divider, 80, GAME_TEXT_SUCCESS    
    gotoXY  0, 11
    print   str_vitoria, 200, GAME_TEXT_SUCCESS
    cmp     [current_player], 1
    gotoXY  0, 12
    jne     vit_player2

; imprime el nombre del jogador 1    
vit_player1:                                                    
    print_addr  player_1, 2, PLAYER_NAME_SIZE, GAME_TEXT_SUCCESS   ;
    jmp     vit_player_continue

; imprimie el nombre del jugador 2   
vit_player2:            
    print_addr  player_2, 2, PLAYER_NAME_SIZE, GAME_TEXT_SUCCESS   ;

; imprime la palabra ganador
vit_player_continue:    
    print   str_votoria_suf, 15, GAME_TEXT_SUCCESS       
    
    jmp     return_to_os


    
ds_game_over:
    call    draw_grid
    gotoXY  0, 10      
    print   str_game_divider, 80, GAME_TEXT_ERRO    
    gotoXY  0, 11
    print   str_game_over, 180, GAME_TEXT_ERRO
    jmp     return_to_os
    
ds_return:    
    ret
endp
