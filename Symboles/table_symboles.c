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

int last_addr = 0;

struct element_t {
	struct symbole_t symbole;
	struct element_t * suivant;
};

struct pile_t {
	int taille;
	struct element_t * first;
};
*
struct pile_t * pile;

char * type_to_string(enum type_t type) {
	if (type == INT) {
		return "int";
	} else {
		return "unknown";	
	}
}

void print_symbole(struct symbole_t symbole) {
    if (symbole.initialized) {
		printf("\t\t{nom:%s, adresse:%p, type:%s, initialized:OUI, profondeur : %d}\n", symbole.nom, (void *)(symbole.adresse), type_to_string(symbole.type), symbole.profondeur);
	} else {
		printf("\t\t{nom:%s, adresse:%p, type:%s, initialized:NON, profondeur : %d}\n", symbole.nom, (void *)(symbole.adresse), type_to_string(symbole.type),symbole.profondeur);
	}
}

void init (void) {
    pile = malloc(sizeof(struct pile_t));
	pile->first = NULL;
	pile->taille = 0;
}

void push(char * nom, int isInit, enum type_t type) {
	struct element_t * aux = malloc(sizeof(struct element_t));
	aux->symbole = symbole;
	aux->suivant = pile->first;
	pile->first = aux;
	pile->taille++;
}

struct symbole_t pop() {
	struct symbole_t retour = {"", 0, UNKNOWN, 0};
	struct element_t * aux;
	if (pile->taille > 0) {
		aux = pile->first;
		pile->first = pile->first->suivant;
		retour = aux->symbole;
		free(aux);
		pile->taille--;
	}
	return retour;
}
		
char status(char * nom) {
	char retour = 0;
	struct element_t * aux = pile->first;
	int i;
	for (i=0; i < pile->taille; i++) {
		if (!strcmp(nom, aux->symbole.nom)) {
			if (aux->symbole.initialized) {
				retour = 1;
			} else {
				retour = 2;
			}
			break;
		} else {
			aux = aux->suivant;
		}
	}
	return retour;
}

struct symbole_t * getVariable(char * nom){
	struct symbole_t * retour = NULL;
	struct element_t * aux = pile->first;
	int i;
	for (i=0; i < pile->taille; i++) {
		if (!strcmp(nom, aux->symbole.nom)) {
		    retour = element_t;
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
			printf("\t\t{nom:%s, adresse:%p, type:%s, initialized:OUI}\n", aux->symbole.nom, (void *)(aux->symbole.adresse), type_to_string(aux->symbole.type));
		} else {
			printf("\t\t{nom:%s, adresse:%p, type:%s, initialized:NON}\n", aux->symbole.nom, (void *)(aux->symbole.adresse), type_to_string(aux->symbole.type));
		}
		aux = aux->suivant;
	}
}
