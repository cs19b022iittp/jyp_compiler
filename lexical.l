%{

#include <stdio.h>
#include<stdlib.h>
#include "y.tab.h"
#include <string.h>

%}

digit [0-9]
letter_ [A-Za-z_]
delim [ \t\n]
number {digit}+(\.{digit}+)?(E[+-]?{digit}+)*
ws {delim}+
floatdecimal digit{1,7}
doubledecimal digit{1,15}
 
%%


"integer"						    {strcpy(yylval.lexeme,yytext); printf("\n keyword %s", yytext); return INTEGER; }
"float"						    { strcpy(yylval.lexeme,yytext); printf("\n keyword %s", yytext); return FLOAT;}
"double"						    { strcpy(yylval.lexeme,yytext); printf("\n keyword %s", yytext); return DOUBLE;}
"long"						    	    { strcpy(yylval.lexeme,yytext); printf("\n keyword %s", yytext); return LONG;}
"string"						    {strcpy(yylval.lexeme,yytext); return STRING;}
"if"						    	    { return IF;}
"elif"						    	    { return ELIF;}
"else"						    	    { return ELSE;}
"for"						    	    { return FOR;}
"while"						    { return WHILE;}
"return"						    { return RETURN;}
"first"						    { printf("\n keyword %s", yytext); return FIRST;}
"end"						    	    { printf("\n keyword %s\n \n \n", yytext); return END;}
"switch"						    {return SWITCH;}
"case"						    	    { return CASE;}
"void"						    	    { return VOID;}
"inp"						    	    { return INP;}
"out"						    	    { return OUT;}
"break"						    { return BREAK;}
"continue"						    { return CONT;}
"char"						    	    { return CHAR;}
"bool"						    	    { return BOOL;}

";"				return SCOL;

("++")                         {return INCREMENT;}

("--")    			{return DECREMENT;}

("+=")				{return ASGNADD;}

("-=")				{return ASGNSUB;}

("*=")				{return ASGNMUL;}

("/=")				{return ASGNDIV;}

("%=")               		{return ASGNMOD;}

"+"				{return ADD; }  
                  
"-"				{return SUB;}

"*"				{ return MUL; }

"/"				{return DIV;}

"%"				{return MOD;}

"="				{printf("\n keyword %s", yytext);return ASSIGN; }

"&&" 				{return AND; }        

"||"				{ return OR; }

"^"				{ return XOR; }

"!"				{ return NOT;}

"<="				{ return LTE; }

">="				{return GTE;}

"<"				return LT;

">"				return GT;
STRING
"=="				{ return EQUAL; }

"!="				{return NOTEQUAL; }

"{"				return '{';
"}"				return '}';

"("				return '(';

")"				return ')';

"["				return '[';

"]"				return ']';

","				return ',';

{digit}*                                                       {yylval.integer=atoi(yytext); return INTEGER_CONSTANT;}
"-"{digit}*                                                    { return NEGINT_CONST;}
{digit}*?\.{digit}+                                       {yylval.f=atof(yytext);return FLOAT_CONSTANT;}

\".*\"                                                       {strcpy(yylval.string,yytext);return STRING_CONSTANT;}
{letter_}({letter_}|{digit})*                                { strcpy(yylval.lexeme,yytext); printf("\n keyword %s", yytext);  return IDENTIFIER;}

{delim}+				;

"/*"(.|\n)*"*/"   ;
"//"(.)*"" ;
. ;
%%

int yywrap(){}






