// LLAMA_MOBILE_VD Wrapper - Copyright (c) 2025 - MIT License
#pragma once

#include <stddef.h>
#include <stdint.h>
#include "llama_mobile_vd_version.h"

#ifdef __cplusplus
extern "C" {
#endif

// Error codes
typedef enum {
    LLAMA_MOBILE_VD_OK = 0,
    LLAMA_MOBILE_VD_ERROR = -1,
    LLAMA_MOBILE_VD_INVALID_ARGUMENT = -2,
    LLAMA_MOBILE_VD_OUT_OF_MEMORY = -3,
    LLAMA_MOBILE_VD_FILE_ERROR = -4,
    LLAMA_MOBILE_VD_DUPLICATE_ID = -5,
    LLAMA_MOBILE_VD_ID_NOT_FOUND = -6,
    LLAMA_MOBILE_VD_INDEX_FULL = -7,
} LLAMA_MOBILE_VD_Error;

// Distance metrics
typedef enum {
    LLAMA_MOBILE_VD_DISTANCE_L2 = 0,
    LLAMA_MOBILE_VD_DISTANCE_COSINE = 1,
    LLAMA_MOBILE_VD_DISTANCE_DOT = 2,
} LLAMA_MOBILE_VD_DistanceMetric;

// Opaque handles
typedef void* LLAMA_MOBILE_VD_VectorStore;
typedef void* LLAMA_MOBILE_VD_HNSWIndex;
typedef void* LLAMA_MOBILE_VD_MMapVectorStore;
typedef void* LLAMA_MOBILE_VD_MMapVectorStoreBuilder;

// Search result structure
typedef struct {
    uint64_t id;
    float distance;
} LLAMA_MOBILE_VD_SearchResult;

// VectorStore functions
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_create(size_t dimension, LLAMA_MOBILE_VD_DistanceMetric metric, LLAMA_MOBILE_VD_VectorStore* store);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_add(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, const float* vector);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_remove(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, int* removed);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_get(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, float* vector, size_t vector_size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_update(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, const float* vector);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_search(LLAMA_MOBILE_VD_VectorStore store, const float* query, size_t k, LLAMA_MOBILE_VD_SearchResult* results, size_t results_size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_size(LLAMA_MOBILE_VD_VectorStore store, size_t* size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_dimension(LLAMA_MOBILE_VD_VectorStore store, size_t* dimension);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_metric(LLAMA_MOBILE_VD_VectorStore store, LLAMA_MOBILE_VD_DistanceMetric* metric);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_contains(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, int* contains);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_reserve(LLAMA_MOBILE_VD_VectorStore store, size_t capacity);
LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_clear(LLAMA_MOBILE_VD_VectorStore store);
void llama_mobile_vd_vector_store_destroy(LLAMA_MOBILE_VD_VectorStore store);

// HNSWIndex functions
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_create(size_t dimension, LLAMA_MOBILE_VD_DistanceMetric metric, size_t max_elements, LLAMA_MOBILE_VD_HNSWIndex* index);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_create_with_params(size_t dimension, LLAMA_MOBILE_VD_DistanceMetric metric, size_t max_elements, size_t M, size_t ef_construction, uint32_t seed, LLAMA_MOBILE_VD_HNSWIndex* index);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_add(LLAMA_MOBILE_VD_HNSWIndex index, uint64_t id, const float* vector);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_search(LLAMA_MOBILE_VD_HNSWIndex index, const float* query, size_t k, LLAMA_MOBILE_VD_SearchResult* results, size_t results_size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_set_ef_search(LLAMA_MOBILE_VD_HNSWIndex index, size_t ef_search);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_get_ef_search(LLAMA_MOBILE_VD_HNSWIndex index, size_t* ef_search);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_size(LLAMA_MOBILE_VD_HNSWIndex index, size_t* size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_dimension(LLAMA_MOBILE_VD_HNSWIndex index, size_t* dimension);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_capacity(LLAMA_MOBILE_VD_HNSWIndex index, size_t* capacity);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_contains(LLAMA_MOBILE_VD_HNSWIndex index, uint64_t id, int* contains);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_get_vector(LLAMA_MOBILE_VD_HNSWIndex index, uint64_t id, float* vector, size_t vector_size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_save(LLAMA_MOBILE_VD_HNSWIndex index, const char* filename);
LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_load(const char* filename, LLAMA_MOBILE_VD_HNSWIndex* index);
void llama_mobile_vd_hnsw_index_destroy(LLAMA_MOBILE_VD_HNSWIndex index);

// MMapVectorStoreBuilder functions
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_create(size_t dimension, LLAMA_MOBILE_VD_DistanceMetric metric, LLAMA_MOBILE_VD_MMapVectorStoreBuilder* builder);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_add(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, uint64_t id, const float* vector);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_reserve(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, size_t capacity);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_save(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, const char* filename);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_size(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, size_t* size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_dimension(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, size_t* dimension);
void llama_mobile_vd_mmap_vector_store_builder_destroy(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder);

// MMapVectorStore functions
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_open(const char* filename, LLAMA_MOBILE_VD_MMapVectorStore* store);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_get(LLAMA_MOBILE_VD_MMapVectorStore store, uint64_t id, float* vector, size_t vector_size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_contains(LLAMA_MOBILE_VD_MMapVectorStore store, uint64_t id, int* contains);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_search(LLAMA_MOBILE_VD_MMapVectorStore store, const float* query, size_t k, LLAMA_MOBILE_VD_SearchResult* results, size_t results_size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_size(LLAMA_MOBILE_VD_MMapVectorStore store, size_t* size);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_dimension(LLAMA_MOBILE_VD_MMapVectorStore store, size_t* dimension);
LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_metric(LLAMA_MOBILE_VD_MMapVectorStore store, LLAMA_MOBILE_VD_DistanceMetric* metric);
void llama_mobile_vd_mmap_vector_store_close(LLAMA_MOBILE_VD_MMapVectorStore store);



#ifdef __cplusplus
}
#endif
