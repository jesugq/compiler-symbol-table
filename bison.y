%{
#include <stdio.h>

int yylex();
int yyerror(char const * text);

void print_success();
%}

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
%token LEFT_PARENTHESIS
%token RIGHT_PARENTHESIS
%token PLUS
%token MINUS
%token ASTERISK
%token SLASH
%token LESS_THAN
%token GREATER_THAN
%token EQUALS
%token LESS_THAN_EQUALS
%token GREATER_THAN_EQUALS
%token ASSIGNMENT

%token INTEGER_TYPE
%token FLOATING_TYPE
%token IDENTIFIER

%union {
    int integer_value;
    float floating_value;
    char * string_value;
}

%start prog

%%
prog        : opt_decls BEGINS opt_stmts ENDS   { print_success(); }
;

opt_decls   : decls
            | %empty
;

decls       : dec SEMICOLON decls
            | dec
;

dec         : VAR IDENTIFIER COLON tipo
;

tipo        : INTEGER_TYPE
            | FLOATING_TYPE
;

stmt        : IDENTIFIER ASSIGNMENT expr
            | IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS stmt
            | IFELSE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS stmt stmt
            | WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS stmt
            | READ IDENTIFIER
            | PRINT expr
            | BEGINS opt_stmts ENDS
;

opt_stmts   : stmt_lst
            | %empty

stmt_lst    : stmt SEMICOLON stmt_lst
            | stmt
;

expr        : expr PLUS term
            | expr MINUS term
            | term
;

term        : term ASTERISK factor
            | term SLASH factor
            | factor
;

factor      : LEFT_PARENTHESIS expr RIGHT_PARENTHESIS
            | IDENTIFIER
            | INTEGER_TYPE
            | FLOATING_TYPE
;

expression  : expr LESS_THAN expr
            | expr GREATER_THAN expr
            | expr EQUALS expr
            | expr LESS_THAN_EQUALS expr
            | expr GREATER_THAN_EQUALS expr
;
%%

/*
 * Prints Flex's Error.
 */
int yyerror(char const * text) {
    fprintf(stderr, "%s\n", text);
}

/*
 * Prints a success message after the code is correctly read.
 */
void print_success() {
    printf("Success!\n");
}

/*
 * Executes the program.
*/
void main() {
    yyparse();
}