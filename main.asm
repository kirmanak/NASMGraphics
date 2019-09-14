section .bss

X: resw 1
Y: resw 1
Color: resb 1
Length: resw 1

section .text

call setVGA

mov byte [Color], 0x1
call showColor
call waitKey

mov byte [Color], 0xD
mov word [X], 0d100
mov word [Y], 0d160
call drawPixel
call waitKey

mov word [X], 0d10
mov word [Y], 0d20
mov word [Length], 0d30
mov byte [Color], 0x4
call drawHorizontalLine
call waitKey

mov word [X], 0d10
mov word [Y], 0d20
mov word [Length], 0d30
mov byte [Color], 0x4
call drawVerticalLine
call waitKey

call setText
call exit

waitKey:
	xor ax, ax
	int 0x16
	ret

exit:
	mov ax, 0x4c00
	int 0x21

setText:
	mov ax,0x3
	int 0x10
	ret

showColor:
	mov ax, [Color]
	mov ah, al
	cld
	mov cx, 0xA000
	mov es, cx
	xor di, di
	mov cx, 0d32000
	rep stosw
	ret

setVGA:
	mov ax,0x13	; 320x200x256
	int 0x10
	ret

drawPixel:
	mov cx, 0xA000
	mov es, cx
	mov ax, 0d320
	mul word [Y]
	add ax, [X]
	mov bx, ax
	mov al, [Color]
	mov [es:bx], al
	ret

drawHorizontalLine:
	mov cx, 0xA000
	mov es, cx
	mov ax, 0d320
	mul word [Y]
	add ax, [X]
	mov di, ax
	mov al, [Color]
	mov cx, [Length]
	cld
	rep stosb
	ret

drawVerticalLine:
	mov cx, 0xA000
	mov es, cx
	mov ax, 0d320
	mul word [Y]
	add ax, [X]
	mov di, ax
	mov al, [Color]
	mov cx, [Length]
	.loop:
		mov [es:di], al
		add di, 320
		loop .loop
	ret
