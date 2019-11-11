// Imports
#include <stdio.h>
#include <stdlib.h>

// Definitions
#define TABLE_SIZE  100
#define TABLE_PRIME 97
#define INTEGER_TYPE  0
#define FLOATING_TYPE 1

// Declarations
typedef struct hash_item hash_item;
typedef struct hash_table hash_table;
struct hash_table symbols;
struct hash_item ** hash_table_items_initialize();
void log_hash_items_initialization(struct hash_item **);
void hash_table_initialize();

/**
 * @typedef     hash_item_t
 * @abstract    Hash Table Item Definition.
 * @field       key     Key for the identifier used in indexing.
 * @field       type    Type of the identifier used in type checking.
 * @field       name    Name of the identifier used in recognition.
 */
typedef struct hash_item {
    int key;
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
    hash_item ** items;
} hash_table;

/**
 * @var         hash_table
 * @abstract    Hash Table Declaration. Used in this class.
 */
struct hash_table symbols;

/**
 * @function    hash_table_items_initialize
 * @abstract    Initializes the hash_table's items field.
 * @return      Pointer to the array of hash_items.
 */
struct hash_item ** hash_table_items_initialize() {
    struct hash_item ** items = (struct hash_item **)calloc(
        TABLE_SIZE, sizeof(struct hash_item *));
    log_hash_items_initialization(items);
    return items;
}

/**
 * @function    log_hash_items_initialization
 * @abstract    Logs the creation of the hash_table's items array.
 */
void log_hash_items_initialization(struct hash_item ** items) {
    fprintf(stdout, "A table has been created: %d elements at position %p\n",
        TABLE_SIZE, items);
}

/**
 * @function    hash_table_initialize
 * @abstract    Initializes the hash_table's fields.
 */
void hash_table_initialize() {
    symbols.size = 0;
    symbols.items = hash_table_items_initialize();
}