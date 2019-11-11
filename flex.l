%{
// Imports
#include <stdio.h>
#include <stdlib.h>
#include "bison.tab.h"
#define INTEGER_TYPE  0
#define FLOATING_TYPE 1

// Declarations
void left_value_type(int type);
void left_value_string();
void log_name_initialization(char * text);
%}

ALPHA   [a-zA-Z]
DIGIT   [0-9]
MINUS   [~]

%%
"begin"     { return BEGINS; }
"end"       { return ENDS; }
"if"        { return IF; }
"ifelse"    { return IFELSE; }
"while"     { return WHILE; }
"read"      { return READ; }
"print"     { return PRINT; }

"int"       { return INT; }
"float"     { return FLOAT; }
"var"       { return VAR; }

":"         { return COLON; }
";"         { return SEMICOLON; }
"("         { return LEFT_PARENTHESIS; }
")"         { return RIGHT_PARENTHESIS; }
"+"         { return PLUS; };
"-"         { return MINUS; };
"*"         { return ASTERISK; };
"/"         { return SLASH; }
"<"         { return LESS_THAN; }
">"         { return GREATER_THAN; }
"="         { return EQUALS; }
"<="        { return LESS_THAN_EQUALS; }
">="        { return GREATER_THAN_EQUALS; }
"<-"        { return ASSIGNMENT; }
\n          { yylineno ++; }

{MINUS}?{DIGIT}+ {
    left_value_type(INTEGER_TYPE);
    return INTEGER_VALUE;
}
{MINUS}?{DIGIT}*.{DIGIT}+ {
    left_value_type(FLOATING_TYPE);
    return FLOATING_VALUE;
}
{ALPHA}({ALPHA}|{DIGIT})* {
    left_value_string();
    return IDENTIFIER;
}
%%
/**
 * @function    left_value_type
 * @abstract    Assigns flex's left value the type of number read.
 * @param       type    The type of value, Integer or Float.
 */
void left_value_type(int type) {
    yylval.type = type;
}

/**
 * @function    left_value_string
 * @abstract    Assigns flex's left value the text read.
 */
void left_value_string() {
    char * text = (char *)calloc(yyleng, sizeof(char));
    strcpy(text, yytext);
    log_name_initialization(text);

    yylval.name = text;
}

/**
 * @function    log_name_initialization
 * @abstract    Logs the creation of the text value.
 */
void log_name_initialization(char * text) {
    fprintf(stdout, "A variable has been created: '%s' at position %p\n",
        text, &text);
}