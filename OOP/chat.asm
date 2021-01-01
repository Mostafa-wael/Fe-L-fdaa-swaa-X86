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
initializaScreen MACRO

	                 mov ah,6 	; function 6
	                 mov al,1 	; scroll by 1 line (al=0 change color)
	                 mov bh,7 	; normal video attribute
	                 mov ch,0 	; upper left Y
	                 mov cl,0 	; upper left X
	                 mov dh,12	; lower right Y
	                 mov dl,79	; lower right X
	                 int 10h
    ENDM
getCursorPos macro rowCol
	             mov ah,3
	             mov bx, 0
	             int 10h
	             mov rowCol, dx
ENDM
setCursorPos macro rowCol
	             mov ah,2      	;Move Cursor
	             mov dx, rowCol
	             int 10h
endm
clearWholeScreen MACRO
	                 mov ah, 0
	                 mov al, 3
	                 INT 10H  	;FOR VIDEO DISPLAY
	ENDM
.stack 64
.data
	place1 DW 0
place2 DW 1279
.code
MAIN PROC FAR
	          mov              AX, @data
	          mov              DS, AX

	          clearWholeScreen

	          mov              ah,13h        	; enter the graphics mode
	          int              21h
	          initializaPort
	          initializaScreen
	startChat:
	;//////////////////////////////
	;Check that Transmitter Holding Register is Empty
	sendData: mov              dx , 3FDH     	; Line Status Register
	          In               al , dx       	; Read Line Status
	          test             al , 00100000b
	          JZ               getData       	; Not empty, can't send data then, go to get data
	;If empty put the VALUE in Transmit data register
	CHECK:    
	          mov              ah,1
	          int              16h           	;Get key pressed (do not wait for a key-AH:scancode,AL:ASCII)
	          jz               getData
	          setCursorPos     place1

	          mov              ah,0
	          int              16h           	;Get key pressed (Wait for a key-AH:scancode,AL:ASCII)

	          mov              ah,2          	;Display Char
	          mov              dl,al
	          int              21h
	          getCursorPos     place1
        
	          mov              dx , 3F8H     	; Transmit data register
	          out              dx , al       	; value read from the keyboard is in al
	;//////////////////////////////
	;Check that Data is Ready
	getData:  mov              dx , 3FDH     	; Line Status Register
	          in               al , dx
	          test             al , 1
	          JZ               sendData      	; Not Ready, can't get data then, go to send data
	;If Ready read the VALUE in Receive data register
	          mov              dx , 03F8H
	          in               al , dx       	; put the read value in al
	          setCursorPos     place2
	          mov              ah,2          	;Display Char
	          mov              dl,al
	          int              21h
	          getCursorPos     place2
	;//////////////////////////////
	          jmp              startChat
	          mov              ah,4ch
	          int              21h
main endp


END MAIN