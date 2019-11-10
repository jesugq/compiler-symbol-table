%{
#include <stdio.h>
#include <stdbool.h>

enum type { INTEGER_TYPE, FLOATING_TYPE };

extern char * yytext;
extern int yylineno;
extern FILE * yyin;
int yylex();
int yyerror(char const * text);

void print_accepted();
bool verify_arguments(int argc, char * argv[]);
bool verify_file(FILE * file, char * arge);
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

%token INTEGER_VALUE
%token FLOATING_VALUE
%token IDENTIFIER

%union {
    int type;
    char * id;
}
%start prog

%%
prog        : opt_decls BEGINS opt_stmts ENDS   { print_accepted(); }
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
            | INTEGER_VALUE
            | FLOATING_VALUE
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
 * @param   text    Error message.
 * @return  Error code.
 */
int yyerror(char const * text) {
    fprintf(stderr, "\n%s found while reading \'%s\' at line %d.\n", text, yytext, yylineno);
    return 1;
}

/*
 * Prints a success message after the code is correctly read.
 */
void print_accepted() {
    printf("\nFile accepted.\n");
}

/* 
 * Prints an error message if either:
 *  No input file was inserted.
 *  Too many arguments were inserted.
 * 
 * @param   argc    Argument Count.
 * @return  Whether execution should proceed.
 */
bool verify_arguments(int argc, char * argv[]) {
    if (argc < 2) {
        fprintf(stderr, "\nNo file argument was provided.\n");
        return false;
    } else if (argc > 2) {
        fprintf(stdout, "Too many arguments used, using '%s'.\n", argv[1]);
        return true;
    } else return true;
}

/* Prints an error message if the file is null.
 *
 * @param   file    File pointer to verify.
 * @return  Whether execution should proceed.
 */
bool verify_file(FILE * file, char * arge) {
    if (file == NULL) {
        fprintf(stderr, "\nFailed to open file '%s'.\n\n", arge);
        return false;
    } else return true;
}

/*
 * Executes the program.
*/
int main(int argc, char * argv[]) {
    if (!verify_arguments(argc, argv)) return 1;
    yyin = fopen(argv[1], "r");
    if (!verify_file(yyin, argv[1])) return 1;

    yyparse();
    fclose(yyin);
    fprintf(stdout, "\n");
    return 0;
}