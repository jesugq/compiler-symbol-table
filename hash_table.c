// Imports
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Definitions
#define TABLE_SIZE 30

// Declarations
typedef struct hash_item hash_item;
typedef struct hash_table hash_table;
struct hash_table table;
struct hash_item * hash_table_items_initialize();
void log_hash_items_initialization(struct hash_item * items);
void hash_table_initialize();
bool hash_table_is_full();
int hash_code(char * name);
int hash_index(int code);
void hash_table_print();
void hash_table_insert(char * name, int type);

/**
 * @typedef     hash_item_t
 * @abstract    Hash Table Item Definition.
 * @field       code    Code for the identifier used in searching
 * @field       type    Type of the identifier used in type checking.
 * @field       name    Name of the identifier used in printing.
 */
typedef struct hash_item {
    int code;
    int type;
    char * name;
} hash_item;

/**
 * @struct      hash_table_t
 * @abstract    Hash Table Definition.
 * @field       size    Current occupancy of the hash table.
 * @field       items   Hash Table Items stored in the hash table.
 */
typedef struct hash_table {
    int size;
    struct hash_item * items;
} hash_table;

/**
 * @var         hash_table
 * @abstract    Hash Table Declaration. Used in this class.
 */
struct hash_table table;

/**
 * @function    hash_table_items_initialize
 * @abstract    Initializes the hash_table's items field.
 * @return      Pointer to the array of hash_items.
 */
struct hash_item * hash_table_items_initialize() {
    struct hash_item * items = (struct hash_item *)calloc(
        TABLE_SIZE, sizeof(struct hash_item));
    log_hash_items_initialization(items);
    return items;
}

/**
 * @function    log_hash_items_initialization
 * @abstract    Logs the creation of the hash_table's items array.
 */
void log_hash_items_initialization(struct hash_item * items) {
    fprintf(stdout, "A table has been created: %d elements at position %p\n",
        TABLE_SIZE, items);
}

/**
 * @function    hash_table_initialize
 * @abstract    Initializes the hash_table's fields.
 */
void hash_table_initialize() {
    table.size = 0;
    table.items = hash_table_items_initialize();
}

/**
 * @function    hash_table_is_full
 * @abstract    Simple function to return the state of the table.
 * @return      Whether the hash table has exhausted its storage.
 */
bool hash_table_is_full() {
    return table.size == TABLE_SIZE;
}

/**
 * @function    hash_code
 * @abstract    Using the identifier's name, generate a hash code.
 * @discussion  The algorithm is the same one provided by Java's hashCode().
 *              https://docs.oracle.com/javase/7/docs/api/java/lang/String.html#hashCode%28%29
 * @param       name    The identifier's name.
 * @return      An integer with the identifier's unique hash code.
 */
int hash_code(char * name) {
    int i, code = 0;
    int length = strlen(name);
    double constant = 31;
    double chars_left = (double)length;

    for (i=0; i<length; i++) {
        chars_left --;
        code += name[i] * (int)(floor(pow(constant, chars_left)));
    }
    /**/printf("Code now is: %d", code);/**/
    return code;
}

/**
 * @function    hash_key
 * @abstract    Using the identifier's hash code, generate a hash key.
 * @param       code    Hash code generated using the identifier's name.
 * @return      An integer with the identifier's unique hash key.
 */
int hash_index(int code) {
    return code % TABLE_SIZE;
}

/**
 * @function    hash_table_print
 * @abstract    Prints the contents of the table.
 */
void hash_table_print() {
    int i;
    for (i=0; i<TABLE_SIZE; i++) {
        fprintf(stdout, "table[%2d] = {%d, %d, %s}\n",
            i, table.items[i].code, table.items[i].type, table.items[i].name);
    }
}

/**
 * @function    hash_table_insert
 * @abstract    Inserts a struct hash_item into the array.
 * @discussion  Insertion implements a linear probing system.
 */
void hash_table_insert(char * name, int type) {
    if (hash_table_is_full()) return;

    int code = hash_code(name);
    int index = hash_index(code);

    while (table.items[index].code == 0) index ++;
    struct hash_item item = {code, type, name};
    
    table.size ++;
    table.items[index] = item;
}