%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"/*"(.|\n|\r)+"*/" ;

#[A-Za-z][A-Za-z0-9]* {yylval.strVal = strdup(yytext);return ID;}
0|[1-9][0-9]*|[+-][1-9][0-9]* {yylval.intVal = atoi(yytext);return NR;}
[ \t] ;



"functie" {return FUNC;}
"clasa" {return CLASA;}

"==" {return DEQ;}
"!=" {return DIF;}
"<=" {return LEQ;}
">=" {return GEQ;}
"<" {return LE;}
">" {return GE;}

"=" {return EQ;}
"+" {return PLUS;}
"-" {return MINUS;}
"/" {return DIV;}
"*" {return MUL;}

"&&" {return AND;}
"||" {return OR;}

"Eval" {return EVAL;}
"int"       {yylval.dataType = strdup(yytext);return INT;} 
"char"        {yylval.dataType = strdup(yytext);return CHAR;}
"float"       {yylval.dataType = strdup(yytext);return FLOAT;}
"string"          {yylval.dataType = strdup(yytext);return STRING;}
"void"      {yylval.dataType = strdup(yytext);return VOID;}  
"bool"       {yylval.dataType = strdup(yytext);return BOOL;}
"array"                 {yylval.dataType = strdup(yytext);return ARRAY;}
"object"                  {yylval.dataType = strdup(yytext);return OBJ;}
"{"                    {return BEG;}
"}"   {return END;}
"return" {return RETURN;}
"true"  {return TRUE;}
"false"   {return FALSE;}
"while" {return WHILE;}
"for" {return FOR;}
"if" {return IF;}
"else" {return ELSE;}
\'.\' {return CHARVAL;}
\"[^\"]+\" {return STRINGVAL;}

\n {yylineno++;}
. {return yytext[0];}
