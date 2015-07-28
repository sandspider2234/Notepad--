locals
data	segment
	fileName	db	13		dup(?)
	filePointer	dw	?
	buffer		dw	0FFh	dup(?)
	uErrorMsg	db	"UNKNOWN ERROR", 10, 13, "$"
	errorMsg2	db	"FILE NOT FOUND", 10, 13, "$"
	errorMsg3	db	"PATH NOT FOUND", 10, 13, "$"
	errorMsg5	db	"TOO MANY OPEN FILES", 10, 13, "$"
	errorMsg12	db	"INVALID PERMISSIONS", 10, 13, "$"
	pressAnyKey	db	"Press any key to continue...", 10, 13, "$"
	message		db	0FFh	dup(?)
	MESSAGE_LEN	=	$-message
data	ends

stac	segment stack
		    dw 100h dup(?)
stac	ends

code	segment
assume	cs:code, ds:data, ss:stac
ClearScreen	proc
			push ax bx cx dx	; Push regs to stack
			pushf				; Push flags to stack
			mov cx, 30
			mov ah, 2
			mov dl, 10
	Clear:	int 21h
			loop Clear
			mov dl, 0
			mov cx, 0
			mov bh, 0
			mov ah, 2
			int 10h
			pop ax bx cx dx		; Pop regs from stack
			popf				; Pop flags from stack
			ret
ClearScreen endp

CreateFile	proc
			mov dx, offset fileName
			mov cx, 0
			mov ah, 3Ch
			int 21h
			mov filePointer, ax
			ret
CreateFile	endp

SetFileName	proc
			mov dx, offset fileName
			mov bx, dx
			mov [byte ptr bx], 11
			mov ah, 0Ah
			int 21h
			mov si, 2
	; Shift moves each letter after the first two ones two bytes to the left.
	; This is because the first two bytes are taken by information that is
	; not needed and disturbs reading the file name.
	@@Shift:	mov al, fileName[si]
				sub si, 2
				mov fileName[si], al
				add si, 3
				cmp si, 11
				jc @@Shift
			mov si, 0
	; Find removes the "enter" ascii code in the end of the string.
	Find:	mov al, fileName[si]
			inc si
			cmp al, 0Dh
			jnz Find
			dec si
			mov fileName[si], 0
			ret
SetFileName	endp

SetMessage	proc
			mov dx, offset message
			mov bx, dx
			mov [byte ptr bx], 0FDh
			mov ah, 0Ah
			int 21h
			mov si, 2
	@@Shift:	mov al, message[si]
				sub si, 2
				mov message[si], al
				add si, 3
				cmp si, 0FDh
				jc @@Shift
			ret
SetMessage	endp

OpenFile	proc
			mov dx, offset fileName
			mov ah, 3Dh
			mov al, 2
			int 21h
			jc OpenError
			mov filePointer, ax
			ret
		OpenError:	cmp ax, 2
					jz AX2
					cmp ax, 3
					jz AX3
					cmp ax, 5
					jz AX5
					cmp ax, 12
					jz AX12
					mov dx, offset uErrorMsg
					mov ah, 9
					int 21h
					jmp Exit
		AX2:	mov dx, offset errorMsg2
				mov ah, 9
				int 21h
				jmp Exit
		AX3:	mov dx, offset errorMsg3
				mov ah, 9
				int 21h
				jmp Exit
		AX5:	mov dx, offset errorMsg5
				mov ah, 9
				int 21h
				jmp Exit
		AX12:	mov dx, offset errorMsg12
				mov ah, 9
				int 21h
				jmp Exit
		Exit:	mov dx, offset pressAnyKey
				int 21h
				mov ah, 7
				int 21h
				mov ah, 4Ch
				int 21h
OpenFile	endp

ReadFile	proc
			mov bx, filePointer
			mov cx, 0FFh
			mov dx, offset buffer
			mov ah, 3Fh
			int 21h
			ret
ReadFile	endp

WriteToFile	proc
			mov bx, filePointer
			mov cx, MESSAGE_LEN
			mov dx, offset message
			mov ah, 40h
			int 21h
			ret
WriteToFile	endp

CloseFile	proc
			mov bx, filePointer
			mov ah, 3Eh
			int 21h
			ret
CloseFile	endp

	Start: 	mov ax, data
			mov ds, ax
			call ClearScreen
			call SetFileName
			call CreateFile
			call OpenFile
			call ClearScreen
			call SetMessage
			call WriteToFile
			call CloseFile
	Stop:	mov ah, 4Ch
			int 21h
code	ends
end 	Start