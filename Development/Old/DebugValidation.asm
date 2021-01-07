.model small
.data
playerName1              DB          21,?,21 dup("$")
Is_Valid_Name DB 1
.code
MAIN PROC FAR
	     lea si, playerName1	; get player's name
	     mov ah, 0Ah
	     mov dx, si
	     int 21h

 mov cx, 0
    mov cl, playerName1 + 1     ; Size of player1 name String

    CMP cx, 0                   ; Check if it is an empty String
    JE InValidName

                                ; Otherwise it isn't an empty String
    MOV SI, 0                   ; For Indexing
    lea BX,  PlayerName1 + 2   ; Maybe +2: Player2Name
    mov dx, 0
    mov dx, BX[0]
    ;add BX, 2 
mov dx, 0
    ValidChar:
    mov dl, 41H
        CMP BX[SI], dl ; Less than A: not a character --> Invalid
        JL InValidName

        mov dl, 7AH
        CMP BX[SI], dl ; Greater than z: not a charcter --> Invalid
        JG InValidName

        mov dl, 5AH
        CMP BX[SI], dl ; Less than or equal to Z
        JLE Move_Next_Char  

        mov dl, 61H
        CMP BX[SI], dl ; If Less than a, and it is greater than Z, then it is invalid
        JL InValidName
        ; Otherwise cont. to the next char

    Move_Next_Char:     
                        INC SI          ; Increment the iterator
                        CMP SI, CX      ; Compare the iterator to the size of the string
                        JNE ValidChar   ; If there aren't empty, then check the next character
                        JE ValidName    ; otherwise cont. to the return of the function

    InValidName: 
    mov dl, 0   ; Set the case to InValid Case
    mov Is_Valid_Name, dl

    ValidName: HLT

MAIN endp
END MAIN