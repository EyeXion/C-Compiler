#include "tab_fonctions.h"

#define MAX_TAILLE_FONC 50

// Table des fonctions
struct fonction_t tab_fonctions[MAX_TAILLE_FONC];
// Index dispo dans la table
int indexTab = 0;


// Renvoi une fonction a partir de son nom
struct fonction_t get_fonction(char * name){
	int not_found = 1;
	int i = 0;
	struct fonction_t res;
	while (not_found && (i <= indexTab)){
		if (!strcmp(name,tab_fonctions[i].name)){
			res = tab_fonctions[i];
			not_found = 0;
		}
		i++;
	}
	return res;
}

// Insere une fonction
void push_fonction(char * name, struct type_t type, int line, int taille_args){
	 if (indexTab < MAX_TAILLE_FONC){
		struct fonction_t fonc;
		fonc.name = malloc(sizeof(char)*50);
		strcpy(fonc.name,name);
		fonc.return_type = type;
		fonc.first_instruction_line = line;
		fonc.taille_args = taille_args;
		tab_fonctions[indexTab] = fonc;
		indexTab++;
	}
}

// Fonction d'affichage des fonctions connues
void print_fonctions(){
	printf("Affichage table des fonctions\n");
	printf("\t Size : %d\n",indexTab);
	printf("\t Contenu : \n"); 
	for (int i =0; i<indexTab; i++){
		printf("\t\t{Fonction : %s returns %s and starts at line %d and its args have a size of %d}\n",tab_fonctions[i].name, type_to_string(tab_fonctions[i].return_type), tab_fonctions[i].first_instruction_line, tab_fonctions[i].taille_args);
	}
}

