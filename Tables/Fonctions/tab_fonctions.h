
#ifndef TAB_FONC_H
#define TAB_FONC_H

#include "../Symboles/table_symboles.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_TAILLE_FONC 50

//Struct dans le tableau qui permet d'identifier une fonction
struct fonction_t {
	char * name;
	struct type_t return_type;
	int first_instruction_line;
	int taille_args;
};

struct fonction_t get_fonction(char * name);

void push_fonction(char * name, struct type_t type, int line, int taille_args);

void print_fonctions();

#endif

