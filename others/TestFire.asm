;///////////////////////////////Macros////////////////////////////////////
.model huge
MOVEMENT MACRO UP, DOWN, LEFT, RIGHT, FIRE_BTN
	
	         mov cx, 0

	         cmp ah,UP
	         jz  MoveUp

	         cmp ah,DOWN
	         jz  MoveDown

	         cmp ah,LEFT
	         jz  MoveLeft

	         cmp ah,RIGHT
	         jz  MoveRight

	         cmp ah, FIRE_BTN
	         jz  Fire
ENDM
clearWholeScreen MACRO
	                 MOV AX,0600H	;06 TO SCROLL & 00 FOR FULL SCREEN
	                 MOV BH,00H  	;ATTRIBUTE BACKGROUND AND FOREGROUND
	                 MOV CX,0000H	;STARTING COORDINATES
	                 MOV DX,320  	;ENDING COORDINATES
	                 INT 10H     	;FOR VIDEO DISPLAY
	ENDM
;///////////////////////////////Macros////////////////////////////////////

;///////////////////////////////Data Initializations////////////////////////////////////
.data
	; constrains depend on the graphics mode
	graphicsMode    equ         4F02h
	offsetX         dw          6h                                                                                                                                                                            	;position of first from left pixel
	offsetY         dw          100                                                                                                                                                                           	;position of first from top pixel
	SizeX           equ         32                                                                                                                                                                            	;img Width
	SizeY           equ         32                                                                                                                                                                            	;img Height
	SizeC           equ         1024
	maxY            equ         360
	maxX            equ         320
	planeSpeed      equ         4
	minY            equ         80
	minX            equ         4                                                                                                                                                                             	;don't make this 0
	shipC           DB          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                DB          0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 77, 151
	                DB          77, 151, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 77, 151, 77, 151, 151, 19, 19, 19, 19, 0
	                DB          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 4, 4, 4, 19, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0
	                DB          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 4, 151, 151, 151, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19
	                DB          19, 19, 19, 19, 19, 19, 19, 19, 112, 4, 112, 151, 151, 151, 151, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 112
	                DB          0, 4, 0, 112, 151, 151, 151, 151, 151, 19, 42, 43, 0, 0, 0, 0, 0, 19, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 112, 4, 4, 4, 112, 112, 4, 112, 4
	                DB          40, 64, 42, 44, 44, 0, 0, 0, 0, 0, 19, 19, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 112, 0, 4, 0, 112, 151, 151, 151, 151, 4, 40, 19, 0, 0, 0, 0, 0
	                DB          0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 112, 4, 112, 151, 151, 151, 151, 151, 151, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                DB          0, 19, 19, 19, 19, 151, 151, 151, 151, 4, 151, 151, 77, 77, 77, 151, 77, 77, 77, 77, 19, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 77, 77, 77, 77, 77, 77, 151
	                DB          4, 4, 4, 151, 77, 100, 151, 77, 77, 151, 151, 19, 0, 0, 0, 0, 0, 19, 77, 77, 77, 100, 100, 100, 100, 100, 77, 100, 77, 100, 77, 151, 151, 151, 100, 151, 77, 77, 100, 151
	                DB          77, 77, 77, 77, 42, 66, 66, 0, 19, 77, 77, 100, 100, 47, 47, 47, 100, 100, 100, 100, 100, 77, 100, 77, 77, 77, 100, 77, 77, 77, 100, 77, 77, 77, 77, 77, 43, 44, 44, 44
	                DB          19, 77, 100, 47, 73, 73, 73, 73, 47, 100, 100, 100, 77, 100, 77, 100, 100, 100, 100, 151, 77, 77, 100, 151, 77, 77, 151, 19, 0, 0, 0, 0, 19, 77, 100, 47, 73, 73, 73, 73
	                DB          47, 100, 100, 100, 77, 100, 77, 100, 100, 100, 100, 151, 77, 77, 100, 151, 77, 77, 151, 19, 0, 0, 0, 0, 19, 77, 77, 100, 100, 47, 47, 47, 100, 100, 100, 100, 100, 77, 100, 77
	                DB          77, 77, 100, 77, 77, 77, 100, 77, 77, 77, 77, 77, 43, 44, 44, 44, 0, 19, 77, 77, 77, 100, 100, 100, 100, 100, 77, 100, 77, 100, 77, 151, 151, 151, 100, 151, 77, 77, 100, 151
	                DB          77, 77, 77, 77, 42, 66, 66, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 77, 77, 77, 77, 77, 77, 151, 4, 4, 4, 151, 77, 100, 151, 77, 77, 151, 151, 19, 0, 0, 0, 0
	                DB          0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 151, 151, 151, 151, 4, 151, 151, 77, 77, 77, 151, 77, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19
	                DB          19, 19, 19, 19, 19, 19, 19, 19, 112, 4, 112, 151, 151, 151, 151, 151, 151, 19, 19, 19, 0, 0, 0, 0, 0, 0, 19, 19, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 112
	                DB          0, 4, 0, 112, 151, 151, 151, 151, 4, 40, 19, 0, 0, 0, 0, 0, 0, 19, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 112, 4, 4, 4, 112, 112, 4, 112, 4
	                DB          40, 64, 42, 44, 44, 0, 0, 0, 0, 0, 19, 19, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 112, 0, 4, 0, 112, 151, 151, 151, 151, 151, 19, 42, 43, 0, 0, 0, 0
	                DB          0, 0, 0, 0, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 112, 4, 112, 151, 151, 151, 151, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                DB          0, 0, 0, 0, 0, 0, 0, 0, 19, 4, 151, 151, 151, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19
	                DB          4, 4, 4, 19, 77, 77, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 77, 151, 77, 151, 151, 19, 19, 19, 19, 0
	                DB          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 77, 151, 77, 151, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                DB          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 19, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	                DB          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	getName         DB          " Your name: $"
	enterValidName  DB          " Please, enter a valid name: $"
	playerName1     DB          21,?,21 dup("$")
	                firstScreen label byte
	                DB          '  ',0ah,0dh                                                                                                                                                                  	; new line
	                DB          '                                                          ||',0ah,0dh
	                DB          '   =======================================================||',0ah,0dh
	                DB          '      ||                                                  ||',0ah,0dh
	                DB          '      ||            #### FE L FDA SWAAA ####              ||',0ah,0dh
	                DB          '      ||                                                  ||',0ah,0dh
	                DB          '      ||--------------------------------------------------||',0ah,0dh
	                DB          '      ||                                                  ||',0ah,0dh
	                DB          '      ||            Please, Enter your name               ||',0ah,0dh
	                DB          '      ||       Then, press Enter to start the game        ||',0ah,0dh
	                DB          '      ||                                                  ||',0ah,0dh
	                DB          '      ||             ** MAX 21 CHARCHTERS **              ||',0ah,0dh
	                DB          '      ||                                                  ||',0ah,0dh
	                DB          '      || =======================================================',0ah,0dh
	                DB          '      ||                                                    ',0ah,0dh
	                DB          '$',0ah,0dh

	                mainMenu    label byte
	                DB          '  ',0ah,0dh                                                                                                                                                                  	; new line
	                DB          '                                                           ||',0ah,0dh
	                DB          '                                                           ||',0ah,0dh
	                DB          '                                                           ||',0ah,0dh
	                DB          '   ========================================================||',0ah,0dh
	                DB          '       ||                                                  ||',0ah,0dh
	                DB          '       ||            Press, F1 to beign chatting           ||',0ah,0dh
	                DB          '       ||            Press, F2 to start the game           ||',0ah,0dh
	                DB          '       ||            Press, ESC to exit the prgram         ||',0ah,0dh
	                DB          '       ||                                                  ||',0ah,0dh
	                DB          '       ||--------------------------------------------------||',0ah,0dh
	                DB          '       ||                     chat...                      ||',0ah,0dh
	                DB          '       || ========================================================',0ah,0dh
	                DB          '       ||                                                    ',0ah,0dh
	                DB          '       ||                                                    ',0ah,0dh
	                DB          '       ||                                                    ',0ah,0dh
	                DB          '$',0ah,0dh
	                byebye      label byte
	                DB          '  ',0ah,0dh
	                DB          '                                   ||',0ah,0dh
	                DB          '                                   ||',0ah,0dh
	                DB          '                                   ||',0ah,0dh
	                DB          '                                   ||',0ah,0dh
	                DB          '                                   ||',0ah,0dh
	                DB          '   ================================||',0ah,0dh
	                DB          '       ||           Bye Bye        ||',0ah,0dh
	                DB          '       || ================================',0ah,0dh
	                DB          '       ||                           ',0ah,0dh
	                DB          '       ||                           ',0ah,0dh
	                DB          '       ||                           ',0ah,0dh
	                DB          '       ||                           ',0ah,0dh
	                DB          '       ||                           ',0ah,0dh
	                DB          '$',0ah,0dh
				   
	; For Bullets
	Bullet          DB          0, 0, 0, 0, 0, 0, 43, 43, 43, 43, 43, 44, 44, 44, 44, 0, 68, 68, 68, 68
	BulletXSize     DB          5
	BulletYSize     DB          4
	BulletSpeed     DB          8
	BulletOffsetX   DW          ?
	BulletOffsetY   DW          ?
	BulletDirection DB          0                                                                                                                                                                             	; 0: Not Moving, 1: Right, 2: Left

;///////////////////////////////Data Initializations////////////////////////////////////
.code
MAIN PROC FAR
	                  mov              AX,@data               	;initializing the data segemnt
	                  mov              DS,AX
	firstScreenLoop:  
	                  mov              ax, graphicsMode       	; enter graphicsMode

	                  mov              ah,09h
	                  lea              dx, firstScreen        	; show the first screen
	                  int              21h

	                  mov              ah,09h
	                  lea              dx, getName            	; ask for player's name
	                  int              21h

	getNameLoop:      lea              si, playerName1        	; get player's name
	                  mov              ah, 0Ah
	                  mov              dx, si
	                  int              21h

	; TODO check of the name is valid
	; mov bp, offset playerName1 + 1
	; or           [bp], 0
	; jnz            mainMenuLoop

	; mov            ah,09h
	; lea            dx, enterValidName      	; ask for a valid player's name
	; int            21h
	; jmp            getNameLoop

	mainMenuLoop:     
	                  mov              ax, graphicsMode       	; enter graphicsMode to delete the screen

	                  mov              ah, 09h
	                  lea              dx, mainMenu           	; show the main menu
	                  int              21h

	CheckInMainMenu:  mov              ah,0                   	;  ah:al = scan code: ASCII code
	                  int              16h
	                  jz               CheckInMainMenu        	; check if there is any input

	                  cmp              ah,3Bh                 	; F1
	                  jz               firstScreenLoop

	                  cmp              ah,3ch                 	; F2
	                  jz               gameLoop

	                  cmp              al,1Bh                 	; ESC
	                  jz               exitProg
					
	                  jmp              CheckInMainMenu        	; not working yet

	gameLoop:                                                 	;NOTE:since we are using words, we will use the value '2' to traverse pixels
	;//////////////////////////////initializations////////////////////////////////////
	                  mov              ax, graphicsMode
	                  mov              bx, 0100h
	                  int              10h
	                  call             Drawship               	;this subroutine is responsible for drawing the ship using its cooardinates
	;//////////////////////////////Interacting with the user////////////////////////////////////
	CHECK:            mov              ah,1
	                  int              16h
	                  jz               CHECK                  	; check if there is any input
	                  CALL             GENERATE_OFFSET        	; TO GENERATE THE new OFFSET OF THE ship
	; ;///////////////////////////////////////////////////////////////////////////////////////
	                  jmp              gameLoop
	exitProg:         
	                  clearWholeScreen
	                  mov              ah,09h
	                  lea              dx, byebye             	; show the first screen
	                  int              21h
					
	                  HLT
	; mov            ah, 4ch                 	;stop execution
	; int            21h
MAIN ENDP

	;//////////////////////////////Procedures//////////////////////////////////////////////
GENERATE_OFFSET PROC near

	                  cmp              al,1Bh                 	; ESC
	                  jz               exitProg
	                  call             Eraseship              	; get the pressed key from the user
	                  MOVEMENT         11H, 1FH, 1EH, 20H, 21H


	ReadKey:          
	;call             Drawship

	                  mov              ah,0                   	;wait for a key to be pressed and put it in ah, ah:al = scan code: ASCII code
	                  int              16h

	                  mov              cx, 0                  	; initialize cx to use it to iterate over the shipSize
	                  jmp              CHECK
	;///////////////////////////////////////////////////////////////////////////////////////
	MoveUp:           
	                  mov              bx, offsetY
	                  cmp              bx, minY
	                  jna              DrawShipCalling
	                  sub              bx, planeSpeed
	                  mov              DI, offset offsetY
	                  mov              [DI], bx
	                  jmp              DrawShipCalling
	MoveDown:         
	                  mov              bx, offsetY
	                  mov              cx, bx
	                  add              cx, sizeY
	                  cmp              cx, maxY
	                  jnb              DrawShipCalling
	                  add              bx,planeSpeed
	                  mov              DI, offset offsetY
	                  mov              [DI], bx
	                  jmp              DrawShipCalling

	MoveLeft:         
	                  mov              bx, offsetX
	                  cmp              bx, minX
	                  jna              DrawShipCalling
	                  sub              bx, planeSpeed
	                  mov              DI, offset offsetX
	                  mov              [DI], bx
	          
	                  jmp              DrawShipCalling

	MoveRight:        
	;checking for boundaries
	                  mov              bx, offsetX
	                  mov              cx, bx
	                  add              cx, sizeX
	                  cmp              cx, maxX
	                  jnb              DrawShipCalling
	                  add              bx, planeSpeed
	                  mov              DI, offset offsetX
	                  mov              [DI], bx

	                  jmp              DrawShipCalling

	DrawShipCalling:  
	                  call             Drawship
	                  jmp              ReadKey
	Fire:             
	                  mov              dl, 1
	                  mov              BulletDirection, dl    	; For Right Direction
	; For x
                    
	                  mov              dX, offsetX
	                  add              DX, sizeX
	                  INC              DX
	                  MOV              BulletOffsetX, DX
                
	; For y

	                  mov              dx, 0
	                  mov              dl, BulletYSize
	                  add              dx, sizeY

	; These steps for division
	; First push ax to stack as we need it after that
	                  push             ax

	; Divsion Process
	                  mov              ax, dx
	                  mov              dx, 2
	                  div              dx
	                  mov              dx, ax

	; retrive the value of reg x
	                  pop              ax
	                  add              dx, offsetY

	                  mov              BulletOffsetY, dx

	                  jmp              DrawBulletCalling
	DrawBulletCalling:
	                  call             DrawBullet
	                  jmp              ReadKey

	                  ret

GENERATE_OFFSET ENDP

	;--------------------------------------------------------------------------------------------------------------------------

Drawship PROC	near
	; initialize containers
	                  mov              SI, offset shipC
	                  mov              cx, SizeX              	;Column X
	                  mov              dx, SizeY              	;Row Y
	                  mov              ah, 0ch                	;Draw Pixel Command
	Drawit:           
	                  mov              bl, [SI]               	;use color from array color for testing
	                  and              bl, bl
	                  JZ               back
	                  add              cx, offsetX
	                  add              dx, offsety
	                  mov              al, [SI]               	;  use color from array color for testing
	                  int              10h                    	;  draw the pixel
	                  sub              cx, offsetX
	                  sub              dx, offsety

	back:             
	                  inc              SI
	                  DEC              Cx                     	;  loop iteration in x direction
	                  JNZ              Drawit                 	;  check if we can draw c urrent x and y and excape the y iteration
	                  mov              Cx, SizeX              	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                  DEC              DX                     	;  loop iteration in y direction
	                  JZ               alldrawn               	;  both x and y reached 00 so finish drawing
	                  jmp              Drawit
	alldrawn:         ret
Drawship ENDP


Eraseship PROC near
	; initialize containers
	                  mov              SI, offset shipC       	;shipY is (shipX index + size * 2) so we can use Si for both
	                  mov              cx, SizeX              	;Column X
	                  mov              dx, SizeY              	;Row Y
	                  push             ax
	                  mov              ah, 0ch                	;Draw Pixel Command
	                  mov              al, 0h                 	;to be replaced with background
	
	Drawit2:          
	                  mov              bl, [SI]               	;  use color from array color for testing
	                  and              bl, bl
	                  JZ               back2
	                  add              cx, offsetX
	                  add              dx, offsety
	                  int              10h                    	;  draw the pixel
	                  sub              cx, offsetX
	                  sub              dx, offsety

	back2:            
	                  inc              SI
	                  DEC              Cx                     	;  loop iteration in x direction
	                  JNZ              Drawit2                	;  check if we can draw c urrent x and y and excape the y iteration
	                  mov              Cx, SizeX              	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                  DEC              DX                     	;  loop iteration in y direction
	                  JZ               alldrawn2              	;  both x and y reached 00 so finish drawing
	                  jmp              Drawit2
	alldrawn2:        pop              ax
	                  ret
Eraseship ENDP

DrawBullet PROC near
	; initialize containers
	                  mov              SI, offset Bullet
	                  mov              cx, 0
	                  mov              dx, 0
	                  mov              cl, BulletXSize        	;Column X
	                  mov              dl, BulletySize        	;Row Y
	                  mov              ah, 0ch                	;Draw Pixel Command
	DrawitBullet:     
	                  mov              bl, [SI]               	;use color from array color for testing
	                  and              bl, bl
	                  JZ               backBullet
	                  add              cx, BulletOffsetX
	                  add              dx, BulletOffsetY
	                  mov              al, [SI]               	;  use color from array color for testing
	                  int              10h                    	;  draw the pixel
	                  sub              cx, BulletOffsetX
	                  sub              dx, BulletOffsetY

	backBullet:       
	                  inc              SI
	                  DEC              cl                     	;  loop iteration in x direction
	                  JNZ              DrawitBullet           	;  check if we can draw c urrent x and y and excape the y iteration
	                  mov              cl, BulletXSize        	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                  DEC              dl                     	;  loop iteration in y direction
	                  JZ               alldrawnBullet         	;  both x and y reached 00 so finish drawing
	                  jmp              DrawitBullet
	alldrawnBullet:   ret
DrawBullet ENDP


EraseBullet PROC near
	; initialize containers
	                  mov              SI, offset Bullet      	;shipY is (shipX index + size * 2) so we can use Si for both
	                  mov              cx, 0
	                  mov              dx, 0
	                  mov              cl, BulletXSize        	;Column X
	                  mov              dl, BulletYSize        	;Row Y
	                  push             ax
	                  mov              ah, 0ch                	;Draw Pixel Command
	                  mov              al, 0h                 	;to be replaced with background
	
	Drawit2Bullet:    
	                  mov              bl, [SI]               	;  use color from array color for testing
	                  and              bl, bl
	                  JZ               back2Bullet
	                  add              cx, BulletOffsetX
	                  add              dx, BulletOffsetY
	                  int              10h                    	;  draw the pixel
	                  sub              cx, BulletOffsetX
	                  sub              dx, BulletOffsetY

	back2Bullet:      
	                  inc              SI
	                  DEC              cl                     	;  loop iteration in x direction
	                  JNZ              Drawit2Bullet          	;  check if we can draw c urrent x and y and excape the y iteration
	                  mov              cl, BulletXSize        	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	                  DEC              dl                     	;  loop iteration in y direction
	                  JZ               alldrawn2Bullet        	;  both x and y reached 00 so finish drawing
	                  jmp              Drawit2Bullet
	alldrawn2Bullet:  
	                  pop              ax
	                  ret
EraseBullet ENDP


;//////////////////////////////Procedures//////////////////////////////////////////////
        END MAIN
		
@comment
		TODO:
		1. new features:
		1.1. reading images -> hossam
		1.2. bounding box -> yahya
		1.3. second player -> gimy

		2. error handling -> mostafa
		2.1. null names
		2.2. F1, F2
		2.3. clear screen
		@