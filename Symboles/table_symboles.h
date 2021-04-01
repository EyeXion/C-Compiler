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

enum type_t {UNKNOWN, INT};
int taille_types[] = {-1, 4};

char * tab_instructions[2] = {"ADD %d %d", "SUB %d %d"}

struct symbole_t {
	char nom[30];
	uintptr_t adresse;
	enum type_t type;
	char initialized;
    int profondeur;
};

void print_symbole(struct symbole_t symbole);

int profondeur = 0;

void init(void);
void push(struct symbole_t symbole, struct pile_t * pile);
struct symbole_t pop(struct pile_t * pile);
// renvoi 0 si nom n'existe pas, 2 si nom existe sans etre initialisée, 1 sinon
char status(char * nom, struct pile_t * pile);
void print(struct pile_t * pile);
