// Imports
#include <stdio.h>

// Definitions
#define TABLE_SIZE  100
#define TABLE_PRIME 97

// Bison Connections
extern enum type;

// Declarations
typedef struct hash_item;
struct hash_table;
void init_hash_table();

/**
 * @typedef     hash_item_t
 * @abstract    Hash Table Item Definition.
 * @field       key     Key for the identifier used in indexing.
 * @field       type    Type of the identifier used in type checking.
 * @field       name    Name of the identifier used in recognition.
 */
typedef struct hash_item_s {
    int key;
    int type;
    char * name;
} hash_item_t;

/**
 * @struct      hash_table_t
 * @abstract    Hash Table Definition.
 * @field       size    Current occupancy of the hash table.
 * @field       items   Hash Table Items stored in the hash table.
 */
typedef struct hash_table_s {
    int size;
    hash_item_t ** items;
} hash_table_t;

/**
 * @var         hash_table
 * @abstract    Hash Table Declaration. Used in this class.
 */
hash_table_t hash_table;

/**
 * @function    hash_table_initialize
 * @abstract    Initializes the struct's fields.
 */
void hash_table_initialize() {
    struct hash_table_s hash_table = 0;
}
