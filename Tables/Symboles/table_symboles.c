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

struct element_t {
	struct symbole_t symbole;
	struct element_t * suivant;
};

struct pile_t {
	int taille;
	struct element_t * first;
};
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
		printf("\t\t{nom:%s, adresse:%ld, type:%s, initialized:OUI, profondeur : %d}\n", symbole.nom, symbole.adresse, type_to_string(symbole.type), symbole.profondeur);
	} else {
		printf("\t\t{nom:%s, adresse:%ld, type:%s, initialized:NON, profondeur : %d}\n", symbole.nom, symbole.adresse, type_to_string(symbole.type),symbole.profondeur);
	}
}

void init (void) {
    pile = malloc(sizeof(struct pile_t));
	pile->first = NULL;
	pile->taille = 0;
}

int push(char * nom, int isInit, enum type_t type) {
	struct element_t * aux = malloc(sizeof(struct element_t));
	struct symbole_t symbole = {"", last_addr, type, isInit,profondeur}; 
	strcpy(symbole.nom,nom);
	aux->symbole = symbole;
	aux->suivant = pile->first;
	pile->first = aux;
	pile->taille++;
	int addr_var = last_addr;
	last_addr += taille_types[type]; 
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
		last_addr -= taille_types[retour.type]; 
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


int allocate_mem_temp_var(enum type_t type){
	temp_addr -= taille_types[type];
	return temp_addr;
}

void reset_temp_vars(){
	temp_addr = MAXADDR;
}


void reset_pronf(){
	while (pile->first->symbole.profondeur == profondeur){
		pop();
	}
}

