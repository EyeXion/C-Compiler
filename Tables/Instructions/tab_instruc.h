#define MAXTAILLE 1024
#include <stdlib.h>
#include <string.h>
#include <stdio.h>


enum opcode_t {ADD,MUL,SOU,DIV,COP,AFC,JMP,JMF,INF,SUP,EQU,PRI};

struct operation_t {
	enum opcode_t opcode;
	int arg1;
	int arg2;
	int arg3;
};

extern struct operation_t tab_op[MAXTAILLE];

void add_operation(enum opcode_t opcode, int arg1, int arg2, int arg3);
void create_asm();
int get_current_index();
void patch(int index, int arg);
