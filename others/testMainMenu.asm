.model small
.data
	getName        db        "Your name: $"
	playerName1    db        21,?,21 dup("$")
	playerName1Len dw        ($-playerName1)
	               firstMenu label byte
	               db        '  ',0ah,0dh                                                                   	; new line
	               db        '                                                                    ',0ah,0dh
	               db        '                                                                    ',0ah,0dh
	               db        '                                                                    ',0ah,0dh
	               db        '                                                                    ',0ah,0dh
	               db        '                                                                    ',0ah,0dh
	               db        '                                                                    ',0ah,0dh
	               db        '                                                                    ',0ah,0dh
	               DB        '                ====================================================',0ah,0dh
	               DB        '               ||                                                  ||',0ah,0dh
	               DB        '               ||            #### FE L FDA SWAAA ####              ||',0ah,0dh
	               DB        '               ||                                                  ||',0ah,0dh
	               DB        '               ||--------------------------------------------------||',0ah,0dh
	               DB        '               ||                                                  ||',0ah,0dh
	               DB        '               ||            Please, Enter your name               ||',0ah,0dh
	               DB        '               ||       Then, press Enter to start the game        ||',0ah,0dh
	               DB        '               ||                                                  ||',0ah,0dh
	               DB        '               ||       **MAX 7 CHARCHTERS FOR EACH PLAYER**       ||',0ah,0dh
	               DB        '               ||                                                  ||',0ah,0dh
	               DB        '                ====================================================',0ah,0dh
	               DB        '$',0ah,0dh
.code
MAIN PROC FAR
	     mov ax, @data
	     mov ds, ax
	     mov ah,0           	;entering the graphics mode 320*200
	     mov al,13h
	;Getting input string
	     mov ah,09h
	     lea dx, firstMenu
	     int 21h


	     mov ah,09h
	     lea dx, getName
	     int 21h

	     lea si, playerName1
	     mov ah, 0Ah
	     mov dx, si
	     int 21h



MAIN ENDP
        END MAIN