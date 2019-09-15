org 0x100

section .text

call	setVGA

mov	byte [Color],	0x1
call	backGroundColor

mov	byte [Color],	0x4

mov	word [X],	0d100
mov	word [Y],	0d50
mov	word [Length],	0d20
call	drawHorizontalLine

mov	word [X],	0d100
mov	word [Y],	0d120
mov	word [Length],	0d20
call	drawHorizontalLine

mov	word [X],	0d120
mov	word [Y],	0d80
mov	word [Length],	0d40
call	drawVerticalLine

mov	word [X],	0d120
mov	word [Y],	0d100
mov	word [Length],	0d20
call	drawHorizontalLine

mov	word [X],	0d120
mov	word [Y],	0d110
mov	word [Length],	0d30
call	drawHorizontalLine

mov	word [X],	0d160
mov	word [Y],	0d120
mov	word [Length],	0d30
call	drawHorizontalLine

mov	word [X],	0d100
mov	word [Y],	0d50
mov	word [Length],	0d70
call	drawVerticalLine

mov	word [X],	0d120
mov	word [X2],	0d190
mov	word [Y],	0d50
mov	word [Y2],	0d120
call	drawLine

mov	word [X],	0d120
mov	word [X2],	0d160
mov	word [Y],	0d80
mov	word [Y2],	0d120
call	drawLine

call	waitKey
call	setText
jmp	exit

; waits for user input
waitKey:
	push	ax

	xor 	ax,	ax
	int 	0x16

	pop	ax
	ret

; calls exit syscall
exit:
	mov	ax,	0x4c00
	int 	0x21

; sets current mode to text
setText:
	push	ax

	mov	ax,	0x3
	int	0x10

	pop	ax
	ret

; fills the whole screen with [Color]
backGroundColor:
	push	ax
	push	cx

	call	setES
	xor	ax,	ax	; start offset is zero
	mov	di,	ax	; setting start offset
	mov	al,	[Color]	; 320 * 200 = 64000 but we
	mov	ah,	[Color]	; can use al and ah to set
	mov	cx,	0d32000	; colors for different pixels
	rep	stosw

	pop	cx
	pop 	ax
	ret

; sets current mode to VGA 320x200x256
setVGA:
	push	ax

	mov	ax,	0x13	; 320x200x256
	int	0x10
	
	pop	ax
	ret

; draws pixel at ([X], [Y]) in [Color]
drawPixel:
	push	ax

	call	setES
	call	calcStartOffset
	mov	al,	[Color]
	stosb
	
	pop	ax
	ret

; calculates start offset based on [Y] and [X]
; and puts it to di
calcStartOffset:
	push	ax
	push	dx

	mov	ax,	0d320
	mul	word [Y]
	add	ax,	[X]
	mov	di,	ax

	pop	dx
	pop	ax
	ret

; sets es segment
setES:
	push	ax

	mov	ax,	0xA000
	mov	es,	ax

	pop	ax
	ret

; draws line from ([X],[Y]) to ([X]+[Length], [Y]) in [Color]
drawHorizontalLine:
	push	cx
	push	ax

	call	setES
	call	calcStartOffset
	mov	al,	[Color]
	mov	cx,	[Length]
	rep	stosb

	pop	ax
	pop	cx
	ret

; draws line from ([X],[Y]) to ([X], [Y]+[Length]) in [Color]
drawVerticalLine:
	push	cx
	push	ax

	call	setES
	call	calcStartOffset
	mov	al,	[Color]
	mov	cx,	[Length]
	.loop:
		stosb
		add	di,	0d319
		loop	.loop

	pop	ax
	pop	cx
	ret

; draws line from ([X], [Y]) to ([X2], [Y2]) in [Color]
drawLine:
	push	cx
	push	ax

	call	setES
	call	calcStartOffset

	; deltax = x1 - x0
	mov	cx,	[X2]
	sub	cx,	[X]	; cx = deltax
	jle	.exit		; if X2 <= X1 exit
	mov	bx,	cx	; deltax in cx is loop counter
	shl	bx,	0d1	; bx = 2*deltax

	; deltay = y1 - y0
	mov	ax,	[Y2]
	sub	ax,	[Y]	; ax = deltay
	jle	.exit		; if Y2 <= Y1 exit
	shl	ax,	0d1	; only 2*deltay is used

	; D = 2 * deltay - deltax
	mov	dx,	ax
	sub	dx,	cx	; dx = D

	.loop:
		call	drawPixel
		inc	word [X]
		cmp	dx,	0
		jle	.endIf
		inc	word [Y]
		sub	dx,	bx
	.endIf:
		add	dx,	ax
		loop	.loop

	.exit:
		pop	ax
		pop	cx
		ret

section .bss

	X:	resw	1
	Y:	resw	1
	X2:	resw	1
	Y2:	resw	1
	Color:	resb	1
	Length:	resw	1
