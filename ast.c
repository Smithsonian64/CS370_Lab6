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

void ASTprint(int level, ASTnode *p) {

	int i;
	if(p == NULL) return;
	else {
		switch (p->type) {
			case VARDEC :
				printf("Variable ");
				switch (p-> operator) {
					case VOIDTYPE : 
						printf("VOID ");
						break;
					case INTTYPE : 
						printf("INT ");
						break;
					case BOOLTYPE : 
						printf("BOOLEAN ");
						break;
					default : printf("invalid type");
				}
                      		printf(" %s",p->name);
                     		if (p->value > 0)
                        		printf("[%d]",p->value);
                     		printf("\n");
     				ASTprint(level,p->s1);
				break;
			
			case FUNDEC :	
				printf("Function ");
				switch (p->operator) {
					case VOIDTYPE : 
						printf("VOID ");
						break;
					case INTTYPE : 
						printf("INT ");
						break;
					case BOOLTYPE : 
						printf("BOOLEAN ");
						break;
					default : printf("invalid type");
				}
				printf("%s", p->name);
				if(p->s1 != NULL) {
					printf("\n(\n");
					ASTprint(level, p->s1);
					printf(")");
				}
				printf("\n");
				ASTprint(level, p->s2);
				printf("\n");
				break;	
			case PARAM :	
				printf("Parameter ");
				switch (p->operator) {
					case VOIDTYPE : 
						printf("VOID ");
						break;
					case INTTYPE : 
						printf("INT ");
						break;
					case BOOLTYPE : 
						printf("BOOLEAN ");
						break;
					default : printf("invalid type");
				}	
				printf("%s", p->name);
				if(p->value == -1) printf("[]");
				printf("\n");
				break;
			case BLOCK:
				printf("Block statment\n");
				ASTprint(level, p->s1);
				ASTprint(level, p->s2);
				printf("\n");
				break;
			default : printf("Unknown type\n");
		}
	}
	ASTprint(level, p->next);

}
