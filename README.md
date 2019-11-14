# Assignment Five - Jesús Antonio González Quevedo
## Instructions
The purpose of this assignment is to build a parser for the grammar given below using flex and bison. With the parser you must also implement a symbol table. This symbol table will only contain information about variables, but later on function names will be added to the language.

Identifiers, ( **id** ), and numbers, ( **numint** and **numfloat** ), have to be recognized via flex using a standard definition, including negative numbers.

Input to the parser is a text file, whose name has to be given to the parser as part of the command line in the console. The output should be a print out of the symbol table in case of a correct program, or an error message, containing the line number where the error is locatad, if a syntax error is encountered by the parser. In this particular case, if a variable name is used and has not been declared previously in the program, or if a variable name is declared more than once, an error has to be reported.

## Grammar
The following is the grammar provided by the professor, which is implemented in this, and further assignments.
```c
prog
    : opt_decls WRD_BEGINS opt_stmts WRD_ENDS

opt_decls
    : decls
    | %empty

decls
    : dec OPT_SEMICOLON decls
    | dec

dec
    : WRD_VAR VAL_IDENTIFIER OPT_COLON tipo

tipo
    : WRD_INT
    | WRD_FLOAT

opt_stmts
    : stmt_lst
    | %empty

stmt_lst
    : stmt OPT_SEMICOLON stmt_lst
    | stmt

stmt
    : VAL_IDENTIFIER OPT_ASSIGNMENT expr
    | WRD_IF OPT_OPEN expression OPT_CLOSE stmt
    | WRD_IFELSE OPT_OPEN expression OPT_CLOSE stmt stmt
    | WRD_WHILE OPT_OPEN expression OPT_CLOSE stmt
    | WRD_READ VAL_IDENTIFIER
    | WRD_PRINT expr
    | BEGINS opt_stmts ENDS

expression
    : expr
    | expr relop expr

expr
    : expr OPT_PLUS term
    | expr OPT_MINUS term
    | signo term
    | term

term
    : term OPT_ASTERISK factor
    | term OPT_SLASH factor
    | factor

factor
    : OPT_OPEN expr OPT_CLOSE
    | VAL_IDENTIFIER
    | VAL_INTEGER
    | VAL_FLOAT

relop
    : LESS
    | GREATER
    | EQUALS
    | LTE
    | GTE

signo
    : OPT_NEGATIVE
```

## Terminal types
The parser needs to know which value is being handled at a time, so it manages a union provided by Bison that handles the following types of values. It's useful to note that unions manage the same position in memory, so any given terminal can be of only one type.

```c
%union {
    int reserved;               // The integer code of the terminal.
    double numeric_value;       // The numeric value of the terminal.
    char * string_value         // The string value of the terminal.
}
```

Terminals take a left value of one of these two types, and return them when called using Bison's $X handler. 

```c
// Reserved Words
// Returns their integer code using the reserved left value.
token<reserved>
    WRD_BEGINS WRD_ENDS
    WRD_IF WRD_IFELSE WRD_WHILE WRD_READ WRD_PRINT
    WRD_INT WRD_FLOAT WRD_VAR

// Reserved Operators
// Returns their integer code using the reserved left value.
token<reserved>
    OPT_COLON OPT_SEMICOLON OPT_OPEN OPT_CLOSE
    OPT_PLUS OPT_MINUS OPT_ASTERISK OPT_SLASH
    OPT_LESS OPT_GREATER OPT_EQUALS OPT_LTE OPT_GTE
    OPT_ASSIGNMENT OPT_NEGATIVE

// Values
// Returns their value using the numeric_value left value.
token<value_integer> VAL_INTEGER
token<value_float> VAL_FLOAT
// Returns their value using the string_value left value.
token<value_identifier> VAL_IDENTIFIER
```

## Non terminal types
Unlike all terminals, some non-terminals do not have to handle being called, such as the case of the first non-terminal, prog. The terminals which do not have a pre-defined type (and are defaulted to int) are the following.

```c
type<int>
    prog
    opt_decls decls dec
    opt_stmts stmt_lst stmt
    signo
```

However, some non-terminals are called when being assigned to a terminal value held inside a non-terminal called previously, such as the non-terminal tipo, which is used to give a type to the identifier in dec. The non terminals used are the following.

```c
// Non-terminal tipo determines the type of variable that the hash table will
// store, returning a #defined value.
type<int> tipo

// Non-terminal expression returns true or false when using the WRD_IF,
// WRD_IFELSE or WRD_WHILE terminals.
type<bool> expression

// Non-terminal expr does an operation of sum or subtraction, and can also make the value negative. It is handled as a double, for the reason state in factor.
type<string> expr

// Non-terminal term does an operation of multiplcation or division with the factor and the preceding term. It is handled as a double, for the reason stated in factor.
type<double> term

// Non-terminal factor gets the value of either reading an integer/float, or by calling the value from the hash table. It is handled as a double, since it can handle both floats and integers.
type<double> factor

// Non-terminal relop determines the type of operation that the non-terminal expression will use, returning a #defined value.
type<int> relop
```

## Hash Table
This program will use a simple hash table, implementing Java's hashCode function, as shown in this link: https://docs.oracle.com/javase/7/docs/api/java/lang/String.html#hashCode%28%29. The structures of the hash table are the following.

Each node in the hash table is a structure called hash item. The hash item is responsible for storing the key generated via the hash_key method, as well as the properties of the identifier, such as its type, its current value, and its identifier.
```c
typedef struct hash_item {
    int key;
    int type;
    double value;
    char * identifier;
} hash_item;
```

The hash table itself is a simple structure that holds its current size and the array of hash items present in it at a given time.
```c
typedef struct hash_table {
    int size;
    struct hash_item * items;
} hash_table;
```