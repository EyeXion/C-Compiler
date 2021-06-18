%code requires {
	#include "../Tables/Symboles/table_symboles.h"

	struct while_t {
		int n_ins_cond;
		int n_ins_jmf;
	};
}

%union {
	int nombre;
	struct symbole_t symbole;
  char id[30];
	struct while_t my_while;
}
%{
#include "../Tables/Fonctions/tab_fonctions.h"
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

// Utile a l'affectation avec des pointeurs
int first_etoile = 1;

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
%token<nombre> tIF tELSE
%token<my_while> tWHILE
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

%right tINT tMAIN

%type<symbole> SymboleAffectation
%type<nombre> E EBis Invocation Args ArgSuite Arg SuiteParams Params Get InitTab SuiteInitTab

%%

/*************************************/
/*************************************/
/*********** Programme C *************/
/*************************************/
/*************************************/

// Un programme C correspond a des focntion et un main, une fois que le programme est compilé, on ajoute le STOP et l'on exporte l'assembleur.
C : Fonctions                     {add_operation(STOP,0,0,0); 
                                   create_asm();
                                  };

// Le main, renvoi un int, possède le mot clé main, des arguments et un body
// Dès que le main est reconnu (token main) on met en place le JMP
Main : tINT tMAIN                 {create_jump_to_main(get_current_index()); printf("DANS LE MAIN \n");
                                  }
       tOBRACE Args tCBRACE Body {print();}; 





/*************************************/
/*************************************/
/************ Fonctions **************/
/*************************************/
/*************************************/

// Des fonctions sont une suite de fonctions (possiblement nulle)
Fonctions : Main ;
Fonctions : Fonction Fonctions ;

// Une fonction possède un Type , un identifiant
Fonction : Type tID               {return_type_fonc = type_courant;                                // On récupère le ype de la fonction                 
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
Arg : Type tID                    {type_courant.nb_blocs = 1;
																	int addr = push($2,1, type_courant);                           // On stocke l'argument dans la pile des symboles      
                                   if (type_courant.pointeur_level > 0) {
                                     $$ = taille_types[ADDR];                                     
                                   } else {
                                     $$ = taille_types[type_courant.base];                        
                                   }
                                  };
// Un argument peut aussi être un tableau (argument classique et crochets) il est considéré comme un pointeur
Arg : Type tID tOCROCH tCCROCH    {type_courant.nb_blocs = 1;
																	type_courant.pointeur_level++;                                  // Considéré comme un simple pointeur
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

While : tWHILE 													 {$1.n_ins_cond = get_current_index();                    // On enregistre l'endroit de la condition (pour le JMP en fin de while)
																				 }

				tOBRACE E tCBRACE                {add_operation(JMF,$4,0,0);                               // Ecriture du JMF
                                          $1.n_ins_jmf = get_current_index() - 1;                  // Enregistrement du numero d'instruction du jmf à patch
                                          pop();                                                   // Pop de la condition
                                         }
        Body                             {int current = get_current_index();                       // Patch du JMF apres le body
                                          patch($1.n_ins_jmf,current + 1);
                                          add_operation(JMP,$1.n_ins_cond,0,0);                               // JMP au debut de la boucle
                                         };






/*************************************/
/*************************************/
/************ Affectations ***********/           
/*************************************/
/*************************************/

// Affectation simple
Aff : tID tEQ E tPV                      {struct symbole_t * symbole = get_variable($1); 
																				  symbole->initialized = 1;
                                          if (symbole->type.isConst == 1 && symbole->type.pointeur_level == 0 || symbole->type.isTab) {
																						printf("\033[31;01m ERROR : \033[00m %s est READ-ONLY\n", symbole->nom);
																					  exit(2);
																					} else {
																						add_operation(COP,symbole->adresse,$3,0);                     // On affecte la valeur
                                          	pop();                                                        // On pop l'expression
																						first_etoile = 1;                                             // On reinitialise first_etoile
																					}
                                         }; 

// Affectation sur un pointeur
Aff : SymboleAffectation tEQ E tPV       {if ($1.type.isConst == 1 && $1.type.pointeur_level == 0 || $1.type.isTab) {
																						printf("\033[31;01m ERROR : \033[00m %s ou un de ses déréférencement est READ-ONLY\n", $1.nom);
																					  exit(2);
																					} else {
																						add_operation(WR,$1.adresse,$3,0);                     // On affecte la valeur
                                          	pop();                                                 // On pop l'expression
                                          	pop();                                                 // On pop la variable temporaire de l'adresse
																					}
                                         }; 

// Debut d'une affectation avec déreférencement de pointeur
SymboleAffectation : tID                                   {struct symbole_t * symbole = get_variable($1); 
																														symbole->initialized = 1;
																														int addr = push("0_TEMPORARY", 1, pointer);
                                                            if (symbole->type.isTab) {
	                                                            add_operation(AFCA, addr, symbole->adresse,0);                              // Si tableau AFCA
	                                                          } else { 
	                                                            add_operation(COP, addr, symbole->adresse,0);                               // Si pointeur COP
	                                                          } 
																														struct symbole_t symbolebis = *symbole;  
																														symbolebis.adresse = addr;
                                                            $$ = symbolebis;                                                              // On renvoi un symbole pointant sur la copie de l'adresse
                                                           };

SymboleAffectation : SymboleAffectation tOCROCH E tCCROCH  {if ($1.type.pointeur_level == 0) {                                            // Check déréférençable
	                  																					printf("\033[35;01m WARNING : \033[00m déréférencement exessif\n");
										                  											} else {
																															$1.type.pointeur_level--;                                                   // On baisse le niveau de pointeur
                                                            	int addr = push("0_TEMPORARY", 1, integer);                                 // On alloue la place pour stocker la taille du type pointé
																															if ($1.type.pointeur_level > 0) {
		                                                            add_operation(AFC, addr, taille_types[ADDR],0);                           // Si on est encore un pointeur, la taille d'un adresse
																															} else {
																																add_operation(AFC, addr, taille_types[$1.type.base],0);                   // Sinon le type de base
																															}
		                                                          add_operation(MUL,$3,addr,$3);                                              // On multiple le nombre de décalage par la taille du type
		                                                          add_operation(ADD,$3,$1.adresse,$3);                                        // On l'ajoute a l'adresse de base
																															$1.type.isTab = 0;
		                                                          $$=$1; 
		                                                          pop(); 
		                                                          pop();
										                  											} 
                                                           };

SymboleAffectation : tMUL SymboleAffectation               {if ($2.type.pointeur_level == 0) {                                            // Check déréférençable
	                  																					printf("\033[35;01m WARNING : \033[00m déréférencement exessif\n");
										                  											} else {
																															$2.type.pointeur_level--;                                                   // On baisse le niveau de pointeur 
																															$2.type.isTab = 0;
																															if (first_etoile) {
																																first_etoile = 0;                                                         // Le premier déréférencement doit être skip a cause du WR
																															} else {
				                                                        add_operation(READ, $2.adresse, $2.adresse,0);                            // 
				                                                        $$=$2;
																															}
										                  											}
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
																					printf("Nombre %d@%d\n", $1, addr);
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




// Opérateur == (idem multiplication)
E : E tEQCOND E                          {add_operation(EQU,$1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };
// Opérateur > (idem multiplication)
E : E tGT E                              {add_operation(SUP,$1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };

// Opérateur < (idem multiplication)
E : E tLT E                              {add_operation(INF,$1,$1,$3); 
																					printf("INF %d %d %d\n", $1, $1, $3);
																					print();
                                          $$ = $1; 
                                          pop();
                                         };
// Opérateur !E <=> E==0
E : tNOT E                               {int addr = push("0_TEMPORARY", 1, integer);              // On réserve la variable temporaire pour le 0
                                          add_operation(AFC, addr,0,0);                            // On affecte le 0
                                          add_operation(EQU, $2, addr, $2);                        // On applique le 0==E
                                          $$ = $2;                                                 // On renvoi l'adresse
                                          pop();   
                                         };

// Opérateur E && E' <=> E*E' (idem multiplication)
E : E tAND E                             {add_operation(MUL,$1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };

// Opérateur E || E' <=> E+E' (idem multiplication)
E : E tOR E                              {add_operation(ADD,$1,$1,$3); 
                                          $$ = $1; 
                                          pop();
                                         };





// Déréférencement de pointeur
E : tMUL E                               {add_operation(READ, $2, $2, 0);                          // Extraction en mémoire
                                          $$=$2;
                                         };



// Une variable
E : tID                                  {struct symbole_t * symbole  = get_variable($1);          // On cherche la variable dans la table des symboles
                                          struct type_t type = symbole->type;                      // On récupère le type
                                          type.nb_blocs = 1; 
                                          int addr = push("0_TEMPORARY", 1, type);                 // On créé la variable temporaire
                                          if (symbole->type.isTab == 1) {
                                            add_operation(AFCA, addr,symbole->adresse,0);          // Si c'est un tableau on affecte l'adresse du début
                                          } else {
                                            add_operation(COP, addr,symbole->adresse,0);           // Si c'est autre chose, on copie la valeur
                                          } 
                                          $$ = addr;
																					printf("variable stoquée a l'adresse %d \n", addr);
                                         };

// Une variable sous forme de tableau
E : tID tOCROCH E tCCROCH                {struct symbole_t * symbole  = get_variable($1);                    // On récupère le symbole
                                          struct type_t type = symbole->type;                                // On récupère le type
                                          type.nb_blocs = 1;                                                 
                                          int addr = push("0_TEMPORARY", 1, type);                           // On créé la variable temporaire
                                          if (type.isTab == 2) {
                                            add_operation(COP, addr,symbole->adresse,0);
                                          } else {
                                            add_operation(AFCA, addr,symbole->adresse,0);
                                          } 
                                          int addr2 = push("0_TEMPORARY", 1, integer); 
                                          add_operation(AFC, addr2, taille_types[symbole->type.base],0);     
                                          add_operation(MUL,$3,addr2,$3);
                                          add_operation(ADD,$3,addr,$3); 
                                          add_operation(READ,$3,$3,0); 
                                          $$=$3; 
                                          pop(); 
                                          pop();
                                         };

E : tADDR EBis {$$=$2;};
E : Get {$$ = $1;};

EBis : tID tOCROCH E tCCROCH             {struct symbole_t * symbole  = get_variable($1); 
                                          struct type_t type = symbole->type; 
                                          type.nb_blocs = 1; 
                                          int addr = push("0_TEMPORARY", 1, type); 
                                          if(type.isTab == 2) {
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


EBis : tID { struct symbole_t * symbole  = get_variable($1); struct type_t type = symbole->type; type.nb_blocs = 1; int addr = push("0_TEMPORARY", 1, type); add_operation(AFCA, addr,symbole->adresse,0); $$=addr;};










/*************************************/
/*************************************/
/*************** Types ***************/          
/*************************************/
/*************************************/

// Type INT
Type : tINT                              {type_courant.base = INT; 
                                          type_courant.pointeur_level = 0;
																					type_courant.isConst = 0;
                                         };

// Type pointeur
Type : Type tMUL                         {type_courant.pointeur_level++;                           // On ajoute un niveau de pointeur
                                         };

// Constante
Type : tCONST Type                       {type_courant.isConst = 1;
                                         };




/*
Type : tINT TypeNext
Type : tCONST tINT TypeNext

TypeNext :
| tMUL TypeNext
*/



/*************************************/
/*************************************/
/************ Déclaration ************/          
/*************************************/
/*************************************/

// Une déclaration est un type, un identifiant eventuellement initialisé, et fin de déclaration (une autre ou un ;);
Decl : Type UneDecl FinDecl ;

// Une déclaration d'une simple variable sans initialisation
UneDecl : tID                            {type_courant.isTab = 0;                                  // On est pas un tableau
                                          type_courant.nb_blocs = 1;                              // On fixe le nombre de blocs
                                          push($1, 0, type_courant);
                                         };

// Une déclaration d'une simple variable avec initialisation
UneDecl : tID tEQ E                      {pop();                                                   // On pop l'expression
                                          type_courant.isTab = 0;                                  // On est pas un tableau   
                                          type_courant.nb_blocs = 1;                              // On fixe le nombre de blocs                             
                                          int addr = push($1,1, type_courant);                     // On déclare la variable qui a la même adresse que la variable temporaire, et, a donc déjà la valeur
                                         }; 

// Une déclaration d'un tableau sans initialisation
UneDecl : tID tOCROCH tNB tCCROCH        {type_courant.isTab = 1;                                  // On est un tableau
																					type_courant.pointeur_level++;                           // On augmente le niveau de pointeur (un tableau est un pointeur)
                                          type_courant.nb_blocs = $3;                              // On fixe le nombre de blocs
                                          push($1, 0, type_courant);
                                         };

// Une déclaration d'un tableau avec initialisation
UneDecl : tID tOCROCH tNB tCCROCH tEQ tOBRACKET InitTab tCBRACKET    {if ($3 != $7) {
																																				printf("\033[31;01m ERROR : \033[00m Initialisation de %s : %d éléments donnés, %d éléments requis\n", $1, $7, $3);
																					  														exit(2);
																																			} else {
																																				type_courant.isTab = 1; 
																					                              type_courant.pointeur_level++;                           // On augmente le niveau de pointeur (un tableau est un pointeur)
                                                                      	type_courant.nb_blocs = $3; 
																																				int i;
																																				for (i=0;i<$3;i++) {
																																					pop();
																																				}
                                                                      	push($1, 1, type_courant);
																																			}
                                                                     };

// Un ; ou une autre déclaration
FinDecl : tPV;
FinDecl : tCOMA UneDecl FinDecl ;

// Initialisation des tableau
InitTab : E SuiteInitTab                 {$$ = $2 + 1; 
                                         };
SuiteInitTab : tCOMA E SuiteInitTab      {$$ = $3 + 1; 
                                         };
SuiteInitTab :                           {$$ = 0;
                                         };



%%
void main(void) {
    init();
	yyparse();
}
