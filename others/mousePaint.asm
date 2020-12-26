.MODEL SMALL
.code
MAIN PROC FAR
	
	checkMouse:mov  ax, 0     	;check if the mouse is attached
	           int  33h       	; if attached, ax = 0ffffh
	           jz   checkMouse

	           mov  ax, 4F02h 	; graphics mode
	           int  10h

	           mov  ax, 1     	;shows mouse cursor
	           int  33h
	Next:      
	           mov  ax, 3     	;get cursor positon in cx,dx and status in bx
	           int  33h

	           cmp  bx, 0h    	; if bx = 0
	           jz   Next      	; do nothing
            ;    mov ah, 03
            ;    mov bh, 0h ;
            ;    int 10h
	           call drawPixel 	;call procedure
	           jmp  Next

	           mov  ah,4ch
	           int  21h
main endp

drawPixel proc
	           mov  al, 7     	;color of pixel
	           mov  bh, 0     	; page number
	           mov  ah, 0ch   	; draw pixel at cx, dx and page bh
	           shL  dx,1      	
	           int  10h       	; set pixel.
	           ret
drawPixel endp
END MAIN