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
"("         { return LEFT_PARENTHESES; }
")"         { return RIGHT_PARENTHESES; }
"+"         { return PLUS; };
"-"         { return MINUS; };
"*"         { return ASTERISK; };
"/"         { return SLASH; }
"<"         { return LESS_THAN; }
">"         { return GREATER_THAN; }
"="         { return EQUALS; }
"<="        { return LESS_THAN_EQUALS; }
">="        { return GREATER_THAN_EQUALS; }


{MINUS}?{DIGIT}+ {
    flex_assign_left_value();
    return INTEGER_TYPE;
}
{MINUS}?{DIGIT}*.{DIGIT}+ {
    flex_assign_left_value();
    return FLOATING_TYPE;
}
{ALPHA}({ALPHA}|{DIGIT})* {
    flex_assign_left_value();
    return IDENTIFIER;
}

%%

#include "lexicon.h"