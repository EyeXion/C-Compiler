default : 
	@echo "Spécifiez une cible"



###########################
###      NETTOYAGE      ###
###########################
clean : clean_Symboles clean_Instructions clean_Lex_Yacc clean_Fonctions
	@rm -f rondoudou_gcc
	@rm -f output.txt

clean_Symboles:
	@rm -f Tables/Symboles/*.o
	@rm -f Tables/Symboles/test

clean_Instructions:
	@rm -f Tables/Instructions/*.o
	@rm -f Tables/Instructions/test

clean_Fonctions:
	@rm -f Tables/Fonctions/*.o
	@rm -f Tables/Fonctions/test

clean_Lex_Yacc:
	@rm -f Lex_Yacc/as.output Lex_Yacc/as.tab.* Lex_Yacc/lex.yy.*



###########################
###     COMPILATION     ###
###########################
build : clean build_Symboles build_Instructions build_Lex_Yacc build_Fonctions
	gcc Lex_Yacc/as.tab.o Lex_Yacc/lex.yy.o Tables/Instructions/tab_instruc.o Tables/Symboles/table_symboles.o Tables/Fonctions/tab_fonctions.o -ly -o rondoudou_gcc

build_Symboles: clean_Symboles
	gcc -c Tables/Symboles/table_symboles.c -o Tables/Symboles/table_symboles.o

build_Instructions: clean_Instructions
	gcc -c Tables/Instructions/tab_instruc.c -o Tables/Instructions/tab_instruc.o

build_Fonctions : clean_Fonctions
	gcc -c Tables/Fonctions/tab_fonctions.c -o Tables/Fonctions/tab_fonctions.o

build_Lex_Yacc: clean_Lex_Yacc
	bison -g -v -d -t -b Lex_Yacc/as Lex_Yacc/as.y
	flex -o Lex_Yacc/lex.yy.c Lex_Yacc/al.lex
	gcc -c Lex_Yacc/as.tab.c -o Lex_Yacc/as.tab.o
	gcc -c Lex_Yacc/lex.yy.c -o Lex_Yacc/lex.yy.o



###########################
###        TESTS        ###
###########################
test_Symboles: build_Symboles
	gcc -c Tables/Symboles/test.c -o Tables/Symboles/test.o
	gcc Tables/Symboles/test.o Tables/Symboles/table_symboles.o -o Tables/Symboles/test
	Tables/Symboles/test

test_Instructions: build_Instructions
	gcc -c Tables/Instructions/test.c -o Tables/Instructions/test.o
	gcc Tables/Instructions/test.o Tables/Instructions/tab_instruc.o -o Tables/Instructions/test
	Tables/Instructions/test

test_Fonctions: build_Fonctions
	gcc -c Tables/Fonctions/test.c -o Tables/Fonctions/test.o
	gcc Tables/Fonctions/test.o Tables/Fonctions/tab_fonctions.o -o Tables/Fonctions/test
	Tables/Fonctions/test

test: build
	cat Fichiers_Tests/progC | ./rondoudou_gcc 



###########################
###       EDITION       ###
###########################
edit_Lex_Yacc: 
	pluma Lex_Yacc/al.lex Lex_Yacc/as.y &

edit_Symboles: 
	pluma Tables/Symboles/table_symboles.c Tables/Symboles/table_symboles.h &

edit_Instructions: 
	pluma Tables/Instructions/tab_instruc.c Tables/Instructions/tab_instruc.h &

edit_Progs: 
	pluma Fichiers_Tests/progC &

edit_Fonctions :
	pluma Tables/Fonctions/tab_fonctions.c Tables/Fonctions/tab_fonctions.h &

edit: edit_Lex_Yacc edit_Symboles edit_Instructions edit_Progs edit_Fonctions
