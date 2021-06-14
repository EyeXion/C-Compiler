%union {
	int nombre;
    char id[30];
}
%{
#include "../Tables/Fonctions/tab_fonctions.h"
#include "../Tables/Symboles/table_symboles.h"
#include <stdio.h> 
#include <string.h>
#include <stdlib.h>
#include "../Tables/Instructions/tab_instruc.h"
#define TAILLE 1024

struct type_t type_courant;
struct type_t return_type_fonc;

// Tableau pour le management des patchs des JMP
int instructions_ligne_to_patch[10][20];
int nbs_instructions_to_patch[10];

%}

// Récupération des tokens
%token tMAIN
%token tOBRACKET tCBRACKET
%token<nombre> tOBRACE tCBRACE
%token tOCROCH tCCROCH
%token tINT
%token tCONST
%token tPV tCOMA
%token tMUL tDIV tADD tSUB tEQ
%token<nombre> tNB tNBEXP
%token<id> tID
%token tPRINTF tGET tSTOP
%token tERROR
%token<nombre> tIF tWHILE tELSE
%token tRETURN
%token tLT tGT tEQCOND
%token tAND tOR
%token tADDR 

%left tLT tGT
%left tEQCOND
%left tAND tOR
%left tNOT
%left tADD tSUB
%left tMUL tDIV

%type<nombre> E SuiteAffPointeur DebutAffPointeur EBis Invocation Args ArgSuite Arg SuiteParams Params Get

%%

/*************************************/
/*************************************/
/*********** Programme C *************/
/*************************************/
/*************************************/

// Un programme C correspond a des focntion et un main, une fois que le programme est compilé, on ajoute le STOP et l'on exporte l'assembleur.
C : Fonctions Main                {add_operation(STOP,0,0,0); 
                                   create_asm();
                                  };






/*************************************/
/*************************************/
/************ Fonctions **************/
/*************************************/
/*************************************/

// Des fonctions sont une suite de fonctions (possiblement nulle)
Fonctions : Fonction Fonctions;
Fonctions : ;





/*************************************/
/*************************************/
/************** Main *****************/
/*************************************/
/*************************************/

// Le main, renvoi un int, possède le mot clé main, des arguments et un body
// Dès que le main est reconnu (token main) on met en place le JMP
Main : tINT tMAIN                 {printf("Déclaration du main\n");
                                   create_jump_to_main(get_current_index());
                                  }
       tOBRACE Args tCBRACE Body; 


// Une fonction possède un Type , un identifiant
Fonction : Type tID               {return_type_fonc = type_courant;                                // On récupère le ype de la fonction
                                   printf("Déclaration de la fonction  %s\n", $2);                  
                                  } 
           tOBRACE                {inc_prof();                                                     // On incrémente la profondeur pour les arguments, ils font parti de la fonction
                                  } 
           Args                   {decrement_prof();                                               // Quand les arguments sont passés, on peur décrémenter la profondeur (sans effacer les variables)
                                   push_fonction($2,return_type_fonc,get_current_index(), $6);     // On enregistre la fonction dans la table des fonctions
                                  }
           tCBRACE Body           {add_operation(RET,0,0,0);                                       // On ajoute le RET
                                  };

// Get, une fonction particulière -> renvoi l'adresse de la valeur getée
Get : tGET tOBRACE tCBRACE        {int addr = push("0_TEMPORARY", 0, integer);                     // On déclare la var temporelle
                                   add_operation(GET,addr,0,0);                                    // On ajoute le GET
                                   $$ = addr;                                                      // On renvoi l'adresse
                                  };

// Print, une fonction particulière
Print : tPRINTF tOBRACE E tCBRACE {add_operation(PRI,$3,0,0);                                      // On ajoute l'instruction PRI
																	 pop();                                                          // On supprime la variable temporaire
                                  };

// Stop, une fonction particulière
Stop : tSTOP tOBRACE tNB tCBRACE  {add_operation(STOP,$3,0,0);                                     // On ajoute juste l'instruction stop
                                  };

// Return, etape clé d'une fonction
Return : tRETURN E tPV            {add_operation(COP,0,$2,0);                                      // On copie la valeur retournée à l'adresse 0 de la frame 
                                   pop();                                                          // On pop la variable temporaire
                                  };





/*************************************/
/*************************************/
/************ Arguments **************/
/*************************************/
/*************************************/

// Les arguments : Args, Arg, ArgSuite renvoient la taille dans la pile des arguments déjà reconnus
// Des argmuments correspondent à : un argument, puis la suite d'arguments
Args : Arg ArgSuite               {$$ = $1 + $2;                                                   // La taille des arguments est la taille du premier argument plus celle des suivants
                                  };
Args :                            {$$ = 0;                                                         // Il peut ne pas y avoir d'arguments, alors la taille est 0
                                  };
// Un argument possède un type et un identifiant (nom)
Arg : Type tID                    { int addr = push($2,1, type_courant);                           // On stocke l'argument dans la pile des symboles      
                                    if (type_courant.pointeur_level > 0) {
                                      $$ = taille_types[ADDR];                                     
                                    } else {
                                      $$ = taille_types[type_courant.base];                        
                                    }
                                  };
// Un argument peut aussi être un tableau (argument classique et crochets) il est considéré comme un pointeur
Arg : Type tID tOCROCH tCCROCH    {type_courant.pointeur_level++;                                  // Considéré comme un simple pointeur
                                   int addr = push($2,1, type_courant);
                                   $$ = taille_types[ADDR];
                                  };
// La suite d'un argument, une virgule, un argument, et d'autres arguments
ArgSuite : tCOMA Arg ArgSuite     {$$ = $2 + $3;                                                
                                  };
// Cela peut être aucun arguments
ArgSuite :                        {$$ = 0;
                                  }; 





/*************************************/
/*************************************/
/*************** Body ****************/
/*************************************/
/*************************************/

// Un body n'est rien d'autre qu'une suite d'instructions entre deux accolades
Body : tOBRACKET                  {inc_prof();                                                     // Lors de l'ouverture de l'accolade la profondeur augmente
                                  }
       Instructions tCBRACKET     {reset_prof();                                                   // A la sortie d'un body, on détruit toutes les variables locales de ce body
                                  };






/*************************************/
/*************************************/
/*********** Instructions ************/
/*************************************/
/*************************************/

// Des instructions sont une instruction suivie d'autres instructions, ou, rien
Instructions : Instruction Instructions ;
Instructions : ;

// Un instruction peut être : une affectation, une déclaration, une invocation, un if, un while, un return, une fonction particulière
Instruction : Aff;
Instruction : Decl;
Instruction : Invocation tPV      {pop();};
Instruction : If;
Instruction : While;
Instruction : Return;
Instruction : Stop tPV;
Instruction : Print tPV;





/*************************************/
/*************************************/
/************ Invocation *************/
/*************************************/
/*************************************/

Invocation : tID tOBRACE Params tCBRACE  {struct fonction_t fonc = get_fonction($1);                              // On récupère la fonction
                                          multiple_pop($3);                                                       // On pop les paramètres de la table des symboles
                                          add_operation(CALL,fonc.first_instruction_line, get_last_addr(),0);     // On écrit le CALL
																					// On renvoi l'adresse de la valeur retour de la fonction
                                          if (fonc.return_type.pointeur_level > 0 || fonc.return_type.isTab) {
                                            $$ = push("0_TEMPORARY_RETURN", 0, pointer); 
                                          } else {
                                            $$ = push("0_TEMPORARY_RETURN", 0, fonc.return_type); 
                                          }
                                         };





/*************************************/
/*************************************/
/************ Paramètres *************/
/*************************************/
/*************************************/

// Ici aussi, 0, 1 ou plusieurs paramètres avec une suite paramètre pour prendre en compte la virgule, on renvoi le nombre de paramètres
Params :                                 {$$ = 0;
                                         };
Params : Param SuiteParams               {$$ = $2 + 1;
                                         };
Param : E                         
SuiteParams : tCOMA Param SuiteParams    {$$ = $3 + 1;};
SuiteParams :                            {$$ = 0;};







/*************************************/
/*************************************/
/******** Sauts conditionnels ********/
/*************************************/
/*************************************/

// Un if : le token, une expression entre parenthèse suivie d'un body et d'un else
If : tIF tOBRACE E tCBRACE               {add_operation(JMF,$3,0,0);                                                                     // On ajoute le JMF sans préciser la ligne du saut
                                          $1 = get_current_index() - 1;                                                                  // On stocke le numéro d'instruction à patcher
                                         } 
     Body                                {int current = get_current_index();                                                             // On récupère le numéro d'instrcution
		                                      patch($1,current + 1);                                                                         // On patch le Jump en cas d'instruction fausse 
																					add_operation(JMP,0,0,0);                                                                      // JMP pour skip le else si on devait faire le body 
																					instructions_ligne_to_patch[get_prof()][nbs_instructions_to_patch[get_prof()]] = current;      // On spécifie que le JMP est a patcher
																					nbs_instructions_to_patch[get_prof()]++;
																					pop();                                                                                         // On pop la condition du if
																				 }
		 Else																 

// Elsif 
Else : tELSE If;

// Else 
Else : tELSE Body                        {int current = get_current_index(); 
                                          for (int i = 0; i< nbs_instructions_to_patch[get_prof()]; i++) {
	                                          patch(instructions_ligne_to_patch[get_prof()][i],current);                                   // On patch après le else
                                          }
                                          nbs_instructions_to_patch[get_prof()] = 0;
                                         };

// If sans else
Else :                                   {int current = get_current_index(); 
																					for (int i = 0; i< nbs_instructions_to_patch[get_prof()]; i++){
																						patch(instructions_ligne_to_patch[get_prof()][i],current);                                   // On patch après le else
																					}
																					nbs_instructions_to_patch[get_prof()] = 0;
																				 };






/*************************************/
/*************************************/
/************** Boucles **************/
/*************************************/
/*************************************/

While : tWHILE tOBRACE E tCBRACE         {add_operation(JMF,$3,0,0);                               // Ecriture du JMF
                                          $1 = get_current_index() - 1;                            // Enregistrement de la ligne a patch
                                          pop();                                                   // Pop de la condition
                                         }
        Body                             {int current = get_current_index();                       // Patch du JMF apres le body
                                          patch($1,current + 1);
                                          add_operation(JMP,$1,0,0);                               // JMP au debut de la boucle
                                         };






/*************************************/
/*************************************/
/************ Affectations ***********/           // A RETRAVAILLER 
/*************************************/
/*************************************/

// Affectation simple
Aff : tID tEQ E tPV                      {struct symbole_t * symbole  = get_variable($1);          // On récupère le symbole
                                          symbole->initialized = 1;                                // Le symbole devient initialisé
																					add_operation(COP, symbole->adresse, $3,0);              // On affecte la valeur
                                          pop();                                                   // On pop l'expression
                                         }; 

// Debut d'une affectation avec déreférencement de pointeur //////// A RETRAVAILLERRRRRR
DebutAffPointeur : tMUL SuiteAffPointeur {add_operation(READ, $2, $2, 0); 
                                          $$=$2;
                                         };

DebutAffPointeur : SuiteAffPointeur      {$$=$1;
                                         };

SuiteAffPointeur : tMUL tID              {struct symbole_t * symbole = get_variable($2); 
                                          int addr = push("0_TEMPORARY", 1, symbole->type); 
                                          add_operation(COP, addr,symbole->adresse,0); 
                                          $$=addr;
                                         };

SuiteAffPointeur : tID tOCROCH E tCCROCH {struct symbole_t * symbole = get_variable($1); 
                                          int addr = push("0_TEMPORARY", 1, symbole->type); 
                                          if (symbole->type.isTab == 2) {
                                            add_operation(COP, addr,symbole->adresse,0);
                                          } else { 
                                            add_operation(AFCA, addr,symbole->adresse,0);
                                          } 
                                          int addr2 = push("0_TEMPORARY", 1, integer); 
                                          add_operation(AFC, addr2, taille_types[symbole->type.base],0); 
                                          add_operation(MUL,$3,addr2,$3); 
                                          add_operation(ADD,$3,addr,$3); 
                                          $$=$3; 
                                          pop(); 
                                          pop();
                                         };



// Affectation sur un pointeur
Aff : DebutAffPointeur tEQ E tPV         {add_operation(WR,$1,$3,0); 
                                          pop(); 
                                          pop();
                                         };












/*************************************/
/*************************************/
/***** Expressions Arithmetiques *****/          
/*************************************/
/*************************************/

// Pour une expression arithmétique, nous renvoyons toujours l'adresse du resultat

// Un simple nombre 
E : tNB                                  {int addr = push("0_TEMPORARY", 1, integer);              // On reserve la place de la variable temporaire
                                          add_operation(AFC, addr,$1,0);                           // On Affecte la valeur a cette adresse
                                          $$ = addr;                                               // On renvoi l'adresse
                                         };

// Un nombre sous forme XeY, même traitement qu'un nombre classique 
E : tNBEXP                               {int addr = push("0_TEMPORARY", 1, integer); 
                                          add_operation(AFC, addr,$1,0); 
                                          $$ = addr;
                                         };

// Une Multiplication
E : E tMUL E                             {add_operation(MUL,$1,$1,$3);                             // On Multiplie les valeurs et stockons le résultat dans la première variable temporaire
                                          $$ = $1;                                                 // On renvoi l'adresse du resultat
                                          pop();                                                   // On libère la seconde variable temporaire
                                         };

// Une Division (idem multiplication)
E : E tDIV E                             {add_operation(DIV, $1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };

// Une Soustraction (idem multiplication)
E : E tSUB E                             {add_operation(SOU,$1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };

// Une Addition (idem multiplication)
E : E tADD E                             {add_operation(ADD,$1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };

// Une invocation
E : Invocation                           {$$ = $1;                                                 // Une invocation renvoi déjà l'adresse, cette règle n'est qu'un cast d'Invocation en E
                                         };

// Consomation de parenthèses
E : tOBRACE E tCBRACE                    {$$ = $2;                                                 // Cela permet de garantir la prioricité des expressions entre parenthèse
                                         };

// Négatif --> -E <=> 0-E
E : tSUB E                               {int addr = push("0_TEMPORARY", 1, integer);              // On réserve la variable temporaire pour le 0
                                          add_operation(AFC, addr,0,0);                            // On affecte le 0
                                          add_operation(SOU, $2, addr, $2);                        // On applique le 0-E
                                          $$ = $2;                                                 // On renvoi l'adresse
                                          pop();                                                   // On libère la mémoire temporaire utilisée par 0
                                         };

E : E tEQCOND E                          {add_operation(EQU,$1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };

E : E tGT E                              {add_operation(SUP,$1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };

E : E tLT E                              {add_operation(INF,$1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };

E : tNOT E                               { printf("!\n"); };

E : E tAND E {add_operation(MUL,$1,$1,$3); $$ = $1; pop();};
E : E tOR E {add_operation(ADD,$1,$1,$3); $$ = $1; pop();} ;
E : tMUL E { add_operation(READ, $2, $2, 0); $$=$2;};
E : tID { printf("Id\n"); struct symbole_t * symbole  = get_variable($1); struct type_t type = symbole->type; type.nb_blocs = 1; int addr = push("0_TEMPORARY", 1, type); if (symbole->type.isTab == 1){add_operation(AFCA, addr,symbole->adresse,0);} else{add_operation(COP, addr,symbole->adresse,0);} $$=addr;};


E : tID tOCROCH E tCCROCH {struct symbole_t * symbole  = get_variable($1); struct type_t type = symbole->type; type.nb_blocs = 1; int addr = push("0_TEMPORARY", 1, type); if(type.isTab == 2) {add_operation(COP, addr,symbole->adresse,0);} else{add_operation(AFCA, addr,symbole->adresse,0);} int addr2 = push("0_TEMPORARY", 1, integer); add_operation(AFC, addr2, taille_types[symbole->type.base],0); add_operation(MUL,$3,addr2,$3);
add_operation(ADD,$3,addr,$3); add_operation(READ,$3,$3,0); $$=$3; pop(); pop();};
E : tADDR EBis {$$=$2;};
E : Get {$$ = $1;};

EBis : tID tOCROCH E tCCROCH {struct symbole_t * symbole  = get_variable($1); 
struct type_t type = symbole->type; type.nb_blocs = 1; 
int addr = push("0_TEMPORARY", 1, type); 
if(type.isTab == 2) {
add_operation(COP, addr,symbole->adresse,0);
}
 else{
add_operation(AFCA, addr,symbole->adresse,0);
}
int addr2 = push("0_TEMPORARY", 1, integer);
add_operation(AFC, addr2, taille_types[symbole->type.base],0); 
add_operation(MUL,$3,addr2,$3); 
add_operation(ADD,$3,addr,$3); $$=$3; 
pop(); pop();};
EBis : tID { printf("Id\n"); struct symbole_t * symbole  = get_variable($1); struct type_t type = symbole->type; type.nb_blocs = 1; int addr = push("0_TEMPORARY", 1, type); add_operation(AFCA, addr,symbole->adresse,0); $$=addr;};



//Créer un champ isConst dans la table des symboles
Type : tINT {type_courant.base = INT; type_courant.pointeur_level = 0; type_courant.isTab = 0; type_courant.nb_blocs = 1; printf("Type int\n");} ;
Type : Type tMUL {type_courant.pointeur_level++;  printf("Type int *\n");};

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
%%
void main(void) {
    init();
	yyparse();
}
