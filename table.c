// Imports
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Definitions
#define TABLE_SIZE 30
#define TYPE_INTEGER 0
#define TYPE_FLOAT 1

// Declarations
typedef struct hash_item hash_item;
typedef struct hash_table hash_table;
struct hash_table * table;
struct hash_item * hash_table_items_initialize();
int hash_key(char *);
int hash_index(int);
void hash_table_initialize();
bool hash_table_is_full();
void hash_table_print();
void hash_table_insert(char *, int);
bool hash_table_search(char *);
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
}

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
 * @var         symbols
 * @abstract    Hash table declaration. Holds this table.
 */
struct hash_table symbols;

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

int hash_key(char *);
int hash_index(int);
void hash_table_initialize();
bool hash_table_is_full();
void hash_table_print();
void hash_table_insert(char *, int);
bool hash_table_search(char *);
bool hash_table_match(char *, int);
void hash_table_terminate();