#**************************************************************************
# MBS 2018 - PRACTICE 1 - MAKEFILE
# Team number:
# 4
#
# Authors names:
# - Blanca Martin Selgas
# - Fernando Villar Gomez
#**************************************************************************

all: labs1a.exe labs1b.exe labs1c.exe

labs1a.exe: labs1a.obj
	tlink /v labs1a

labs1a.obj: labs1a.asm
	tasm /zi labs1a.asm

labs1b.exe: labs1b.obj
	tlink /v labs1b

labs1b.obj: labs1b.asm
	tasm /zi labs1b.asm

labs1c.exe: labs1c.obj
	tlink /v labs1c

labs1c.obj: labs1c.asm
	tasm /zi labs1c.asm
