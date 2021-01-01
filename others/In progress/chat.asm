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
.data
value          DB ?
.code
MAIN PROC FAR

	          mov              ah,13h
	          int              21h
	          initializaPort
	          initializaScreen
	startChat:
	;//////////////////////////////
	;Check that Transmitter Holding Register is Empty
	          mov              dx , 3FDH     	; Line Status Register
	sendData: In               al , dx       	; Read Line Status
	          test             al , 00100000b
	          JZ               getData      	; Not empty, can't send data then, go to get data
	;If empty put the VALUE in Transmit data register
	          mov              dx , 3F8H     	; Transmit data register
	          mov              al,VALUE
	          out              dx , al
	;//////////////////////////////
	;Check that Data is Ready
	          mov              dx , 3FDH     	; Line Status Register
	getData:  in               al , dx
	          test             al , 1
	          JZ               sendData       	; Not Ready, can't get data then, go to send data
	;If Ready read the VALUE in Receive data register
	          mov              dx , 03F8H
	          in               al , dx
	          mov              VALUE , al
	;//////////////////////////////
	          jmp              startChat        
	          mov              ah,4ch
	          int              21h
main endp


END MAIN