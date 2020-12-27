.model small
.data
	getName        db       "Your name: $"
	playerName1    db       21,?,21 dup("$")
	playerName1Len dw       ($-playerName1)
	               byebye label byte
	               DB       '  ',0ah,0dh                                        	; new line
	               DB       '                                   ||',0ah,0dh
	               DB       '   ================================||',0ah,0dh
	               DB       '       ||            Bye !         ||',0ah,0dh
	               DB       '       || ================================',0ah,0dh
	               DB       '       ||                           ',0ah,0dh
	               DB        '$',0ah,0dh
.code
MAIN PROC FAR
	      mov ax, @data
	      mov ds, ax
	      mov ah,0        	;entering the graphics mode 320*200
	      mov al,13h

	      mov ah,09h
	      lea dx, mainMenu
	      int 21h


	CHECK:mov ah,1
	      int 16h
	      jz  CHECK       	; check if there is any input

	      cmp ah,5Bh      	; F1
	      jz  firstMenu

	      cmp ah,5ch      	; F2
	      jz  gameLoop

	      cmp ah,1bh      	; ESC
	      jz  exitProg

	      mov ah,0        	;wait for a key to be pressed and put it in ah, ah:al = scan code: ASCII code
	      int 16h

	      mov cx, 0       	; initialize cx to use it to iterate over the shipSize
	      jmp CHECK





MAIN ENDP
        END MAIN