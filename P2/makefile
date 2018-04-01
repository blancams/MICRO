all: dec2asc.exe

dec2asc.exe: dec2asc.obj
	tlink /v dec2asc
dec2asc.obj: dec2asc.asm
	tasm /zi dec2asc.asm