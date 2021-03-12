%union {
	int nombre;
}

%token tMAIN
%token tOBRACKET tCBRACKET
%token tOBRACE tCBRACE
%token tINT
%token tCONST
%token tPV tCOMA
%token tMUL tDIV tADD tSUB tEQ
%token<nombre> tNB tNBEXP
%token tPRINTF
%token tERROR

//%type<nombre> E

/* 1 + 2 + 3 + 4 */

/* E => E + E => 1 + E => 1 + E + E ... */
/* E => E + E => E + 4 => E + E + 4 ... */

%%

/* S -> E ; S
 * S ->
 */
S : E tPV
						{ printf("RES: %d\n", $1); }
		S
	|					{ printf("END\n"); }
	;

E : E tADD E	{ $$ = $1 + $3; }
	| E tSUB E	{ $$ = $1 - $3; }
	| tOB E tCB	{ $$ = $2; }
	| tNB				{ $$ = $1; }
	;

%%

void main(void) {
	yyparse();
}
