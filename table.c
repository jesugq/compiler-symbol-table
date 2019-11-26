// Imports
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Definitions
#define TABLE_SIZE 20
#define TYPE_INTEGER 1
#define TYPE_FLOAT 2

// Declarations
typedef struct hash_item hash_item;
typedef struct hash_table hash_table;
struct hash_table * table;
struct hash_item * hash_items_initialize();
int hash_key(char *);
int hash_index(int);
void hash_table_initialize();
bool hash_table_full();
void hash_table_print();
bool hash_table_insert(char *, int);
bool hash_table_assign(char *, double);
int hash_table_search(char *);
double hash_table_value(char *);
bool hash_table_match(char *, int);
void hash_table_terminate();

/**
 * @typedef     hash_item
 * @abstract    Hash item definition.
 * @field       
 */
typedef struct hash_item {
    int key;
    int type;
    double value;
    char * identifier;
} hash_item;

/**
 * @typedef     hash_table
 * @abstract    Hash table definiton.
 * @field       size    Current occupancy of the hash table.
 * @field       items   Hash items array in the table.
 */
typedef struct hash_table {
    int size;
    struct hash_item * items;
} hash_table;

/**
 * @var         table
 * @abstract    Hash table declaration. Holds this table.
 */
struct hash_table * table;

/**
 * @function    hash_items_initialize
 * @abstract    Initializes an array of hash items for the table.
 * @return      Pointer to the array of hash items.
 */
struct hash_item * hash_items_initialize() {
    struct hash_item * items = (struct hash_item *)calloc(
        TABLE_SIZE, sizeof(struct hash_item));
    return items;
}

/**
 * @function    hash_key
 * @abstract    Using the identifier's name, generates a hash key.
 * @discussion  The algorithm is the same one provided by Java's hashCode().
 * @param       identifier  The name of the identifier.
 * @return      An integer with the identifier's hash code.
 */
int hash_key(char * identifier) {
    int i, key;
    int length = strlen(identifier);
    double constant = 31;
    double chars_left = (double)length;

    for (i=key=0; i<length; i++) {
        chars_left --;
        key += identifier[i] * (int)(floor(pow(constant, chars_left)));
    }
    return key;
}

/**
 * @function    hash_index
 * @abstract    Using the identifier's hash key, generate an index in the table.
 * @param       key     Hash code generated using the identifier's name.
 * @return      An integer with the identifier's hash index.
 */
int hash_index(int key) {
    return abs(key % TABLE_SIZE);
}

/**
 * @function    hash_table_initialize
 * @abstract    Initializes the hash_table and its fields.
 */
void hash_table_initialize() {
    table = (struct hash_table *)calloc(1, sizeof(struct hash_table));
    table->size = 0;
    table->items = hash_items_initialize();
}

/**
 * @function    hash_table_full
 * @abstract    Simple function returning the occupancy of the table.
 * @return      Whether the hash table has exhausted its storage.
 */
bool hash_table_full() {
    return table->size == TABLE_SIZE;
}

/**
 * @function    hash_table_print
 * @abstract    Prints the contents of the table.
 */
void hash_table_print() {
    int i;
    char integer_item[] = "int";
    char float_item[] = "float";
    char none_item[] = "none";
    
    fprintf(stdout, "\n");
    for (i=0; i<TABLE_SIZE; i++) {
        fprintf(stdout, "table[%2d] = {%d, %s, %s, %1.2f}\n",
        i, table->items[i].key,
        table->items[i].type == TYPE_INTEGER ? integer_item :
            (table->items[i].type == TYPE_FLOAT ? float_item : none_item),
        table->items[i].identifier, table->items[i].value
        );
    }
}

/**
 * @function    hash_table_insert
 * @abstract    Inserts a struct hash item into the table.
 * @discussion  Implements a linear probing system.
 * @param       identifier  Name of the identifier.
 * @param       type        Type of the identifier.
 * @return      True if insertion was successful.
 */
bool hash_table_insert(char * identifier, int type) {
    if (hash_table_full()) return false;

    int key = hash_key(identifier);
    int index = hash_index(key);

    while (table->items[index].key != 0) {
        index ++;
        if (index >= TABLE_SIZE) index = 0;
    }
    struct hash_item item = {key, type, 0, identifier};
    table->items[index] = item;
    table->size ++;
    return true;
}

/**
 * @function    hash_table_assign
 * @abstract    Inserts a struct hash item into the table.
 * @discussion  Implements a linear probing system.
 * @param       identifier  Name of the identifier.
 * @param       value       Numeric value of the identifier.
 * @return      True if assignment was successful.
 */
bool hash_table_assign(char * identifier, double value) {
    int index = hash_table_search(identifier);
    if (!(index >= 0)) return false;

    table->items[index].value = value;
    return true;
}


/**
 * @function    hash_table_search
 * @abstract    Looks for a hash item inside of the table. Returns if found.
 * @discussion  Implements a linear probing searching system.
 * @param       identifier  Name of the identifier.
 * @return      An index higher or equal to zero if found. -1 if not.
 */
int hash_table_search(char * identifier) {
    int key = hash_key(identifier);
    int index = hash_index(key);
    int looped = index;

    while (table->items[index].key != 0) {
        if (table->items[index].key == key) return index;
        index ++;
        if (index >= TABLE_SIZE) index = 0;
        if (index == looped) break;
    } return -1;
}

/**
 * @function    hash_table_value
 * @abstract    Returns the value found in the hash item. Zero if not found.
 * @param       identifier  Name of the identifier.
 * @return      Numeric value of the identifier if found, zero otherwise.
 */
double hash_table_value(char * identifier) {
    int index = hash_table_search(identifier);
    if (!(index >= 0)) return 0;

    return table->items[index].value;
}

/**
 * @function    hash_table_match
 * @abstract    Checks the type of the identifier. Returns if it was the same.
 * @param       identifier  Name of the identifier.
 * @param       type        Type of the identifier.
 */
bool hash_table_match(char * identifier, int type) {
    int index = hash_table_search(identifier);
    if (!(index >= 0)) return false;

    return table->items[index].type == type;
}

/**
 * @function    hash_table_terminate
 * @abstract    Frees the memory for all items, then the table itself.
 */
void hash_table_terminate() {
    int index;
    for (index=0; index<TABLE_SIZE; index ++) {
        if (table->items[index].identifier != NULL)
            free(table->items[index].identifier);
    }
    free(table->items);
    free(table);
}