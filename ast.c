/*
 * Implementation file of the functions prototyped in ast.h.
 * 
 * ASTCreateNode() creates a node and initializes the branches s1 and s2
 * to NULL and sets the type data member to the type defined as the parameter.
 * It then returns the created node.
 *
 * ASTprint() prints out the abstract syntax tree by traversing down the tree
 * starting at a paramater passed ASTnode. It looks for the types defined 
 * at each node and does different printing operations depending on the type.
 *
 * ASTIndent() helps indent in ASTprint()
 *
 * When the AST is printed multops are executed viertically in the the tree and
 * and addops are executed laterally in the tree. This is to allow for the 
 * the order of operations. 
 *
 * Michael Smith 
 * April 2020
 */

#include <stdio.h>
#include <malloc.h>
#include "ast.h"

ASTnode * ASTCreateNode(enum ASTtype targetType) {

	ASTnode * p;
	p=(ASTnode *)malloc(sizeof(ASTnode));
	p->type = targetType;
	p->s1 = NULL;
	p->s2 = NULL;
	return p;
}

void ASTIndent(int x) {

	if(x < 0) return;

	for(int i = 0; i < x; i++) printf(" ");

}

void ASTprintOperator(enum OPERATORS type) {
	switch (type) {
		case VOIDTYPE:
			printf("VOID ");
			break;
		case INTTYPE:
			printf("INT ");
			break;
		case BOOLTYPE:
			printf("BOOLEAN ");
			break;
		case PLUS:
			printf("Operator +");
			break;
		case MINUS:
			printf("Operator -");
			break;
		case LESSTHAN:
			printf("Operator <");
			break;
		case LESSTHANOREQUAL:
			printf("Operator <=");
			break;
		case GREATERTHAN:
			printf("Operator >");
			break;
		case GREATERTHANOREQUAL:
			printf("Operator >=");
			break;
		case EQUAL:
			printf("Operator ==");
			break;
		case NOTEQUAL:
			printf("Operator !=");
			break;
		case MULT:
			printf("Operator *");
			break;
		case DIV:
			printf("Operator /");
			break;
		case EXPRAND:
			printf("Opearator and");
			break;
		case EXPROR:
			printf("Operator or");
			break;
		case EXPRNOT:
			printf("Operator not");
			break;
		default:
			printf("Unknown Operator");
	}
}

void ASTprint(int level, ASTnode *p) {

	int i;
	if(p == NULL) return;
	else {
		switch (p->type) {
			case VARDEC :
				ASTIndent(level);
				printf("Variable ");
                      		ASTprintOperator(p->operator);
				printf("%s",p->name);
                     		if (p->value > 0)
                        		printf("[%d]",p->value);
                     		printf("\n");
     				ASTprint(level,p->s1);
				break;
			
			case FUNDEC :	
				ASTIndent(level);
				printf("Function ");
				ASTprintOperator(p->operator);
				printf("%s", p->name);
				if(p->s1 != NULL) {
					printf("\n(\n");
					ASTprint(level + 1, p->s1);
					printf(")");
				}
				else {
					printf("\n(\n");
					printf(")");
				}
				printf("\n");
				ASTprint(level + 1, p->s2);
				printf("\n");
				break;	
			case PARAM :	
				ASTIndent(level);
				printf("Parameter ");
				ASTprintOperator(p->operator);
				printf("%s", p->name);
				if(p->value == -1) printf("[]");
				printf("\n");
				break;
			case BLOCK:
				ASTIndent(level);
				printf("Block statment\n");
				ASTprint(level + 1, p->s1);
				ASTprint(level + 1, p->s2);
				printf("\n");
				break;
			case ASSIGN:
				ASTIndent(level);
				printf("Assignment statment\n");
				ASTprint(level + 1, p->s1);
				ASTprint(level + 2, p->s2);
				break;
			case IDENT:
				ASTIndent(level);
				printf("Identifier ");
				printf("%s\n", p->name);
				if(p->s1 != NULL) {
					ASTIndent(level);
					printf("Array Reference\n");
					ASTIndent(level);
					printf("[\n");
					ASTprint(level + 1, p->s1);
					ASTIndent(level);
					printf("]\n");
				}
				break;
			case NUMBER:
				ASTIndent(level);
				printf("Number ");
				printf("%d\n", p->value);
				break;
			case EXPR:
				ASTIndent(level);
				printf("Expression\n");
				ASTIndent(level);
				ASTprintOperator(p->operator);
				printf("\n");
				ASTprint(level + 1, p->s1);
				ASTprint(level + 1, p->s2);
				break;
			case EXPRSTMT:
				ASTIndent(level);
				printf("Expression Statement\n");
				ASTprint(level + 1, p->s1);
				break;
			case MULTOPTERM:
				ASTIndent(level);
				ASTprintOperator(p->operator);
				printf("\n");
				ASTprint(level + 1, p->s1);
			   	ASTprint(level + 1, p->s2);
				break;
			case CALL:
				ASTIndent(level);
				printf("Call ");
				printf("%s\n", p->name);
				ASTIndent(level);
				printf("(\n");
				ASTprint(level + 1, p->s1);
				ASTIndent(level);
				printf(")\n");
				break;
			case READSTMT:
				ASTIndent(level);
				printf("Read \n");
				ASTprint(level + 1, p->s1);
				break;
			case WRITESTMT:
				ASTIndent(level);
				printf("Write \n");
				ASTprint(level + 1, p->s1);
				break;
			case WHILEBLOCK:
				ASTIndent(level);
				printf("While Block\n");
				ASTIndent(level);
				printf("Condition\n");
				ASTprint(level + 1, p->s1);
				ASTIndent(level);
				printf("Statements\n");
				ASTprint(level + 1, p->s2);
				break;
			case FUNRET:
				if(p->s1 != NULL) {
					ASTIndent(level);
					printf("Return\n");
					ASTIndent(level);
					printf("(\n");
					ASTprint(level + 1, p->s1);
					ASTIndent(level);
					printf(")\n");
				}
				else {
					ASTIndent(level);
					printf("Return\n");
					ASTIndent(level);
					printf("(\n");
					ASTIndent(level);
					printf(")\n");
				}
				break;
			case IFBLOCK:
				ASTIndent(level);
				printf("If Block\n");
				ASTIndent(level);
				printf("Condition\n");
				ASTprint(level + 1, p->s1);
				ASTprint(level, p->s2);
				break;
			case IFELSESTMTS:
				ASTIndent(level);
				printf("Statement\n");
				ASTprint(level + 1, p->s1);
				if(p->s2 != NULL) {
					ASTIndent(level);
					printf("Else Block\n");
					ASTprint(level + 1, p->s2);	
				}
				break;
			case ARG:
				ASTIndent(level);
				printf("Argument\n");
				ASTprint(level + 1, p->s1);
				break;
			default : printf("Unknown type\n");
		}
	}
	ASTprint(level, p->next);

}
