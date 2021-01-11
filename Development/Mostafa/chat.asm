PUBLIC CHATModule
PUBLIC inGameChat
EXTRN DrawMsgWithBox:FAR
.MODEL SMALL
.stack 64
;///////////////////////////////Macros////////////////////////////////////
include MACROS.inc
;///////////////////////////////Macros////////////////////////////////////
.data
	;////////////////////////////// Chat Module Parameters
	; you only need to edit those numbers to specify the cooardinates you want!
	M_BF_upper            equ 3Fh
	M_topLeftX_upper      equ 0
	M_topLeftY_upper      equ 0
	M_bottomRightX_upper  equ 79
	M_bottomRightY_upper  equ 11               	; less than M_topLeftY_lower by 2, to leave an empty line between them
	;
	M_BF_lower            equ 6Fh
	M_topLeftX_lower      equ 0
	M_topLeftY_lower      equ 13               	; more than M_bottomRightY_upper by 2,  to leave an empty line between them
	M_bottomRightX_lower  equ 79
	M_bottomRightY_lower  equ 24
	; we don't write in the last line to achive symmetry, if you want to delete the middle line,
	; edit M_bottomRightY_lower to 25 and M_bottomRightY_upper to 12
	;
	M_col_send            DB  M_topLeftX_upper
	M_row_send            DB  M_topLeftY_upper
	M_col_rec             DB  M_topLeftX_lower
	M_row_rec             DB  M_topLeftY_lower
	;
	;////////////////////////////// In-Game chat Parameters
	GC_BF_upper           equ 3Fh
	GC_topLeftX_upper     equ 14
	GC_topLeftY_upper     equ 2
	GC_bottomRightX_upper equ 65
	GC_bottomRightY_upper equ 3                	; less than M_topLeftY_lower by 2, to leave an empty line between them
	;
	GC_BF_lower           equ 6Fh
	GC_topLeftX_lower     equ 14
	GC_topLeftY_lower     equ 4                	; more than M_bottomRightY_upper by 2,  to leave an empty line between them
	GC_bottomRightX_lower equ 65
	GC_bottomRightY_lower equ 5
	; we don't write in the last line to achive symmetry, if you want to delete the middle line,
	; edit M_bottomRightY_lower to 25 and M_bottomRightY_upper to 12
	;
	GC_col_send           DB  GC_topLeftX_upper
	GC_row_send           DB  GC_topLeftY_upper
	GC_col_rec            DB  GC_topLeftX_lower
	GC_row_rec            DB  GC_topLeftY_lower
	;
	currentChar DB ?
.code
CHATModule PROC FAR
	                      mov                         AX, @data
	                      mov                         DS, AX
	                      clearWholeScreen_noGraphics
	                      initializaPort
	                      colorScreen                 M_BF_upper, M_topLeftX_upper, M_topLeftY_upper, M_bottomRightX_upper, M_bottomRightY_upper
	                      colorScreen                 M_BF_lower, M_topLeftX_lower, M_topLeftY_lower, M_bottomRightX_lower, M_bottomRightY_lower
	;//////////////////////////////
	startChat:            
	;//////////////////////////////
	;Check that Transmitter Holding Register is Empty
	sendData:             port_checkCanSend           getData_midLabel1                                                                              	; Not empty, can't send data then, go to get data
	;If empty put the VALUE in Transmit data register
	                      call                        M_checkForScrollUpper                                                                          	; cehck for the scrolling status

	                      checkIfInput                getData_midLabel1                                                                              	; if no key is pressed then, go to get data
	                      getCharASCII                currentChar                                                                                    	; Get key pressed (Wait for a key-AH:scancode,AL:ASCII)
	           
	                      checkIfPrintable            currentChar, sendNotPrintable
	                      printCharAtLoc              currentChar, M_row_send, M_col_send
	                      getCursorAt_Row__col        M_row_send, M_col_send
	                      jmp                         sendIsDone
	;////////////////////////////////////
	;/// midLabel1
	getData_midLabel1:    jmp                         getData_midLabel2
	sendData_midLabel1:   jmp                         sendData
	;/// to solve the jump out of range
	;////////////////////////////////////
	sendNotPrintable:     
	                      checkIfEnter                currentChar, sendNotEnter
	                      inc                         M_row_send                                                                                     	; go to the next line
	                      mov                         M_col_send, M_topLeftX_upper                                                                   	; start from column zero
	                      setCursorAt_Row_Col         M_row_send, M_col_send                                                                         	; set the cursor to the new location
	;////////////////////////////////////
	sendNotEnter:         
	                      checkIfBackSpace            currentChar, sendNotBackSpace
	; if not start of a new line then, backspace
	                      cmp                         M_col_send, M_topLeftX_upper
	                      JNE                         backSpaceInSend                                                                                	; not a start of a line
	; it is a start of a new line
	; check if the first row then do nothing
	                      cmp                         M_row_send, M_topLeftY_upper
	                      JE                          sendNotBackSpace
	; if not the first row then, dec the row
	                      dec                         M_row_send
	                      mov                         M_col_send, M_topLeftX_upper + M_bottomRightX_upper +1                                         	; move it to the end of the last line
	checkForRowInSend:    
	;erase the previous character and update the cursor position
	backSpaceInSend:      dec                         M_col_send                                                                                     	; start from column zero
	                      printCharAtLoc              ' ', M_row_send, M_col_send
	                      setCursorAt_Row_Col         M_row_send, M_col_send                                                                         	; set the cursor to the new location
	;////////////////////////////////////
	sendNotBackSpace:     
	                      checkIfESC                  currentChar, sendNotESC
	                      port_sendChar               currentChar                                                                                    	; if escape then, send it to the other user before closing the program
	                      jmp                         returnToMainApp
	sendNotESC:           
	; do nothing!
	;////////////////////////////////////
	sendIsDone:           port_sendChar               currentChar
	;////////////////////////////////////
	;/// midLabel2
	getData_midLabel2:    jmp                         getData
	sendData_midLabel2:   jmp                         sendData_midLabel1
	;/// to solve the jump out of range
	;////////////////////////////////////
	;//////////////////////////////;////////////////////////////////////;////////////////////////////////////;////////////////////////////////////
	;Check that Data is Ready
	getData:              port_checkReceive           sendData_midLabel2                                                                             	; Not Ready, can't get data then, go to send data
	;If Ready read the VALUE in Receive data register
	                      call                        M_checkForScrollLow
	                      port_getChar                currentChar
	                      checkIfPrintable            currentChar, recNotPrintable
	                      printCharAtLoc              currentChar, M_row_rec, M_col_rec
	                      getCursorAt_Row__col        M_row_rec, M_col_rec
	                      jmp                         recIsDone
	recNotPrintable:      
	                      checkIfEnter                currentChar, recNotEnter
	                      inc                         M_row_rec                                                                                      	; go to the next line
	                      mov                         M_col_rec, M_topLeftX_lower                                                                    	; start from column zero
	                      setCursorAt_Row_Col         M_row_rec, M_col_rec
	recNotEnter:          
	                      checkIfBackSpace            currentChar, recNotBackSpace
	; if not start of a new line then, backspace
	                      cmp                         M_col_rec, M_topLeftX_lower
	                      JNE                         backSpaceInRec                                                                                 	; not a start of a line
	; it is a start of a new line
	; check if the first row then do nothing
	                      cmp                         M_row_rec, M_topLeftY_lower
	                      JE                          recNotBackSpace
	; if not the first row then, dec the row
	                      dec                         M_row_rec
	                      mov                         M_col_rec, M_topLeftX_lower + M_bottomRightX_lower +1                                          	; move it to the end of the last line
	checkForRowInRec:     
	;erase the previous character and update the cursor position
	backSpaceInRec:       dec                         M_col_rec                                                                                      	; start from column zero
	                      printCharAtLoc              ' ', M_row_rec, M_col_rec
	                      setCursorAt_Row_Col         M_row_rec, M_col_rec                                                                           	; set the cursor to the new location
	;////////////////////////////////////
	recNotBackSpace:      
	                      checkIfESC                  currentChar, recNotESC
	                      jmp                         returnToMainApp
	recNotESC:            
	; do nothing!
	;////////////////////////////////////
	recIsDone:            getCursorAt_Row__col        M_row_rec, M_col_rec
	;////////////////////////////////////
	                      jmp                         startChat
	;//////////////////////////////
	returnToMainApp:      
	                      mov                         M_col_send , M_topLeftX_upper
	                      mov                         M_row_send , M_topLeftY_upper
	                      mov                         M_col_rec  , M_topLeftX_lower
	                      mov                         M_row_rec  , M_topLeftY_lower
	                      ret
CHATModule endp
M_checkForScrollUpper PROC
	; check for the row!
	                      cmp                         M_col_send, M_bottomRightX_upper
	                      JBE                         M_nothingInRowUp
	; go to the next line
	                      inc                         M_row_send                                                                                     	; go to the next line
	                      mov                         M_col_send, M_topLeftX_upper                                                                   	; start from column zero
	                      setCursorAt_Row_Col         M_row_send, M_col_send
	M_nothingInRowUp:     
	                      cmp                         M_row_send, M_bottomRightY_upper                                                               	; if it is the last row, then, scroll
	                      JB                          M_nothingInColUP
	                      scrollScreen_graphics       M_BF_upper, M_topLeftX_upper, M_topLeftY_upper, M_bottomRightX_upper, M_bottomRightY_upper-1
	;
	                      mov                         M_row_send, M_bottomRightY_upper -1                                                            	; go to the next line
	                      mov                         M_col_send, M_topLeftX_upper                                                                   	; start from column zero
	                      setCursorAt_Row_Col         M_row_send, M_col_send                                                                         	; set the cursor to the new location
	M_nothingInColUP:     
	                      ret
M_checkForScrollUpper ENDP
M_checkForScrollLow PROC
	; check for the row!
	                      cmp                         M_col_rec, M_bottomRightX_lower
	                      JBE                         M_nothingInRowLow
	; go to the next line
	                      inc                         M_row_rec                                                                                      	; go to the next line
	                      mov                         M_col_rec, M_topLeftX_lower                                                                    	; start from column zero
	                      setCursorAt_Row_Col         M_row_rec, M_col_rec
	M_nothingInRowLow:    
	                      cmp                         M_row_rec, M_bottomRightY_lower                                                                	; if it is the last row, then, scroll
	                      JB                          M_nothingInColLow
	                      scrollScreen_graphics       M_BF_lower, M_topLeftX_lower, M_topLeftY_lower, M_bottomRightX_lower, M_bottomRightY_lower-1
	;
	                      mov                         M_row_rec, M_bottomRightY_lower -1                                                             	; go to the next line
	                      mov                         M_col_rec, M_topLeftX_lower                                                                    	; start from column zero
	                      setCursorAt_Row_Col         M_row_rec, M_col_rec                                                                           	; set the cursor to the new location
	M_nothingInColLow:    
	                      ret
M_checkForScrollLow ENDP
	;//////////////////////////////;//////////////////////////////;//////////////////////////////;//////////////////////////////
inGameChat PROC NEAR
	                      mov                         AX, @data
	                      mov                         DS, AX
	; upper cursor
	                      mov                         GC_col_send, GC_topLeftX_upper
	                      mov                         GC_row_send, GC_topLeftY_upper
	                      setCursorAt_Row_Col         GC_row_send, GC_col_send
	                     
	;lower cursor
	                      mov                         GC_col_rec , GC_topLeftX_lower
	                      mov                         GC_row_rec , GC_topLeftY_lower
	                      setCursorAt_Row_Col         GC_row_rec, GC_col_rec
	; upper box
	;clearWholeScreen_noGraphics
	                      initializaPort
	                      colorScreen                 GC_BF_upper, GC_topLeftX_upper, GC_topLeftY_upper, GC_bottomRightX_upper, GC_bottomRightY_upper
	                      colorScreen                 GC_BF_lower, GC_topLeftX_lower, GC_topLeftY_lower, GC_bottomRightX_lower, GC_bottomRightY_lower

	;//////////////////////////////
	GC_startChat:         
	;//////////////////////////////
	;Check that Transmitter Holding Register is Empty
	GC_sendData:          port_checkCanSend           GC_getData_midLabel1                                                                           	; Not empty, can't send data then, go to get data
	;If empty put the VALUE in Transmit data register
	                      checkIfInput                GC_getData_midLabel1                                                                           	; if no key is pressed then, go to get data
	                      getCharASCII                currentChar                                                                                    	; Get key pressed (Wait for a key-AH:scancode,AL:ASCII)
	;\\\\\ check for scrolling
	                      cmp                         GC_col_send, GC_bottomRightX_upper
	                      JBE                         P_GC_nothingInRowUp
	                      mov                         bx, 3
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                      call                        DrawMsgWithBox
	                      mov                         GC_col_send, GC_topLeftX_upper                                                                 	; start from column zero
	                      setCursorAt_Row_Col         GC_row_send, GC_col_send
	;//////////////////////////////
	P_GC_nothingInRowUp:  
	           
	                      checkIfPrintable            currentChar, GC_sendNotPrintable
	                      printCharAtLoc              currentChar, GC_row_send, GC_col_send
	                      getCursorAt_Row__col        GC_row_send, GC_col_send
	                      jmp                         GC_sendIsDone
	;////////////////////////////////////
	;/// midLabel1
	GC_getData_midLabel1: jmp                         GC_getData_midLabel2
	GC_sendData_midLabel1:jmp                         GC_sendData
	;/// to solve the jump out of range
	;////////////////////////////////////
	GC_sendNotPrintable:  
	                      checkIfEnter                currentChar, GC_sendNotEnter
	                      mov                         bx, 3
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                      call                        DrawMsgWithBox
	                      mov                         GC_col_send, GC_topLeftX_upper                                                                 	; start from column zero
	                      mov                         GC_row_send, GC_topLeftY_upper
	                      setCursorAt_Row_Col         GC_row_send, GC_col_send                                                                       	; set the cursor to the new location
	;////////////////////////////////////
	GC_sendNotEnter:      
	                      checkIfBackSpace            currentChar, GC_sendNotBackSpace
	; if not start of a new line then, backspace
	                      cmp                         GC_col_send, GC_topLeftX_upper
	                      JNE                         GC_backSpaceInSend                                                                             	; not a start of a line
	; it is a start of a new line
	; check if the first row then, clear the box
	                      cmp                         GC_row_send, GC_topLeftY_upper
	                      mov                         bx, 3
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                      call                        DrawMsgWithBox
	                      setCursorAt_Row_Col         GC_row_send, GC_col_send                                                                       	; move it to the end of the last line
	                      jmp                         GC_sendNotBackSpace
	 
	;erase the previous character and update the cursor position
	GC_backSpaceInSend:   dec                         GC_col_send                                                                                    	; start from column zero
	                      printCharAtLoc              ' ', GC_row_send, GC_col_send
	                      setCursorAt_Row_Col         GC_row_send, GC_col_send                                                                       	; set the cursor to the new location
	;////////////////////////////////////
	GC_sendNotBackSpace:  
	                      checkIfESC                  currentChar, GC_sendNotESC
	                      port_sendChar               currentChar                                                                                    	; if escape then, send it to the other user before closing the program
	                      jmp                         GC_returnToMainApp
	GC_sendNotESC:        
	  
	; do nothing!
	;////////////////////////////////////
	GC_sendIsDone:        port_sendChar               currentChar
	;////////////////////////////////////
	;/// midLabel2
	GC_getData_midLabel2: jmp                         GC_getData
	GC_sendData_midLabel2:jmp                         GC_sendData_midLabel1
	;/// to solve the jump out of range
	;////////////////////////////////////
	;//////////////////////////////;////////////////////////////////////;////////////////////////////////////;////////////////////////////////////
	;Check that Data is Ready
	GC_getData:           port_checkReceive           GC_sendData_midLabel2                                                                          	; Not Ready, can't get data then, go to send data
	;If Ready read the VALUE in Receive data register
	                      port_getChar                currentChar
	;\\\\\ check for scrolling
	                      cmp                         GC_col_rec, GC_bottomRightX_lower
	                      JBE                         P_GC_nothingInRowLow
	                      mov                         bx, 0
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                      call                        DrawMsgWithBox
	                      mov                         GC_col_rec, GC_topLeftX_lower                                                                  	; start from column zero

	                      setCursorAt_Row_Col         GC_row_rec, GC_col_rec
	;//////////////////////////////
	P_GC_nothingInRowLow: 
	                      checkIfPrintable            currentChar, GC_recNotPrintable
	                      printCharAtLoc              currentChar, GC_row_rec, GC_col_rec
	                      getCursorAt_Row__col        GC_row_rec, GC_col_rec
	                      jmp                         GC_recIsDone
	GC_recNotPrintable:   
	                      checkIfEnter                currentChar, GC_recNotEnter
	                      mov                         bx, 0
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                      call                        DrawMsgWithBox
	                      mov                         GC_col_rec, GC_topLeftX_lower                                                                  	; start from column zero
	                      mov                         GC_row_rec, GC_topLeftY_lower
	                      setCursorAt_Row_Col         GC_row_rec, GC_col_rec
	GC_recNotEnter:       
	                      checkIfBackSpace            currentChar, GC_recNotBackSpace
	; if not start of a new line then, backspace
	                      cmp                         GC_col_rec, GC_topLeftX_lower
	                      JNE                         GC_backSpaceInrec                                                                              	; not a start of a line
	; it is a start of a new line
	; check if the first row then, clear the box
	                      cmp                         GC_row_rec, GC_topLeftY_lower
	                      mov                         bx, 0
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                      call                        DrawMsgWithBox
	                      setCursorAt_Row_Col         GC_row_rec, GC_col_rec                                                                         	; move it to the end of the last line
	                      jmp                         GC_recNotBackSpace
	 
	;erase the previous character and update the cursor position
	GC_backSpaceInrec:    dec                         GC_col_rec                                                                                     	; start from column zero
	                      printCharAtLoc              ' ', GC_row_rec, GC_col_rec
	                      setCursorAt_Row_Col         GC_row_rec, GC_col_rec                                                                         	; set the cursor to the new location
	;////////////////////////////////////
	GC_recNotBackSpace:   
	                      checkIfESC                  currentChar, GC_recNotESC
	                      jmp                         GC_returnToMainApp
	GC_recNotESC:         
	; do nothing!
	;////////////////////////////////////
	GC_recIsDone:         getCursorAt_Row__col        GC_row_rec, GC_col_rec
	;////////////////////////////////////
	                      jmp                         GC_startChat
	;//////////////////////////////
	GC_returnToMainApp:   
	                      call                        initializaChat_up_low
	                      ret
inGameChat ENDP
initializaChat_up_low PROC
	; upper cursor
	                      mov                         GC_col_send, GC_topLeftX_upper
	                      mov                         GC_row_send, GC_topLeftY_upper
	                      setCursorAt_Row_Col         GC_row_send, GC_col_send
	                     
	;lower cursor
	                      mov                         GC_col_rec , GC_topLeftX_lower
	                      mov                         GC_row_rec , GC_topLeftY_lower
	                      setCursorAt_Row_Col         GC_row_rec, GC_col_rec
	; upper box
	                      mov                         bx, 3
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                      call                        DrawMsgWithBox
	; lower box
	                      mov                         bx, 0
	; BX: 0 down character1, 1 down character2, 2 up character1, 3 up character2
	                      call                        DrawMsgWithBox
						  
	                      ret
	                      endp





END inGameChat