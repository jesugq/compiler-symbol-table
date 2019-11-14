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
bool verify_arguments(int, char *);
int main(int, char *)
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

/**
 * @function    yyerror
 * @abstract    Overrides yyerror to print both the line and the error.
 * @param       error   Error message.
 * @return      Error code, only received by yylex.
 */
int yyerror(char const * error) {
    fprintf(stderr, "\n%s found after readin '%s' at line %d.\n",
        error, yytext, yylineno
    );
}

/**
 * @function    verify_arguments
 * @abstract    Checks the argument count, returns if a filename was provided.
 * @param       argc    Argument count.
 * @return      True if at least one argument was provided.
 */
bool verify_arguments(int argc, char * argv[]) {
    if (argc < 2) {
        fprintf(stderr, "\nNo file argument was provided.\n");
        return false;
    } else if (arg > 2) {
        fprintf(stdout, "\nToo many arguments used. using '%s'\n", argv[1]);
        return true;
    } else return true;
}

/**
 * @function    verify_file
 * @abstract    Verifies and returns if the file was correctly opened.
 * @param       file    File pointer to verify.
 * @param       arge    Argument element.
 * @return      True if the file was opened correctly.
 */
bool verify_file(FILE * file, char * arge) {
    if (file == NULL) {
        fprintf(stderr, "\nFailed to open file '%s',\n", arge);
        return false;
    } else return true;
}

/**
 * @function    main
 * @abstract    Runtime of this program. Executes yyparse and hash table init.
 * @param       argc    Argument count.
 * @param       argv    Argument values.
 * @return      Runtime code, zero for OK.
 */
int main(int argc, char * argv[]) {
    // Argument and file verification
    if (!verify_arguments(argc, argv)) return 1;
    yyin = fopen(argv[1], "r");
    if (!verify_file(yyin, argv[1])) return 1;
}