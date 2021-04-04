#include "table_symboles.h"
#include <stdio.h>

int main() {
    printf("Procedure de test de la Table des Symboles\n");
    init();
    printf("Affichage de la Table des Symboles (vide)\n");
    print(pile);

    printf("Test de la fonction push :\n");
    struct symbole_t symbole = {"Salut", 0x77b58af, INT, 1};
    push(symbole, pile);
    printf("Affichage de la Table des Symboles (1 élément : Salut)\n");
    print(pile);
    struct symbole_t symbole2 = {"Coucou", 0x77b54af, UNKNOWN, 0};
    push(symbole2, pile);
    printf("Affichage de la Table des Symboles (2 élément : Salut, Coucou)\n");
    print(pile);

    printf("Test de la fonction status :\n\tStatus de Salut (1 expected) : %d\n\tStatus de Coucou (2 expected) : %d\n\tStatus de Truc (0 expected) : %d\n", (int)status("Salut",pile), (int)status("Coucou",pile), (int)status("Truc",pile));
    
    printf("Test de la fonction pop :\n");
    printf("Symbole expected Coucou\n\t");
    print_symbole(pop(pile));
    print(pile);
    printf("Symbole expected Salut\n\t");
    print_symbole(pop(pile));
    print(pile);
    printf("Symbole expected Aucun\n\t");
    print_symbole(pop(pile));
    print(pile);
}
