/*
 * This yacc routine takes tokens from lex and parses them according to the
 * ALGOL-C language. It takes semantic action depending on syntax recieved.
 * The semantic actions taken are actions to create the nodes of an abstract
 * syntax tree. When parsing is completed the abstact syntax tree is printed.
 *
 * If a syntax error is encounterd in the input program then the routine
 * immediately exits and a line number with the error is emmitted. CAUTION
 * the line number emmitted is not always the line the error has occured.
 * Since ALGOL-C ignores whitespace, the error may point the line of first
 * token after the actual error.
 *
 * Michael Smith
 * April 2020
 */

%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include "ast.h"

int mydebug = 0;

extern int line;

void yyerror (s)
	char *s;
{
	fprintf(stderr, "error on line %d: %s\nAborting...\n", line, s);
	exit(1);

}

int yylex(void);

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
%type<node> param_list param stmt_list local_decs expression_stmt selection_stmt
%type<node> iteration_stmt assignment_stmt return_stmt read_stmt write_stmt stmt
%type<node> expression simple_expression additive_expression term factor call
%type<node> variable args arg_list
%type<operator> type_spec relop addop multop


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
				$$ = ASTCreateNode(EXPRSTMT);
			}
		;

selection_stmt	:	IF expression THEN stmt
	       		{
				$$ = ASTCreateNode(IFBLOCK);
				$$->s1 = $2;
				$$->s2 = ASTCreateNode(IFELSESTMTS);
				$$->s2->s1 = $4;
				$$->s2->s2 = NULL; 
			}
	       	|	IF expression THEN stmt ELSE stmt
			{
				$$ = ASTCreateNode(IFBLOCK);
				$$->s1 = $2;
				$$->s2 = ASTCreateNode(IFELSESTMTS);
				$$->s2->s1 = $4;
				$$->s2->s2 = $6;
			}
		;

iteration_stmt	:	WHILE expression DO stmt
	       		{
				$$ = ASTCreateNode(WHILEBLOCK);
				$$->s1 = $2;
				$$->s2 = $4;
			}
	       	;

return_stmt	:	RET ';'
	    		{
				$$ = ASTCreateNode(FUNRET);
			}
	    	|	RET expression ';'
			{
				$$ = ASTCreateNode(FUNRET);
				$$->s1 = $2;
			}
		;

read_stmt	:	READ variable ';'
	  		{
				$$ = ASTCreateNode(READSTMT);
				$$->s1 = $2;
			}
	  	;

write_stmt	:	WRITE expression ';'
	   		{
				$$ = ASTCreateNode(WRITESTMT);
				$$->s1 = $2;
			}
	   	;

assignment_stmt	:	variable '=' simple_expression ';'
			{
				$$ = ASTCreateNode(ASSIGN);
				$$->s1 = $1;
				$$->s2 = $3;
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
				$$ = ASTCreateNode(IDENT);
				$$->name = $1;
				$$->s1 = $3;
				$$->value = $3->value;
			}
		;

simple_expression	:	additive_expression
		  		{
					$$ = $1;
				}
		  	|	simple_expression relop additive_expression
				{
					$$ = ASTCreateNode(EXPR);
					$$->s1 = $1;
					$$->s2 = $3;
					$$->operator = $2;
				}
			;

relop		:	LE
       			{
				$$ = LESSTHANOREQUAL;
			}
       		|	LT
			{
				$$ = LESSTHAN;
			}
		|	GT
			{
				$$ = GREATERTHAN;
			}
		|	GE
			{
				$$ = GREATERTHANOREQUAL;
			}
		|	EQ
			{
				$$ = EQUAL;
			}				
		|	NE
			{
				$$ = NOTEQUAL;
			}
		;

additive_expression	:	term
		    		{
					$$ = $1;
				}
			|	additive_expression addop term
				{
					$$ = ASTCreateNode(EXPR);
					$$->s1 = $1;
					$$->s2 = $3;
					$$->operator = $2;
				}
			;

addop		:	'+'
       			{
				$$ = PLUS;
			}
       		|	'-'
			{
				$$ = MINUS;
			}
		;

term		:	factor
      			{
				$$ = $1;
			}
		|	term multop factor
			{
				$$ = ASTCreateNode(MULTOPTERM);
				$$->s1 = $1;
				$$->s2 = $3;
				$$->operator = $2;
			}
		;

multop		:	'*'
			{
				$$ = MULT;
			}
		|	'/'
			{
				$$ = DIV;
			}
		|	AND
			{
				$$ = EXPRAND;
			}
		|	OR
			{
				$$ = EXPROR;
			}
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
				$$ = $1;
			}
		|	call
			{
				$$ = $1;
			}
		|	TRUE
			{
				$$ = ASTCreateNode(NUMBER);
				$$->value = 1;
			}
		|	FALSE
			{
				$$ = ASTCreateNode(NUMBER);
				$$->value = 0;
			}
		|	NOT factor
			{
				$$ = ASTCreateNode(EXPR);
				$$->operator = EXPRNOT;
				$$->s1 = $2;
			}
		;

call		:	ID '(' args ')'
			{
				$$ = ASTCreateNode(CALL);
				$$->s1 = $3;
				$$->name = $1;
			}      
		;

args		:	arg_list
      			{
				$$ = $1;
			}
		|	/*empty*/
			{
				$$ = NULL;
			}
		;

arg_list	:	expression
	 		{
				$$ = ASTCreateNode(ARG);
				$$->s1 = $1;
			}
	 	|	expression ',' arg_list
			{
				$$ = ASTCreateNode(ARG);
				$$->s1 = $1;
				$$->next = $3;
			}
		;

%%		

int main(void) {
	yyparse();
	fprintf(stderr, "No errors found\n");
	printf("Abstract Syntax Tree:\n\n");
	ASTprint(0, globalTreePointer);
	return 1;
}

