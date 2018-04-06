#**************************************************************************
# MBS 2018 - PRACTICE 2 - MAKEFILE
# Team number:
# 4
#
# Authors names:
# - Blanca Martin Selgas
# - Fernando Villar Gomez
#**************************************************************************

all: dec2asc.exe Labs2a.exe Labs2b.exe

dec2asc.exe: dec2asc.obj
	tlink /v dec2asc
dec2asc.obj: dec2asc.asm
	tasm /zi dec2asc.asm
	
Labs2a.exe: Labs2a.obj
	tlink /v Labs2a
Labs2a.obj: Labs2a.asm
	tasm /zi Labs2a.asm
	
Labs2b.exe: Labs2b.obj
	tlink /v Labs2b
Labs2b.obj: Labs2b.asm
	tasm /zi Labs2b.asm