#include "table_symboles.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// Première adresse disponible
int last_addr = 0;
// Tableau indexé sur les types donnant leur tailles 
int taille_types[] = {-1, 1, 1};
// Pronfondeur dans le code (pour la visibilité des variables)
int profondeur = 0;
// Constante pour les entiers
const struct type_t integer = {INT, 0, 1, 0, 0};
// Constante pour les pointeurs
const struct type_t pointer = {ADDR, 0, 1, 0, 0};

// Structure chainant les symboles
struct element_t {
	struct symbole_t symbole;
	struct element_t * suivant;
};

// Structure de la pile des symboles
struct pile_t {
	int taille;
	struct element_t * first;
};

// Pile des symboles
struct pile_t * pile;

// Fonction d'affichage pour un type
char * type_to_string(struct type_t type) {
  char * star = "*";
  char * resultat = malloc(sizeof(char)*20);
  for (int i = 0; i< type.pointeur_level; i++){
      strncat(resultat,star,20);
  }
	if (type.base == INT) {
		strncat(resultat,"int",20);
	} else {;
	  strncat(resultat,"unknown",20);
	}
    return resultat;
}

// Fonction d'affichage pour un symbole
void print_symbole(struct symbole_t symbole) {
    char * type = type_to_string(symbole.type);
    if (symbole.initialized) {
		printf("\t\t{nom:%s, adresse:%ld, type:%s, initialized:OUI, profondeur : %d, isTab : %d, isConst : %d}\n", symbole.nom, symbole.adresse, type, symbole.profondeur,symbole.type.isTab, symbole.type.isConst);
	} else {
		printf("\t\t{nom:%s, adresse:%ld, type:%s, initialized:NON, profondeur : %d, isTab : %d, isConst : %d}\n", symbole.nom, symbole.adresse, type,symbole.profondeur,symbole.type.isTab, symbole.type.isConst);
	}
    free(type);
}

// Initialisation de la pile
void init (void) {
  pile = malloc(sizeof(struct pile_t));
	pile->first = NULL;
	pile->taille = 0;
}

// Fonction d'ajout d'un symbole à la pile
int push(char * nom, int isInit, struct type_t type) {
	struct element_t * aux = malloc(sizeof(struct element_t));
	struct symbole_t symbole = {"", last_addr, type, isInit,profondeur}; 
	strcpy(symbole.nom,nom);
	aux->symbole = symbole;
	aux->suivant = pile->first;
	pile->first = aux;
	pile->taille++;
	int addr_var = last_addr;
	printf("Push de %s avec une taille de type de %d et %d blocs a l'adresse %d\n", nom, taille_types[type.base],type.nb_blocs,last_addr);
	last_addr += (type.nb_blocs)*taille_types[type.base]; 
	return addr_var;
}

// Fonction renvoyant et supprimant le premier symbole
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

// Fonction supprimant les n premiers symboles
void multiple_pop(int n){
	for (int i =0; i<n; i++){
		pop();
	}
}

// Fonction d'accès a un symbole par son nom
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

// Fonction d'affichage de la pile
void print() {
	printf("Affichage de la Table des Symboles\n\tSize : %d\n\tTop : %d\n\tContenu : \n", pile->taille, last_addr);
	struct element_t * aux = pile->first;
	int i;
	for (i=0; i < pile->taille; i++) {
		print_symbole(aux->symbole);
		aux = aux->suivant;
	}
}

// Getteur sur la première adresse dispo (utile pour le CALL)
int get_last_addr(){
	return last_addr;
}




/********************************/
/*** GESTION DE LA PROFONDEUR ***/
/********************************/
void inc_prof() {
    profondeur++;
}

void decrement_prof(){
	profondeur--;
}

int get_prof() {
    return profondeur;
}

void reset_prof(){
    while (pile->first != NULL && pile->first->symbole.profondeur == profondeur){
	    pop();
    }
    profondeur--;
}
