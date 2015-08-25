IF [%1]==[] GOTO NoParameter
IF NOT [%1]==[] GOTO Parameter
:NoParameter
STRINGS Name= ASK ASM file name (exclude .ASM):  
IF [%Name%]==[] ECHO Null input
IF [%Name%]==[] GOTO End
TASM	/ZI	%Name%
IF ERRORLEVEL 1	GOTO End
TLINK	/v	%Name%
IF ERRORLEVEL 1	GOTO End
TD		%Name%
GOTO	End
:Parameter
TASM	/ZI	%1
IF ERRORLEVEL 1	GOTO End
TLINK	/v	%1
IF ERRORLEVEL 1	GOTO End
TD		%1
:End