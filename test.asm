.model small
;///////////////////////////////Data Initializations////////////////////////////////////
.data
	testColor  equ 0fh
	
	paddleSize equ 100                    	;paddle's size, the paddle consists of n-pixels where, n = paddleSize
	originX    equ 10
	originY    equ 10
	originC    equ 0fh

	paddleX    DW  paddleSize dup(originX)	;the initial x-coardinates of the pixels
	paddleY    DW  paddleSize dup(originY)	;the initialy-coardinates of the pixels
	paddleC    DB  paddleSize dup(originC)	;the initial color of the pixels

	minX       equ 0h
	minY       equ 0h
	maxX       equ 318
	maxY       equ 198
;///////////////////////////////Data Initializations////////////////////////////////////
.code
	;NOTE:since we are using words, we will use the value '2' to traverse pixels
MAIN PROC FAR
	           mov  AX,@data             	;initializing the data segemnt
	           mov  DS,AX

	           mov  ah,0                 	;entering the graphics mode 320*200
	           mov  al,13h
	           int  10h
	;//////////////////////////////initializing the paddle////////////////////////////////////
	; responsiple for drawing the initial position of the paddle
	           mov  CX,0
	           mov  BX,0
	fill:                                	;as all pixels have the same x & y cooardinates, this loop is responsible for giving each pixel its right coardinates
	           add  paddleY[BX],CX
	           add  BX,2
	           inc  cx
	           cmp  cx,paddleSize-1
	           jnz  fill

	           call Drawpaddle           	;this subroutine is responsible for drawing the paddle using its cooardinates
	;//////////////////////////////Interacting with the user////////////////////////////////////
	CHECK:     mov  ah,1
	           int  16h
	           jz   CHECK                	; check if there is any input

	           mov  SI,offset paddleX    	; the top of the paddle
	           mov  DI,offset paddleY    	; the bottom of the paddle
	           mov  cx, 0

	           cmp  ah,72
	           jz   MoveUp

	           cmp  ah,80
	           jz   MoveDown

	           cmp  ah,75
	           jz   MoveLeft

	           cmp  ah,77
	           jz   MoveRight

	ReadKey:                             	; get the pressed key from the user
	           mov  ah,0                 	;wait for a key to be pressed and put it in ah, ah:al = scan code: ASCII code
	           int  16h

	           mov  cx, 0                	; initialize cx to use it to iterate over the paddleSize
	           call Drawpaddle
	           jmp  CHECK
	;///////////////////////////////////////////////////////////////////////////////////////
	MoveUp:    
	;checking for boundaries
	           mov  BX,[DI]
	           cmp  BX, minY
	           jz   ReadKey
	;moveUP
	           inc  cx
	           mov  BX,[DI]
	           dec  BX                   	;decrement y, we can use SUB [DI], 2h but it's not compatabile with other versions of assembelers
	           mov  [DI],BX

	           add  DI, 2
	           cmp  cx,paddleSize        	; do this for all the pixels of the paddle
	           jnz  MoveUp

	           jmp  ReadKey

	MoveDown:  
	;checking for boundaries
	           mov  BX,[DI + paddleSize*2 - 4]; as we want to check for the bottom of the paddle
	           cmp  BX, maxY
	           jz   ReadKey
	;MoveDown
	           inc  cx
	           mov  BX,[DI]
	           inc  BX                   	;increment y
	           mov  [DI],BX

	           add  DI, 2
	           cmp  cx,paddleSize        	;do this for all the pixels of the paddle
	           jnz  MoveDown

	           jmp  ReadKey

	MoveLeft:  
	;checking for boundaries
	           mov  BX,[SI]
	           cmp  BX, minX
	           jz   ReadKey
	;MoveLeft
	           inc  cx
	           mov  BX,[SI]
	           dec  BX                   	;decrement x
	           mov  [SI],BX

	           add  SI, 2
	           cmp  cx,paddleSize        	;do this for all the pixels of the paddle
	           jnz  MoveLeft
	          
	           jmp  ReadKey

	MoveRight: 
	;checking for boundaries
	           mov  BX,[SI]
	           cmp  BX, maxX
	           jz   ReadKey
	;MoveRight
	           inc  cx
	           mov  BX,[SI]
	           inc  BX                   	;increment x
	           mov  [SI],BX

	           add  SI, 2
	           cmp  cx,paddleSize        	;do this for all the pixels of the paddle
	           jnz  MoveRight

	           jmp  ReadKey
	;///////////////////////////////////////////////////////////////////////////////////////

	           HLT
MAIN ENDP
	;//////////////////////////////Procedures////////////////////////////////////
Drawpaddle PROC

	           mov  ah,0                 	;entering the graphics mode, to clear screen
	           mov  al,13h
	           int  10h
	; initialize containers
	           mov  SI, offset paddleX
	           mov  DI, offset paddleY
	           mov  bp, offset paddleC
	           mov  Bl,paddleSize

	           mov  ah,0ch               	;Draw Pixel Command
	back:      
	;mov  al,[bp]           	;Pixel color
	           mov  al, 0fh              	; use white color for testing
	           mov  cx,[SI]              	;Column
	           mov  dx,[DI]              	;Row
	           int  10h                  	;draw the pixel
	           add  SI,2                 	;move to the next paddleX
	           add  DI,2                 	;move to the next paddleY
	           dec  bl
	;add  bp, 1 ;adding differnet colors to each pixel
	           jnz  back                 	;loop over the paddle size
	           ret
Drawpaddle ENDP
;///////////////////////////////////////////////////////////////////////////////////////
        END MAIN
