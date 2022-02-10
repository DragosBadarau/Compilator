%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "temafinal.h"

extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern char* yytext;

%}
%union {
  int intVal; //valoare
  char* dataType; // tip de data
  char* strVal; // ID
  char *key;
}

%token EQ PLUS MINUS FUNC CLASA DEQ DIF LEQ GEQ LE GE AND OR EVAL OBJ BEG END RETURN TRUE FALSE WHILE FOR IF ELSE CHARVAL STRINGVAL
%token <dataType> INT BOOL STRING CHAR FLOAT VOID ARRAY
%token <intVal> NR
%token <strVal> ID

%type <intVal> exp e 

%start s
%left PLUS MINUS
%left DIV MUL
%%

s: progr {printf ("\n Limbajul este corect din punct de vedere sintactic.\n"); Print(); Scrie();ScrieFunc();}

progr : global_variables functions



global_variables : objects
                 | EVAL '(' exp ')'
                 |
                 ;

objects : objects object variabileplus
        | object variabileplus
        ;

object : CLASA OBJ ID BEG variabile OBJEnd 
       | CLASA OBJ ID BEG OBJEnd
       ;

variabileplus  : { instructiuniplus(); }
               ;

OBJEnd    : END { instructiuniminus(); }
          ;

variabile    : variabile variabila
             | variabila
             ;

variabila : INT ID EQ NR';' {insereaza($1,$2,$4);}
          | INT ID';'       {insereaza($1, $2, 2147483647);}
          | CHAR ID EQ CHARVAL';'{insereaza($1, $2, -1);}
          | CHAR ID';'        {insereaza($1, $2, -1);}
          | STRING ID EQ STRINGVAL';'{insereaza($1, $2, -1);}
          | STRING ID';'{insereaza($1, $2, -1);}
          | BOOL ID EQ TRUE';'{insereaza($1, $2, 1);}
          | BOOL ID EQ FALSE';'{insereaza($1, $2, 0);}
          | BOOL ID';'{insereaza($1,$2,-1);}
          | ARRAY ID EQ arraylist';'{insereaza($1, $2, -1);}
          | OBJ ID object';'
          | OBJ ID';'
          | EVAL '(' exp ')'
          | ID '(' calls ')'  {    inserareNume($1);
                                                   if (verificareIdentitate($1)==0)
                                                       printf("Tipul functiei apelate nu se potriveste cu tipurile declarate pentru %s \n", $1);
                                             }

arraylist : '['']'
          | '['list']'
          ;

list : list',' listval
     | listval
     ;

listval : NR
        | CHARVAL
        | STRINGVAL
        | ID
        | object
        | arraylist
        ;

functions : functions function variabileplus
          | function variabileplus
          ;
function  : FUNC INT ID  functionBody { inserareInFunctieSemn($2); inserareInFunctieSemn($3); inserareNumeArray($3); insereazaFunc();}
          | FUNC CHAR ID   functionBody { inserareInFunctieSemn($2); inserareInFunctieSemn($3); inserareNumeArray($3); insereazaFunc();}
          | FUNC VOID ID  functionBody { inserareInFunctieSemn($2); inserareInFunctieSemn($3); inserareNumeArray($3); insereazaFunc();}
          | FUNC BOOL ID   functionBody { inserareInFunctieSemn($2); inserareInFunctieSemn($3); inserareNumeArray($3); insereazaFunc();}
          | FUNC STRING ID functionBody { inserareInFunctieSemn($2); inserareInFunctieSemn($3); inserareNumeArray($3); insereazaFunc();}
          | FUNC INT EVAL '(' exp ')'
          | ID '(' calls ')' {    inserareNume($1);
                                                   if (verificareIdentitate($1)==0)
                                                       printf("Tipul functiei apelate nu se potriveste cu tipurile declarate pentru %s \n", $1);
                                             }
          ;

functionBody   : '(' decls ')' body
               ;

calls    : calls ',' call
         | call
         ;

call     : INT ID {inserareArrayUser($1);}
                    | CHAR ID {inserareArrayUser($1);}
                    | STRING ID {inserareArrayUser($1);}
                    | BOOL ID {inserareArrayUser($1);}
                    | function      
                    | NR {inserareArrayUser("int");}
                    ;

decls    : decls ',' decl
         | decl
         ;

decl     : INT ID    {  inserareArrayParam($1);}
         | CHAR ID   {  inserareArrayParam($1);}
         | STRING ID {  inserareArrayParam($1);}
         | BOOL ID   {  inserareArrayParam($1);}
         ;


exp       : e  {$$=$1; printf("Valoarea expresiei este %d\n",$$);} 
          ;

e : e PLUS e   {$$=$1+$3; }
  | e MINUS e   {$$=$1-$3; }
  | e MUL e   {$$=$1*$3; }
  | e DIV e   {$$=$1/$3; }
  | NR {$$=$1; }
  | INT ID EQ NR';' { int i; 
                              if((i=cauta($2)) != -1)
                              { 
                                   actualizeazaVAL($2, $4);
                                   $$ =  tabel[i].valoare ;
                                   
                              }
                              else {
                                  printf("Variabila nu exista\n"); 
                                  printf("Eroare: argumentul pentru Eval nu este valid!\n");
                                   exit(0);
                              }
                              }
  | INT ID';' { int i;
                         if((i=cauta($2)) != -1)
                         {   
                              $$= tabel[i].valoare;
                         }
                          else 
                          {
                                   printf("Variabila nu exista\n"); 
                                   printf("Eroare: argumentul pentru Eval nu este valid!\n");
                                   exit(1);
                          }
                        }
  ;

body      : BEG blocks RETURN BODYEnd
          | BEG blocks BODYEnd
          | BEG END
          ;

BODYEnd   : END { instructiuniminus(); }
          ;

blocks   : blocks block 
         | block
         ;

block    : variabila
         | assignment
         | while
         | for
         | if
         ;

while : WHILE variabileplus '(' conditii ')' body
      ;

for  : FOR variabileplus '(' assignment conditii ';' assignment ')' body
     ;

if   : IF variabileplus '(' conditii ')' body
     | IF variabileplus '(' conditii ')' body ELSE variabileplus body
     ;


assignment : ID EQ NR';' { actualizeazaVAL($1, $3); }
           | ID EQ CHARVAL';'
           | ID EQ STRINGVAL';'
           | ID EQ TRUE';'
           | ID EQ FALSE';'
           | ID EQ arraylist';'
           | ID EQ operatie';' 
           | ID EQ ID';' { actualizeazaID($1, $3); }
           ;

operatie  : plus
          | minus
          | mul
          | div
          ;

plus : ID PLUS ID { verificDeclaratii($1); verificDeclaratii($3); }
     | ID PLUS NR { verificDeclaratii($1);}
     | NR PLUS ID { verificDeclaratii($3);}
     ;

minus : ID MINUS ID { verificDeclaratii($1); verificDeclaratii($3); }
      | ID MINUS NR { verificDeclaratii($1);}
      | NR MINUS ID { verificDeclaratii($3);}
      ;

div  : ID DIV ID { verificDeclaratii($1); verificDeclaratii($3); }
     | ID DIV NR { verificDeclaratii($1);}
     | NR DIV ID { verificDeclaratii($3);}
     ;

mul  : ID MUL ID { verificDeclaratii($1); verificDeclaratii($3); }
     | ID MUL NR { verificDeclaratii($1);}
     | NR MUL ID { verificDeclaratii($3);}
     ;



conditii  : conditii Op conditie
          | conditie
          ;

Op : AND
   | OR
   ;

conditie  : TRUE
          | FALSE
          | NR bool NR
          | ID bool NR
          | NR bool ID
          | ID bool ID
          ;

bool    : DEQ
        | GEQ
        | LEQ
        | DIF
        | LE
        | GE
        ;


%%

int yyerror(char * s){
printf("Eroare: %s pe linia:%d si yytext este %s\n",s,yylineno,yytext);
}

int main(int argc, char** argv){
     yyin=fopen(argv[1],"r");
     yyparse();
}
