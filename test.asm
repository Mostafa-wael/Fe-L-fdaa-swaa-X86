.model small
.data
	Color    equ 0fh
	SnakSize equ 100                  	;snake's size, the snake consists of snakeSize pixels
	originX  equ 10
	originY  equ 10
	originC  equ 0h
	snakeX   DW  SnakSize dup(originX)	;the initial x-coardinates of the pixels
	snakeY   DW  SnakSize dup(originY)	;the initialy-coardinates of the pixels
	snakeC   DB  SnakSize dup(originC)  ;the initial color of the pixels 
    ;since we are using words, we will use the value '2' to traverse pixels
.code
MAIN PROC FAR
	          mov  AX,@data         	;initializing the data segemnt
	          mov  DS,AX

	          mov  ah,0             	;entering the graphics mode
	          mov  al,13h
	          int  10h

	          mov  CX,0
	          mov  BX,0

	fill:                           	;as all pixels have the same x & y cooardinates, this loop is responsible for giving each pixel its right coardinates
	          add  snakeY[BX],CX
	          add  BX,2
	          inc  cx
	          cmp  cx,SnakSize-1
	          jnz  fill

	;this subroutine is responsible for drawing the snake using its cooardinates
	          call DrawSnak
	;///////////////////////Interacting with the user////////////////////////////////////
	CHECK:    mov  ah,1
	          int  16h
	          jz   CHECK

	          mov  SI,offset snakeX
	          mov  DI,offset snakeY
	          mov  cx, 0

	          cmp  ah,72
	          jz   MoveUp

	          cmp  ah,80
	          jz   MoveDown

	          cmp  ah,75
	          jz   MoveLeft

	          cmp  ah,77
	          jz   MoveRight

	ReadKey:  
	          mov  ah,0
	          mov  cx, 0
	          int  16h
	          call DrawSnak
	          jmp  CHECK

	MoveUp:   
	          inc  cx
	          mov  BX,[DI]          	;decrement y
	          dec  BX
	          mov  [DI],BX
	          add  DI, 2
	          cmp  cx,SnakSize
	          jnz  MoveUp

	          jmp  ReadKey

	MoveDown: 
	          inc  cx
	          mov  BX,[DI]          	;increment y
	          inc  BX
	          mov  [DI],BX
	          add  DI, 2
	          cmp  cx,SnakSize
	          jnz  MoveDown

	          jmp  ReadKey

	MoveLeft: 
	          inc  cx
	          mov  BX,[SI]          	;decrement x
	          dec  BX
	          mov  [SI],BX
	          add  SI, 2
	          cmp  cx,SnakSize
	          jnz  MoveLeft
	          
	          jmp  ReadKey

	MoveRight:
	          inc  cx
	          mov  BX,[SI]          	;increment x
	          inc  BX
	          mov  [SI],BX
	          add  SI, 2
	          cmp  cx,SnakSize
	          jnz  MoveRight

	          jmp  ReadKey
	;/////////////////////////////////////////////////////////////////////////////////////////

 

	          HLT
MAIN ENDP

DrawSnak PROC

	          mov  ah,0             	;entering the graphics mode, to clear screen
	          mov  al,13h
	          int  10h

	          mov  SI,offset snakeX
	          mov  DI,offset snakeY
	          mov  Bl,SnakSize
	          mov  bp, offset snakeC


	          mov  ah,0ch           	;Draw Pixel Command
	back:     
	          mov  al,[bp]          	;Pixel color
	          mov  cx,[SI]          	;Column
	          mov  dx,[DI]          	;Row
	          int  10h
	          add  SI,2
	          add  DI,2
	;add  bp, 1
	          dec  bl
	          jnz  back
	          ret
DrawSnak ENDP
 
        END MAIN
