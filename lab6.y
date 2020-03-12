/*
The yacc file reads tokens taken from lex and parses them according to the
ALGOL-C grammar structure. All constants will be emitted through stderr and if
there is an error it will be emmitted through stderr as well as the line number.

This yacc routine will exit as soon as an error is encountered.

ALGOL-C ignores whitespaces and newlines so if there is a lot of empty lines to
to space out a program line counts may be inaccurate for errors. for example, a mispelled END token will be parsed as an ID and the routine will not detect an
error until, most likely, the next token, even if it is several empty newlines
away. See test.al for an example. The error is on line 10 but the routine will
not emit an error until line 12.

Michael Smith
March 2020
*/
%{
#include <stdio.h>
#include <ctype.h>
#include "ast.h"
#include "ast.c"
#include "lex.yy.c"

int mydebug = 0;

extern int line;

void yyerror (s)
	char *s;
{
	fprintf(stderr, "error on line %d: %s\nAborting...\n", line, s);
	exit(0);

}

ASTnode * globalTreePointer;

%}

%start program

%union {
	char * string;
	int value;
	ASTnode * node;
	enum OPERATORS operator;
}

%token ID NUM INT VOID BOOLEAN BEG END IF THEN ELSE WHILE DO RET READ WRITE
%token LE LT GE GT EQ NE
%token AND OR TRUE FALSE NOT

%type<value> NUM
%type<string> ID
%type<node> program decls_list dec var_dec fun_dec var_list params compound_stmt
param_list param stmt_list local_decs expression_stmt selection_stmt iteration_stmt assignment_stmt return_stmt read_stmt write_stmt stmt expression simple_expression additive_expression term factor call variable
%type<operator> type_spec


%%

program		:	decls_list	 
			{
				$$ = $1;
				globalTreePointer = $$;
			}
		;

decls_list 	:	dec
	    		{
				$$ = $1;
			}

	   	|	dec decls_list
			{
				$1->next = $2;
				$$ = $1;
			}
		;

dec		:	var_dec
     			{
				$$ = $1;
			}

     		|	fun_dec
			{
				$$ = $1;
			}
		;

var_dec		:	type_spec var_list ';'
	 		{		
				ASTnode * p = $2;
				while(p != NULL) {
					p->operator = $1;
					p = p->s1;
				}
				$$ = $2;
				
			}
	 	;

var_list	:	ID
	 		{
				$$ = ASTCreateNode(VARDEC);
				$$->name = $1;
			}
	 	|	ID '[' NUM ']'
			{
				
				$$ = ASTCreateNode(VARDEC);
				$$->name = $1;
				$$->value = $3;
			}
		|	ID ',' var_list
			{	
				$$ = ASTCreateNode(VARDEC);
				$$->name = $1;
				$$->s1 = $3;	
			} 
		|	ID '[' NUM ']' ',' var_list
			{	
				$$ = ASTCreateNode(VARDEC);
				$$->name = $1;
				$$->value = $3;
				$$->s1 = $6;
			}
		;

type_spec	:	INT
	  		{
				$$ = INTTYPE;
			}
	  	|	VOID
			{
				$$ = VOIDTYPE;
			}
		|	BOOLEAN
			{
				$$ = BOOLTYPE;
			}
	  	;

fun_dec		:	type_spec ID '(' params ')' compound_stmt
	 		{
				$$ = ASTCreateNode(FUNDEC);
				$$->name = $2;
				$$->operator = $1;
				$$->s1 = $4;
				$$->s2 = $6;
			}
	 	;

params		:	VOID
			{
				$$ = NULL;
			}
		|	param_list
			{
				$$ = $1;
			}
		;

param_list	:	param
	   		{
				$$ = $1;
			}
	   	|	param ',' param_list
			{
				$1->next = $3;
				$$ = $1;
			}
		;

param		:	type_spec ID
       			{
				$$ = ASTCreateNode(PARAM);
				$$->operator = $1;
				$$->name = $2;
				$$->value = 0;
			}
       		|	type_spec ID '[' ']'
			{
				$$ = ASTCreateNode(PARAM);
				$$->operator = $1;
				$$->name = $2;
				$$->value = -1;
			}
       		;

compound_stmt	:	BEG local_decs stmt_list END
	      		{
				
				$$ = ASTCreateNode(BLOCK);
				$$->s1 = $2;
				$$->s2 = $3;
			}
	      	;

local_decs	:	/*nothing*/
	   		{
				$$ = NULL;
			}
	   	|	var_dec local_decs
			{
				$$ = $1;
				$$->next = $2;
			}
		;

stmt_list	:	/*nothing*/
	  		{
				
				$$ = NULL;
			}
	  	|	stmt stmt_list
			{
				
				$$ = $1;
				$$->next = $2;
			}
		;

stmt		:	expression_stmt
      			{
				$$ = $1;
			}
      		|	compound_stmt
			{
				$$ = $1;
			}
		|	selection_stmt
			{
				$$ = $1;
			}
		|	iteration_stmt
			{
				$$ = $1;
			}
		|	assignment_stmt
			{
				$$ = $1;
			}
		|	return_stmt
			{
				$$ = $1;
			}
		|	read_stmt
			{
				$$ = $1;
			}
		|	write_stmt
			{
				$$ = $1;
			}
		;

expression_stmt	:	expression ';'
			{
				$$ = ASTCreateNode(EXPRSTMT);
				$$->s1 = $1;
			}
		|	';'
			{
				$$ = NULL;
			}
		;

selection_stmt	:	IF expression THEN stmt
	       		{
				$$ = NULL;
			}
	       	|	IF expression THEN stmt ELSE stmt
			{
				$$ = NULL;
			}
		;

iteration_stmt	:	WHILE expression DO stmt
	       		{
				$$ = NULL;
			}
	       	;

return_stmt	:	RET ';'
	    		{
				$$ = NULL;
			}
	    	|	RET expression ';'
			{
				$$ = NULL;
			}
		;

read_stmt	:	READ variable ';'
	  		{
				$$ = NULL;
			}
	  	;

write_stmt	:	WRITE expression ';'
	   		{
				$$ = NULL;
			}
	   	;

assignment_stmt	:	variable '=' simple_expression ';'
			{
				$$ = ASTCreateNode(ASSIGN);
				$$->s1 = $3;
			}
		;

expression	:	simple_expression
	   		{
				$$ = $1;
			}
	   	;

variable	:	ID
	 		{
				$$ = ASTCreateNode(IDENT);
				$$->name = $1;
			}
	 	|	ID '[' expression ']'
			{
				$$ = NULL;
			}
		;

simple_expression	:	additive_expression
		  		{
					//printf("hello");
					$$ = $1;
				}
		  	|	additive_expression relop additive_expression
				{
					$$ = NULL;
				}
			;

relop		:	LE
       		|	LT
		|	GT
		|	GE
		|	EQ
		|	NE
		;

additive_expression	:	term
		    		{
					$$ = $1;
				}
			|	term addop additive_expression
				{
					$$ = NULL;
				}
			;

addop		:	'+'
       		|	'-'
		;

term		:	factor
      			{
				$$ = $1;
			}
		|	factor multop term
			{
				$$ = NULL;
			}
		;

multop		:	'*'
		|	'/'
		|	AND
		|	OR
		;

factor		:	'(' expression	')'
			{
				$$ = $2;
			}
		|	NUM
			{
				$$ = ASTCreateNode(NUMBER);
				$$->value = $1;
			}
		|	variable
			{
				$$ = NULL;
			}
		|	call
			{
				$$ = NULL;
			}
		|	TRUE
			{
				$$ = NULL;
			}
		|	FALSE
			{
				$$ = NULL;
			}
		|	NOT factor
			{
				$$ = NULL;
			}
		;

call		:	ID '(' args ')'
			{
				$$ = NULL;
			}      
		;

args		:	arg_list
		;

arg_list	:	expression
	 	|	expression ',' arg_list
		;

%%		

int main(void) {
	yyparse();
	fprintf(stderr, "No errors found\n");
	printf("Abstract Syntax Tree:\n\n");
	ASTprint(0, globalTreePointer);
	return 1;
}

