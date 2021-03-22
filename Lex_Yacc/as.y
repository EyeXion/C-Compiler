%union {
	int nombre;
    char id[30];
}
%{
#include "../Symboles/table_symboles.h"
#include <stdio.h> 
#include <string.h>
#include <stdlib.h>

int addr = 0;

%}

%token tMAIN
%token tOBRACKET tCBRACKET
%token tOBRACE tCBRACE
%token tINT
%token tCONST
%token tPV tCOMA#include <string.h>
%token tMUL tDIV tADD tSUB tEQ
%token<nombre> tNB tNBEXP
%token<id> tID
%token tPRINTF
%token tERROR
%token tIF tWHILE tELSE
%token tLT tGT tEQCOND
%token tAND tOR

%left tAND tOR
%left tNOT
%left tLT tGT
%left tEQCOND
%left tADD tSUB
%left tMUL tDIV



//%type<nombre> E

/******************************************** FAIRE LA GENERATION DU CODE ASSEMBLEUR DANS UN TABLEAU AVEC UN FPRINTF *******************/

%%

Main : tINT tMAIN tOBRACE Params tCBRACE Body { print(pile);  printf("addr = %d\n",addr);} ; 

Params : { printf("Sans Params\n"); } ;
Params : Param SuiteParams ;
Param : tINT tID { printf("Prametre : %s\n", $2); };
SuiteParams : tCOMA Param SuiteParams ;
SuiteParams : ;

Body : tOBRACKET Instructions tCBRACKET { struct symbole_t symbole = {"Salut", 0x77b58af, INT, 1}; push(symbole, pile); } ;


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


Aff : tID tEQ E tPV { printf("%s prend une valeur\n", $1);} ; //besoin de get_address

E : tNB { printf("Nombre\n"); 
 struct symbole_t symbole = ("", addr, INT, 1};
 push(symbole, pile); 
$$=addr;
  addr++;
 printf("AFC %d %d",addr,$1); } ;

E : tNBEXP { printf("Nombre exp\n"); struct symbole_t symbole = {"", addr, INT, 1}; push(symbole, pile); $$=addr;  addr++; printf("AFC %d %d",addr,$1); };
E : tID { printf("Id\n"); /*Faire un get_address sur la pile*/};
E : E tMUL E { printf("Mul\n"); struct symbole_t symbole = {"", addr, INT, 1}; push(symbole, pile); $$=addr;  addr++; printf("MUL %d %d %d",addr, $1,$2);};
E : E tDIV E { printf("Div\n"); struct symbole_t symbole = {"", addr, INT, 1}; push(symbole, pile); $$=addr;  addr++; printf("DIV %d %d %d",addr, $1,$2);};
E : E tSUB E { printf("Sub\n"); struct symbole_t symbole = {"", addr, INT, 1}; push(symbole, pile); $$=addr;  addr++; printf("SOU %d %d %d",addr, $1,$2);};
E : E tADD E { printf("Add\n"); struct symbole_t symbole = {"", addr, INT, 1}; push(symbole, pile); $$=addr;  addr++; printf("ADD %d %d %d",addr, $1,$2);}};
E : Invocation { printf("Invoc\n"); struct symbole_t symbole = {"", addr, INT, 1}; push(symbole, pile); $$=addr;  addr++; printf("AFC %d %d",addr, $1);};
E : tOBRACE E tCBRACE { printf("Parentheses\n"); $$=$2};
E : tSUB E { printf("Moins\n"); printf("SUB %d 0 %d",addr,$2);};
E : E tEQCOND E { printf("==\n"); struct symbole_t symbole = {"", addr, INT, 1}; push(symbole, pile); $$=addr;  addr++; printf("EQU %d %d %d",addr, $1,$3);};
E : E tGT E { printf(">\n"); struct symbole_t symbole = {"", addr, INT, 1}; push(symbole, pile); $$=addr;  addr++; printf("SUP %d %d %d",addr, $1,$3);};
E : E tLT E { printf("<\n"); struct symbole_t symbole = {"", addr, INT, 1}; push(symbole, pile); $$=addr;  addr++; printf("SUP %d %d %d",addr, $1,$3);};
E : tNOT E { printf("!\n"); };



//Créer un champ isConst dans la table des symboles
Decl : tCONST tINT tID SuiteDeclConst { int init = ($3 != -1); 
 if (init){
    int val = *$2;
    printf("AFC %ld %d",addr,val);
 }
struct symbole_t symbole = {$2, addr, INT, init};
push(symbole, pile); 
addr++;} ;
SuiteDeclConst : tCOMA tID SuiteDecl { $$=$3; int init = ($3 != -1); 
 if (init){
    int val = *$2;
    printf("AFC %ld %d",addr,val);
 }
struct symbole_t symbole = {$2, addr, INT, init}; push(symbole, pile); addr++;};
SuiteDeclConst : tEQ E tPV { $$=$2; };
SuiteDeclConst : tPV { $$=$2; };

Decl : tINT tID SuiteDecl { int init = ($3 != -1);
 if (init){
    int val = *$2;
    printf("AFC %ld %d",addr,val);
 }
 struct symbole_t symbole = {$2, addr, INT, init}; 
push(symbole, pile); 
addr++;} ;
SuiteDecl : tCOMA tID SuiteDecl
 { $$=$3; 
 int init = ($3 != -1);
 if (init){
    int val = *$2;
    printf("AFC %ld %d",addr,val);
 }
 struct symbole_t symbole = {$2, addr, INT, init};
 push(symbole, pile); 
 addr++;};
SuiteDecl : tEQ E tPV { $$=$2;};
SuiteDecl : tPV { $$=$2; };

Invocation : tPRINTF tOBRACE  tID tCBRACE { printf("Appel de printf sur %s\n", $3); } ;

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
void main(void) {
    init();
	yyparse();
}
