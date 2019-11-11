# Assignment Five - Jesús Antonio González Quevedo - A00399890

### Instructions
The purpose of this assignment is to build a parser for the grammar given below using flex and bison. With the parser you must also implement a symbol table. This symbol table will only contain information about variables, but later on function names will be added to the language.

Identifiers, ( **id** ), and numbers, ( **numint** and **numfloat** ), have to be recognized via flex using a standard definition, including negative numbers.

Input to the parser is a text file, whose name has to be given to the parser as part of the command line in the console. The output should be a print out of the symbol table in case of a correct program, or an error message, containing the line number where the error is locatad, if a syntax error is encountered by the parser. In this particular case, if a variable name is used and has not been declared previously in the program, or if a variable name is declared more than once, an error has to be reported.

### Legend
```c
// Tokens for reserved words.
%token BEGINS ENDS IF ELSE IFELSE WHILE READ PRINT

// Tokens for value assignment.
%token INT FLOAT VAR

// Tokens for reserved symbols.
%token COLON SEMICOLON LEFT_PARENTHESIS RIGHT_PARENTHESIS PLUS MINUS ASTERISK SLASH LESS_THAN GREATER_THAN EQUALS LESS_THAN_EQUALS GREATER_THAN_EQUALS ASSIGNMENT

// Enums for the type of an identifier.
enum type { INTEGER_TYPE, FLOATING_TYPE }
```

### Grammar
```
prog        : opt_decls BEGINS opt_stmts ENDS

opt_decls   : decls
            | %empty

decls       : dec SEMICOLON decls
            | dec

dec         : VAR IDENTIFIER COLON tipo

tipo        : INT
            | FLOAT

stmt        : IDENTIFIER ASSIGNMENT expr
            | IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS stmt
            | IFELSE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS stmt stmt
            | WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS stmt
            | READ IDENTIFIER
            | PRINT expr
            | BEGINS opt_stmts ENDS

opt_stmts   : stmt_lst
            | %empty

stmt_lst    : stmt SEMICOLON stmt_lst
            | stmt

expr        : expr PLUS term
            | expr MINUS term
            | term

term        : term ASTERISK factor
            | term SLASH factor
            | factor

factor      : LEFT_PARENTHESIS expr RIGHT_PARENTHESIS
            | IDENTIFIER
            | INTEGER_VALUE
            | FLOATING_VALUE

expression  : expr LESS_THAN expr
            | expr GREATER_THAN expr
            | expr EQUALS expr
            | expr LESS_THAN_EQUALS expr
            | expr GREATER_THAN_EQUALS expr
```

### Compilation
```bash
lex flex.l && bison -d bison.y
gcc lex.yy.c bison.tab.c -lfl -o run.out
./run.out
```

### Notes
Tipo de Nodo: {
    Variable
    Constante
    Instrucción
    Operador
}

Apuntadores a Nodo

Apuntador a Tabla de Símbolos
    En caso de ser una variable.

Valor si es una constante.

Un código si es instrucción.

Un código si es operador.