# Descritpion opcodes



## ADD @Y @A @B 

Met dans l'adresse @Y le résultat de l'addition des valeurs contenues aux adresses @A et @B

## SOU @Y @A @B 

Idem ADD mais Soustraction

## MUL @Y @A @B 

Idem ADD mais multiplication

## DIV @Y @A @B 

Idem ADD mais division

## COP @X @Y

Copie le contenu de l'adresse @Y à l'adresse @X

## AFC @X val

Copie la valeur val à l'adresse @X

## AFCA @X @C

Copie la valeur contenue dans @C à l'adresse @X en considérant que ce qui est copié est une adresse (et donc il faut ajouter BP)

## JMP lig

Saute vers la ligne lig dans le code sans condition

## JMF @X lig

Saute vers la ligne lig dans le code si la valeur à l'adresse @X est 0

## INF @X @A @B

Met à l'adresse @X 1 si val en @A plus petite que en @B et 0 sinon

## SUP @X @A @B 

Met à l'adresse @X 1 si val en @A plus grande que en @B et 0 sinon

## EQU @X @A @B 

Met à l'adresse @X 1 si val en @A égale à celle en @B et 0 sinon

## READ @X @Y

Va mettre à l'adresse @X ce qui est à l'addresse contenue à l'adresse @Y (on considère que ce qui est dans @Y est un adresse et on va voir à cette adresse)

## WR @X @Y

Va mettre le contenue dans @Y dans l'adresse qui est la valeur dans @X (on considère que @X est un pointeur et on écrit dans l'adresse qui est contenue dans @X)

