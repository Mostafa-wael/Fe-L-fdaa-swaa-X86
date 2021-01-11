;///////////////////////////////Macros////////////////////////////////////
;///////////////////////////////
;/////////////////////////////// Cursor operations
;///////////////////////////////
setCursorAt_Row_Col MACRO row, col		; the screen is 80*25
	                    mov dh, row 	;Cursor position line
	                    mov dl, col 	;Cursor position column
	                    mov ah, 02h 	;Set cursor position function
	                    mov bl, 0ffh	; BF color, not working in this mode
	                    mov bh, 0   	;Page number
	                    int 10h     	;Interrupt call
ENDM
getCursorAt_Row__col MACRO row, col		; the screen is 80*25
	                     mov ah,3
	                     mov bx, 0
	                     int 10h
	                     mov row, dh
	                     mov col, dl
ENDM
setCursorAt_Row_Col_rowCol MACRO rowCol  		; sets cursor position in DX and in rowCol
	                           mov ah,2      	;Move Cursor
	                           mov dx, rowCol
	                           int 10h
ENDM
getCursorAt_rowCol MACRO rowCol  		; returns cursor position in DX and in rowCol
	                   mov ah,3
	                   mov bx, 0
	                   int 10h
	                   mov rowCol, dx
ENDM
;///////////////////////////////
;/////////////////////////////// String operations
;///////////////////////////////
printStringAtLoc MACRO string, row, col		; pass the acctual string i.e. (string +2)
	                 mov dh, row   	;Cursor position line
	                 mov dl, col   	;Cursor position column
	                 mov ah, 02h   	;Set cursor position function
	                 mov bl, 0ffh  	; BF color, not working in this mode
	                 mov bh, 0     	;Page number
	                 int 10h       	;Interrupt call

	                 mov ah,09h    	; print player's name
	                 lea dx, string
	                 int 21h
ENDM 
printString MACRO string
	            mov ah,09h
	            lea dx, string
	            int 21h
	ENDM
getString MACRO string         		; get a string from the user, wait for the user to press enter
	          mov ah, 0Ah
	          mov dx, offset string
	          int 21h
	ENDM
;
waitForInput MACRO    		;  ah:al = scan code: ASCII code, it also fetch the input from the buffer
	             mov ax, 0
	             int 16h
ENDM
checkIfInput MACRO   noInputLabel		; jumps to this label if there is no input		;  ah:al = scan code: ASCII code
	             mov ah, 1
	             int 16h
	             jz  noInputLabel
	ENDM
;
printInMsgBoxUP MACRO string
	                mov              bx, 2
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                call             DrawMsgWithBox
	                printStringAtLoc string, 2, 20
ENDM
printInMsgBoxLow MACRO string
	                mov              bx, 1
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                call             DrawMsgWithBox
	                printStringAtLoc string, 4, 20
ENDM
;
printChar macro char 		; prints the char at the current cursor position
	          mov ah,2
	          mov dl,char
	          int 21h
endm 
printCharAtLoc macro char, row, col		; prints the char at row and col
	               mov dh, row 	;Cursor position line
	               mov dl, col 	;Cursor position column
	               mov ah, 02h 	;Set cursor position function
	               mov bl, 0ffh	; BF color, not working in this mode
	               mov bh, 0   	;Page number
	               int 10h     	;Interrupt call

	               mov ah,2
	               mov dl,char
	               int 21h
endm 
getCharASCII macro    char		;  ah:al = scan code: ASCII code
	             mov ax, 0
	             int 16h
	             mov char, al
endm 
getCharScan macro    char		;  ah:al = scan code: ASCII code
	            mov ax, 0
	            int 16h
	            mov char, ah
endm 
;///////////////////////////////
;/////////////////////////////// Name operations
;///////////////////////////////
checkStringSize MACRO string, size, invalidSizeLabel		; check if the string is less than or equal to a given size
	                mov al, string+1
	                cmp al, size
	                JA  invalidSizeLabel
ENDM
checkFirstChar MACRO string, invalidCharLabel  		; check if the first character is a letter
	               local secondCheck, charIsALetter
	               mov   al, string+2
	;
	               cmp   al, 65                    	; 'A'
	               JB    invalidCharLabel
	; 65 <= char
	               cmp   al, 122                   	; 'z'
	               JA    invalidCharLabel
	; 65 <= char <= 122
	               cmp   al, 90                    	; 'Z'
	               jA    secondCheck
	; 65 <= char <= 90
	               jmp   charIsALetter
	secondCheck:   
	               cmp   al, 97                    	; 'a'
	               jb    invalidCharLabel
	; 97 <= char <= 122
	charIsALetter: 
				   ENDM
;
validateName MACRO string, size, validLabel, invalidLabel                              		; check if the name is valid (size and the first char)
	                local            invalidNameSize, invalidNameChar
	                checkStringSize  string, size, invalidNameSize
	; size is valid
	                checkFirstChar   string, invalidNameChar
	; first char is a letter
	                jmp              validLabel
	invalidNameSize:
	                call             DrawRec

	                editDrawPrams    logo, logoSizeX, logoSizeY, logoOffsetX2, logoOffsetY2
	                call             drawShape_extra

	                printStringAtLoc enterShorterName, 2, 25
	                jmp              invalidLabel
	invalidNameChar:
	                call             DrawRec

	                editDrawPrams    logo, logoSizeX, logoSizeY, logoOffsetX2, logoOffsetY2
	                call             drawShape_extra

	                printStringAtLoc enterValidName, 2, 25
	                jmp              invalidLabel
	ENDM
getPlayersName_ID MACRO                                                                  		; gets players name and ID
	;////////////////////////////// get player1 name
	;///// color the background and draw the logo
	                  call             DrawRec
	                  editDrawPrams    logo, logoSizeX, logoSizeY, logoOffsetX2, logoOffsetY2
	                  call             drawShape_extra
	;/////get the name and validate it
	                  printStringAtLoc getname1, 2, 28
	GetPlayer1Name:   
	                  getString        playername1
	                  validateName     playername1, maxPlayerSize, validName1, GetPlayer1Name
	validName1:       
	;//// choose character1
	                  call             getCharID                                             	;  adds the player ID in BL
	                  MOV              playerID1, BL
	;//////////////////////////////;//////////////////////////////;//////////////////////////////;//////////////////////////////
	; ;////////////////////////////// get player2 name
	; ;///// color the background and draw the logo
	;                   call             DrawRec
	;                   editDrawPrams    logo, logoSizeX, logoSizeY, logoOffsetX2, logoOffsetY2
	;                   call             drawShape_extra
	; ;///// get the name and validate it
	;                   printStringAtLoc getname2, 2, 28
	; GetPlayer2Name:
	;                   getString        playername2
	;                   validateName     playername2, maxPlayerSize, validName2, GetPlayer2Name
	; validName2:
	; ;//// choose character2
	;                   call             getCharID                                             	;  adds the player ID in BL
	;                   MOV              playerID2, BL
	ENDM
;///////////////////////////////
;/////////////////////////////// related to the screen
;///////////////////////////////
showScreen MACRO screen
	           mov ah,09h
	           lea dx, screen
	           int 21h
	ENDM
;
clearWholeScreen_noGraphics MACRO    		; clear the whole screen and return back to the graphics mode
	                            mov ah, 0
	                            mov al, 3
	                            INT 10H  	;FOR VIDEO DISPLAY
	ENDM
clearWholeScreen MACRO                  		; clear the whole screen and return back to the graphics mode
	                 mov               ah, 0
	                 mov               al, 3
	                 INT               10H  	;FOR VIDEO DISPLAY

	                 enterGraphicsMode

	ENDM	
clearRow MACRO row    		; clears a certain row ,the screen is 80*25
	         mov ax ,0600h
	         mov bh ,34h

	         mov cl,0
	         mov ch,row

	         mov dl,79
	         mov dh,row
	         int 10h
ENDM
;
colorScreen MACRO BF_color, topLeftX, topLeftY, bottomRightX, bottomRightY
	            mov al,0           	; (al = 1 scroll by 1 line) (al=0 change color)
	            mov bh,BF_color    	; normal video attribute
	            mov cl,topLeftX    	; upper left X
	            mov ch,topLeftY    	; upper left Y

	            mov dl,bottomRightX	; lower right X
	            mov dh,bottomRightY	; lower right Y

	            mov ah,6           	; function 6
	            int 10h
    ENDM
scrollScreen_graphics MACRO BF_color, topLeftX, topLeftY, bottomRightX, bottomRightY
	                      mov al,1           	; (al = 1 scroll by 1 line) (al=0 change color)
	                      mov bh,BF_color    	; normal video attribute
	                      mov cl,topLeftX    	; upper left X
	                      mov ch,topLeftY    	; upper left Y

	                      mov dl,bottomRightX	; lower right X
	                      mov dh,bottomRightY	; lower right Y

	                      mov ah,6           	; function 6
	                      int 10h
    ENDM
scrollScreen_text MACRO BF_color, topLeftX, topLeftY, bottomRightX, bottomRightY
	                  LOCAL Loop1

	                  mov   bh,BF_color
	                  mov   cl,topLeftX
	                  mov   ch,topLeftY

	Loop1:            mov   dl,cl
	                  mov   dh,ch
	                  int   10h

	                  mov   ah,8
	                  int   10h
	                  mov   bl,al

	                  mov   ah,2
	                  mov   dl,' '
	                  int   21h

	                  mov   dl,cl
	                  mov   dh,ch
	                  dec   dh
	                  int   10h

	                  mov   dl,bl
	                  int   21h

	                  inc   cl
	                  cmp   cl,bottomRightX
	                  jbe   Loop1

	                  mov   cl,topLeftX
	                  inc   ch
	                  cmp   ch,bottomRightY
	                  jbe   Loop1
	              ENDM 
;///////////////////////////////
;/////////////////////////////// Draw operations
;///////////////////////////////
editDrawPrams MACRO shape, sizeX, sizeY, offsetX, offsetY		; modifies the draw parameters before the drawShape proc
	              MOV AX, sizeX
	              MOV shapeSizeX, AX
	              MOV AX, sizeY
	              MOV shapeSizeY, AX
	              MOV AX, offsetY
	              MOV shapeOffsetY, AX
			
	              LEA SI, shape
	              MOV AX, offsetX
	              MOV shapeOffsetX, AX
ENDM
inputToMoveShip macro UP, DOWN, LEFT, RIGHT, FIRE_BTN, movShip_label		; pass the keys and the label to jump to
	                cmp ah,UP
	                jz  movShip_label

	                cmp ah,DOWN
	                jz  movShip_label

	                cmp ah,LEFT
	                jz  movShip_label

	                cmp ah,RIGHT
	                jz  movShip_label

	                cmp ah, FIRE_BTN
	                jz  movShip_label
ENDM
setCurrentChar MACRO playerID
	                    local drawShip_secondChar, drawShip_thirdChar, drawShip_fourthChar, drawShip_fifthChar, drawShip_start
	                    mov   ah, playerID

	                    cmp   ah, 0
	                    JNE   drawShip_secondChar
	                    mov   SI, offset Fenn_Plane
	                    jmp   drawShip_start

	drawShip_secondChar:cmp   ah, 1
	                    jne   drawShip_thirdChar
	                    mov   SI, offset Mikasa_Plane
	                    jmp   drawShip_start

	drawShip_thirdChar: cmp   ah, 2
	                    jne   drawShip_fourthChar
	                    mov   SI, offset Hisoka_Plane
	                    jmp   drawShip_start

	drawShip_fourthChar:cmp   ah, 3
	                    jne   drawShip_fifthChar
	                    mov   SI, offset Asta_Plane
	                    jmp   drawShip_start

	drawShip_fifthChar: 
	                    mov   SI, offset Meruem_Plane
	drawShip_start:     
	ENDM
;///////////////////////////////
;/////////////////////////////// related to the main menu and the choosing character screen
;///////////////////////////////
displayMainMenu MACRO                                                                    		; without the logo                                                                   		; responsible for drawing the main menu
	                call          background
	                mov           REV, 0
	                editDrawPrams gamebtn, btnsize, btnsize+2, gamebtnOffset, gamebtnOffset+2
	                call          drawShape_extra
	                editDrawPrams chatbtn, btnsize, btnsize+2, chatbtnOffset, chatbtnOffset+2
	                call          drawShape_extra
	                editDrawPrams exitbtn, btnsize, btnsize+2, exitbtnOffset, exitbtnOffset+2
	                call          drawShape_extra
	
	;call          drawLogo
	                call          eraseArrows
	                add           arrowoffsetY, arrowStep
	                call          eraseArrows
	                add           arrowoffsetY, arrowStep
	                call          eraseArrows
	                sub           arrowoffsetY, arrowStep
	                sub           arrowoffsetY, arrowStep
	                              

	                mov           Rev, 1
	                editDrawPrams ship1, shipSizeX, shipSizeX, arrowOffsetXRev, arrowoffsetY
	                call          drawShape
	                mov           Rev, 0
	                mov           AX, arrowOffsetX
	                mov           shapeOffsetX, AX
	                Lea           SI, Ship1
	                call          drawShape
	ENDM
;///////////////////////////////
;/////////////////////////////// related to keys
;///////////////////////////////
checkIfPrintable MACRO char, notPrintableLabel		;checks if the character is printable, 32D<=printable char<=126D
	                 mov al, char
	;
	                 cmp al, 32
	                 JB  notPrintableLabel
	; 32 <= char
	                 cmp al, 126
	                 JA  notPrintableLabel
	; 32 <= char <= 126
ENDM
checkIfEnter MACRO char, notEnterLabel		; check if the character is enter
	             mov al, char
	;
	             cmp al, 0Dh      	; enter character
	             JNE notEnterLabel
	; else
ENDM
checkIfBackSpace MACRO char, notBackSpaceLabel		; check if the character is BackSpace
	                 mov al, char
	;
	                 cmp al, 08h
	                 JNE notBackSpaceLabel
ENDM
checkIfESC MACRO char, notESCLabel		; check if the character is escape
	           mov al, char
	;
	           cmp al, 01Bh
	           JNE notESCLabel
	; else
ENDM
;///////////////////////////////
;/////////////////////////////// related to ports
;///////////////////////////////
initializaPort MACRO
	;Set Divisor Latch Access Bit
	               mov dx,3fbh     	; Line Control Register
	               mov al,10000000b	;Set Divisor Latch Access Bit
	               out dx,al       	;Out it
	;Set LSB byte of the Baud Rate Divisor Latch register.
	               mov dx,3f8h
	               mov al,0ch
	               out dx,al
	;Set MSB byte of the Baud Rate Divisor Latch register.
	               mov dx,3f9h
	               mov al,00h
	               out dx,al
	;Set port configuration
	               mov dx,3fbh
	; 0:Access to Receiver buffer, Transmitter buffer
	; 0:Set Break disabled
	; 011:Even Parity
	; 0:One Stop Bit
	; 11:8bits
	               mov al,00011011b
	               out dx,al
ENDM
; can be converted into a procedure
port_getChar MACRO  char
	             mov dx , 03F8H
	             in  al , dx   	; put the read value in al
	             mov char, al
ENDM
port_sendChar MACRO char
	              mov dx , 3F8H	; Transmit data register
	              mov al, char
	              out dx , al  	; value read from the keyboard is in al
ENDM
;
port_checkCanSend MACRO cannotSendLabel
	;Check that Transmitter Holding Register is Empty
	                  mov  dx , 3FDH      	; Line Status Register
	                  In   al , dx        	; Read Line Status
	                  test al , 00100000b
	                  JZ   cannotSendLabel	; Not empty, can't send data then, go to cannotSendLabel
	ENDM
port_checkReceive MACRO nothingToReceiveLabel
	;Check that Data is Ready
	                  mov  dx , 3FDH            	; Line Status Register
	                  in   al , dx
	                  test al , 1
	                  JZ   nothingToReceiveLabel	; Not Ready, can't get data then, go to nothingToReceiveLabel
	ENDM
;///////////////////////////////
;/////////////////////////////// Other operations
;///////////////////////////////
delay MACRO duration             		; using a nested for loop to get the square of trhe delay value
	              local outerLoop
	              local innerLoop
	              local innerLoopDone
	              local done
	              push  Cx
	              push  bx
	outerLoop:    
	              cmp   cx, duration
	              jz    done
	              mov   bx, 0
	innerLoop:    
	              cmp   bx, duration
	              jz    innerLoopDone
	              inc   bx
	              jmp   innerLoop
	innerLoopDone:
	              inc   cx
	              jmp   outerLoop
	done:         
	              pop   bx
	              pop   cx

endm
enterGraphicsMode MACRO                 		; enter the graphics mode
	                  mov ax, graphicsModeAX	; enter graphicsMode
	                  mov bx, graphicsModeBX
	                  int 10h
	ENDM
returnToDos MACRO
	            mov ah,4ch
	            int 21h
	ENDM
;///////////////////////////////Macros////////////////////////////////////
