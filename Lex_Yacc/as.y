%union {
	int nombre;
    char id[30];
}
%{
#include "../Tables/Symboles/table_symboles.h"
#include <stdio.h> 
#include <string.h>
#include <stdlib.h>
#include "../Tables/Instructions/tab_instruc.h"
#define TAILLE 1024

enum type_t type_courant;

int instructions_ligne_to_patch[10][20];
int nbs_instructions_to_patch[10];

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
%token<nombre> tIF tWHILE tELSE
%token tLT tGT tEQCOND
%token tAND tOR

%left tAND tOR
%left tNOT
%left tLT tGT
%left tEQCOND
%left tADD tSUB
%left tMUL tDIV

%type<nombre> E Invocation



//%type<nombre> E

/******************************************** FAIRE LA GENERATION DU CODE ASSEMBLEUR DANS UN TABLEAU AVEC UN FPRINTF *******************/

%%

Main : tINT tMAIN tOBRACE Params tCBRACE Body { print(); create_asm();} ; 

Params : { printf("Sans Params\n"); } ;
Params : Param SuiteParams ;
Param : DeclType tID { printf("Prametre : %s\n", $2); };
SuiteParams : tCOMA Param SuiteParams ;
SuiteParams : ;

Body : tOBRACKET Instructions tCBRACKET { } ;


Instructions : Instruction Instructions ;
Instructions : ;
Instruction : Aff {reset_temp_vars();};
Instruction : Decl {reset_temp_vars();};
Instruction : Invocation tPV{reset_temp_vars();};
Instruction : If {reset_temp_vars();};
Instruction : While {reset_temp_vars();};

//On considère que la première ligne du code en ASM est la ligne 0
If : tIF tOBRACE E tCBRACE { profondeur++;
add_operation(JMF,$3,0,0); $1 = get_current_index() - 1;} 
Body  {int current = get_current_index();
		patch($1,current + 1);
		add_operation(JMP,0,0,0);
		instructions_ligne_to_patch[profondeur][nbs_instructions_to_patch[profondeur]] = current;
		nbs_instructions_to_patch[profondeur]++;}
Else { printf("If reconnu\n");  reset_pronf(); profondeur--;};


//On considère que la première ligne du code en ASM est la ligne 0
ElseIf : tIF tOBRACE E tCBRACE {add_operation(JMF,$3,0,0); $1 = get_current_index() - 1;} 
Body  {int current = get_current_index();
		patch($1,current + 1);
		add_operation(JMP,0,0,0);
		instructions_ligne_to_patch[profondeur][nbs_instructions_to_patch[profondeur]] = current;
		nbs_instructions_to_patch[profondeur]++;}
Else { printf("If reconnu\n");};




Else : tELSE ElseIf { printf("Else if reconnu\n"); };
Else : tELSE Body { printf("Else reconnu\n"); int current = get_current_index(); 
for (int i = 0; i< nbs_instructions_to_patch[profondeur]; i++){
	patch(instructions_ligne_to_patch[profondeur][i],current);
}
nbs_instructions_to_patch[profondeur] = 0;
};
Else : {int current = get_current_index(); 
for (int i = 0; i< nbs_instructions_to_patch[profondeur]; i++){
	patch(instructions_ligne_to_patch[profondeur][i],current);
}
nbs_instructions_to_patch[profondeur] = 0;};
While : tWHILE tOBRACE E tCBRACE {profondeur++;
add_operation(JMF,$3,0,0); 
$1 = get_current_index() - 1;}

Body { printf("While reconnu\n");
int current = get_current_index();
patch($1,current + 1);
add_operation(JMP,$1,0,0);
reset_pronf(); profondeur--;};


Aff : tID tEQ E tPV { printf("%s prend une valeur\n", $1); struct symbole_t * symbole  = get_variable($1); symbole->initialized = 1; add_operation(COP, symbole->adresse, $3,0);} ; //besoin de get_address

E : tNB { int addr = allocate_mem_temp_var(INT); add_operation(AFC, addr,$1,0); $$ = addr;};

E : tNBEXP { printf("Nombre exp\n"); int addr = allocate_mem_temp_var(INT); add_operation(AFC, addr,$1,0); $$ = addr;};
E : tID { printf("Id\n"); struct symbole_t * symbole  = get_variable($1); int addr = allocate_mem_temp_var(symbole->type); add_operation(COP, addr,symbole->adresse,0); $$=addr;};
E : E tMUL E { printf("Mul\n"); int addr = allocate_mem_temp_var(INT); add_operation(MUL, addr,$1,$3); $$ = addr;};
E : E tDIV E { printf("Div\n"); int addr = allocate_mem_temp_var(INT); add_operation(DIV, addr,$1,$3); $$ = addr;};
E : E tSUB E { printf("Sub\n"); int addr = allocate_mem_temp_var(INT); add_operation(SOU, addr,$1,$3); $$ = addr;};
E : E tADD E { printf("Add\n"); int addr = allocate_mem_temp_var(INT); add_operation(ADD, addr,$1,$3); $$ = addr;};
E : Invocation { printf("Invoc\n"); int addr = allocate_mem_temp_var(INT); add_operation(AFC, addr,$1,0); $$ = addr;};
E : tOBRACE E tCBRACE { printf("Parentheses\n"); $$=$2;};
E : tSUB E { printf("Moins\n"); int addr = allocate_mem_temp_var(INT); add_operation(SOU, 0,addr,0); $$ = addr;};
E : E tEQCOND E { printf("==\n"); int addr = allocate_mem_temp_var(INT); add_operation(EQU, addr,$1,$3); $$ = addr;};
E : E tGT E { printf(">\n"); int addr = allocate_mem_temp_var(INT); add_operation(SUP, addr,$1,$3); $$ = addr;};
E : E tLT E { printf("<\n"); int addr = allocate_mem_temp_var(INT); add_operation(INF, addr,$1,$3); $$ = addr;};
E : tNOT E { printf("!\n"); };
E : E tAND E {int addr = allocate_mem_temp_var(INT); add_operation(MUL, addr, $1, $3); $$=addr;};
E : E tOR E {int addr = allocate_mem_temp_var(INT); add_operation(ADD, addr, $1, $3); $$=addr;} ;



//Créer un champ isConst dans la table des symboles
DeclType : tINT {type_courant = INT; printf("Type int\n");} ;

Decl : DeclType SuiteDecl FinDecl ;
Decl : tCONST DeclType SuiteDeclConst FinDeclConst;

SuiteDecl : tID {push($1, 0, type_courant); printf("Suite Decl\n");};
SuiteDecl : tID tEQ E {int addr = push($1,1, type_courant); add_operation(COP, addr,$3,0);};
FinDecl : tPV { printf("Fin Decl\n");};
FinDecl : tCOMA SuiteDecl FinDecl ;

SuiteDeclConst : tID tEQ E {int addr = push($1,1, type_courant); add_operation(COP, addr,$3,0);};
FinDeclConst : tPV;
FinDeclConst : tCOMA SuiteDeclConst FinDeclConst;


/* //Créer un champ isConst dans la table des symboles
DeclType : tINT {type_courant = INT; printf("Type int\n");} ;

Decl : tCONST DeclType SuiteDeclConst { } ;
SuiteDeclConst : tCOMA tID SuiteDeclConst ;
SuiteDeclConst : tEQ E tPV { };
SuiteDeclConst : tPV { };


Decl : DeclType Decl SuiteDecl { } ;
Decl : tID {push($1, 0, type_courant);};
Decl : tID tEQ E {int addr = push($1,1, type_courant); add_operation(AFC, addr,$3,0);} ;
SuiteDecl : tCOMA Decl SuiteDecl { };
SuiteDecl : tPV { };
*/

Invocation : tPRINTF tOBRACE tID tCBRACE { printf("Appel de printf sur %s\n", $3); } ;

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
