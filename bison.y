%{
#include <stdio.h>
#include <stdbool.h>

int lines;
FILE * yyin;
char * yytext;
int yylex();
int yyerror(char const * text);

void print_success();
bool verify_arguments(int argc, char * argv[]);
int main(int argc, char * argv[]);
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

tipo        : INT
            | FLOAT
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
    fprintf(stderr, "%s found while reading \'%s\' at line %d.\n",
        text, yytext, lines);
    fclose(yyin);
}

/*
 * Prints a success message after the code is correctly read.
 */
void print_success() {
    printf("Success!\n");
}

/* 
 * Prints an error message if either:
 *  No input file was inserted.
 *  Too many arguments were inserted.
 * 
 * @param   argc    Argument Count.
 * @return  Whether the execution should proceed.
 */
bool print_argument_verification(int argc, char * argv[]) {
    if (argc < 2) {
        fprintf(stderr, "No filename argument was provided.\n");
        return false;
    } else if (argc > 2) {
        fprintf(stdout, "Too many arguments used, using %s\n", argv[1]);
        return true;
    } else return true;
}

/*
 * Executes the program.
*/
int main(int argc, char * argv[]) {
    if (print_argument_verification(argc, argv)){
        yyin = fopen(argv[1], "r");
        yyparse();
        fclose(yyin);
    }
    return 0;
}