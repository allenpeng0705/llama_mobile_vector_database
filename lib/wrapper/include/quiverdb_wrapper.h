// QuiverDB Wrapper - Copyright (c) 2025 - MIT License
#pragma once

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Error codes
typedef enum {
    QUIVERDB_OK = 0,
    QUIVERDB_ERROR = -1,
    QUIVERDB_INVALID_ARGUMENT = -2,
    QUIVERDB_OUT_OF_MEMORY = -3,
    QUIVERDB_FILE_ERROR = -4,
    QUIVERDB_DUPLICATE_ID = -5,
    QUIVERDB_ID_NOT_FOUND = -6,
    QUIVERDB_INDEX_FULL = -7,
} QuiverDBError;

// Distance metrics
typedef enum {
    QUIVERDB_DISTANCE_L2 = 0,
    QUIVERDB_DISTANCE_COSINE = 1,
    QUIVERDB_DISTANCE_DOT = 2,
} QuiverDBDistanceMetric;

// Opaque handles
typedef void* QuiverDBVectorStore;
typedef void* QuiverDBHNSWIndex;
typedef void* QuiverDBMMapVectorStore;
typedef void* QuiverDBMMapVectorStoreBuilder;

// Search result structure
typedef struct {
    uint64_t id;
    float distance;
} QuiverDBSearchResult;

// VectorStore functions
QuiverDBError quiverdb_vector_store_create(size_t dimension, QuiverDBDistanceMetric metric, QuiverDBVectorStore* store);
QuiverDBError quiverdb_vector_store_add(QuiverDBVectorStore store, uint64_t id, const float* vector);
QuiverDBError quiverdb_vector_store_remove(QuiverDBVectorStore store, uint64_t id, int* removed);
QuiverDBError quiverdb_vector_store_get(QuiverDBVectorStore store, uint64_t id, float* vector, size_t vector_size);
QuiverDBError quiverdb_vector_store_update(QuiverDBVectorStore store, uint64_t id, const float* vector);
QuiverDBError quiverdb_vector_store_search(QuiverDBVectorStore store, const float* query, size_t k, QuiverDBSearchResult* results, size_t results_size);
QuiverDBError quiverdb_vector_store_size(QuiverDBVectorStore store, size_t* size);
QuiverDBError quiverdb_vector_store_dimension(QuiverDBVectorStore store, size_t* dimension);
QuiverDBError quiverdb_vector_store_metric(QuiverDBVectorStore store, QuiverDBDistanceMetric* metric);
QuiverDBError quiverdb_vector_store_contains(QuiverDBVectorStore store, uint64_t id, int* contains);
QuiverDBError quiverdb_vector_store_reserve(QuiverDBVectorStore store, size_t capacity);
QuiverDBError quiverdb_vector_store_clear(QuiverDBVectorStore store);
void quiverdb_vector_store_destroy(QuiverDBVectorStore store);

// HNSWIndex functions
QuiverDBError quiverdb_hnsw_index_create(size_t dimension, QuiverDBDistanceMetric metric, size_t max_elements, QuiverDBHNSWIndex* index);
QuiverDBError quiverdb_hnsw_index_create_with_params(size_t dimension, QuiverDBDistanceMetric metric, size_t max_elements, size_t M, size_t ef_construction, uint32_t seed, QuiverDBHNSWIndex* index);
QuiverDBError quiverdb_hnsw_index_add(QuiverDBHNSWIndex index, uint64_t id, const float* vector);
QuiverDBError quiverdb_hnsw_index_search(QuiverDBHNSWIndex index, const float* query, size_t k, QuiverDBSearchResult* results, size_t results_size);
QuiverDBError quiverdb_hnsw_index_set_ef_search(QuiverDBHNSWIndex index, size_t ef_search);
QuiverDBError quiverdb_hnsw_index_get_ef_search(QuiverDBHNSWIndex index, size_t* ef_search);
QuiverDBError quiverdb_hnsw_index_size(QuiverDBHNSWIndex index, size_t* size);
QuiverDBError quiverdb_hnsw_index_dimension(QuiverDBHNSWIndex index, size_t* dimension);
QuiverDBError quiverdb_hnsw_index_capacity(QuiverDBHNSWIndex index, size_t* capacity);
QuiverDBError quiverdb_hnsw_index_contains(QuiverDBHNSWIndex index, uint64_t id, int* contains);
QuiverDBError quiverdb_hnsw_index_get_vector(QuiverDBHNSWIndex index, uint64_t id, float* vector, size_t vector_size);
QuiverDBError quiverdb_hnsw_index_save(QuiverDBHNSWIndex index, const char* filename);
QuiverDBError quiverdb_hnsw_index_load(const char* filename, QuiverDBHNSWIndex* index);
void quiverdb_hnsw_index_destroy(QuiverDBHNSWIndex index);

// MMapVectorStoreBuilder functions
QuiverDBError quiverdb_mmap_vector_store_builder_create(size_t dimension, QuiverDBDistanceMetric metric, QuiverDBMMapVectorStoreBuilder* builder);
QuiverDBError quiverdb_mmap_vector_store_builder_add(QuiverDBMMapVectorStoreBuilder builder, uint64_t id, const float* vector);
QuiverDBError quiverdb_mmap_vector_store_builder_reserve(QuiverDBMMapVectorStoreBuilder builder, size_t capacity);
QuiverDBError quiverdb_mmap_vector_store_builder_save(QuiverDBMMapVectorStoreBuilder builder, const char* filename);
QuiverDBError quiverdb_mmap_vector_store_builder_size(QuiverDBMMapVectorStoreBuilder builder, size_t* size);
QuiverDBError quiverdb_mmap_vector_store_builder_dimension(QuiverDBMMapVectorStoreBuilder builder, size_t* dimension);
void quiverdb_mmap_vector_store_builder_destroy(QuiverDBMMapVectorStoreBuilder builder);

// MMapVectorStore functions
QuiverDBError quiverdb_mmap_vector_store_open(const char* filename, QuiverDBMMapVectorStore* store);
QuiverDBError quiverdb_mmap_vector_store_get(QuiverDBMMapVectorStore store, uint64_t id, float* vector, size_t vector_size);
QuiverDBError quiverdb_mmap_vector_store_contains(QuiverDBMMapVectorStore store, uint64_t id, int* contains);
QuiverDBError quiverdb_mmap_vector_store_search(QuiverDBMMapVectorStore store, const float* query, size_t k, QuiverDBSearchResult* results, size_t results_size);
QuiverDBError quiverdb_mmap_vector_store_size(QuiverDBMMapVectorStore store, size_t* size);
QuiverDBError quiverdb_mmap_vector_store_dimension(QuiverDBMMapVectorStore store, size_t* dimension);
QuiverDBError quiverdb_mmap_vector_store_metric(QuiverDBMMapVectorStore store, QuiverDBDistanceMetric* metric);
void quiverdb_mmap_vector_store_close(QuiverDBMMapVectorStore store);

// Version information
const char* quiverdb_version();
int quiverdb_version_major();
int quiverdb_version_minor();
int quiverdb_version_patch();

#ifdef __cplusplus
}
#endif
