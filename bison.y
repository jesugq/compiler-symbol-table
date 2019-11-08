%token BEGINS
%token ENDS
%token IF
%token ELSE
%token IFELSE
%token WHILE
%token READ
%token PRINT

%token INT
%token FLOAT
%token VAR

%token COLON
%token SEMICOLON
%token LEFT_PARENTHESES
%token RIGHT_PARENTHESES
%token PLUS
%token MINUS
%token ASTERISK
%token SLASH
%token LESS_THAN
%token GREATER_THAN
%token EQUALS
%token LESS_THAN_EQUALS
%token GREATER_THAN_EQUALS

%token INTEGER_TYPE
%token FLOATING_TYPE
%token IDENTIFIER

%start prog
%empty epsilon

%%

prog        : opt_decls BEGINS opt_stmts ENDS   { bison_print_success(); }
;

opt_decls   : decls
            | epsilon
;

decls       : dec SEMICOLON decls
            | dec
;

dec         : VAR IDENTIFIER COLON tipo
;

tipo        : INTEGER_TYPE
            | FLOATING_TYPE

%%

#include <stdio.h>
#include "semantic.h"