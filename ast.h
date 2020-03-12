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
	IDENT

};

enum OPERATORS {

	BOOLTYPE,
	INTTYPE,
	VOIDTYPE

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


#endif
