
#ifndef TAB_FONC_H
#define TAB_FONC_H

#include "../Symboles/table_symboles.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

//Struct dans le tableau qui permet d'identifier une fonction
struct fonction_t {
	char * name;
	struct type_t return_type;
	int first_instruction_line;
	int taille_args;
};

// Renvoi les informations sur une fonction à partir de son nom
struct fonction_t get_fonction(char * name);
// Insere une fonction dans la table (déclare une fonction)
void push_fonction(char * name, struct type_t type, int line, int taille_args);
// Fonction d'affichage des fonctions connues
void print_fonctions();

#endif

