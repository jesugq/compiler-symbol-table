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
bool assert_identifier_exists(char * identifier);
void execute_identifier_insert(char * identifier, int type);
void error_identifier_repeated(char * identifier);
void error_identifier_missing(char * identifier);
int main(int argc, char * argv[]);

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
%token<operator> NEGATIVE

%token<integer> INTEGER_VALUE
%token<floating> FLOATING_VALUE
%token<identifier> IDENTIFIER

%type<type> tipo

%start prog

%%
prog        : opt_decls BEGINS opt_stmts ENDS
;

opt_decls   : decls
            | %empty
;

decls       : dec SEMICOLON decls
            | dec
;

dec         : VAR IDENTIFIER COLON tipo {
                if (!assert_identifier_exists($2))
                    execute_identifier_insert($2, $4);
                else {
                    error_identifier_repeated($2);
                    YYERROR;
                }
            }
;

tipo        : INT
            | FLOAT
;

stmt        : IDENTIFIER ASSIGNMENT expr {
                if (assert_identifier_exists($1))
                    // free($1)
                    ;
                    // Should be freed but can be used later
                else {
                    error_identifier_missing($1);
                    YYERROR;
                }
            }
            | IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS stmt
            | IFELSE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS stmt stmt
            | WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS stmt
            | READ IDENTIFIER {
                if (assert_identifier_exists($2))
                    // free($2)+
                    ;
                    // Should be freed but can be used later
                else {
                    error_identifier_missing($2);
                    YYERROR;
                }
            }
            | PRINT expr
            | BEGINS opt_stmts ENDS
;

opt_stmts   : stmt_lst
            | %empty

stmt_lst    : stmt SEMICOLON stmt_lst
            | stmt
;

expression  : expr
            | expr relop expr

expr        : expr PLUS term
            | expr MINUS term
            | signo term
            | term
;

term        : term ASTERISK factor
            | term SLASH factor
            | factor
;

factor      : LEFT_PARENTHESIS expr RIGHT_PARENTHESIS
            | IDENTIFIER {
                if (assert_identifier_exists($1))
                    // free($1)
                    ;
                    // Should be freed but can be used later
                else {
                    error_identifier_missing($1);
                    YYERROR;
                }
            }
            | INTEGER_VALUE
            | FLOATING_VALUE
;

relop       : LESS_THAN
            | GREATER_THAN
            | EQUALS
            | LESS_THAN_EQUALS
            | GREATER_THAN_EQUALS

signo       : NEGATIVE
;
%%

/**
 * @function    yyerror
 * @abstract    Prints Flex's Error.
 * @param       text    Error message.
 * @return      Error code.
 */
int yyerror(char const * text) {
    fprintf(stderr, "\n%s found after reading '%s' at line %d.\n", text, yytext, yylineno);
    return 1;
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
 * @function    assert_identifier_exists
 * @abstract    Tries to look for an identifier in the hash table.
 * @param       identifier  Name of the identifier.
 * @return      True if the identifier exists in the table.
 */
bool assert_identifier_exists(char * identifier) {
    return hash_table_search(identifier);
}

/**
 * @function    execute_identifier_insert
 * @abstract    Inserts an identifier in the hash table.
 * @param       identifier  Name of the identifier.
 */
void execute_identifier_insert(char * identifier, int type) {
    if (type == INT) type = INTEGER_VALUE;
    else type = FLOATING_VALUE;
    hash_table_insert(identifier, type);
}

/**
 * @function    error_identifier_repeated
 * @abstract    Calls yyerror with reason: Identifier is declared twice.
 * @param       identifier  Name of the identifier.
 */
void error_identifier_repeated(char * identifier) {
    yyerror("variable declared twice");
}

/**
 * @function    error_identifier_missing
 * @abstract    Calls yyerror with reason: Identifier was not declared once.
 * @param       identifier  Name of the identifier.
 */
void error_identifier_missing(char * identifier) {
    yyerror("variable unknown");
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
    hash_table_initialize(INTEGER_VALUE, FLOATING_VALUE);
    if (yyparse() == 0)
        printf("\nFile Accepted.\n");
    hash_table_print();
    hash_table_terminate();

    // Exiting the program.
    fclose(yyin);
    fprintf(stdout, "\n");
    return 0;
}