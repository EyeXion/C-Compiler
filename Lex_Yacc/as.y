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
#include "../Tables/Fonctions/tab_fonctions.h"
#define TAILLE 1024

struct type_t type_courant;

int instructions_ligne_to_patch[10][20];
int nbs_instructions_to_patch[10];

%}

%token tMAIN
%token tOBRACKET tCBRACKET
%token tOBRACE tCBRACE
%token tOCROCH tCCROCH
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
%token tADDR

%left tLT tGT
%left tEQCOND
%left tAND tOR
%left tNOT
%left tADD tSUB
%left tMUL tDIV

%type<nombre> E DebutAff SuiteAffPointeur DebutAffPointeur EBis ETer



//%type<nombre> E

/******************************************** FAIRE LA GENERATION DU CODE ASSEMBLEUR DANS UN TABLEAU AVEC UN FPRINTF *******************/

%%

Main : tINT tMAIN tOBRACE Params tCBRACE Body { print(); create_asm();} ; 

Params : { printf("Sans Params\n"); } ;
Params : Param SuiteParams ;
Param : Type tID { printf("Parametre : %s\n", $2); };
SuiteParams : tCOMA Param SuiteParams ;
SuiteParams : ;


Args : Arg ArgSuite;
Args : ;
Arg : Type tID {int addr = push($2,1, type_courant);};
ArgSuite : tCOMA Arg ArgSuite {} ;
ArgSuite : ; 


Body : tOBRACKET {inc_prof();} Instructions tCBRACKET {print(); reset_prof();} ;


Instructions : Instruction Instructions ;
Instructions : ;
Instruction : Aff {};
Instruction : Decl {};
//Instruction : Invocation tPV{};
Instruction : If {};
Instruction : While {};

//On considère que la première ligne du code en ASM est la ligne 0
If : tIF tOBRACE E tCBRACE {
add_operation(JMF,$3,0,0); $1 = get_current_index() - 1;} 
Body  {int current = get_current_index();
		patch($1,current + 1);
		add_operation(JMP,0,0,0);
		instructions_ligne_to_patch[get_prof()][nbs_instructions_to_patch[get_prof()]] = current;
		nbs_instructions_to_patch[get_prof()]++;
		pop();}
Else {printf("If reconnu\n");};


Else : tELSE If { printf("Else if reconnu\n"); };
Else : tELSE Body { printf("Else reconnu\n"); int current = get_current_index(); 
for (int i = 0; i< nbs_instructions_to_patch[get_prof()]; i++){
	patch(instructions_ligne_to_patch[get_prof()][i],current);
}
nbs_instructions_to_patch[get_prof()] = 0;
};
Else : {int current = get_current_index(); 
for (int i = 0; i< nbs_instructions_to_patch[get_prof()]; i++){
	patch(instructions_ligne_to_patch[get_prof()][i],current);
}
nbs_instructions_to_patch[get_prof()] = 0;};
While : tWHILE tOBRACE E tCBRACE {
add_operation(JMF,$3,0,0); 
$1 = get_current_index() - 1;
pop();}

Body { printf("While reconnu\n");
int current = get_current_index();
patch($1,current + 1);
add_operation(JMP,$1,0,0);};


Aff : DebutAff tEQ E tPV {add_operation(COP, $1, $3,0); pop();} ; 
Aff : DebutAffPointeur tEQ E tPV {add_operation(WR,$1,$3,0); pop(); pop();};

DebutAff : tID {struct symbole_t * symbole  = get_variable($1); symbole->initialized = 1; $$=symbole->adresse; printf("%s prend une valeur\n", $1);};

DebutAffPointeur : tMUL SuiteAffPointeur {add_operation(READ, $2, $2, 0); $$=$2;};
DebutAffPointeur : SuiteAffPointeur {$$=$1;};
SuiteAffPointeur : tMUL tID {struct symbole_t * symbole  = get_variable($2); int addr = push("0_TEMPORARY", 1, symbole->type); add_operation(COP, addr,symbole->adresse,0); $$=addr;};
SuiteAffPointeur : tID tOCROCH E tCCROCH {struct symbole_t * symbole  = get_variable($1); int addr = push("0_TEMPORARY", 1, symbole->type); if (symbole->type.pointeur_level > 0){add_operation(COP, addr,symbole->adresse,0);} else{add_operation(AFCA, addr,symbole->adresse,0);} int addr2 = push("0_TEMPORARY", 1, integer); add_operation(AFC, addr2, taille_types[symbole->type.base],0); add_operation(MUL,$3,addr2,$3); add_operation(ADD,$3,addr,$3); $$=$3; pop(); pop();};


E : tNB { int addr = push("0_TEMPORARY", 1, integer); add_operation(AFC, addr,$1,0); $$ = addr;};
E : tNBEXP { printf("Nombre exp\n"); int addr = push("0_TEMPORARY", 1, integer); add_operation(AFC, addr,$1,0); $$ = addr;};
E : E tMUL E { printf("Mul\n"); add_operation(MUL,$1,$1,$3); $$ = $1; pop();};
E : E tDIV E { printf("Div\n");  add_operation(DIV, $1,$1,$3); $$ = $1; pop();};
E : E tSUB E { printf("Sub\n"); add_operation(SOU,$1,$1,$3); $$ = $1; pop();};
E : E tADD E { printf("Add\n"); add_operation(ADD,$1,$1,$3); $$ = $1; pop();};
//E : Invocation { printf("Invoc\n"); int addr = push("0_TEMPORARY", 1, integer); add_operation(AFC, addr,$1,0); $$ = addr;};
E : tOBRACE E tCBRACE { printf("Parentheses\n"); $$=$2;};
E : tSUB E { printf("Moins\n");  int addr = push("0_TEMPORARY", 1, integer);  add_operation(AFC, addr,0,0); add_operation(SOU, $2,$2,addr);  $$ = $2; pop();};
E : E tEQCOND E { printf("==\n"); add_operation(EQU,$1,$1,$3); $$ = $1; pop();};
E : E tGT E { printf(">\n"); add_operation(SUP,$1,$1,$3); $$ = $1; pop();};
E : E tLT E { printf("<\n"); add_operation(INF,$1,$1,$3); $$ = $1; pop();};
E : tNOT E { printf("!\n"); };
E : E tAND E {add_operation(MUL,$1,$1,$3); $$ = $1; pop();};
E : E tOR E {add_operation(ADD,$1,$1,$3); $$ = $1; pop();} ;
E : tMUL E { add_operation(READ, $2, $2, 0); $$=$2;};
E : tADDR EBis {add_operation(COPA,$2, $2,0); $$=$2;};
E : tADDR ETer {add_operation(COPA,$2, $2,0); $$=$2;};
E : tID { printf("Id\n"); struct symbole_t * symbole  = get_variable($1); struct type_t type = symbole->type; type.nb_blocs = 1; int addr = push("0_TEMPORARY", 1, type); if (symbole->type.isTab){add_operation(AFCA, addr,symbole->adresse,0); } else{add_operation(COP, addr,symbole->adresse,0);} $$=addr;};
E : tID tOCROCH E tCCROCH {struct symbole_t * symbole  = get_variable($1); struct type_t type = symbole->type; type.nb_blocs = 1; int addr = push("0_TEMPORARY", 1, type); if(type.pointeur_level > 0) {add_operation(COP, addr,symbole->adresse,0);} else{add_operation(AFCA, addr,symbole->adresse,0);} int addr2 = push("0_TEMPORARY", 1, integer); add_operation(AFC, addr2, taille_types[symbole->type.base],0); add_operation(MUL,$3,addr2,$3); add_operation(ADD,$3,addr,$3); add_operation(READ,$3,$3,0); $$=$3; pop(); pop();};

EBis : tID tOCROCH E tCCROCH {struct symbole_t * symbole  = get_variable($1); struct type_t type = symbole->type; type.nb_blocs = 1; int addr = push("0_TEMPORARY", 1, type); if(type.pointeur_level > 0) {add_operation(COP, addr,symbole->adresse,0);} else{add_operation(AFCA, addr,symbole->adresse,0);} int addr2 = push("0_TEMPORARY", 1, integer); add_operation(AFC, addr2, taille_types[symbole->type.base],0); add_operation(MUL,$3,addr2,$3); add_operation(ADD,$3,addr,$3); $$=$3; pop(); pop();};
ETer : tID { printf("Id\n"); struct symbole_t * symbole  = get_variable($1); struct type_t type = symbole->type; type.nb_blocs = 1; int addr = push("0_TEMPORARY", 1, type); add_operation(AFCA, addr,symbole->adresse,0); $$=addr;};



//Créer un champ isConst dans la table des symboles
Type : tINT {type_courant.base = INT; type_courant.pointeur_level = 0; type_courant.isTab = 0; type_courant.nb_blocs = 1; printf("Type int\n");} ;
Type : Type tMUL {type_courant.pointeur_level++;  printf("Type int *\n");};
//SuiteType : tMUL SuiteType {type_courant.pointeur_level++; printf(" * en plus\n");} ; 
//SuiteType : ;

Decl : Type SuiteDecl FinDecl ;
Decl : tCONST Type SuiteDeclConst FinDeclConst;

SuiteDecl : tID {push($1, 0, type_courant); printf("Suite Decl\n");};
SuiteDecl : tID tEQ E {pop(); int addr = push($1,1, type_courant);};
SuiteDecl : tID tOCROCH tNB tCCROCH {type_courant.isTab = 1; type_courant.nb_blocs = $3; push($1, 0, type_courant);} ;
FinDecl : tPV { printf("Fin Decl\n");};
FinDecl : tCOMA SuiteDecl FinDecl ;

SuiteDeclConst : tID tEQ E {pop(); int addr = push($1,1, type_courant);};
FinDeclConst : tPV;
FinDeclConst : tCOMA SuiteDeclConst FinDeclConst;

Fonction : Type tID {push_fonction($2,type_courant,get_current_index());} tOBRACE {} Args {} tCBRACE Body { printf("Déclaration de la fonction  %s\n", $1); } ;)


%%
void main(void) {
    init();
	yyparse();
}
