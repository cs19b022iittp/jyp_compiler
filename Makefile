parser: lexical.l lex.y
	lex lexical.l
	yacc -d lex.y
	yacc lex.y -o gm.cc
	cc -c  lex.yy.c -o lex.yy.o
	g++ lex.yy.o gm.cc -o  parser 
clean:
	rm -f y.tab.c lex.yy.c y.tab.h parser y.output lex.yy.o gm.cc gm.hh
