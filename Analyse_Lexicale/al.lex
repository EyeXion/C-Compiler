%{
#include "as.tab.h"
#include <stdio.h>
%}

%%

"main"      { printf("tMAIN\n");} 
"{"         { printf("tOBRACKET\n"); }
"}"         { printf("tCBRACKET\n"); }
"("			{ printf("tOBRACE\n"); }
")"			{ printf("tCBRACE\n"); }
"const"     { printf("tCONST\n"); }
"int"       { printf("tINT\n"); }
"printf"    { printf("tPRINTF\n"); } //Degeu mais à degager




[0-9]+	{ printf("tNB\n"); }
[0-9]+e[0-9]+	{ printf("tNBEXP\n"); } //Renvoyer le token tNB et pas tNBEXP
"+"			{ printf("tADD\n"); }
"-"			{ printf("tSUB\n"); }
"*"         { printf("tMUL\n"); }
"/"         { printf("tDIV\n"); }
"="         { printf("tEQ\n"); }
";"			{ printf("tPV\n"); }
" "			{ printf("tSPACE\n"); } //Ne pas les retourner à Yacc
"   "       { printf("tTAB\n"); } //Ne pas les retourner à Yacc
","         { printf("tCOMA\n"); }
"\n"        { printf("tRC\n") ; } //Ne pas les retourner à Yacc
[a-zA-Z][a-zA-Z0-9_]* { printf("tID\n"); }
.				{ return tERROR; }

%%


int yywrap(void){return 1;}
