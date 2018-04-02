all: dec2asc.exe Labs2a.exe

dec2asc.exe: dec2asc.obj
	tlink /v dec2asc
dec2asc.obj: dec2asc.asm
	tasm /zi dec2asc.asm
	
Labs2a.exe: Labs2a.obj
	tlink /v Labs2a
Labs2a.obj: Labs2a.asm
	tasm /zi Labs2a.asm