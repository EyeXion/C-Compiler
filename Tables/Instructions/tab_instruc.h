#define MAXTAILLE 1024
#include <stdlib.h>
#include <string.h>
#include <stdio.h>


enum opcode_t {ADD,MUL,SOU,DIV,COP,AFC,COPA,JMP,JMF,INF,SUP,EQU,PRI,READ,WR};

struct operation_t {
	enum opcode_t opcode;
	int arg1;
	int arg2;
	int arg3;
};

//Ajoute une opération dans la table (à la fin)
void add_operation(enum opcode_t opcode, int arg1, int arg2, int arg3);
//Renvoi le prochain slot disponible
int get_current_index();
//Permet de patcher les Jump (pas de Van Halen)
void patch(int index, int arg);
//Ecrit la table des intructions dans un fichier ASM
void create_asm();
