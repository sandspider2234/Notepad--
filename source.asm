locals
jumps

setCursorToCurrData	macro
	mov ah, 2
	xor bh, bh
	mov dl, cursorX
	mov dh, cursorY
	int 10h
endm

completeNewFile	macro
	call CheckSave
	call SetFileName
	push offset fileName
	call CreateFile
	call OpenFile
	call WriteToFile
	call ClearScreen
	call PrintMessage
endm

completeSaveFile	macro
	push offset menuMenu offset mainFileHighC 0
	call PrintBar
	push offset fileMenu offset fileMenuSaveHigh 1
	call PrintBar
	setCursorToCurrData
	call SetFileName
	push offset fileName
	call CreateFile
	call OpenFile
	call WriteToFile
	call ClearScreen
	call PrintMessage
endm

completeOpenFile	macro
	push offset menuType offset mainFileHighC 0
	call PrintBar
	push offset fileMenu offset fileMenuOpenHigh 1
	call PrintBar
	setCursorToCurrData
	call SetFileName
	call OpenFile
	call ReadFile
	call ClearScreen
	call PrintMessage
endm

; Macros for switching DSEGs.
setDataDS	macro
	push ax
	mov ax, data
	mov ds, ax
	assume ds:data
	pop ax
endm

setMesDS	macro
	push ax
	mov ax, mesDat
	mov ds, ax
	assume ds:mesDat
	pop ax
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
	askForName	db	10, 13, "Filename: ", "$"
	checkSaveS	db	10, 13, "Do you want to save before quitting? (Y/N) ", "$"
	checkSaveE	db	10, 13, "INVALID INPUT, try again!", "$"
	menuType	db  " File  Edit  Help", 5 dup(20h), "Opened: ", 45 dup(20h), "TYPE "
	menuMenu	db	" File  Edit  Help", 5 dup(20h), "Opened: ", 45 dup(20h), "MENU "
	menuColor	db  77h, 74h, 3 dup(70h), 2 dup(77h), 74h, 3 dup(70h), 2 dup(77h), 74h, 3 dup(70h), 5 dup(77h), 8 dup(70h), 44 dup(72h), 6 dup(2Fh)
	mainFileHighC	db	37h, 34h, 3 dup(30h), 37h, 77h, 74h, 3 dup(70h), 2 dup(77h), 74h, 3 dup(70h), 5 dup(77h), 8 dup(70h), 44 dup(72h), 6 dup(2Fh)
	mainEditHighC	db	77h, 74h, 3 dup(70h), 77h, 37h, 34h, 3 dup(30h), 37h, 77h, 74h, 3 dup(70h), 5 dup(77h), 8 dup(70h), 44 dup(72h), 6 dup(2Fh)
	mainHelpHighC	db	77h, 74h, 3 dup(70h), 77h, 77h, 74h, 3 dup(70h), 77h, 37h, 34h, 3 dup(30h), 37h, 4 dup(77h), 8 dup(70h), 44 dup(72h), 6 dup(2Fh)
	fileMenu	db	" New (Alt+N)  Open (Alt+O)  Save (Alt+S)", 40 dup(20h)
	fileMenuNewHigh	db	6 dup(30h), 5 dup(34h), 2 dup(30h), 7 dup(70h), 5 dup(74h), 9 dup(70h), 5 dup(74h), 41 dup(70h)
	fileMenuOpenHigh	db	6 dup(70h), 5 dup(74h), 2 dup(70h), 7 dup(30h), 5 dup(34h), 2 dup(30h), 7 dup(70h), 5 dup(74h), 41 dup(70h)
	fileMenuSaveHigh	db	6 dup(70h), 5 dup(74h), 9 dup(70h), 5 dup(74h), 2 dup(70h), 7 dup(30h), 5 dup(34h), 2 dup(30h), 40 dup(70h)
	editMenu	db	" Delete all text (Alt+Del)", 54 dup(20h)
	editMenuDeleteHigh	db	18 dup(30h), 7 dup(34h), 2 dup(30h), 53 dup(70h)
	helpMenu	db	" Help (F1)  About (F2)", 58 dup(20h)
	helpMenuF1High	db	7 dup(30h), 2 dup(34h), 2 dup(30h), 8 dup(70h), 2 dup(74h), 59 dup(70h)
	helpMenuF2High	db	7 dup(70h), 2 dup(74h), 2 dup(70h), 8 dup(30h), 2 dup(34h), 2 dup(30h), 58 dup(70h)
	textBlanks	db	80 dup(20h)
	colorBlanks	db	80 dup(0)
	aboutString	db	35 dup(20h), "Notepad--", 10, 13, 22 dup(20h), "The open source x86 ASM text editor!", 10, 13, 23 dup(20h), "Created by Barak Nehmad, 2015-2016", 10, 13, 27 dup(20h), "Press any key to return...$"
	helpString	db	"========================================", 10, 13, "Keyboard shortcuts:", 10, 13, "Alt+S = Save current buffer to file", 10, 13, "Alt+O = Open a file", 10, 13, "Alt+N = Create new blank buffer", 10, 13, "Alt+X OR Alt+F4 = Exit", 10, 13, "F1 = Open help page (this one!)", 10, 13, "F2 = Open about page", 10, 13, "F10 = Enter menu navigation mode", 10, 13, "========================================", 10, 13, "Navigation tips:", 10, 13, "When in menu navigation mode, press the left and right arrow keys to navigate", 10, 13, "within the current selected sub-menu. In order to move to another sub-menu,", 10, 13, "press Alt+right/left arrow keys.", 10, 13, "In order to return to file editing, press ESC.$"
	messagePos	dw	0
	numOfReadBytes	dw	0
	cursorX		db	0
	cursorY		db  0
	txtWild		db	"*.TXT"
	pyWild		db	"*.PY"
	batchWild	db	"*.BAT"
	asmWild		db	"*.ASM"
data	ends

; Second data segment dedicated for a large message buffer which allows for 65535 bytes of data.
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
		xor dl, dl
		xor dh, dh
		xor bh, bh
		mov ah, 2
		int 10h
		popf			; Pop flags from stack
		pop dx cx bx ax	; Pop regs from stack
		ret
ClearScreen endp

; Gets called whenever there's an error, displays error message.
; Uses AX to determine which error message to display.
ErrorMessages	proc
		push ax cx dx di es
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
		lea dx, errorMsg2
		jmp @@ShowError
	@@PathDoesNotExist:
		lea dx, errorMsg3
		jmp @@ShowError
	@@AccessDenied:
		lea dx, errorMsg5
		jmp @@ShowError
	@@AccessCodeInvalid:
		lea dx, errorMsg12
		jmp @@ShowError
	@@UnknownError:
		lea dx, uErrorMsg
	@@ShowError:
		mov ah, 9
		int 21h
		lea dx, pressAnyKey
		int 21h
		mov ah, 7
		int 21h
	@@Reset:
		call ClearScreen
		mov ax, data
		mov es, ax
		lea di, fileName
		inc di
		xor al, al
		cld
		mov cx, 22
		rep stosb
		mov fileHandle, 0
		call PrintMessage
	@@Return:
		popf
		pop es di dx cx ax
		ret
ErrorMessages	endp

; Prints menu bar.
; Recieves three parameters through stack:
; TextParameter - array of 80 bytes which contains textual data to print.
; MenuColorParameter - array of 80 bytes which contains text color attributes.
; RowToPrint - type int. This determines where to print the menu bar.
TextParameter		equ	[bp+8]
MenuColorParameter	equ	[bp+6]
RowToPrint			equ	[bp+4]
PrintBar	proc
		push bp
		mov bp, sp
		push ax bx cx dx si
		pushf
		mov dh, RowToPrint
		xor dl, dl
		xor bh, bh
		mov ah, 2
		int 10h
		xor si, si
		mov cx, 1
	@@Print:
		mov ah, 9
		mov bx, TextParameter
		mov al, [bx+si]
		mov bx, MenuColorParameter
		mov bl, [bx+si]
		xor bh, bh
		int 10h
		mov ah, 2
		inc dl
		int 10h
		inc si
		cmp si, 80
		jc @@Print
		mov ah, 2
		xor bh, bh
		xor dl, dl
		mov dh, 2
		int 10h
		popf
		pop si dx cx bx ax
		pop bp
		ret 6
PrintBar	endp

; Creates a file according to passed pathname.
; Recieves one parameter through the stack:
; CreateFile - Pathname in ASCII.
FileToCreate	equ	[bp+4]
CreateFile	proc
		push bp
		mov bp, sp
		push ax cx dx
		pushf
		mov dx, FileToCreate
		xor cx, cx
		mov ah, 3Ch
		int 21h
		mov fileHandle, ax
		popf
		pop dx cx ax
		pop bp
		ret 2
CreateFile	endp

; Asks user for a filename and pushes answer to memory after cleaning it up.
SetFileName	proc
		push ax bx cx dx si di
		pushf
		lea dx, askForName
		mov ah, 9
		int 21h
		lea dx, fileName
		mov bx, 21
		mov ah, 0Ah
		int 21h
		mov cl, fileName[1]
		xor ch, ch
	; Shift moves each letter after the first two ones two bytes to the left.
	; This is because the first two bytes are taken by information that is
	; not needed and disturbs reading the file name.
		mov si, 2
	@@Shift:
		mov al, fileName[si]
		sub si, 2
		mov fileName[si], al
		add si, 3
		cmp si, 21
		jc @@Shift
	; End of Shift label, these lines remove the enter ASCII code
	; at the end of the string.
		mov si, cx
		mov fileName[si], 0
		push cx
	@@PrintOnBar:
		mov ax, data
		mov es, ax
		lea di, menuType
		add di, 30
		xor al, al
		cld
		mov cx, 22
		rep stosb
		lea di, menuMenu
		add di, 30
		mov cx, 22
		rep stosb
		pop cx
		lea si, fileName
		lea di, menuType
		add di, 30
		rep movsb
		lea si, fileName
		lea di, menuMenu
		add di, 30
		rep movsb
		popf
		pop di si dx cx bx ax
		ret
SetFileName	endp

; Opens file using filename from memory.
OpenFile	proc
		push ax dx ds
		pushf
		setDataDS
		lea dx, fileName
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

; Reads opened file into message buffer.
ReadFile	proc
		push ax bx cx dx si ds
		pushf
		mov bx, fileHandle
		mov cx, 0FFFFh
		setMesDS
		lea dx, message
		mov ah, 3Fh
		int 21h
		setDataDS
		mov numOfReadBytes, ax
		mov messagePos, ax
		mov si, ax
		setMesDS
		mov message[si], '$' ; Adds a terminate to the end of the string.
		setDataDS
		popf
		pop ds si dx cx bx ax
		ret
ReadFile	endp

; Gets current position of file pointer and returns it to memory.
GetFilePos	proc
		push ax bx cx dx
		pushf
		mov ah, 42h 	; seek file pointer (same as file.seek() in python)
		mov al, 1		; current location plus offset
		mov bx, fileHandle
		xor cx, cx		; high order word of bytes to move
		xor dx, dx		; low order word of bytes to move
		int 21h 		; new pointer stored in DX:AX
		mov messagePos, ax
		popf
		pop dx cx bx ax
		ret
GetFilePos	endp

; Prints buffer to screen.
PrintMessage	proc
		push ax bx dx ds
		pushf
		mov ah, 2
		xor bh, bh
		mov dh, 2
		xor dl, dl
		int 10h
		setMesDS
		mov ah, 9
		lea dx, message
		int 21h
		setDataDS
		mov ah, 3
		int 10h
		mov cursorX, dl
		mov cursorY, dh
		push offset menuType offset menuColor 0
		call PrintBar
		push offset textBlanks offset colorBlanks 1
		call PrintBar
		setCursorToCurrData
		popf
		pop ds dx bx ax
		ret
PrintMessage	endp

DeleteMessageBuffer	proc
		push ax cx di es
		pushf
		mov cx, messagePos
		mov ax, mesDat
		mov es, ax
		lea di, message
		mov al, 0
		cld
		rep stosb
		mov messagePos, 0
		call ClearScreen
		push offset menuType offset menuColor 0
		call PrintBar
		push offset textBlanks offset colorBlanks 1
		call PrintBar
		call GetCursorPos
		popf
		pop es di cx ax
		ret
DeleteMessageBuffer	endp

; TODO: Should list all files with txt, bat, py and asm extensions.
ListFiles	proc
		lea si, txtWild
		ret
ListFiles	endp

; Writes to file using handle and message buffer.
WriteToFile	proc
		push ax bx cx dx ds
		pushf
		setDataDS
		mov bx, fileHandle
		mov cx, messagePos
		setMesDS
		lea dx, message
		mov ah, 40h
		int 21h
		jc @@Error
		mov si, cx
		mov message[si], '$'
		popf
		pop ds dx cx bx ax
		ret
	@@Error:
		call ErrorMessages
		popf
		pop ds dx cx bx ax
		ret
WriteToFile	endp

; Closes file and frees file handle.
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

; Deletes a file according to passed pathname.
; Recieves one parameter through the stack:
; FileToDelete - Pathname in ASCII.
FileToDelete	equ	[bp+4]
DeleteFile	proc
		push bp
		mov bp, sp
		push ax dx
		pushf
		mov ah, 41h
		mov dx, FileToDelete	; pointer to ascii file name to delete
		int 21h
		jnc @@EndProc	; if CF set, error code is in AX
		call ErrorMessages
	@@EndProc:
		popf
		pop dx ax
		pop bp
		ret 2
DeleteFile	endp

; Main input loop. Gets input from user and writes it to message buffer.
MainInput	proc
		setDataDS
		jmp @@GetKey
	@@Enter:
		mov si, messagePos
		inc messagePos
		setMesDS
		mov message[si], 10
		inc si
		mov message[si], 13
		setDataDS
		inc messagePos
		jmp @@GetKey
	@@Backspace:
		call Backspace
		jmp @@GetKey
	@@Write:
		mov si, messagePos
		inc messagePos
		setMesDS
		mov message[si], al
		setDataDS
	@@GetKey:
		call GetCursorPos
		mov ah, 1
		int 21h
		cmp al, 13
		jz @@Enter
		cmp al, 8
		jz @@Backspace
		cmp al, 0
		jnz @@Write
		call RecognizeDoubleKey
		jmp @@GetKey
		ret
MainInput	endp

; Handles backspace press.
Backspace	proc
		push ax bx cx dx si di ds es
		pushf
		cmp messagePos, 0
		jz @@EndProc
		dec messagePos
		mov si, messagePos
		setMesDS
		mov message[si], 0
		setDataDS
		cmp cursorX, 0
		ja @@DelLetter
		dec si
		setMesDS
		cmp message[si], 10
		jz @@EnterFound
	@@JmpToEndLine:
		setDataDS
		mov dl, 79
		mov dh, cursorY
		dec dh
		xor bh, bh
		mov ah, 2
		int 10h
		jmp @@DelLetter
	@@EnterFound:
		dec si
		mov ax, mesDat
		mov es, ax
		assume es:mesDat
		lea di, message
		add di, si
		std
		mov al, 13
		mov cx, si
		repnz scasb
		cmp di, 0
		jz @@DiIsStartOfDoc
		inc di
		jmp @@Division
	@@DiIsStartOfDoc: 
		inc si
	@@Division:
		sub si, di
		mov ax, si
		mov dl, 80
		div dl
		xor bh, bh
		setDataDS
		mov dh, cursorY
		dec dh
		mov dl, ah
		mov ah, 2
		int 10h
		dec messagePos
		mov si, messagePos
		setMesDS
		mov message[si], 0
		setDataDS
	@@DelLetter:
		mov ah, 0Ah
		xor al, al
		xor bh, bh
		mov cx, 1
		int 10h
	@@EndProc:
		popf
		pop es ds di si dx cx bx ax
		ret
Backspace	endp

; Queries cursor position and returns data to memory.
GetCursorPos	proc
		push ax bx dx
		pushf
		mov ah, 3
		xor bh, bh
		int 10h
		mov cursorX, dl
		mov cursorY, dh
		popf
		pop dx bx ax
		ret
GetCursorPos	endp

; Uses data from previous int 21h|7 in order to determine a keyboard shortcut.
RecognizeDoubleKey	proc
		push ax bx dx
		pushf
		mov ah, 7
		int 21h
		cmp al, 1Fh ; alt+s
		jz @@SaveFile
		cmp al, 18h ; alt+o
		jz @@OpenFile
		cmp al, 0A3h ;alt+del
		jz @@DeleteBuffer
		cmp al, 3Bh ; F1
		jz @@Help
		cmp al, 3Ch ; F2
		jz @@About
		cmp al, 21h ; alt+f
		jz @@FileMenu
		cmp al, 12h ; alt+e
		jz @@EditMenu
		cmp al, 23h ; alt+h
		jz @@HelpMenu
		cmp al, 44h ; F10
		jz @@MenuMode
		cmp al, 2Dh ; alt+x
		jz @@Exit
		cmp al, 6Bh ; alt+F4
		jz @@Exit
		setCursorToCurrData
		jmp @@Return
	@@SaveFile:
		completeSaveFile
		jmp @@Return
	@@OpenFile:
		completeOpenFile
		jmp @@Return
	@@DeleteBuffer:
		call DeleteMessageBuffer
		jmp @@Return
	@@Help:
		push offset helpString 0
		call PrintSecondPage
		jmp @@Return
	@@About:
		push offset aboutString 7
		call PrintSecondPage
		jmp @@Return
	@@FileMenu:
		push 0
		call MenuMode
		push offset menuType offset menuColor 0
		call PrintBar
		push offset textBlanks offset colorBlanks 1
		call PrintBar
		setCursorToCurrData
		jmp @@Return
	@@EditMenu:
		push 1
		call MenuMode
		push offset menuType offset menuColor 0
		call PrintBar
		push offset textBlanks offset colorBlanks 1
		call PrintBar
		setCursorToCurrData
		jmp @@Return
	@@HelpMenu:
		push 2
		call MenuMode
		push offset menuType offset menuColor 0
		call PrintBar
		push offset textBlanks offset colorBlanks 1
		call PrintBar
		setCursorToCurrData
		jmp @@Return
	@@MenuMode:
		push 0
		call MenuMode
		push offset menuType offset menuColor 0
		call PrintBar
		push offset textBlanks offset colorBlanks 1
		call PrintBar
		setCursorToCurrData
	@@Return:
		popf
		pop dx bx ax
		ret
	@@Exit:
		call CheckSave
		mov ah, 4Ch
		int 21h
RecognizeDoubleKey	endp

DefaultMenu	equ	[bp+4]
MenuMode	proc
		push bp
		mov bp, sp
		push ax bx
		pushf
		mov bh, DefaultMenu	; bh is selected sub-menu
		mov bl, 0			; bl is selected entry in sub-menu
	@@CheckBH:
		cmp bh, 1
		jc @@FileMenuCheck	; bh is 0
		ja @@HelpMenuCheck	; bh is 2
		@@EditMenuCheck:
			push offset menuMenu offset mainEditHighC 0
			call PrintBar
			push offset editMenu offset editMenuDeleteHigh 1
			call PrintBar
			jmp @@StartInput
		@@FileMenuCheck:
			push offset menuMenu offset mainFileHighC 0
			call PrintBar
			cmp bl, 1
			jc @@FileMenuBLIs0
			ja @@FileMenuBLIs2
			push offset fileMenu offset fileMenuOpenHigh 1
			call PrintBar
			jmp @@StartInput
			@@FileMenuBLIs0:
				push offset fileMenu offset fileMenuNewHigh 1
				call PrintBar
				jmp @@StartInput
			@@FileMenuBLIs2:
				push offset fileMenu offset fileMenuSaveHigh 1
				call PrintBar
				jmp @@StartInput
		@@HelpMenuCheck:
			push offset menuMenu offset mainHelpHighC 0
			call PrintBar
			cmp bl, 0
			jnz @@HelpMenuBLIs1
			push offset helpMenu offset helpMenuF1High 1
			call PrintBar
			jmp @@StartInput
		@@HelpMenuBLIs1:
			push offset helpMenu offset helpMenuF2High 1
			call PrintBar
	@@StartInput:
		mov ah, 7
		int 21h
		cmp al, 13	; enter
		jz @@Select
		cmp al, 1Bh	; escape
		jz @@Return
		cmp al, 0
		jnz @@StartInput
		int 21h
		cmp al, 4Dh ; right
		jz @@MoveInSubRight
		cmp al, 4Bh ; left
		jz @@MoveInSubLeft
		cmp al, 9Dh ; alt+right
		jz @@MoveSubRight
		cmp al, 9Bh ; alt+left
		jz @@MoveSubLeft
		jmp @@StartInput
		@@MoveInSubRight:
			cmp bh, 1
			jc @@MoveInSubFileRight
			ja @@MoveInSubHelpRight
			@@MoveInSubEditRight:
				jmp @@EditMenuCheck
			@@MoveInSubFileRight:
				cmp bl, 2
				jz @@MaxBL
				inc bl
				jmp @@FileMenuCheck
			@@MoveInSubHelpRight:
				cmp bl, 1
				jz @@MaxBL
				inc bl
				jmp @@HelpMenuBLIs1
			@@MaxBL:
				xor bl, bl
				jmp @@CheckBH
		@@MoveInSubLeft:
			cmp bh, 1
			jc @@MoveInSubFileLeft
			ja @@MoveInSubHelpLeft
			@@MoveInSubEditLeft:
				jmp @@EditMenuCheck
			@@MoveInSubFileLeft:
				cmp bl, 0
				jz @@MinBL2
				dec bl
				jmp @@FileMenuCheck
			@@MoveInSubHelpLeft:
				cmp bl, 0
				jz @@MinBL1
				dec bl
				jmp @@HelpMenuCheck
			@@MinBL2:
				mov bl, 2
				jmp @@CheckBH
			@@MinBL1:
				inc bl
				jmp @@CheckBH
		@@MoveSubRight:
			cmp bh, 1
			ja @@MaxBH
			inc bh
			jmp @@CheckBH
			@@MaxBH:
				xor bh, bh
				jmp @@CheckBH
		@@MoveSubLeft:
			cmp bh, 1
			jc @@MinBH
			dec bh
			jmp @@CheckBH
			@@MinBH:
				mov bh, 2
				jmp @@CheckBH
	@@Select:
		cmp bh, 1
		jc @@SelectInFile
		ja @@SelectInHelp
		@@SelectInEdit:
			@@InEditSelectDelete:
				call DeleteMessageBuffer
				jmp @@Return
		@@SelectInFile:
			cmp bl, 1
			jc @@InFileSelectNew
			ja @@InFileSelectSave
			@@InFileSelectOpen:
				completeOpenFile
				jmp @@Return
			@@InFileSelectNew:
				completeNewFile
				jmp @@Return
			@@InFileSelectSave:
				completeSaveFile
				jmp @@Return
		@@SelectInHelp:
			cmp bl, 1
			jz @@InHelpSelectAbout
			@@InHelpSelectHelp:
				push offset helpString 0
				call PrintSecondPage
				jmp @@Return
			@@InHelpSelectAbout:
				push offset aboutString 7
				call PrintSecondPage
				jmp @@Return
	@@Return:
		popf
		pop bx ax
		pop bp
		ret 2
MenuMode	endp

StringToPrint	equ	[bp+6]
RowToPrint		equ	[bp+4]
PrintSecondPage	proc
		push bp
		mov bp, sp
		push ax cx dx si
		pushf
		mov ah, 5
		mov al, 1
		int 10h
		call ClearScreen
		mov ah, 2
		mov bh, 1
		mov dh, RowToPrint
		xor dl, dl
		int 10h
		mov ah, 9
		mov dx, StringToPrint
		int 21h
		mov ah, 7
		int 21h
		mov ah, 5
		xor al, al
		int 10h
		setCursorToCurrData
		popf
		pop si dx cx ax
		pop bp
		ret 4
PrintSecondPage	endp

; Upon request of exit, asks user whether to save the file or not.
CheckSave	proc
		push ax dx
		pushf
	@@PrintStart:
		mov ah, 9
		lea dx, checkSaveS
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
		lea dx, checkSaveE
		int 21h
		jmp @@PrintStart
	@@Yes:
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
		push offset menuType offset menuColor 0
		call PrintBar
		call MainInput
		call CloseFile
	Stop:
		mov ah, 4Ch
		int 21h
code	ends
end 	Start