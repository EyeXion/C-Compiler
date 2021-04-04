bison -d -t as.y -v
flex al.lex 
gcc as.tab.c lex.yy.c ../Symboles/tab_instruc.c ../Symboles/table_symboles.c -ll -o a.exe
cat ./ProgC | ./a.exe
