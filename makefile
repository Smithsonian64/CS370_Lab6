#Lab6
#Michael Smith
#March 2020
#Lab6 parses by an input file and prints the abstract syntax tree according to
#ALGOL-C grammar and return the line number of the first error
#input: input file
#output: Abstract syntax tree and the first of if any errors
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




