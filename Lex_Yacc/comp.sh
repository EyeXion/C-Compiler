bison -d -t as.y -v
flex al.lex 
gcc *.c ../Symboles/table_symboles.c -ly
cat ../Fichiers_Tests/progC | ./a.out 

