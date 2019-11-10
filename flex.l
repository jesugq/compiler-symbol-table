%{
#include <stdlib.h>
#include "bison.tab.h"

enum type { INTEGER_TYPE, FLOATING_TYPE };

void left_value_type(int type);
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
"\n"        { yylineno ++; }


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

/*
 * Assigns flex's left value the type of number read.
 * @param   type    The type of value, Integer or Float.
 */
void left_value_type(int type) {
    yylval.type = type;
}

/*
 * Assigns flex's left value the text read.
 */
void left_value_string() {
    char * text = (char *)calloc(strlen(yytext+1), sizeof(char));
    strcpy(text, yytext);

    yylval.id = text;
}