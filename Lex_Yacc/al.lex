%{ // Ne pas toucher
#include "as.tab.h"
int yywrap(void){return 1;}
void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}

%}

%%


"main"      { return tMAIN;     }    // Token de la fonction main

"{"         { return tOBRACKET; }    // Token accolade ouvrante
"}"         { return tCBRACKET; }    // Token accolade fermante
"("		    	{ return tOBRACE;   }    // Token parenthèse ouvrante
")"	    		{ return tCBRACE;   }    // Token parenthèse fermante

"const"     { return tCONST;    }    // Token constante
"int"       { return tINT;      }    // Token type int

"if"        { return tIF;       }    // Token if
"else"      { return tELSE;     }    // Token else
"while"     { return tWHILE;    }    // Token while

"return"    {return tRETURN;    }    // Token return

"<"         { return tLT;       }    // Token plus petit que
">"         { return tGT;       }    // Token plus grand que
"=="        { return tEQCOND;   }    // Token égal comparaison

"&&"        { return tAND;      }    // Token ET
"||"        { return tOR;       }    // Token OU

"&"         { return tADDR;     }    // Token adresse
"["         { return tOCROCH;   }    // Token crochet ouvrante
"]" 		    { return tCCROCH;   }    // Token crochet ouvrante

"get"       { return tGET;      }    // Token fonction get
"printf"    { return tPRINTF;   }    // Token fonction print
"stop"      { return tSTOP;     }    // Token fonction stop

"+"			    { return tADD;      }    // Token addition
"-"		    	{ return tSUB;      }    // Token soustraction
"*"         { return tMUL;      }    // Token multiplication
"/"         { return tDIV;      }    // Token division

"="         { return tEQ;       }    // Token egal affectation

";"			    { return tPV;       }
","         { return tCOMA;     }

[0-9]+	        { yylval.nombre = atoi(yytext); return tNB; }    // Token nombre au format classique
[0-9]+e[0-9]+ 	{ yylval.nombre = -1; return tNB;        }       // Token nombre au format exponentiel

[a-zA-Z][a-zA-Z0-9_]* { strcpy(yylval.id, yytext); return tID; } // Chaine de caractère (identifiant variable, fonction..)


" "			    {} //Ne pas les retourner à Yacc (espace)
"   "       {} //Ne pas les retourner à Yacc (tabulation)
"\n"        {} //Ne pas les retourner à Yacc (retour chariot)

%%


