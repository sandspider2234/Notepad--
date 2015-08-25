locals
data	segment
	fileName	db	23		dup(?)
	filePointer	dw	?
	buffer		dw	0FFh	dup(?)
	uErrorMsg	db	"UNKNOWN ERROR", 10, 13, "$"
	errorMsg2	db	"FILE NOT FOUND", 10, 13, "$"
	errorMsg3	db	"PATH NOT FOUND", 10, 13, "$"
	errorMsg5	db	"TOO MANY OPEN FILES", 10, 13, "$"
	errorMsg12	db	"INVALID PERMISSIONS", 10, 13, "$"
	pressAnyKey	db	"Press any key to continue...", 10, 13, "$"
	askForName	db	"Filename: ", 10, 13, "$"
    menu        db  " File  Edit  Help", 59 dup(20h), "F10 "
    menuColor   db  77h, 74h, 70h, 70h, 70h, 77h, 77h, 74h, 70h, 70h, 70h, 77h, 77h, 74h, 70h, 70h, 70h, 59 dup(77h), 3 dup(74h), 77h
	MENU_LEN	=	$-menuColor
	fileHighC	db	37h, 34h, 30h, 30h, 30h, 37h, 77h, 74h, 70h, 70h, 70h, 77h, 77h, 74h, 70h, 70h, 70h, 59 dup(77h), 3 dup(74h), 77h
	fileMenu	db	" New (Ctrl+N)  Open (Ctrl+O)  Save (Ctrl+S)", 37 dup(20h)
	fileMenuC	db	6 dup(70h), 6 dup(74h), 9 dup(70h), 6 dup(74h), 9 dup (70h), 6 dup(74h), 38 dup(70h)
	message		db	0FFh	dup(?)
	MESSAGE_LEN	=	$-message
	messagePos	dw	0
	cursorX		db	0
	cursorY		db  0
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

PrintMainMenu	proc
			mov dh, 0
			mov dl, 0
			mov bh, 0
			mov ah, 2
			int 10h
			mov si, 0
			mov cx, 1
	@@Print:
			mov ah, 9
			mov al, menu[si]
			mov bl, menuColor[si]
			int 10h
			mov ah, 2
			inc dl
			int 10h
			inc si
			cmp si, MENU_LEN
			jc @@Print
			mov ah, 2
			mov dl, 10
			int 21h
			int 21h
			mov dl, 13
			int 21h
			ret
PrintMainMenu	endp

PrintMainFile	proc
				mov dh, 0
				mov dl, 0
				mov bh, 0
				mov ah, 2
				int 10h
				mov si, 0
				mov cx, 1
		@@Print:
				mov ah, 9
				mov al, menu[si]
				mov bl, fileHighC[si]
				int 10h
				mov ah, 2
				inc dl
				int 10h
				inc si
				cmp si, MENU_LEN
				jc @@Print
				ret
PrintMainFile	endp

PrintSecondBar	proc
				mov dh, 1
				mov dl, 0
				mov bh, 0
				mov ah, 2
				int 10h
				mov si, 0
				mov cx, 1
		@@Print:
				mov ah, 9
				mov al, fileMenu[si]
				mov bl, fileMenuC[si]
				int 10h
				mov ah, 2
				inc dl
				int 10h
				inc si
				cmp si, MENU_LEN
				jc @@Print
				ret
PrintSecondBar	endp

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
			mov [byte ptr bx], 21
			mov ah, 0Ah
			int 21h
			mov si, 2
	; Shift moves each letter after the first two ones two bytes to the left.
	; This is because the first two bytes are taken by information that is
	; not needed and disturbs reading the file name.
	@@Shift:	
			mov al, fileName[si]
			sub si, 2
			mov fileName[si], al
			add si, 3
			cmp si, 21
			jc @@Shift
			mov si, 0
	; Find removes the "enter" ascii code in the end of the string.
	@@FindEnter:	
			mov al, fileName[si]
			inc si
			cmp al, 0Dh
			jnz @@FindEnter
			dec si
			mov fileName[si], 0
			ret
SetFileName	endp

OpenFile	proc
			mov dx, offset fileName
			mov ah, 3Dh
			mov al, 2
			int 21h
			jc OpenError
			mov filePointer, ax
			ret
		OpenError:	
			cmp ax, 2
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
		AX2:	
			mov dx, offset errorMsg2
			mov ah, 9
			int 21h
			jmp Exit
		AX3:
			mov dx, offset errorMsg3
			mov ah, 9
			int 21h
			jmp Exit
		AX5:
			mov dx, offset errorMsg5
			mov ah, 9
			int 21h
			jmp Exit
		AX12:
			mov dx, offset errorMsg12
			mov ah, 9
			int 21h
			jmp Exit
		Exit:
			mov dx, offset pressAnyKey
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
			pop ax bx cx dx
			popf
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

Input		proc
			jmp @@GetKey
	@@Write:
			mov si, messagePos
			mov message[si], al
			inc messagePos
	@@GetKey:
			mov ah, 3
			mov bh, 0
			int 10h ; int 10h, 3 gets cursor position, returns to dx
			mov cursorX, dl
			mov cursorY, dh
			mov ah, 1
			int 21h
			cmp al, 0
			jnz @@Write
			mov ah, 7
			int 21h
			cmp al, 21h ; alt+f
			jz @@FileMenu
			cmp al, 44h ; F10
			jz @@FileMenu
			cmp al, 12h ; alt+e
			jz @@EditMenu
			cmp al, 23h ; alt+h
			jz @@HelpMenu
			cmp al, 50h ; down
			jz @@MoveDown
			cmp al, 4Bh ; left
			jz @@MoveLeft
			cmp al, 4Dh ; right
			jz @@MoveRight
			cmp al, 48h ; up
			jz @@MoveUp
			mov ah, 2
			mov bh, 0
			mov dl, cursorX
			mov dh, cursorY
			int 10h
			jmp @@GetKey
	@@FileMenu:
			call PrintMainFile
			call PrintSecondBar
			mov ah, 2
			mov bh, 0
			mov dl, cursorX
			mov dh, cursorY
			int 10h
			call SetFileName
			call CreateFile
			call WriteToFile
			ret
	@@EditMenu:
			mov ah, 7
			int 21h
			ret
	@@HelpMenu:
			mov ah, 7
			int 21h
			ret
Input		endp

	Start: 	mov ax, data
			mov ds, ax
			call ClearScreen
			call PrintMainMenu
			call Input
			call CloseFile
	Stop:	mov ah, 4Ch
			int 21h
code	ends
end 	Start