section .text

;---initializing graphics mode
mov ax, 012h
int 10h

;---drawing red dot in the left upper corner of the screen
mov ax, 0A000H		; pointing at video buffer
mov es, ax		; loading starting address to video memory
mov bx, 0		; pointing at the first byte of buffer

;---masking all bits except the seventh
mov dx, 3CEH		; pointing at address register
mov al, 8		; register number
out dx, al		; sending address
inc dx			; pointing at data register
mov al, 10000000B	; mask
out dx, al		; sending the data

;---clearing current contents of the TODO ?
mov al, [es:bx]		; reading contents of the TODO ?
mov al, 0		; preparing for the purge
mov [es:bx], al		; purging!

;---setting up the mask map register for the red color
mov dx, 3C4H		; pointing at address register
mov al, 2		; mask map register number
out dx, al		; sending address
inc dx			; pointing at data register
mov al, 4		; color code
out dx, al		; sending the data

;---drawing the dot
mov al, 0FFH		; any value with set seventh bit
mov [es:bx], al		; showing the dot

;---waiting for key pressing
xor	ax, ax
int	16h

;---returning to the previous mode
mov	ax, 4c00h
int	21h

