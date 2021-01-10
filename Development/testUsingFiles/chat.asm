PUBLIC CHATModule
.MODEL SMALL
.stack 64
;///////////////////////////////Macros////////////////////////////////////
include MACROS.inc
;///////////////////////////////Macros////////////////////////////////////
.data
	; you only need to edit those numbers to specify the cooardinates you want!
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
	;
	currentChar DB ?
.code
CHATModule PROC FAR
	                    mov                         AX, @data
	                    mov                         DS, AX
	                    clearWholeScreen_noGraphics
	                    initializaPort
	                    colorScreen                 BF_upper, topLeftX_upper, topLeftY_upper, bottomRightX_upper, bottomRightY_upper
	                    colorScreen                 BF_lower, topLeftX_lower, topLeftY_lower, bottomRightX_lower, bottomRightY_lower
	;//////////////////////////////
	startChat:          
	;//////////////////////////////
	;Check that Transmitter Holding Register is Empty
	sendData:           port_checkCanSend           getData_midLabel1                                                                 	; Not empty, can't send data then, go to get data
	;If empty put the VALUE in Transmit data register
	                    call                        checkForScrollUpper                                                               	; cehck for the scrolling status

	                    checkIfInput                getData_midLabel1                                                                 	; if no key is pressed then, go to get data
	                    getCharASCII                currentChar                                                                       	; Get key pressed (Wait for a key-AH:scancode,AL:ASCII)
	           
	                    checkIfPrintable            currentChar, sendNotPrintable
	                    printCharAtLoc              currentChar, row_send, col_send
	                    getCursorAt_Row__col        row_send, col_send
	                    jmp                         sendIsDone
	;////////////////////////////////////
	;/// midLabel1
	getData_midLabel1:  jmp                         getData_midLabel2
	sendData_midLabel1: jmp                         sendData
	;/// to solve the jump out of range
	;////////////////////////////////////
	sendNotPrintable:   
	                    checkIfEnter                currentChar, sendNotEnter
	                    inc                         row_send                                                                          	; go to the next line
	                    mov                         col_send, topLeftX_upper                                                          	; start from column zero
	                    setCursorAt_Row_Col         row_send, col_send                                                                	; set the cursor to the new location
	;////////////////////////////////////
	sendNotEnter:       
	                    checkIfBackSpace            currentChar, sendNotBackSpace
	; if not start of a new line then, backspace
	                    cmp                         col_send, topLeftX_upper
	                    JNE                         backSpaceInSend                                                                   	; not a start of a line
	; it is a start of a new line
	; check if the first row then do nothing
	                    cmp                         row_send, topLeftY_upper
	                    JE                          sendNotBackSpace
	; if not the first row then, dec the row
	                    dec                         row_send
	                    mov                         col_send, topLeftX_upper + bottomRightX_upper +1                                  	; move it to the end of the last line
	checkForRowInSend:  
	;erase the previous character and update the cursor position
	backSpaceInSend:    dec                         col_send                                                                          	; start from column zero
	                    printCharAtLoc              ' ', row_send, col_send
	                    setCursorAt_Row_Col         row_send, col_send                                                                	; set the cursor to the new location
	;////////////////////////////////////
	sendNotBackSpace:   
	                    checkIfESC                  currentChar, sendNotESC
	                    port_sendChar               currentChar                                                                       	; if escape then, send it to the other user before closing the program
	                    jmp                         returnToMainApp
	sendNotESC:         
	; do nothing!
	;////////////////////////////////////
	sendIsDone:         port_sendChar               currentChar
	;////////////////////////////////////
	;/// midLabel2
	getData_midLabel2:  jmp                         getData
	sendData_midLabel2: jmp                         sendData_midLabel1
	;/// to solve the jump out of range
	;////////////////////////////////////
	;//////////////////////////////;////////////////////////////////////;////////////////////////////////////;////////////////////////////////////
	;Check that Data is Ready
	getData:            port_checkReceive           sendData_midLabel2                                                                	; Not Ready, can't get data then, go to send data
	;If Ready read the VALUE in Receive data register
	                    call                        checkForScrollLow
	                    port_getChar                currentChar
	                    checkIfPrintable            currentChar, recNotPrintable
	                    printCharAtLoc              currentChar, row_rec, col_rec
	                    getCursorAt_Row__col        row_rec, col_rec
	                    jmp                         recIsDone
	recNotPrintable:    
	                    checkIfEnter                currentChar, recNotEnter
	                    inc                         row_rec                                                                           	; go to the next line
	                    mov                         col_rec, topLeftX_lower                                                           	; start from column zero
	                    setCursorAt_Row_Col         row_rec, col_rec
	recNotEnter:        
	                    checkIfBackSpace            currentChar, recNotBackSpace
	; if not start of a new line then, backspace
	                    cmp                         col_rec, topLeftX_lower
	                    JNE                         backSpaceInRec                                                                    	; not a start of a line
	; it is a start of a new line
	; check if the first row then do nothing
	                    cmp                         row_rec, topLeftY_lower
	                    JE                          recNotBackSpace
	; if not the first row then, dec the row
	                    dec                         row_rec
	                    mov                         col_rec, topLeftX_lower + bottomRightX_lower +1                                   	; move it to the end of the last line
	checkForRowInRec:   
	;erase the previous character and update the cursor position
	backSpaceInRec:     dec                         col_rec                                                                           	; start from column zero
	                    printCharAtLoc              ' ', row_rec, col_rec
	                    setCursorAt_Row_Col         row_rec, col_rec                                                                  	; set the cursor to the new location
	;////////////////////////////////////
	recNotBackSpace:    
	                    checkIfESC                  currentChar, recNotESC
	                    jmp                         returnToMainApp
	recNotESC:          
	; do nothing!
	;////////////////////////////////////
	recIsDone:          getCursorAt_Row__col        row_rec, col_rec
	;////////////////////////////////////
	                    jmp                         startChat
	;//////////////////////////////
	returnToMainApp:    
	                    ret
CHATModule endp
checkForScrollUpper PROC
	; check for the row!
	                    cmp                         col_send, bottomRightX_upper
	                    JBE                          nothingInRowUp
	; go to the next line
	                    inc                         row_send                                                                           	; go to the next line
	                    mov                         col_send, topLeftX_upper                                                           	; start from column zero
	                    setCursorAt_Row_Col         row_send, col_send
	nothingInRowUp:    
	                    cmp                         row_send, bottomRightY_upper                                                      	; if it is the last row, then, scroll
	                    JB                          nothingInColUP
	                    scrollScreen                BF_upper, topLeftX_upper, topLeftY_upper, bottomRightX_upper, bottomRightY_upper-1
	;
	                    mov                         row_send, bottomRightY_upper -1                                                   	; go to the next line
	                    mov                         col_send, topLeftX_upper                                                          	; start from column zero
	                    setCursorAt_Row_Col         row_send, col_send                                                                	; set the cursor to the new location
	nothingInColUP:     
	                    ret
checkForScrollUpper ENDP
checkForScrollLow PROC
	; check for the row!
	                    cmp                         col_rec, bottomRightX_lower
	                    JBE                          nothingInRowLow
	; go to the next line
	                    inc                         row_rec                                                                           	; go to the next line
	                    mov                         col_rec, topLeftX_lower                                                           	; start from column zero
	                    setCursorAt_Row_Col         row_rec, col_rec
	nothingInRowLow:   
	                    cmp                         row_rec, bottomRightY_lower                                                       	; if it is the last row, then, scroll
	                    JB                          nothingInColLow
	                    scrollScreen                BF_lower, topLeftX_lower, topLeftY_lower, bottomRightX_lower, bottomRightY_lower-1
	;
	                    mov                         row_rec, bottomRightY_lower -1                                                    	; go to the next line
	                    mov                         col_rec, topLeftX_lower                                                           	; start from column zero
	                    setCursorAt_Row_Col         row_rec, col_rec                                                                  	; set the cursor to the new location
	nothingInColLow:    
	                    ret
checkForScrollLow	ENDP
END CHATModule