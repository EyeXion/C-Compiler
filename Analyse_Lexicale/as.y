%union {
	int nombre;
    char id[30];
}
%{
#include <stdio.h>
%}

%token tMAIN
%token tOBRACKET tCBRACKET
%token tOBRACE tCBRACE
%token tINT
%token tCONST
%token tPV tCOMA
%token tMUL tDIV tADD tSUB tEQ
%token<nombre> tNB tNBEXP
%token<id> tID
%token tPRINTF
%token tERROR
%token tIF tWHILE tELSE
%token tLT tGT tEQCOND
%token tAND tOR

//%type<nombre> E

%%

Main : tINT tMAIN tOBRACE Params tCBRACE Body { printf("Main reconnu\n"); } ; 

Params : { printf("Sans Params\n"); } ;
Params : Param SuiteParams ;
Param : tINT tID { printf("Prametre : %s\n", $2); };
SuiteParams : tCOMA Param SuiteParams ;
SuiteParams : ;

Body : tOBRACKET Instructions tCBRACKET { printf("Body reconnu\n"); } ;


Instructions : Instruction Instructions ;
Instructions : ;
Instruction : Aff ;
Instruction : Decl ;
Instruction : Invocation tPV ;
Instruction : If;
Instruction : While;


If : tIF tOBRACE Cond tCBRACE Body Else { printf("If reconnu\n"); };
Else : tELSE If { printf("Else if reconnu\n"); };
Else : tELSE Body { printf("Else reconnu\n"); };
Else : ;
While : tWHILE tOBRACE Cond tCBRACE Body { printf("While reconnu\n"); };

Cond : E SuiteCond ;
SuiteCond : ;
SuiteCond : tAND E SuiteCond;
SuiteCond : tOR E SuiteCond;


Aff : tID tEQ E tPV { printf("%s prend une valeur\n", $1); } ;

E : tNB ;
E : tNBEXP ;
E : tID ;
E : E tADD E ;
E : E tMUL E ;
E : E tSUB E ;
E : E tDIV E ;
E : Invocation ;
E : tOBRACE E tCBRACE ;
E : tSUB E ;
E : E tEQCOND E;
E : E tGT E;
E : E tLT E;


Decl : tINT tID SuiteDecl FinDeclaration { printf("Declaration de %s\n", $2); } ;
Decl : tCONST tINT tID SuiteDecl tEQ E tPV { printf("Declaration de %s (CONSTANTE)\n", $3); } ;
SuiteDecl : tCOMA tID SuiteDecl { printf("Declaration de %s\n", $2); } ;
SuiteDecl : ;
FinDeclaration : tEQ E tPV { printf("Declaration avec valeur\n"); };
FinDeclaration : tPV { printf("Declaration sans valeur\n"); };

Invocation : tPRINTF tOBRACE  tID  tCBRACE { printf("Appel de printf sur %s\n", $3); } ;

/*S : E tPV
						{ printf("RES: %d\n", $1); }
		S
	|					{ printf("END\n"); }
	;

E : E tADD E	{ $$ = $1 + $3; }
	| E tSUB E	{ $$ = $1 - $3; }
	| tOB E tCB	{ $$ = $2; }
	| tNB				{ $$ = $1; }
	;*/

%%
#include <stdio.h> 
void main(void) {
	yyparse();
}
