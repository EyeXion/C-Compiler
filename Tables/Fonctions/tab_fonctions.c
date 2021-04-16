struct fonction_t tab_fonctions[MAX_TAILLE_FONC];
int index = 0;


struct fonction_t get_fonction(char * name){
	int not_found = 1;
	int i = 0;
	struct fonction_t res = NULL;
	while (not_found && (i <= index)){
		if (!strcmp(name,tab_fonctions[i].name){
			res = tab_fonctions[i];
			not_found = 0;
		}
		i++;
	}
	return res;
}

void push_fonction(char * name, struct type_t type, int line){
	if (index < MAX_TAILLE_FONC){
		struct fonction_t fonc;
		strcpy(fonc.name,name);
		fonc.type = type;
		fonc.first_instruction_line = line;
		tab_fonctions[i] = fonc;
		index++;
	}
}

