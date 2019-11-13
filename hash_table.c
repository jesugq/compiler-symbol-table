// Imports
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Definitions
#define TABLE_SIZE 20

// Declarations
typedef struct hash_item hash_item;
typedef struct hash_table hash_table;
struct hash_table table;
struct hash_item * hash_table_items_initialize();
int hash_code(char * identifier);
int hash_index(int code);
void hash_table_initialize();
bool hash_table_is_full();
void hash_table_print();
void hash_table_insert(char * identifier);
void hash_table_terminate();

/**
 * @typedef     hash_item_t
 * @abstract    Hash Table Item Definition.
 * @field       code    Code for the identifier used in searching
 * @field       type    Type of the identifier used in type checking.
 * @field       identifier    identifier of the identifier used in printing.
 */
typedef struct hash_item {
    int code;
    char * identifier;
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
    return items;
}

/**
 * @function    hash_code
 * @abstract    Using the identifier's identifier, generate a hash code.
 * @discussion  The algorithm is the same one provided by Java's hashCode().
 *              https://docs.oracle.com/javase/7/docs/api/java/lang/String.html#hashCode%28%29
 * @param       identifier    The identifier's identifier.
 * @return      An integer with the identifier's unique hash code.
 */
int hash_code(char * identifier) {
    int i, code = 0;
    int length = strlen(identifier);
    double constant = 31;
    double chars_left = (double)length;

    for (i=0; i<length; i++) {
        chars_left --;
        code += identifier[i] * (int)(floor(pow(constant, chars_left)));
    }
    return code;
}

/**
 * @function    hash_key
 * @abstract    Using the identifier's hash code, generate a hash key.
 * @param       code    Hash code generated using the identifier's identifier.
 * @return      An integer with the identifier's unique hash key.
 */
int hash_index(int code) {
    return abs(code % TABLE_SIZE);
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
 * @function    hash_table_print
 * @abstract    Prints the contents of the table.
 */
void hash_table_print() {
    int i;
    fprintf(stdout, "\n");
    for (i=0; i<TABLE_SIZE; i++) {
        fprintf(stdout, "table[%2d] = {%d, %s}\n",
            i, table.items[i].code, table.items[i].identifier);
    }
}

/**
 * @function    hash_table_insert
 * @abstract    Inserts a struct hash_item into the array.
 * @discussion  Insertion implements a linear probing system.
 * @param       identifier  Name of the identifier.
 */
void hash_table_insert(char * identifier) {
    if (hash_table_is_full()) return;

    int code = hash_code(identifier);
    int index = hash_index(code);

    while (table.items[index].code != 0) {
        index ++;
        if (index >= TABLE_SIZE) index = 0;
    }
    struct hash_item item = {code, identifier};
    
    table.size ++;
    table.items[index] = item;
}

/**
 * @function    hash_table_search
 * @abstract    Looks for a struct hash_item in the array, and returns if found.
 * @discussion  The algorithm will look at the index the identifier's code
 *              generates. If not there, it will use linear probing to search,
 *              that is, while there are adjacent items (code is not zero).
 *              Once it reaches an item of zero, it knows it's not present.
 * @param       identifier  Name of the identifier.
 * @return      True if found.
 */
bool hash_table_search(char * identifier) {
    int code = hash_code(identifier);
    int index = hash_index(code);
    int loop = index;

    while (table.items[index].code != 0) {
        if (table.items[index].code == code)
            return true;
        index ++;
        if (index >= TABLE_SIZE) index = 0;
        if (index == loop) break;
    }
    return false;
}

/**
 * @function    hash_table_terminate
 * @abstract    Frees the memory for all items' identifiers, then the table.
 */
void hash_table_terminate() {
    int index;
    for (index=0; index<TABLE_SIZE; index++) {
        if (table.items[index].identifier != NULL)
            free(table.items[index].identifier);
    }
    free(table.items);
}