%{
// Imports
#include <stdlib.h>
#include <string.h>
#include "bison.tab.h"

// Declarations
void left_value_reserved(int);
void left_value_numeric();
void left_value_string();
%}

ALPHA [a-zA-Z]
DIGIT [0-9]

%%
"begin"     { left_value_reserved(WRD_BEGINS); return WRD_BEGINS;}
"end"       { left_value_reserved(WRD_ENDS); return WRD_ENDS; }
"if"        { left_value_reserved(WRD_IF); return WRD_IF; }
"ifelse"    { left_value_reserved(WRD_IFELSE); return WRD_IFELSE; }
"while"     { left_value_reserved(WRD_WHILE); return WRD_WHILE; }
"read"      { left_value_reserved(WRD_READ); return WRD_READ; }
"print"     { left_value_reserved(WRD_PRINT); return WRD_PRINT; }
"int"       { left_value_reserved(WRD_INT); return WRD_INT; }
"float"     { left_value_reserved(WRD_FLOAT); return WRD_FLOAT; }
"var"       { left_value_reserved(WRD_VAR); return WRD_VAR; }

":"         { left_value_reserved(OPT_COLON); return OPT_COLON; }
";"         { left_value_reserved(OPT_SEMICOLON); return OPT_SEMICOLON; }
"("         { left_value_reserved(OPT_OPENS); return OPT_OPENS; }
")"         { left_value_reserved(OPT_CLOSES); return OPT_CLOSES; }
"+"         { left_value_reserved(OPT_PLUS); return OPT_PLUS; }
"-"         { left_value_reserved(OPT_MINUS); return OPT_MINUS; }
"*"         { left_value_reserved(OPT_ASTERISK); return OPT_ASTERISK; }
"/"         { left_value_reserved(OPT_SLASH); return OPT_SLASH; }
"<"         { left_value_reserved(OPT_LESS); return OPT_LESS; }
">"         { left_value_reserved(OPT_GREATER); return OPT_GREATER; }
"="         { left_value_reserved(OPT_EQUALS); return OPT_EQUALS; }
"<="        { left_value_reserved(OPT_LTE); return OPT_LTE; }
">="        { left_value_reserved(OPT_GTE); return OPT_GTE; }
"<-"        { left_value_reserved(OPT_ASSIGN); return OPT_ASSIGN; }
"~"         { left_value_reserved(OPT_NEGATIVE); return OPT_NEGATIVE; }

"\n"        { yylineno++; }

{DIGIT}+                    { left_value_numeric(); return VAL_INTEGER; }
{DIGIT}*"."{DIGIT}+         { left_value_numeric(); return VAL_FLOAT; }
{ALPHA}({ALPHA}|{DIGIT})*   { left_value_string(); return VAL_IDENTIFIER; }
%%

/**
 * @function    left_value_reserved
 * @abstract    Inserts the terminal's integer code into yylval.
 * @param       code    Code of the terminal.
 */
void left_value_reserved(int code) {
    yylval.reserved = code;
}

/**
 * @function    left_value_numeric
 * @abstract    Inserts the terminal's numeric value into yylval.
 */
void left_value_numeric() {
    yylval.numeric = atof(yytext);
}

/**
 * @function    left_value_string
 * @abstract    Inserts the terminal's string value into yylval.
 */
void left_value_string() {
    yylval.string = strdup(yytext);
}