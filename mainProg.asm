;///////////////////////////////Macros////////////////////////////////////
MOVEMENT MACRO UP, DOWN, LEFT, RIGHT
	
	         mov SI,offset shipX	; the top of the ship
	         mov DI,offset shipY	; the bottom of the ship
	         mov cx, 0

	         cmp ah,UP
	         jz  MoveUp

	         cmp ah,DOWN
	         jz  MoveDown

	         cmp ah,LEFT
	         jz  MoveLeft

	         cmp ah,RIGHT
	         jz  MoveRight
ENDM
ERASE_MOVEMENT MACRO UP, DOWN, LEFT, RIGHT
	               mov cx,[SI]  	;Column X
	               mov dx,[DI]
	               cmp ah,UP
	               jz  BackUp
	
	               cmp ah,DOWN
	               jz  BackDown

	               cmp ah,LEFT
	               jz  BackLeft

	               cmp ah,RIGHT
	               jz  BackRight
	
ENDM
clearWholeScreen MACRO
	                 MOV AX,0600H	;06 TO SCROLL & 00 FOR FULL SCREEN
	                 MOV BH,00H  	;ATTRIBUTE BACKGROUND AND FOREGROUND
	                 MOV CX,0000H	;STARTING COORDINATES
	                 MOV DX,320  	;ENDING COORDINATES
	                 INT 10H     	;FOR VIDEO DISPLAY
	                
	ENDM
;///////////////////////////////Macros////////////////////////////////////
.model small
;///////////////////////////////Data Initializations////////////////////////////////////
.data
	; constrains depend on the graphics mode
	graphicsMode   equ         0013h
	minX           equ         0h
	minY           equ         0h
	maxX           equ         318
	maxY           equ         198
	;Comment @
	shipSize       equ         0556h                                                                                                                 	;ship's size, the ship consists of n-pixels where, n = shipSize
	shipX          DW          05h, 06h, 06h, 07h, 08h, 07h, 08h, 09h, 0ah, 08h, 09h, 0ah, 0bh, 09h, 0ah, 0bh, 0ch, 0ah, 0bh, 0ch
	               DW          0dh, 0eh, 0bh, 0ch, 0dh, 0eh, 0fh, 0ch, 0dh, 0eh, 0fh, 010h, 09h, 0ah, 0dh, 0eh, 0fh, 010h, 011h, 0ah
	               DW          0bh, 0ch, 0dh, 0eh, 0fh, 010h, 011h, 012h, 013h, 0bh, 0ch, 0dh, 0eh, 0fh, 010h, 011h, 012h, 013h, 014h, 0dh
	               DW          0eh, 0fh, 010h, 011h, 012h, 013h, 014h, 015h, 0eh, 0fh, 010h, 011h, 012h, 013h, 014h, 015h, 016h, 0bh, 010h, 011h
	               DW          012h, 013h, 014h, 015h, 016h, 017h, 018h, 0bh, 0ch, 0dh, 0eh, 011h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h
	               DW          0dh, 0eh, 0fh, 010h, 011h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 0fh, 010h, 011h, 012h, 013h, 014h
	               DW          015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 011h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh
	               DW          013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch
	               DW          01dh, 01eh, 01fh, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 015h, 016h
	               DW          017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh
	               DW          01fh, 020h, 021h, 022h, 023h, 0fh, 010h, 011h, 012h, 013h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h
	               DW          021h, 022h, 023h, 024h, 010h, 011h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh
	               DW          020h, 021h, 022h, 023h, 024h, 025h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h
	               DW          021h, 022h, 023h, 024h, 025h, 026h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h
	               DW          023h, 024h, 025h, 026h, 027h, 028h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h
	               DW          025h, 026h, 027h, 028h, 029h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h
	               DW          027h, 028h, 029h, 02ah, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h
	               DW          029h, 02ah, 02bh, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h
	               DW          025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h
	               DW          023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h
	               DW          022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 01bh, 01ch, 01dh, 01eh, 01fh, 020h
	               DW          021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 01dh, 01eh, 01fh, 020h
	               DW          021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 020h, 021h, 022h
	               DW          023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 01dh, 01eh, 01fh, 020h
	               DW          021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 01ah
	               DW          01bh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h
	               DW          032h, 033h, 034h, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch
	               DW          02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 034h, 035h, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h
	               DW          029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 034h, 035h, 036h, 020h, 021h, 022h, 023h, 024h, 025h
	               DW          026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 034h, 035h, 036h, 037h, 022h, 023h
	               DW          024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 034h, 035h, 036h, 037h
	               DW          038h, 039h, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh
	               DW          02fh, 030h, 031h, 032h, 033h, 034h, 035h, 036h, 037h, 038h, 039h, 03ah, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h
	               DW          022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 034h, 035h
	               DW          036h, 037h, 038h, 039h, 03ah, 03bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h
	               DW          02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 034h, 035h, 036h, 037h, 038h, 039h, 03ah, 01dh, 01eh, 01fh
	               DW          020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h
	               DW          034h, 035h, 036h, 037h, 038h, 039h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh
	               DW          030h, 031h, 032h, 033h, 034h, 035h, 036h, 037h, 038h, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah
	               DW          02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 034h, 035h, 036h, 037h, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h
	               DW          025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 034h, 035h, 036h, 01ch, 01dh
	               DW          01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h
	               DW          032h, 033h, 034h, 035h, 01ah, 01bh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch
	               DW          02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 034h, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h
	               DW          029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 033h, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h
	               DW          029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 032h, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h
	               DW          027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 031h, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h
	               DW          024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 030h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h
	               DW          021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 02fh, 018h, 019h, 01ah, 01bh, 01ch
	               DW          01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h, 02ah, 02bh, 02ch, 02dh, 02eh, 014h, 015h
	               DW          016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h, 029h
	               DW          02ah, 02bh, 02ch, 02dh, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h
	               DW          029h, 02ah, 02bh, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h
	               DW          029h, 02ah, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h, 028h
	               DW          029h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h
	               DW          028h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 024h, 025h
	               DW          026h, 010h, 011h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h
	               DW          023h, 024h, 025h, 0fh, 010h, 011h, 012h, 013h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h
	               DW          023h, 024h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 022h, 023h, 015h, 016h, 017h, 018h
	               DW          019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 020h, 021h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch
	               DW          01dh, 01eh, 01fh, 020h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 01fh, 013h, 014h, 015h, 016h, 017h
	               DW          018h, 019h, 01ah, 01bh, 01ch, 01dh, 01eh, 011h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 01ch, 01dh
	               DW          0fh, 010h, 011h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h, 01ah, 01bh, 0dh, 0eh, 0fh, 010h, 011h, 012h, 013h
	               DW          014h, 015h, 016h, 017h, 018h, 019h, 01ah, 0bh, 0ch, 0dh, 0eh, 011h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 019h
	               DW          0bh, 010h, 011h, 012h, 013h, 014h, 015h, 016h, 017h, 018h, 0eh, 0fh, 010h, 011h, 012h, 013h, 014h, 015h, 016h, 0dh
	               DW          0eh, 0fh, 010h, 011h, 012h, 013h, 014h, 015h, 0bh, 0ch, 0dh, 0eh, 0fh, 010h, 011h, 012h, 013h, 014h, 0ah, 0bh
	               DW          0ch, 0dh, 0eh, 0fh, 010h, 011h, 012h, 013h, 09h, 0ah, 0dh, 0eh, 0fh, 010h, 011h, 0ch, 0dh, 0eh, 0fh, 010h
	               DW          0bh, 0ch, 0dh, 0eh, 0fh, 0ah, 0bh, 0ch, 0dh, 0eh, 09h, 0ah, 0bh, 0ch, 08h, 09h, 0ah, 0bh, 07h, 08h
	               DW          09h, 06h, 07h, 08h, 05h, 06h
	shipY          DW          014h, 014h, 015h, 015h, 015h, 016h, 016h, 016h, 016h, 017h, 017h, 017h, 017h, 018h, 018h, 018h, 018h, 019h, 019h, 019h
	               DW          019h, 019h, 01ah, 01ah, 01ah, 01ah, 01ah, 01bh, 01bh, 01bh, 01bh, 01bh, 01ch, 01ch, 01ch, 01ch, 01ch, 01ch, 01ch, 01dh
	               DW          01dh, 01dh, 01dh, 01dh, 01dh, 01dh, 01dh, 01dh, 01dh, 01eh, 01eh, 01eh, 01eh, 01eh, 01eh, 01eh, 01eh, 01eh, 01eh, 01fh
	               DW          01fh, 01fh, 01fh, 01fh, 01fh, 01fh, 01fh, 01fh, 020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h, 021h, 021h, 021h
	               DW          021h, 021h, 021h, 021h, 021h, 021h, 021h, 022h, 022h, 022h, 022h, 022h, 022h, 022h, 022h, 022h, 022h, 022h, 022h, 022h
	               DW          023h, 023h, 023h, 023h, 023h, 023h, 023h, 023h, 023h, 023h, 023h, 023h, 023h, 023h, 024h, 024h, 024h, 024h, 024h, 024h
	               DW          024h, 024h, 024h, 024h, 024h, 024h, 024h, 025h, 025h, 025h, 025h, 025h, 025h, 025h, 025h, 025h, 025h, 025h, 025h, 025h
	               DW          026h, 026h, 026h, 026h, 026h, 026h, 026h, 026h, 026h, 026h, 026h, 026h, 027h, 027h, 027h, 027h, 027h, 027h, 027h, 027h
	               DW          027h, 027h, 027h, 028h, 028h, 028h, 028h, 028h, 028h, 028h, 028h, 028h, 028h, 028h, 028h, 028h, 028h, 028h, 029h, 029h
	               DW          029h, 029h, 029h, 029h, 029h, 029h, 029h, 029h, 029h, 029h, 029h, 02ah, 02ah, 02ah, 02ah, 02ah, 02ah, 02ah, 02ah, 02ah
	               DW          02ah, 02ah, 02ah, 02ah, 02ah, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh, 02bh
	               DW          02bh, 02bh, 02bh, 02bh, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02ch
	               DW          02ch, 02ch, 02ch, 02ch, 02ch, 02ch, 02dh, 02dh, 02dh, 02dh, 02dh, 02dh, 02dh, 02dh, 02dh, 02dh, 02dh, 02dh, 02dh, 02dh
	               DW          02dh, 02dh, 02dh, 02dh, 02dh, 02dh, 02eh, 02eh, 02eh, 02eh, 02eh, 02eh, 02eh, 02eh, 02eh, 02eh, 02eh, 02eh, 02eh, 02eh
	               DW          02eh, 02eh, 02eh, 02eh, 02eh, 02eh, 02fh, 02fh, 02fh, 02fh, 02fh, 02fh, 02fh, 02fh, 02fh, 02fh, 02fh, 02fh, 02fh, 02fh
	               DW          02fh, 02fh, 02fh, 02fh, 02fh, 030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
	               DW          030h, 030h, 030h, 030h, 031h, 031h, 031h, 031h, 031h, 031h, 031h, 031h, 031h, 031h, 031h, 031h, 031h, 031h, 031h, 031h
	               DW          031h, 031h, 031h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h
	               DW          032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 032h, 033h, 033h, 033h, 033h, 033h, 033h, 033h, 033h, 033h, 033h, 033h
	               DW          033h, 033h, 033h, 033h, 033h, 033h, 033h, 033h, 033h, 033h, 033h, 033h, 034h, 034h, 034h, 034h, 034h, 034h, 034h, 034h
	               DW          034h, 034h, 034h, 034h, 034h, 034h, 034h, 034h, 034h, 034h, 034h, 034h, 034h, 034h, 035h, 035h, 035h, 035h, 035h, 035h
	               DW          035h, 035h, 035h, 035h, 035h, 035h, 035h, 035h, 035h, 035h, 035h, 035h, 035h, 035h, 035h, 035h, 036h, 036h, 036h, 036h
	               DW          036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 036h, 037h, 037h, 037h
	               DW          037h, 037h, 037h, 037h, 037h, 037h, 037h, 037h, 037h, 037h, 037h, 037h, 037h, 037h, 037h, 037h, 038h, 038h, 038h, 038h
	               DW          038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 038h, 039h
	               DW          039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h, 039h
	               DW          039h, 039h, 039h, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah
	               DW          03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03ah, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh
	               DW          03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03bh, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch
	               DW          03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03ch, 03dh, 03dh
	               DW          03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh, 03dh
	               DW          03dh, 03dh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh
	               DW          03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03eh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh
	               DW          03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 03fh
	               DW          03fh, 03fh, 03fh, 03fh, 03fh, 03fh, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h
	               DW          040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 040h, 041h, 041h, 041h
	               DW          041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h, 041h
	               DW          041h, 041h, 041h, 041h, 041h, 041h, 042h, 042h, 042h, 042h, 042h, 042h, 042h, 042h, 042h, 042h, 042h, 042h, 042h, 042h
	               DW          042h, 042h, 042h, 042h, 042h, 042h, 042h, 042h, 042h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h
	               DW          043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 043h, 044h, 044h, 044h, 044h, 044h, 044h, 044h
	               DW          044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 044h, 045h, 045h
	               DW          045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h, 045h
	               DW          045h, 045h, 045h, 045h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h
	               DW          046h, 046h, 046h, 046h, 046h, 046h, 046h, 046h, 047h, 047h, 047h, 047h, 047h, 047h, 047h, 047h, 047h, 047h, 047h, 047h
	               DW          047h, 047h, 047h, 047h, 047h, 047h, 047h, 047h, 047h, 047h, 047h, 048h, 048h, 048h, 048h, 048h, 048h, 048h, 048h, 048h
	               DW          048h, 048h, 048h, 048h, 048h, 048h, 048h, 048h, 048h, 048h, 049h, 049h, 049h, 049h, 049h, 049h, 049h, 049h, 049h, 049h
	               DW          049h, 049h, 049h, 049h, 049h, 049h, 049h, 049h, 049h, 049h, 049h, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah
	               DW          04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04ah, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh
	               DW          04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04bh, 04ch, 04ch, 04ch, 04ch, 04ch
	               DW          04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04ch, 04dh, 04dh
	               DW          04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh, 04dh
	               DW          04dh, 04dh, 04dh, 04dh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh, 04eh
	               DW          04eh, 04eh, 04eh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh, 04fh
	               DW          04fh, 04fh, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h, 050h
	               DW          050h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h, 051h
	               DW          051h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h, 052h
	               DW          052h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h, 053h
	               DW          053h, 053h, 053h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h, 054h
	               DW          054h, 054h, 055h, 055h, 055h, 055h, 055h, 055h, 055h, 055h, 055h, 055h, 055h, 055h, 055h, 055h, 056h, 056h, 056h, 056h
	               DW          056h, 056h, 056h, 056h, 056h, 056h, 056h, 056h, 056h, 057h, 057h, 057h, 057h, 057h, 057h, 057h, 057h, 057h, 057h, 057h
	               DW          057h, 057h, 057h, 057h, 058h, 058h, 058h, 058h, 058h, 058h, 058h, 058h, 058h, 058h, 058h, 059h, 059h, 059h, 059h, 059h
	               DW          059h, 059h, 059h, 059h, 059h, 059h, 059h, 05ah, 05ah, 05ah, 05ah, 05ah, 05ah, 05ah, 05ah, 05ah, 05ah, 05ah, 05ah, 05ah
	               DW          05bh, 05bh, 05bh, 05bh, 05bh, 05bh, 05bh, 05bh, 05bh, 05bh, 05bh, 05bh, 05bh, 05ch, 05ch, 05ch, 05ch, 05ch, 05ch, 05ch
	               DW          05ch, 05ch, 05ch, 05ch, 05ch, 05ch, 05ch, 05dh, 05dh, 05dh, 05dh, 05dh, 05dh, 05dh, 05dh, 05dh, 05dh, 05dh, 05dh, 05dh
	               DW          05eh, 05eh, 05eh, 05eh, 05eh, 05eh, 05eh, 05eh, 05eh, 05eh, 05fh, 05fh, 05fh, 05fh, 05fh, 05fh, 05fh, 05fh, 05fh, 060h
	               DW          060h, 060h, 060h, 060h, 060h, 060h, 060h, 060h, 061h, 061h, 061h, 061h, 061h, 061h, 061h, 061h, 061h, 061h, 062h, 062h
	               DW          062h, 062h, 062h, 062h, 062h, 062h, 062h, 062h, 063h, 063h, 063h, 063h, 063h, 063h, 063h, 064h, 064h, 064h, 064h, 064h
	               DW          065h, 065h, 065h, 065h, 065h, 066h, 066h, 066h, 066h, 066h, 067h, 067h, 067h, 067h, 068h, 068h, 068h, 068h, 069h, 069h
	               DW          069h, 06ah, 06ah, 06ah, 06bh, 06bh
	shipC          DB          0ch, 04h, 0ch, 04h, 04h, 0ch, 04h, 04h, 04h, 0ch, 04h, 04h, 04h, 0ch, 04h, 04h, 04h, 0ch, 04h, 04h
	               DB          04h, 04h, 0ch, 04h, 04h, 04h, 04h, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch
	               DB          04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 04h, 04h, 04h, 04h, 04h, 0ch, 04h, 04h, 04h, 0ch
	               DB          04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 0ch, 04h, 04h, 04h, 04h, 04h, 04h
	               DB          04h, 04h, 0ch, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h
	               DB          0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 0ch, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h
	               DB          04h, 0ch, 0ch, 0ch, 0ch, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 0ch, 04h, 0ch, 0ch, 04h, 04h, 04h
	               DB          04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 0eh, 04h
	               DB          0ch, 04h, 04h, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 04h, 04h, 0eh, 04h, 0ch, 04h, 04h, 0ch, 0ch
	               DB          04h, 04h, 0ch, 0ch, 04h, 04h, 0eh, 04h, 0ch, 04h, 04h, 0ch, 0ch, 04h, 04h, 0ch, 0ch, 04h, 04h, 0eh
	               DB          04h, 0ch, 04h, 04h, 04h, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 0eh, 0eh, 04h
	               DB          0ch, 04h, 04h, 04h, 0ch, 0ch, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 0eh
	               DB          0eh, 04h, 0ch, 0ch, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 0eh
	               DB          0eh, 04h, 0ch, 0ch, 0ch, 04h, 0ch, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 0eh, 0eh
	               DB          04h, 0ch, 0ch, 0ch, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 0eh, 0eh, 0eh
	               DB          04h, 0ch, 0ch, 04h, 04h, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 04h, 04h, 0eh, 0eh, 0eh, 04h
	               DB          0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 04h, 04h, 0eh, 0eh, 0eh, 04h, 0ch
	               DB          0ch, 04h, 04h, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h
	               DB          0eh, 0eh, 0eh, 04h, 0ch, 0ch, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch
	               DB          0ch, 04h, 04h, 0eh, 0eh, 0eh, 04h, 0ch, 0ch, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h
	               DB          04h, 0ch, 0ch, 04h, 04h, 0eh, 0eh, 0eh, 04h, 0ch, 0ch, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h
	               DB          04h, 04h, 04h, 0ch, 0ch, 04h, 0eh, 0eh, 0eh, 0eh, 04h, 0ch, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 04h
	               DB          04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 0eh, 0eh, 0eh, 0eh, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h
	               DB          04h, 04h, 04h, 0ch, 04h, 0eh, 0eh, 0eh, 0fh, 0eh, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h
	               DB          04h, 04h, 04h, 04h, 04h, 0ch, 04h, 0eh, 0eh, 0eh, 0fh, 0eh, 0eh, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h
	               DB          04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch, 04h, 0eh, 0eh, 0fh, 0fh, 0eh, 0eh, 04h, 0ch, 0ch
	               DB          04h, 04h, 04h, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 04h, 0eh, 0eh, 0eh, 0fh
	               DB          0fh, 0eh, 0eh, 04h, 0dh, 04h, 04h, 04h, 04h, 0ch, 0ch, 0ch, 04h, 04h, 04h, 04h, 04h, 04h, 0ch, 0ch
	               DB          04h, 0eh, 0eh, 0eh, 0fh, 0fh, 0fh, 0eh, 04h, 0ch, 04h, 04h, 04h, 04h, 0ch, 0dh, 04h, 04h, 04h, 04h
	               DB          04h, 04h, 0ch, 0dh, 0eh, 0eh, 0eh, 0eh, 0fh, 0fh, 0eh, 0eh, 04h, 0dh, 04h, 05h, 04h, 05h, 05h, 04h
	               DB          05h, 04h, 05h, 04h, 0dh, 0ch, 04h, 0eh, 0eh, 0eh, 0eh, 0fh, 0fh, 0eh, 0eh, 04h, 0ch, 04h, 05h, 04h
	               DB          05h, 0dh, 0dh, 0dh, 05h, 04h, 05h, 04h, 05h, 04h, 05h, 04h, 05h, 04h, 0dh, 04h, 0fh, 0eh, 0fh, 0eh
	               DB          0fh, 0fh, 0fh, 0eh, 0fh, 04h, 0dh, 0dh, 05h, 04h, 05h, 0dh, 0dh, 0dh, 05h, 05h, 05h, 05h, 05h, 05h
	               DB          05h, 05h, 05h, 05h, 05h, 05h, 05h, 0dh, 04h, 0eh, 0fh, 0eh, 0fh, 0fh, 0fh, 0fh, 0fh, 0eh, 0fh, 04h
	               DB          0dh, 0dh, 05h, 05h, 05h, 0dh, 0dh, 05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h, 0dh
	               DB          03h, 0fh, 0bh, 0fh, 0bh, 0fh, 0fh, 0fh, 0fh, 0fh, 0bh, 03h, 0dh, 0dh, 05h, 05h, 0dh, 0dh, 0dh, 01h
	               DB          05h, 01h, 05h, 01h, 05h, 01h, 05h, 01h, 05h, 0dh, 03h, 0bh, 0fh, 0bh, 0fh, 0fh, 0fh, 0fh, 0fh, 0bh
	               DB          03h, 0dh, 0dh, 01h, 05h, 01h, 01h, 05h, 01h, 05h, 01h, 05h, 0dh, 09h, 03h, 0bh, 0bh, 0bh, 0bh, 0fh
	               DB          0fh, 0bh, 0bh, 03h, 09h, 05h, 01h, 05h, 01h, 09h, 0dh, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 0dh, 03h
	               DB          0bh, 0bh, 0bh, 0fh, 0fh, 0bh, 0bh, 03h, 09h, 05h, 01h, 05h, 01h, 09h, 09h, 09h, 01h, 01h, 01h, 01h
	               DB          01h, 01h, 09h, 09h, 03h, 0bh, 0bh, 0bh, 0fh, 0fh, 0fh, 0bh, 03h, 09h, 01h, 01h, 01h, 01h, 09h, 09h
	               DB          01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 03h, 0bh, 0bh, 0bh, 0fh, 0fh, 0bh, 0bh, 03h, 09h
	               DB          01h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 03h, 0bh, 0bh, 0fh, 0fh
	               DB          0bh, 0bh, 03h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 03h
	               DB          0bh, 0bh, 0fh, 0bh, 0bh, 03h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 03h, 0bh
	               DB          0bh, 0bh, 0fh, 0bh, 03h, 09h, 09h, 01h, 01h, 01h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 09h
	               DB          03h, 0bh, 0bh, 0bh, 0bh, 03h, 09h, 09h, 01h, 01h, 01h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
	               DB          09h, 09h, 03h, 0bh, 0bh, 0bh, 0bh, 03h, 09h, 01h, 01h, 01h, 01h, 09h, 09h, 01h, 01h, 01h, 01h, 01h
	               DB          01h, 01h, 09h, 09h, 03h, 03h, 0bh, 0bh, 0bh, 03h, 09h, 09h, 01h, 01h, 01h, 09h, 09h, 01h, 01h, 01h
	               DB          01h, 01h, 01h, 01h, 01h, 09h, 09h, 03h, 03h, 0bh, 0bh, 0bh, 03h, 09h, 09h, 01h, 01h, 01h, 09h, 01h
	               DB          01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 03h, 03h, 0bh, 0bh, 0bh, 03h, 09h
	               DB          09h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 03h, 03h, 0bh, 0bh, 0bh, 03h, 09h
	               DB          09h, 01h, 01h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 03h, 03h, 0bh, 0bh, 0bh, 03h, 09h, 09h
	               DB          01h, 01h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 03h, 0bh, 0bh, 0bh, 03h, 09h, 09h, 01h
	               DB          01h, 09h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 03h, 0bh, 0bh, 03h, 09h, 09h, 09h, 01h
	               DB          01h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 03h, 0bh, 0bh, 03h, 09h, 09h, 09h
	               DB          01h, 09h, 09h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 03h, 0bh, 0bh, 03h, 09h
	               DB          09h, 01h, 01h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 03h, 0bh, 0bh, 03h, 09h, 01h
	               DB          01h, 01h, 09h, 09h, 01h, 01h, 09h, 09h, 03h, 03h, 0bh, 03h, 09h, 01h, 01h, 01h, 09h, 09h, 01h, 01h
	               DB          09h, 09h, 03h, 03h, 0bh, 03h, 09h, 01h, 01h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 03h, 03h, 0bh
	               DB          03h, 09h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 03h, 0bh, 03h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 09h
	               DB          09h, 03h, 03h, 09h, 09h, 01h, 01h, 09h, 09h, 01h, 01h, 01h, 01h, 09h, 03h, 09h, 09h, 09h, 01h, 01h
	               DB          09h, 09h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 09h, 09h, 09h, 01h, 09h, 09h, 01h, 01h, 01h, 01h, 01h
	               DB          01h, 09h, 09h, 09h, 09h, 01h, 01h, 09h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 09h, 01h, 01h, 01h
	               DB          01h, 01h, 01h, 01h, 01h, 09h, 09h, 01h, 01h, 01h, 09h, 09h, 01h, 01h, 01h, 09h, 01h, 01h, 01h, 09h
	               DB          01h, 01h, 01h, 01h, 09h, 01h, 01h, 01h, 09h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 01h
	               DB          01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 09h, 01h, 01h, 01h, 01h
	               DB          09h, 01h, 01h, 01h, 01h, 09h, 01h, 01h, 01h, 01h, 09h, 01h, 01h, 01h, 09h, 01h, 01h, 01h, 09h, 01h
	               DB          01h, 09h, 01h, 01h, 09h, 01h
	;@
	getName        DB          " Your name: $"
	enterValidName DB          " Please, enter a valid name: $"
	playerName1    DB          21,?,21 dup("$")
	               firstScreen label byte
	               DB          '  ',0ah,0dh                                                                                                          	; new line
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
	               DB          '  ',0ah,0dh                                                                                                          	; new line
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
				   
;///////////////////////////////Data Initializations////////////////////////////////////
.code
MAIN PROC FAR
	                mov              AX,@data                	;initializing the data segemnt
	                mov              DS,AX
	firstScreenLoop:
	                mov              ax, graphicsMode        	; enter graphicsMode

	                mov              ah,09h
	                lea              dx, firstScreen         	; show the first screen
	                int              21h

	                mov              ah,09h
	                lea              dx, getName             	; ask for player's name
	                int              21h

	getNameLoop:    lea              si, playerName1         	; get player's name
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
	                mov              ax, graphicsMode        	; enter graphicsMode to delete the screen

	                mov              ah,09h
	                lea              dx, mainMenu            	; show the main menu
	                int              21h

	CheckInMainMenu:mov              ah,0                    	;  ah:al = scan code: ASCII code
	                int              16h
	                jz               CheckInMainMenu         	; check if there is any input

	                cmp              ah,3Bh                  	; F1
	                jz               firstScreenLoop

	                cmp              ah,3ch                  	; F2
	                jz               gameLoop

	                cmp              al,1Bh                  	; ESC
	                jz               exitProg
					
	                jmp              CheckInMainMenu         	; not working yet

	gameLoop:                                                	;NOTE:since we are using words, we will use the value '2' to traverse pixels
	;//////////////////////////////initializations////////////////////////////////////
	                mov              ax, graphicsMode
	                int              10h
	                call             Drawship                	;this subroutine is responsible for drawing the ship using its cooardinates
	;//////////////////////////////Interacting with the user////////////////////////////////////
	CHECK:          mov              ah,1
	                int              16h
	                jz               CHECK                   	; check if there is any input
	                CALL             GENERATE_OFFSET         	; TO GENERATE THE new OFFSET OF THE ship
	;///////////////////////////////////////////////////////////////////////////////////////
	                jmp              gameLoop
	exitProg:       
	                clearWholeScreen
	                mov              ah,09h
	                lea              dx, byebye              	; show the first screen
	                int              21h
					
	                HLT
	; mov            ah, 4ch                 	;stop execution
	; int            21h
MAIN ENDP

	;//////////////////////////////Procedures//////////////////////////////////////////////
GENERATE_OFFSET PROC                                     		; genertaing new offsets for the ship
	                MOVEMENT         11H, 1FH, 1EH, 20H
	                cmp              al,1Bh                  	; ESC
	                jz               exitProg
	ReadKey:                                                 	; get the pressed key from the user
	                call             Eraseship
	                call             Drawship

	                mov              ah,0                    	;wait for a key to be pressed and put it in ah, ah:al = scan code: ASCII code
	                int              16h

	                mov              cx, 0                   	; initialize cx to use it to iterate over the shipSize
	                jmp              CHECK
	;///////////////////////////////////////////////////////////////////////////////////////
	MoveUp:         
	;checking for boundaries
	                mov              BX,[DI]
	                cmp              BX, minY
	                jz               ReadKey
	;moveUP
	                inc              cx
	                mov              BX,[DI]
	                dec              BX                      	;decrement y, we can use SUB [DI], 2h but it's not compatabile with other versions of assembelers
	                mov              [DI],BX

	                add              DI, 2
	                cmp              cx,shipSize             	; do this for all the pixels of the ship
	                jnz              MoveUp

	                jmp              ReadKey

	MoveDown:       
	;checking for boundaries
	                mov              BX,[DI + shipSize*2 - 4]	; as we want to check for the bottom of the ship
	                cmp              BX, maxY
	                jz               ReadKey
	;MoveDown
	                inc              cx
	                mov              BX,[DI]
	                inc              BX                      	;increment y
	                mov              [DI],BX

	                add              DI, 2
	                cmp              cx,shipSize             	;do this for all the pixels of the ship
	                jnz              MoveDown

	                jmp              ReadKey

	MoveLeft:       
	;checking for boundaries
	                mov              BX,[SI]
	                cmp              BX, minX
	                jz               ReadKey
	;MoveLeft
	                inc              cx
	                mov              BX,[SI]
	                dec              BX                      	;decrement x
	                mov              [SI],BX

	                add              SI, 2
	                cmp              cx,shipSize             	;do this for all the pixels of the ship
	                jnz              MoveLeft
	          
	                jmp              ReadKey

	MoveRight:      
	;checking for boundaries
	                mov              BX,[SI]
	                cmp              BX, maxX
	                jz               ReadKey
	;MoveRight
	                inc              cx
	                mov              BX,[SI]
	                inc              BX                      	;increment x
	                mov              [SI],BX

	                add              SI, 2
	                cmp              cx,shipSize             	;do this for all the pixels of the ship
	                jnz              MoveRight

	                jmp              ReadKey
	                ret

GENERATE_OFFSET ENDP
Drawship PROC
	; initialize containers
	                mov              SI, offset shipX        	;shipY is (shipX index + size * 2) so we can use Si for both
	                mov              DI, offset shipC
	                mov              Bx ,shipSize
 
	                mov              ah,0ch                  	;Draw Pixel Command
	back:           
	                push             bx
	                mov              bx, 0
	                add              bx, shipSize
	                add              bx, shipSize
	                mov              al, [DI]                	; use white color for testing
	                mov              cx,[SI]                 	;Column X
	                mov              dx,[SI][BX]             	;Row Y
	                int              10h                     	;draw the pixel
	                add              SI,2                    	;move to the next shipX&Y
	                add              DI,1                    	;move to the next shipC
	                pop              bx
	                dec              bx
	                jnz              back                    	;loop over the ship size
	                ret
Drawship ENDP
Eraseship PROC
	; initialize containers
	                mov              SI, offset shipX        	;shipY is (shipX index + size * 2) so we can use Si for both
	                mov              DI, offset shipY        	;shipY is (shipX index + size * 2) so we can use Si for both

	                mov              Bx ,shipSize
	                mov              al, 0h
	back2:          
	                ERASE_MOVEMENT   11H, 1FH, 1EH, 20H
 

	BackUp:         inc              dx
	                jmp              DrawBlack
	BackDown:       dec              dx
	                jmp              DrawBlack
	BackLeft:       inc              cx
	                jmp              DrawBlack
	BackRight:      dec              cx
	                jmp              DrawBlack
		
	DrawBlack:      push             ax
	                mov              ah,0ch                  	;Draw Pixel Command
	                int              10h                     	;draw the pixel
	                pop              ax
	                add              SI,2                    	;move to the next shipX&Y
	                add              DI,2                    	;move to the next shipX&Y
	                dec              bx
	;add  bp, 1 ;adding differnet colors to each pixel
	                jnz              back2                   	;loop over the ship size
	                ret
Eraseship ENDP
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