/* TABLE DES SYMBOLE DU COMPILATEUR (PILE)

-----------------------------------------------------
|  symbole   |  adresse   |    type    | initialisé |
-----------------------------------------------------
|            |            |            |            |
|            |            |            |            |
|            |            |            |            |
|      i     | 0x777756b8 |     int    |    false   |
|    size    | 0x777756b8 |     int    |    true    |
-----------------------------------------------------

Types pour l'implémentation : 
	- enum type_t : [int]
	- struct symbole : {
			char nom[30];
			uintptr_t adresse;
			enum type_t type;
			char initialized;
		}

Opérations possible : 
	- init -> pile * -> void
	- push -> symbole -> pile * -> void
	- pop -> pile * -> symbole
	- exist -> pile * -> symbole -> char
	- initialized -> pile * -> symbole -> char					*/

#include "table_symboles.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#define MAXADDR 1024*5

int last_addr = 0;
int temp_addr = MAXADDR;
int taille_types[] = {-1, 4};
int profondeur = 0;
int last_temp_var_size;
const struct type_t integer = {INT, 0, 1};

struct element_t {
	struct symbole_t symbole;
	struct element_t * suivant;
};

struct pile_t {
	int taille;
	struct element_t * first;
};
struct pile_t * pile;

char * type_to_string(struct type_t type) {
    char * star = "*";
    char * resultat = malloc(sizeof(char)*20);
    for (int i = 0; i< type.pointeur_level; i++){
        strcat(resultat,star);
    }
	if (type.base == INT) {
		strcat(resultat,"int");
	} else {;
	    strcat(resultat,"unknown");
	}
    return resultat;
}

void print_symbole(struct symbole_t symbole) {
    char * type = type_to_string(symbole.type);
    if (symbole.initialized) {
		printf("\t\t{nom:%s, adresse:%ld, type:%s, initialized:OUI, profondeur : %d}\n", symbole.nom, symbole.adresse, type, symbole.profondeur);
	} else {
		printf("\t\t{nom:%s, adresse:%ld, type:%s, initialized:NON, profondeur : %d}\n", symbole.nom, symbole.adresse, type,symbole.profondeur);
	}
    free(type);
}

void init (void) {
    pile = malloc(sizeof(struct pile_t));
	pile->first = NULL;
	pile->taille = 0;
}



int push(char * nom, int isInit, struct type_t type) {
	struct element_t * aux = malloc(sizeof(struct element_t));
	struct symbole_t symbole = {"", last_addr, type, isInit,profondeur}; 
	strcpy(symbole.nom,nom);
	aux->symbole = symbole;
	aux->suivant = pile->first;
	pile->first = aux;
	pile->taille++;
	int addr_var = last_addr;
	last_addr += (type.nb_blocs)*taille_types[type.base]; 
	return addr_var;
}

struct symbole_t pop() {
	struct symbole_t retour = {"", 0, UNKNOWN, 0, 0};
	struct element_t * aux;
	if (pile->taille > 0) {
		aux = pile->first;
		pile->first = pile->first->suivant;
		retour = aux->symbole;
		free(aux);
		pile->taille--;
		last_addr -= taille_types[retour.type.base]; 
	}
	return retour;
}

struct symbole_t * get_variable(char * nom){
	struct symbole_t * retour = NULL;
	struct element_t * aux = pile->first;
	int i;
	for (i=0; i < pile->taille; i++) {
		if (!strcmp(nom, aux->symbole.nom)) {
		    retour = &aux->symbole;
			break;
		} else {
			aux = aux->suivant;
		}
	}
	return retour;
}

void print() {
	printf("Affichage de la Table des Symboles\n\tSize : %d\n\tContenu : \n", pile->taille);
	struct element_t * aux = pile->first;
	int i;
	for (i=0; i < pile->taille; i++) {
		if (aux->symbole.initialized) {
			printf("\t\t{nom:%s, adresse:%ld, type:%s, initialized:OUI, profondeur : %d}\n", aux->symbole.nom, aux->symbole.adresse, type_to_string(aux->symbole.type), aux->symbole.profondeur);
		} else {
			printf("\t\t{nom:%s, adresse:%ld, type:%s, initialized:NON, profondeur : %d}\n", aux->symbole.nom, aux->symbole.adresse, type_to_string(aux->symbole.type), aux->symbole.profondeur);
		}
		aux = aux->suivant;
	}
}


int get_last_addr(){
	return last_addr;
}

void inc_prof() {
    profondeur++;
}

int get_prof() {
    return profondeur;
}

void reset_prof(){
    printf("Profondeur dans reset : %d\n", profondeur);
    while (pile->first != NULL && pile->first->symbole.profondeur == profondeur){
	    pop();
    }
    profondeur--;
}
