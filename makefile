#Lab6
#Michael Smith
#March 2020
#Lab6 can parse either by user input or an input file
#ALGOL-C grammar and return any errors
#input: user input or input file
#output: indication of any errors
#

all:	lab6

lab6:	y.tab.c
	gcc y.tab.c -o lab6

y.tab.c:check
	lex lab6.l
	yacc -d lab6.y

check:	clean
	gcc ast.h
	rm ast.h.gch
	rm -f a.out

clean:
	rm -f y.tab.c y.tab.h




