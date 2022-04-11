
parser: y.tab.c lex.yy.c y.tab.h
	gcc y.tab.c lex.yy.c -o parser
lex.yy.c: lexical.l
	lex lexical.l
y.tab.c: lex.y
	yacc -v -d lex.y
clean:
	rm -f y.tab.c lex.yy.c y.tab.h parser y.output
