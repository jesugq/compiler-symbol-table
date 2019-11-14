%{
// Imports
#include <stdio.h>
#include <stdbool.h>
#include "table.c"

#define TYPE_INTEGER 1
#define TYPE_FLOAT 2
#define TYPE_LESS_THAN 3
#define TYPE_GREATER_THAN 4
#define TYPE_EQUALS 5
#define TYPE_LESS_THAN_EQUALS 6
#define TYPE_GREATER_THAN_EQUALS 7

// Flex externals
extern FILE * yyin;
extern int yylineno;
extern char * yytext;
extern int yylex();
extern int yyerror(char const *);

// Declarations
bool verify_arguments(int, char * []);
bool verify_files(FILE *, char *);
bool evaluate_to_zero(double);
bool evaluate_with_operator(double, double, int);
bool evaluate_identifier_exists(char *);
void execute_print_expression(double);
void execute_identifier_insert(char *, int);
void execute_identifier_assign(char *, double);
double get_identifier_value(char *);
void success_parse();
void error_identifier_repeated(char *);
void error_identifier_missing(char *);
%}

%union {
    int reserved;
    int type;
    int boolean;
    double numeric;
    char * string;
}

%token<reserved> WRD_BEGINS WRD_ENDS WRD_IF WRD_ELSE WRD_IFELSE WRD_WHILE WRD_READ WRD_PRINT WRD_INT WRD_FLOAT WRD_VAR
%token<reserved> OPT_COLON OPT_SEMICOLON OPT_OPENS OPT_CLOSES OPT_PLUS OPT_MINUS OPT_ASTERISK OPT_SLASH OPT_LESS OPT_GREATER OPT_EQUALS OPT_LTE OPT_GTE OPT_ASSIGN OPT_NEGATIVE
%token <numeric> VAL_INTEGER VAL_FLOAT
%token <string> VAL_IDENTIFIER

%type<type> tipo relop
%type<boolean> expression
%type<numeric> expr term factor

%start prog

%%
prog
    : opt_decls WRD_BEGINS opt_stmts WRD_ENDS {
        success_parse();
    }
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
    : WRD_VAR VAL_IDENTIFIER OPT_COLON tipo {
        if (!evaluate_identifier_exists($2))
            execute_identifier_insert($2, $4);
        else {
            error_identifier_repeated($2); YYERROR;
        }
    }
;
tipo
    : WRD_INT {
        yylval.type = TYPE_INTEGER;
    }
    | WRD_FLOAT {
        yylval.type = TYPE_FLOAT;
    }
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
    : VAL_IDENTIFIER OPT_ASSIGN expr {
        if (evaluate_identifier_exists($1))
            execute_identifier_assign($1, $3);
        else {
            error_identifier_missing($1); YYERROR;
        }
    }
    | WRD_IF OPT_OPENS expression OPT_CLOSES stmt {
        // $5 should not execute if expression is false.
        // Not yet implemented.
    }
    | WRD_IFELSE OPT_OPENS expression OPT_CLOSES stmt stmt {
        // $5 should execute on expression true, and $6 on false.
        // Not yet implemented.
    }
    | WRD_WHILE OPT_OPENS expression OPT_CLOSES stmt {
        // $5 should execute until expression is false.
        // Not yet implemented.
    }
    | WRD_READ VAL_IDENTIFIER {
        // I'm not sure what this should do.
    }
    | WRD_PRINT expr {
        execute_print_expression($2);
    }
    | WRD_BEGINS opt_stmts WRD_ENDS
;
expression
    : expr {
        yylval.boolean = evaluate_to_zero($1);
    }
    | expr relop expr {
        yylval.boolean = evaluate_with_operator($1, $3, $2);
    }
;
expr
    : expr OPT_PLUS term {
        yylval.numeric = $1 + $2;
    }
    | expr OPT_MINUS term {
        yylval.numeric = $1 - $2;
    }
    | signo term {
        yylval.numeric = $2 * -1;
    }
    | term
;
term
    : term OPT_ASTERISK factor {
        yylval.numeric = $1 * $2;
    }
    | term OPT_SLASH factor {
        yylval.numeric = $1 / $2;
    }
    | factor
;
factor
    : OPT_OPENS expr OPT_CLOSES {
        yylval.numeric = $2;
    }
    | VAL_IDENTIFIER {
        if (evaluate_identifier_exists($1))
            yylval.numeric = get_identifier_value($1);
        else {
            error_identifier_missing($1); YYERROR;
        }
    }
    | VAL_INTEGER
    | VAL_FLOAT
;
relop
    : OPT_LESS      { yylval.type = TYPE_LESS_THAN; }
    | OPT_GREATER   { yylval.type = TYPE_GREATER_THAN; }
    | OPT_EQUALS    { yylval.type = TYPE_EQUALS; }
    | OPT_LTE       { yylval.type = TYPE_LESS_THAN_EQUALS; }
    | OPT_GTE       { yylval.type = TYPE_GREATER_THAN_EQUALS; }
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
    fprintf(stderr, "\n%s found after reading '%s' at line %d.\n",
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
    } else if (argc > 2) {
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
 * @function    evaluate_to_zero
 * @abstract    Evaluates the double to see if it zero (True in this parser).
 * @param       num     Double value to evaluate.
 * @return      True if it is zero.
 */
bool evaluate_to_zero(double num) {
    return num == 0 ? true:false;
}

/**
 * @function    evaluate_with_operator
 * @abstract    Evaluates two doubles using an operator, such as <, >, =, etc.
 * @param       one         First double value to evaluate.
 * @param       two         Second double value to evaluate.
 * @param       operator    Operator used for switch case handling.
 * @return      The expression's result, false if using an invalid operator.
 */
bool evaluate_with_operator(double one, double two, int operator) {
    switch (operator) {
        case TYPE_LESS_THAN:            return one < two;
        case TYPE_GREATER_THAN:         return one > two;
        case TYPE_EQUALS:               return one == two;
        case TYPE_LESS_THAN_EQUALS:     return one <= two;
        case TYPE_GREATER_THAN_EQUALS:  return one >= two;
        default:                        return false;
    }
}

/**
 * @function    evaluate_identifier_exists
 * @abstract    Evaluates if the identifier exists in the symbol table.
 * @param       identifier  Name of the identifier.
 * @return      True if the identifier exists in the symbol table.
 */
bool evaluate_identifier_exists(char * identifier) {
    return hash_table_search(identifier) >= 0;
}

/**
 * @function    execute_print_expression
 * @abstract    Prints the value of an expression.
 * @param       num     Double expression to print.
 */
void execute_print_expression(double num) {
    fprintf(stdout, "\nValue is: %f\n", num);
}

/**
 * @function    execute_identifier_insert
 * @abstract    Calls the hash table to insert a hash item.
 * @param       identifier  Name of the identifier.
 * @param       type        Type of the identifier.
 */
void execute_identifier_insert(char * identifier, int type) {
    switch (type) {
        case WRD_INT: type = TYPE_INTEGER; break;
        case WRD_FLOAT: type = TYPE_FLOAT; break;
        default: type = 0; break;
    }
    hash_table_insert(identifier, type);
}

/**
 * @function    execute_identifier_assign
 * @abstract    Calls the hash table to assign a value to a hash item.
 * @param       identifier  Name of the identifier.
 * @param       value       Numeric value of the identifier.
 */
void execute_identifier_assign(char * identifier, double value) {
    printf("\nAssignment was: %f\n", value);
    hash_table_assign(identifier, value);
}

/**
 * @function    get_identifier_value
 * @abstract    Calls the hash table to return the hash item's value.
 * @param       identifier  Name of the identifier.
 * @return      Numeric value of the identifier.
 */
double get_identifier_value(char * identifier) {
    return hash_table_value(identifier);
}

/**
 * @function    success_parse
 * @abstract    Prints a success message.
 */
void success_parse() {
    fprintf(stdout, "\nFile accepted.\n");
}

/**
 * @function    error_identifier_repeated
 * @abstract    Calls yerror with reason: Identifier was already declared.
 * @param       identifier  Name of the identifier.
 */
void error_identifier_repeated(char * identifier) {
    char error[1000] = "variable already declared: ";
    strcat(error, identifier);
    yyerror(error);
}

/**
 * @function    error_identifier_missing
 * @abstract    Calls yyerror with reason: Identifier was not declared before.
 * @param       identifier  Name of the identifier.
 */
void error_identifier_missing(char * identifier) {
    char error[1000] = "variable not declared before: ";
    strcat(error, identifier);
    yyerror(error);
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

    // Execution of the parser and symbol table.
    hash_table_initialize();
    yyparse();
    hash_table_print();
    hash_table_terminate();

    // Exiting and closing the file.
    fclose(yyin);
    fprintf(stdout, "\n");
    return 0;
}