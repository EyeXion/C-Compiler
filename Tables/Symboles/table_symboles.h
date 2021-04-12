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
	- status -> nom -> pile -> char					*/

#include <stdint.h>









/**************************************/
/**************************************/
/**** Gestion des types possibles  ****/
/**************************************/
/**************************************/

//Enumération des types de base reconnus 
enum base_type_t {UNKNOWN, INT};
//Table enregistrant la taille de ces types de bases (indexée sur les types)
extern int taille_types[];
//Structure gérant les types 
struct type_t {
    //Champs enregsitrant le type de base
    enum base_type_t base;
    //Si la variable est un pointeur, on enregitre son niveau (nombre de *)
    int pointeur_level;
    //Si il s'agit d'un tableau, on enregistre sa taille (nombre de cases)
	int nb_blocs;
};
//Constante pour les entiers
extern const struct type_t integer;



/**************************************/
/**************************************/
/*****  Gestion de la profondeur  *****/
/**************************************/
/**************************************/
//Incrémente la profondeur
void inc_prof();
//Récupère la profondeur
int get_prof();
//Détruit toutes les variables de la profondeur actuelle puis décrémente la profondeur
void reset_prof();



/**************************************/
/**************************************/
/*Table des symboles : fonctionnement */
/**************************************/
/**************************************/

//Structure représentant un symbole
struct symbole_t {
    //Son Nom
	char nom[30];
    //Son Adresse
	uintptr_t adresse;
    //Son type
	struct type_t type;
    //Est il initialisé
	int initialized;
    //Sa profondeur de création
    int profondeur;
};

//Fonction d'affichage d'un symbole
void print_symbole(struct symbole_t symbole);

//Fonction d'initialisation de la table, à appeler une fois
void init(void);






/**************************************/
/**************************************/
/** Table des symboles : primitives  **/
/**************************************/
/**************************************/

//Ajout d'un symbole a la table
int push(char * nom, int isInit, struct type_t type);
//Destruction et récupération du premier élément de la table
struct symbole_t pop();
//Retourne la dernière adresse disponible
int get_last_addr();
//Renvoi un pointeur vers le symbole correspondant au nom de variable
struct symbole_t * get_variable(char * nom);
//Affiche la table des symboles
void print();

