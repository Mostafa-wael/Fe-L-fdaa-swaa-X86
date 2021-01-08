EXTRN CHAT:FAR
.model COMPACT ; no restrictions on the data segemnt
.stack 1024
;///////////////////////////////Macros////////////////////////////////////
;///////////////////////////////
;/////////////////////////////// Cursor operations
;///////////////////////////////
setCursorAt_Row_Col_Row_Col MACRO row, col		; the screen is 80*25
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
	;////////////////////////////// get player2 name
	;///// color the background and draw the logo
	                  call             DrawRec
	                  editDrawPrams    logo, logoSizeX, logoSizeY, logoOffsetX2, logoOffsetY2
	                  call             drawShape_extra
	;///// get the name and validate it
	                  printStringAtLoc getname2, 2, 28
	GetPlayer2Name:   
	                  getString        playername2
	                  validateName     playername2, maxPlayerSize, validName2, GetPlayer2Name
	validName2:       
	;//// choose character2
	                  call             getCharID                                             	;  adds the player ID in BL
	                  MOV              playerID2, BL
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
clearWholeScreen MACRO    		; clear the whole screen and return back to the graphics mode
	                 mov ah, 0
	                 mov al, 3
	                 INT 10H  	;FOR VIDEO DISPLAY
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
scrollScreen MACRO BF_color, topLeftX, topLeftY, bottomRightX, bottomRightY
	             mov al,1           	; (al = 1 scroll by 1 line) (al=0 change color)
	             mov bh,BF_color    	; normal video attribute
	             mov cl,topLeftX    	; upper left X
	             mov ch,topLeftY    	; upper left Y

	             mov dl,bottomRightX	; lower right X
	             mov dh,bottomRightY	; lower right Y

	             mov ah,6           	; function 6
	             int 10h
    ENDM
; can be converted into a procedure
checkForScrollUpper MACRO row, col
	                    local               nothing
	; no need to check for the row!
	                    cmp                 row, bottomRightY_upper                                                           	; if it is the last row, then, scroll
	                    JB                  nothing
	                    scrollScreen        BF_upper, topLeftX_upper, topLeftY_upper, bottomRightX_upper, bottomRightY_upper-1
	;
	                    mov                 row_send, bottomRightY_upper -1                                                   	; go to the next line
	                    mov                 col_send, topLeftX_upper                                                          	; start from column zero
	                    setCursorAt_Row_Col_Row_Col row_send, col_send                                                                	; set the cursor to the new location
	nothing:            
	ENDM
checkForScrollLower MACRO row, col
	                    local               nothing
	; no need to check for the row!
	                    cmp                 row, bottomRightY_lower                                                           	; if it is the last row, then, scroll
	                    JB                  nothing
	                    scrollScreen        BF_lower, topLeftX_lower, topLeftY_lower, bottomRightX_lower, bottomRightY_lower-1
	;
	                    mov                 row_rec, bottomRightY_lower -1                                                    	; go to the next line
	                    mov                 col_rec, topLeftX_lower                                                           	; start from column zero
	                    setCursorAt_Row_Col_Row_Col row_rec, col_rec                                                                  	; set the cursor to the new location
	nothing:            
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
displayMainMenu MACRO                                                                    		; responsible for drawing the main menu
	                call          background
	                mov           Ers, 0
	                mov           REV, 0
	                editDrawPrams gamebtn, btnsize, btnsize+2, gamebtnOffset, gamebtnOffset+2
	                call          drawShape_extra
	                editDrawPrams chatbtn, btnsize, btnsize+2, chatbtnOffset, chatbtnOffset+2
	                call          drawShape_extra
	                editDrawPrams exitbtn, btnsize, btnsize+2, exitbtnOffset, exitbtnOffset+2
	                call          drawShape_extra
	
	                call          drawLogo
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
checkMainMenuOptions MACRO gameLoop_label, exitProg_label, chatLoop_label                              		; remember to add the chatLoop_label
	                     local        CheckInMainMenu, Make_THE_JMP_CLOSER, downArrow_label, enterKey_label
	CheckInMainMenu:     
	                     waitForInput

	                     cmp          ah, key_upArrow                                                      	; up arrow
	                     jne          downArrow_label
	                     cmp          arrowoffsetY, arrowAtgame
	                     je           CheckInMainMenu
	                     call         eraseArrows
	                     mov          AX, arrowStep
	                     SUB          arrowoffsetY, AX
	                     mov          Rev, 1
	                     Lea          SI, Ship1
	                     mov          AX, arrowOffsetXRev
	                     mov          shapeOffsetX, AX
	                     mov          AX, arrowoffsetY
	                     mov          shapeOffsetY, AX
	                     call         drawShape
	                     Lea          SI, Ship1

	                     mov          Rev, 0
	                     mov          AX, arrowOffsetX
	                     mov          shapeOffsetX, AX
	                     call         drawShape
	Make_THE_JMP_CLOSER: jmp          CheckInMainMenu

	downArrow_label:     cmp          ah, key_downArrow                                                    	; down arrow
	                     jne          enterKey_label
	                     cmp          arrowoffsetY, arrowAtExit
	                     je           CheckInMainMenu
	                     call         eraseArrows

	                     mov          AX, arrowStep
	                     ADD          arrowoffsetY, AX
	                     mov          Rev, 1
	                     Lea          SI, Ship1
	                     mov          AX, arrowOffsetXRev
	                     mov          shapeOffsetX, AX
	                     mov          AX, arrowoffsetY
	                     mov          shapeOffsetY, AX
	                     call         drawShape
	                     Lea          SI, Ship1
	                     mov          Rev, 0
	                     mov          AX, arrowOffsetX
	                     mov          shapeOffsetX, AX
	                     call         drawShape

	                     jmp          Make_THE_JMP_CLOSER

	enterKey_label:      cmp          ah, key_enter                                                        	; enter
	                     jne          Make_THE_JMP_CLOSER                                                  	; added to prevent other buttons from doing enter's action

	                     cmp          arrowoffsetY, arrowAtChat
	                     je           chatLoop_label
	                     cmp          arrowoffsetY, arrowAtgame
	                     je           gameLoop_label
	                     cmp          arrowoffsetY, arrowAtExit
	                     je           exitProg_label
	                     jmp          Make_THE_JMP_CLOSER
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

;/////////////////////////////////////////////////////////////////////////
;///////////////////////////////Extra segment////////////////////////////////////
extra SEGMENT
	        org 900
	exitbtn DB  0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 1, 104, 1, 104
	        DB  1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104
	        DB  1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104
	        DB  1, 104, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1
	        DB  104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1
	        DB  104, 1, 104, 1, 104, 1, 104, 1, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1
	        DB  104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1
	        DB  104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104
	        DB  1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104
	        DB  1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 104, 1, 100
	        DB  0, 0, 0, 0, 0, 0, 0, 100, 104, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 104, 100, 0, 0, 0, 0, 0, 0, 100, 104, 1, 104, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 1, 104, 100, 0, 0, 0, 0, 0, 100, 177, 104, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 104, 104, 177, 100, 0, 0, 0, 0, 100, 104, 104, 1, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 1, 104, 104, 100, 0, 0, 0, 100, 104, 177
	        DB  104, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 104, 177, 104, 100, 0, 0, 100, 177, 104, 104, 1, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 104, 1, 104, 104, 177, 100, 0, 0, 100, 104, 177, 104, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 104, 177, 104, 100, 0
	        DB  0, 100, 177, 104, 104, 1, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 1, 104, 104, 177, 100, 0, 100, 177, 104, 177, 104, 104, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 104, 104, 104, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 104, 177, 104, 177, 100, 100, 177, 177, 104, 104, 1, 104, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 1, 1, 1, 1, 104, 104, 104, 104, 104, 104, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 104, 1, 104
	        DB  104, 177, 177, 100, 100, 177, 104, 177, 104, 104, 1, 1, 1, 31, 100, 100, 100, 77, 100, 77, 100, 77, 100, 77, 100, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 104, 104, 77, 77, 77, 77, 104, 104, 104, 104, 104, 104, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 9, 77, 9, 77, 9, 77, 9, 77, 77, 9, 77, 9, 77, 9, 77, 9, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 100, 77, 100, 77, 100, 77, 100, 77, 100, 100, 100, 31, 1, 1, 1, 104, 104, 177, 104, 177, 100, 100, 177, 177, 104, 104, 31, 31, 100
	        DB  100, 77, 77, 77, 77, 77, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 77, 104
	        DB  9, 9, 9, 9, 77, 77, 104, 104, 104, 104, 77, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 77, 77, 77, 77, 77, 100, 100, 31, 31, 104, 104, 177, 177, 100, 100, 177, 104, 177, 31, 100, 100, 77, 77, 77, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 77, 9, 9, 9, 9, 9, 9, 77, 77, 104, 104, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 77, 77
	        DB  77, 100, 100, 31, 177, 104, 177, 100, 100, 177, 177, 31, 100, 100, 77, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 77, 104, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 77, 100, 100, 31, 177, 177, 100, 100, 177, 104, 100
	        DB  77, 77, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 77, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 77, 77, 100, 104, 177, 100, 100, 177, 177, 100, 77, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 77, 100, 177, 177, 100, 100, 177, 177, 100, 77, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 77, 77, 77, 77, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 77, 100, 177, 177, 100
	        DB  100, 177, 100, 77, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 1, 1, 77, 77, 77, 77, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 77, 100, 177, 100, 100, 177, 100, 77, 9, 9, 9, 9, 9, 100, 100, 100
	        DB  100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 77, 77, 1, 1
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1
	        DB  1, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 77, 100, 177, 100, 100, 177, 77, 77, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 77, 77, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9
	        DB  77, 77, 177, 100, 100, 177, 100, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 77, 77, 77, 77, 77, 77, 77, 77, 1, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 77, 77, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 100, 177, 100, 100, 177, 77, 9, 9, 9, 9, 9
	        DB  9, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77
	        DB  77, 77, 77, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 77, 177, 100, 100, 177, 77, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1
	        DB  1, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1
	        DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	        DB  1, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 1, 1, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9
	        DB  9, 9, 9, 9, 9, 77, 177, 100, 100, 177, 77, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 1
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 77, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 77, 177, 100, 100, 104, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 1, 77, 77, 77, 77, 77, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9
	        DB  9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 104, 100, 100, 177, 77, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 1, 1, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 1, 1, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 9, 9, 9, 9, 9, 9, 9, 9, 77, 177, 100, 100, 104, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 1, 77, 77, 77, 77
	        DB  1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 77, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 104, 100
	        DB  100, 177, 77, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	        DB  77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 1, 77, 77, 77, 77, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 1, 77, 77, 77, 77, 77, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 77, 177, 100, 100, 104, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 1, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	        DB  31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 1, 31, 31, 31, 31, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 31, 31, 31, 31
	        DB  31, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 104, 100, 100, 104, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 31, 31, 31, 31, 31, 1, 9, 1
	        DB  31, 31, 31, 31, 31, 1, 9, 1, 31, 31, 31, 31, 31, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 31, 31, 31, 31, 31, 1, 1
	        DB  31, 31, 31, 31, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 31, 31, 31, 31, 31, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 104, 100, 100, 104, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 31, 31, 31, 31, 31, 1, 9, 1, 31, 31, 31, 31, 31, 1, 9, 1, 31, 31, 31, 31
	        DB  31, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 31, 31, 31, 31, 31, 1, 9, 1, 31, 31, 31, 31, 1, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 31, 31, 31, 31, 31, 31, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 104, 100, 100, 104, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 31, 31, 31, 31, 31, 9, 9, 9, 31, 31, 31, 31, 31, 9, 9, 9, 31, 31, 31, 31, 31, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 31, 31, 31, 31, 31, 9, 9, 9, 31, 31, 31, 31, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 9, 9, 9, 9, 1
	        DB  31, 31, 31, 31, 31, 31, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 104, 100, 100, 104, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 31, 31, 31, 31
	        DB  31, 9, 9, 9, 31, 31, 31, 31, 31, 9, 9, 9, 31, 31, 31, 31, 31, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 31, 31, 31
	        DB  31, 31, 9, 9, 9, 31, 31, 31, 31, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 31, 31, 9, 9, 31, 31, 31, 31, 31, 31, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 104, 100, 100, 104, 9, 9, 9, 9, 9, 9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 9, 31, 31, 31, 31, 31, 9, 53, 9
	        DB  31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 9, 31, 31, 31, 31, 31, 31, 9
	        DB  53, 53, 53, 53, 53, 53, 9, 9, 9, 9, 9, 9, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 53, 53, 53, 53, 53, 53, 53, 53, 9, 9, 9, 9, 9, 9, 9, 104, 100, 100, 104, 9, 9
	        DB  9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 31, 31, 31, 31, 31, 53, 53, 53, 31, 31, 31, 31, 31, 53, 53, 53, 31, 31, 31, 31, 31, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 9, 9, 9, 9, 9, 31, 31
	        DB  31, 31, 31, 31, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 1, 1, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 1, 1, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 9, 9, 9, 104, 100, 100, 104, 9, 9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 1
	        DB  1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 31, 31, 31, 53, 53, 53, 53, 53, 31, 31, 31, 53, 53, 53, 53, 53, 31, 31, 31, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  9, 31, 31, 31, 31, 31, 9, 53, 53, 9, 31, 31, 31, 31, 31, 9, 9, 53, 53, 53, 9, 9, 9, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 9, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 1, 1, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1, 1, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 9, 9, 9, 104, 100, 100, 104, 9, 9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 53, 9, 31, 31
	        DB  31, 31, 31, 9, 9, 53, 53, 53, 9, 9, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 9, 9, 9, 104, 100
	        DB  100, 104, 9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 53, 9, 9, 31, 31, 31
	        DB  31, 31, 31, 31, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 9, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 9, 104, 100, 100, 1, 9, 9, 53, 53, 53, 53, 53, 53, 53, 9
	        DB  9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 53, 9, 9, 31, 31, 31, 31, 31, 31, 9, 31, 31, 31, 31, 31, 9, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 9, 9, 53, 53, 53, 53, 53, 53, 53, 9, 9, 1, 100, 100, 104, 9, 53, 53, 53, 53, 53, 53, 53, 53, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53
	        DB  53, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53
	        DB  53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 53, 9, 31, 31, 31, 31, 31, 31, 9, 9, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 9, 9, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 9, 9, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 9, 104, 100, 100, 1, 9, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 9, 31, 31, 31, 31, 9, 53, 53, 9
	        DB  31, 31, 31, 31, 9, 9, 9, 9, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 9, 1, 100, 100, 1, 9, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 9, 9, 9, 31, 31, 31, 31, 31
	        DB  31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 9, 1, 100, 100, 1, 9, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31
	        DB  31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 9, 1, 100, 100, 1, 9, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 9, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 9, 1, 100, 100, 1, 9, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 31, 31
	        DB  31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 9, 1, 100, 100, 1, 9, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100
	        DB  100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100
	        DB  100, 53, 53, 53, 53, 53, 53, 53, 53, 9, 1, 100, 0, 100, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31, 31, 31, 31, 31, 31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 100, 0
	        DB  0, 100, 77, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 31, 31
	        DB  31, 31, 31, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 77, 100, 0, 0, 0, 100, 9, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 100, 0, 0, 0, 0, 100, 77, 77, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 77
	        DB  77, 100, 0, 0, 0, 0, 0, 100, 100, 77, 77, 9, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 9, 77, 77, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 77
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
	        DB  9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 77, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	        DB  100, 0, 0, 0, 0, 0, 0, 0
	
	chatbtn DB  0, 0, 0, 0, 0, 0, 0, 0, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96
	        DB  96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96
	        DB  96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96
	        DB  96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96
	        DB  96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 96, 96, 96, 119, 2, 119, 2
	        DB  119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2
	        DB  119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2
	        DB  119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2
	        DB  119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2
	        DB  119, 2, 119, 2, 119, 2, 119, 2, 96, 96, 96, 0, 0, 0, 0, 0, 0, 0, 0, 0, 96, 2, 119, 2, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119
	        DB  2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119
	        DB  2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119
	        DB  2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119
	        DB  2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 119, 2, 2, 2, 119, 2, 96
	        DB  0, 0, 0, 0, 0, 0, 0, 96, 119, 119, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 119, 119, 96, 0, 0, 0, 0, 0, 0, 96, 119, 2, 119, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 119, 2, 119, 96, 0, 0, 0, 0, 0, 96, 194, 119, 119, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 119, 119, 194, 96, 0, 0, 0, 0, 96, 119, 119, 2, 119, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 119, 2, 119, 119, 96, 0, 0, 0, 96, 119, 194
	        DB  119, 119, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 119, 119, 194, 119, 96, 0, 0, 96, 194, 119, 119, 2, 119, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 119, 2, 119, 119, 194, 96, 0, 0, 96, 119, 194, 119, 119, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 119, 119, 194, 119, 96, 0
	        DB  0, 96, 194, 119, 119, 2, 119, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 119, 2, 119, 119, 194, 96, 0, 96, 194, 119, 194, 119, 119, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 119, 119, 194, 119, 194, 96, 96, 194, 194, 119, 119, 2, 119, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 119, 2, 119
	        DB  119, 194, 194, 96, 96, 194, 119, 194, 119, 119, 2, 2, 2, 96, 96, 96, 96, 71, 96, 71, 96, 71, 96, 71, 96, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71
	        DB  71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71
	        DB  71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 48, 71, 48, 71, 48, 71, 48, 71, 71, 48, 71, 48, 71, 48, 71, 48, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71
	        DB  71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71
	        DB  71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 96, 71, 96, 71, 96, 71, 96, 71, 96, 96, 96, 96, 2, 2, 2, 119, 119, 194, 119, 194, 96, 96, 194, 194, 119, 119, 31, 31, 96
	        DB  71, 71, 71, 71, 71, 71, 71, 71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 2, 2, 2, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 71, 71, 71, 71, 71, 71, 71, 71, 96, 31, 31, 119, 119, 194, 194, 96, 96, 194, 119, 194, 31, 96, 96, 71, 71, 71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 71, 71
	        DB  71, 96, 96, 31, 194, 119, 194, 96, 96, 194, 194, 31, 96, 71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 2, 2, 2, 2, 2, 2, 69, 69, 69, 69, 69, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 71, 96, 31, 194, 194, 96, 96, 194, 119, 96
	        DB  71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 71, 96, 119, 194, 96, 96, 194, 194, 71, 71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 2
	        DB  2, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 71, 71, 194, 194, 96, 96, 194, 194, 71, 71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 2, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 2, 2, 2, 2, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 71, 71, 194, 194, 96
	        DB  96, 194, 71, 71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 71, 71, 194, 96, 96, 194, 96, 71, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 71, 96, 194, 96, 96, 194, 71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 48, 48, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 48, 48, 48, 48, 48
	        DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2
	        DB  2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 71, 194, 96, 96, 194, 96, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 2, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 48, 2, 2, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 48, 48, 48, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
	        DB  2, 2, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 2, 2, 2, 2, 48, 48, 48, 96, 194, 96, 96, 194, 71, 48, 48, 48, 48, 48
	        DB  31, 31, 72, 72, 72, 72, 72, 72, 2, 2, 2, 2, 48, 48, 48, 2, 2, 2, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  2, 2, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 2, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 2, 69
	        DB  69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 2, 48, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31
	        DB  31, 31, 31, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 2, 2
	        DB  48, 48, 48, 2, 2, 2, 2, 72, 72, 72, 72, 72, 72, 72, 31, 48, 48, 71, 194, 96, 96, 194, 48, 48, 48, 48, 48, 48, 48, 31, 31, 72, 72, 72, 72, 72, 72, 72, 72, 2
	        DB  2, 2, 72, 72, 72, 72, 72, 72, 2, 2, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 2, 2, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 69, 69, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2
	        DB  2, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 31, 2, 48, 2, 31, 31, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 2, 72, 72, 72, 72, 72, 72, 2, 2, 2, 72, 72, 72, 72, 72, 72, 72, 72
	        DB  95, 31, 48, 48, 48, 48, 194, 96, 96, 194, 71, 48, 48, 48, 48, 48, 48, 48, 48, 31, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 2
	        DB  2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 31, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 31, 2, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 2, 2, 48, 48, 48, 48, 48, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 2, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 2, 2, 2, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 48, 48, 48, 48, 48, 71, 194, 96, 96, 119, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 31, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 95, 72, 72, 72, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 2, 2, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 31, 2, 48, 2, 2, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 31, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 31, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 2, 69, 69, 69, 69, 69, 69, 31, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 72, 72, 72, 95, 72, 72
	        DB  72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 31, 48, 48, 48, 48, 48, 48, 119, 96, 96, 194, 71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 31, 95, 72, 72
	        DB  72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 95, 72, 72, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 31, 69, 69, 69, 69, 69, 69, 69, 31, 2, 48, 48, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 2, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 2, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 2, 31, 69, 69, 69, 69, 69, 69, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 2, 2, 72, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 72, 72, 72, 72, 72, 72
	        DB  72, 95, 31, 48, 48, 48, 48, 48, 48, 71, 194, 96, 96, 119, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 31, 95, 72, 72, 72, 72, 72, 95, 95, 95, 95, 95, 95, 95, 95
	        DB  95, 95, 72, 72, 72, 95, 72, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 48, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2
	        DB  31, 69, 69, 69, 69, 69, 69, 69, 69, 2, 48, 48, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 31, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 2, 48, 48, 48, 48, 48, 48, 48, 2, 2, 2, 31, 69, 69, 69, 69, 69, 31, 2, 48
	        DB  48, 48, 48, 48, 48, 48, 2, 2, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 72, 72, 72, 95, 31, 48, 48, 48, 48, 48, 48, 48, 48, 119, 96
	        DB  96, 194, 71, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 31, 72, 95, 72, 72, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 95, 72, 2, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 69, 2, 2, 31, 69, 69, 69, 69, 69, 69, 69, 31, 2, 48, 48
	        DB  2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 2, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 69, 31, 2, 48, 48, 48, 48, 48, 48, 48, 2, 2, 31, 31, 69, 69, 69, 69, 69, 31, 2, 48, 48, 48, 48, 48, 48, 48, 2, 72, 95, 95, 95, 95
	        DB  95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 31, 48, 48, 48, 48, 48, 48, 48, 71, 194, 96, 96, 119, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 31, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 2, 2, 48, 48, 48, 48, 48, 48, 48, 48, 2, 31, 69, 69, 69, 69
	        DB  69, 69, 69, 69, 69, 69, 69, 31, 31, 31, 31, 31, 31, 2, 48, 2, 31, 69, 31, 69, 69, 69, 69, 69, 31, 2, 48, 48, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69
	        DB  69, 69, 31, 31, 31, 31, 69, 2, 48, 2, 31, 69, 69, 69, 69, 69, 69, 69, 69, 31, 69, 69, 69, 69, 69, 69, 69, 69, 69, 31, 69, 69, 69, 69, 69, 31, 2, 48, 48, 48
	        DB  48, 48, 48, 48, 2, 31, 69, 69, 69, 69, 69, 69, 69, 31, 2, 48, 48, 48, 48, 48, 48, 2, 2, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95
	        DB  95, 95, 95, 95, 95, 31, 48, 48, 48, 48, 48, 48, 48, 48, 119, 96, 96, 119, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 31, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95
	        DB  95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 2, 48, 48, 48, 48, 48, 48, 48, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 2, 2, 2
	        DB  2, 48, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 2, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 2, 2, 2, 2, 48, 48, 2, 31, 31
	        DB  31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 2, 31, 31, 31, 31, 31, 31, 31, 2, 2, 48, 48, 48, 48, 48, 48, 2, 31, 31, 31, 31, 31, 31, 31
	        DB  31, 31, 2, 48, 48, 48, 48, 48, 48, 2, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 119, 96, 96, 119, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 31, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95
	        DB  72, 2, 48, 48, 48, 48, 48, 48, 48, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 2, 2, 2, 48, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31
	        DB  31, 2, 2, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 2, 2, 2, 48, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 31, 31, 31, 31
	        DB  31, 31, 31, 31, 2, 31, 31, 31, 31, 31, 31, 31, 2, 2, 48, 48, 48, 48, 48, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 2, 48, 48, 48, 48, 48, 48, 48, 2, 72, 95
	        DB  95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 31, 48, 48, 48, 48, 48, 48, 48, 119, 96, 96, 119, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 95, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 95, 2, 2, 48, 48, 48, 48, 48, 48, 48, 2, 31
	        DB  31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 2, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 48, 2, 31, 31, 31, 31, 31, 31, 31
	        DB  31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 2, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 31, 31, 31, 31, 31, 31, 31, 31, 48, 48, 31, 31, 31, 31, 31, 31
	        DB  31, 2, 48, 48, 48, 48, 48, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 2, 48, 48, 48, 48, 48, 48, 2, 2, 95, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95
	        DB  95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 48, 48, 48, 48, 48, 48, 48, 119, 96, 96, 119, 48, 48, 48, 48, 48, 48, 48, 48, 48, 31, 72, 95, 95, 95, 95, 95, 95, 95
	        DB  95, 95, 31, 95, 31, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 2, 48, 48, 48, 48, 48, 48, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	        DB  31, 31, 31, 31, 2, 2, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 2, 2
	        DB  48, 48, 2, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 31, 31, 31, 31, 31, 31, 31, 48, 48, 31, 31, 31, 31, 31, 31, 31, 2, 48, 48, 48, 48, 48, 48, 48, 2, 31, 31
	        DB  31, 31, 31, 31, 2, 48, 48, 48, 48, 48, 48, 48, 2, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 31
	        DB  48, 48, 48, 48, 48, 48, 119, 96, 96, 119, 48, 48, 48, 48, 48, 48, 48, 45, 45, 31, 95, 95, 95, 95, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31
	        DB  95, 95, 95, 95, 95, 72, 2, 45, 45, 45, 45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 48, 31, 31, 31
	        DB  31, 31, 31, 31, 31, 31, 48, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 31, 31, 31, 31, 31, 31, 31, 31, 31
	        DB  48, 31, 31, 31, 31, 31, 31, 31, 31, 48, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  2, 72, 95, 95, 95, 95, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 95, 95, 95, 31, 95, 31, 95, 95, 95, 31, 48, 48, 48, 48, 48, 48, 119, 96, 96, 119, 48, 48
	        DB  48, 48, 45, 45, 45, 45, 45, 31, 95, 95, 95, 95, 95, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 95, 95, 72, 2, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 48, 31
	        DB  31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 31, 31, 31, 31, 31, 31, 31, 31, 48, 31, 31
	        DB  31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 2, 72, 95, 95, 95, 95, 31, 95, 31, 95, 31, 95
	        DB  31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 95, 95, 31, 45, 45, 45, 48, 48, 48, 119, 96, 96, 119, 48, 48, 48, 45, 45, 45, 45, 45, 45, 45, 31, 95, 95, 95
	        DB  95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 95, 72, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31
	        DB  31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	        DB  31, 31, 31, 48, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 48, 31, 31, 31, 31, 31, 31, 31, 48, 48, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 72, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31
	        DB  95, 95, 31, 45, 45, 45, 45, 48, 48, 48, 119, 96, 96, 119, 48, 48, 48, 45, 45, 45, 45, 45, 45, 45, 31, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95
	        DB  31, 95, 31, 95, 31, 95, 95, 95, 72, 2, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45
	        DB  45, 48, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 48, 31, 31, 31, 31, 31
	        DB  31, 31, 31, 31, 48, 48, 48, 31, 31, 31, 31, 31, 48, 48, 48, 48, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 2, 72, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 95, 31, 45, 45, 45, 45, 45, 48, 48, 119, 96
	        DB  96, 119, 48, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 31, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 72, 2, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 2, 2, 48, 48, 48, 48, 45, 48, 48
	        DB  2, 2, 2, 2, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 2, 72, 95, 95, 31, 95, 31
	        DB  95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 95, 31, 45, 45, 45, 45, 45, 45, 48, 48, 119, 96, 96, 2, 48, 48, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 31, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 95, 72, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 31, 31
	        DB  31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 48, 31, 31, 31, 31, 2, 48, 48, 2, 2, 31, 31, 31, 2, 2, 48, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 72, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95
	        DB  31, 95, 31, 95, 95, 31, 45, 45, 45, 45, 45, 45, 48, 48, 2, 96, 96, 119, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 31, 95, 95, 31, 95, 31, 95, 31, 95, 31
	        DB  95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 72, 2, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 31, 48, 2, 2, 31, 31, 31, 31, 31, 2, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 2, 72, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 31, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 48, 119, 96, 96, 2, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 31, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 72
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 2, 31, 31, 31, 31, 31, 31
	        DB  31, 2, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 72
	        DB  95, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 95, 31, 45, 45, 45, 45, 45, 45, 45, 45, 48, 2, 96, 96, 2, 48, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 31, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 31, 95, 95, 72, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 2, 31, 31, 31, 31, 31, 31, 31, 2, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 72, 95, 95, 95, 95, 31, 95, 31, 95, 31, 95, 31
	        DB  95, 31, 95, 95, 95, 95, 95, 31, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 2, 96, 96, 2, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 31, 31, 95, 95
	        DB  95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72, 72, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 2, 31, 31, 31, 31, 31, 31, 31, 2, 31, 31, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 72, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 31, 31, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 48, 2, 96, 96, 2, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 31, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 72
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 2, 31, 31
	        DB  31, 31, 31, 31, 48, 45, 2, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 72, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 31, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 2, 96, 96, 2, 48, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 31, 72, 31, 72, 31, 72, 72, 72, 72, 72, 72, 72, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 48, 48, 48, 48, 31, 31, 31, 48
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 72, 72, 72, 72
	        DB  72, 72, 31, 72, 31, 72, 31, 31, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 2, 96, 96, 2, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 48, 2, 2, 2, 48, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 2, 96, 0, 96, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 48, 2, 31, 31, 31, 48, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 96, 0
	        DB  0, 96, 71, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 2, 31, 31, 31, 31
	        DB  31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 71, 96, 0, 0, 0, 96, 48, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 2, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 96, 0, 0, 0, 0, 96, 71, 71, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 31, 31, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 71
	        DB  71, 96, 0, 0, 0, 0, 0, 96, 96, 71, 71, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  48, 31, 31, 31, 48, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45
	        DB  45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 48, 71, 71, 96, 96, 0, 0, 0, 0, 0, 0, 0, 0, 96, 96, 71
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
	        DB  48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 71, 96, 96, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96
	        DB  96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96
	        DB  96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96
	        DB  96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96
	        DB  96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96
	        DB  96, 0, 0, 0, 0, 0, 0, 0

	gamebtn DB  0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 6, 114, 6, 114
	        DB  6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114
	        DB  6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114
	        DB  6, 114, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6
	        DB  114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6
	        DB  114, 6, 114, 6, 114, 6, 114, 6, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6
	        DB  114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6
	        DB  114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114
	        DB  6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114
	        DB  6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 114, 6, 91
	        DB  0, 0, 0, 0, 0, 0, 0, 91, 114, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 91, 0, 0, 0, 0, 0, 0, 91, 114, 6, 114, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 6, 114, 91, 0, 0, 0, 0, 0, 91, 184, 114, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 114, 114, 184, 91, 0, 0, 0, 0, 91, 114, 114, 6, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 6, 114, 114, 91, 0, 0, 0, 91, 114, 184
	        DB  114, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 184, 114, 91, 0, 0, 91, 184, 114, 114, 6, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 114, 6, 114, 114, 184, 91, 0, 0, 91, 114, 184, 114, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 184, 114, 91, 0
	        DB  0, 91, 184, 114, 114, 6, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 6, 114, 114, 184, 91, 0, 91, 184, 114, 184, 114, 114, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 184, 114, 184, 91, 91, 184, 184, 114, 114, 6, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 6, 114
	        DB  114, 184, 184, 91, 91, 184, 114, 184, 114, 114, 6, 6, 6, 90, 90, 90, 90, 66, 90, 66, 90, 66, 90, 66, 90, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66
	        DB  66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66
	        DB  66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 42, 66, 42, 66, 42, 66, 42, 66, 66, 42, 66, 42, 66, 42, 66, 42, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66
	        DB  66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66
	        DB  66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 90, 66, 90, 66, 90, 66, 90, 66, 90, 90, 90, 90, 6, 6, 6, 114, 114, 184, 114, 184, 91, 91, 184, 184, 114, 114, 31, 91, 90
	        DB  91, 66, 66, 66, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 66, 66, 66, 66, 66, 66, 66, 66, 91, 90, 91, 31, 114, 114, 184, 184, 91, 91, 184, 114, 184, 31, 90, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66
	        DB  66, 66, 90, 31, 184, 114, 184, 91, 91, 184, 184, 31, 90, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 90, 31, 184, 184, 91, 91, 184, 114, 90
	        DB  66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 90, 114, 184, 91, 91, 184, 184, 91, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 6, 6, 6, 6, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 66, 91, 184, 184, 91, 91, 184, 184, 91, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 6, 6, 6, 6, 6, 6, 6, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 91, 184, 184, 91
	        DB  91, 184, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 6, 67, 67
	        DB  67, 67, 6, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 184, 91, 91, 184, 90, 66, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 67, 67, 67, 67, 67, 6, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 90, 184, 91, 91, 184, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 67, 31, 31, 67, 67, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  66, 66, 184, 91, 91, 184, 90, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 6, 31, 31, 31, 31, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 90, 184, 91, 91, 184, 66, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 6, 6, 6, 6, 6, 6, 6, 42, 42, 42, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 42
	        DB  42, 42, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 42, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 184, 91, 91, 184, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 42, 42, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 42, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	        DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 184, 91, 91, 184, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 6, 6, 67, 67, 67, 67, 67, 6, 42, 42, 6, 6, 67, 67, 67, 67, 67
	        DB  67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 6, 6, 6, 6, 6, 67, 67, 67, 67, 67, 67, 67, 67, 6, 6, 6, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67
	        DB  67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 6, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 184, 91, 91, 114, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67
	        DB  67, 67, 67, 6, 6, 6, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67
	        DB  67, 67, 67, 67, 67, 67, 67, 67, 67, 6, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 114, 91, 91, 184, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67
	        DB  67, 67, 67, 67, 67, 67, 6, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67
	        DB  67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 6, 6, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 184, 91, 91, 114, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 66, 66, 66, 66, 66, 66
	        DB  66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 6, 67, 67
	        DB  67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67
	        DB  67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 114, 91
	        DB  91, 184, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67
	        DB  67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67
	        DB  67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 184, 91, 91, 114, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 42, 42, 42, 42, 6, 6, 6, 67, 67, 67, 67, 67, 67, 67, 67, 67
	        DB  67, 67, 6, 6, 6, 42, 42, 42, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 67, 67, 67, 67
	        DB  67, 67, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 66, 66, 66, 66, 66, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 114, 91, 91, 114, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 66
	        DB  66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42
	        DB  42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 42, 42, 6, 6, 6, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 6, 6, 6, 42, 42, 42, 6, 67
	        DB  67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 114, 91, 91, 114, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42, 6, 67, 67, 67, 67, 67, 67, 67, 6, 42, 42
	        DB  42, 42, 6, 6, 6, 31, 31, 31, 31, 31, 31, 6, 6, 6, 31, 31, 31, 31, 31, 31, 6, 6, 6, 42, 42, 42, 6, 31, 31, 31, 31, 31, 31, 31, 31, 6, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 31, 31, 31, 31, 31, 31, 31, 6, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 66, 66
	        DB  66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 114, 91, 91, 114, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 91, 91, 91, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 91, 91, 91, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 6, 67, 67, 31, 31, 31, 31, 67, 6, 42, 42, 6, 67, 67, 31, 31, 31, 31, 67, 6, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31, 6, 6
	        DB  6, 6, 6, 31, 31, 31, 31, 31, 31, 31, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31, 31, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 31
	        DB  31, 31, 31, 31, 31, 31, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	        DB  91, 91, 91, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 114, 91, 91, 114, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 91, 91, 91
	        DB  91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 6, 67, 31, 31, 31, 31
	        DB  31, 31, 42, 42, 42, 6, 31, 31, 31, 31, 31, 31, 31, 42, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 42, 42
	        DB  42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 114, 91, 91, 114, 42, 42, 42, 42, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31
	        DB  31, 42, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 42, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 42, 42, 42, 42, 42, 114, 91, 91, 114, 42, 42
	        DB  42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 91, 91, 91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31
	        DB  31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 91
	        DB  91, 91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 42, 42, 114, 91, 91, 114, 42, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31
	        DB  31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	        DB  31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 42, 42, 42, 114, 91, 91, 114, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31
	        DB  31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 42, 114, 91
	        DB  91, 114, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 91, 91, 91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 42, 114, 91, 91, 6, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 42, 6, 91, 91, 114, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43
	        DB  43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 42, 114, 91, 91, 6, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 6, 91, 91, 6, 42, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 91, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 6, 91, 91, 6, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31
	        DB  31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 42, 6, 91, 91, 6, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31
	        DB  31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 6, 91, 91, 6, 42, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 6, 91, 91, 6, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31
	        DB  31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 6, 91, 0, 91, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 31, 31, 31, 31, 31, 31, 31, 42, 43, 43, 42, 31, 31
	        DB  31, 31, 31, 31, 31, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 91, 0
	        DB  0, 91, 66, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 66, 91, 0, 0, 0, 91, 42, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 91, 0, 0, 0, 0, 91, 66, 66, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 66
	        DB  66, 91, 0, 0, 0, 0, 0, 91, 91, 66, 66, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43
	        DB  43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 42, 66, 66, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 66
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
	        DB  42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 66, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91
	        DB  91, 0, 0, 0, 0, 0, 0, 0
	logo    DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 106, 106, 106, 106, 106, 106, 106, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 57, 34, 34, 34, 34, 34, 34, 34, 34, 57, 57, 57, 106, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 34, 34, 57, 106, 106
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 57, 34, 34, 34, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 34, 34, 34, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 34, 34
	        DB  34, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 106, 106, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 106, 106, 106, 106, 0, 0, 0, 106, 106, 57, 57, 57, 57, 106, 106, 0, 0, 0, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  57, 57, 57, 57, 57, 57, 57, 34, 34, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 57, 57, 57, 106, 106, 0, 106, 57, 57, 34, 34, 34, 34, 57, 106, 106, 0, 106
	        DB  106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 34, 34, 34, 34, 34, 34, 34, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 34
	        DB  57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 34, 34, 106, 106, 34, 34, 34, 34, 34, 34
	        DB  106, 106, 106, 106, 106, 34, 34, 34, 34, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 100, 100, 53
	        DB  53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 34, 57, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 34, 34
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54
	        DB  53, 53, 53, 53, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 34, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 106, 57, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 54, 54, 54, 54
	        DB  54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 53, 53, 53, 53, 100, 100, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 57, 106, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 54, 54, 54, 54, 54, 54, 54, 54, 54, 53, 53, 53, 53, 54, 54, 54, 53, 53, 53, 53, 53, 100, 100, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 53, 53, 53, 106, 106
	        DB  106, 106, 34, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 57, 34, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 106, 106, 106, 106, 53
	        DB  53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 53, 53, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 34, 106, 106, 106, 106, 106
	        DB  53, 53, 53, 53, 53, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 100, 100, 100, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  106, 57, 34, 34, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 106, 106, 54, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 54, 106, 106, 106, 34, 34, 106, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 34, 34, 106, 106, 106, 53, 53, 53, 100, 100, 100, 100, 106, 106, 54, 53, 53, 53, 53, 53, 53, 100, 100, 100, 106, 106, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 100, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53
	        DB  53, 54, 106, 106, 106, 34, 57, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 34, 106, 106, 54, 53, 53, 53, 100, 100, 100, 100, 106, 106, 53, 53, 53, 53, 53
	        DB  53, 100, 100, 100, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 100, 53, 53, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 53, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 54, 106, 106, 34, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 34, 34, 106, 106, 106, 53, 53, 100, 100, 100
	        DB  100, 106, 106, 106, 54, 53, 53, 53, 53, 100, 100, 100, 106, 106, 106, 54, 53, 53, 53, 53, 53, 53, 100, 100, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100
	        DB  53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 34, 57, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57
	        DB  34, 106, 106, 106, 54, 53, 53, 100, 100, 100, 106, 106, 106, 54, 53, 53, 53, 53, 100, 100, 100, 106, 106, 106, 54, 53, 53, 53, 53, 53, 100, 100, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 53, 53, 53, 100, 53, 53, 53, 54, 53, 53, 106, 106, 106, 106, 106, 106, 34, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 54, 106, 106, 106, 34, 57, 106
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 53, 53, 53, 100, 100, 53, 106, 106, 54, 53, 53, 53, 53, 53, 100, 100, 100, 106, 106, 106, 54, 53, 53, 53, 53, 53
	        DB  100, 100, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 53, 53, 106, 54, 53, 53, 106, 106, 106, 106, 106, 106, 34, 106, 106, 106, 106, 106, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 53, 53, 100, 100, 100, 106, 106, 106, 54, 53, 53, 53, 53, 100, 100, 106
	        DB  106, 106, 106, 106, 54, 53, 53, 53, 53, 100, 100, 106, 106, 106, 106, 106, 106, 34, 34, 106, 106, 106, 106, 106, 53, 53, 100, 53, 53, 53, 106, 54, 54, 53, 106, 106, 106, 106, 106, 106
	        DB  34, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 54, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 53, 53, 100, 100, 53, 106
	        DB  106, 106, 54, 53, 53, 53, 100, 100, 100, 106, 106, 106, 106, 106, 54, 53, 53, 53, 100, 100, 100, 106, 106, 106, 106, 106, 106, 34, 34, 106, 106, 106, 106, 106, 53, 53, 100, 53, 53, 53
	        DB  106, 54, 54, 53, 106, 106, 106, 106, 106, 106, 34, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 54, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57
	        DB  34, 106, 106, 106, 53, 53, 100, 100, 106, 106, 106, 106, 54, 53, 53, 53, 100, 100, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 106, 106, 106, 106, 106, 106, 34, 34, 34, 106
	        DB  106, 106, 106, 106, 53, 53, 100, 53, 53, 106, 106, 54, 54, 53, 106, 106, 106, 106, 106, 34, 34, 34, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 53, 53, 54, 106, 106, 34, 34, 57
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 54, 53, 100, 100, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 106
	        DB  106, 106, 106, 106, 106, 34, 201, 201, 34, 106, 106, 106, 106, 106, 53, 53, 100, 53, 53, 106, 106, 54, 54, 53, 106, 106, 106, 106, 106, 34, 34, 34, 106, 106, 106, 106, 106, 53, 53, 53
	        DB  100, 100, 100, 53, 53, 54, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 34, 106, 106, 106, 54, 53, 100, 100, 106, 106, 106, 106, 106, 54, 53, 100, 100, 106, 106, 106
	        DB  106, 106, 106, 106, 53, 53, 53, 100, 100, 106, 106, 106, 106, 106, 34, 201, 201, 201, 34, 106, 106, 106, 106, 106, 53, 53, 100, 53, 53, 106, 106, 54, 54, 53, 106, 106, 106, 106, 106, 34
	        DB  34, 34, 106, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100, 53, 53, 54, 106, 106, 106, 34, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 54, 100, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 100, 100, 106, 106, 106, 106, 106, 106, 106, 54, 53, 53, 100, 100, 106, 106, 106, 106, 34, 34, 201, 201, 201, 34, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 54
	        DB  54, 54, 53, 53, 106, 106, 106, 106, 34, 34, 201, 34, 106, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100, 100, 53, 54, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  57, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 100, 106, 106, 106, 106, 106, 34, 34, 201, 201, 201, 34, 106
	        DB  106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 34, 34, 201, 201, 34, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100, 100, 53, 53, 106, 106, 106, 34
	        DB  34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 34, 34, 201, 201, 34, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 34, 106, 201, 201, 34, 106, 106, 106, 106, 106, 53, 53
	        DB  100, 100, 100, 100, 53, 53, 54, 106, 106, 106, 34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 106, 106, 106, 106, 106, 34, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 34, 34, 201
	        DB  201, 201, 34, 34, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 100, 53, 54, 106, 106, 106, 34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 34, 34, 34, 57
	        DB  106, 106, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 34, 34, 201, 201, 201, 201, 201, 34, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100, 100, 53, 53, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 201, 106, 57, 57, 34, 57, 57, 106, 201, 201, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 201, 201, 201, 201, 201, 34, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100, 100, 53, 53, 106, 106, 106
	        DB  34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 201, 201, 106, 106, 106, 106, 201, 106, 57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 201, 201, 201, 201, 201, 201, 201, 34, 106, 106, 106, 106, 53
	        DB  53, 100, 100, 100, 100, 53, 53, 106, 106, 106, 106, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 57, 57, 57, 57, 106, 201, 201, 106, 106, 57, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 201, 201
	        DB  201, 201, 201, 201, 34, 106, 106, 106, 106, 53, 53, 100, 100, 100, 100, 53, 53, 54, 106, 106, 106, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 34, 34, 57, 57, 106, 106, 57, 57, 34
	        DB  34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 34, 34, 34, 201, 201, 201, 201, 201, 34, 106, 106, 106, 106, 53, 53, 100, 100, 100, 100, 53, 53, 54, 106, 106, 106, 34, 106, 0, 0, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 106, 106, 106, 106, 106, 0, 0, 0, 0, 106, 57, 57, 34, 34
	        DB  34, 106, 106, 34, 34, 34, 34, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 201, 201, 201, 34, 106, 106, 106, 106, 106, 53, 100, 100, 100, 100, 100, 53, 54, 106, 106
	        DB  106, 34, 57, 57, 57, 57, 34, 34, 34, 34, 34, 57, 57, 57, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 57, 34, 34, 34, 34, 34
	        DB  57, 106, 106, 0, 106, 57, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 34, 34, 34, 34, 34, 57, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 201, 34, 106, 106, 106, 106, 106
	        DB  53, 100, 100, 100, 100, 100, 53, 53, 54, 106, 106, 106, 34, 34, 34, 34, 34, 106, 106, 106, 106, 34, 34, 34, 57, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 106, 106, 57, 34, 34, 34, 34, 34, 34, 34, 57, 106, 106, 106, 57, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 34, 34, 34, 34
	        DB  34, 34, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 34, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 34, 34, 34, 34, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100, 100, 53, 53, 54, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 106, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 57, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 34, 34, 106, 106, 106, 106, 106, 57, 57, 106, 106, 106, 106, 106, 106, 106
	        DB  57, 57, 57, 57, 57, 34, 34, 34, 34, 57, 57, 57, 57, 57, 57, 57, 57, 81, 81, 57, 57, 57, 57, 57, 57, 57, 34, 34, 34, 34, 34, 34, 57, 57, 57, 57, 57, 57, 57, 34
	        DB  34, 34, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100, 100, 53, 53, 54, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 34, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57
	        DB  57, 57, 57, 57, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 34, 34, 34, 34, 57, 57, 57, 57, 57, 57, 57, 81, 81, 57, 57, 57, 57, 57, 57, 57, 34, 34, 34, 34, 57, 57
	        DB  57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 100, 100, 100, 100, 53, 53, 54, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 34, 106, 106, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 106, 106, 57, 57, 57, 57, 57, 57, 34, 34, 34, 34, 34, 57, 57, 57, 57, 57, 57, 81, 81, 57, 57, 57, 57
	        DB  57, 57, 57, 34, 34, 34, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  53, 53, 100, 100, 100, 100, 53, 53, 53, 106, 106, 106, 106, 106, 106, 34, 34, 34, 57, 57, 57, 57, 57, 106, 106, 106, 34, 57, 57, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 34
	        DB  106, 106, 106, 106, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 106, 57, 57, 57, 57, 57, 57, 57, 34, 106, 34, 34, 57, 57, 57
	        DB  57, 57, 81, 81, 81, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 34
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 53, 106, 106, 106, 34, 34, 34, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 34, 57, 106
	        DB  0, 0, 0, 0, 0, 0, 106, 57, 34, 34, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 106, 57, 57, 57, 57, 57
	        DB  106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 81, 81, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 53, 106, 106, 106, 34, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 57, 57, 57, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 106, 106, 34, 34, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57
	        DB  57, 57, 57, 57, 106, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 81, 81, 81, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 53, 106
	        DB  106, 34, 57, 57, 57, 57, 57, 57, 57, 57, 81, 57, 57, 57, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 81, 81, 57, 57, 57, 57, 57, 57, 57, 34, 106
	        DB  106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  53, 53, 53, 100, 100, 100, 53, 53, 53, 106, 34, 34, 57, 57, 57, 57, 57, 57, 57, 81, 81, 57, 57, 57, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106
	        DB  106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 81, 57
	        DB  57, 57, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106, 81, 57, 57, 57, 57, 57, 57, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 53, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 34, 57, 57, 0
	        DB  0, 0, 0, 0, 106, 34, 34, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 57, 57, 57, 57, 57, 81, 57, 57, 34, 57, 57, 57, 57, 57, 34, 34, 106, 106, 106, 81, 57, 57, 57, 57, 57, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 34
	        DB  57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 53, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 106, 106, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 57, 34, 34, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 34, 106, 57, 57, 57, 57, 57, 34, 34, 106, 106, 106, 81, 81, 57, 57, 57, 57, 81, 81
	        DB  106, 106, 106, 34, 34, 34, 34, 34, 106, 34, 57, 81, 81, 81, 57, 57, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 53, 106
	        DB  106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57
	        DB  106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 34, 34, 106, 57, 57, 57, 57, 57, 34, 34, 106
	        DB  106, 106, 81, 81, 57, 57, 57, 57, 34, 106, 106, 106, 106, 34, 57, 57, 57, 57, 106, 34, 57, 81, 81, 81, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 106, 106
	        DB  53, 53, 53, 100, 100, 100, 53, 53, 53, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 34, 57, 57, 0, 0, 0, 106, 106, 34, 34, 106, 106, 106, 57
	        DB  57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 34
	        DB  34, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 81, 81, 81, 57, 57, 57, 34, 106, 106, 106, 106, 34, 57, 57, 57, 57, 106, 34, 57, 81, 81, 81, 106, 57, 57, 57, 57, 57
	        DB  57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 53, 106, 106, 106, 34, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 34, 34, 57, 106
	        DB  0, 0, 106, 57, 34, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 34, 34, 34, 34, 34
	        DB  106, 106, 57, 57, 57, 57, 57, 57, 57, 34, 106, 57, 57, 57, 57, 57, 34, 34, 106, 106, 106, 106, 106, 81, 81, 57, 57, 57, 34, 106, 106, 106, 34, 34, 57, 57, 57, 57, 106, 106
	        DB  57, 81, 81, 81, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 54, 106, 106, 106, 106, 34, 34, 34, 34, 57, 57, 81
	        DB  81, 57, 57, 57, 106, 106, 106, 34, 34, 106, 0, 0, 106, 57, 34, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 57, 57, 57, 57, 81, 81, 57, 57
	        DB  57, 106, 106, 106, 106, 34, 57, 57, 57, 34, 106, 106, 57, 57, 57, 57, 57, 57, 57, 106, 34, 57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 106, 106, 81, 81, 57, 57, 57, 34, 106
	        DB  106, 106, 34, 57, 57, 57, 57, 106, 106, 106, 57, 81, 81, 81, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 106, 106
	        DB  106, 106, 106, 34, 34, 34, 34, 57, 57, 81, 81, 57, 57, 57, 106, 106, 106, 34, 34, 106, 0, 0, 57, 34, 34, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106
	        DB  106, 106, 57, 57, 57, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 34, 106, 106, 57, 34, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106
	        DB  106, 106, 106, 81, 81, 81, 81, 57, 57, 57, 57, 57, 57, 57, 81, 81, 81, 106, 106, 106, 106, 57, 57, 106, 106, 106, 106, 57, 57, 57, 57, 81, 57, 57, 57, 106, 106, 106, 106, 106
	        DB  53, 53, 53, 100, 100, 100, 53, 53, 106, 106, 106, 106, 106, 106, 106, 34, 57, 57, 57, 81, 81, 57, 57, 57, 106, 106, 106, 34, 34, 106, 0, 106, 57, 34, 106, 106, 106, 57, 57, 57
	        DB  57, 57, 57, 81, 57, 57, 57, 57, 57, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 34, 106, 106, 57, 34, 106, 106, 81, 57, 57, 57, 57, 57, 57, 57
	        DB  57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57
	        DB  57, 81, 81, 57, 57, 57, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 106, 106, 106, 106, 106, 34, 34, 57, 57, 57, 81, 81, 81, 57, 57, 57, 106, 106, 106, 34, 34, 106
	        DB  0, 106, 34, 34, 106, 106, 106, 57, 57, 57, 57, 57, 57, 81, 81, 57, 57, 57, 57, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 34, 106, 106, 57, 34
	        DB  106, 106, 81, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 81, 81, 81, 81, 81, 81, 81, 81, 81, 106, 106, 106, 34, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 81, 81, 57, 57, 57, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 106, 106, 106, 106, 106, 34, 34, 57, 57, 57, 81, 81
	        DB  81, 57, 57, 57, 106, 106, 106, 34, 57, 106, 0, 106, 34, 34, 106, 106, 106, 57, 57, 57, 57, 57, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57
	        DB  57, 106, 106, 106, 34, 34, 106, 106, 57, 34, 106, 106, 81, 81, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 81, 81
	        DB  81, 106, 106, 106, 106, 106, 106, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 81, 81, 81, 57, 57, 57, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 53, 106, 106
	        DB  106, 106, 34, 34, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 34, 34, 57, 0, 0, 106, 34, 34, 106, 106, 106, 57, 57, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106
	        DB  106, 106, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 34, 57, 106, 106, 57, 34, 106, 106, 106, 81, 81, 81, 57, 57, 57, 57, 57, 57, 57, 34, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 57, 57, 81, 81, 81, 57, 57, 57, 106, 106, 106
	        DB  53, 53, 53, 100, 100, 100, 53, 106, 106, 106, 106, 106, 57, 57, 57, 57, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 34, 57, 106, 0, 106, 106, 34, 34, 106, 106, 106, 57, 57, 57
	        DB  57, 81, 81, 81, 57, 57, 57, 57, 106, 106, 106, 57, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 34, 57, 201, 106, 106, 34, 106, 106, 106, 81, 81, 81, 81, 57, 57, 57
	        DB  57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 34, 34, 34, 34, 106, 106, 106, 106, 106, 57
	        DB  57, 81, 81, 81, 57, 57, 57, 106, 106, 106, 53, 53, 53, 100, 100, 100, 53, 106, 106, 106, 106, 106, 57, 57, 57, 57, 81, 81, 57, 57, 57, 106, 106, 106, 106, 106, 34, 57, 106, 0
	        DB  106, 57, 34, 34, 106, 106, 106, 57, 57, 57, 57, 81, 81, 81, 57, 57, 57, 57, 106, 106, 106, 57, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 34, 57, 201, 201, 106, 57
	        DB  34, 106, 106, 106, 106, 81, 81, 81, 81, 81, 81, 106, 106, 106, 106, 106, 106, 106, 34, 34, 201, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 201, 201
	        DB  106, 34, 34, 34, 106, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 106, 53, 53, 53, 100, 100, 53, 53, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57
	        DB  106, 106, 106, 106, 106, 34, 57, 106, 0, 0, 106, 57, 34, 106, 106, 106, 106, 57, 57, 57, 57, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 81, 57, 57
	        DB  57, 106, 106, 106, 34, 57, 201, 201, 201, 106, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 201, 34, 34, 106, 106, 106, 106, 106, 34, 34, 34
	        DB  57, 57, 106, 106, 106, 106, 106, 34, 201, 201, 201, 201, 201, 106, 106, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 106, 53, 53, 53, 100, 100, 53, 53, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 57, 106, 0, 0, 0, 106, 57, 34, 106, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106
	        DB  106, 57, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 34, 57, 201, 201, 201, 106, 34, 106, 106, 106, 106, 106, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 34, 34, 106, 201
	        DB  34, 34, 106, 106, 106, 106, 34, 34, 34, 57, 57, 57, 34, 106, 106, 106, 106, 34, 201, 201, 201, 201, 201, 201, 106, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 106
	        DB  53, 53, 100, 100, 100, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 57, 57, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 106, 57, 57, 57
	        DB  81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 34, 57, 201, 0, 201, 57, 34, 106, 106, 106, 106, 34, 34, 34, 57, 106
	        DB  106, 106, 106, 106, 106, 34, 34, 201, 201, 201, 34, 34, 106, 106, 106, 106, 34, 34, 57, 57, 81, 81, 57, 106, 106, 106, 106, 34, 201, 201, 201, 201, 201, 201, 106, 106, 106, 106, 106, 57
	        DB  57, 81, 81, 81, 81, 57, 57, 106, 106, 106, 53, 100, 100, 100, 100, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 57, 106, 106, 0, 0, 0, 0
	        DB  106, 57, 34, 106, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 34, 57, 0, 0, 0, 57
	        DB  106, 106, 106, 34, 34, 34, 57, 57, 57, 57, 106, 106, 106, 106, 106, 34, 201, 201, 201, 201, 34, 106, 106, 106, 106, 34, 34, 34, 57, 57, 81, 81, 57, 106, 106, 106, 106, 106, 201, 201
	        DB  201, 201, 201, 201, 34, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 53, 53, 100, 100, 100, 100, 53, 106, 106, 106, 106, 34, 34, 34, 34, 106, 106, 106, 106, 34, 34
	        DB  34, 57, 57, 106, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 81, 57, 57
	        DB  57, 106, 106, 106, 106, 57, 0, 0, 0, 57, 106, 106, 106, 34, 34, 34, 57, 57, 81, 57, 106, 106, 106, 106, 106, 34, 201, 201, 201, 201, 106, 106, 106, 106, 106, 106, 34, 57, 57, 57
	        DB  81, 106, 106, 106, 106, 106, 34, 106, 201, 201, 201, 201, 201, 201, 34, 106, 106, 106, 106, 57, 57, 57, 81, 81, 81, 57, 57, 106, 106, 53, 53, 100, 100, 100, 53, 53, 106, 106, 106, 106
	        DB  34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 57, 106, 106, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 34, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 57, 57, 57, 57, 106, 106
	        DB  106, 106, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 57, 106, 0, 0, 57, 34, 106, 106, 106, 34, 57, 81, 81, 81, 106, 106, 106, 106, 106, 106, 34, 201, 106, 34, 34
	        DB  106, 106, 106, 106, 106, 106, 106, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 201, 201, 201, 201, 201, 201, 34, 34, 106, 106, 106, 57, 57, 57, 81, 81, 81, 57, 57, 106, 106, 53
	        DB  53, 53, 100, 100, 53, 53, 106, 106, 106, 34, 57, 57, 106, 57, 57, 57, 57, 57, 57, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 34, 106, 106, 106, 57, 57, 57
	        DB  81, 81, 81, 81, 57, 57, 57, 57, 106, 106, 106, 106, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 34, 106, 0, 0, 106, 34, 34, 106, 106, 106, 57, 57, 57, 57, 106
	        DB  106, 106, 106, 106, 34, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 106, 106, 106, 201, 201, 201, 34, 34, 106, 106, 106, 57
	        DB  57, 81, 81, 81, 81, 57, 57, 106, 106, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 106, 34, 34, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 57, 57, 57, 57, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 34, 106, 0, 0, 106
	        DB  34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34
	        DB  106, 106, 106, 201, 34, 34, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 53, 53, 53, 53, 53, 53, 106, 106, 106, 34, 34, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 57, 57, 57, 57, 57, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57
	        DB  57, 106, 106, 106, 106, 34, 106, 0, 0, 0, 57, 57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 34, 34, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 106, 53, 53, 53, 53, 106, 106, 106, 34, 34, 57
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 34, 34, 106, 106, 106, 57, 57, 81, 81, 81, 81, 81, 57, 57, 57, 57, 106
	        DB  106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 106, 106, 34, 106, 0, 0, 0, 106, 106, 57, 34, 34, 34, 34, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 54, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 106
	        DB  53, 53, 53, 53, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 57, 34, 106, 106, 106, 57, 57
	        DB  57, 81, 81, 81, 81, 57, 57, 57, 57, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 106, 106, 34, 106, 0, 0, 0, 0, 106, 57, 57, 34, 34, 34, 34, 34, 34
	        DB  34, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 34, 34, 106, 106, 106, 57
	        DB  57, 81, 81, 81, 81, 57, 57, 106, 106, 106, 53, 53, 53, 53, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 106, 57, 34, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 57, 106, 106, 106, 106, 34, 57, 106, 0, 0
	        DB  0, 0, 0, 106, 106, 57, 57, 57, 106, 34, 34, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106
	        DB  106, 106, 106, 106, 106, 34, 106, 106, 106, 57, 57, 81, 81, 81, 57, 57, 106, 106, 106, 106, 53, 53, 53, 53, 106, 106, 106, 34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 34, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 106, 106, 57, 57, 81, 81, 81
	        DB  57, 57, 106, 106, 106, 34, 34, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 34, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 81, 81, 81, 57, 57, 106, 106, 106, 106, 53, 53, 53, 106, 106, 106, 34, 57, 57, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 34, 106, 106, 106, 57, 57, 81, 81, 81, 81, 81, 81, 57, 57, 106
	        DB  106, 106, 106, 106, 106, 57, 57, 57, 81, 57, 57, 57, 106, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 34, 106, 106, 106, 106, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 81, 81, 81, 57, 57, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 34, 34, 106, 106, 106
	        DB  57, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34
	        DB  106, 106, 106, 106, 53, 53, 53, 53, 53, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 57, 81
	        DB  81, 81, 81, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 106, 57, 57, 81, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 57, 57, 57, 57, 106, 106, 106, 34, 57, 106, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 106, 106, 106, 106, 53, 53, 53, 100, 100, 100, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 100, 100, 100, 53, 53, 53
	        DB  53, 53, 53, 106, 106, 106, 106, 106, 57, 81, 81, 81, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 106, 57, 57, 57, 81, 81, 81, 81, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  57, 57, 57, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 106, 106, 106, 106, 53, 53, 100, 100, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 100, 100, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 57, 57, 81, 81, 57, 57, 106, 106, 106, 106, 34, 34, 34, 34, 34, 34, 34, 57, 106, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 106, 106, 57, 81, 81, 81, 81, 57, 57
	        DB  57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 106, 106, 106, 106, 53, 53, 53, 53, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 100, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 106, 106, 106, 34, 57, 57
	        DB  57, 57, 57, 57, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 34, 106
	        DB  106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106
	        DB  106, 106, 106, 106, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 100, 100, 106, 106, 106, 106, 106, 57, 57
	        DB  57, 57, 106, 106, 106, 106, 106, 34, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 57, 34, 34, 106, 106, 106, 106, 57, 57, 57, 57, 57, 57, 57, 106, 106, 106, 106, 34, 34, 34, 34, 106, 106, 106, 106, 106, 34, 34, 106, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53
	        DB  53, 100, 100, 106, 106, 106, 106, 106, 57, 57, 57, 57, 106, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 34, 106, 106, 106, 106, 106, 57, 57, 57, 57, 57, 106, 106, 106, 34, 34, 106, 106, 57, 57
	        DB  34, 34, 34, 57, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 34, 106, 106, 106, 106, 54, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 100, 100, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 34, 34, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 34, 34, 57, 106, 0, 106, 106, 106, 106, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 54, 53, 53, 100, 53, 53, 53, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 100, 100, 100, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 57, 57, 106, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106
	        DB  57, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 57, 34, 106
	        DB  106, 106, 53, 53, 53, 100, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 100, 100, 100, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 34, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 34, 106, 106, 106, 106, 106, 106, 106, 34, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 57, 34, 106, 106, 106, 53, 53, 53, 100, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 100, 100, 100
	        DB  106, 106, 106, 106, 34, 34, 34, 34, 106, 106, 106, 34, 34, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 34, 106, 106, 106, 106, 106, 34, 34, 57, 57, 106, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 34, 106, 106, 106, 53, 53, 100, 100, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 53, 53, 53, 53, 53, 100, 100, 100, 106, 106, 106, 106, 34, 34, 34, 34, 34, 34, 34, 34, 57, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 34, 34, 34, 34
	        DB  34, 34, 57, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 34, 106, 106, 106, 53, 100, 100, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 53, 53, 53, 53, 100, 100, 100, 106, 106, 106, 106, 106, 34, 57, 106, 106, 57, 57, 57, 57, 57, 106, 106, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 106, 106, 106, 57, 57, 57, 57, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 34, 106, 106
	        DB  106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 53, 100, 100, 100, 100, 100, 106, 106, 106, 106, 106, 34, 34, 106, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 106, 106, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 57, 34, 34, 106, 106, 54, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 53, 100, 100, 100, 100, 100, 106, 106, 106
	        DB  106, 34, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 53, 53, 53, 106, 106, 106, 106, 53, 53, 53, 53, 100, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106, 106, 106, 53, 53, 53, 53, 53, 53, 53, 53
	        DB  53, 53, 53, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 34, 106, 106, 34, 34, 34, 57, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 34, 106
	        DB  106, 106, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 100, 106, 106, 106, 106, 34, 34, 34, 34, 34, 34, 34, 34, 34, 106, 34, 34, 57, 57, 106, 106, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 106, 57, 106, 106, 106, 106, 106, 53, 53, 53, 53, 53, 53, 100, 100, 100, 106, 106, 106, 34, 34, 57, 57, 57, 57, 106, 106, 57, 34, 34, 57, 106, 106
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 106, 34, 34, 34, 57, 106, 0
	        DB  106, 0, 0, 0, 106, 106, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 34, 106, 106, 106, 106, 106, 106, 106, 106, 106
	        DB  106, 106, 106, 34, 34, 34, 57, 57, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57
	        DB  34, 34, 34, 34, 106, 53, 53, 53, 53, 106, 106, 34, 34, 57, 57, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 106, 106, 106, 106, 57, 34, 106, 106, 106, 34, 106, 106, 106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 34, 106, 106, 34, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 106, 57, 57, 57, 106
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	        DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	


 


	
	
	extra ENDS
;///////////////////////////////Extra segment////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////
;///////////////////////////////Data segment////////////////////////////////////
.data
	; initializations
	REV                      DB           0
	Ers                      DB           0
	;////////////////////////////////
	; keys
	key_upArrow              equ          048h
	key_downArrow            equ          050h
	key_leftArrow            equ          04Bh
	key_rightArrow           equ          04Dh

	key_enter                equ          01ch
	key_esc                  equ          1Bh

	key_w                    equ          11h
	key_s                    equ          1FH
	key_a                    equ          1EH
	key_d                    equ          20h
	key_f                    equ          21h
	key_y                    equ          15H
	key_n                    equ          31H
	;////////////////////////////////
	; constrains depend on the graphics mode
	graphicsModeAX           equ          4F02h
	graphicsModeBX           equ          0100h
	delayDuration            equ          260
	;DRAW FUNCS PARAMETERS
	background_Game_Color    equ          0C5h
	;
	RECXEND                  DW           640
	RECYEND                  DW           400
	RECXSTART                DW           0
	RECYSTART                DW           0
	RECCOLOR                 DB           0B3h
	;
	BorderXEND               DW           00
	BorderYEND               DW           00
	BorderXSTART             DW           00
	BorderYSTART             DW           00
	BorderBRIGHTColor        DB           00
	BorderDARKColor          DB           00
	BorderMIDDLED1           DW           00
	BorderMIDDLE             DW           00
	BorderMIDDLED2           DW           00
	;
	shipOffsetX1             dw           30                                                                                                                                                                                                    	;position of first from left pixel
	shipOffsetY1             dw           219                                                                                                                                                                                                   	;position of first from top pixel
	shipSizeX                equ          32                                                                                                                                                                                                    	;img Width
	shipSizeX                equ          32                                                                                                                                                                                                    	;img Height
	screenMaxY1              equ          370
	screenMaxX1              equ          320
	screenMinY1              equ          100
	screenMinX1              equ          4
	;
	shipOffsetX2             dw           578                                                                                                                                                                                                   	;position of first from left pixel
	shipOffsetY2             dw           219
	shipSizeX2               equ          32                                                                                                                                                                                                    	; ship's Width
	shipSizeY2               equ          32
	screenMinY2              equ          100
	screenMinX2              equ          320
	screenMaxY2              equ          370
	screenMaxX2              equ          640
	;
	SHIP_DAMAGE_COLOR        db           04h
	SHIP_DAMAGE_EFFECT_DELAY equ          650
	HEALTH_ANGRY             EQU          100
	ExplosionOffsetX         dw           0
	ExplosionOffsetY         dw           0
	ExplosionItr             db           6
	ExplosionDelay           equ          1100
	shipSpeed1               equ          4
	shipSpeed2               equ          4
	;////////////////////////////////
	; main menu buttons
	gamebtnOffset            dw           226, 204
	chatbtnOffset            dw           226, 268
	exitbtnOffset            dw           226, 332
	btnsize                  dw           188, 56
	;
	                         logoOffset   label word
	logoOffsetX              dW           190
	logoOffsetY              DW           8
	logoOffsetX2             dW           255
	logoOffsetY2             DW           100
	logoSizeX                equ          130
	logoSizeY                equ          95
	
	shapeOffsetX             DW           0
	shapeOffsetY             DW           0
	shapeSizeX               DW           0
	shapeSizeY               DW           0
	;
	                         arrowOffset  label word
	arrowOffsetX             dw           184
	arrowOffsetY             dw           216
	arrowOffsetXRev          dw           424
	arrowSizeX               equ          32
	arrowSizeY               equ          32
	arrowStep                equ          64
	arrowAtgame              equ          216
	arrowAtChat              equ          280
	arrowAtExit              equ          344
	;////////////////////////////////
	; getting players' names	                                                                                                                                                                                      	;don't make this 0
	getName1                 DB           "  Player1 Name: $"
	getName2                 DB           "  Player2 Name: $"
	;
	enterValidName           DB           "  Please, enter a valid name: $"
	enterShorterName         DB           "  Please, enter a shorter name: $"
	;
	playerName1              DB           10,?,10 dup("$")
	playerName2              DB           10,?,10 dup("$")
	maxPlayerSize            equ          7
	;////////////////////////////////
	; some text screens
	                         firstScreen  label byte
	                         DB           '  ',0ah,0dh
	                         DB           '  ',0ah,0dh
	                         DB           '  ',0ah,0dh
	                         DB           '  ',0ah,0dh
	                         DB           '  ',0ah,0dh
	                         DB           09,'                                                       ||',0ah,0dh
	                         DB           09,'                                                       ||',0ah,0dh
	                         DB           09,'  =====================================================||',0ah,0dh
	                         DB           09,'     ||                                                ||',0ah,0dh
	                         DB           09,'     ||            #### FE L FDA SWAAA ####            ||',0ah,0dh
	                         DB           09,'     ||                                                ||',0ah,0dh
	                         DB           09,'     ||------------------------------------------------||',0ah,0dh
	                         DB           09,'     ||                                                ||',0ah,0dh
	                         DB           09,'     ||       Please, Enter your name(max 7 chars)     ||',0ah,0dh
	                         DB           09,'     ||       Then, choose your favourite character    ||',0ah,0dh
	                         DB           09,'     ||                                                ||',0ah,0dh
	                         DB           09,'     ||           **press any key to continue**        ||',0ah,0dh
	                         DB           09,'     ||                                                ||',0ah,0dh
	                         DB           09,'     || =====================================================',0ah,0dh
	                         DB           09,'     ||                                                  ',0ah,0dh
	                         DB           09,'     ||                                                  ',0ah,0dh
	                         DB           '$',0ah,0dh
	                         winnerWinner label byte
	                         DB           '  ',0ah,0dh
	                         DB           '  ',0ah,0dh
	                         DB           '  ',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'   ================================||',0ah,0dh
	                         DB           09,09,'       ||       Winner Winner!     ||',0ah,0dh
	                         DB           09,09,'       ||       chicken Dinner     ||',0ah,0dh
	                         DB           09,09,'       || ================================',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           '$',0ah,0dh
	                         byebye       label byte
	                         DB           '  ',0ah,0dh
	                         DB           '  ',0ah,0dh
	                         DB           '  ',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'                                   ||',0ah,0dh
	                         DB           09,09,'   ================================||',0ah,0dh
	                         DB           09,09,'       ||           Bye Bye        ||',0ah,0dh
	                         DB           09,09,'       || ================================',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           09,09,'       ||                           ',0ah,0dh
	                         DB           '$',0ah,0dh
				   
	;//////////////////////////////////////Art/////////////////////////////////////////////
	; For Bullets, health and damage
	Bullet                   DB           0, 0, 43, 43, 43, 43, 43, 43, 43, 43, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 44, 0, 0, 68, 68, 68, 68, 68, 68
	BulletXSize              equ          8
	BulletYSize              equ          4
	BulletSpeed              DB           1
	MAXBULLET                equ          100
	BulletOffset             DW           200 DUP(0)
	BulletDirection          DB           100 DUP(0)
	MAXBULLETLEFT            equ          631
	MAXBULLETRIGHT           equ          8
	;
	HEALTH1                  DB           200
	HEALTH2                  DB           200
	DAMAGE                   equ          5
	ISNEWGAME                db           0
	;////////////////////////////////
	; messages
	congrats                 DB           " is the Winner, Congrats!", "$"
	NewEndGame               DB           " Press Y For New Game (suprise!!!), N To return to the main menu ", "$"


	MSGTAILXsize             equ          16
	MSGTAILYsize             equ          16
	MSGTAILXoffset1          dw           110 - MSGTAILXsize
	MSGTAILXoffset2          dw           530
	MSGTAILYoffset1          dw           15
	MSGTAILYoffset2          dw           55

	MSGTAIL                  DB           26, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 26, 18, 18, 18, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 26, 26, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 26, 26, 26, 26, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           26, 26, 26, 26, 26, 26, 18, 18, 18, 0, 0, 0, 0, 0, 0, 0, 26, 26, 26, 26, 27, 26, 26, 18, 18, 18, 0, 0, 0, 0, 0, 0, 26, 26, 26, 27, 27, 27, 26, 26
	                         DB           18, 18, 18, 0, 0, 0, 0, 0, 26, 26, 26, 27, 27, 27, 27, 26, 26, 18, 18, 18, 0, 0, 0, 0, 26, 26, 26, 27, 27, 27, 27, 27, 26, 26, 18, 18, 18, 0, 0, 0
	                         DB           26, 26, 26, 27, 27, 27, 27, 27, 27, 26, 26, 18, 18, 18, 0, 0, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 26, 26, 18, 18, 18, 0, 26, 26, 26, 26, 27, 27, 27, 27
	                         DB           27, 27, 27, 26, 26, 18, 18, 0, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 18, 0, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 0, 0, 0
	;//////////////////////////////////////Art/////////////////////////////////////////////
	;game layout
	CharacteroffsetX         dw           7
	CharacteroffsetX2        dw           568                                                                                                                                                                                                   	;position of first from left pixel                                                                                                                                                                                              	;position of first from left pixel
	CharacteroffsetY         dw           13                                                                                                                                                                                                    	;position of first from top pixel
	CharacterSizeX           equ          64                                                                                                                                                                                                    	;img Width
	CharacterSizeY           equ          64

	NameBoxSizeX             equ          82
	NameBoxSizeY             equ          26

	; Characters
	charSizeX                equ          64
	charSizeY                equ          64
	firstCharOffsetX         equ          80
	secondCharOffsetX        equ          184
	thirdCharOffsetX         equ          288
	fourthCharOffsetX        equ          392
	fifthCharOffsetX         equ          496
	charOffsetY              equ          230

	; Player ID
	playerID1                db           0
	playerID2                db           0

	; pointer of the 'choose character menu'
	pointerAt                DB           0
	pointerAtFirstChar       equ          60
	pointerAtFifthChar       equ          476
	pointerStep              equ          104
	pointerSizeX             equ          16
	pointerSizeY             equ          16
	pointerOffsetX           dw           60
	pointerOffsetY           equ          230

	Mikasa2                  DB           0, 0, 91, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 6, 114, 114, 114, 114, 114, 114, 114, 113, 113, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 26, 30, 30, 30
	                         DB           30, 26, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 91, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114
	                         DB           6, 114, 114, 114, 114, 114, 114, 114, 113, 113, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 26, 30, 30, 30, 30, 26, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	                         DB           6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 91, 91, 114, 114, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 114, 6, 114, 114, 114, 114, 114, 114, 113, 113, 113, 113, 113, 4, 4, 4
	                         DB           4, 113, 113, 113, 26, 30, 30, 30, 30, 26, 114, 114, 6, 6, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 0, 91, 91, 91, 114, 114
	                         DB           6, 6, 6, 6, 6, 6, 114, 114, 114, 6, 114, 114, 114, 114, 114, 114, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 26, 26, 26, 30, 30, 26, 114, 114, 114, 114, 114, 114
	                         DB           6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 6, 6, 0, 0, 0, 0, 0, 91, 91, 91, 114, 114, 114, 6, 6, 6, 114, 114, 6, 114, 114, 114, 114, 114, 114, 113
	                         DB           113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 26, 26, 26, 26, 114, 114, 114, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 114, 114, 114, 114
	                         DB           0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 114, 114, 114, 114, 114, 6, 114, 114, 114, 114, 114, 114, 113, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 113
	                         DB           26, 26, 114, 114, 114, 114, 6, 6, 114, 114, 6, 6, 6, 114, 114, 114, 114, 114, 6, 6, 6, 114, 114, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 114, 6
	                         DB           114, 114, 114, 114, 114, 114, 114, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 114, 114, 114, 114, 6, 6, 6, 6, 114, 114, 114, 114, 6, 114
	                         DB           114, 114, 114, 114, 114, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 114, 6, 114, 114, 114, 114, 114, 114, 114, 4, 4, 4, 4, 4, 4, 4, 4, 4
	                         DB           4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 114, 114, 114, 114, 6, 6, 6, 6, 114, 6, 6, 6, 6, 6, 114, 114, 114, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 114, 6, 114, 114, 114, 114, 114, 113, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 4, 4, 4, 4, 114, 114, 114, 6, 6, 6
	                         DB           6, 6, 114, 114, 6, 114, 114, 114, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 6, 114, 114, 114, 114, 114, 114, 113, 4, 4
	                         DB           4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 4, 4, 4, 114, 114, 114, 6, 6, 6, 6, 6, 6, 114, 114, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 6, 114, 114, 114, 114, 114, 113, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 113, 113, 113, 113, 113, 113, 4, 113, 113
	                         DB           113, 4, 114, 114, 6, 6, 6, 6, 6, 6, 6, 114, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 114
	                         DB           114, 114, 114, 114, 113, 4, 4, 4, 4, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 4, 4, 114, 114, 6, 6, 6, 6, 6, 6, 6, 114, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 114, 114, 114, 113, 4, 4, 4, 113, 113, 4, 4, 4, 4, 4, 4
	                         DB           113, 113, 113, 4, 113, 113, 4, 113, 113, 113, 114, 114, 114, 114, 114, 6, 6, 6, 6, 114, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 114, 114, 113, 4, 4, 113, 113, 4, 4, 4, 4, 4, 113, 113, 113, 113, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 113, 113, 114, 6
	                         DB           6, 6, 6, 18, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 113, 113, 113, 113
	                         DB           4, 4, 4, 4, 4, 113, 113, 113, 113, 113, 113, 113, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 114, 114, 18, 6, 114, 18, 18, 91, 91, 18, 91, 91, 91, 91, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 0, 0, 0, 0, 91, 91, 113, 113, 4, 4, 4, 4, 4, 4, 113, 113, 90, 90, 90, 113, 113, 113, 113, 113, 4
	                         DB           4, 4, 4, 4, 4, 4, 91, 91, 18, 114, 91, 18, 18, 91, 91, 18, 18, 91, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 91, 91
	                         DB           91, 91, 0, 0, 91, 91, 113, 4, 4, 4, 4, 4, 113, 90, 90, 90, 90, 90, 90, 90, 113, 113, 113, 113, 113, 4, 4, 4, 4, 113, 91, 91, 18, 18, 91, 18, 18, 18, 91, 18
	                         DB           18, 91, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 91, 91, 18, 91, 91, 91, 91, 91, 113, 4, 4, 113, 4, 113, 90, 90, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 65, 113, 113, 113, 113, 113, 4, 113, 18, 91, 18, 18, 91, 18, 18, 18, 91, 91, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 91, 91, 18, 18, 91, 18, 91, 18, 18, 91, 91, 113, 113, 4, 113, 113, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 160, 113, 113, 113, 91, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 91, 18, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 91, 18, 91, 18, 18, 91, 91, 91, 113
	                         DB           113, 113, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 160, 65, 65, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 18, 18, 18, 18, 18, 91, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 91, 91, 113, 90, 90, 90, 90, 160, 160, 160, 160, 90, 90, 90, 90, 90, 90, 90
	                         DB           90, 65, 65, 160, 65, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 91, 0, 91, 91, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 65, 160, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 91, 65, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 65, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 91, 91, 65, 90, 90, 90, 90, 65, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 65, 18, 91, 18
	                         DB           18, 18, 18, 19, 18, 18, 18, 18, 18, 18, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 65, 90
	                         DB           90, 90, 90, 65, 65, 160, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 18, 18, 18, 18, 18, 18, 19, 18, 91, 91
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 90, 90, 90, 90, 90, 65, 65, 160, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           90, 90, 90, 65, 65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 18, 18, 18, 19, 18, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 65, 90, 90, 90, 90, 90, 90, 65, 65, 160, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 18, 18
	                         DB           18, 19, 18, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 90, 90, 90, 90, 90, 90, 90, 65, 160, 90
	                         DB           90, 90, 18, 65, 90, 90, 90, 90, 90, 90, 90, 90, 65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 18, 18, 18, 19, 18, 19, 18, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 18, 18, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 18, 18, 19
	                         DB           19, 18, 19, 19, 19, 18, 19, 19, 18, 19, 18, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 65, 65, 65
	                         DB           65, 90, 90, 90, 90, 90, 18, 19, 19, 18, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19, 18, 19, 18, 19, 19, 19, 18, 91
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 29, 236, 236, 236, 65, 90, 90, 65, 18, 19, 19, 18, 65, 65, 65, 65, 65, 65, 65
	                         DB           90, 90, 90, 90, 65, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19, 19, 19, 18, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 16, 29, 29, 236, 16, 236, 29, 16, 65, 18, 18, 19, 18, 65, 65, 29, 236, 236, 236, 236, 29, 65, 90, 90, 90, 65, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19
	                         DB           19, 19, 18, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 16, 26, 16, 16, 16, 16, 65, 18, 18, 19, 19, 18
	                         DB           65, 29, 29, 236, 16, 16, 236, 29, 29, 16, 65, 65, 160, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19, 19, 19, 19, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 16, 16, 16, 16, 16, 16, 16, 18, 18, 19, 19, 18, 65, 16, 26, 16, 16, 16, 16, 16, 16, 65, 65, 18, 160, 18, 18, 19
	                         DB           19, 18, 19, 19, 19, 18, 19, 19, 19, 19, 19, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 65, 65, 19
	                         DB           19, 18, 18, 18, 18, 19, 18, 65, 19, 19, 16, 16, 16, 16, 16, 16, 16, 65, 18, 18, 18, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19, 19, 19, 20, 19, 19, 19, 18, 91
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 18, 18, 18, 19, 19, 19, 18, 160, 90, 19, 19, 19, 65, 65, 65, 65
	                         DB           65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 19, 20, 19, 18, 19, 19, 19, 19, 20, 19, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 160, 160, 160, 18, 18, 19, 19, 19, 19, 18, 160, 65, 90, 90, 19, 19, 19, 19, 19, 19, 18, 18, 18, 19, 18, 19, 19, 19, 18, 19, 20, 19, 18, 19, 19
	                         DB           19, 19, 20, 19, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 160, 18, 18, 18, 19, 19, 19, 18, 18, 160
	                         DB           160, 65, 65, 65, 18, 18, 65, 65, 160, 18, 18, 18, 19, 18, 19, 19, 19, 18, 19, 20, 19, 18, 19, 20, 19, 19, 20, 19, 19, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 160, 18, 18, 19, 19, 19, 19, 18, 18, 160, 160, 160, 160, 18, 18, 65, 65, 160, 18, 18, 19, 18, 19, 18, 19, 19
	                         DB           20, 19, 19, 20, 19, 18, 19, 20, 19, 19, 20, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 18, 18
	                         DB           18, 19, 19, 19, 19, 18, 18, 18, 160, 160, 18, 18, 18, 160, 160, 18, 18, 19, 19, 18, 19, 19, 18, 19, 20, 19, 19, 20, 19, 19, 20, 19, 19, 19, 20, 19, 18, 18, 91, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 18, 18, 18, 19, 19, 19, 19, 18, 18, 18, 18, 18, 18, 18, 160, 160, 18, 18
	                         DB           18, 19, 19, 20, 19, 19, 18, 19, 19, 19, 19, 20, 19, 19, 20, 19, 19, 19, 20, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 18, 18, 18, 18, 18, 18, 18, 160, 18, 18, 18, 19, 19, 18, 20, 19, 19, 18, 19, 19, 19, 19, 20, 19, 19, 20, 19
	                         DB           19, 20, 19, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 18, 18, 19
	                         DB           18, 19, 19, 18, 160, 18, 18, 19, 19, 19, 20, 19, 19, 19, 18, 19, 20, 19, 20, 20, 19, 19, 20, 19, 19, 20, 19, 19, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 18, 18, 19, 18, 19, 19, 18, 160, 18, 18, 19, 19, 19, 20, 19, 19, 19, 19, 19
	                         DB           20, 20, 20, 20, 20, 19, 20, 19, 20, 19, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           19, 20, 19, 19, 19, 18, 18, 19, 18, 19, 19, 19, 18, 18, 19, 19, 19, 20, 20, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 20, 21, 19, 19, 18, 18, 91, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 20, 19, 19, 19, 18, 18, 19, 18, 19, 20, 19, 18, 18, 19, 19
	                         DB           19, 20, 20, 19, 19, 19, 19, 20, 21, 20, 20, 20, 21, 20, 20, 20, 21, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18
	                         DB           18, 18, 18, 18, 19, 18, 18, 18, 19, 20, 19, 19, 19, 18, 18, 19, 18, 19, 20, 19, 19, 19, 19, 19, 19, 20, 20, 19, 19, 19, 20, 20, 21, 20, 20, 20, 21, 20, 20, 21
	                         DB           20, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 20, 19, 19, 19, 18, 18, 19
	                         DB           18, 19, 20, 19, 19, 20, 19, 19, 19, 20, 20, 19, 19, 19, 20, 21, 20, 20, 21, 20, 21, 20, 20, 21, 20, 19, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 91, 18, 18, 18, 19, 18, 18, 18, 18, 18, 18, 18, 19, 20, 19, 19, 19, 19, 18, 19, 18, 19, 20, 20, 19, 20, 20, 19, 19, 20, 19, 19, 19, 20, 20, 21
	                         DB           20, 21, 20, 20, 21, 20, 21, 20, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 19, 18, 18, 18, 19, 18, 18, 18
	                         DB           19, 20, 19, 19, 19, 19, 19, 19, 19, 20, 21, 20, 20, 20, 20, 19, 20, 20, 19, 19, 19, 20, 21, 20, 20, 21, 20, 21, 20, 21, 20, 19, 18, 18, 18, 91, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 19, 18, 18, 18, 19, 18, 19, 18, 18, 18, 19, 19, 20, 20, 19, 19, 20, 19, 19, 20, 21, 20, 20, 20, 20, 19
	                         DB           20, 21, 19, 19, 19, 20, 21, 20, 21, 21, 21, 21, 21, 21, 19, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 19, 19
	                         DB           18, 19, 18, 18, 19, 18, 18, 19, 19, 19, 20, 20, 20, 19, 21, 21, 20, 20, 21, 20, 20, 21, 20, 19, 20, 21, 19, 19, 20, 21, 20, 20, 21, 20, 21, 20, 21, 19, 19, 18
	                         DB           18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 19, 18, 18, 18, 18, 19, 18, 18, 19, 19, 19, 20, 21, 20, 20, 20, 21
	                         DB           20, 20, 21, 20, 20, 21, 20, 19, 20, 21, 19, 19, 20, 21, 20, 21, 20, 21, 20, 21, 19, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 91, 18, 19, 18, 18, 19, 19, 18, 18, 19, 19, 19, 19, 21, 21, 20, 20, 21, 20, 20, 21, 20, 20, 21, 20, 19, 20, 21, 19, 19, 20, 20, 20, 20
	                         DB           20, 20, 20, 20, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 19, 19, 19, 19, 19, 18, 18, 18
	                         DB           19, 19, 19, 20, 21, 20, 20, 21, 20, 20, 21, 20, 20, 21, 20, 19, 19, 20, 19, 20, 20, 20, 20, 20, 19, 20, 20, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 19, 19, 19, 19, 19, 18, 19, 19, 19, 19, 20, 20, 21, 20, 20, 21, 20, 20, 21, 20, 20, 20, 19
	                         DB           19, 20, 19, 19, 19, 20, 20, 20, 19, 19, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91
	                         DB           18, 19, 19, 19, 19, 19, 18, 18, 19, 19, 19, 19, 20, 21, 20, 20, 21, 20, 20, 20, 20, 20, 20, 20, 19, 20, 19, 19, 19, 19, 20, 19, 19, 19, 18, 18, 18, 91, 91, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 19, 19, 19, 19, 19, 18, 19, 19, 19, 19, 20, 20, 21, 20
	                         DB           21, 20, 19, 20, 19, 19, 19, 20, 19, 20, 19, 19, 19, 20, 19, 19, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 19, 19, 19, 19, 18, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 19, 20, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19
	                         DB           18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 20, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 18, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 19, 19, 19, 19, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 18, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 18, 18, 18, 18, 18, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 19, 18, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Hisoka2                  DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 35, 107, 107, 107, 107, 58, 58, 58, 58, 58, 107, 107, 107, 107, 107, 58, 35, 35, 107, 86, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86
	                         DB           86, 107, 107, 58, 58, 82, 82, 82, 82, 82, 82, 82, 58, 58, 58, 58, 107, 107, 107, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 35, 58, 107, 107, 107, 107, 107, 107, 107, 107, 82, 82, 58, 58
	                         DB           35, 35, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 107, 107, 88, 88, 88, 88, 88, 88, 88, 88, 107, 107, 107, 107, 58, 35, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 184, 64, 64, 64, 64, 64, 64
	                         DB           64, 64, 64, 88, 64, 88, 88, 88, 107, 107, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 184, 64, 112, 112, 112, 112, 112, 112, 112, 112, 64, 88, 64, 88, 88, 88, 64, 184, 86, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           86, 184, 112, 31, 31, 31, 31, 31, 31, 31, 112, 112, 64, 88, 64, 88, 64, 184, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 88, 112, 64, 88, 64
	                         DB           64, 184, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 31, 88, 88, 88, 31, 31, 31, 31, 88, 88, 112, 64, 88, 64, 184, 86, 0, 0, 0, 0, 86, 86, 86, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 88, 88, 112, 64, 64, 184, 86, 0, 0, 0, 86, 86, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 88, 88, 112, 64, 184, 86, 0, 0, 86, 86, 185
	                         DB           43, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86
	                         DB           112, 31, 112, 88, 88, 88, 88, 88, 88, 112, 112, 31, 31, 31, 88, 112, 112, 184, 86, 0, 86, 86, 185, 68, 43, 43, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 88, 31, 31, 112, 112, 112, 112, 112, 112, 31, 31, 31, 31, 31, 31, 88
	                         DB           112, 184, 86, 0, 86, 185, 68, 43, 43, 43, 43, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 86, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 88, 88, 112, 86, 86, 86, 86, 185, 68, 6, 43, 185, 86, 86, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 31, 31, 31, 31, 88, 88, 112, 86, 86, 86, 86, 185, 6, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 31, 88, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 88, 88, 112, 86, 86, 185, 68
	                         DB           68, 43, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 31
	                         DB           31, 31, 88, 88, 112, 112, 31, 31, 31, 31, 31, 31, 31, 31, 3, 31, 31, 88, 88, 112, 86, 86, 185, 68, 68, 43, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 5, 31, 38, 31, 88, 88, 112, 112, 31, 31, 31, 31, 31, 31, 31, 31, 3, 51, 51
	                         DB           31, 31, 88, 88, 112, 86, 86, 185, 6, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 86, 86, 112, 5, 38, 38, 31, 31, 88, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 3, 51, 51, 31, 31, 88, 88, 88, 112, 185, 68, 68, 43, 185, 86, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 5, 38, 38, 38, 31, 31, 88, 112, 112, 31, 31
	                         DB           31, 31, 31, 31, 31, 3, 51, 51, 31, 31, 31, 88, 88, 88, 112, 68, 68, 43, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 5, 38, 38, 38, 38, 38, 31, 88, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 51, 31, 31, 31, 88, 31, 88, 88, 112, 185
	                         DB           6, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 38, 31
	                         DB           31, 31, 31, 88, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 51, 31, 31, 31, 31, 88, 31, 88, 88, 31, 6, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 31, 38, 31, 31, 31, 31, 31, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 88, 31, 31, 43, 6, 112, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 86, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 88, 31, 43, 43, 88, 112, 86, 86, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 112, 31, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 42, 42, 42, 31, 31, 112, 31, 31, 31, 88, 31, 112, 31, 88, 88, 88, 112, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 112, 42, 68, 42, 31, 112, 31, 31, 31, 31, 31, 31, 112, 31, 42, 68, 42, 31, 112, 31, 31, 31, 88, 31, 31, 88, 112
	                         DB           112, 112, 88, 112, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 112, 112
	                         DB           112, 112, 31, 31, 31, 31, 31, 31, 31, 31, 112, 112, 112, 112, 112, 31, 31, 31, 31, 31, 88, 31, 88, 64, 88, 112, 88, 88, 112, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           88, 112, 31, 88, 31, 31, 88, 88, 64, 64, 112, 88, 112, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           86, 112, 88, 31, 112, 88, 31, 31, 31, 31, 88, 31, 31, 31, 31, 31, 31, 88, 88, 31, 31, 31, 31, 88, 112, 31, 31, 31, 88, 112, 112, 112, 112, 64, 112, 88, 112, 86, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 112, 88, 88, 88, 88, 112, 31, 31, 31, 31, 31
	                         DB           31, 112, 88, 88, 88, 88, 88, 112, 31, 31, 31, 88, 31, 31, 112, 64, 64, 64, 112, 88, 112, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 112, 112, 112, 112, 31, 31, 31, 31, 31, 31, 31, 31, 112, 112, 112, 112, 112, 31, 31, 31, 31, 31, 88, 31, 88, 112
	                         DB           64, 112, 88, 88, 112, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 88, 112, 31, 88, 88, 112, 88, 88, 112, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 112, 112, 31, 88, 88, 88, 112, 5, 5, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86
	                         DB           107, 5, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 5, 5, 112, 112, 112, 112, 5, 5, 5, 5, 107, 86
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 107, 5, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 86, 86, 107, 5, 5, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 5, 5, 5, 5, 5
	                         DB           5, 5, 5, 5, 5, 5, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 5, 5, 38, 112, 88, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 5, 5, 5, 112, 31, 31, 31, 31, 31, 31, 31, 5, 5, 5, 5, 5, 5, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 5, 5
	                         DB           5, 38, 112, 31, 31, 31, 5, 5, 5, 5, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 31, 31, 31, 31, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	                         DB           107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 5, 38, 5, 5, 5, 5, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5
	                         DB           38, 5, 38, 5, 38, 5, 5, 5, 5, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 86, 86, 107, 38, 5, 38, 5, 5, 5, 38, 5, 38, 5, 5, 5, 38, 5, 38, 5, 5, 5, 38, 5, 5, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5
	                         DB           5, 5, 5, 5, 5, 5, 38, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 5, 38, 38, 5, 38, 5, 38, 5, 38, 5
	                         DB           38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 5, 38, 5, 107, 86, 86, 86, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 38, 38, 38, 38, 5, 5, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38
	                         DB           5, 5, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 5, 38, 5, 107, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 38, 38
	                         DB           38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 5, 5, 38, 5, 38, 5, 5, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 38
	                         DB           38, 38, 38, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 5, 38
	                         DB           38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 5, 38, 5, 38, 5, 5, 5, 5, 5, 110, 62, 62, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 86, 110, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 5, 38, 38, 38, 5
	                         DB           38, 5, 38, 5, 38, 5, 5, 5, 110, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 38, 38, 38, 38, 38, 5, 38, 38, 38
	                         DB           38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 62, 110, 86, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 110, 38, 38, 62, 38, 38, 38, 38, 5, 38, 38, 5, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 5
	                         DB           38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 62, 110, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110
	                         DB           38, 38, 38, 38, 38, 38, 38, 38, 62, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 5, 5, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38
	                         DB           110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 38, 38, 38, 38, 38, 38, 38, 62, 5, 5, 38, 62, 38, 38
	                         DB           5, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 5, 5, 38, 38, 38, 62, 38, 38, 38, 38, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 86, 110, 38, 62, 38, 38, 38, 62, 38, 62, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 62, 38, 38, 5, 5, 38, 38, 38, 38, 38
	                         DB           5, 38, 38, 38, 62, 38, 38, 38, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 62, 38, 38, 62, 38
	                         DB           38, 62, 38, 38, 38, 62, 38, 62, 38, 5, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 62, 38, 38, 110, 86, 86, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 110, 62, 38, 62, 38, 62, 38, 38, 38, 62, 38, 38, 38, 62, 38, 38, 38, 5, 38, 38, 38, 62, 38
	                         DB           38, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 62, 38, 38, 38, 110, 62, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           86, 110, 62, 38, 38, 38, 62, 38, 38, 62, 38, 62, 38, 38, 38, 62, 38, 38, 5, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 62, 38, 38, 62
	                         DB           110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 38, 38, 38, 62, 38, 38, 62, 38, 38, 38, 38, 38
	                         DB           62, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38, 38, 62, 38, 62, 38, 38, 62, 62, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38
	                         DB           38, 62, 38, 62, 38, 38, 62, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 38, 38
	                         DB           62, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 62, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 62, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 110, 110, 62, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 62, 38, 38, 38, 38
	                         DB           38, 38, 38, 62, 62, 38, 38, 38, 38, 38, 38, 38, 62, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 86, 86, 86, 86, 110, 62, 62, 110, 38, 38, 38, 62, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38, 62, 62, 62, 62, 62, 62, 62, 38, 38, 38, 110, 86
	                         DB           86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 110, 86, 110, 38, 110, 110
	                         DB           62, 38, 38, 38, 62, 62, 38, 38, 38, 38, 38, 38, 38, 110, 110, 110, 110, 110, 110, 110, 62, 62, 38, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 86, 86, 86, 110, 86, 86, 110, 62, 38, 110, 62, 62, 62, 38, 38, 38, 38, 38, 110, 86, 86, 86
	                         DB           86, 86, 86, 86, 110, 110, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 86, 86, 86, 86, 86, 110, 62, 110, 110, 110, 62, 62, 62, 62, 110, 62, 110, 86, 0, 0, 0, 0, 0, 86, 86, 86, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 86, 86, 86, 110, 110
	                         DB           110, 110, 86, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 86, 0, 86, 86, 86, 86, 86, 86, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Fenn2                    DB           100, 125, 53, 53, 53, 54, 54, 125, 125, 54, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	                         DB           53, 53, 53, 53, 53, 53, 54, 191, 2, 2, 120, 191, 54, 53, 53, 53, 54, 191, 120, 2, 120, 2, 2, 2, 100, 125, 53, 53, 53, 54, 191, 191, 191, 191, 54, 54, 53, 53, 53, 53
	                         DB           53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 54, 191, 2, 2, 2, 120, 191, 54, 53, 53, 53
	                         DB           54, 191, 120, 120, 2, 120, 2, 2, 100, 100, 125, 53, 54, 191, 120, 120, 120, 120, 191, 54, 54, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	                         DB           53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 54, 54, 191, 2, 2, 120, 191, 54, 53, 53, 53, 54, 54, 191, 120, 2, 120, 2, 2, 2, 0, 100, 125, 53, 54, 191, 120, 2
	                         DB           2, 120, 191, 54, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 54, 191, 2
	                         DB           2, 120, 191, 54, 53, 53, 53, 54, 191, 120, 120, 120, 2, 2, 2, 2, 0, 100, 125, 53, 54, 191, 2, 2, 2, 2, 191, 54, 54, 53, 53, 53, 53, 53, 54, 53, 54, 53, 54, 53
	                         DB           54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 53, 53, 54, 54, 191, 2, 2, 2, 120, 191, 54, 53, 53, 54, 191, 120, 120, 2, 120, 2, 2, 2
	                         DB           0, 100, 125, 53, 54, 191, 2, 2, 2, 2, 191, 54, 53, 53, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54
	                         DB           53, 54, 53, 54, 53, 54, 191, 2, 2, 2, 120, 191, 54, 53, 53, 54, 191, 120, 2, 120, 2, 2, 2, 2, 0, 100, 100, 125, 54, 191, 2, 2, 2, 2, 191, 54, 54, 53, 54, 53
	                         DB           54, 53, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 53, 54, 53, 54, 53, 54, 53, 54, 191, 2, 2, 120, 191, 54, 53, 53, 54
	                         DB           120, 120, 120, 120, 2, 2, 2, 2, 0, 0, 100, 125, 54, 191, 2, 2, 2, 2, 191, 54, 53, 54, 53, 54, 53, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54
	                         DB           54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 53, 54, 54, 191, 2, 2, 2, 120, 191, 54, 54, 54, 120, 2, 2, 120, 120, 120, 2, 2, 0, 0, 100, 125, 54, 120, 120, 120
	                         DB           120, 120, 120, 54, 54, 53, 54, 54, 54, 54, 54, 54, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54
	                         DB           191, 2, 2, 120, 120, 120, 120, 120, 2, 2, 46, 46, 46, 71, 120, 2, 0, 0, 100, 100, 125, 120, 2, 46, 2, 46, 120, 54, 54, 54, 54, 125, 125, 125, 125, 125, 27, 27, 27, 27
	                         DB           27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 125, 125, 125, 125, 125, 125, 125, 125, 54, 54, 54, 191, 2, 120, 71, 46, 46, 46, 120, 120, 2, 46, 46, 46, 71, 71, 120
	                         DB           0, 0, 0, 100, 125, 120, 46, 71, 71, 46, 120, 54, 54, 54, 125, 27, 27, 27, 27, 27, 27, 27, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 27, 27, 27, 27
	                         DB           27, 27, 27, 27, 27, 125, 125, 125, 125, 120, 46, 46, 71, 71, 71, 46, 46, 120, 120, 71, 71, 71, 71, 71, 0, 0, 0, 100, 100, 120, 46, 71, 71, 46, 120, 125, 125, 125, 27, 27
	                         DB           27, 27, 27, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 29, 29, 27, 27, 27, 27, 27, 27, 27, 27, 27, 46, 46, 71, 71, 71
	                         DB           71, 46, 46, 71, 71, 71, 71, 71, 0, 0, 0, 0, 100, 120, 46, 71, 71, 46, 120, 27, 27, 27, 27, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 27, 27, 27, 27, 27, 120, 120, 46, 46, 71, 71, 71, 71, 71, 71, 71, 71, 71, 0, 0, 0, 0, 100, 120, 46, 71
	                         DB           71, 46, 120, 27, 27, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 160, 160, 160, 160, 160, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29
	                         DB           27, 27, 27, 27, 27, 120, 120, 46, 46, 46, 46, 71, 71, 71, 71, 71, 0, 0, 0, 0, 100, 100, 120, 71, 71, 46, 27, 27, 29, 29, 30, 30, 30, 30, 30, 30, 30, 160, 160, 160
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 27, 27, 27, 27, 22, 120, 120, 120, 120, 71, 71, 71, 71, 71
	                         DB           0, 0, 0, 0, 0, 100, 100, 120, 120, 120, 29, 29, 29, 30, 30, 30, 30, 30, 30, 160, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 160, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 27, 27, 22, 46, 46, 46, 46, 71, 71, 71, 71, 46, 0, 0, 0, 0, 0, 0, 100, 100, 22, 27, 29, 29, 30, 30, 30, 30
	                         DB           30, 160, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 27, 22, 71
	                         DB           71, 71, 71, 71, 71, 71, 46, 2, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 29, 30, 30, 30, 30, 160, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 160, 160, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 22, 71, 71, 71, 71, 71, 71, 46, 2, 191, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 29, 30, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 65, 160, 30, 30, 30
	                         DB           30, 30, 30, 29, 27, 27, 22, 46, 46, 46, 46, 46, 46, 2, 191, 100, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           183, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 160, 30, 30, 30, 30, 30, 29, 27, 27, 22, 46, 46, 46, 46, 2, 2, 191, 100, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 65, 65, 160, 30, 30, 30, 30, 30, 30, 27, 27, 22, 2, 2, 2, 191, 191, 191, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 30, 29, 160, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 30, 30, 30, 27, 27, 22, 191
	                         DB           191, 191, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 183
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 160, 30, 30, 30, 30, 27, 27, 22, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160
	                         DB           30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           183, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 89, 89, 89, 89, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 27, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 183, 183, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65
	                         DB           65, 160, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 16, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 16, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 27, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 16, 89, 89, 89, 89, 89, 89, 89, 65, 160
	                         DB           30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 160, 30, 30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 30, 30, 29, 160, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 30, 30, 30, 30, 30, 30, 27, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 30, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 30, 30, 30, 30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 30, 30, 30, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 30, 30, 160, 160, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 30, 30, 30, 30, 160, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 160, 160, 160, 160, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 27, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29
	                         DB           29, 29, 29, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 29, 30, 30, 29, 29, 22, 30, 30, 30, 30, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 22, 22, 22, 22, 29, 29, 30, 30, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 29, 29, 22, 22, 22, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 22, 22
	                         DB           22, 22, 22, 100, 100, 100, 22, 29, 30, 30, 30, 30, 30, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 30, 29
	                         DB           27, 22, 100, 23, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 100, 100, 100, 100, 100, 100, 0, 100, 22, 29, 30, 30, 30, 30, 30, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 30, 30, 30, 29, 27, 22, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 30, 30, 30, 30, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           100, 22, 29, 30, 30, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22
	                         DB           29, 30, 30, 30, 30, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 29, 22, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 30, 30, 29, 22
	                         DB           100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 29, 29, 22, 100, 100, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 29, 22, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 22, 22, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 100, 22, 22, 22, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Asta                     DB           0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 67, 67, 67, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 67, 67, 18, 18, 18, 67, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 67, 18, 18, 18, 18, 18, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 67, 18, 18, 20
	                         DB           20, 20, 18, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 67, 67, 18, 18, 20, 20, 20, 20, 18, 18, 67, 67, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 67, 67, 67, 67, 67, 67, 67
	                         DB           67, 67, 18, 18, 18, 20, 20, 20, 20, 18, 18, 18, 18, 18, 18, 67, 67, 67, 67, 67, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 20, 20, 20, 20, 20, 18, 136, 65, 65, 65, 65, 18, 18
	                         DB           18, 18, 18, 18, 18, 67, 67, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 18, 20, 20, 20, 20, 20, 18, 136, 65, 65, 65, 65, 65, 65, 65, 65, 136, 65, 18, 18, 18, 18, 67, 67, 67, 67, 67, 67, 67, 67
	                         DB           67, 67, 67, 67, 67, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 20, 20, 20, 20, 20, 136
	                         DB           136, 136, 65, 65, 65, 65, 65, 65, 65, 136, 136, 136, 18, 20, 20, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 20, 20, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 20, 20, 18, 18, 136, 90, 90, 136, 136, 136, 136, 65, 65, 65, 65, 136, 65, 136, 18, 20, 20, 20
	                         DB           20, 20, 20, 20, 20, 20, 20, 20, 18, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91
	                         DB           91, 18, 18, 91, 91, 136, 90, 90, 90, 90, 90, 90, 90, 136, 136, 136, 65, 136, 136, 136, 18, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 18, 18, 91, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 91, 91, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           136, 136, 136, 18, 20, 20, 20, 20, 20, 20, 20, 20, 20, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 18, 20, 20, 20, 20, 20, 20, 18, 18, 18, 22, 22, 22
	                         DB           26, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 136, 90, 90, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 18, 20, 18, 18, 18, 18, 18, 136, 22, 22, 22, 26, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 18, 18, 18, 90, 136, 65
	                         DB           65, 65, 136, 22, 22, 26, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 136, 90, 90, 136, 136, 136, 136, 136, 136, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 136, 65, 65, 136, 22, 22, 22, 91, 91, 91, 91, 91, 91, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 136, 136, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 136, 65, 136, 22, 22, 22, 22, 22, 22, 22, 22, 22, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 136, 65, 136, 22, 22, 22, 22, 22
	                         DB           22, 22, 22, 26, 26, 26, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 136, 90, 65, 65, 65, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 136, 136, 22, 26, 26, 26, 26, 26, 26, 26, 26, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 65, 65, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           90, 136, 136, 22, 26, 26, 26, 26, 26, 26, 26, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91
	                         DB           136, 90, 65, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 136, 22, 26, 26, 26, 26, 26, 26, 91, 91, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 90, 90, 90, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 136, 22, 22, 22, 22, 26, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 91, 136, 90, 90, 90, 90, 90, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 136, 136, 136, 22, 22
	                         DB           91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 65, 90, 90, 90, 90, 136, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 136, 90, 90, 136, 22, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 65, 29, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 29, 29, 29, 29, 29, 29, 65, 136, 90, 90, 90, 90
	                         DB           90, 90, 65, 136, 90, 90, 90, 136, 22, 22, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136
	                         DB           117, 117, 117, 29, 90, 65, 90, 90, 90, 65, 65, 29, 29, 117, 117, 117, 29, 29, 29, 65, 136, 90, 90, 90, 90, 90, 65, 136, 90, 65, 90, 90, 136, 22, 22, 91, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 19, 117, 190, 117, 29, 29, 65, 65, 90, 90, 65, 65, 28, 29, 117, 190, 117
	                         DB           29, 29, 28, 28, 65, 65, 65, 65, 65, 65, 65, 136, 90, 90, 90, 90, 136, 26, 26, 22, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 26, 19, 190, 190, 117, 28, 19, 21, 65, 90, 90, 90, 65, 19, 28, 190, 190, 117, 28, 28, 28, 28, 19, 65, 65, 65, 65, 22, 65, 136, 90, 65, 65, 90
	                         DB           136, 26, 26, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 26, 22, 19, 190, 190, 19, 65, 21, 65, 65
	                         DB           90, 90, 90, 65, 19, 19, 19, 190, 28, 28, 28, 19, 65, 65, 65, 65, 136, 26, 22, 136, 90, 65, 65, 90, 136, 16, 16, 26, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 26, 136, 19, 19, 19, 65, 22, 22, 21, 65, 65, 19, 90, 90, 65, 65, 19, 190, 28, 19, 19, 65, 65, 65, 65, 65
	                         DB           136, 26, 26, 22, 22, 90, 90, 22, 16, 16, 16, 16, 91, 26, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 136
	                         DB           65, 65, 65, 19, 22, 26, 21, 21, 65, 65, 19, 19, 65, 65, 65, 19, 19, 65, 136, 65, 136, 136, 136, 136, 22, 22, 26, 26, 22, 22, 22, 19, 16, 16, 16, 16, 91, 91, 91, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 22, 136, 65, 136, 19, 22, 22, 26, 26, 21, 21, 136, 65, 65, 19, 19, 65, 65
	                         DB           65, 65, 22, 136, 22, 22, 22, 22, 21, 22, 26, 26, 26, 22, 19, 19, 16, 16, 16, 16, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 91, 91, 22, 22, 22, 136, 65, 65, 136, 22, 22, 26, 22, 26, 21, 21, 136, 65, 65, 65, 19, 65, 65, 22, 26, 136, 22, 26, 22, 26, 22, 21, 26, 22, 22, 19, 19, 19
	                         DB           16, 16, 16, 16, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 22, 26, 136, 136, 136, 22, 22, 26, 22, 26, 26
	                         DB           26, 21, 136, 136, 65, 65, 65, 136, 136, 26, 136, 22, 26, 26, 22, 22, 26, 22, 21, 19, 19, 19, 19, 19, 19, 16, 16, 16, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 26, 26, 22, 136, 136, 22, 22, 26, 26, 22, 26, 26, 26, 26, 21, 136, 136, 136, 136, 136, 26, 26, 21, 21, 26, 26, 22, 22
	                         DB           26, 26, 22, 19, 19, 19, 19, 19, 19, 16, 16, 16, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 22, 26, 26, 26, 22, 136
	                         DB           136, 22, 26, 26, 22, 22, 26, 26, 26, 26, 26, 21, 136, 136, 136, 22, 26, 22, 22, 21, 21, 21, 22, 19, 19, 26, 22, 19, 19, 19, 19, 19, 19, 16, 16, 21, 21, 21, 21, 26
	                         DB           91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 22, 26, 22, 22, 26, 26, 22, 22, 26, 26, 26, 26, 26, 26, 21, 136, 22, 26
	                         DB           22, 22, 22, 26, 26, 21, 19, 19, 19, 19, 26, 22, 19, 19, 19, 19, 19, 16, 16, 21, 21, 21, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 22, 22, 21, 21, 21, 22, 22, 22, 26, 26, 26, 26, 26, 26, 21, 21, 21, 21, 21, 19, 19, 19, 19, 26, 22, 19, 19, 19, 19, 26, 19, 19, 19, 19
	                         DB           19, 16, 16, 21, 26, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 21, 19, 19, 19, 19, 21, 21, 21, 21, 21
	                         DB           21, 21, 21, 21, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 26, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 16, 21, 21, 26, 26, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 19, 19, 16, 16, 21, 21, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 19
	                         DB           19, 19, 43, 43, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 16, 22, 22, 26, 21, 21, 21, 91, 91
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 19, 19, 19, 68, 43, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 16, 16, 16, 16, 26, 26, 26, 21, 21, 26, 21, 21, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 16, 19, 19, 43, 68, 68, 19, 19, 19, 19, 19, 19, 19, 19, 21, 21, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 16, 16, 21, 21, 26, 26
	                         DB           26, 21, 21, 26, 26, 26, 26, 22, 91, 91, 26, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 19, 19, 43, 68, 68, 43, 19, 19, 19
	                         DB           19, 19, 19, 19, 26, 21, 21, 19, 19, 19, 19, 26, 19, 19, 19, 19, 19, 16, 21, 21, 21, 21, 26, 26, 21, 21, 21, 26, 26, 26, 26, 26, 26, 26, 22, 91, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 19, 6, 43, 43, 43, 6, 19, 19, 26, 19, 19, 19, 19, 26, 26, 21, 21, 19, 19, 19, 21, 26, 19, 16, 16
	                         DB           16, 21, 21, 26, 26, 21, 21, 21, 21, 21, 21, 21, 21, 26, 26, 26, 26, 22, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 16
	                         DB           6, 6, 43, 6, 6, 6, 19, 26, 21, 19, 19, 19, 26, 26, 21, 21, 21, 19, 19, 21, 26, 16, 16, 21, 21, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 21, 21, 21, 21, 21
	                         DB           21, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 16, 6, 6, 6, 22, 6, 19, 19, 26, 21, 21, 19, 19, 26, 26, 26, 21
	                         DB           21, 21, 16, 21, 26, 26, 21, 21, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 21, 21, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 22, 22, 22, 22, 22, 22, 16, 19, 22, 26, 26, 19, 19, 26, 26, 21, 21, 16, 26, 26, 26, 26, 26, 21, 21, 21, 21, 26, 21, 21, 26, 26, 26, 26, 26, 26, 26, 22
	                         DB           22, 21, 21, 21, 21, 21, 21, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 22, 22, 22, 22, 22, 16, 26, 16, 26, 26, 16, 26
	                         DB           26, 26, 21, 21, 26, 26, 26, 26, 26, 26, 21, 21, 22, 22, 22, 26, 26, 26, 26, 26, 26, 22, 22, 22, 22, 22, 26, 26, 26, 26, 26, 22, 91, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 26, 26, 26, 26, 22, 26, 26, 22, 26, 22, 26, 26, 26, 26, 22, 22, 22, 26, 26, 26, 26, 26, 22, 26, 22, 22, 22
	                         DB           22, 22, 22, 22, 22, 22, 22, 22, 26, 26, 26, 26, 91, 91, 26, 22, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 26, 26, 26
	                         DB           26, 22, 22, 26, 22, 22, 22, 22, 26, 26, 26, 22, 26, 22, 22, 26, 26, 26, 26, 22, 26, 26, 26, 26, 26, 26, 26, 22, 22, 26, 26, 26, 26, 26, 26, 22, 91, 91, 91, 26
	                         DB           91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 26, 26, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 26, 26, 26, 22
	                         DB           26, 26, 26, 22, 22, 26, 26, 26, 26, 26, 26, 22, 22, 26, 26, 26, 22, 22, 22, 91, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 91, 22, 22, 22, 22, 26, 26, 26, 26, 26, 26, 22, 22, 22, 22, 26, 26, 22, 22, 26, 26, 22, 22, 22, 26, 26, 26, 26, 26, 26, 22, 22, 22, 22
	                         DB           22, 22, 22, 22, 91, 26, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 26, 26, 26, 26, 26, 26, 26, 26
	                         DB           26, 26, 22, 26, 22, 22, 26, 26, 22, 26, 22, 22, 22, 22, 26, 26, 26, 22, 22, 22, 22, 22, 22, 26, 26, 26, 26, 26, 26, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 22, 26, 22, 22, 26, 22, 22, 22, 26, 26, 26, 22, 22
	                         DB           22, 22, 26, 26, 26, 26, 26, 26, 26, 26, 22, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 26, 22
	                         DB           22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 26, 26, 22, 22, 22, 22, 22, 22, 22, 22, 26, 26, 22, 22, 22, 22, 26, 26, 26, 26, 91, 91, 91, 91, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 22, 22, 22, 26, 26, 26, 22, 22, 22, 22, 22, 26, 26, 26, 22, 22, 22, 26, 26, 22
	                         DB           26, 26, 22, 22, 26, 26, 26, 26, 26, 26, 22, 22, 22, 22, 22, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 91, 22, 22, 22, 26, 26, 26, 22, 22, 22, 22, 22, 26, 26, 26, 26, 26, 22, 22, 22, 22, 22, 26, 26, 26, 22, 22, 22, 22, 26, 26, 26, 26, 26, 22, 22, 22, 22
	                         DB           91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 26, 26, 26, 26, 26, 22, 22, 22, 26, 26, 26, 26
	                         DB           26, 22, 26, 22, 22, 22, 22, 22, 22, 26, 26, 26, 22, 22, 22, 22, 22, 26, 26, 26, 26, 26, 26, 22, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 26, 91, 91, 91, 91, 22, 22, 26, 26, 26, 26, 22, 22, 22, 22, 22, 22, 22, 26, 26, 22, 22, 26, 26, 26, 22, 22, 91
	                         DB           91, 91, 91, 91, 26, 26, 26, 26, 26, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 22
	                         DB           22, 26, 26, 91, 91, 91, 91, 22, 22, 22, 22, 26, 26, 26, 26, 22, 22, 22, 26, 26, 26, 26, 22, 22, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 0, 0, 91, 91, 22, 26, 26, 26, 26, 26, 91, 91
	                         DB           91, 91, 91, 91, 91, 26, 26, 26, 26, 26, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 26, 26, 26, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Hisoka                   DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 35, 107, 107, 107, 107, 58, 58, 58, 58, 58, 107, 107, 107, 107, 107, 58, 35, 35, 107, 86, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86
	                         DB           86, 107, 107, 58, 58, 82, 82, 82, 82, 82, 82, 82, 58, 58, 58, 58, 107, 107, 107, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 35, 58, 107, 107, 107, 107, 107, 107, 107, 107, 82, 82, 58, 58
	                         DB           35, 35, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 107, 107, 88, 88, 88, 88, 88, 88, 88, 88, 107, 107, 107, 107, 58, 35, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 184, 64, 64, 64, 64, 64, 64
	                         DB           64, 64, 64, 88, 64, 88, 88, 88, 107, 107, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 184, 64, 112, 112, 112, 112, 112, 112, 112, 112, 64, 88, 64, 88, 88, 88, 64, 184, 86, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           86, 184, 112, 31, 31, 31, 31, 31, 31, 31, 112, 112, 64, 88, 64, 88, 64, 184, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 88, 112, 64, 88, 64
	                         DB           64, 184, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 31, 88, 88, 88, 31, 31, 31, 31, 88, 88, 112, 64, 88, 64, 184, 86, 0, 0, 0, 0, 86, 86, 86, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 88, 88, 112, 64, 64, 184, 86, 0, 0, 0, 86, 86, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 88, 88, 88, 88, 31, 31, 31, 31, 31, 31, 88, 88, 112, 64, 184, 86, 0, 0, 86, 86, 185
	                         DB           43, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86
	                         DB           112, 31, 88, 112, 112, 112, 112, 112, 112, 31, 31, 31, 31, 31, 88, 112, 112, 184, 86, 0, 86, 86, 185, 68, 43, 43, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 88, 31, 112, 31, 31, 31, 31, 31, 31, 112, 112, 31, 31, 31, 31, 88
	                         DB           112, 184, 86, 0, 86, 185, 68, 43, 43, 43, 43, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 86, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 88, 88, 112, 86, 86, 86, 86, 185, 68, 6, 43, 185, 86, 86, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 31, 31, 31, 31, 88, 88, 112, 86, 86, 86, 86, 185, 6, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 31, 88, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 88, 88, 112, 86, 86, 185, 68
	                         DB           68, 43, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 31
	                         DB           31, 31, 88, 88, 112, 112, 31, 31, 31, 31, 31, 31, 31, 31, 3, 31, 31, 88, 88, 112, 86, 86, 185, 68, 68, 43, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 5, 31, 38, 31, 88, 88, 112, 112, 31, 31, 31, 31, 31, 31, 31, 31, 3, 51, 51
	                         DB           31, 31, 88, 88, 112, 86, 86, 185, 6, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 86, 86, 112, 5, 38, 38, 31, 31, 88, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 3, 51, 51, 31, 31, 88, 88, 88, 112, 185, 68, 68, 43, 185, 86, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 5, 38, 38, 38, 31, 31, 88, 112, 112, 31, 31
	                         DB           31, 31, 31, 31, 31, 3, 51, 51, 31, 31, 31, 88, 88, 88, 112, 68, 68, 43, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 5, 38, 38, 38, 38, 38, 31, 88, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 51, 31, 31, 31, 88, 31, 88, 88, 112, 185
	                         DB           6, 185, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 38, 31
	                         DB           31, 31, 31, 88, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 51, 31, 31, 31, 31, 88, 31, 88, 88, 31, 6, 185, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 31, 38, 31, 31, 31, 31, 31, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 88, 31, 31, 43, 6, 112, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 86, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 88, 31, 43, 43, 88, 112, 86, 86, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 31, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 31, 31, 31, 31, 112, 31, 31, 31, 88, 31, 112, 31, 88, 88, 88, 112, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 112, 31, 31, 31, 31, 112, 31, 31, 31, 31, 31, 31, 112, 31, 31, 31, 31, 31, 112, 31, 31, 31, 88, 31, 31, 88, 112
	                         DB           112, 112, 88, 112, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 112, 112
	                         DB           112, 112, 31, 31, 31, 31, 31, 31, 31, 31, 112, 112, 112, 112, 112, 31, 31, 31, 31, 31, 88, 31, 88, 64, 88, 112, 88, 88, 112, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           88, 112, 31, 88, 31, 31, 88, 88, 64, 64, 112, 88, 112, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           86, 112, 88, 31, 112, 88, 31, 31, 31, 31, 88, 31, 31, 31, 31, 31, 31, 88, 88, 31, 31, 31, 31, 88, 112, 31, 31, 31, 88, 112, 112, 112, 112, 64, 112, 88, 112, 86, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 112, 88, 88, 88, 88, 112, 31, 31, 31, 31, 31
	                         DB           31, 112, 88, 88, 88, 88, 88, 112, 31, 31, 31, 88, 31, 31, 112, 64, 64, 64, 112, 88, 112, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 112, 88, 88, 112, 31, 31, 31, 31, 31, 31, 31, 31, 112, 112, 88, 88, 112, 31, 31, 31, 31, 31, 88, 31, 88, 112
	                         DB           64, 112, 88, 88, 112, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 112, 88, 31, 31, 31, 31, 112
	                         DB           112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 112, 112, 31, 31, 31, 31, 31, 88, 112, 31, 88, 88, 112, 88, 88, 112, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 112, 112, 31, 88, 88, 88, 112, 5, 5, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86
	                         DB           107, 5, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 5, 5, 112, 112, 112, 112, 5, 5, 5, 5, 107, 86
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 107, 5, 112, 88, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 86, 86, 107, 5, 5, 112, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 5, 5, 5, 5, 5
	                         DB           5, 5, 5, 5, 5, 5, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 5, 5, 38, 112, 88, 31, 31, 31, 31
	                         DB           31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 5, 5, 5, 112, 31, 31, 31, 31, 31, 31, 31, 5, 5, 5, 5, 5, 5, 31, 31, 31, 31, 31, 31, 31, 31
	                         DB           31, 31, 31, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 5, 5
	                         DB           5, 38, 112, 31, 31, 31, 5, 5, 5, 5, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 31, 31, 31, 31, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
	                         DB           107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 5, 38, 5, 5, 5, 5, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5
	                         DB           38, 5, 38, 5, 38, 5, 5, 5, 5, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 86, 86, 107, 38, 5, 38, 5, 5, 5, 38, 5, 38, 5, 5, 5, 38, 5, 38, 5, 5, 5, 38, 5, 5, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5
	                         DB           5, 5, 5, 5, 5, 5, 38, 5, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 5, 38, 38, 5, 38, 5, 38, 5, 38, 5
	                         DB           38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 5, 38, 5, 107, 86, 86, 86, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 38, 38, 38, 38, 5, 5, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38, 5, 38
	                         DB           5, 5, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 5, 38, 5, 107, 107, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 38, 38
	                         DB           38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 5, 5, 38, 5, 38, 5, 5, 5, 38, 5, 38, 5, 5, 5, 5, 5, 5, 5, 5, 38
	                         DB           38, 38, 38, 107, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 107, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 5, 38
	                         DB           38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 5, 38, 5, 38, 5, 5, 5, 5, 5, 110, 62, 62, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 86, 110, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 5, 38, 38, 38, 5
	                         DB           38, 5, 38, 5, 38, 5, 5, 5, 110, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 38, 38, 38, 38, 38, 5, 38, 38, 38
	                         DB           38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 62, 110, 86, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 110, 38, 38, 62, 38, 38, 38, 38, 5, 38, 38, 5, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 5
	                         DB           38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 62, 110, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110
	                         DB           38, 38, 38, 38, 38, 38, 38, 38, 62, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 5, 5, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38
	                         DB           110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 38, 38, 38, 38, 38, 38, 38, 62, 5, 5, 38, 62, 38, 38
	                         DB           5, 38, 38, 38, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 5, 5, 38, 38, 38, 62, 38, 38, 38, 38, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 86, 110, 38, 62, 38, 38, 38, 62, 38, 62, 38, 38, 5, 38, 38, 38, 38, 5, 38, 38, 38, 38, 38, 62, 38, 38, 5, 5, 38, 38, 38, 38, 38
	                         DB           5, 38, 38, 38, 62, 38, 38, 38, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 62, 38, 38, 62, 38
	                         DB           38, 62, 38, 38, 38, 62, 38, 62, 38, 5, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 62, 38, 38, 110, 86, 86, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 110, 62, 38, 62, 38, 62, 38, 38, 38, 62, 38, 38, 38, 62, 38, 38, 38, 5, 38, 38, 38, 62, 38
	                         DB           38, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 62, 38, 38, 38, 110, 62, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           86, 110, 62, 38, 38, 38, 62, 38, 38, 62, 38, 62, 38, 38, 38, 62, 38, 38, 5, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 62, 38, 38, 62
	                         DB           110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 38, 38, 38, 62, 38, 38, 62, 38, 38, 38, 38, 38
	                         DB           62, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38, 38, 62, 38, 62, 38, 38, 62, 62, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38
	                         DB           38, 62, 38, 62, 38, 38, 62, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 62, 38, 38
	                         DB           62, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 62, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 62, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 110, 110, 62, 38, 38, 38, 38, 38, 62, 38, 38, 38, 38, 62, 38, 38, 38, 38
	                         DB           38, 38, 38, 62, 62, 38, 38, 38, 38, 38, 38, 38, 62, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 86, 86, 86, 86, 107, 62, 62, 110, 38, 38, 38, 62, 38, 38, 38, 62, 38, 38, 38, 38, 38, 38, 38, 38, 62, 62, 62, 62, 62, 62, 62, 38, 38, 38, 110, 86
	                         DB           86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 110, 86, 110, 38, 110, 110
	                         DB           62, 38, 38, 38, 62, 62, 38, 38, 38, 38, 38, 38, 38, 110, 110, 110, 110, 110, 110, 110, 62, 62, 38, 110, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 86, 86, 86, 110, 86, 86, 110, 62, 38, 110, 62, 62, 62, 38, 38, 38, 38, 38, 110, 86, 86, 86
	                         DB           86, 86, 86, 86, 110, 110, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 86, 86, 86, 86, 86, 110, 62, 110, 110, 110, 62, 62, 62, 62, 110, 62, 110, 86, 0, 0, 0, 0, 0, 86, 86, 86, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 110, 86, 86, 86, 110, 110
	                         DB           110, 110, 86, 110, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 86, 86, 86, 0, 86, 86, 86, 86, 86, 86, 86, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Mikasa                   DB           0, 0, 91, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 6, 114, 114, 114, 114, 114, 114, 114, 113, 113, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 26, 30, 30, 30
	                         DB           30, 26, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 91, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114
	                         DB           6, 114, 114, 114, 114, 114, 114, 114, 113, 113, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 26, 30, 30, 30, 30, 26, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	                         DB           6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 91, 91, 114, 114, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 114, 6, 114, 114, 114, 114, 114, 114, 113, 113, 113, 113, 113, 4, 4, 4
	                         DB           4, 113, 113, 113, 26, 30, 30, 30, 30, 26, 114, 114, 6, 6, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 0, 91, 91, 91, 114, 114
	                         DB           6, 6, 6, 6, 6, 6, 114, 114, 114, 6, 114, 114, 114, 114, 114, 114, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 26, 26, 26, 30, 30, 26, 114, 114, 114, 114, 114, 114
	                         DB           6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 6, 6, 0, 0, 0, 0, 0, 91, 91, 91, 114, 114, 114, 6, 6, 6, 114, 114, 6, 114, 114, 114, 114, 114, 114, 113
	                         DB           113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 26, 26, 26, 26, 114, 114, 114, 114, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 114, 114, 114, 114, 114, 114
	                         DB           0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 114, 114, 114, 114, 114, 6, 114, 114, 114, 114, 114, 114, 113, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 113
	                         DB           26, 26, 114, 114, 114, 114, 6, 6, 114, 114, 6, 6, 6, 114, 114, 114, 114, 114, 6, 6, 6, 114, 114, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 114, 6
	                         DB           114, 114, 114, 114, 114, 114, 114, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 114, 114, 114, 114, 6, 6, 6, 6, 114, 114, 114, 114, 6, 114
	                         DB           114, 114, 114, 114, 114, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 114, 6, 114, 114, 114, 114, 114, 114, 114, 4, 4, 4, 4, 4, 4, 4, 4, 4
	                         DB           4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 114, 114, 114, 114, 6, 6, 6, 6, 114, 6, 6, 6, 6, 6, 114, 114, 114, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 114, 6, 114, 114, 114, 114, 114, 113, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 4, 4, 4, 4, 114, 114, 114, 6, 6, 6
	                         DB           6, 6, 114, 114, 6, 114, 114, 114, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 6, 114, 114, 114, 114, 114, 114, 113, 4, 4
	                         DB           4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 4, 4, 4, 114, 114, 114, 6, 6, 6, 6, 6, 6, 114, 114, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 6, 114, 114, 114, 114, 114, 113, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 113, 113, 113, 113, 113, 113, 4, 113, 113
	                         DB           113, 4, 114, 114, 6, 6, 6, 6, 6, 6, 6, 114, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 114
	                         DB           114, 114, 114, 114, 113, 4, 4, 4, 4, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 113, 4, 4, 114, 114, 6, 6, 6, 6, 6, 6, 6, 114, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 114, 114, 114, 113, 4, 4, 4, 113, 113, 4, 4, 4, 4, 4, 4
	                         DB           113, 113, 113, 4, 113, 113, 4, 113, 113, 113, 114, 114, 114, 114, 114, 6, 6, 6, 6, 114, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 114, 114, 113, 4, 4, 113, 113, 4, 4, 4, 4, 4, 113, 113, 113, 113, 4, 4, 4, 4, 4, 4, 4, 4, 113, 113, 113, 113, 114, 6
	                         DB           6, 6, 6, 18, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 113, 113, 113, 113
	                         DB           4, 4, 4, 4, 4, 113, 113, 113, 113, 113, 113, 113, 4, 4, 4, 4, 4, 4, 4, 4, 4, 113, 114, 114, 18, 6, 114, 18, 18, 91, 91, 18, 91, 91, 91, 91, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 0, 0, 0, 0, 91, 91, 113, 113, 4, 4, 4, 4, 4, 4, 113, 113, 90, 90, 90, 113, 113, 113, 113, 113, 4
	                         DB           4, 4, 4, 4, 4, 4, 91, 91, 18, 114, 91, 18, 18, 91, 91, 18, 18, 91, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 91, 91
	                         DB           91, 91, 0, 0, 91, 91, 113, 4, 4, 4, 4, 4, 113, 90, 90, 90, 90, 90, 90, 90, 113, 113, 113, 113, 113, 4, 4, 4, 4, 113, 91, 91, 18, 18, 91, 18, 18, 18, 91, 18
	                         DB           18, 91, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 91, 91, 18, 91, 91, 91, 91, 91, 113, 4, 4, 113, 4, 113, 90, 90, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 65, 113, 113, 113, 113, 113, 4, 113, 18, 91, 18, 18, 91, 18, 18, 18, 91, 91, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 91, 91, 18, 18, 91, 18, 91, 18, 18, 91, 91, 113, 113, 4, 113, 113, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 160, 113, 113, 113, 91, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 91, 18, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 91, 18, 91, 18, 18, 91, 91, 91, 113
	                         DB           113, 113, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 160, 65, 65, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 18, 18, 18, 18, 18, 91, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 91, 91, 113, 90, 90, 90, 90, 90, 160, 160, 160, 160, 90, 90, 90, 90, 90, 90
	                         DB           90, 65, 65, 160, 65, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 91, 0, 91, 91, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 65, 160, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 91, 65, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 65, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 91, 91, 65, 90, 90, 90, 90, 65, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 65, 18, 91, 18
	                         DB           18, 18, 18, 19, 18, 18, 18, 18, 18, 18, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 65, 90
	                         DB           90, 90, 90, 65, 65, 160, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 18, 18, 18, 18, 18, 18, 19, 18, 91, 91
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 90, 90, 90, 90, 90, 65, 65, 160, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           90, 90, 90, 65, 65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 18, 18, 18, 19, 18, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 65, 90, 90, 90, 90, 90, 90, 65, 65, 160, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 18, 18
	                         DB           18, 19, 18, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 90, 90, 90, 90, 90, 90, 90, 65, 160, 90
	                         DB           90, 90, 18, 65, 90, 90, 90, 90, 90, 90, 90, 90, 65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 18, 18, 18, 19, 18, 19, 18, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 18, 18, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 18, 18, 19
	                         DB           19, 18, 19, 19, 19, 18, 19, 19, 18, 19, 18, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 65, 65, 65
	                         DB           65, 90, 90, 90, 90, 90, 18, 19, 19, 18, 65, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19, 18, 19, 18, 19, 19, 19, 18, 91
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 65, 29, 236, 236, 236, 65, 90, 90, 65, 18, 19, 19, 18, 65, 65, 65, 65, 65, 65, 65
	                         DB           90, 90, 90, 90, 65, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19, 19, 19, 18, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 16, 29, 29, 236, 16, 236, 29, 16, 65, 18, 18, 19, 18, 65, 65, 29, 236, 236, 236, 236, 29, 65, 90, 90, 90, 65, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19
	                         DB           19, 19, 18, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 16, 26, 16, 16, 16, 16, 65, 18, 18, 19, 19, 18
	                         DB           65, 29, 29, 236, 16, 16, 236, 29, 29, 16, 65, 65, 160, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19, 19, 19, 19, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 16, 16, 16, 16, 16, 16, 16, 18, 18, 19, 19, 18, 65, 16, 26, 16, 16, 16, 16, 16, 16, 65, 65, 18, 160, 18, 18, 19
	                         DB           19, 18, 19, 19, 19, 18, 19, 19, 19, 19, 19, 19, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 65, 65, 65
	                         DB           65, 18, 18, 18, 18, 19, 18, 65, 65, 65, 16, 16, 16, 16, 16, 16, 16, 65, 18, 18, 18, 18, 18, 19, 19, 18, 19, 19, 19, 18, 19, 19, 19, 19, 20, 19, 19, 19, 18, 91
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 160, 160, 160, 18, 18, 18, 19, 19, 19, 18, 65, 160, 65, 65, 65, 65, 65, 65, 65
	                         DB           65, 18, 18, 18, 18, 18, 19, 19, 19, 18, 19, 20, 19, 18, 19, 19, 19, 19, 20, 19, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 160, 65, 160, 18, 18, 19, 19, 19, 19, 18, 65, 90, 160, 160, 160, 160, 160, 160, 160, 160, 18, 18, 18, 19, 18, 19, 19, 19, 18, 19, 20, 19, 18, 19, 19
	                         DB           19, 19, 20, 19, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 160, 18, 18, 18, 19, 19, 19, 18, 18, 65
	                         DB           65, 90, 65, 65, 18, 18, 65, 65, 160, 18, 18, 18, 19, 18, 19, 19, 19, 18, 19, 20, 19, 18, 19, 20, 19, 19, 20, 19, 19, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 160, 18, 18, 19, 19, 19, 19, 18, 18, 65, 65, 65, 65, 18, 18, 65, 65, 160, 18, 18, 19, 18, 19, 18, 19, 19
	                         DB           20, 19, 19, 20, 19, 18, 19, 20, 19, 19, 20, 19, 19, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 18, 18
	                         DB           18, 19, 19, 19, 19, 18, 18, 18, 65, 65, 18, 18, 18, 65, 160, 18, 18, 19, 19, 18, 19, 19, 18, 19, 20, 19, 19, 20, 19, 19, 20, 19, 19, 19, 20, 19, 18, 18, 91, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 160, 18, 18, 18, 19, 19, 19, 19, 18, 18, 18, 18, 18, 18, 18, 65, 160, 18, 18
	                         DB           18, 19, 19, 20, 19, 19, 18, 19, 19, 19, 19, 20, 19, 19, 20, 19, 19, 19, 20, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 18, 18, 18, 18, 18, 18, 18, 160, 18, 18, 18, 19, 19, 18, 20, 19, 19, 18, 19, 19, 19, 19, 20, 19, 19, 20, 19
	                         DB           19, 20, 19, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 18, 18, 19
	                         DB           18, 19, 19, 18, 160, 18, 18, 19, 19, 19, 20, 19, 19, 19, 18, 19, 20, 19, 20, 20, 19, 19, 20, 19, 19, 20, 19, 19, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 18, 18, 19, 18, 19, 19, 18, 160, 18, 18, 19, 19, 19, 20, 19, 19, 19, 19, 19
	                         DB           20, 20, 20, 20, 20, 19, 20, 19, 20, 19, 19, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           19, 20, 19, 19, 19, 18, 18, 19, 18, 19, 19, 19, 18, 18, 19, 19, 19, 20, 20, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 20, 21, 19, 19, 18, 18, 91, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 20, 19, 19, 19, 18, 18, 19, 18, 19, 20, 19, 18, 18, 19, 19
	                         DB           19, 20, 20, 19, 19, 19, 19, 20, 21, 20, 20, 20, 21, 20, 20, 20, 21, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18
	                         DB           18, 18, 18, 18, 19, 18, 18, 18, 19, 20, 19, 19, 19, 18, 18, 19, 18, 19, 20, 19, 19, 19, 19, 19, 19, 20, 20, 19, 19, 19, 20, 20, 21, 20, 20, 20, 21, 20, 20, 21
	                         DB           20, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 20, 19, 19, 19, 18, 18, 19
	                         DB           18, 19, 20, 19, 19, 20, 19, 19, 19, 20, 20, 19, 19, 19, 20, 21, 20, 20, 21, 20, 21, 20, 20, 21, 20, 19, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 91, 18, 18, 18, 19, 18, 18, 18, 18, 18, 18, 18, 19, 20, 19, 19, 19, 19, 18, 19, 18, 19, 20, 20, 19, 20, 20, 19, 19, 20, 19, 19, 19, 20, 20, 21
	                         DB           20, 21, 20, 20, 21, 20, 21, 20, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 19, 18, 18, 18, 19, 18, 18, 18
	                         DB           19, 20, 19, 19, 19, 19, 19, 19, 19, 20, 21, 20, 20, 20, 20, 19, 20, 20, 19, 19, 19, 20, 21, 20, 20, 21, 20, 21, 20, 21, 20, 19, 18, 18, 18, 91, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 19, 18, 18, 18, 19, 18, 19, 18, 18, 18, 19, 19, 20, 20, 19, 19, 20, 19, 19, 20, 21, 20, 20, 20, 20, 19
	                         DB           20, 21, 19, 19, 19, 20, 21, 20, 21, 21, 21, 21, 21, 21, 19, 19, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 19, 19
	                         DB           18, 19, 18, 18, 19, 18, 18, 19, 19, 19, 20, 20, 20, 19, 21, 21, 20, 20, 21, 20, 20, 21, 20, 19, 20, 21, 19, 19, 20, 21, 20, 20, 21, 20, 21, 20, 21, 19, 19, 18
	                         DB           18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 19, 18, 18, 18, 18, 19, 18, 18, 19, 19, 19, 20, 21, 20, 20, 20, 21
	                         DB           20, 20, 21, 20, 20, 21, 20, 19, 20, 21, 19, 19, 20, 21, 20, 21, 20, 21, 20, 21, 19, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 91, 18, 19, 18, 18, 19, 19, 18, 18, 19, 19, 19, 19, 21, 21, 20, 20, 21, 20, 20, 21, 20, 20, 21, 20, 19, 20, 21, 19, 19, 20, 20, 20, 20
	                         DB           20, 20, 20, 20, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 19, 19, 19, 19, 19, 18, 18, 18
	                         DB           19, 19, 19, 20, 21, 20, 20, 21, 20, 20, 21, 20, 20, 21, 20, 19, 19, 20, 19, 20, 20, 20, 20, 20, 19, 20, 20, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 19, 19, 19, 19, 19, 18, 19, 19, 19, 19, 20, 20, 21, 20, 20, 21, 20, 20, 21, 20, 20, 20, 19
	                         DB           19, 20, 19, 19, 19, 20, 20, 20, 19, 19, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91
	                         DB           18, 19, 19, 19, 19, 19, 18, 18, 19, 19, 19, 19, 20, 21, 20, 20, 21, 20, 20, 20, 20, 20, 20, 20, 19, 20, 19, 19, 19, 19, 20, 19, 19, 19, 18, 18, 18, 91, 91, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 19, 19, 19, 19, 19, 18, 19, 19, 19, 19, 20, 20, 21, 20
	                         DB           21, 20, 19, 20, 19, 19, 19, 20, 19, 20, 19, 19, 19, 20, 19, 19, 19, 18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 19, 19, 19, 19, 18, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 19, 20, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19
	                         DB           18, 18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 20, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 18, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 19, 19, 19, 19, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 18, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 18, 18, 18, 18, 18, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 19, 18, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Fenn                     DB           100, 125, 53, 53, 53, 54, 54, 125, 125, 54, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	                         DB           53, 53, 53, 53, 53, 53, 54, 191, 2, 2, 120, 191, 54, 53, 53, 53, 54, 191, 120, 2, 120, 2, 2, 2, 100, 125, 53, 53, 53, 54, 191, 191, 191, 191, 54, 54, 53, 53, 53, 53
	                         DB           53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 54, 191, 2, 2, 2, 120, 191, 54, 53, 53, 53
	                         DB           54, 191, 120, 120, 2, 120, 2, 2, 100, 100, 125, 53, 54, 191, 120, 120, 120, 120, 191, 54, 54, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53
	                         DB           53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 54, 54, 191, 2, 2, 120, 191, 54, 53, 53, 53, 54, 54, 191, 120, 2, 120, 2, 2, 2, 0, 100, 125, 53, 54, 191, 120, 2
	                         DB           2, 120, 191, 54, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 54, 191, 2
	                         DB           2, 120, 191, 54, 53, 53, 53, 54, 191, 120, 120, 120, 2, 2, 2, 2, 0, 100, 125, 53, 54, 191, 2, 2, 2, 2, 191, 54, 54, 53, 53, 53, 53, 53, 54, 53, 54, 53, 54, 53
	                         DB           54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 53, 53, 54, 54, 191, 2, 2, 2, 120, 191, 54, 53, 53, 54, 191, 120, 120, 2, 120, 2, 2, 2
	                         DB           0, 100, 125, 53, 54, 191, 2, 2, 2, 2, 191, 54, 53, 53, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54, 53, 54
	                         DB           53, 54, 53, 54, 53, 54, 191, 2, 2, 2, 120, 191, 54, 53, 53, 54, 191, 120, 2, 120, 2, 2, 2, 2, 0, 100, 100, 125, 54, 191, 2, 2, 2, 2, 191, 54, 54, 53, 54, 53
	                         DB           54, 53, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 53, 54, 53, 54, 53, 54, 53, 54, 191, 2, 2, 120, 191, 54, 53, 53, 54
	                         DB           120, 120, 120, 120, 2, 2, 2, 2, 0, 0, 100, 125, 54, 191, 2, 2, 2, 2, 191, 54, 53, 54, 53, 54, 53, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54
	                         DB           54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 53, 54, 54, 191, 2, 2, 2, 120, 191, 54, 54, 54, 120, 2, 2, 120, 120, 120, 2, 2, 0, 0, 100, 125, 54, 120, 120, 120
	                         DB           120, 120, 120, 54, 54, 53, 54, 54, 54, 54, 54, 54, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 125, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54
	                         DB           191, 2, 2, 120, 120, 120, 120, 120, 2, 2, 46, 46, 46, 71, 120, 2, 0, 0, 100, 100, 125, 120, 2, 46, 2, 46, 120, 54, 54, 54, 54, 125, 125, 125, 125, 125, 27, 27, 27, 27
	                         DB           27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 125, 125, 125, 125, 125, 125, 125, 125, 54, 54, 54, 191, 2, 120, 71, 46, 46, 46, 120, 120, 2, 46, 46, 46, 71, 71, 120
	                         DB           0, 0, 0, 100, 125, 120, 46, 71, 71, 46, 120, 54, 54, 54, 125, 27, 27, 27, 27, 27, 27, 27, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 27, 27, 27, 27
	                         DB           27, 27, 27, 27, 27, 125, 125, 125, 125, 120, 46, 46, 71, 71, 71, 46, 46, 120, 120, 71, 71, 71, 71, 71, 0, 0, 0, 100, 100, 120, 46, 71, 71, 46, 120, 125, 125, 125, 27, 27
	                         DB           27, 27, 27, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 29, 29, 27, 27, 27, 27, 27, 27, 27, 27, 27, 46, 46, 71, 71, 71
	                         DB           71, 46, 46, 71, 71, 71, 71, 71, 0, 0, 0, 0, 100, 120, 46, 71, 71, 46, 120, 27, 27, 27, 27, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 27, 27, 27, 27, 27, 120, 120, 46, 46, 71, 71, 71, 71, 71, 71, 71, 71, 71, 0, 0, 0, 0, 100, 120, 46, 71
	                         DB           71, 46, 120, 27, 27, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 160, 160, 160, 160, 160, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29
	                         DB           27, 27, 27, 27, 27, 120, 120, 46, 46, 46, 46, 71, 71, 71, 71, 71, 0, 0, 0, 0, 100, 100, 120, 71, 71, 46, 27, 27, 29, 29, 30, 30, 30, 30, 30, 30, 30, 160, 160, 160
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 27, 27, 27, 27, 22, 120, 120, 120, 120, 71, 71, 71, 71, 71
	                         DB           0, 0, 0, 0, 0, 100, 100, 120, 120, 120, 29, 29, 29, 30, 30, 30, 30, 30, 30, 160, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 160, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 27, 27, 22, 46, 46, 46, 46, 71, 71, 71, 71, 46, 0, 0, 0, 0, 0, 0, 100, 100, 22, 27, 29, 29, 30, 30, 30, 30
	                         DB           30, 160, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 27, 22, 71
	                         DB           71, 71, 71, 71, 71, 71, 46, 2, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 29, 30, 30, 30, 30, 160, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 160, 160, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 22, 71, 71, 71, 71, 71, 71, 46, 2, 191, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 29, 30, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 65, 160, 30, 30, 30
	                         DB           30, 30, 30, 29, 27, 27, 22, 46, 46, 46, 46, 46, 46, 2, 191, 100, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           183, 183, 183, 183, 183, 183, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 160, 30, 30, 30, 30, 30, 29, 27, 27, 22, 46, 46, 46, 46, 2, 2, 191, 100, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 183, 183, 136, 64, 64, 64, 64, 136, 136, 183, 183, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 65, 65, 160, 30, 30, 30, 30, 30, 30, 27, 27, 22, 2, 2, 2, 191, 191, 191, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 30, 29, 160, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 183, 136, 136, 136, 136, 136, 136, 136, 136, 136, 136, 136, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 30, 30, 30, 27, 27, 22, 191
	                         DB           191, 191, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 136, 136, 136, 136, 136, 136, 30, 30, 136, 136
	                         DB           136, 136, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 65, 160, 30, 30, 30, 30, 27, 27, 22, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 136, 30, 30, 136, 136, 136, 30, 30, 136, 30, 30, 136, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160
	                         DB           30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 136, 30
	                         DB           30, 183, 183, 183, 183, 183, 183, 30, 30, 183, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 183, 183, 183, 89, 89, 89, 89, 89, 89, 183, 183, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 27, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 65, 160, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65
	                         DB           65, 160, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 160, 89, 89, 89, 89, 89
	                         DB           89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 27, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 16, 16, 16, 89, 89, 89, 89, 89, 89, 89, 65, 160
	                         DB           30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 65, 160, 30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 160, 30, 30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 30, 30, 29, 160, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 30, 30, 30, 30, 30, 30, 27, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 30, 30, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 30, 30, 30, 30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 30, 30, 30, 30, 30, 29, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 30, 30, 160, 160, 89, 89, 89, 89, 89, 89
	                         DB           89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 30, 30, 30, 30, 160, 160, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 89, 160, 160, 160, 160, 160, 160, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 27, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 27, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29, 29, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100
	                         DB           22, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 29, 29
	                         DB           29, 29, 29, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 29, 30, 30, 29, 29, 22, 30, 30, 30, 30, 30, 30, 30, 30
	                         DB           30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 22, 22, 22, 22, 29, 29, 30, 30, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 29, 29, 22, 22, 22, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 22, 22
	                         DB           22, 22, 22, 100, 100, 100, 22, 29, 30, 30, 30, 30, 30, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 30, 29
	                         DB           27, 22, 100, 23, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 100, 100, 100, 100, 100, 100, 0, 100, 22, 29, 30, 30, 30, 30, 30, 27, 22, 100
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 30, 30, 30, 29, 27, 22, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 30, 30, 30, 30, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           100, 22, 29, 30, 30, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22
	                         DB           29, 30, 30, 30, 30, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 30, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 29, 27, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 100, 22, 29, 30, 30, 30, 29, 22, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 30, 30, 29, 22
	                         DB           100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 29, 29, 22, 100, 100, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 29, 29, 22, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 22, 22, 22, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 100, 22, 22, 22, 22, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Asta2                    DB           0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 67, 67, 67, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 67, 67, 18, 18, 18, 67, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 67, 18, 18, 18, 18, 18, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 67, 18, 18, 20
	                         DB           20, 20, 18, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 67, 67, 18, 18, 20, 20, 20, 20, 18, 18, 67, 67, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 67, 67, 67, 67, 67, 67, 67
	                         DB           67, 67, 18, 18, 18, 20, 20, 20, 20, 18, 18, 18, 18, 18, 18, 67, 67, 67, 67, 67, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 20, 20, 20, 20, 20, 18, 136, 65, 65, 65, 65, 18, 18
	                         DB           18, 18, 18, 18, 18, 67, 67, 67, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 18, 20, 20, 20, 20, 20, 18, 136, 65, 65, 65, 65, 65, 65, 65, 65, 136, 65, 18, 18, 18, 18, 67, 67, 67, 67, 67, 67, 67, 67
	                         DB           67, 67, 67, 67, 67, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 20, 20, 20, 20, 20, 136
	                         DB           136, 136, 65, 65, 65, 65, 65, 65, 65, 136, 136, 136, 18, 20, 20, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 20, 20, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 20, 20, 18, 18, 136, 90, 90, 136, 136, 136, 136, 65, 65, 65, 65, 136, 65, 136, 18, 20, 20, 20
	                         DB           20, 20, 20, 20, 20, 20, 20, 20, 18, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91
	                         DB           91, 18, 18, 91, 91, 136, 90, 90, 90, 90, 90, 90, 90, 136, 136, 136, 65, 136, 136, 136, 18, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 18, 18, 91, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 18, 18, 91, 91, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           136, 136, 136, 18, 20, 20, 20, 20, 20, 20, 20, 20, 20, 18, 18, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 18, 20, 20, 20, 20, 20, 20, 18, 18, 18, 16, 16, 16
	                         DB           22, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 136, 90, 90, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 18, 20, 18, 18, 18, 18, 18, 136, 16, 16, 16, 19, 22, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 90, 90, 90, 90, 90, 136, 90, 90, 90, 90, 90, 90, 90, 90, 18, 18, 18, 19, 19, 65
	                         DB           65, 65, 136, 16, 16, 19, 19, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 136, 90, 90, 136, 136, 136, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 19, 90, 19, 19, 19, 136, 65, 65, 136, 16, 16, 16, 91, 91, 91, 91, 91, 91, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           90, 19, 90, 19, 19, 19, 90, 90, 136, 65, 136, 16, 16, 16, 16, 16, 16, 16, 16, 16, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 19, 90, 19, 19, 19, 90, 19, 136, 65, 136, 16, 16, 16, 16, 16
	                         DB           16, 16, 16, 19, 22, 22, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 136, 90, 65, 65, 65, 90, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 19, 19, 19, 90, 19, 90, 65, 136, 136, 16, 19, 19, 19, 19, 19, 19, 22, 22, 22, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 65, 65, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 19, 19, 19, 90, 19, 90, 90
	                         DB           65, 136, 136, 16, 19, 19, 19, 19, 22, 22, 19, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91
	                         DB           136, 90, 65, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 19, 90, 19, 19, 90, 90, 19, 90, 90, 65, 65, 136, 16, 19, 19, 19, 19, 19, 19, 91, 91, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 90, 90, 90, 136, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90
	                         DB           19, 19, 19, 90, 19, 90, 90, 90, 65, 65, 136, 16, 16, 16, 16, 19, 19, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 91, 136, 90, 90, 90, 90, 90, 136, 90, 90, 90, 90, 90, 90, 90, 90, 19, 90, 19, 19, 90, 90, 90, 90, 90, 90, 90, 65, 65, 136, 136, 136, 16, 16
	                         DB           91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 90, 65, 90, 90, 90, 90, 136, 90
	                         DB           90, 90, 90, 90, 90, 90, 90, 90, 19, 90, 90, 19, 90, 90, 90, 90, 90, 65, 65, 136, 90, 90, 136, 16, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136, 65, 29, 90, 90, 90, 90, 90, 90, 90, 90, 90, 65, 29, 29, 29, 29, 29, 29, 65, 136, 90, 90, 90, 90
	                         DB           65, 65, 65, 136, 90, 90, 90, 136, 16, 16, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 136
	                         DB           117, 117, 117, 29, 90, 65, 90, 90, 90, 65, 65, 29, 29, 4, 4, 4, 29, 29, 29, 65, 136, 90, 90, 65, 65, 65, 136, 136, 90, 65, 90, 90, 136, 16, 16, 91, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 19, 117, 190, 117, 29, 29, 65, 65, 90, 90, 65, 65, 28, 29, 4, 183, 4
	                         DB           29, 29, 28, 28, 65, 65, 65, 65, 65, 136, 136, 136, 90, 90, 90, 90, 136, 19, 19, 16, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 26, 19, 190, 190, 117, 28, 19, 21, 65, 90, 90, 90, 65, 16, 28, 183, 183, 4, 28, 28, 28, 28, 19, 65, 65, 65, 136, 16, 136, 136, 90, 65, 65, 90
	                         DB           136, 19, 19, 22, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 26, 22, 19, 190, 190, 19, 16, 16, 65, 65
	                         DB           90, 16, 16, 65, 16, 183, 183, 183, 28, 28, 28, 19, 65, 65, 65, 65, 136, 22, 16, 136, 90, 65, 65, 90, 136, 16, 16, 22, 22, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 26, 136, 19, 19, 19, 16, 16, 16, 21, 65, 65, 65, 16, 16, 65, 183, 183, 183, 28, 19, 19, 65, 65, 65, 65, 65
	                         DB           136, 19, 22, 16, 16, 90, 90, 22, 16, 16, 16, 16, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 136
	                         DB           65, 65, 65, 19, 22, 16, 16, 16, 65, 65, 65, 16, 16, 65, 16, 16, 16, 65, 136, 65, 136, 136, 136, 136, 16, 16, 19, 19, 16, 16, 16, 183, 16, 16, 16, 16, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 22, 136, 65, 136, 16, 22, 22, 26, 26, 16, 16, 136, 65, 65, 16, 16, 65, 65
	                         DB           65, 65, 16, 136, 16, 16, 16, 16, 16, 16, 19, 19, 19, 16, 183, 16, 16, 16, 16, 16, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 91, 91, 22, 22, 22, 136, 65, 16, 136, 22, 22, 26, 22, 19, 16, 16, 136, 65, 65, 16, 16, 16, 65, 16, 22, 136, 16, 22, 16, 19, 16, 16, 19, 16, 16, 16, 16, 16
	                         DB           16, 16, 16, 16, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 22, 26, 136, 136, 136, 22, 22, 26, 16, 19, 19
	                         DB           19, 16, 136, 136, 65, 65, 16, 16, 16, 22, 136, 16, 22, 22, 16, 16, 19, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 26, 26, 22, 136, 136, 22, 22, 26, 26, 16, 19, 22, 19, 19, 16, 136, 136, 136, 136, 136, 19, 19, 16, 16, 19, 19, 16, 16
	                         DB           19, 19, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 22, 26, 26, 26, 22, 136
	                         DB           136, 22, 26, 26, 22, 16, 19, 22, 22, 19, 16, 16, 136, 136, 136, 16, 19, 16, 16, 16, 16, 16, 16, 19, 22, 22, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 91, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 22, 26, 22, 22, 26, 26, 22, 16, 19, 22, 22, 19, 19, 16, 16, 136, 16, 19
	                         DB           16, 16, 16, 19, 19, 16, 19, 19, 19, 22, 22, 16, 16, 16, 16, 16, 16, 16, 16, 16, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 22, 22, 21, 21, 21, 22, 22, 16, 19, 19, 19, 19, 19, 16, 16, 16, 16, 16, 16, 19, 19, 16, 16, 22, 16, 16, 16, 16, 16, 22, 16, 16, 16, 16
	                         DB           16, 16, 16, 16, 16, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 21, 16, 16, 16, 16, 21, 21, 21, 16, 16
	                         DB           16, 16, 19, 16, 16, 19, 19, 19, 19, 16, 16, 16, 16, 16, 22, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 19, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
	                         DB           16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 19, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 16
	                         DB           16, 16, 43, 43, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 19, 16, 16, 16, 91, 91
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 16, 16, 16, 68, 43, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
	                         DB           16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 19, 19, 19, 16, 16, 19, 16, 16, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 16, 16, 16, 43, 68, 68, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 19, 19
	                         DB           19, 16, 16, 19, 19, 19, 19, 22, 91, 91, 22, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 16, 16, 43, 68, 68, 43, 16, 16, 16
	                         DB           16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 19, 19, 16, 16, 16, 19, 19, 19, 19, 22, 22, 22, 22, 91, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 16, 16, 6, 43, 43, 43, 6, 16, 16, 26, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
	                         DB           16, 16, 16, 19, 19, 16, 16, 16, 16, 16, 16, 16, 16, 19, 19, 19, 22, 19, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 16
	                         DB           6, 6, 43, 6, 6, 6, 16, 26, 21, 16, 16, 16, 16, 16, 16, 16, 16, 19, 19, 16, 19, 16, 16, 16, 16, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 16, 16, 16, 16, 16
	                         DB           16, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 16, 6, 6, 6, 22, 6, 19, 19, 26, 21, 21, 16, 19, 19, 19, 19, 16
	                         DB           16, 16, 16, 16, 19, 19, 16, 16, 19, 19, 19, 19, 19, 19, 22, 22, 22, 22, 22, 19, 16, 16, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 91, 22, 22, 22, 22, 22, 22, 16, 19, 22, 26, 26, 19, 19, 26, 26, 21, 21, 16, 19, 19, 19, 19, 19, 16, 16, 16, 16, 19, 16, 16, 19, 19, 19, 19, 22, 22, 22, 16
	                         DB           16, 16, 16, 16, 16, 16, 16, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 22, 22, 22, 22, 22, 16, 26, 16, 26, 26, 16, 26
	                         DB           26, 26, 21, 21, 16, 19, 19, 22, 19, 19, 16, 16, 16, 16, 16, 19, 19, 19, 19, 19, 19, 16, 16, 16, 16, 16, 19, 19, 19, 22, 22, 19, 91, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 26, 26, 26, 26, 22, 26, 26, 22, 26, 22, 26, 26, 26, 26, 22, 16, 16, 19, 19, 22, 19, 19, 16, 19, 16, 16, 16
	                         DB           16, 16, 16, 16, 16, 16, 16, 16, 19, 19, 19, 19, 91, 91, 19, 22, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 26, 26, 26
	                         DB           26, 22, 22, 26, 22, 22, 22, 22, 26, 26, 26, 22, 26, 16, 16, 19, 22, 22, 19, 16, 19, 19, 19, 19, 19, 19, 19, 16, 16, 19, 19, 19, 19, 19, 19, 16, 91, 91, 91, 22
	                         DB           91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 26, 26, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 26, 26, 26, 16
	                         DB           19, 22, 19, 16, 16, 19, 19, 19, 19, 19, 19, 16, 16, 19, 19, 19, 16, 16, 16, 91, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 91, 91, 22, 22, 22, 22, 26, 26, 26, 26, 26, 26, 22, 22, 22, 22, 26, 26, 16, 16, 19, 19, 16, 16, 16, 19, 22, 22, 22, 22, 19, 16, 16, 16, 16
	                         DB           16, 16, 16, 16, 91, 22, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 26, 26, 26, 26, 26, 26, 26, 26
	                         DB           26, 26, 22, 26, 22, 16, 26, 22, 16, 19, 16, 16, 16, 16, 19, 19, 19, 16, 16, 16, 16, 16, 16, 19, 19, 19, 19, 22, 22, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 22, 26, 22, 16, 26, 16, 16, 16, 19, 19, 19, 16, 16
	                         DB           16, 16, 19, 19, 19, 19, 19, 19, 19, 19, 16, 91, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 22, 22, 26, 22
	                         DB           22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 26, 26, 16, 16, 16, 16, 16, 16, 16, 16, 19, 19, 16, 16, 16, 16, 19, 19, 19, 19, 91, 91, 91, 91, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 22, 22, 22, 26, 26, 26, 22, 22, 22, 22, 22, 26, 26, 26, 22, 22, 22, 26, 26, 16
	                         DB           19, 19, 16, 16, 19, 19, 19, 19, 19, 19, 16, 16, 16, 16, 16, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 91, 22, 22, 22, 26, 26, 26, 22, 22, 22, 22, 22, 26, 26, 26, 26, 26, 22, 22, 22, 16, 16, 19, 19, 19, 16, 16, 16, 16, 19, 19, 19, 19, 19, 16, 16, 16, 16
	                         DB           91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 26, 26, 26, 26, 26, 22, 22, 22, 26, 26, 26, 26
	                         DB           26, 22, 26, 22, 22, 16, 16, 16, 16, 19, 19, 19, 16, 16, 16, 16, 16, 19, 19, 22, 22, 22, 19, 16, 91, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 22, 26, 91, 91, 91, 91, 22, 22, 26, 26, 26, 26, 22, 22, 22, 22, 22, 22, 22, 26, 26, 16, 16, 19, 19, 19, 16, 16, 91
	                         DB           91, 91, 91, 91, 22, 22, 22, 22, 19, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 22
	                         DB           22, 26, 26, 91, 91, 91, 91, 22, 22, 22, 22, 26, 26, 26, 26, 16, 16, 16, 19, 19, 22, 22, 16, 16, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 0, 0, 91, 91, 22, 26, 26, 26, 26, 26, 91, 91
	                         DB           91, 91, 91, 91, 91, 22, 22, 22, 19, 19, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 26, 26, 26, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0, 91, 91, 91, 91, 91, 91, 91, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Meruem                   DB           0, 81, 58, 35, 122, 71, 71, 2, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 2, 2, 2, 2, 2, 71, 71, 71, 71, 34, 129, 129, 71, 71, 122, 35, 35, 58, 81, 0, 0, 81, 58, 35, 122, 71, 71, 71, 2, 2, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 2, 2, 71, 71, 71, 71, 71, 71, 129, 129, 96, 96
	                         DB           96, 71, 71, 122, 35, 58, 81, 0, 0, 81, 58, 35, 122, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 2, 2, 71, 71, 71, 71, 71, 71, 129, 34, 96, 96, 96, 96, 96, 71, 122, 35, 58, 81, 81, 0, 81, 58, 35, 122, 129, 71, 71
	                         DB           71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 2, 71, 71, 71, 71
	                         DB           71, 71, 96, 129, 34, 96, 96, 96, 96, 96, 71, 122, 35, 58, 58, 81, 0, 81, 58, 35, 122, 34, 129, 71, 71, 71, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71
	                         DB           71, 18, 18, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 2, 71, 71, 71, 71, 71, 71, 96, 34, 129, 96, 96, 96, 96, 96, 71, 71, 122, 35, 58, 81
	                         DB           0, 81, 58, 35, 122, 71, 34, 129, 71, 71, 18, 18, 18, 18, 18, 18, 122, 18, 18, 18, 18, 71, 71, 71, 71, 18, 18, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 2, 71, 71, 71, 71, 71, 96, 129, 34, 96, 96, 96, 96, 96, 96, 96, 71, 122, 35, 58, 81, 0, 81, 58, 35, 122, 71, 71, 129, 71, 71, 71, 18, 18, 18, 18, 18
	                         DB           122, 18, 18, 18, 18, 71, 71, 71, 71, 18, 18, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 96, 129, 34, 96, 96, 96, 96
	                         DB           96, 96, 96, 71, 122, 35, 58, 81, 0, 81, 58, 58, 35, 122, 71, 34, 129, 71, 71, 18, 18, 18, 18, 71, 71, 71, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 96, 129, 34, 96, 96, 96, 96, 96, 96, 96, 71, 122, 35, 58, 81, 0, 81, 81, 58, 35, 122, 71, 71
	                         DB           129, 71, 71, 18, 18, 18, 18, 71, 71, 71, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 122, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71
	                         DB           71, 96, 34, 34, 96, 96, 96, 96, 96, 96, 96, 71, 122, 35, 58, 81, 0, 0, 81, 58, 35, 122, 71, 71, 34, 129, 71, 71, 18, 18, 18, 71, 71, 71, 18, 18, 18, 18, 71, 71
	                         DB           71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 122, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 129, 34, 96, 96, 96, 96, 96, 96, 96, 122, 35, 58, 58, 81
	                         DB           0, 0, 81, 58, 58, 35, 122, 71, 71, 129, 71, 71, 18, 18, 18, 18, 71, 71, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 71, 71, 71, 18
	                         DB           18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 34, 129, 96, 96, 96, 96, 96, 96, 122, 35, 58, 81, 81, 0, 0, 81, 81, 58, 58, 35, 122, 71, 34, 129, 71, 71, 71, 18, 18
	                         DB           18, 71, 18, 18, 18, 18, 71, 71, 71, 71, 2, 71, 71, 71, 2, 18, 18, 18, 18, 18, 71, 71, 71, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 129, 34, 96, 96, 96
	                         DB           96, 96, 96, 122, 35, 58, 81, 0, 0, 0, 0, 81, 81, 58, 58, 35, 122, 71, 129, 71, 71, 71, 18, 18, 18, 71, 18, 18, 18, 18, 18, 71, 71, 2, 2, 2, 2, 71, 71, 2
	                         DB           18, 18, 18, 18, 71, 71, 71, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 129, 34, 129, 96, 96, 96, 129, 122, 35, 58, 58, 81, 0, 0, 0, 0, 0, 81, 81, 58, 58
	                         DB           35, 122, 122, 71, 71, 122, 122, 122, 122, 18, 71, 18, 18, 18, 18, 71, 2, 2, 2, 2, 2, 2, 71, 2, 2, 18, 18, 18, 18, 18, 71, 18, 18, 18, 18, 18, 18, 18, 18, 71
	                         DB           71, 71, 71, 71, 129, 34, 34, 34, 129, 122, 35, 35, 58, 81, 81, 0, 0, 0, 0, 0, 0, 81, 58, 58, 58, 35, 35, 122, 122, 35, 35, 35, 35, 122, 71, 18, 18, 18, 18, 2
	                         DB           2, 2, 71, 71, 2, 2, 2, 2, 2, 18, 18, 18, 18, 18, 71, 18, 18, 18, 18, 18, 18, 18, 122, 122, 122, 71, 71, 71, 71, 129, 129, 122, 122, 35, 58, 35, 81, 81, 0, 0
	                         DB           0, 0, 0, 0, 0, 58, 81, 81, 58, 58, 58, 35, 35, 35, 35, 35, 35, 122, 71, 122, 122, 122, 18, 18, 2, 71, 71, 71, 71, 71, 71, 2, 2, 18, 18, 18, 18, 18, 71, 71
	                         DB           122, 122, 122, 122, 122, 122, 35, 35, 35, 122, 122, 122, 122, 122, 122, 35, 35, 58, 58, 58, 81, 0, 0, 0, 0, 0, 0, 0, 81, 0, 81, 81, 81, 81, 58, 58, 58, 58, 58, 35
	                         DB           35, 122, 71, 122, 35, 35, 122, 122, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 2, 2, 2, 2, 122, 71, 122, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 58
	                         DB           58, 58, 81, 58, 81, 0, 0, 0, 0, 0, 0, 81, 81, 0, 0, 0, 0, 81, 58, 58, 58, 58, 58, 58, 35, 122, 71, 122, 35, 35, 35, 122, 2, 2, 2, 71, 71, 71, 71, 71
	                         DB           71, 71, 71, 71, 71, 71, 122, 71, 122, 35, 35, 35, 35, 35, 58, 58, 58, 58, 58, 58, 58, 58, 35, 58, 81, 81, 81, 58, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 81
	                         DB           81, 58, 81, 81, 81, 81, 58, 58, 35, 122, 71, 122, 35, 35, 122, 2, 71, 71, 71, 2, 2, 2, 71, 71, 71, 71, 71, 71, 71, 122, 122, 71, 122, 35, 35, 35, 58, 58, 58, 58
	                         DB           58, 81, 81, 81, 81, 58, 58, 81, 81, 0, 81, 81, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 81, 0, 0, 0, 0, 81, 81, 81, 58, 35, 122, 71, 122, 122, 122, 2, 71
	                         DB           71, 71, 71, 71, 71, 2, 2, 2, 2, 71, 71, 71, 71, 122, 122, 71, 122, 35, 35, 58, 58, 58, 58, 81, 81, 81, 81, 81, 81, 58, 58, 81, 0, 0, 81, 0, 81, 81, 81, 0
	                         DB           0, 0, 0, 81, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 81, 58, 35, 122, 71, 122, 122, 2, 71, 2, 2, 71, 71, 71, 71, 71, 71, 2, 2, 2, 71, 71, 71, 122, 35, 122
	                         DB           71, 122, 35, 58, 58, 81, 81, 81, 81, 0, 0, 0, 81, 58, 58, 81, 0, 0, 0, 0, 81, 58, 81, 0, 0, 0, 0, 81, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 81, 58
	                         DB           35, 122, 71, 122, 2, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 2, 71, 122, 35, 35, 122, 71, 122, 35, 58, 58, 81, 81, 81, 0, 0, 0, 0, 81, 81, 58, 81
	                         DB           0, 0, 0, 0, 81, 58, 81, 0, 0, 0, 81, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 35, 122, 122, 2, 71, 71, 122, 122, 122, 122, 71, 71, 71, 71, 71, 71
	                         DB           71, 71, 2, 2, 122, 35, 35, 122, 71, 122, 35, 58, 58, 81, 81, 0, 0, 0, 0, 0, 81, 81, 58, 81, 0, 0, 0, 0, 0, 81, 81, 0, 0, 0, 81, 0, 0, 81, 0, 0
	                         DB           0, 0, 0, 0, 0, 81, 58, 58, 35, 122, 2, 71, 71, 71, 71, 71, 71, 71, 122, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 35, 35, 122, 71, 122, 35, 58, 81, 81, 81, 0
	                         DB           0, 0, 0, 0, 0, 81, 81, 58, 81, 0, 0, 0, 0, 81, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 81, 58, 35, 122, 2, 71, 71, 71, 71, 71, 71
	                         DB           71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 35, 122, 71, 122, 35, 58, 81, 81, 81, 0, 0, 0, 0, 0, 0, 0, 81, 58, 81, 0, 0, 0, 0, 81, 0, 0
	                         DB           0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 81, 58, 35, 122, 71, 71, 71, 71, 71, 2, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 122
	                         DB           71, 122, 35, 58, 81, 81, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 81, 81, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 58, 58, 35
	                         DB           122, 71, 71, 71, 71, 2, 2, 2, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 71, 122, 35, 58, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 81, 58
	                         DB           81, 81, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 58, 35, 122, 71, 71, 71, 71, 122, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71
	                         DB           71, 71, 71, 71, 71, 71, 2, 122, 71, 122, 35, 58, 58, 81, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 81, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 81, 0, 0
	                         DB           0, 0, 0, 0, 81, 58, 35, 122, 71, 71, 71, 71, 71, 122, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 71, 71, 122, 35, 58, 81, 81, 0
	                         DB           0, 0, 0, 0, 0, 0, 81, 81, 81, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 81, 58, 35, 122, 71, 192, 192, 192, 192, 192, 192, 71
	                         DB           71, 71, 71, 192, 192, 192, 192, 192, 192, 71, 71, 71, 71, 71, 71, 71, 71, 71, 122, 35, 58, 58, 81, 0, 0, 0, 0, 0, 0, 0, 81, 81, 81, 0, 0, 0, 0, 81, 81, 0
	                         DB           0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 58, 58, 35, 122, 192, 30, 37, 37, 30, 192, 2, 2, 2, 2, 2, 192, 30, 37, 37, 37, 30, 192, 71, 71, 71, 71, 71, 71
	                         DB           71, 71, 71, 122, 35, 58, 81, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 81, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 58, 35, 122, 71
	                         DB           192, 28, 5, 5, 192, 2, 192, 2, 2, 2, 192, 2, 192, 5, 5, 5, 28, 28, 192, 71, 71, 71, 71, 71, 71, 2, 71, 122, 35, 58, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           81, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 35, 122, 192, 192, 192, 192, 192, 2, 195, 195, 195, 195, 2, 2, 192, 2, 192, 192, 192
	                         DB           192, 192, 192, 192, 71, 71, 122, 71, 2, 2, 71, 122, 35, 58, 58, 81, 81, 81, 81, 0, 0, 0, 0, 0, 0, 81, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81
	                         DB           81, 81, 81, 58, 58, 35, 195, 2, 2, 2, 2, 2, 195, 195, 195, 195, 195, 195, 195, 2, 192, 192, 2, 2, 2, 2, 2, 2, 2, 2, 122, 2, 2, 2, 2, 122, 35, 35, 58, 58
	                         DB           58, 58, 81, 81, 81, 0, 0, 0, 0, 81, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 58, 58, 58, 35, 195, 195, 192, 192, 195, 195, 195, 195, 195, 146, 195
	                         DB           195, 195, 195, 195, 195, 195, 195, 192, 192, 192, 192, 2, 2, 2, 2, 2, 2, 2, 195, 195, 195, 195, 35, 35, 35, 58, 58, 58, 81, 81, 0, 0, 0, 0, 81, 81, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 81, 58, 58, 35, 35, 35, 195, 195, 195, 195, 195, 195, 195, 195, 195, 146, 195, 146, 146, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 2, 2, 2, 2
	                         DB           195, 195, 195, 195, 195, 195, 195, 195, 195, 35, 35, 58, 58, 81, 0, 0, 0, 0, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 58, 35, 195, 195, 195, 195, 195, 195, 195
	                         DB           195, 195, 195, 195, 195, 195, 195, 195, 195, 146, 146, 146, 146, 146, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 35, 58, 81, 0, 0
	                         DB           0, 0, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 58, 35, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 122, 122, 195, 195, 195, 195, 195, 241, 195, 195
	                         DB           195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 146, 146, 146, 146, 195, 195, 195, 195, 35, 58, 81, 0, 0, 0, 0, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 58
	                         DB           58, 35, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 122, 122, 242, 122, 122, 122, 122, 122, 122, 122, 122, 195, 195, 195, 195, 195, 146, 146, 146, 146, 146, 146, 146, 195, 195, 195, 195, 195
	                         DB           195, 35, 35, 58, 58, 81, 0, 0, 0, 0, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 35, 35, 195, 122, 122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122
	                         DB           122, 122, 122, 122, 122, 122, 242, 122, 122, 122, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 122, 122, 122, 195, 35, 58, 58, 58, 81, 81, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 81, 58, 58, 35, 35, 195, 122, 122, 242, 122, 122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 242, 122
	                         DB           122, 122, 122, 122, 242, 122, 122, 195, 35, 58, 81, 81, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 58, 35, 195, 122, 122, 122
	                         DB           122, 122, 122, 242, 122, 122, 122, 242, 122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 195, 35, 58, 58, 81, 81, 81, 0, 0, 0
	                         DB           0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 35, 195, 122, 122, 122, 242, 122, 122, 122, 122, 122, 195, 195, 195, 195, 122, 122, 122, 122, 122, 122
	                         DB           122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122, 242, 122, 122, 195, 35, 58, 81, 81, 81, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 81, 58, 58, 35, 195, 242, 122, 225, 225, 122, 122, 122, 242, 242, 195, 195, 195, 195, 242, 122, 122, 122, 122, 122, 225, 225, 225, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 195, 35
	                         DB           58, 81, 0, 81, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 35, 195, 122, 225, 225, 225, 225, 122, 122, 122, 195, 195
	                         DB           195, 195, 195, 122, 122, 122, 122, 122, 225, 225, 225, 225, 225, 225, 225, 122, 122, 122, 242, 122, 122, 195, 35, 58, 58, 81, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 58, 58, 35, 225, 225, 225, 225, 225, 242, 122, 122, 195, 195, 195, 195, 195, 122, 122, 122, 122, 122, 225, 225, 225, 225, 225, 225, 225, 225
	                         DB           225, 225, 122, 122, 122, 195, 35, 58, 81, 81, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 35, 225, 225
	                         DB           225, 153, 225, 122, 122, 122, 195, 195, 146, 195, 195, 195, 122, 122, 122, 122, 122, 225, 225, 153, 153, 225, 225, 225, 225, 225, 225, 225, 225, 35, 58, 58, 81, 0, 0, 0, 81, 0, 0, 0
	                         DB           0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 58, 35, 225, 225, 153, 153, 122, 122, 122, 242, 195, 195, 146, 195, 195, 195, 122, 122, 122, 122
	                         DB           122, 242, 122, 225, 225, 153, 153, 225, 225, 225, 225, 225, 225, 35, 58, 81, 81, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 81, 58, 35, 225, 225, 153, 242, 122, 122, 122, 122, 195, 195, 146, 195, 195, 195, 122, 122, 122, 242, 122, 122, 122, 122, 122, 225, 225, 153, 153, 225, 225, 225, 225, 35, 58, 81
	                         DB           0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 58, 58, 35, 225, 225, 122, 242, 122, 122, 122, 122, 195
	                         DB           146, 195, 195, 195, 195, 242, 122, 122, 122, 122, 122, 122, 122, 122, 122, 225, 225, 153, 153, 153, 35, 58, 58, 81, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 58, 35, 195, 122, 122, 122, 122, 122, 122, 195, 146, 146, 195, 195, 195, 122, 122, 122, 122, 122, 122, 122, 242, 122, 122, 122
	                         DB           122, 225, 225, 35, 58, 58, 81, 0, 0, 0, 0, 0, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 58
	                         DB           35, 195, 122, 122, 242, 122, 122, 195, 146, 146, 195, 195, 195, 122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122, 195, 35, 35, 58, 58, 81, 81, 0, 0, 0, 0, 0, 0, 81, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 58, 35, 195, 122, 122, 122, 242, 195, 195, 146, 146, 195, 195, 195, 195, 122
	                         DB           242, 122, 122, 122, 122, 122, 122, 195, 35, 58, 58, 58, 81, 81, 0, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 81, 81, 58, 58, 35, 195, 122, 122, 122, 122, 195, 146, 146, 195, 195, 195, 195, 195, 195, 122, 122, 122, 122, 195, 195, 35, 58, 58, 81, 81, 81, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 58, 35, 195, 122, 122, 122
	                         DB           195, 146, 146, 146, 195, 195, 195, 195, 195, 195, 195, 195, 195, 35, 35, 58, 58, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 58, 35, 195, 195, 195, 195, 146, 146, 146, 146, 195, 195, 195, 195, 35, 35, 35, 35, 58, 58, 58
	                         DB           81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 81, 81, 58, 58, 35, 35, 35, 35, 195, 195, 195, 195, 195, 195, 195, 35, 58, 58, 58, 58, 58, 81, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 58, 58, 58, 58, 58, 35, 35, 35, 35, 35, 35, 35
	                         DB           58, 58, 81, 81, 81, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 81, 81, 81, 81, 58, 58, 58, 58, 58, 58, 58, 58, 58, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81
	                         DB           81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Meruem2                  DB           0, 0, 0, 95, 122, 71, 71, 2, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 2, 2, 2, 2, 2, 71, 71, 71, 71, 34, 129, 129, 71, 71, 122, 95, 95, 0, 0, 0, 0, 0, 0, 95, 122, 71, 71, 71, 2, 2, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 2, 2, 71, 71, 71, 71, 71, 71, 129, 129, 96, 96
	                         DB           96, 71, 71, 122, 95, 0, 0, 0, 0, 0, 0, 95, 122, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 2, 2, 71, 71, 71, 71, 71, 71, 129, 34, 96, 96, 96, 96, 96, 71, 122, 95, 0, 0, 0, 0, 0, 0, 95, 122, 129, 71, 71
	                         DB           71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 2, 71, 71, 71, 71
	                         DB           71, 71, 96, 129, 34, 96, 96, 96, 96, 96, 71, 122, 95, 95, 0, 0, 0, 0, 0, 95, 122, 34, 129, 71, 71, 71, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71
	                         DB           71, 18, 18, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 2, 71, 71, 71, 71, 71, 71, 96, 34, 129, 96, 96, 96, 96, 96, 71, 71, 122, 95, 0, 0
	                         DB           0, 0, 0, 95, 122, 71, 34, 129, 71, 71, 18, 18, 18, 18, 18, 18, 122, 18, 18, 18, 18, 71, 71, 71, 71, 18, 18, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18
	                         DB           18, 18, 18, 2, 71, 71, 71, 71, 71, 96, 129, 34, 96, 96, 96, 96, 96, 96, 96, 71, 122, 95, 0, 0, 0, 0, 0, 95, 122, 71, 71, 129, 71, 71, 71, 18, 18, 18, 18, 18
	                         DB           122, 18, 18, 18, 18, 71, 71, 71, 71, 18, 18, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 96, 129, 34, 96, 96, 96, 96
	                         DB           96, 96, 96, 71, 122, 95, 0, 0, 0, 0, 0, 95, 95, 122, 71, 34, 129, 71, 71, 18, 18, 18, 18, 71, 71, 71, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 18
	                         DB           18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 96, 129, 34, 96, 96, 96, 96, 96, 96, 96, 71, 122, 95, 0, 0, 0, 0, 0, 0, 95, 122, 71, 71
	                         DB           129, 71, 71, 18, 18, 18, 18, 71, 71, 71, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 122, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71
	                         DB           71, 96, 34, 34, 96, 96, 96, 96, 96, 96, 96, 71, 122, 95, 0, 0, 0, 0, 0, 0, 95, 122, 71, 71, 34, 129, 71, 71, 18, 18, 18, 71, 71, 71, 18, 18, 18, 18, 71, 71
	                         DB           71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 18, 122, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 129, 34, 96, 96, 96, 96, 96, 96, 96, 122, 95, 95, 0, 0
	                         DB           0, 0, 0, 0, 95, 95, 122, 71, 71, 129, 71, 71, 18, 18, 18, 18, 71, 71, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 71, 2, 18, 18, 18, 18, 18, 71, 71, 71, 18
	                         DB           18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 71, 34, 129, 96, 96, 96, 96, 96, 96, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 122, 71, 34, 129, 71, 71, 71, 18, 18
	                         DB           18, 71, 18, 18, 18, 18, 71, 71, 71, 71, 2, 71, 71, 71, 2, 18, 18, 18, 18, 18, 71, 71, 71, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 71, 129, 34, 96, 96, 96
	                         DB           96, 96, 96, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 122, 71, 129, 71, 71, 71, 18, 18, 18, 71, 18, 18, 18, 18, 18, 71, 71, 2, 2, 2, 2, 71, 71, 2
	                         DB           18, 18, 18, 18, 71, 71, 71, 18, 18, 18, 18, 18, 18, 18, 71, 71, 71, 71, 71, 129, 34, 129, 96, 96, 96, 129, 122, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95
	                         DB           95, 122, 122, 71, 71, 122, 122, 122, 122, 18, 71, 18, 18, 18, 18, 71, 2, 2, 2, 2, 2, 2, 71, 2, 2, 18, 18, 18, 18, 18, 71, 18, 18, 18, 18, 18, 18, 18, 18, 71
	                         DB           71, 71, 71, 71, 129, 34, 34, 34, 129, 122, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 95, 122, 122, 95, 95, 95, 95, 122, 71, 18, 18, 18, 18, 2
	                         DB           2, 2, 71, 71, 2, 2, 2, 2, 2, 18, 18, 18, 18, 18, 71, 18, 18, 18, 18, 18, 18, 18, 122, 122, 122, 71, 71, 71, 71, 129, 129, 122, 122, 95, 95, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 95, 95, 0, 0, 95, 122, 71, 122, 122, 122, 18, 18, 2, 71, 71, 71, 71, 71, 71, 2, 2, 18, 18, 18, 18, 18, 71, 71
	                         DB           122, 122, 122, 122, 122, 122, 95, 95, 95, 122, 122, 122, 122, 122, 122, 95, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           95, 122, 71, 122, 95, 95, 122, 122, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 2, 2, 2, 2, 122, 71, 122, 95, 95, 95, 95, 95, 95, 0, 95, 95, 95, 95, 95, 95, 95, 95
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 71, 122, 95, 95, 95, 122, 2, 2, 2, 71, 71, 71, 71, 71
	                         DB           71, 71, 71, 71, 71, 71, 122, 71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 71, 122, 95, 95, 122, 2, 71, 71, 71, 2, 2, 2, 71, 71, 71, 71, 71, 71, 71, 122, 122, 71, 122, 95, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 71, 122, 122, 122, 2, 71
	                         DB           71, 71, 71, 71, 71, 2, 2, 2, 2, 71, 71, 71, 71, 122, 122, 71, 122, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 71, 122, 122, 2, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 2, 2, 71, 71, 71, 122, 95, 122
	                         DB           71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           95, 122, 71, 122, 2, 71, 71, 2, 2, 71, 71, 71, 71, 71, 71, 71, 71, 2, 2, 71, 122, 95, 95, 122, 71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 122, 2, 71, 71, 71, 71, 71, 71, 122, 71, 71, 71, 71, 71
	                         DB           71, 71, 2, 2, 122, 95, 95, 122, 71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 95, 95, 122, 2, 71, 71, 71, 122, 122, 122, 122, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 95, 95, 122, 71, 122, 95, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 2, 71, 71, 71, 71, 71, 71
	                         DB           71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 95, 122, 71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 71, 71, 71, 71, 71, 2, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 122
	                         DB           71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95
	                         DB           122, 71, 71, 71, 71, 2, 2, 2, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 71, 71, 71, 71, 122, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71
	                         DB           71, 71, 71, 71, 71, 71, 2, 122, 71, 122, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 95, 122, 71, 71, 71, 71, 71, 122, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 71, 2, 122, 71, 71, 122, 95, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 71, 192, 192, 192, 192, 192, 192, 71
	                         DB           71, 71, 71, 192, 192, 192, 192, 192, 192, 71, 71, 71, 71, 71, 71, 71, 71, 71, 122, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 122, 192, 30, 37, 37, 30, 192, 2, 2, 2, 2, 2, 192, 30, 37, 37, 37, 30, 192, 71, 71, 71, 71, 71, 71
	                         DB           71, 71, 71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 71
	                         DB           192, 28, 5, 5, 192, 2, 192, 2, 2, 2, 192, 2, 192, 5, 5, 5, 28, 28, 192, 71, 71, 71, 71, 71, 71, 2, 71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 122, 192, 192, 192, 192, 192, 2, 195, 195, 195, 195, 2, 2, 192, 2, 192, 192, 192
	                         DB           192, 192, 192, 192, 71, 71, 122, 71, 2, 2, 71, 122, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 95, 95, 195, 2, 2, 2, 2, 2, 195, 195, 195, 195, 195, 195, 195, 2, 192, 192, 2, 2, 2, 2, 2, 2, 2, 2, 122, 2, 2, 2, 2, 122, 95, 95, 95, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 195, 195, 192, 192, 195, 195, 195, 195, 195, 146, 195
	                         DB           195, 195, 195, 195, 195, 195, 195, 192, 192, 192, 192, 2, 2, 2, 2, 2, 2, 2, 195, 195, 195, 195, 95, 95, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 95, 95, 195, 195, 195, 195, 195, 195, 195, 195, 195, 146, 195, 146, 146, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 2, 2, 2, 2
	                         DB           195, 195, 195, 195, 195, 195, 195, 195, 195, 95, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 195, 195, 195, 195, 195, 195, 195
	                         DB           195, 195, 195, 195, 195, 195, 195, 195, 195, 146, 146, 146, 146, 146, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 95, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 122, 122, 195, 195, 195, 195, 195, 241, 195, 195
	                         DB           195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 146, 146, 146, 146, 195, 195, 195, 195, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           95, 95, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 122, 122, 242, 122, 122, 122, 122, 122, 122, 122, 122, 195, 195, 195, 195, 195, 146, 146, 146, 146, 146, 146, 146, 195, 195, 195, 195, 195
	                         DB           195, 95, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 195, 122, 122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122
	                         DB           122, 122, 122, 122, 122, 122, 242, 122, 122, 122, 195, 195, 195, 195, 195, 195, 195, 195, 195, 195, 122, 122, 122, 195, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 195, 122, 122, 242, 122, 122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 242, 122
	                         DB           122, 122, 122, 122, 242, 122, 122, 195, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 195, 122, 122, 122
	                         DB           122, 122, 122, 242, 122, 122, 122, 242, 122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 195, 95, 95, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 195, 122, 122, 122, 242, 122, 122, 122, 122, 122, 195, 195, 195, 195, 122, 122, 122, 122, 122, 122
	                         DB           122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122, 242, 122, 122, 195, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 95, 95, 195, 242, 122, 225, 225, 122, 122, 122, 242, 242, 195, 195, 195, 195, 242, 122, 122, 122, 122, 122, 225, 225, 225, 122, 122, 122, 122, 122, 122, 122, 122, 122, 122, 195, 95
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 195, 122, 225, 225, 225, 225, 122, 122, 122, 195, 195
	                         DB           195, 195, 195, 122, 122, 122, 122, 122, 225, 225, 225, 225, 225, 225, 225, 122, 122, 122, 242, 122, 122, 195, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 225, 225, 225, 225, 225, 242, 122, 122, 195, 195, 195, 195, 195, 122, 122, 122, 122, 122, 225, 225, 225, 225, 225, 225, 225, 225
	                         DB           225, 225, 122, 122, 122, 195, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 225, 225
	                         DB           225, 153, 225, 122, 122, 122, 195, 195, 146, 195, 195, 195, 122, 122, 122, 122, 122, 225, 225, 153, 153, 225, 225, 225, 225, 225, 225, 225, 225, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 225, 225, 153, 153, 122, 122, 122, 242, 195, 195, 146, 195, 195, 195, 122, 122, 122, 122
	                         DB           122, 242, 122, 225, 225, 153, 153, 225, 225, 225, 225, 225, 225, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 95, 225, 225, 153, 242, 122, 122, 122, 122, 195, 195, 146, 195, 195, 195, 122, 122, 122, 242, 122, 122, 122, 122, 122, 225, 225, 153, 153, 225, 225, 225, 225, 95, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 225, 225, 122, 242, 122, 122, 122, 122, 195
	                         DB           146, 195, 195, 195, 195, 242, 122, 122, 122, 122, 122, 122, 122, 122, 122, 225, 225, 153, 153, 153, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 195, 122, 122, 122, 122, 122, 122, 195, 146, 146, 195, 195, 195, 122, 122, 122, 122, 122, 122, 122, 242, 122, 122, 122
	                         DB           122, 225, 225, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95
	                         DB           95, 195, 122, 122, 242, 122, 122, 195, 146, 146, 195, 195, 195, 122, 122, 122, 122, 122, 242, 122, 122, 122, 122, 122, 195, 95, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 195, 122, 122, 122, 242, 195, 195, 146, 146, 195, 195, 195, 195, 122
	                         DB           242, 122, 122, 122, 122, 122, 122, 195, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 195, 122, 122, 122, 122, 195, 146, 146, 195, 195, 195, 195, 195, 195, 122, 122, 122, 122, 195, 195, 95, 95, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 195, 122, 122, 122
	                         DB           195, 146, 146, 146, 195, 195, 195, 195, 195, 195, 195, 195, 195, 95, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 195, 195, 195, 195, 146, 146, 146, 146, 195, 195, 195, 195, 95, 95, 95, 95, 95, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 95, 95, 95, 95, 95, 195, 195, 195, 195, 195, 195, 195, 95, 95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 95, 95, 95, 95, 95, 95, 95
	                         DB           95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	
	; Planes
	shipSizeX                equ          32
	shipSizeY                equ          32
	firstShipOffsetX         equ          96
	secondShipOffsetX        equ          200
	thirdShipOffsetX         equ          304
	fourthShipOffsetX        equ          408
	fifthShipOffsetX         equ          512
	shipOffsetY              equ          304
	;
	                         arrow        label byte
	                         ship2        label byte                                                                                                                                                                                            	; remove before adding ship2
	                         ship1        label byte
	Mikasa_Plane             DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 138, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 138, 138, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19
	                         DB           138, 138, 138, 138, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 138, 138, 138, 66, 138, 19, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 138, 138, 138, 138, 138, 138, 19, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 19, 19, 19, 0, 0, 0, 19, 138, 138, 138, 138, 66, 138, 19, 0, 0, 0, 0, 0, 0, 19, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29
	                         DB           29, 19, 19, 19, 19, 19, 19, 138, 66, 66, 138, 19, 0, 0, 0, 0, 0, 19, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 19, 19, 19, 19, 19, 19, 66
	                         DB           138, 66, 138, 19, 0, 0, 0, 0, 19, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 19, 19, 19, 19, 138, 66, 138, 138, 66, 138, 19, 0, 0, 0, 0
	                         DB           0, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 23, 19, 19, 19, 66, 138, 66, 66, 138, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 19, 19, 138, 138, 138, 138, 138, 138, 19, 23, 23, 27, 27, 19, 138, 66, 66, 66, 66, 19, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 66, 66, 66, 66, 66, 66, 66
	                         DB           66, 138, 19, 19, 19, 19, 138, 66, 66, 138, 138, 19, 19, 23, 23, 27, 0, 0, 19, 19, 66, 66, 91, 91, 91, 91, 66, 91, 66, 91, 66, 138, 138, 138, 91, 138, 66, 66, 91, 138
	                         DB           66, 66, 66, 66, 4, 65, 65, 23, 0, 19, 66, 91, 91, 4, 4, 4, 91, 91, 91, 91, 91, 66, 91, 66, 66, 66, 91, 66, 66, 91, 91, 66, 66, 66, 66, 66, 6, 64, 64, 64
	                         DB           19, 66, 91, 4, 64, 64, 64, 64, 4, 91, 91, 91, 66, 91, 66, 91, 91, 91, 91, 138, 66, 66, 91, 138, 66, 66, 138, 19, 67, 67, 67, 67, 19, 66, 91, 4, 64, 64, 64, 64
	                         DB           4, 91, 91, 91, 66, 91, 66, 91, 91, 91, 91, 138, 66, 66, 91, 138, 66, 66, 138, 19, 67, 67, 67, 67, 0, 19, 66, 91, 91, 4, 4, 4, 91, 91, 91, 91, 91, 66, 91, 66
	                         DB           66, 66, 91, 66, 66, 91, 91, 66, 66, 66, 66, 66, 6, 64, 64, 64, 0, 0, 19, 19, 66, 66, 91, 91, 91, 91, 66, 91, 66, 91, 66, 138, 138, 138, 91, 138, 66, 66, 91, 138
	                         DB           66, 66, 66, 66, 4, 65, 65, 23, 0, 0, 0, 0, 19, 19, 19, 19, 19, 66, 66, 66, 66, 66, 66, 66, 66, 138, 19, 19, 19, 19, 138, 66, 66, 138, 138, 19, 19, 23, 23, 27
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 138, 138, 138, 138, 138, 138, 19, 23, 23, 27, 27, 19, 138, 66, 66, 66, 66, 19, 0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 23, 19, 19, 19, 66, 138, 66, 66, 138, 19, 0, 0, 0, 0, 19, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27
	                         DB           27, 19, 19, 19, 19, 138, 66, 138, 138, 66, 138, 19, 0, 0, 0, 0, 0, 19, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 19, 19, 19, 19, 19, 19, 66
	                         DB           138, 66, 138, 19, 0, 0, 0, 0, 0, 0, 19, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 19, 19, 19, 19, 19, 19, 138, 66, 66, 138, 19, 0, 0, 0, 0
	                         DB           0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 0, 0, 0, 19, 138, 138, 138, 138, 66, 138, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 138, 138, 138, 138, 138, 138, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 19, 138, 138, 138, 66, 138, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19
	                         DB           138, 138, 138, 138, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 138, 138, 19, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 138, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 0, 0, 0
	Meruem_Plane             DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 73, 169
	                         DB           73, 169, 73, 19, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 73, 169, 73, 169, 169, 19, 19, 169, 169, 19
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 169, 73, 19, 169, 169, 169, 19, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 19, 169, 169, 169, 169, 169, 73, 73, 73, 73, 169, 169, 169, 169, 169, 169, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 95, 95, 95, 95, 95, 95, 95
	                         DB           95, 95, 73, 73, 73, 73, 73, 73, 169, 19, 42, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 169, 169, 169, 169, 169, 73, 73, 73, 73, 73, 169, 169, 169, 169, 169
	                         DB           169, 19, 42, 44, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 95, 95, 95, 95, 95, 95, 95, 95, 95, 73, 73, 73, 73, 73, 73, 169, 19, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 169, 169, 169, 169, 169, 73, 73, 73, 73, 169, 169, 169, 169, 169, 169, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 19, 19, 19, 19, 169, 169, 169, 169, 169, 73, 73, 169, 169, 73, 169, 169, 169, 169, 169, 19, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 73, 73, 73, 73, 73, 73, 73
	                         DB           73, 95, 169, 73, 73, 95, 169, 73, 169, 169, 169, 19, 0, 0, 0, 0, 0, 19, 73, 73, 95, 95, 95, 95, 95, 95, 95, 95, 73, 95, 73, 73, 73, 73, 95, 169, 73, 73, 95, 169
	                         DB           73, 73, 73, 73, 42, 66, 66, 0, 19, 73, 73, 95, 95, 35, 35, 35, 95, 95, 95, 95, 95, 73, 95, 73, 73, 73, 95, 73, 73, 73, 95, 73, 73, 73, 73, 73, 43, 44, 44, 44
	                         DB           19, 73, 95, 35, 58, 58, 58, 58, 35, 95, 95, 95, 73, 95, 73, 95, 95, 95, 95, 169, 73, 73, 95, 169, 73, 73, 169, 19, 0, 0, 0, 0, 19, 73, 95, 35, 58, 58, 58, 58
	                         DB           35, 95, 95, 95, 73, 95, 73, 95, 95, 95, 95, 169, 73, 73, 95, 169, 73, 73, 169, 19, 0, 0, 0, 0, 19, 73, 73, 95, 95, 35, 35, 35, 95, 95, 95, 95, 95, 73, 95, 73
	                         DB           73, 73, 95, 73, 73, 73, 95, 73, 73, 73, 73, 73, 43, 44, 44, 44, 0, 19, 73, 73, 95, 95, 95, 95, 95, 95, 95, 95, 73, 95, 73, 73, 73, 73, 95, 169, 73, 73, 95, 169
	                         DB           73, 73, 73, 73, 42, 66, 66, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 73, 73, 73, 73, 73, 73, 73, 73, 95, 169, 73, 73, 95, 169, 73, 169, 169, 169, 19, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 169, 169, 169, 169, 169, 73, 73, 169, 169, 73, 169, 169, 169, 169, 169, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 19, 169, 169, 169, 169, 169, 73, 73, 73, 73, 169, 169, 169, 169, 169, 169, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 95, 95, 95, 95, 95, 95, 95
	                         DB           95, 95, 73, 73, 73, 73, 73, 73, 169, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 169, 169, 169, 169, 169, 73, 73, 73, 73, 73, 169, 169, 169, 169, 169
	                         DB           169, 19, 42, 44, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 95, 95, 95, 95, 95, 95, 95, 95, 95, 73, 73, 73, 73, 73, 73, 169, 19, 42, 43, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 169, 169, 169, 169, 169, 73, 73, 73, 73, 169, 169, 169, 169, 169, 169, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 19, 19, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19
	                         DB           19, 169, 73, 19, 169, 169, 169, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 73, 169, 73, 169, 169, 19, 19, 169, 169, 19
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 73, 169, 73, 169, 73, 19, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Asta_Plane               DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 16, 42, 43, 16, 41, 4, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 16, 16, 0, 16, 42, 16, 4, 41, 16, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 41, 16, 0, 16, 16
	                         DB           41, 4, 16, 0, 0, 0, 0, 0, 0, 0, 0, 16, 41, 4, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 4, 41, 16, 0, 16, 4, 41, 16, 16, 16, 16, 16, 16
	                         DB           16, 16, 16, 16, 16, 16, 4, 16, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 16, 16, 16, 16, 16, 0, 16, 4, 41, 4, 16, 41, 16, 41, 16, 41, 4, 16, 41, 16, 41, 16
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 16, 4, 16, 41, 16, 41, 4, 16, 0, 41, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 16, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           16, 41, 16, 16, 16, 4, 41, 4, 41, 114, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 16, 0, 55, 55, 55, 0, 0, 0, 0, 16, 4, 41, 16, 41, 41, 4, 41
	                         DB           114, 114, 114, 114, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 16, 55, 54, 54, 53, 55, 0, 0, 0, 16, 16, 16, 16, 16, 16, 16, 16, 16, 114, 114, 114, 114, 114, 114, 114
	                         DB           114, 114, 114, 114, 114, 114, 114, 16, 54, 54, 53, 53, 55, 0, 0, 0, 16, 0, 0, 16, 0, 0, 0, 0, 16, 114, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 16
	                         DB           54, 54, 53, 53, 53, 55, 55, 0, 0, 0, 0, 16, 0, 0, 16, 16, 16, 54, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 16, 54, 53, 53, 52, 52, 52, 53, 55
	                         DB           0, 0, 0, 0, 0, 16, 16, 16, 114, 114, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 16, 54, 53, 53, 52, 76, 76, 76, 76, 0, 0, 0, 0, 0, 16, 16, 16
	                         DB           114, 114, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 16, 54, 53, 53, 52, 52, 52, 53, 55, 0, 0, 0, 16, 0, 0, 16, 16, 16, 54, 114, 114, 114, 114, 114, 114
	                         DB           114, 114, 114, 114, 114, 114, 114, 16, 54, 53, 53, 52, 53, 54, 54, 55, 16, 0, 0, 16, 0, 0, 0, 0, 16, 114, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 16
	                         DB           54, 54, 53, 53, 53, 55, 55, 0, 16, 16, 16, 16, 16, 16, 16, 16, 16, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 16, 54, 54, 53, 53, 55, 0, 0, 0
	                         DB           16, 4, 41, 16, 41, 41, 4, 41, 114, 114, 114, 114, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 16, 55, 54, 54, 54, 55, 0, 0, 0, 16, 41, 16, 16, 16, 4, 41, 4
	                         DB           41, 114, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 42, 114, 16, 0, 55, 55, 55, 0, 0, 0, 0, 16, 4, 16, 41, 16, 41, 4, 16, 0, 41, 114, 114, 114, 114, 114, 114
	                         DB           114, 114, 114, 114, 114, 114, 114, 16, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 16, 16, 16, 16, 16, 0, 16, 4, 41, 4, 16, 41, 16, 41, 16, 41, 4, 16, 41, 16, 41, 16
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 4, 41, 16, 0, 16, 4, 41, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 4, 16, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 16, 41, 16, 0, 16, 16, 41, 4, 16, 0, 0, 0, 0, 0, 0, 0, 0, 16, 41, 4, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 0, 16, 42, 16
	                         DB           4, 41, 16, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 16, 42, 43, 16, 41, 4, 16, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Hisoka_Plane             DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 63, 134
	                         DB           63, 134, 63, 19, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 63, 134, 63, 134, 134, 19, 19, 134, 134, 19
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 134, 63, 19, 134, 134, 134, 19, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 134, 134, 134, 134, 134, 134, 134, 63, 63, 134, 134, 134, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 63, 134, 63
	                         DB           134, 63, 134, 63, 134, 134, 134, 134, 134, 63, 63, 63, 134, 63, 134, 134, 134, 19, 0, 0, 0, 0, 0, 0, 0, 0, 19, 63, 134, 63, 134, 63, 134, 63, 63, 63, 63, 63, 134, 134
	                         DB           63, 63, 63, 63, 63, 63, 134, 134, 134, 19, 42, 43, 0, 0, 0, 0, 0, 0, 19, 63, 134, 63, 134, 63, 134, 63, 134, 63, 134, 134, 63, 134, 134, 63, 63, 63, 134, 63, 134, 134
	                         DB           134, 19, 42, 44, 44, 0, 0, 0, 0, 0, 19, 63, 134, 63, 134, 63, 134, 63, 63, 63, 63, 63, 134, 63, 134, 134, 134, 63, 63, 134, 134, 134, 134, 19, 42, 44, 0, 0, 0, 0
	                         DB           0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 134, 63, 134, 134, 63, 134, 63, 134, 134, 134, 134, 134, 134, 134, 134, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 19, 63, 134, 134, 63, 134, 63, 134, 19, 19, 19, 19, 63, 134, 134, 134, 134, 42, 43, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19
	                         DB           19, 19, 63, 63, 63, 63, 134, 63, 134, 134, 134, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 43, 43, 86, 86, 86, 86, 86, 86, 86, 86, 63, 86, 134
	                         DB           63, 63, 63, 63, 42, 66, 66, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 43, 43, 86, 86, 35, 35, 35, 86, 86, 86, 86, 86, 86, 63, 63, 63, 63, 63, 43, 44, 44, 44
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 43, 86, 35, 58, 58, 58, 58, 35, 86, 86, 86, 63, 86, 134, 63, 63, 134, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 19, 43, 86, 35, 58, 58, 58, 58, 35, 86, 86, 86, 63, 86, 134, 63, 63, 134, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 43, 43, 86, 86, 35, 35
	                         DB           35, 86, 86, 86, 86, 86, 86, 63, 63, 63, 63, 63, 43, 44, 44, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 43, 43, 86, 86, 86, 86, 86, 86, 86, 86, 63, 86, 134
	                         DB           63, 63, 63, 63, 42, 66, 66, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 63, 63, 63, 63, 134, 63, 134, 134, 134, 19, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 63, 134, 63, 134, 63, 134, 19, 19, 19, 19, 63, 134, 134, 134, 134, 42, 43, 44, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19
	                         DB           19, 19, 134, 63, 134, 134, 63, 134, 63, 134, 134, 134, 134, 134, 134, 134, 134, 19, 19, 19, 0, 0, 0, 0, 0, 0, 19, 63, 134, 63, 134, 63, 134, 63, 63, 63, 63, 63, 134, 63
	                         DB           134, 134, 134, 63, 63, 134, 134, 134, 134, 19, 42, 44, 0, 0, 0, 0, 0, 0, 19, 63, 134, 63, 134, 63, 134, 63, 134, 63, 134, 134, 63, 134, 134, 63, 63, 63, 63, 63, 63, 134
	                         DB           134, 19, 42, 44, 44, 0, 0, 0, 0, 0, 19, 63, 134, 63, 134, 63, 134, 63, 63, 63, 63, 63, 134, 134, 63, 63, 63, 63, 63, 63, 63, 63, 134, 19, 42, 43, 0, 0, 0, 0
	                         DB           0, 0, 0, 19, 19, 63, 134, 63, 134, 63, 134, 63, 134, 134, 134, 134, 134, 63, 63, 63, 63, 63, 63, 134, 134, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19
	                         DB           19, 19, 19, 19, 134, 134, 134, 134, 134, 134, 134, 63, 63, 134, 134, 134, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19
	                         DB           19, 134, 63, 19, 134, 134, 134, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 63, 134, 63, 134, 134, 19, 19, 134, 134, 19
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 63, 134, 63, 134, 63, 19, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         
	Fenn_Plane               DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 77, 151
	                         DB           77, 151, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 77, 151, 77, 151, 151, 19, 19, 19, 19, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 4, 4, 4, 19, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 4, 151, 151, 151, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 19, 19, 112, 4, 112, 151, 151, 151, 151, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 112
	                         DB           0, 4, 0, 112, 151, 151, 151, 151, 151, 19, 42, 43, 0, 0, 0, 0, 0, 19, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 112, 4, 4, 4, 112, 112, 4, 112, 4
	                         DB           40, 64, 42, 44, 44, 0, 0, 0, 0, 0, 19, 19, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 112, 0, 4, 0, 112, 151, 151, 151, 151, 4, 40, 19, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 112, 4, 112, 151, 151, 151, 151, 151, 151, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 19, 19, 19, 19, 151, 151, 151, 151, 4, 151, 151, 77, 77, 77, 151, 77, 77, 77, 77, 19, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 77, 77, 77, 77, 77, 77, 151
	                         DB           4, 4, 4, 151, 77, 100, 151, 77, 77, 151, 151, 19, 0, 0, 0, 0, 0, 19, 77, 77, 77, 100, 100, 100, 100, 100, 77, 100, 77, 100, 77, 151, 151, 151, 100, 151, 77, 77, 100, 151
	                         DB           77, 77, 77, 77, 42, 66, 66, 0, 19, 77, 77, 100, 100, 47, 47, 47, 100, 100, 100, 100, 100, 77, 100, 77, 77, 77, 100, 77, 77, 77, 100, 77, 77, 77, 77, 77, 43, 44, 44, 44
	                         DB           19, 77, 100, 47, 73, 73, 73, 73, 47, 100, 100, 100, 77, 100, 77, 100, 100, 100, 100, 151, 77, 77, 100, 151, 77, 77, 151, 19, 0, 0, 0, 0, 19, 77, 100, 47, 73, 73, 73, 73
	                         DB           47, 100, 100, 100, 77, 100, 77, 100, 100, 100, 100, 151, 77, 77, 100, 151, 77, 77, 151, 19, 0, 0, 0, 0, 19, 77, 77, 100, 100, 47, 47, 47, 100, 100, 100, 100, 100, 77, 100, 77
	                         DB           77, 77, 100, 77, 77, 77, 100, 77, 77, 77, 77, 77, 43, 44, 44, 44, 0, 19, 77, 77, 77, 100, 100, 100, 100, 100, 77, 100, 77, 100, 77, 151, 151, 151, 100, 151, 77, 77, 100, 151
	                         DB           77, 77, 77, 77, 42, 66, 66, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 77, 77, 77, 77, 77, 77, 151, 4, 4, 4, 151, 77, 100, 151, 77, 77, 151, 151, 19, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 151, 151, 151, 151, 4, 151, 151, 77, 77, 77, 151, 77, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19
	                         DB           19, 19, 19, 19, 19, 19, 19, 19, 112, 4, 112, 151, 151, 151, 151, 151, 151, 19, 19, 19, 0, 0, 0, 0, 0, 0, 19, 19, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 112
	                         DB           0, 4, 0, 112, 151, 151, 151, 151, 4, 40, 19, 0, 0, 0, 0, 0, 0, 19, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 112, 4, 4, 4, 112, 112, 4, 112, 4
	                         DB           40, 64, 42, 44, 44, 0, 0, 0, 0, 0, 19, 19, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 112, 0, 4, 0, 112, 151, 151, 151, 151, 151, 19, 42, 43, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 112, 4, 112, 151, 151, 151, 151, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 19, 4, 151, 151, 151, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19
	                         DB           4, 4, 4, 19, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 77, 151, 77, 151, 151, 19, 19, 19, 19, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 77, 151, 77, 151, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	;
	NameBoxC                 DB           0, 0, 0, 0, 0, 0, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222
	                         DB           222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 222, 222, 150, 150, 222, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150
	                         DB           150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 222, 150, 150, 222, 222, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 222, 222, 150, 3, 150, 222, 150, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 150, 222, 150, 3, 150
	                         DB           222, 222, 0, 0, 0, 0, 0, 0, 0, 222, 222, 150, 77, 53, 150, 222, 150, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 150, 222, 150
	                         DB           53, 77, 150, 222, 222, 0, 0, 0, 0, 0, 222, 222, 150, 77, 3, 3, 222, 150, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           150, 222, 3, 3, 77, 150, 222, 222, 0, 0, 0, 222, 222, 150, 77, 3, 77, 53, 222, 150, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 150, 222, 53, 77, 3, 77, 150, 222, 222, 0, 222, 222, 150, 77, 77, 77, 3, 3, 222, 150, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 150, 222, 3, 3, 77, 77, 77, 150, 222, 222, 222, 150, 77, 77, 77, 3, 77, 53, 222, 150, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 150, 222, 53, 77, 3, 77, 77, 77, 150, 222, 222, 150, 77, 77, 77, 77, 3, 3, 222, 150, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 150, 222, 3, 3, 77, 77, 77, 77, 150, 222, 222, 150, 77, 77, 77, 3, 77, 53, 222, 150, 77, 77, 77, 77, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 77, 77, 77, 77, 150, 222, 53, 77, 3, 77, 77, 77, 150, 222, 222, 222, 150, 77, 77, 77, 3, 3, 222, 150, 77, 77, 77, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 77, 77, 77, 150, 222, 3, 3, 77, 77, 77, 150, 222, 222, 0, 222, 222, 150, 77, 3, 77, 53, 222, 150, 77, 77, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 77, 77, 150, 222, 53, 77, 3, 77, 150, 222, 222, 0, 0, 0, 222, 222, 150, 77, 3, 3, 222, 150, 77, 77, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 77, 77, 150, 222, 3, 3, 77, 150, 222, 222, 0, 0, 0, 0, 222, 150, 77, 3, 77, 53, 222, 150, 77, 77, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 77, 77, 150, 222, 53, 77, 3, 77, 150, 222, 0, 0, 0, 222, 222, 150, 77, 77, 3, 3, 222, 150, 77, 77
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 77, 77, 150, 222, 3, 3, 77, 77, 150, 222, 222, 0, 0, 222, 150, 77, 77, 3, 77, 53, 222, 150
	                         DB           77, 77, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 77, 77, 150, 222, 53, 77, 3, 77, 77, 150, 222, 0, 0, 222, 150, 77, 77, 77, 3, 3
	                         DB           222, 150, 77, 77, 77, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100
	                         DB           100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 77, 77, 77, 150, 222, 3, 3, 77, 77, 77, 150, 222, 0, 0, 222, 150, 77, 77, 3
	                         DB           77, 53, 150, 222, 150, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 150, 222, 150, 53, 77, 3, 77, 77, 150, 222, 0, 222, 222, 150, 77
	                         DB           77, 77, 3, 3, 150, 222, 150, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77
	                         DB           77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 150, 222, 150, 3, 3, 77, 77, 77, 150, 222, 222, 222, 150
	                         DB           77, 77, 77, 3, 77, 53, 150, 222, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150
	                         DB           150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 222, 150, 53, 77, 3, 77, 77, 77, 150, 222
	                         DB           222, 150, 77, 77, 77, 77, 3, 150, 150, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222
	                         DB           222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 222, 150, 150, 3, 77, 77, 77, 77
	                         DB           150, 222, 222, 150, 77, 77, 77, 3, 150, 222, 222, 222, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 222, 222, 222, 150, 3, 77
	                         DB           77, 77, 150, 222, 222, 150, 77, 77, 77, 150, 222, 222, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 222, 222
	                         DB           150, 77, 77, 77, 150, 222, 222, 150, 77, 77, 150, 222, 222, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 222, 222, 150, 77, 77, 150, 222, 222, 150, 150, 150, 222, 222, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 222, 222, 150, 150, 150, 222, 222, 222, 222, 222, 222, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 222, 222, 222, 222, 222
	;
	Explosion1               DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 41, 41, 41, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 42, 42, 42, 42, 41, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 41, 41, 43, 44, 43, 42, 41, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 41, 42, 44
	                         DB           68, 44, 44, 42, 41, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 42, 44, 44, 44, 43, 41, 0, 0, 0, 0
	                         DB           42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 41, 42, 42, 43, 42, 42, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42, 42, 42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Explosion2               DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 41, 41, 41, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 44, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 44, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41
	                         DB           41, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 41, 42, 41, 41, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 41, 41, 42, 42, 42, 42, 42, 41, 41, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0
	                         DB           0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 41, 41, 42, 43, 44, 44, 43, 42, 42, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0
	                         DB           0, 0, 0, 41, 42, 42, 44, 68, 68, 44, 43, 43, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 41, 41, 0, 0, 41, 42, 43, 44, 68
	                         DB           68, 44, 44, 43, 42, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 43, 0, 0, 0, 41, 42, 43, 44, 44, 44, 44, 43, 42, 41, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 44, 43, 0, 0, 0, 0, 41, 42, 42, 42, 43, 43, 42, 42, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 41, 42, 42, 41, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 41, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 41, 43, 0, 0
	                         DB           0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 43, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 44, 0, 0, 0, 41, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 41, 41, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Explosion3               DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 42, 42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42
	                         DB           42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 92, 43, 43, 42, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 44, 68, 43, 42, 44, 92, 92, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 44, 44, 42, 43, 44, 92, 68, 42, 42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 42, 43, 43, 42, 43, 44, 44, 43, 42, 44, 92, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 44, 43, 42, 43, 42
	                         DB           43, 44, 43, 42, 43, 44, 68, 92, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42, 43, 44, 43, 42, 42, 42, 43, 43, 42, 43, 44, 44, 44
	                         DB           42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 43, 43, 42, 42, 43, 42, 43, 43, 42, 42, 42, 43, 43, 43, 42, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 42, 42, 43, 92, 68, 44, 43, 42, 43, 44, 44, 44, 43, 42, 42, 44, 68, 43, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           43, 68, 44, 44, 43, 42, 43, 92, 92, 44, 43, 43, 42, 44, 68, 92, 92, 42, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 42, 44, 44, 43, 42, 42, 43, 92
	                         DB           92, 44, 44, 43, 42, 44, 44, 68, 68, 42, 0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 43, 43, 43, 42, 42, 43, 44, 44, 44, 43, 42, 42, 43, 44, 44
	                         DB           44, 42, 0, 0, 0, 0, 0, 0, 43, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42, 42, 42, 43, 43, 42, 42, 43, 42, 43, 43, 43, 43, 42, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42, 43, 43, 43, 43, 43, 42, 43, 43, 43, 42, 42, 42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 42, 43, 44, 44, 44, 43, 42, 43, 43, 44, 44, 44, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 44, 68, 68, 44, 44, 42
	                         DB           42, 43, 44, 44, 68, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 68, 92, 92, 44, 42, 42, 43, 44, 68, 92, 42, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 43, 44, 43, 0, 0, 42, 43, 44, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42, 42, 0, 0, 0, 42, 42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 0, 0, 0
	Explosion5               DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 41
	                         DB           41, 41, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 92, 92, 92, 43, 43, 42, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 92, 92, 44, 44, 43, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0, 43, 92, 92, 44, 44, 43, 42, 41, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 41, 44, 68, 68, 44, 43, 42, 44, 92, 42, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 44, 44, 44, 43
	                         DB           42, 43, 44, 92, 92, 92, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 44, 43, 43, 43, 43, 43, 41, 43, 44, 44, 92, 68, 42, 0
	                         DB           42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 42, 43, 44, 42, 43, 43, 43, 42, 43, 44, 43, 44, 43, 42, 43, 44, 92, 43, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 42, 42, 42, 43, 44, 43, 42, 41, 42, 41, 42, 43, 43, 43, 42, 43, 44, 44, 68, 92, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 43, 43
	                         DB           43, 43, 42, 42, 43, 41, 42, 41, 42, 41, 43, 43, 43, 41, 43, 44, 44, 44, 44, 92, 42, 0, 0, 0, 0, 0, 41, 42, 42, 43, 44, 44, 44, 44, 43, 43, 43, 42, 41, 43
	                         DB           43, 43, 42, 43, 43, 42, 43, 44, 44, 44, 44, 44, 41, 0, 0, 0, 0, 0, 0, 42, 43, 92, 92, 92, 68, 44, 43, 41, 42, 41, 43, 44, 44, 43, 43, 41, 42, 41, 43, 43
	                         DB           43, 43, 42, 44, 42, 0, 0, 0, 0, 0, 0, 0, 43, 92, 68, 68, 44, 44, 43, 42, 43, 43, 44, 44, 44, 44, 43, 43, 42, 41, 42, 41, 42, 41, 42, 41, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 42, 43, 44, 44, 44, 43, 42, 41, 43, 43, 44, 92, 92, 44, 43, 43, 41, 42, 43, 44, 68, 43, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 43, 43
	                         DB           43, 43, 41, 41, 43, 43, 44, 92, 92, 44, 44, 43, 43, 41, 43, 44, 68, 92, 92, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 43, 43, 43, 43, 42, 42, 43, 43, 44, 44
	                         DB           44, 44, 43, 44, 43, 42, 43, 44, 44, 68, 68, 92, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 41, 41, 43, 43, 44, 44, 44, 44, 43, 43, 42, 41, 43, 43
	                         DB           44, 44, 44, 68, 42, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 41, 43, 42, 41, 42, 43, 43, 43, 42, 41, 43, 41, 42, 43, 43, 44, 44, 44, 44, 42, 41, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 43, 44, 44, 43, 43, 43, 41, 43, 43, 41, 43, 42, 43, 42, 41, 43, 43, 43, 43, 44, 42, 41, 0, 0, 0, 0, 0, 0, 0, 41, 42, 43
	                         DB           44, 44, 44, 43, 43, 42, 41, 42, 43, 43, 43, 43, 43, 43, 42, 41, 41, 42, 43, 43, 42, 0, 0, 0, 0, 0, 0, 0, 0, 41, 42, 44, 68, 68, 44, 43, 43, 43, 42, 43
	                         DB           43, 44, 44, 44, 43, 41, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 42, 44, 68, 68, 44, 44, 44, 43, 41, 42, 43, 44, 44, 44, 44, 43, 41, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 43, 68, 92, 92, 44, 44, 43, 42, 41, 43, 44, 44, 44, 68, 68, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 42, 42, 43, 44, 44, 44, 43, 41, 42, 43, 44, 44, 44, 68, 68, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 42, 42, 43, 43, 42, 0, 0, 42, 43, 44, 68, 92, 68, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 42, 42, 0, 0, 0
	                         DB           0, 42, 43, 44, 44, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 41, 42, 42, 42, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Explosion6               DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 41
	                         DB           41, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 67, 67, 67, 42, 42, 41, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 67, 67, 43, 43, 42, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 67, 67, 43, 43, 42, 41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 43, 67, 67, 43, 42, 41, 43, 67, 43, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 43, 43, 43, 42
	                         DB           41, 42, 43, 67, 67, 67, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 41, 42, 42, 42, 42, 41, 42, 43, 43, 67, 67, 42, 0
	                         DB           41, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 41, 42, 67, 41, 41, 41, 41, 42, 42, 43, 42, 43, 42, 41, 42, 43, 67, 42, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 41, 41, 41, 42, 43, 42, 0, 0, 41, 42, 42, 42, 42, 42, 41, 42, 43, 43, 67, 67, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 42, 42
	                         DB           42, 42, 41, 41, 41, 0, 41, 41, 41, 41, 42, 42, 42, 41, 42, 43, 43, 43, 43, 67, 41, 0, 0, 0, 0, 0, 41, 41, 41, 42, 43, 43, 43, 43, 42, 42, 41, 41, 42, 42
	                         DB           42, 42, 41, 41, 41, 41, 42, 43, 43, 43, 43, 43, 41, 0, 0, 0, 0, 0, 0, 41, 42, 67, 67, 67, 67, 43, 42, 41, 41, 42, 43, 43, 43, 42, 42, 41, 0, 41, 42, 42
	                         DB           42, 42, 41, 43, 41, 0, 0, 0, 0, 0, 0, 0, 42, 67, 67, 67, 43, 43, 42, 41, 42, 42, 43, 43, 43, 43, 42, 42, 41, 0, 41, 41, 41, 41, 41, 41, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 41, 43, 43, 43, 43, 42, 41, 0, 42, 42, 43, 67, 67, 43, 42, 42, 41, 41, 42, 43, 67, 42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 42, 42
	                         DB           42, 42, 41, 0, 41, 42, 43, 67, 67, 43, 43, 42, 42, 41, 42, 43, 67, 67, 67, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 42, 42, 42, 42, 41, 0, 41, 42, 43, 43
	                         DB           43, 43, 42, 43, 42, 41, 42, 43, 43, 67, 67, 67, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 41, 41, 42, 43, 43, 43, 43, 42, 42, 41, 41, 42, 42
	                         DB           43, 43, 43, 67, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 42, 41, 41, 41, 42, 42, 42, 41, 41, 42, 41, 41, 42, 42, 43, 43, 43, 43, 41, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 42, 43, 43, 42, 42, 42, 41, 42, 42, 41, 42, 41, 42, 41, 41, 42, 42, 42, 42, 43, 41, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 42
	                         DB           43, 43, 43, 42, 42, 41, 41, 41, 42, 42, 42, 42, 42, 42, 41, 41, 41, 41, 42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 43, 67, 67, 43, 42, 42, 42, 41, 42
	                         DB           42, 43, 43, 43, 42, 41, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 43, 67, 67, 43, 43, 43, 42, 41, 41, 42, 43, 43, 43, 43, 42, 41, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 42, 67, 67, 67, 43, 43, 42, 41, 41, 42, 43, 43, 43, 67, 67, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 41, 41, 42, 43, 43, 43, 42, 41, 41, 42, 43, 43, 43, 67, 67, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 41, 41, 42, 42, 41, 0, 0, 41, 42, 43, 67, 67, 67, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 41, 41, 41, 0, 0, 0
	                         DB           0, 41, 42, 43, 43, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 41, 41, 41, 41, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Explosion7               DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21
	                         DB           161, 161, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 161, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 21, 21, 0, 0, 0, 21, 21, 21
	                         DB           21, 21, 21, 0, 0, 0, 0, 0, 0, 21, 161, 0, 0, 0, 0, 0, 0, 0, 161, 21, 0, 0, 0, 27, 21, 21, 0, 0, 21, 24, 89, 89, 89, 24, 24, 21, 0, 0, 0, 0
	                         DB           27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 161, 161, 21, 0, 0, 27, 27, 0, 0, 0, 21, 24, 89, 89, 65, 65, 24, 21, 0, 0, 0, 0, 27, 0, 0, 0, 21, 21, 0, 0
	                         DB           0, 0, 21, 21, 21, 0, 0, 0, 27, 0, 0, 0, 21, 24, 89, 89, 65, 65, 24, 21, 21, 0, 0, 0, 27, 0, 0, 0, 21, 161, 161, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           27, 0, 0, 21, 65, 89, 89, 65, 24, 21, 65, 89, 65, 65, 21, 0, 0, 0, 0, 0, 0, 21, 21, 0, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 21, 21, 65, 65, 65, 24
	                         DB           21, 65, 65, 89, 89, 89, 24, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 0, 27, 27, 0, 0, 0, 21, 65, 21, 24, 24, 24, 24, 21, 65, 65, 65, 89, 89, 24, 21
	                         DB           21, 21, 0, 0, 0, 27, 0, 0, 0, 0, 0, 0, 0, 27, 0, 21, 21, 21, 24, 89, 21, 21, 21, 21, 24, 24, 24, 65, 65, 24, 21, 24, 65, 89, 24, 0, 27, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 21, 21, 21, 24, 65, 24, 21, 0, 21, 24, 24, 24, 24, 24, 21, 24, 65, 65, 89, 89, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 24, 24
	                         DB           24, 24, 21, 21, 21, 0, 21, 21, 21, 21, 21, 21, 24, 21, 24, 65, 65, 65, 65, 89, 21, 0, 0, 0, 0, 0, 21, 21, 21, 24, 65, 65, 65, 65, 24, 24, 21, 21, 24, 24
	                         DB           24, 24, 21, 21, 21, 21, 24, 24, 24, 24, 65, 65, 21, 0, 0, 0, 0, 0, 0, 21, 24, 89, 89, 89, 89, 65, 24, 21, 21, 24, 65, 65, 65, 24, 24, 21, 0, 21, 21, 21
	                         DB           24, 24, 21, 65, 21, 0, 27, 0, 0, 27, 27, 0, 24, 89, 89, 89, 65, 65, 24, 21, 24, 24, 65, 65, 65, 65, 24, 24, 21, 0, 21, 21, 21, 21, 21, 21, 0, 0, 27, 0
	                         DB           0, 27, 0, 0, 21, 65, 65, 65, 65, 24, 21, 21, 24, 24, 65, 89, 89, 65, 24, 24, 21, 21, 24, 65, 89, 24, 24, 0, 0, 0, 0, 0, 0, 0, 27, 27, 0, 21, 24, 24
	                         DB           24, 24, 21, 0, 21, 24, 65, 89, 89, 65, 65, 24, 24, 21, 24, 65, 89, 89, 89, 21, 0, 0, 0, 0, 0, 0, 27, 0, 0, 21, 24, 24, 24, 21, 21, 0, 21, 24, 65, 65
	                         DB           65, 65, 24, 65, 24, 21, 24, 65, 65, 89, 89, 89, 21, 0, 0, 0, 0, 0, 27, 0, 27, 0, 21, 21, 21, 21, 21, 21, 21, 24, 65, 65, 65, 65, 24, 24, 21, 21, 24, 24
	                         DB           21, 21, 65, 89, 21, 0, 27, 0, 0, 0, 27, 27, 27, 0, 0, 21, 21, 21, 24, 21, 21, 21, 24, 24, 24, 21, 21, 24, 21, 21, 24, 24, 65, 65, 65, 65, 21, 0, 27, 27
	                         DB           0, 0, 0, 27, 0, 0, 21, 21, 24, 65, 65, 24, 21, 21, 21, 24, 24, 21, 24, 21, 21, 21, 21, 24, 24, 24, 24, 65, 21, 0, 0, 27, 0, 0, 0, 27, 0, 21, 21, 24
	                         DB           65, 65, 65, 24, 21, 21, 21, 21, 24, 24, 24, 24, 24, 24, 21, 21, 21, 21, 24, 24, 0, 0, 0, 27, 0, 0, 27, 27, 0, 21, 21, 65, 89, 89, 65, 24, 24, 24, 21, 24
	                         DB           24, 65, 65, 65, 24, 21, 0, 0, 0, 0, 21, 21, 0, 0, 0, 0, 0, 0, 27, 0, 0, 21, 21, 65, 89, 89, 65, 65, 65, 24, 21, 21, 24, 65, 65, 65, 65, 24, 21, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 27, 0, 21, 24, 89, 89, 89, 65, 65, 24, 21, 21, 24, 65, 65, 65, 89, 89, 21, 0, 0, 0, 0, 27, 0, 0, 0, 0
	                         DB           0, 0, 0, 27, 0, 0, 0, 21, 21, 24, 65, 65, 65, 24, 21, 21, 24, 65, 65, 65, 89, 89, 21, 0, 0, 0, 0, 0, 27, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 27
	                         DB           0, 21, 21, 24, 24, 21, 0, 0, 21, 24, 65, 89, 89, 89, 21, 0, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 27, 27, 0, 21, 21, 21, 21, 0, 0, 0
	                         DB           0, 21, 24, 65, 65, 24, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 27, 27, 27, 0, 0, 0, 27, 21, 0, 0, 27, 0, 0, 21, 21, 21, 21, 21, 0, 0
	                         DB           0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 27, 27, 0, 0, 27, 27, 0, 0, 0, 21, 0, 0, 0, 0, 27, 0, 0, 27, 27, 0, 0, 0, 0
	                         DB           0, 0, 27, 0, 0, 0, 0, 27, 0, 27, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0
	Explosion8               DB           0, 0, 0, 0, 0, 0, 0, 21, 21, 161, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 161, 0, 0, 0, 0, 0, 0, 0, 0, 161, 161, 0, 0, 0, 0, 21
	                         DB           21, 161, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 161, 161, 21, 0, 0, 0, 27, 21, 21, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 0, 161, 161, 0, 0, 21, 21, 21, 0, 0, 0, 27, 27, 0, 0, 0, 0, 21, 21, 21, 0, 0, 0, 0, 0, 0, 27, 0
	                         DB           0, 0, 0, 0, 0, 21, 161, 161, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 24, 24, 24, 21, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 21
	                         DB           0, 0, 27, 27, 0, 0, 0, 0, 27, 0, 0, 0, 24, 24, 21, 24, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 27, 27, 0, 0, 0
	                         DB           0, 0, 0, 0, 21, 24, 24, 24, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 21, 0, 0, 21, 21, 21
	                         DB           0, 0, 21, 21, 21, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 21, 24, 0, 0, 0, 0, 0, 21, 24, 24, 24, 21, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 24, 21, 0, 0, 0, 0, 21, 24, 24, 21, 21, 0, 0, 21, 21, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 24, 24, 0, 0, 0, 0, 0, 24, 24, 21, 0, 0, 0, 21, 21, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 21, 21, 0, 0, 0, 0, 0, 21, 21, 0, 0, 24, 21, 24, 21, 21, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 21, 21, 21, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 21, 24, 24, 24, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 24, 24, 0, 0, 0, 0, 0, 21, 21, 21, 21, 0, 0, 0, 0, 0, 0
	                         DB           21, 21, 21, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 21, 24, 21, 0, 0, 0, 21, 21, 21, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 0, 0, 0, 0, 0, 24, 24, 21, 0, 0, 0, 21, 24, 24, 21, 21, 0, 0, 0, 21, 24, 24, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24
	                         DB           24, 21, 0, 0, 0, 21, 24, 24, 24, 24, 21, 0, 0, 24, 24, 21, 24, 21, 0, 0, 27, 0, 0, 0, 0, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           21, 21, 0, 0, 21, 24, 24, 21, 21, 24, 21, 0, 27, 27, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 21, 24, 21
	                         DB           21, 24, 0, 0, 0, 0, 27, 0, 0, 0, 27, 27, 27, 0, 0, 0, 0, 24, 21, 21, 24, 0, 0, 0, 0, 0, 0, 0, 0, 21, 21, 24, 21, 21, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 27, 27, 27, 0, 0, 0, 24, 21, 21, 21, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 27, 27, 0, 0, 0, 0
	                         DB           21, 24, 21, 24, 21, 0, 0, 0, 0, 24, 24, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 27, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 24, 24, 21, 21, 0, 0, 0
	                         DB           21, 24, 21, 21, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 24, 21, 21, 24, 24, 21, 0
	                         DB           0, 0, 0, 27, 0, 0, 27, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 24, 24, 24, 24, 21, 0, 0, 0, 0, 0, 27, 0, 0, 27, 0
	                         DB           0, 27, 27, 0, 0, 0, 27, 0, 0, 27, 27, 0, 0, 0, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 0, 0, 27, 0
	                         DB           0, 27, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 27, 27, 27, 0, 0, 27, 0, 0, 0, 27, 0, 0
	                         DB           0, 0, 0, 0, 27, 0, 0, 0, 27, 27, 0, 0, 0, 27, 0, 27, 0, 0, 0, 27, 27, 27, 0, 0, 0, 27, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 27, 27, 0, 0
	                         DB           0, 27, 27, 0, 0, 27, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 27, 27, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 27, 27, 0, 0, 0, 0
	                         DB           0, 0, 27, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                         DB           0, 0, 27, 0, 0, 0, 27, 27, 0, 0, 0, 0, 0, 0, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0

	;///////////////////////////////Data segment////////////////////////////////////
	;/////////////////////////////////////////////////////////////////////////
;///////////////////////////////Code segment////////////////////////////////////
.code
MAIN PROC FAR
	;///////////////////////////////Initializations////////////////////////////////////
	                              mov                  AX,@data                                                                             	;initializing the data segemnt
	                              mov                  DS,AX
	                              ASSUME               ES:extra
	                              mov                  ax, extra
	                              mov                  es, ax
	                              enterGraphicsMode
	;///////////////////////////////First Screen////////////////////////////////////
	                              showScreen           firstScreen
	                              waitForInput                                                                                              	; wait for any character to procced
	;///////////////////////////////Name & character Screen////////////////////////
	                              getPlayersName_ID
	;///////////////////////////////Main Menu////////////////////////////////////
	mainMenuLoop:                 
	                              clearWholeScreen
	                              displayMainMenu
	                              checkMainMenuOptions gameLoop, exitProg, chatLoop
	;///////////////////////////////Chat Loop////////////////////////////////////
	chatLoop:                     
	                              call                 CHAT
	; if the user left the chat procedure then, he has send esc --> return to the mainMenuLoop 
								  jmp mainMenuLoop
	;///////////////////////////////Game Loop////////////////////////////////////
	gameLoop:                                                                                                                               	;NOTE:since we are using words, we will use the value '2' to traverse pixels
	;//////////////////////////////initializations////////////////////////////////////
	                              call                 initializeGameLoop
	;////////////////////////////Interacting with the user////////////////////////////
	gameLoopRoutine:              
	                              mov                  dl, 0
	                              mov                  ISNEWGAME, dl
	                              CALL                 checkForWinner

	                              CMP                  ISNEWGAME, 1
	                              JE                   gameLoop

	                              call                 BulletChecker
	                              call                 updateBullets
	;////////////////////////////////////check for user input///////////////////////////
	                              checkIfInput gameLoopRoutine
	                              jz                   gameLoopRoutine                                                                      	; check if there is any input

	                              inputToMoveShip      key_w, key_s, key_a, key_d, key_f, moveShip1_label
	                              inputToMoveShip      key_upArrow, key_downArrow, key_leftArrow, key_rightArrow, key_enter, moveShip2_label
	                             
	moveShip1_label:              
	                              call                 movShip1
	                              jmp                  gameLoopRoutine
	moveShip2_label:              
	                              CALL                 movShip2                                                                             	; TO GENERATE THE new OFFSET OF THE ship
	                              jmp                  gameLoopRoutine
	;/////////////////////////////////////////////////////////////////////////////////
	;///////////////////////////////Exit Program/////////////////////////////////////
	exitProg:                     
	                              clearWholeScreen
	                              showScreen           byebye
	                              returnTODos
MAIN ENDP
	;/////////////////////////////////////////////////////////////////////////
	;//////////////////////////////Procedures//////////////////////////////////////////////
	;/////////////////////////////// initialize the game
initializeGameLoop PROC near                                                                                                            		; draws the layout and the ships                                                                                           		; draws the game layout, ships, msgBoxes and health bars
	                              enterGraphicsMode
	                              call                 DrawLayout
	                              call                 DrawHealthbar
	                              call                 DrawHealthbar2
	                              call                 drawShip1
	                              call                 drawShip2
	                              mov                  bx, 0
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                              call                 DrawMsgWithBox
	                              mov                  bx, 3
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                              call                 DrawMsgWithBox
	;this subroutine is responsible for drawing the ship using its cooardinates
	                              ret
	                              ENDP
NewGameInitializer PROC near                                                                                                            		; initializes bullets, healthe and ship offsets
	                              call                 InitalizeBullets
	                              mov                  dl, 1
	                              mov                  ISNEWGAME, dl
	                              mov                  dl, 200
	                              mov                  HEALTH1, dl
	                              mov                  HEALTH2, dl
	                              mov                  dx, 30
	                              mov                  shipOffsetX1, dx
	                              mov                  dx, 219
	                              mov                  shipOffsetY1, dx
	                              mov                  shipOffsetY2, dx
	                              mov                  dx, 578
	                              mov                  shipOffsetX2, dx
	                              ret

NewGameInitializer ENDP
InitalizeBullets PROC NEAR                                                                                                              		; initializes the bullets

	                              mov                  bx, offset BulletDirection
	                              mov                  SI, 100
	InitializeBullet:             
	                              mov                  dx, 0
	                              mov                  bx[SI], dx
	                              dec                  SI
	                              JNZ                  InitializeBullet
	                              ret
InitalizeBullets ENDP
	;/////////////////////////////// moving ships
movShip1 PROC near                                                                                                                      		; responsible for moving ship 1

	                              cmp                  al,key_esc                                                                           	; ESC
	                              jz                   exitProg
	                              cmp                  ah, 21H
	                              jz                   movShip1_donotErase
	                              call                 eraseShip1                                                                           	; get the pressed key from the user

	movShip1_donotErase:          cmp                  ah,key_w
	                              jz                   movShip1_moveUp

	                              cmp                  ah,key_s
	                              jz                   movShip1_moveDown

	                              cmp                  ah,key_a
	                              jz                   movShip1_moveLeft

	                              cmp                  ah,key_d
	                              jz                   movShip1_moveRight

	                              cmp                  ah, key_f
	                              jz                   movShip1_fire


	movShip1_readKey:             
	                              call                 drawShip1

	                              waitForInput

	                              mov                  cx, 0                                                                                	; initialize cx to use it to iterate over the shipSize
	                              jmp                  gameLoopRoutine


	movShip1_readFire:            

	                              waitForInput

	                              mov                  cx, 0                                                                                	; initialize cx to use it to iterate over the Bullet Size
	                              jmp                  gameLoopRoutine
	;///////////////////////////////////////////////////////////////////////////////////////
	movShip1_moveUp:              
	;checking for boundaries
	                              mov                  bx, shipOffsetY1
	                              cmp                  bx, screenMinY1
	                              jna                  movShip1_readKey
	                              sub                  bx, shipSpeed1
	                              mov                  DI, offset shipOffsetY1
	                              mov                  [DI], bx

	                              jmp                  movShip1_readKey

	movShip1_moveDown:            
	;checking for boundaries
	                              mov                  bx, shipOffsetY1
	                              mov                  cx, bx
	                              add                  cx, shipSizeY
	                              cmp                  cx, screenMaxY1
	                              jnb                  movShip1_readKey
	                              add                  bx,shipSpeed1
	                              mov                  DI, offset shipOffsetY1
	                              mov                  [DI], bx

	                              jmp                  movShip1_readKey

	movShip1_moveLeft:            
	;checking for boundaries
	                              mov                  bx, shipOffsetX1
	                              cmp                  bx, screenMinX1
	                              jna                  movShip1_readKey
	                              sub                  bx, shipSpeed1
	                              mov                  DI, offset shipOffsetX1
	                              mov                  [DI], bx
	          
	                              jmp                  movShip1_readKey

	movShip1_moveRight:           
	;checking for boundaries
	                              mov                  bx, shipOffsetX1
	                              mov                  cx, bx
	                              add                  cx, shipSizeX
	                              cmp                  cx, screenMaxX1
	                              jnb                  movShip1_readKey
	                              add                  bx, shipSpeed1
	                              mov                  DI, offset shipOffsetX1
	                              mov                  [DI], bx

	                              jmp                  movShip1_readKey


	movShip1_fire:                
	                              mov                  bx, 0
	                              LEA                  SI, BulletDirection
	movShip1_findEmptyBullet:     MOV                  DL, 0
	                              CMP                  [SI], DL
	                              JE                   movShip1_found
	                              CMP                  BX, MAXBULLET
	                              JE                   movShip1_notFound
	                              INC                  BX
	                              INC                  SI
	                              JMP                  movShip1_findEmptyBullet
    
	movShip1_notFound:            ret

	movShip1_found:               mov                  dl, 1
	                              mov                  [SI], dl                                                                             	; For Right Direction
	                              LEA                  DI, BulletOffset
	                              ADD                  DI, BX
	                              ADD                  DI, BX
	                              ADD                  DI, BX
	                              ADD                  DI, BX

	; For x
                    
	                              mov                  dX, shipOffsetX1
	                              add                  DX, shipSizeX
	                              INC                  DX
	                              MOV                  [DI], DX
                
	; For y

	                              mov                  dx, shipSizeY
	                              sub                  dx, BulletYSize

	; These steps for division
	; First push ax to stack as we need it after that
	                              push                 ax

	; Divsion Process
	                              mov                  ax, dx
	                              mov                  cl, 2
	                              div                  cl
	                              mov                  dx, ax

	; retrive the value of reg ax
	                              pop                  ax
	                              add                  dx, shipOffsetY1

	                              mov                  [DI] + 2, dx
	                              jmp                  movShip1_readFire

	                      
	                              ret

movShip1 ENDP
movShip2 PROC near                                                                                                                      		; responsible for moving ship 2
	                              mov                  cx, 0
	                              cmp                  ah, key_enter
	                              jz                   movShip2_donotErase
	                              call                 eraseShip2                                                                           	; get the pressed key from the user
	movShip2_donotErase:          

	                              cmp                  ah,key_upArrow
	                              jz                   movShip2_moveUp

	                              cmp                  ah,50H
	                              jz                   movShip2_moveDown

	                              cmp                  ah,key_leftArrow
	                              jz                   movShip2_moveLeft

	                              cmp                  ah,key_rightArrow
	                              jz                   movShip2_moveRight
	                              cmp                  ah,key_enter
	                              jz                   movShip2_fire



	movShip2_readKey:             
	                              call                 drawShip2

	                              waitForInput

	                              mov                  cx, 0                                                                                	; initialize cx to use it to iterate over the shipSize
	                              jmp                  gameLoopRoutine
	;///////////////////////////////////////////////////////////////////////////////////////
	movShip2_moveUp:              
	;checking for boundaries
	                              mov                  bx, shipOffsetY2
	                              cmp                  bx, screenMinY2
	                              jna                  movShip2_readKey
	                              sub                  bx, shipSpeed2
	                              mov                  DI, offset shipOffsetY2
	                              mov                  [DI], bx

	                              jmp                  movShip2_readKey

	movShip2_moveDown:            
	;checking for boundaries
	                              mov                  bx, shipOffsetY2
	                              mov                  cx, bx
	                              add                  cx, shipSizeY2
	                              cmp                  cx, screenMaxY2
	                              jnb                  movShip2_readKey
	                              add                  bx,shipSpeed2
	                              mov                  DI, offset shipOffsetY2
	                              mov                  [DI], bx

	                              jmp                  movShip2_readKey

	movShip2_moveLeft:            
	;checking for boundaries
	                              mov                  bx, shipOffsetX2
	                              cmp                  bx, screenMinX2
	                              jna                  movShip2_readKey
	                              sub                  bx, shipSpeed2
	                              mov                  DI, offset shipOffsetX2
	                              mov                  [DI], bx
	          
	                              jmp                  movShip2_readKey

	movShip2_moveRight:           
	;checking for boundaries
	                              mov                  bx, shipOffsetX2
	                              mov                  cx, bx
	                              add                  cx, shipSizeX2
	                              cmp                  cx, screenMaxX2
	                              jnb                  movShip2_readKey
	                              add                  bx, shipSpeed2
	                              mov                  DI, offset shipOffsetX2
	                              mov                  [DI], bx

	                              jmp                  movShip2_readKey
	                              ret
	movShip2_fire:                
	                              mov                  bx, 0
	                              LEA                  SI, BulletDirection
	movShip2_findEmptyBullet:     MOV                  DL, 0
	                              CMP                  [SI], DL
	                              JE                   movShip2_found
	                              CMP                  BX, MAXBULLET
	                              JE                   movShip2_notFound
	                              INC                  BX
	                              INC                  SI
	                              JMP                  movShip2_findEmptyBullet
    
	movShip2_notFound:            ret

	movShip2_found:               mov                  dl, 2
	                              mov                  [SI], dl                                                                             	; For Right Direction
	                              LEA                  DI, BulletOffset
	                              ADD                  DI, BX
	                              ADD                  DI, BX
	                              ADD                  DI, BX
	                              ADD                  DI, BX

	; For x
                    
	                              mov                  dX, shipOffsetX2
	                              sub                  dx, BulletXSize
	                              INC                  DX
	                              MOV                  [DI], DX
                
	; For y

	                              mov                  dx, shipSizeY2
	                              sub                  dx, BulletYSize

	; These steps for division
	; First push ax to stack as we need it after that
	                              push                 ax

	; Divsion Process
	                              mov                  ax, dx
	                              mov                  cl, 2
	                              div                  cl
	                              mov                  dx, ax

	; retrive the value of reg ax
	                              pop                  ax
	                              add                  dx, shipOffsetY2

	                              mov                  [DI] + 2, dx
	                              jmp                  movShip1_readFire

	                              ret
movShip2 ENDP
	;
drawShip1 PROC	near                                                                                                                     		; drawing ship1
	; initialize containers
	                              mov                  Ers, 0
	                              mov                  REV, 0
	                              editDrawPrams        ship1, shipSizeX, shipSizeX, shipOffsetX1, shipOffsetY1                              	; ship1 will be overwritten in the next line
	                              setCurrentChar       playerID1                                                                            	; add the offest of the plane in SI to be drawn
	                              call                 drawShape
	                              ret
drawShip1 ENDP
eraseShip1 PROC near                                                                                                                    		; eraing ship 1
	; initialize containers
	                              push                 ax
	                              mov                  ah, playerID1

	                              cmp                  ah, 0
	                              JNE                  eraseShip1_secondChar
	                              mov                  SI, offset Fenn_Plane
	                              jmp                  eraseShip1_start

	eraseShip1_secondChar:        cmp                  ah, 1
	                              jne                  eraseShip1_thirdChar
	                              mov                  SI, offset Mikasa_Plane
	                              jmp                  eraseShip1_start

	eraseShip1_thirdChar:         cmp                  ah, 2
	                              jne                  eraseShip1_fourthChar
	                              mov                  SI, offset Hisoka_Plane
	                              jmp                  eraseShip1_start

	eraseShip1_fourthChar:        cmp                  ah, 3
	                              jne                  eraseShip1_fifthChar
	                              mov                  SI, offset Asta_Plane
	                              jmp                  eraseShip1_start

	eraseShip1_fifthChar:         
	                              mov                  SI, offset Meruem_Plane

	                                                                            
	eraseShip1_start:             mov                  cx, shipSizeX                                                                        	;Column X
	                              mov                  dx, shipSizeX                                                                        	;Row Y
	                              
	                              mov                  ah, 0ch
	                              cmp                  al, SHIP_DAMAGE_COLOR
	                              jz                   eraseShip1_drawIt                                                                    	;Draw Pixel Command
	                              mov                  al, background_Game_Color                                                            	;to be replaced with background
	
	eraseShip1_drawIt:            
	                              mov                  bl, [SI]                                                                             	;  use color from array color for testing
	                              and                  bl, bl
	                              JZ                   eraseShip1_back
	                              add                  cx, shipOffsetX1
	                              add                  dx, shipOffsetY1
	                              int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, shipOffsetX1
	                              sub                  dx, shipOffsetY1

	eraseShip1_back:              
	                              inc                  SI
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              JNZ                  eraseShip1_drawIt                                                                    	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, shipSizeX                                                                        	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   eraseShip1_allDrawn                                                                  	;  both x and y reached 00 so finish drawing
	                              jmp                  eraseShip1_drawIt
	eraseShip1_allDrawn:          pop                  ax
	                              ret
eraseShip1 ENDP
	;
drawShip2 PROC	near                                                                                                                     		; drawing ship1
	; initialize containers
	                              mov                  Ers, 0
	                              mov                  REV, 1
	                              editDrawPrams        ship1, shipSizeX, shipSizeX, shipOffsetX2, shipOffsetY2                              	; ship1 will be overwritten in the next line
	                              setCurrentChar       playerID2                                                                            	; add the offest of the plane in SI to be drawn
	                              call                 drawShape
	                              ret
drawShip2 ENDP
eraseShip2 PROC near                                                                                                                    		; eraing ship 1
	; initialize containers
	                              push                 ax
	                              mov                  ah, playerID2

	                              cmp                  ah, 0
	                              JNE                  eraseShip2_secondChar
	                              mov                  SI, offset Fenn_Plane
	                              jmp                  eraseShip2_start

	eraseShip2_secondChar:        cmp                  ah, 1
	                              jne                  eraseShip2_thirdChar
	                              mov                  SI, offset Mikasa_Plane
	                              jmp                  eraseShip2_start

	eraseShip2_thirdChar:         cmp                  ah, 2
	                              jne                  eraseShip2_fourthChar
	                              mov                  SI, offset Hisoka_Plane
	                              jmp                  eraseShip2_start

	eraseShip2_fourthChar:        cmp                  ah, 3
	                              jne                  eraseShip2_fifthChar
	                              mov                  SI, offset Asta_Plane
	                              jmp                  eraseShip2_start

	eraseShip2_fifthChar:         
	                              mov                  SI, offset Meruem_Plane
								                                                                   	
	eraseShip2_start:             mov                  cx, 0                                                                                	;Column X
	                              mov                  dx, shipSizeX                                                                        	;Row Y
	                              mov                  ah, 0ch
	                              cmp                  al, SHIP_DAMAGE_COLOR
	                              jz                   eraseShip2_drawIt                                                                    	;Draw Pixel Command
	                              mov                  al, background_Game_Color                                                            	;to be replaced with background
	
	eraseShip2_drawIt:            
	                              mov                  bl, [SI]                                                                             	;  use color from array color for testing
	                              and                  bl, bl
	                              JZ                   eraseShip2_back
	                              add                  cx, shipOffsetX2
	                              add                  dx, shipOffsetY2
	                              int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, shipOffsetX2
	                              sub                  dx, shipOffsetY2

	eraseShip2_back:              
	                              inc                  SI
	                              INC                  Cx                                                                                   	;  loop iteration in x direction
	                              CMP                  CX, shipSizeX
	                              JNZ                  eraseShip2_drawIt                                                                    	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, 0                                                                                	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   eraseShip2_allDrawn                                                                  	;  both x and y reached 00 so finish drawing
	                              jmp                  eraseShip2_drawIt
	eraseShip2_allDrawn:          pop                  ax
	                              ret
eraseShip2 ENDP
	;/////////////////////////////// related to the bullets
updateBullets proc NEAR                                                                                                                 		; updateBullets status every frame
	                              mov                  BX, 0
	                              LEA                  SI, BulletDirection
	                              LEA                  DI, BulletOffset

	updateBullets_CHECKBULLETS:   mov                  ah,0
	                              mov                  Al, [SI]
	                              CMP                  Al, 0
	                              JE                   updateBullets_ContinueBullet
	                              CALL                 EraseBullet
	                              MOV                  dx, MAXBULLETRIGHT
	                              CMP                  [DI], dx
	                              JLE                  updateBullets_StopBullet
	                              CMP                  [DI], MAXBULLETLEFT

	                              JGE                  updateBullets_StopBullet
	                              CALL                 Bullet_Offset
	                              CALL                 DrawBullet
	                              jmp                  updateBullets_ContinueBullet

	updateBullets_StopBullet:     mov                  dl, 0
	                              mov                  [SI], dl
	updateBullets_ContinueBullet: INC                  BX
	                              ADD                  SI, 1
	                              ADD                  DI, 4
	                              CMP                  BX, MAXBULLET
	                              JE                   updateBullets_ContinueBullets
	                              JMP                  updateBullets_CHECKBULLETS

	updateBullets_ContinueBullets:
	                              delay                delayDuration
	                              ret

updateBullets endp
BulletChecker PROC NEAR                                                                                                                 		; check for collisions

	                              mov                  BX, 0
	                              LEA                  SI, BulletDirection
	                              LEA                  DI, BulletOffset
	CHECKBULLETS:                 mov                  ah,0
	                              mov                  Al, [SI]
	                              CMP                  Al, 0
	                              JE                   ContinueBullet
	                              CALL                 EraseBullet

	                              MOV                  dx, MAXBULLETRIGHT
	                              CMP                  [DI], dx
	                              JLE                  StopBullet
	                              CMP                  [DI], MAXBULLETLEFT
	                              JGE                  StopBullet

	                              mov                  dx, shipOffsetX1
	                              add                  dx, shipSizeX
	                              CMP                  [DI], dx
	                              JLE                  CheckY1_Up

	                              mov                  dx, shipOffsetX2
	                              Sub                  dx, 6
	                              CMP                  [DI], dx
	                              JGE                  CheckY2_Up

	                              CALL                 Bullet_Offset
	                              CALL                 DrawBullet
	                              jmp                  ContinueBullet
	CheckY1_Up:                   
	                              mov                  dx, [DI] + 2
	                              mov                  cx, shipOffsetY1
	;add cx, 16
	                              CMP                  dx, Cx
	                              jge                  CheckY1_Down
	                              jmp                  ContinueBullet

	CheckY1_Down:                 
	                              mov                  dx, [DI] + 2
	                              mov                  cx, shipOffsetY1
	                              add                  cx, shipSizeX
	                              CMP                  dx, Cx
	                              jle                  BulletCollusion
	                              jmp                  ContinueBullet

	CheckY2_Up:                   
	                              mov                  dx, [DI] + 2
	                              mov                  cx, shipOffsetY2
	;add cx, 16
	                              CMP                  dx, Cx
	                              jge                  CheckY2_Down
	                              jmp                  ContinueBullet

	CheckY2_down:                 
	                              mov                  dx, [DI] + 2
	                              mov                  cx, shipOffsetY2
	                              add                  cx, shipSizeX
	                              CMP                  dx, Cx
	                              jle                  BulletCollusion2
	                              jmp                  ContinueBullet

	StopBullet:                   mov                  dl, 0
	                              mov                  [SI], dl
	                              JMP                  ContinueBullet

	ContinueBullet:               INC                  BX
	                              ADD                  SI, 1
	                              ADD                  DI, 4
	                              CMP                  BX, MAXBULLET
	                              JE                   MAKEJMPENDCHECKCLOSER
	                              JMP                  CHECKBULLETS
						
	BulletCollusion:              
	                              mov                  dl, 0
	                              mov                  [SI], dl
	                              mov                  dl, HEALTH1
	                              sub                  dl, DAMAGE
	                              mov                  HEALTH1, dl
	                              call                 DrawHealthbar
	                              mov                  al, SHIP_DAMAGE_COLOR
	                              call                 Eraseship1
	                              delay                SHIP_DAMAGE_EFFECT_DELAY
	                              cmp                  HEALTH1, HEALTH_ANGRY
	                              ja                   DontAngry1
	                              CALL                 DrawAngry1
	DontAngry1:                   call                 Drawship1
	                              jmp                  ContinueBullet
	;INT 21h
	MAKEJMPENDCHECKCLOSER:        JMP                  ENDCHECKBULLET

	BulletCollusion2:             
	                              mov                  dl, 0
	                              mov                  [SI], dl
	                              mov                  dl, HEALTH2
	                              sub                  dl, DAMAGE
	                              mov                  HEALTH2, dl
	                              call                 DrawHealthbar2
	                              mov                  al, SHIP_DAMAGE_COLOR
	                              call                 Eraseship2
	                              delay                SHIP_DAMAGE_EFFECT_DELAY
	                              cmp                  HEALTH2, HEALTH_ANGRY
	                              ja                   DontAngry2
	                              CALL                 DrawAngry2
	DontAngry2:                   call                 drawShip2
	                              jmp                  ContinueBullet


	ENDCHECKBULLET:               ret
BulletChecker ENDP
	;
DrawBullet PROC near                                                                                                                    		; drawing bullets
	; initialize containers
	                              push                 SI
	                              push                 BX
	                              push                 AX
	                              mov                  AL, 2
	                              CMP                  [SI], AL
	                              JZ                   REVERSE
	                              mov                  SI, offset Bullet
	                              mov                  cx, BulletXSize                                                                      	;Column X
                        
	                              mov                  dx, BulletYSize                                                                      	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	BulletDrawit:                 
	                              mov                  bl, [SI]                                                                             	;use color from array color for testing
	                              and                  bl, bl
	                              JZ                   Bulletback
	                              add                  cx, [DI]
	                              add                  dx, [DI] + 2
	                              mov                  al, [SI]                                                                             	;  use color from array color for testing
	                              int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, [DI]
	                              sub                  dx, [DI] + 2

	Bulletback:                   
	                              inc                  SI
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              JNZ                  BulletDrawit                                                                         	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, BulletXSize                                                                      	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   Bulletalldrawn                                                                       	;  both x and y reached 00 so finish drawing
	                              jmp                  BulletDrawit

	REVERSE:                      
	                              mov                  SI, offset Bullet
	                              mov                  cx, 0                                                                                	;Column X
                        
	                              mov                  dx, BulletYSize                                                                      	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	BulletDrawit2:                
	                              mov                  bl, [SI]                                                                             	;use color from array color for testing
	                              and                  bl, bl
	                              JZ                   Bulletback2
	                              add                  cx, [DI]
	                              add                  dx, [DI] + 2
	                              mov                  al, [SI]                                                                             	;  use color from array color for testing
	                              int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, [DI]
	                              sub                  dx, [DI] + 2

	Bulletback2:                  
	                              inc                  SI
	                              inc                  Cx
	                              CMP                  CX, BulletXSize                                                                      	;  loop iteration in x direction
	                              JNZ                  BulletDrawit2                                                                        	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, 0                                                                                	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   Bulletalldrawn                                                                       	;  both x and y reached 00 so finish drawing
	                              jmp                  BulletDrawit2

	Bulletalldrawn:               pop                  AX
	                              POP                  BX
	                              POP                  SI
	                              ret
DrawBullet ENDP
EraseBullet PROC near                                                                                                                   		; erasing bullets
	; initialize containers
	                              PUSH                 SI
	                              PUSH                 BX
	                              push                 ax
	                              MOV                  AL, 2
	                              CMP                  [SI], AL
	                              JZ                   REVERSE2


	                              mov                  SI, offset Bullet                                                                    	;shipY is (shipX index + size * 2) so we can use Si for both
	                              mov                  Cx, BulletXSize                                                                      	;Column X
	                              mov                  dx, BulletYSize                                                                      	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	                              mov                  al, background_Game_Color                                                            	;to be replaced with background
	
	Drawit2Bullet:                
	                              mov                  bl, [SI]                                                                             	;  use color from array color for testing
	                              and                  bl, bl
	                              JZ                   back2Bullet
	                              add                  cx, [DI]
	                              add                  dx, [DI] + 2
	                              int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, [DI]
	                              sub                  dx, [DI] + 2

	back2Bullet:                  
	                              inc                  SI
	                              DEC                  cx                                                                                   	;  loop iteration in x direction
	                              JNZ                  Drawit2Bullet                                                                        	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  cx, BulletXSize                                                                      	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  dx                                                                                   	;  loop iteration in y direction
	                              JZ                   alldrawn2Bullet                                                                      	;  both x and y reached 00 so finish drawing
	                              jmp                  Drawit2Bullet


	REVERSE2:                     mov                  Cx, 0                                                                                	;Column X
	                              mov                  dx, BulletYSize                                                                      	;Row Y
	                              mov                  SI, offset Bullet                                                                    	;shipY is (shipX index + size * 2) so we can use Si for both

	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	                              mov                  al, background_Game_Color                                                            	;to be replaced with background
	
	Drawit2BulletREV:             
	                              mov                  bl, [SI]                                                                             	;  use color from array color for testing
	                              and                  bl, bl
	                              JZ                   back2BulletREV
	                              add                  cx, [DI]
	                              add                  dx, [DI] + 2
	                              int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, [DI]
	                              sub                  dx, [DI] + 2

	back2BulletREV:               
	                              inc                  SI
	                              inc                  cx                                                                                   	;  loop iteration in x direction
	                              cmp                  cx, BulletXSize
	                              JNZ                  Drawit2BulletREV                                                                     	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  cx, 0                                                                                	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  dx                                                                                   	;  loop iteration in y direction
	                              JZ                   alldrawn2Bullet                                                                      	;  both x and y reached 00 so finish drawing
	                              jmp                  Drawit2BulletREV
	alldrawn2Bullet:              
	                              pop                  ax
	                              POP                  BX
	                              POP                  SI
	                              ret
EraseBullet ENDP
Bullet_Offset PROC near                                                                                                                 		; update each single bullet offset
                       
	                              push                 ax
	                              push                 bx
	                              mov                  cl, BulletSpeed
	                              mov                  ch, 0
	                              mov                  dl, 0
	                              cmp                  [SI], dl
	                              JZ                   Bullete_Offset_ret
	                              mov                  dl, 1
	                              cmp                  [SI], dl
	                              JZ                   INCREASE_SPEED
	                              sub                  [DI], cx
	                              jmp                  Bullete_Offset_ret
	INCREASE_SPEED:               add                  [DI], cx
	Bullete_Offset_ret:           pop                  BX
	                              pop                  ax
	                              ret
Bullet_Offset ENDP
	;/////////////////////////////// game layout
DrawMsgWithBox PROC near                                                                                                                		; drawing the message box                                                                                                             		; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                              mov                  cx, bx
	                              and                  cx, 2
	                              JNZ                  DRAWMSGUP
	                              
	                              mov                  RECXEND, 532
	                              mov                  RECYEND, 85
	                              mov                  RECXSTART, 108
	                              mov                  RECYSTART, 55
	                              mov                  RECCOLOR, 12h
	                              call                 DrawRec

	                              mov                  RECXEND, 530
	                              mov                  RECYEND, 87
	                              mov                  RECXSTART, 110
	                              mov                  RECYSTART, 53
	                              call                 DrawRec

	                              mov                  RECYEND, 85
	                              mov                  RECYSTART, 55
	                              mov                  RECCOLOR, 1dh
	                              call                 DrawRec
	
	                              mov                  RECXEND, 526
	                              mov                  RECYEND, 70
	                              mov                  RECXSTART, 114
	                              mov                  RECYSTART, 59
	                              mov                  RECCOLOR, 1eh
	                              call                 DrawRec
	                              jmp                  ALL_DRAWN_MSGBox
	
	DRAWMSGUP:                    

	                              mov                  RECXEND, 532
	                              mov                  RECYEND, 45
	                              mov                  RECXSTART, 108
	                              mov                  RECYSTART, 15
	                              mov                  RECCOLOR, 12h
	                              call                 DrawRec

	                              mov                  RECXEND, 530
	                              mov                  RECYEND, 47
	                              mov                  RECXSTART, 110
	                              mov                  RECYSTART, 13
	                              call                 DrawRec

	                              mov                  RECYEND, 45
	                              mov                  RECYSTART, 15
	                              mov                  RECCOLOR, 1dh
	                              call                 DrawRec
	
	                              mov                  RECXEND, 526
	                              mov                  RECYEND, 30
	                              mov                  RECXSTART, 114
	                              mov                  RECYSTART, 19
	                              mov                  RECCOLOR, 1eh
	                              call                 DrawRec

	ALL_DRAWN_MSGBox:             

	                              test                 bx, 1
	                              jnz                  DRAWMSGTAILRIGHT

	                              mov                  REV, 0
	                              mov                  Ers, 0
	                              editDrawPrams        MSGTAIL, MSGTAILXsize, MSGTAILYsize, MSGTAILXoffset1, MSGTAILYoffset1
	                              test                 bx, 2
	                              jnz                  DRAW_MSGTAIL_L_DOWN
	                              editDrawPrams        MSGTAIL, MSGTAILXsize, MSGTAILYsize, MSGTAILXoffset1, MSGTAILYoffset2
	DRAW_MSGTAIL_L_DOWN:          call                 drawShape
	                              jmp                  MSGtAILEND
	DRAWMSGTAILRIGHT:             
	                              mov                  REV, 1
	                              mov                  Ers, 0
	                              editDrawPrams        MSGTAIL, MSGTAILXsize, MSGTAILYsize, MSGTAILXoffset2, MSGTAILYoffset1

	                              test                 bx, 2
	                              jnz                  DRAW_MSGTAIL_R_DOWN
	                              editDrawPrams        MSGTAIL, MSGTAILXsize, MSGTAILYsize, MSGTAILXoffset2, MSGTAILYoffset2
	DRAW_MSGTAIL_R_DOWN:          call                 drawShape

	MSGtAILEND:                   ret
DrawMsgWithBox endp
DrawHealthbar PROC near                                                                                                                 		; drawing the health bar of player 1
	                              push                 bx
	                              mov                  ch, 0
	                              mov                  cl, 200                                                                              	;Column X
	                              add                  cl, 40
	                              mov                  dx, screenMaxY1+20                                                                   	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	ERASE_H_Border:               
	                              mov                  al, 0b2h                                                                             	;  use color from array color for testing
	                              int                  10h                                                                                  	;  draw the pixel
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              cmp                  CX, 40
	                              JNZ                  ERASE_H_Border                                                                       	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cl, 200                                                                              	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              add                  cl, 40
	                              DEC                  DX
	                              cmp                  dx, screenMaxY2+10                                                                   	;  loop iteration in y direction
	                              JZ                   ALL_ERASE_H_Border                                                                   	;  both x and y reached 00 so finish drawing
	                              jmp                  ERASE_H_Border
	ALL_ERASE_H_Border:           

	                              mov                  ch, 0
	                              mov                  cl, HEALTH1
	                              cmp                  cl, 200
	                              ja                   ALL_DRAWN_H_Border
	                              cmp                  cl, 0
	                              jz                   ALL_DRAWN_H_Border                                                                   	;Column X
	                              add                  cl, 40
	                              mov                  dx, screenMaxY1+20                                                                   	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	DRAW_H_Border:                
	                              mov                  al, 0h                                                                               	;  use color from array color for testing
	                              cmp                  dx, screenMaxY1+19
	                              jz                   DRAWwithblack_H_Border
	                              cmp                  dx, screenMaxY1+12
	                              jz                   DRAWwithblack_H_Border
	                              cmp                  dx, screenMaxY1+11
	                              jz                   DRAWwithblack_H_Border
	                              cmp                  dx, screenMaxY1+20
	                              jz                   DRAWwithblack_H_Border
	                              mov                  al, HEALTH1
	                              mov                  ah, 0
	                              mov                  bl, 20
	                              div                  bl
	                              add                  al, 40h
	                              cmp                  dx, screenMaxY1+15
	                              jz                   DRAWwithblack_H_Border
	                              cmp                  dx, screenMaxY1+16
	                              jz                   DRAWwithblack_H_Border
	                              mov                  al, HEALTH1
	                              mov                  ah, 0
	                              mov                  bl, 20
	                              div                  bl
	                              add                  al, 28h                                                                              	;  use color from array color for testing
	DRAWwithblack_H_Border:       mov                  ah, 0ch                                                                              	;Draw Pixel Command
	                              int                  10h                                                                                  	;  draw the pixel
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              cmp                  CX, 40
	                              JNZ                  DRAW_H_Border                                                                        	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cl, HEALTH1                                                                          	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              add                  cl, 40
	                              DEC                  DX
	                              cmp                  dx, screenMaxY2+10                                                                   	;  loop iteration in y direction
	                              JZ                   ALL_DRAWN_H_Border                                                                   	;  both x and y reached 00 so finish drawing
	                              jmp                  DRAW_H_Border
	ALL_DRAWN_H_Border:           pop                  bx
	                              ret
DrawHealthbar endp
DrawHealthbar2 PROC near                                                                                                                		; drawing the health bar of player 2
	                              push                 bx
	                              mov                  cx, 400
	                              mov                  dx, screenMaxY1+20                                                                   	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	ERASE_H_Border2:              
	                              mov                  al, 0b2h                                                                             	;  use color from array color for testing
	                              int                  10h                                                                                  	;  draw the pixel
	                              inc                  Cx                                                                                   	;  loop iteration in x direction
	                              cmp                  CX, 600
	                              JNZ                  ERASE_H_Border2                                                                      	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, 400                                                                              	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX
	                              cmp                  dx, screenMaxY2+10                                                                   	;  loop iteration in y direction
	                              JZ                   ALL_ERASE_H_Border2                                                                  	;  both x and y reached 00 so finish drawing
	                              jmp                  ERASE_H_Border2
	ALL_ERASE_H_Border2:          
	                              mov                  ch, 0
	                              mov                  cl, HEALTH2
	                              cmp                  cl, 200
	                              ja                   ALL_DRAWN_H_Border2
	                              cmp                  cl, 0
	                              jz                   ALL_DRAWN_H_Border2                                                                  	;Column X
	                              mov                  dx, screenMaxY1+20                                                                   	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	DRAW_H_Border2:               
	                              mov                  al, 0h                                                                               	;  use color from array color for testing
	                              cmp                  dx, screenMaxY1+19
	                              jz                   DRAWwithblack_H_Border2
	                              cmp                  dx, screenMaxY1+12
	                              jz                   DRAWwithblack_H_Border2
	                              cmp                  dx, screenMaxY1+11
	                              jz                   DRAWwithblack_H_Border2
	                              cmp                  dx, screenMaxY1+20
	                              jz                   DRAWwithblack_H_Border2
	                              mov                  al, HEALTH2
	                              mov                  ah, 0
	                              mov                  bl, 20
	                              div                  bl
	                              add                  al, 40h
	                              cmp                  dx, screenMaxY1+15
	                              jz                   DRAWwithblack_H_Border2
	                              cmp                  dx, screenMaxY1+16
	                              jz                   DRAWwithblack_H_Border2
	                              mov                  al, HEALTH2
	                              mov                  ah, 0
	                              mov                  bl, 20
	                              div                  bl
	                              add                  al, 28h
	DRAWwithblack_H_Border2:      
						
								  			   
	                              mov                  bl, HEALTH2
	                              mov                  bh, 0
	                              add                  cx, 600
	                              sub                  cx, bx
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	                              int                  10h
	                              add                  cx, bx
	                              sub                  cx, 600                                                                              	;  draw the pixel
	                              dec                  Cx
	                              JNZ                  DRAW_H_Border2                                                                       	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cl, HEALTH2                                                                          	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX
	                              cmp                  dx, screenMaxY2+10                                                                   	;  loop iteration in y direction
	                              JZ                   ALL_DRAWN_H_Border2                                                                  	;  both x and y reached 00 so finish drawing
	                              jmp                  DRAW_H_Border2
	ALL_DRAWN_H_Border2:          pop                  bx
	                              ret
DrawHealthbar2 endp
DrawLayout PROC near                                                                                                                    		; drawing the game layout
	;///////////////////////////////////UPPER_BAR\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	                              mov                  RECXEND, 640
	                              mov                  RECYEND, 400
	                              mov                  RECXSTART, 0
	                              mov                  RECYSTART, 0
	                              mov                  RECCOLOR, background_Game_Color
	                              call                 DrawRec


	                              mov                  RECXEND, screenMaxX2
	                              mov                  RECYEND, screenMinY1
	                              mov                  RECXSTART, 0
	                              mov                  RECYSTART, 0
	                              mov                  RECCOLOR, 099h
	                              call                 DrawRec

	                              mov                  RECXEND, 559
	                              mov                  RECYEND, screenMinY1
	                              mov                  RECXSTART, 79
	                              mov                  RECYSTART, 0
	                              mov                  RECCOLOR, 095h
	                              call                 DrawRec

	;//////////////Borders\\\\\\\\\\\\\

	                              mov                  BorderXEND, 559
	                              mov                  BorderYEND, 100
	                              mov                  BorderMIDDLE, 556
	                              mov                  BorderMIDDLED1, 557
	                              mov                  BorderMIDDLED2, 555
	                              mov                  BorderXSTART, 552
	                              mov                  BorderYSTART, 0
	                              mov                  BorderBRIGHTColor, 56h
	                              mov                  BorderDARKColor, 35h
	                              call                 DrawVertBorder

	                              mov                  BorderXEND, 86
	                              mov                  BorderMIDDLE, 83
	                              mov                  BorderMIDDLED1, 84
	                              mov                  BorderMIDDLED2, 82
	                              mov                  BorderXSTART, 79
	                              call                 DrawVertBorder

	                              mov                  BorderXEND, 639
	                              mov                  BorderMIDDLE, 636
	                              mov                  BorderMIDDLED1, 637
	                              mov                  BorderMIDDLED2, 635
	                              mov                  BorderXSTART, 632
	                              mov                  BorderBRIGHTColor, 39h
	                              mov                  BorderDARKColor, 22h
	                              call                 DrawVertBorder

	                              mov                  BorderXEND, 6
	                              mov                  BorderMIDDLE, 3
	                              mov                  BorderMIDDLED1, 4
	                              mov                  BorderMIDDLED2, 2
	                              mov                  BorderXSTART, 0FFFFH
	                              call                 DrawVertBorder

	                              mov                  BorderXEND, 640
	                              mov                  BorderYEND, 7
	                              mov                  BorderMIDDLE, 4
	                              mov                  BorderMIDDLED1, 3
	                              mov                  BorderMIDDLED2, 5
	                              mov                  BorderXSTART, 0
	                              mov                  BorderYSTART, 0
	                              call                 DrawHorizBorder

	                              mov                  BorderYEND, 100
	                              mov                  BorderMIDDLE, 97
	                              mov                  BorderMIDDLED1, 98
	                              mov                  BorderMIDDLED2, 96
	                              mov                  BorderYSTART, 93
	                              call                 DrawHorizBorder

	                              mov                  BorderXEND, 559
	                              mov                  BorderXSTART, 79
	                              mov                  BorderBRIGHTColor, 65h
	                              mov                  BorderDARKColor, 35h
	                              call                 DrawHorizBorder

	                              mov                  BorderYEND, 7
	                              mov                  BorderMIDDLE, 4
	                              mov                  BorderMIDDLED1, 3
	                              mov                  BorderMIDDLED2, 5
	                              mov                  BorderYSTART, 0
	                              call                 DrawHorizBorder
	;//////////////////////////////////DrawCharacter\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	                              mov                  REV, 0
	                              mov                  Ers, 0

	                              mov                  al, playerID1
								  
	                              cmp                  al, 0
	                              JNE                  DrawLayout_secondchar
	                              editDrawPrams        Fenn, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              JMP                  DrawLayout_start

	DrawLayout_secondchar:        cmp                  al, 1
	                              JNE                  DrawLayout_thirdchar
	                              editDrawPrams        Mikasa, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              JMP                  DrawLayout_start
	
	DrawLayout_thirdchar:         cmp                  al, 2
	                              JNE                  DrawLayout_fourthchar
	                              editDrawPrams        Hisoka, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              JMP                  DrawLayout_start

	DrawLayout_fourthchar:        cmp                  al, 3
	                              JNE                  DrawLayout_fifthchar
	                              editDrawPrams        Asta, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              JMP                  DrawLayout_start

	DrawLayout_fifthchar:         
	                              editDrawPrams        Meruem, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              
	DrawLayout_start:             call                 drawShape

	                              mov                  REV, 1
	                              mov                  Ers, 0
	                            
	                              mov                  al, playerID2
								  
	                              cmp                  al, 0
	                              JNE                  DrawLayout2_secondchar
	                              editDrawPrams        Fenn, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY
	                              JMP                  DrawLayout2_start

	DrawLayout2_secondchar:       cmp                  al, 1
	                              JNE                  DrawLayout2_thirdchar
	                              editDrawPrams        Mikasa, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY
	                              JMP                  DrawLayout2_start
	
	DrawLayout2_thirdchar:        cmp                  al, 2
	                              JNE                  DrawLayout2_fourthchar
	                              editDrawPrams        Hisoka, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY
	                              JMP                  DrawLayout2_start

	DrawLayout2_fourthchar:       cmp                  al, 3
	                              JNE                  DrawLayout2_fifthchar
	                              editDrawPrams        Asta, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY
	                              JMP                  DrawLayout2_start

	DrawLayout2_fifthchar:        
	                              editDrawPrams        Meruem, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY

	DrawLayout2_start:            call                 drawShape
	                              mov                  REV, 0
	                              mov                  Ers, 0
	                              editDrawPrams        NameBoxC, NameBoxSizeX, NameBoxSizeY, 2, 72
	                              call                 drawShape

	                              mov                  REV, 0
	                              mov                  Ers, 0
	                              editDrawPrams        NameBoxC, NameBoxSizeX, NameBoxSizeY, 554, 72
	                              call                 drawShape
	;///////////////////////////LowerPart\\\\\\\\\\\\\\\\\\\\\\\\\\\

	                              mov                  RECXEND, screenMaxX2
	                              mov                  RECYEND, screenMaxY2+30
	                              mov                  RECXSTART, 0
	                              mov                  RECYSTART, screenMaxY2
	                              mov                  RECCOLOR, 082h
	                              call                 DrawRec

	                              mov                  BorderXEND, 639
	                              mov                  BorderYEND, screenMaxY2+30
	                              mov                  BorderMIDDLE, 636
	                              mov                  BorderMIDDLED1, 637
	                              mov                  BorderMIDDLED2, 635
	                              mov                  BorderXSTART, 632
	                              mov                  BorderYSTART, screenMaxY1
	                              mov                  BorderBRIGHTColor, 39h
	                              mov                  BorderDARKColor, 22h
	                              call                 DrawVertBorder

	                              mov                  BorderXEND, 6
	                              mov                  BorderMIDDLE, 3
	                              mov                  BorderMIDDLED1, 4
	                              mov                  BorderMIDDLED2, 2
	                              mov                  BorderXSTART, 0FFFFH
	                              call                 DrawVertBorder

	                              mov                  BorderXEND, 640
	                              mov                  BorderYEND, screenMaxY1+7
	                              mov                  BorderMIDDLE, screenMaxY1+4
	                              mov                  BorderMIDDLED1, screenMaxY1+3
	                              mov                  BorderMIDDLED2, screenMaxY1+5
	                              mov                  BorderXSTART, 0
	                              mov                  BorderYSTART, screenMaxY1
	                              call                 DrawHorizBorder

	                              mov                  BorderYEND, screenMaxY1+30
	                              mov                  BorderMIDDLE, screenMaxY1+27
	                              mov                  BorderMIDDLED1, screenMaxY1+28
	                              mov                  BorderMIDDLED2, screenMaxY1+26
	                              mov                  BorderYSTART, screenMaxY1+23
	                              call                 DrawHorizBorder
	; print player's name
	                              printStringAtLoc     playerName1[2], 5, 2
	                              printStringAtLoc     playerName2[2], 5, 71
	                              ret
DrawLayout ENDP
DrawAngry1 PROC NEAR                                                                                                                    		; draw angry character for player 1
	                              mov                  REV, 0
	                              mov                  Ers, 0

	                              mov                  al, playerID1
								  
	                              cmp                  al, 0
	                              JNE                  DrawAngry_secondchar
	                              editDrawPrams        Fenn, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              JMP                  DrawAngry_start

	DrawAngry_secondchar:         cmp                  al, 1
	                              JNE                  DrawAngry_thirdchar
	                              editDrawPrams        Mikasa2, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              JMP                  DrawAngry_start
	
	DrawAngry_thirdchar:          cmp                  al, 2
	                              JNE                  DrawAngry_fourthchar
	                              editDrawPrams        Hisoka2, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              JMP                  DrawAngry_start

	DrawAngry_fourthchar:         cmp                  al, 3
	                              JNE                  DrawAngry_fifthchar
	                              editDrawPrams        Asta2, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              JMP                  DrawAngry_start

	DrawAngry_fifthchar:          
	                              editDrawPrams        Meruem2, CharacterSizeX, CharacterSizeY, CharacteroffsetX, CharacteroffsetY
	                              
	DrawAngry_start:              call                 drawShape

	                              ret
DrawAngry1 ENDP
DrawAngry2 PROC NEAR                                                                                                                    		; draw angry char for player 2
	                              mov                  REV, 1
	                              mov                  Ers, 0
	                            
	                              mov                  al, playerID2
								  
	                              cmp                  al, 0
	                              JNE                  DrawAngry2_secondchar
	                              editDrawPrams        Fenn2, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY
	                              JMP                  DrawAngry2_start

	DrawAngry2_secondchar:        cmp                  al, 1
	                              JNE                  DrawAngry2_thirdchar
	                              editDrawPrams        Mikasa2, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY
	                              JMP                  DrawAngry2_start
	
	DrawAngry2_thirdchar:         cmp                  al, 2
	                              JNE                  DrawAngry2_fourthchar
	                              editDrawPrams        Hisoka2, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY
	                              JMP                  DrawAngry2_start

	DrawAngry2_fourthchar:        cmp                  al, 3
	                              JNE                  DrawAngry2_fifthchar
	                              editDrawPrams        Asta2, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY
	                              JMP                  DrawAngry2_start

	DrawAngry2_fifthchar:         
	                              editDrawPrams        Meruem2, CharacterSizeX, CharacterSizeY, CharacteroffsetX2, CharacteroffsetY

	DrawAngry2_start:             call                 drawShape
	                              ret
DrawAngry2 ENDP
	;/////////////////////////////// related to the win and lose
checkForWinner PROC NEAR
	; check for health
	                              mov                  ah, HEALTH1
	                              mov                  al, 0
	                              CMP                  ah, al
	                              JE                   Player2_Winner
	                              mov                  ah, HEALTH2
	                              CMP                  ah, al
	                              JE                   Player1_Winner
	                              JMP                  EndGameWinner
	Player1_Winner:                                                                                                                         	; if player 1 is the winner then, explode ship2
	                              call                 Eraseship2
	                              mov                  ax, shipOffsetX2
	                              mov                  ExplosionOffsetX, ax
	                              mov                  ax, shipOffsetY2
	                              mov                  ExplosionOffsetY, ax
	                              call                 DrawExplosion
	                              clearWholeScreen

	                              showScreen           winnerWinner
	                              printStringAtLoc     playerName1[2], 18, 0
	                              printStringAtLoc     congrats, 18, playerName1[1]

	                              jmp                  CONINUE_ENDMSG
	Player2_Winner:                                                                                                                         	; if player 2 is the winner then, explode ship1
	                              call                 Eraseship1
	                              mov                  ax, shipOffsetX1
	                              mov                  ExplosionOffsetX, ax
	                              mov                  ax, shipOffsetY1
	                              mov                  ExplosionOffsetY, ax
	                              call                 DrawExplosion
	                              clearWholeScreen

	                              showScreen           winnerWinner
	                              printStringAtLoc     playerName2[2], 18, 0
	                              printStringAtLoc     congrats, 18, playerName2[1]
CONINUE_ENDMSG:
	                              printStringAtLoc     NewEndGame, 1, 0                                                                     	; show ask for a new game message
	ReadNewGame:                  
	                              waitForInput
	                              CMP                  ah, key_y
	                              JE                   NewGameCreator
	                              CMP                  ah, key_n
	                              JE                   EndGameCreator
	                              JMP                  ReadNewGame
	EndGameCreator:               
	                              call                 NewGameInitializer
	                              jmp                  mainMenuLoop
	NewGameCreator:               
	                              call                 NewGameInitializer
	EndGameWinner:                
	                              ret
checkForWinner ENDP

DrawExplosion PROC near
	                              push                 DI
	                              mov                  rev, 0
	                              mov                  ers, 0
	                              editDrawPrams        Explosion1, shipSizeX, shipSizeY, ExplosionOffsetX, ExplosionOffsetY
	                              mov                  DI, SI
	                              mov                  RECCOLOR, background_Game_Color

	ExplosionAnimate:             
	                              call                 drawShape
	                              Xchg                 DI, SI
	                              delay                ExplosionDelay
	                              call                 Eraseshape
	                              dec                  ExplosionItr
	                              jnz                  ExplosionAnimate

	                              call                 drawShape
	                              mov                  ExplosionItr, 6
	                              pop                  DI

	                              delay                4000
	                              ret
DrawExplosion ENDP
	;/////////////////////////////// related to the main menu and the get name screens
displayChooseCharScreen proc NEAR                                                                                                       		; display the choose character screen                                                                                                     		; draw the characters in the choose character screen
	                              editDrawPrams        Fenn, charSizeX, charSizeY, firstCharOffsetX, charOffsetY
	                              call                 drawShape

	                              editDrawPrams        Mikasa2, charSizeX, charSizeY, secondCharOffsetX, charOffsetY
	                              call                 drawShape

	                              editDrawPrams        Hisoka2, charSizeX, charSizeY, thirdCharOffsetX, charOffsetY
	                              call                 drawShape

	                              editDrawPrams        Asta2, charSizeX, charSizeY, fourthCharOffsetX, charOffsetY
	                              call                 drawShape

	                              editDrawPrams        Meruem2, charSizeX, charSizeY, fifthCharOffsetX, charOffsetY
	                              call                 drawShape
	; draw the planes in the choose character screen
	                              editDrawPrams        Fenn_Plane, shipSizeX, shipSizeY, firstShipOffsetX, shipOffsetY
	                              call                 drawShape

	                              editDrawPrams        Mikasa_Plane, shipSizeX, shipSizeY, secondShipOffsetX, shipOffsetY
	                              call                 drawShape

	                              editDrawPrams        Hisoka_Plane, shipSizeX, shipSizeY, thirdShipOffsetX, shipOffsetY
	                              call                 drawShape

	                              editDrawPrams        Asta_Plane, shipSizeX, shipSizeY, fourthShipOffsetX, shipOffsetY
	                              call                 drawShape

	                              editDrawPrams        Meruem_Plane, shipSizeX, shipSizeY, fifthShipOffsetX, shipOffsetY
	                              call                 drawShape
	; draw the pointer in the choose character screen
	                              editDrawPrams        MSGTAIL, pointerSizeX, pointerSizeY, pointerOffsetX, pointerOffsetY
	                              call                 drawShape

	                              ret
	                              endp
getCharID proc                                                                                                                          		; get player's char ID form the choose character screen                                                                                                                		; adds the player ID in BL
	drawPointer1_Label:           
	                              call                 displayChooseCharScreen
	checkFirstScreen:             waitForInput
	                              cmp                  ah, key_rightArrow                                                                   	; up pointer
	                              jne                  leftpointer_label
	                              cmp                  pointerOffsetX, pointerAtFifthChar
	                              JE                   checkFirstScreen
	                              editDrawPrams        MSGTAIL, pointerSizeX, pointerSizeY, pointerOffsetX, pointerOffsetY
	                              call                 Eraseshape
	                              MOV                  BX, pointerStep
	                              ADD                  pointerOffsetX, BX
	                              editDrawPrams        MSGTAIL, pointerSizeX, pointerSizeY, pointerOffsetX, pointerOffsetY
	                              call                 drawShape

	                              mov                  Al, background_Game_Color
	                              call                 getCurrentChar
	                              call                 Eraseshape
	                              mov                  Al, 1
	                              call                 getCurrentChar
	                              call                 drawShape
						
	                              INC                  pointerAt

	                              mov                  Al, 1
	                              call                 getCurrentChar
	                              call                 Eraseshape
	                              mov                  Al, 0
	                              call                 getCurrentChar
	                              call                 drawShape
	checkFirstScreen_1:           
	                              JMP                  checkFirstScreen
	leftpointer_label:            
	                              cmp                  ah, key_leftArrow
	                              JNE                  enterpointer_label
	                              CMP                  pointerOffsetX, pointerAtFirstChar
	                              JE                   checkFirstScreen_1
	                              editDrawPrams        MSGTAIL, pointerSizeX, pointerSizeY, pointerOffsetX, pointerOffsetY
	                              call                 Eraseshape
	                              MOV                  BX, pointerStep
	                              SUB                  pointerOffsetX, BX
	                              editDrawPrams        MSGTAIL, pointerSizeX, pointerSizeY, pointerOffsetX, pointerOffsetY
	                              call                 drawShape

	                              mov                  Al, 0
	                              call                 getCurrentChar
	                              call                 Eraseshape
	                              mov                  Al, 1
	                              call                 getCurrentChar
	                              call                 drawShape

	                              DEC                  pointerAt

	                              mov                  Al, 1
	                              call                 getCurrentChar
	                              call                 Eraseshape
	                              mov                  Al, 0
	                              call                 getCurrentChar
	                              call                 drawShape
						
	checkFirstScreen_2:           JMP                  checkFirstScreen
	enterpointer_label:           CMP                  AH, key_enter
	                              JNE                  checkFirstScreen_2
	                              MOV                  BL, pointerAt
								  
	                              Ret
	                              endp
background PROC near                                                                                                                    		; draws the background -patterns-
	                              MOV                  CX, 640                                                                              	;set the width (X) up to ff, dont forget to change this number in the loop
	                              MOV                  DX, 400                                                                              	;set the hieght (Y) up to AA
	                              jmp                  background_start                                                                     	;Avoid drawing before the calculations
	background_drawIt:            
	                              push                 cx
	                              push                 dx
	                              add                  cx,cx
	                              add                  cx,cx
	                              add                  dx,dx
	                              mov                  AX, 0                                                                                	;  |
	                              mov                  AL, DL                                                                               	;  |  > Multuply DL*Dl and Store in AX then BX
	                              Mul                  DL                                                                                   	;  |
	                              mov                  bx, AX                                                                               	;  |
	                              mov                  AL, CL                                                                               	;  \
	                              Mul                  CL                                                                                   	;  \   > Multuply CL*Cl and Store in AX


	                              add                  bx, AX
	                              xchg                 ax,bx
	                              mov                  bl, 8
	                              mov                  ah, 0

	                              div                  bl
	                              xchg                 al,ah
	                              add                  al, 7fh
	                              MOV                  AH,0Ch                                                                               	;set the configuration to writing a pixel
	                              INT                  10h
	                              pop                  dx
	                              pop                  cx                                                                                   	;execute the configuration
	background_start:             
        
	                              DEC                  CX                                                                                   	;  loop iteration in x direction
	                              JNZ                  TRY                                                                                  	;  check if we can draw current x and y and excape the y iteration
	                              mov                  CX, 640                                                                              	;  if loop iteration in y direction, then x should background_start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   ENDING                                                                               	;  both x and y reached 00 so end program
	TRY:                          jmp                  background_drawIt                                                                    	; loop
	ENDING:                       
	                              RET
background ENDP
eraseArrows PROC near                                                                                                                   		; erase the arrows used in the main menu
	; initialize containers
	                              mov                  SI, offset arrow                                                                     	;shipY is (shipX index + size * 2) so we can use Si for both
	                              mov                  cx, arrowSizeX                                                                       	;Column X
	                              mov                  dx, arrowSizeY                                                                       	;Row Y
	                              push                 ax
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	                              mov                  al, 0h                                                                               	;to be replaced with background
	
	eraseArrows_drawIt:           
	                              mov                  bl, [SI]                                                                             	;  use color from array color for testing
	                              and                  bl, bl
	                              JZ                   eraseArrows_back
	                              add                  cx, arrowoffsetX
	                              add                  dx, arrowoffsetY
	                              int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, arrowoffsetX
	                              sub                  dx, arrowoffsetY
	                              push                 cx
	                              push                 dx
	                              mov                  AX, 0                                                                                	;  |
	                              mov                  AL, DL                                                                               	;  |  > Multuply DL*Dl and Store in AX then BX
	                              Mul                  DL                                                                                   	;  |
	                              mov                  bx, AX                                                                               	;  |
	                              mov                  AL, CL                                                                               	;  \
	                              Mul                  CL                                                                                   	;  \   > Multuply CL*Cl and Store in AX


	                              add                  bx, AX
	                              xchg                 ax,bx
	                              mov                  bl, 8
	                              mov                  ah, 0

	                              div                  bl
	                              xchg                 al,ah
	                              add                  al, 7fh
	                              MOV                  AH,0Ch
	                              add                  cx, arrowoffsetX
	                              add                  dx, arrowoffsetY                                                                     	;set the configuration to writing a pixel
	                              INT                  10h
	                              pop                  dx
	                              pop                  cx

	eraseArrows_back:             
	                              inc                  SI
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              JNZ                  eraseArrows_drawIt                                                                   	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, arrowSizeX                                                                       	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   eraseArrows_allDrawn                                                                 	;  both x and y reached 00 so finish drawing
	                              jmp                  eraseArrows_drawIt
	eraseArrows_allDrawn:         pop                  ax
	;/////////////////////////////////////////////////////////////////////////////////////////////
	; initialize containers
	                              mov                  SI, offset arrow                                                                     	;shipY is (shipX index + size * 2) so we can use Si for both
	                              mov                  cx, 0                                                                                	;Column X
	                              mov                  dx, arrowSizeY                                                                       	;Row Y
	                              push                 ax
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	                              mov                  al, 0h                                                                               	;to be replaced with background
	
	eraseArrows_drawItR:          
	                              mov                  bl, [SI]                                                                             	;  use color from array color for testing
	                              and                  bl, bl
	                              JZ                   eraseArrows_backR
	                              add                  cx, arrowoffsetXRev
	                              add                  dx, arrowoffsetY
	                              int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, arrowoffsetXRev
	                              sub                  dx, arrowoffsetY
	                              push                 cx
	                              push                 dx
	                              mov                  AX, 0                                                                                	;  |
	                              mov                  AL, DL                                                                               	;  |  > Multuply DL*Dl and Store in AX then BX
	                              Mul                  DL                                                                                   	;  |
	                              mov                  bx, AX                                                                               	;  |
	                              mov                  AL, CL                                                                               	;  \
	                              Mul                  CL                                                                                   	;  \   > Multuply CL*Cl and Store in AX


	                              add                  bx, AX
	                              xchg                 ax,bx
	                              mov                  bl, 8
	                              mov                  ah, 0

	                              div                  bl
	                              xchg                 al,ah
	                              add                  al, 7fh
	                              MOV                  AH,0Ch
	                              add                  cx, arrowoffsetXRev
	                              add                  dx, arrowoffsetY                                                                     	;set the configuration to writing a pixel
	                              INT                  10h
	                              pop                  dx
	                              pop                  cx

	eraseArrows_backR:            
	                              inc                  SI
	                              INC                  Cx                                                                                   	;  loop iteration in x direction
	                              CMP                  CX, arrowSizeX
	                              JNZ                  eraseArrows_drawItR                                                                  	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, 0                                                                                	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   eraseArrows_allDrawnR                                                                	;  both x and y reached 00 so finish drawing
	                              jmp                  eraseArrows_drawItR
	eraseArrows_allDrawnR:        pop                  ax
	                              ret
eraseArrows ENDP
getCurrentChar PROC                                                                                                                     		; gets the character that the pointer is pointing to, to get its ID
	                              MOV                  BL, pointerAt
	
	                              CMP                  BL, 0
	                              JNE                  getCurrentChar_At1
	                              CMP                  AL, 0
	                              JNE                  getCurrentChar_At02
	                              editDrawPrams        Fenn, charSizeX, charSizeY, firstCharOffsetX, charOffsetY
	                              ret
	getCurrentChar_At02:          
	                              editDrawPrams        Fenn2, charSizeX, charSizeY, firstCharOffsetX, charOffsetY
	                              ret

	getCurrentChar_At1:           CMP                  BL, 1
	                              JNE                  getCurrentChar_At2
	                              CMP                  AL, 0
	                              JNE                  getCurrentChar_At12
	                              editDrawPrams        Mikasa, charSizeX, charSizeY, secondCharOffsetX, charOffsetY
	                              ret
	getCurrentChar_At12:          
	                              editDrawPrams        Mikasa2, charSizeX, charSizeY, secondCharOffsetX, charOffsetY
	                              ret

	getCurrentChar_At2:           CMP                  BL, 2
	                              JNE                  getCurrentChar_At3
	                              CMP                  AL, 0
	                              JNE                  getCurrentChar_At22
	                              editDrawPrams        Hisoka, charSizeX, charSizeY, thirdCharOffsetX, charOffsetY
	                              ret
	getCurrentChar_At22:          
	                              editDrawPrams        Hisoka2, charSizeX, charSizeY, thirdCharOffsetX, charOffsetY
	                              ret

	getCurrentChar_At3:           CMP                  BL, 3
	                              JNE                  getCurrentChar_At4
	                              CMP                  AL, 0
	                              JNE                  getCurrentChar_At32
	                              editDrawPrams        Asta, charSizeX, charSizeY, fourthCharOffsetX, charOffsetY
	                              ret
	getCurrentChar_At32:          
	                              editDrawPrams        Asta2, charSizeX, charSizeY, fourthCharOffsetX, charOffsetY
	                              ret

	getCurrentChar_At4:           
	                              CMP                  AL, 0
	                              JNE                  getCurrentChar_At42
	                              editDrawPrams        Meruem, charSizeX, charSizeY, fifthCharOffsetX, charOffsetY
	                              ret
	getCurrentChar_At42:          
	                              editDrawPrams        Meruem2, charSizeX, charSizeY, fifthCharOffsetX, charOffsetY
	                              ret
getCurrentChar ENDP
drawLogo PROC                                                                                                                           		; draws the logo streched                                                                                                                		; streched                                                                                                                          		; this function stretches the logo
	; initialize container

	                              mov                  SI, offset logo
	                              mov                  cx, logoSizeX                                                                        	;Column X
	                              mov                  dx, logoSizeY                                                                        	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	drawlogo_drawIt:              
	                              mov                  bl, ES:[SI]                                                                          	;use color from array color for testing
	                              and                  bl, bl
	                              JZ                   drawlogo_back
	                              mov                  al, ES:[SI]                                                                          	;  use color from array color for testing
	                              push                 cx
	                              push                 dx
	                              add                  cx,cx
	                              add                  dx,dx
	                              add                  cx,logoOffset
	                              add                  dx,logoOffset+2
	                              int                  10h
	                              DEC                  cx
	                              int                  10h
	                              dec                  dx
	                              inc                  cx
	                              int                  10h
	                              dec                  cx
	                              int                  10h                                                                                  	;  draw the pixel
	                              pop                  dx
	                              pop                  cx

	drawlogo_back:                
	                              inc                  SI
	                              DEC                  Cx
	                              JNZ                  drawlogo_drawIt                                                                      	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, logoSizeX                                                                        	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX
	                              JZ                   drawlogo_allDrawn                                                                    	;  both x and y reached 00 so finish drawing
	                              jmp                  drawlogo_drawIt
	drawlogo_allDrawn:            ret
drawLogo ENDP
	;/////////////////////////////// global drawing functions
drawShape PROC                                                                                                                          		; call (editDrawPrams) before it
	; initialize containers
	;mov SI, offset Shape
	                              mov                  cx, shapeSizeX
	                              cmp                  REV, 0
	                              jz                   DontREVCXDraw
	                              mov                  cx, 0                                                                                	;Column X
	DontREVCXDraw:                push                 cx
	                              mov                  dx, shapeSizeY                                                                       	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	drawShape_drawIt:             
	                              mov                  bl, [SI]                                                                             	;use color from array color for testing
	                              and                  bl, bl
	                              JZ                   drawShape_back
	                              add                  cx, shapeOffsetX
	                              add                  dx, shapeOffsetY
	                              mov                  al, [SI]
	                              cmp                  Ers, 0
	                              jz                   DrawWithPxl
	                              mov                  al, RECCOLOR                                                                         	;  use color from array color for testing
	DrawWithPxl:                  int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, shapeOffsetX
	                              sub                  dx, shapeOffsetY
	drawShape_back:               
	                              inc                  SI
	                              cmp                  REV, 1
	                              JZ                   RevDraw
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              jmp                  ContinueDrawLoop
	RevDraw:                      inc                  cx
	                              cmp                  cx, shapeSizeX
	ContinueDrawLoop:             JNZ                  drawShape_drawIt                                                                     	;  check if we can draw current x and y and excape the y iteration
	                              pop                  cx
	                              push                 cx                                                                                   	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   drawShape_alldrawn                                                                   	;  both x and y reached 00 so finish drawing
	                              jmp                  drawShape_drawIt
	drawShape_alldrawn:           pop                  cx
	                              ret
drawShape ENDP
drawShape_extra PROC                                                                                                                    		; call (editDrawPrams) before it                                                                                                                    		; draw shapes in the extra segment
	; initialize containers
	;mov SI, offset Shape
	                              mov                  cx, shapeSizeX
	                              cmp                  REV, 0
	                              jz                   DontREVCXDraw_ex
	                              mov                  cx, 0                                                                                	;Column X
	DontREVCXDraw_ex:             push                 cx
	                              mov                  dx, shapeSizeY                                                                       	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	drawShape_drawIt_ex:          
	                              mov                  bl, ES:[SI]                                                                          	;use color from array color for testing
	                              and                  bl, bl
	                              JZ                   drawShape_back_ex
	                              add                  cx, shapeOffsetX
	                              add                  dx, shapeOffsetY
	                              mov                  al, ES:[SI]
	                              cmp                  Ers, 0
	                              jz                   DrawWithPxl_ex
	                              mov                  al, RECCOLOR                                                                         	;  use color from array color for testing
	DrawWithPxl_ex:               int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, shapeOffsetX
	                              sub                  dx, shapeOffsetY
	drawShape_back_ex:            
	                              inc                  SI
	                              cmp                  REV, 1
	                              JZ                   RevDraw_ex
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              jmp                  ContinueDrawLoop_ex
	RevDraw_ex:                   inc                  cx
	                              cmp                  cx, shapeSizeX
	ContinueDrawLoop_ex:          JNZ                  drawShape_drawIt_ex                                                                  	;  check if we can draw current x and y and excape the y iteration
	                              pop                  cx
	                              push                 cx                                                                                   	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   drawShape_alldrawn_ex                                                                	;  both x and y reached 00 so finish drawing
	                              jmp                  drawShape_drawIt_ex
	drawShape_alldrawn_ex:        pop                  cx
	                              ret
drawShape_extra ENDP
Eraseshape PROC near                                                                                                                    		; call (editDrawPrams) before it
	; initialize containers
	                              mov                  cx, shapeSizeX                                                                       	;Column X
	                              mov                  dx, shapeSizeY                                                                       	;Row Y
	                              push                 ax
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	                              mov                  al, RECCOLOR                                                                         	;to be replaced with background
	
	Eraseshape_Drawit:            
	                              mov                  bl, [SI]                                                                             	;  use color from array color for testing
	                              and                  bl, bl
	                              JZ                   Eraseshape_back
	                              add                  cx, shapeOffsetX
	                              add                  dx, shapeOffsetY
	                              int                  10h                                                                                  	;  draw the pixel
	                              sub                  cx, shapeOffsetX
	                              sub                  dx, shapeOffsetY

	Eraseshape_back:              
	                              inc                  SI
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              JNZ                  Eraseshape_Drawit                                                                    	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, shapeSizeX                                                                       	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              JZ                   Eraseshape_alldrawn                                                                  	;  both x and y reached 00 so finish drawing
	                              jmp                  Eraseshape_Drawit
	Eraseshape_alldrawn:          pop                  ax
	                              ret
Eraseshape ENDP
DrawRec PROC near
	                              mov                  cx, RECXEND                                                                          	;Column X
	                              mov                  dx, RECYEND                                                                          	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	DRAW_REC1:                    
	                              mov                  al, RECCOLOR                                                                         	;  use color from array color for testing
	                              int                  10h                                                                                  	;  draw the pixel
	BACK_REC1:                    
	                              DEC                  Cx
	                              CMP                  CX, RECXSTART                                                                        	;  loop iteration in x direction
	                              JNZ                  DRAW_REC1                                                                            	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, RECXEND                                                                          	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX
	                              CMP                  DX,RECYSTART                                                                         	;  loop iteration in x direction
	                              JZ                   ALL_DRAWN_REC1                                                                       	;  both x and y reached 00 so finish drawing
	                              jmp                  DRAW_REC1
	ALL_DRAWN_REC1:               
	                              ret
DrawRec ENDP
DrawHorizBorder PROC	near
	                              mov                  cx, BorderXEND                                                                       	;Column X
	                              mov                  dx, BorderYEND                                                                       	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	DRAW_HorizBorder:             
	                              mov                  al, BorderDARKColor
	                              cmp                  dx, BorderMIDDLED1
	                              jz                   DRAWwithblack_HorizBorder
	                              cmp                  dx, BorderMIDDLED2
	                              jz                   DRAWwithblack_HorizBorder
	                              mov                  al, BorderBRIGHTColor
	                              cmp                  dx, BorderMIDDLE
	                              jz                   DRAWwithblack_HorizBorder
	                              mov                  al, 0h                                                                               	;  use color from array color for testing
	DRAWwithblack_HorizBorder:    int                  10h                                                                                  	;  draw the pixel
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              cmp                  CX, BorderXSTART
	                              JNZ                  DRAW_HorizBorder                                                                     	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, BorderXEND                                                                       	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              cmp                  dx, BorderYSTART
	                              JZ                   ALL_DRAWN_HorizBorder                                                                	;  both x and y reached 00 so finish drawing
	                              jmp                  DRAW_HorizBorder

	ALL_DRAWN_HorizBorder:        
	                              ret
DrawHorizBorder ENDP
DrawVertBorder PROC NEAR
	                              mov                  cx, BorderXEND                                                                       	;Column X
	                              mov                  dx, BorderYEND                                                                       	;Row Y
	                              mov                  ah, 0ch                                                                              	;Draw Pixel Command
	Draw_VertBorder:              
	                              mov                  al, BorderDARKColor
	                              cmp                  cx, BorderMIDDLED1
	                              jz                   DRAWwithblack_VertBorder
	                              cmp                  cx, BorderMIDDLED2
	                              jz                   DRAWwithblack_VertBorder
	                              mov                  al, BorderBRIGHTColor
	                              cmp                  cx, BorderMIDDLE
	                              jz                   DRAWwithblack_VertBorder
	                              mov                  al, 0h                                                                               	;  use color from array color for testing
	DRAWwithblack_VertBorder:     int                  10h                                                                                  	;  draw the pixel
	                              DEC                  Cx                                                                                   	;  loop iteration in x direction
	                              cmp                  CX, BorderXSTART
	                              JNZ                  Draw_VertBorder                                                                      	;  check if we can draw c urrent x and y and excape the y iteration
	                              mov                  Cx, BorderXEND                                                                       	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                              DEC                  DX                                                                                   	;  loop iteration in y direction
	                              cmp                  dx, BorderYSTART
	                              JZ                   ALL_DRAWN_VertBorder                                                                 	;  both x and y reached 00 so finish drawing
	                              jmp                  Draw_VertBorder
	ALL_DRAWN_VertBorder:         
	                              ret
DrawVertBorder endp
;//////////////////////////////Procedures///////////////////////////////////////
        END MAIN
;///////////////////////////////code segment////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////
;//////////////////////////////TODO/////////////////////////////////////////////
@comment
		TODO:

@
;//////////////////////////////TODO//////////////////////////////////////////////
