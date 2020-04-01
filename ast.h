/*
 * Abstract syntax tree header file. This file outlines the basic structure for
 * the abstract syntax tree data structure created when parsing an input
 * ALGOL-C program. The tree is built from nodes built from a struct type
 * defined as an ASTNode. Nodes contain data members that extend define the
 * abstract syntax tree as a trinary tree and data members that provide
 * information about the current node. An enumeration is created to define the
 * type of the current node called ASTtype and another enumeration define 
 * the type of operation taking place at the current node if applicable.
 * A function to print the abstract syntax tree is defined as ASTprint(), 
 * a function to create a node defined as ASTCreateNode() and a function
 * ASTIndent is defined to help to print function indent.
 *
 * Michael Smith 
 * April 2020
 */

#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <malloc.h>

enum ASTtype {

	VARDEC,
	FUNDEC,
	PARAM,
	BLOCK,
	EXPRSTMT,
	EXPR,
	NUMBER,
	ASSIGN,
	IDENT,
	MULTOPTERM,
	CALL,
	READSTMT,
	WRITESTMT,
	WHILEBLOCK,
	FUNRET,
	IFBLOCK,
	IFELSESTMTS

};

enum OPERATORS {

	BOOLTYPE,
	INTTYPE,
	VOIDTYPE,
	EXPRNOT,
	LESSTHANOREQUAL,
	GREATERTHANOREQUAL,
	EQUAL,
	LESSTHAN,
	GREATERTHAN,
	NOTEQUAL,
	PLUS,
	MINUS,
	MULT,
	DIV,
	EXPRAND,
	EXPROR,

};

typedef struct ASTnode {

	enum ASTtype type;
	char * name;
	int value;
	enum OPERATORS operator;
	struct ASTnode * s1, * s2, * next;

} ASTnode;

ASTnode *  ASTCreateNode(enum ASTtype targetType);

void ASTprint(int level, ASTnode *p);

void ASTIndent(int x);


#endif
