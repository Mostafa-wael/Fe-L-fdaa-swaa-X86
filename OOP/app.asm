EXTRN drawgamebtn:FAR
EXTRN drawchatbtn:FAR
EXTRN drawexitbtn:FAR
EXTRN drawlogo:FAR

.model COMPACT
.STACK 64
.data 
	graphicsMode equ 4F02h

.code
MAIN PROC FAR
	             mov  AX, @data
	             mov  DS, AX
mainMenuLoop:	 mov  ax, graphicsMode
	             mov  bx, 0100h
	             int  10h

				 call drawlogo
	             
				;  call drawexitbtn
	            ;  call drawgamebtn
	            ;  call drawchatbtn

	             mov  ah,4ch
	             int  21h

                        

MAIN ENDP

END MAIN