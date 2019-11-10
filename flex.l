%{
#include <stdlib.h>
#include "bison.tab.h"

int lines = 1;

void left_value_integer();
void left_value_floating();
void left_value_string();
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
"\n"        { lines ++; }


{MINUS}?{DIGIT}+ {
    left_value_integer();
    return INTEGER_TYPE;
}
{MINUS}?{DIGIT}*.{DIGIT}+ {
    left_value_floating();
    return FLOATING_TYPE;
}
{ALPHA}({ALPHA}|{DIGIT})* {
    left_value_string();
    return IDENTIFIER;
}
%%

/*
 * Assigns flex's left value the integer read.
 */
void left_value_integer() {
    yylval.integer_value = atoi(yytext);
}

/*
 * Assigns flex's left value the floating point read.
 */
void left_value_floating() {
    yylval.floating_value = atof(yytext);
}

/*
 * Assigns flex's left value the text read.
 */
void left_value_string() {
    char * text = (char *)calloc(strlen(yytext+1), sizeof(char));
    strcpy(text, yytext);

    yylval.string_value = text;
}