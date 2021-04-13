#include "tab_instruc.h"
int current_index = 0;
struct operation_t tab_op[MAXTAILLE];

void add_operation(enum opcode_t opcode, int arg1, int arg2, int arg3){
	if (current_index == MAXTAILLE){
		printf("Taillemax tableau operations atteinte\n");
	}
	else{
		struct operation_t new_op = {opcode, arg1, arg2, arg3};
		tab_op[current_index] = new_op;
		current_index++;
	}
}



char * get_asm_line_from_op(struct operation_t op){
	char * buffer = malloc(sizeof(char)*200);
	switch (op.opcode){
		case (ADD):
			sprintf(buffer,"ADD %d %d %d\n",op.arg1, op.arg2, op.arg3);
			break;
		case (MUL):
			sprintf(buffer,"MUL %d %d %d\n",op.arg1, op.arg2, op.arg3);
			break;
		case (SOU):
			sprintf(buffer,"SOU %d %d %d\n",op.arg1, op.arg2, op.arg3);
			break;
		case (DIV):
			sprintf(buffer,"DIV %d %d %d\n",op.arg1, op.arg2, op.arg3);
			break;
		case (COP):
			sprintf(buffer,"COP %d %d\n",op.arg1, op.arg2);
			break;
		case (AFC):
			sprintf(buffer,"AFC %d %d\n",op.arg1, op.arg2);
			break;
		case (COPA):
			sprintf(buffer,"COPA %d %d\n",op.arg1, op.arg2);
			break;
		case (JMP):
			sprintf(buffer,"JMP %d\n",op.arg1);
			break;
		case (JMF):
			sprintf(buffer,"JMF %d %d\n",op.arg1, op.arg2);
			break;
		case (INF):
			sprintf(buffer,"INF %d %d %d\n",op.arg1, op.arg2, op.arg3);
			break;
		case (SUP):
			sprintf(buffer,"SUP %d %d %d\n",op.arg1, op.arg2, op.arg3);
			break;
		case (EQU):
			sprintf(buffer,"DIV %d %d %d\n",op.arg1, op.arg2, op.arg3);
			break;
		case (PRI):
			sprintf(buffer,"PRI %d\n",op.arg1);
			break;
		case (READ):
			sprintf(buffer,"READ %d %d\n",op.arg1, op.arg2);
			break;
		case (WR):
			sprintf(buffer,"WR %d %d\n",op.arg1, op.arg2);
			break;
	}
	return buffer;
}

void create_asm(){
	FILE * output = fopen("output.txt","w");
	for (int i = 0; i < current_index; i++){
		char * line = get_asm_line_from_op(tab_op[i]);
		fputs(line, output);
		free(line);
	}
}

int get_current_index(){return current_index;}



void patch(int index, int arg){
	if (tab_op[index].opcode == JMP){
		tab_op[index].arg1 = arg;
	}
	else if (tab_op[index].opcode == JMF){
		tab_op[index].arg2 = arg;
	}
}
