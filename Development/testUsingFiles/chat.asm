.MODEL SMALL
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
;
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
setCursorAt_rowCol MACRO rowCol  		; sets cursor position in DX and in rowCol
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
;
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
checkIfESC MACRO char, notESCLabel		; check if the character is escape
	           mov al, char
	;
	           cmp al, 01Bh
	           JNE notESCLabel
	; else
ENDM
checkIfBackSpace MACRO char, notBackSpaceLabel		; check if the character is BackSpace
	                 mov al, char
	;
	                 cmp al, 08h
	                 JNE notBackSpaceLabel
ENDM
;
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
	                    setCursorAt_Row_Col row_send, col_send                                                                	; set the cursor to the new location
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
	                    setCursorAt_Row_Col row_rec, col_rec                                                                  	; set the cursor to the new location
	nothing:            
	ENDM
;
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
;
.stack 64
.data
	BF_upper           equ 3Fh
	topLeftX_upper     equ 0
	topLeftY_upper     equ 0
	bottomRightX_upper equ 79
	bottomRightY_upper equ 11            	; less than topLeftY_lower by 2, to leave an empty line between them
	;
	BF_lower           equ 6Fh
	topLeftX_lower     equ 0
	topLeftY_lower     equ 13            	; more than bottomRightY_upper by 2,  to leave an empty line between them
	bottomRightX_lower equ 79
	bottomRightY_lower equ 24
	; we don't write in the last line to achive symmetry, if you want to delete the middle line,
	; edit bottomRightY_lower to 25 and bottomRightY_upper to 12
	;
	col_send           DB  topLeftX_upper
	row_send           DB  topLeftY_upper
	col_rec            DB  topLeftX_lower
	row_rec            DB  topLeftY_lower
	currentChar DB ?
.code
MAIN PROC FAR
	                   mov                  AX, @data
	                   mov                  DS, AX
	                   clearWholeScreen
	;   mov                aX,4F02h          	; enter the graphics mode
	;   mov                bx, 0100h
	;   int                21h
	                   initializaPort
	                   colorScreen          BF_upper, topLeftX_upper, topLeftY_upper, bottomRightX_upper, bottomRightY_upper
	                   colorScreen          BF_lower, topLeftX_lower, topLeftY_lower, bottomRightX_lower, bottomRightY_lower
	;//////////////////////////////
	startChat:         
	;//////////////////////////////
	;Check that Transmitter Holding Register is Empty
	sendData:          port_checkCanSend    getData_midLabel1                                                               	; Not empty, can't send data then, go to get data
	;If empty put the VALUE in Transmit data register
	                   checkForScrollUpper  row_send, col_send                                                              	; cehck for the scrolling status

	                   checkIfInput         getData_midLabel1                                                               	; if no key is pressed then, go to get data
	                   getCharASCII         currentChar                                                                     	; Get key pressed (Wait for a key-AH:scancode,AL:ASCII)
	           
	                   checkIfPrintable     currentChar, sendNotPrintable
	                   printCharAtLoc       currentChar, row_send, col_send
	                   getCursorAt_Row__col row_send, col_send
	                   jmp                  sendIsDone
	;////////////////////////////////////
	;/// midLabel1
	getData_midLabel1: jmp                  getData_midLabel2
	sendData_midLabel1:jmp                  sendData
	;/// to solve the jump out of range
	;////////////////////////////////////
	sendNotPrintable:  
	                   checkIfEnter         currentChar, sendNotEnter
	                   inc                  row_send                                                                        	; go to the next line
	                   mov                  col_send, topLeftX_upper                                                        	; start from column zero
	                   setCursorAt_Row_Col  row_send, col_send                                                              	; set the cursor to the new location
	;////////////////////////////////////
	sendNotEnter:      
	                   checkIfBackSpace     currentChar, sendNotBackSpace
	; if not start of a new line then, backspace
	                   cmp                  col_send, topLeftX_upper
	                   JNE                  backSpaceInSend                                                                 	; not a start of a line
	; it is a start of a new line
	; check if the first row then do nothing
	                   cmp                  row_send, topLeftY_upper
	                   JE                   sendNotBackSpace
	; if not the first row then, dec the row
	                   dec                  row_send
	                   mov                  col_send, topLeftX_upper + 80                                                   	; move it to the end of the last line
	checkForRowInSend: 
	;erase the previous character and update the cursor position
	backSpaceInSend:   dec                  col_send                                                                        	; start from column zero
	                   printCharAtLoc       ' ', row_send, col_send
	                   setCursorAt_Row_Col  row_send, col_send                                                              	; set the cursor to the new location
	;////////////////////////////////////
	sendNotBackSpace:  
	                   checkIfESC           currentChar, sendNotESC
						port_sendChar        currentChar; if escape then, send it to the other user before closing the program
	                   jmp                  exitProg
	sendNotESC:        
	; do nothing!
	;////////////////////////////////////
	sendIsDone:        port_sendChar        currentChar
	;////////////////////////////////////
	;/// midLabel2
	getData_midLabel2: jmp                  getData
	sendData_midLabel2:jmp                  sendData_midLabel1
	;/// to solve the jump out of range
	;////////////////////////////////////
	;//////////////////////////////;////////////////////////////////////;////////////////////////////////////;////////////////////////////////////
	;Check that Data is Ready
	getData:           port_checkReceive    sendData_midLabel2                                                              	; Not Ready, can't get data then, go to send data
	;If Ready read the VALUE in Receive data register
	                   checkForScrollLower  row_rec, col_rec
	                   port_getChar         currentChar
	                   checkIfPrintable     currentChar, recNotPrintable
	                   printCharAtLoc       currentChar, row_rec, col_rec
	                   getCursorAt_Row__col row_rec, col_rec
	                   jmp                  recIsDone
	recNotPrintable:   
	                   checkIfEnter         currentChar, recNotEnter
	                   inc                  row_rec                                                                         	; go to the next line
	                   mov                  col_rec, topLeftX_lower                                                         	; start from column zero
	                   setCursorAt_Row_Col  row_rec, col_rec
	recNotEnter:       
	                   checkIfBackSpace     currentChar, recNotBackSpace
	; if not start of a new line then, backspace
	                   cmp                  col_rec, topLeftX_lower
	                   JNE                  backSpaceInRec                                                                  	; not a start of a line
	; it is a start of a new line
	; check if the first row then do nothing
	                   cmp                  row_rec, topLeftY_lower
	                   JE                   recNotBackSpace
	; if not the first row then, dec the row
	                   dec                  row_rec
	                   mov                  col_rec, topLeftX_lower + 80                                                    	; move it to the end of the last line
	checkForRowInRec:  
	;erase the previous character and update the cursor position
	backSpaceInRec:    dec                  col_rec                                                                         	; start from column zero
	                   printCharAtLoc       ' ', row_rec, col_rec
	                   setCursorAt_Row_Col  row_rec, col_rec                                                                	; set the cursor to the new location
	;////////////////////////////////////
	recNotBackSpace:   
	                   checkIfESC           currentChar, recNotESC
	                   jmp                  exitProg
	recNotESC:        
	; do nothing!
	;////////////////////////////////////
	recIsDone:         getCursorAt_Row__col row_rec, col_rec
	;//////////////////////////////
	                   jmp                  startChat
	exitProg:          mov                  ah,4ch
	                   int                  21h
main endp
END MAIN