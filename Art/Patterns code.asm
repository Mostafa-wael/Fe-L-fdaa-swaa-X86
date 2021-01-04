
.model small
.Stack 64
.CODE 
	MAIN PROC FAR
		MOV Ax,4F02h ;set the configuration to video mode
		mov bx, 0100h
		INT 10h    ;execute the configuration 
		MOV AH,0Bh ;set the configuration
		MOV BH,00h ;to the background color
		MOV BL,00h ;choose black as background color
		INT 10h    ;execute the configuration
                MOV CX, 640 ;set the width (X) up to ff, dont forget to change this number in the loop
		MOV DX, 400 ;set the hieght (Y) up to AA
        jmp Start ;Avoid drawing before the calculations
Drawit: 
        MOV AH,0Ch ;set the configuration to writing a pixel
        push bx
        ; next 6 lines to make the pattern darker
        cmp bl, 32
        jb DontDarken
        cmp bl, 175
        ja DontDarken
        add bl, 72
DontDarken:
	MOV AL, bl ;choose white as color
	MOV BH,00h ;set the page number 
        pop bx
        INT 10h    ;execute the configuration
Start:  
        mov AX, 0      ;  |
        mov AL, DL     ;  |  > Multuply DL*Dl and Store in AX then BX 
        Mul DL         ;  |
        mov bx, AX     ;  |
        mov AL, CL     ;  \
        Mul CL         ;  \   > Multuply CL*Cl and Store in AX 


;/////////////THIS LINE CHOOSES THE PATTERN TO BE DRAWN\\\\\\\\\\\\\\\\\\\\\\\\\\\\
        Xor bx, AX     ;  Relation between DL^2 and CL^2, Sub : X2-Y2 = Hyberbolic Patterns, Add: X2+Y2 = Circular, OR/AND: Rectangular, Xor: Diagonal
        
        
        DEC CX         ;  loop iteration in x direction
        JNZ TRY        ;  check if we can draw current x and y and excape the y iteration
        mov CX, 640  ;  if loop iteration in y direction, then x should start over so that we sweep the grid
        DEC DX         ;  loop iteration in y direction
        JZ ENDING      ;  both x and y reached 00 so end program
TRY:    Sub BX, 70E4h
        Jp Drawit ;js for quarter circle, also parity produces patterns (in addition to formula pattern)
        jmp Start ; loop
ENDING:
	RET
	MAIN ENDP
END MAIN