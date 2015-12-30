locals
jumps

setDataDS	macro
	mov ax, data
	mov ds, ax
	assume ds:data
endm

setMesDS	macro
	mov ax, mesDat
	mov ds, ax
	assume ds:mesDat
endm

data	segment
	fileName	db	22, 23	dup(?)
	fileHandle	dw	?
	uErrorMsg	db	"UNKNOWN ERROR", 10, 13, "$"
	errorMsg2	db	"FILE NOT FOUND", 10, 13, "$"
	errorMsg3	db	"PATH NOT FOUND", 10, 13, "$"
	errorMsg5	db	"ACCESS DENIED", 10, 13, "$"
	errorMsg12	db	"ACCESS CODE INVALID", 10, 13, "$"
	pressAnyKey	db	"Press any key to continue...", 10, 13, "$"
	askForName	db	10, 10, 13, "Filename: ", "$"
	checkSaveS	db	10, 13, "Do you want to save before quitting? (Y/N) ", "$"
	checkSaveE	db	10, 13, "INVALID INPUT, try again!", "$"
    menu        db  " File  Edit  Help", 59 dup(20h), "F10 "
    menuColor   db  77h, 74h, 70h, 70h, 70h, 77h, 77h, 74h, 70h, 70h, 70h, 77h, 77h, 74h, 70h, 70h, 70h, 59 dup(77h), 3 dup(74h), 77h
	fileHighC	db	37h, 34h, 30h, 30h, 30h, 37h, 77h, 74h, 70h, 70h, 70h, 77h, 77h, 74h, 70h, 70h, 70h, 59 dup(77h), 3 dup(74h), 77h
	editHighC	db	77h, 74h, 70h, 70h, 70h, 77h, 37h, 34h, 30h, 30h, 30h, 37h, 77h, 74h, 70h, 70h, 70h, 59 dup(77h), 3 dup(74h), 77h
	fileMenu	db	" New (Ctrl+N)  Open (Ctrl+O)  Save (Ctrl+S)", 37 dup(20h)
	fileMenuC	db	6 dup(70h), 6 dup(74h), 9 dup(70h), 6 dup(74h), 9 dup (70h), 6 dup(74h), 38 dup(70h)
	messagePos	dw	0
	numOfReadBytes	dw	0
	cursorX		db	0
	cursorY		db  0
	txtWild		db	"*.TXT"
	pyWild		db	"*.PY"
	batchWild	db	"*.BAT"
	asmWild		db	"*.ASM"
data	ends

mesDat	segment
	message		db	0FFFFh	dup(?)
mesDat	ends

stac	segment stack
		dw 300h dup(?)
stac	ends

code	segment
assume	cs:code, ds:data, ss:stac
ClearScreen	proc
		push ax bx cx dx	; Push regs to stack
		pushf				; Push flags to stack
		mov cx, 25
		mov ah, 2
		mov dl, 10
	@@Clear:
		int 21h
		loop @@Clear
		mov dl, 0
		mov dh, 0
		mov bh, 0
		mov ah, 2
		int 10h
		popf			; Pop flags from stack
		pop dx cx bx ax	; Pop regs from stack
		ret
ClearScreen endp

ErrorMessages	proc
		push dx
		pushf
		cmp ax, 2
		jz @@FileNotFound
		cmp ax, 3
		jz @@PathDoesNotExist
		cmp ax, 5
		jz @@AccessDenied
		cmp ax, 12
		jz @@AccessCodeInvalid
		jmp @@UnknownError
	@@FileNotFound:
		mov dx, offset errorMsg2
		jmp @@ShowError
	@@PathDoesNotExist:
		mov dx, offset errorMsg3
		jmp @@ShowError
	@@AccessDenied:
		mov dx, offset errorMsg5
		jmp @@ShowError
	@@AccessCodeInvalid:
		mov dx, offset errorMsg12
		jmp @@ShowError
	@@UnknownError:
		mov dx, offset uErrorMsg
	@@ShowError:
		mov ah, 9
		int 21h
	@@EndProc:
		mov dx, offset pressAnyKey
		int 21h
		mov ah, 7
		int 21h
		popf
		pop dx
		ret
ErrorMessages	endp

TextParameter		equ	[bp+8]
MenuColorParameter	equ	[bp+6]
RowToPrint			equ	[bp+4]
PrintBar	proc
		push bp
		mov bp, sp
		push ax bx cx dx si
		mov dh, RowToPrint
		mov dl, 0
		mov bh, 0
		mov ah, 2
		int 10h
		mov si, 0
		mov cx, 1
	@@Print:
		mov ah, 9
		mov bx, TextParameter
		mov al, [bx+si]
		mov bx, MenuColorParameter
		mov bl, [bx+si]
		mov bh, 0
		int 10h
		mov ah, 2
		inc dl
		int 10h
		inc si
		cmp si, 80
		jc @@Print
		mov ah, 2
		mov bh, 0
		mov dl, 0
		mov dh, 2
		int 10h
		pop si dx cx bx ax
		pop bp
		ret 6
PrintBar	endp

FileToCreate	equ	[bp+4]
CreateFile	proc
		push bp
		mov bp, sp
		mov dx, FileToCreate
		mov cx, 0
		mov ah, 3Ch
		int 21h
		mov fileHandle, ax
		pop bp
		ret 2
CreateFile	endp

SetFileName	proc
		push ax bx dx si
		pushf
		mov dx, offset fileName
		mov bx, 21
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
		popf
		pop si dx bx ax
		ret
SetFileName	endp

OpenFile	proc
		push ax dx ds
		pushf
		setDataDS
		mov dx, offset fileName
		mov ah, 3Dh
		mov al, 2
		int 21h
		jc @@OpenError
		mov fileHandle, ax
		popf
		pop ds dx ax
		ret
	@@OpenError:
		call ErrorMessages
		popf
		pop ds dx ax
		ret
OpenFile	endp

ReadFile	proc
		push ax bx cx dx si ds
		pushf
		mov bx, fileHandle
		mov cx, 0FFFFh
		setMesDS
		mov dx, offset message
		mov ah, 3Fh
		int 21h
		push ax
		setDataDS
		pop ax
		mov numOfReadBytes, ax
		mov messagePos, ax
		mov si, ax
		setMesDS
		mov message[si], '$'
		setDataDS
		popf
		pop ds si dx cx bx ax
		ret
ReadFile	endp

GetFilePos	proc
		push ax bx cx dx
		pushf
		mov ah, 42h 	; seek file pointer (same as file.seek() in python)
		mov al, 1		; current location plus offset
		mov bx, fileHandle
		mov cx, 0		; high order word of bytes to move
		mov dx, 0		; low order word of bytes to move
		int 21h 		; new pointer stored in DX:AX
		mov messagePos, ax
		popf
		pop dx cx bx ax
		ret
GetFilePos	endp

PrintMessage	proc
		push ax bx dx ds
		pushf
		mov ah, 2
		mov bh, 0
		mov dh, 2
		mov dl, 0
		int 10h
		setMesDS
		mov ah, 9
		mov dx, offset message
		int 21h
		setDataDS
		mov ah, 3
		int 10h
		mov cursorX, dl
		mov cursorY, dh
		push offset menu
		push offset menuColor
		push 0
		call PrintBar
		mov ah, 2
		mov dl, cursorX
		mov dh, cursorY
		int 10h
		popf
		pop ds dx bx ax
		ret
PrintMessage	endp

; TODO: Should list all files with txt, bat, py and asm extensions.
ListFiles	proc
		mov si, offset txtWild
		ret
ListFiles	endp

WriteToFile	proc
		push ax bx cx dx ds
		pushf
		setDataDS
		mov bx, fileHandle
		mov cx, messagePos
		setMesDS
		mov dx, offset message
		mov ah, 40h
		int 21h
		jc @@Error
		popf
		pop ds dx cx bx ax
		ret
	@@Error:
		call ErrorMessages
		popf
		pop ds dx cx bx ax
		ret
WriteToFile	endp

CloseFile	proc
		push ax bx ds
		pushf
		setDataDS
		mov bx, fileHandle
		mov ah, 3Eh
		int 21h
		popf
		pop ds bx ax
		ret
CloseFile	endp

FileToDelete	equ	[bp+4]
DeleteFile	proc
		push bp
		mov bp, sp
		mov ah, 41h
		mov dx, FileToDelete	; pointer to ascii file name to delete
		int 21h
		jnc @@EndProc	; if CF set, error code is in AX
		call ErrorMessages
	@@EndProc:
		pop bp
		ret 2
DeleteFile	endp

MainInput	proc
		setDataDS
		jmp @@GetKey
	@@Enter:
		mov si, messagePos
		inc messagePos
		push ax
		setMesDS
		pop ax
		mov message[si], 10
		inc si
		mov message[si], 13
		setDataDS
		inc messagePos
		jmp @@GetKey
	@@Write:
		mov si, messagePos
		inc messagePos
		push ax
		setMesDS
		pop ax
		mov message[si], al
		setDataDS
	@@GetKey:
		call SetCursorPosData
		mov ah, 1
		int 21h
		cmp al, 13
		jz @@Enter
		cmp al, 0
		jnz @@Write
		call RecognizeDoubleKey
		jmp @@GetKey
		ret
MainInput	endp

SetCursorPosData	proc
		push ax bx dx
		pushf
		mov ah, 3
		mov bh, 0
		int 10h
		mov cursorX, dl
		mov cursorY, dh
		popf
		pop dx bx ax
		ret
SetCursorPosData	endp

RecognizeDoubleKey	proc
		push ax bx dx
		pushf
		mov ah, 7
		int 21h
		cmp al, 21h ; alt+f
		jz @@SaveFile
		cmp al, 44h ; F10
		jz @@SaveFile
		cmp al, 12h ; alt+e
		jz @@EditMenu
		cmp al, 23h ; alt+h
		jz @@HelpMenu
		cmp al, 18h ; alt+o
		jz @@OpenFile
		cmp al, 2Dh ; alt+x
		jz @@Exit
		; cmp al, 50h ; down
		; jz @@MoveDown
		; cmp al, 4Bh ; left
		; jz @@MoveLeft
		; cmp al, 4Dh ; right
		; jz @@MoveRight
		; cmp al, 48h ; up
		; jz @@MoveUp
		mov ah, 2
		mov bh, 0
		mov dl, cursorX
		mov dh, cursorY
		int 10h
		popf
		pop dx bx ax
		ret
	@@SaveFile:
		push offset menu
		push offset fileHighC
		push 0
		call PrintBar
		push offset fileMenu
		push offset fileMenuC
		push 1
		call PrintBar
		mov ah, 2
		mov bh, 0
		mov dl, cursorX
		mov dh, cursorY
		int 10h
		mov dx, offset askForName
		mov ah, 9
		int 21h
		call SetFileName
		push offset fileName
		call CreateFile
		call OpenFile
		call WriteToFile
		popf
		pop dx bx ax
		ret
	@@OpenFile:
		push offset menu
		push offset fileHighC
		push 0
		call PrintBar
		push offset fileMenu
		push offset fileMenuC
		push 1
		call PrintBar
		mov ah, 2
		mov bh, 0
		mov dl, cursorX
		mov dh, cursorY
		int 10h
		mov dx, offset askForName
		mov ah, 9
		int 21h
		call SetFileName
		call OpenFile
		call ReadFile
		call ClearScreen
		call PrintMessage
		popf
		pop dx bx ax
		ret
	@@EditMenu:
		mov ah, 7
		int 21h
		popf
		pop dx bx ax
		ret
	@@HelpMenu:
		mov ah, 7
		int 21h
		popf
		pop dx bx ax
		ret
	@@Exit:
		call CheckSave
		mov ah, 4Ch
		int 21h
RecognizeDoubleKey	endp

CheckSave	proc
		push ax dx
		pushf
	@@PrintStart:
		mov ah, 9
		mov dx, offset checkSaveS
		int 21h
	@@GetInput:
		mov ah, 1
		int 21h
		cmp al, 79h ; lowCase y
		jz @@Yes
		cmp al, 59h ; caps Y
		jz @@Yes
		cmp al, 6Eh ; lowCase n
		jz @@No
		cmp al, 4Eh ; caps N
		jz @@No
		mov ah, 9
		mov dx, offset checkSaveE
		int 21h
		jmp @@PrintStart
	@@Yes:
		mov ah, 9
		mov dx, offset askForName
		int 21h
		call SetFileName
		push offset fileName
		call CreateFile
		call OpenFile
		call WriteToFile
		popf
		pop dx ax
		ret
	@@No:
		popf
		pop dx ax
		ret
CheckSave	endp

	Start:
		setDataDS
		call ClearScreen
		push offset menu
		push offset menuColor
		push 0
		call PrintBar
		call MainInput
		call CloseFile
	Stop:
		mov ah, 4Ch
		int 21h
code	ends
end 	Start