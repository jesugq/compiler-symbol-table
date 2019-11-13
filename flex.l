%{
// Imports
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bison.tab.h"

// Declarations
int global = 0;
void left_value_reserved();
void left_value_type();
void left_value_operator();
void left_value_integer();
void left_value_floating();
void left_value_identifier();

%}

ALPHA   [a-zA-Z]
DIGIT   [0-9]

%%
"begin"     { left_value_reserved(BEGINS);      return BEGINS; }
"end"       { left_value_reserved(ENDS);        return ENDS; }
"if"        { left_value_reserved(IF);          return IF; }
"ifelse"    { left_value_reserved(IFELSE);      return IFELSE; }
"while"     { left_value_reserved(WHILE);       return WHILE; }
"read"      { left_value_reserved(READ);        return READ; }
"print"     { left_value_reserved(PRINT);       return PRINT; }

"int"       { left_value_type(INT);     return INT; }
"float"     { left_value_type(FLOAT);   return FLOAT; }
"var"       { left_value_type(VAR);     return VAR; }

":"         { left_value_operator(COLON);
              return COLON; }
";"         { left_value_operator(SEMICOLON);
              return SEMICOLON; }
"("         { left_value_operator(LEFT_PARENTHESIS);
              return LEFT_PARENTHESIS; }
")"         { left_value_operator(RIGHT_PARENTHESIS);
              return RIGHT_PARENTHESIS; }
"+"         { left_value_operator(PLUS);
              return PLUS; }
"-"         { left_value_operator(MINUS);
              return MINUS; }
"*"         { left_value_operator(ASTERISK);
              return ASTERISK; }
"/"         { left_value_operator(SLASH);
              return SLASH; }
"<"         { left_value_operator(LESS_THAN);
              return LESS_THAN; }
">"         { left_value_operator(GREATER_THAN);
              return GREATER_THAN; }
"="         { left_value_operator(EQUALS);
              return EQUALS; }
"<="        { left_value_operator(LESS_THAN_EQUALS);
              return LESS_THAN_EQUALS; }
">="        { left_value_operator(GREATER_THAN_EQUALS);
              return GREATER_THAN_EQUALS; }
"<-"        { left_value_operator(ASSIGNMENT);
              return ASSIGNMENT; }
"~"         { left_value_operator(NEGATIVE);
              return NEGATIVE; }

"\n"        { yylineno ++; }

{DIGIT}+ {
    left_value_integer();
    return INTEGER_VALUE;
}
{DIGIT}*.{DIGIT}+ {
    left_value_floating();
    return FLOATING_VALUE;
}
{ALPHA}({ALPHA}|{DIGIT})* {
    left_value_identifier();
    return IDENTIFIER;
}
%%
/**
 * @function    left_value_reserved
 * @abstract    Assigns flex's left value the reserved word read.
 * @param       reserved    Reserved word code.
 */
void left_value_reserved(int reserved) {
    yylval.reserved = reserved;
}

/**
 * @function    left_value_type
 * @abstract    Assign's flex's left value the value type read.
 * @param       type    Value type code.
 */
void left_value_type(int type) {
    yylval.type = type;
}

/**
 * @function    left_value_operator
 * @abstract    Assigns flex's left value the operator read.
 * @param       operator    Operator code.
 */
void left_value_operator(int operator) {
    yylval.operator = operator;
}

/**
 * @function    left_value_integer
 * @abstract    Assigns flex's left value the integer read.
 * @param       integer     Integer value.
 */
void left_value_integer() {
    int integer = atoi(yytext);
    yylval.integer = integer;
}

/**
 * @function    left_value_floating
 * @abstract    Assigns flex's left value the floating point read.
 * @param       floating    Floating point value.
 */
void left_value_floating() {
    float floating = atof(yytext);
    yylval.floating = floating;
}

/**
 * @function    left_value_identifier
 * @abstract    Allocates and assigns flex's left value the identifier read.
 */
void left_value_identifier() {
    char * identifier = strdup(yytext);
    yylval.identifier = identifier;
}