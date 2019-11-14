%{
// Imports
// #include <stdio.h>
// #include <stdbool.h>
#include "hash_table.c"

// Flex externals
extern FILE * yyin;
extern int yylineno;
extern char * yytext;
extern int yylex();
extern int yyerror(char const *);

// Hash table externals
extern struct hash_table table;

// Declarations
%}

%union {
    int reserved;
    int type;
    bool boolean;
    double numeric;
    char * string;
}

%token<reserved> WRD_BEGINS WRD_ENDS WRD_IF WRD_ELSE WRD_IFELSE WRD_WHILE WRD_READ WRD_PRINT WRD_INT WRD_FLOAT WRD_VAR
%token<reserved> OPT_COLON OPT_SEMICOLON OPT_OPENS OPT_CLOSES OPT_PLUS OPT_MINUS OPT_ASTERISK OPT_SLASH OPT_LESS OPT_GREATER OPT_EQUALS OPT_LTE OPT_GTE OPT_ASSIGN OPT_NEGATIVE
%token <numeric> VAL_INTEGER VAL_FLOAT
%token <string> VAL_IDENTIFIER

%type<reserved> prog opt_decls decls dec opt_stmts stmt_lst stmt signo
%type<type> tipo relop
%type<boolean> expression
%type<numeric> expr term factor

%start prog

%%
prog
    : opt_decls WRD_BEGINS opt_stmts WRD_ENDS
;
opt_decls
    : decls
    | %empty
;
decls
    : dec OPT_SEMICOLON decls
    | dec
;
dec
    : WRD_VAR VAL_IDENTIFIER OPT_COLON tipo
;

tipo
    : WRD_INT
    | WRD_FLOAT
;
opt_stmts
    : stmt_lst
    | %empty
;
stmt_lst
    : stmt OPT_SEMICOLON stmt_lst
    | stmt
;
stmt
    : VAL_IDENTIFIER OPT_ASSIGN expr
    | WRD_IF OPT_OPENS expression OPT_CLOSES stmt
    | WRD_IFELSE OPT_OPENS expression OPT_CLOSES stmt stmt
    | WRD_WHILE OPT_OPENS expression OPT_CLOSES stmt
    | WRD_READ VAL_IDENTIFIER
    | WRD_PRINT expr
    | BEGINS opt_stmts ENDS
;
expression
    : expr
    | expr relop expr
;
expr
    : expr OPT_PLUS term
    | expr OPT_MINUS term
    | signo term
    | term
;
term
    : term OPT_ASTERISK factor
    | term OPT_SLASH factor
    | factor
;
factor
    : OPT_OPENS expr OPT_CLOSES
    | VAL_IDENTIFIER
    | VAL_INTEGER
    | VAL_FLOAT
;
relop
    : LESS
    | GREATER
    | EQUALS
    | LTE
    | GTE
;
signo
    : OPT_NEGATIVE
;
%%