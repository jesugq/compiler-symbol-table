%{
// Imports
#include <stdio.h>
#include <stdbool.h>
#include "hash_table.c"

// Flex Connections
extern char * yytext;
extern int yylineno;
extern FILE * yyin;
extern int yylex();
extern int yyerror(char const * text);

// Hash Table Connections
extern struct hash_table table;

// Declarations
void print_accepted();
bool verify_arguments(int argc, char * argv[]);
bool verify_file(FILE * file, char * arge);
int main(int argc, char * argv[]);

void what_am_i(char * code);
%}

%union {
    int reserved;
    int type;
    int operator;
    int integer;
    float floating;
    char * identifier;
}

%token<reserved> BEGINS
%token<reserved> ENDS
%token<reserved> IF
%token<reserved> ELSE
%token<reserved> IFELSE
%token<reserved> WHILE
%token<reserved> READ
%token<reserved> PRINT

%token<type> INT
%token<type> FLOAT
%token<type> VAR

%token<operator> COLON
%token<operator> SEMICOLON
%token<operator> LEFT_PARENTHESIS
%token<operator> RIGHT_PARENTHESIS
%token<operator> PLUS
%token<operator> MINUS
%token<operator> ASTERISK
%token<operator> SLASH
%token<operator> LESS_THAN
%token<operator> GREATER_THAN
%token<operator> EQUALS
%token<operator> LESS_THAN_EQUALS
%token<operator> GREATER_THAN_EQUALS
%token<operator> ASSIGNMENT

%token<integer> INTEGER_VALUE
%token<floating> FLOATING_VALUE
%token<identifier> IDENTIFIER

%start prog

%%
prog        : opt_decls BEGINS opt_stmts ENDS {
                print_accepted();
            }
;

opt_decls   : decls
            | %empty
;

decls       : dec SEMICOLON decls
            | dec
;

dec         : VAR IDENTIFIER COLON tipo {
                what_am_i($2);
            }
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

void what_am_i(char * code) {
    printf("Code: %s\n", code);
}

/**
 * @function    yyerror
 * @abstract    Prints Flex's Error.
 * @param       text    Error message.
 * @return      Error code.
 */
int yyerror(char const * text) {
    fprintf(stderr, "\n%s found while reading '%s' at line %d.\n", text, yytext, yylineno);
    return 1;
}

/**
 * @function    print_accepted
 * @abstract    Prints a success message after the code is correctly read.
 */
void print_accepted() {
    printf("\nFile accepted.\n");
}

/**
 * @function    verify_arguments
 * @abstract    Checks the argument count and returns if it were satisfactory.
 * @param       argc    Argument Count.
 * @return      True if enough arguments were inserted.
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

/** 
 * @function    verify_file
 * @abstract    Tries to open a file and returns if it was correctly opened.
 * @param       file    File pointer to verify.
 * @return      True if the file was opened correctly.
 */
bool verify_file(FILE * file, char * arge) {
    if (file == NULL) {
        fprintf(stderr, "\nFailed to open file '%s'.\n\n", arge);
        return false;
    } else return true;
}

/**
 * @function    main
 * @abstract    Executes the program.
 * @param       argc    Argument count.
 * @param       argv    Argument values.
 * @return      Zero if the system finished successfully.
 */
int main(int argc, char * argv[]) {
    // Argument and file verification
    if (!verify_arguments(argc, argv)) return 1;
    yyin = fopen(argv[1], "r");
    if (!verify_file(yyin, argv[1])) return 1;

    // Execution of the program.
    hash_table_initialize();
    yyparse();

    // Exiting the program.
    fclose(yyin);
    fprintf(stdout, "\n");
    return 0;
}