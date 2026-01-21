// Test file for QuiverDB Wrapper API
// Copyright (c) 2025 - MIT License

#include <iostream>
#include <cassert>
#include <vector>
#include <algorithm>
#include "llama_mobile_vd_wrapper.h"

// Helper function to create a random vector
void create_random_vector(float* vector, size_t dimension) {
    for (size_t i = 0; i < dimension; ++i) {
        vector[i] = static_cast<float>(rand()) / static_cast<float>(RAND_MAX) * 2.0f - 1.0f;
    }
}

// Test VectorStore functionality
void test_vector_store() {
    std::cout << "=== Testing VectorStore ===" << std::endl;
    
    const size_t dimension = 128;
    const size_t num_vectors = 100;
    const size_t k = 5;
    
    // Create VectorStore
    LLAMA_MOBILE_VD_VectorStore store;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_create(dimension, LLAMA_MOBILE_VD_DISTANCE_L2, &store);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Test dimension
    size_t actual_dimension = 0;
    error = llama_mobile_vd_vector_store_dimension(store, &actual_dimension);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(actual_dimension == dimension);
    std::cout << "✓ VectorStore dimension test passed" << std::endl;
    
    // Test metric
    LLAMA_MOBILE_VD_DistanceMetric metric;
    error = llama_mobile_vd_vector_store_metric(store, &metric);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(metric == LLAMA_MOBILE_VD_DISTANCE_L2);
    std::cout << "✓ VectorStore metric test passed" << std::endl;
    
    // Add vectors
    std::vector<float> vectors(num_vectors * dimension);
    std::vector<uint64_t> ids(num_vectors);
    
    for (size_t i = 0; i < num_vectors; ++i) {
        ids[i] = i + 1;
        float* vec = &vectors[i * dimension];
        create_random_vector(vec, dimension);
        
        error = llama_mobile_vd_vector_store_add(store, ids[i], vec);
        assert(error == LLAMA_MOBILE_VD_OK);
    }
    
    // Test size
    size_t size = 0;
    error = llama_mobile_vd_vector_store_size(store, &size);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(size == num_vectors);
    std::cout << "✓ VectorStore add and size test passed" << std::endl;
    
    // Test contains
    int contains = 0;
    error = llama_mobile_vd_vector_store_contains(store, ids[0], &contains);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(contains == 1);
    
    error = llama_mobile_vd_vector_store_contains(store, 9999, &contains);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(contains == 0);
    std::cout << "✓ VectorStore contains test passed" << std::endl;
    
    // Test get
    float retrieved[dimension];
    error = llama_mobile_vd_vector_store_get(store, ids[0], retrieved, dimension);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Verify the retrieved vector matches
    bool matches = true;
    for (size_t i = 0; i < dimension; ++i) {
        if (retrieved[i] != vectors[i]) {
            matches = false;
            break;
        }
    }
    assert(matches);
    std::cout << "✓ VectorStore get test passed" << std::endl;
    
    // Test update
    float updated[dimension];
    create_random_vector(updated, dimension);
    error = llama_mobile_vd_vector_store_update(store, ids[0], updated);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Verify update
    error = llama_mobile_vd_vector_store_get(store, ids[0], retrieved, dimension);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    matches = true;
    for (size_t i = 0; i < dimension; ++i) {
        if (retrieved[i] != updated[i]) {
            matches = false;
            break;
        }
    }
    assert(matches);
    std::cout << "✓ VectorStore update test passed" << std::endl;
    
    // Test search
    float query[dimension];
    create_random_vector(query, dimension);
    
    LLAMA_MOBILE_VD_SearchResult results[k];
    error = llama_mobile_vd_vector_store_search(store, query, k, results, k);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Verify results are sorted
    for (size_t i = 0; i < k - 1; ++i) {
        assert(results[i].distance <= results[i + 1].distance);
    }
    std::cout << "✓ VectorStore search test passed" << std::endl;
    
    // Test remove
    int removed = 0;
    error = llama_mobile_vd_vector_store_remove(store, ids[0], &removed);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(removed == 1);
    
    // Verify remove
    error = llama_mobile_vd_vector_store_size(store, &size);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(size == num_vectors - 1);
    
    error = llama_mobile_vd_vector_store_contains(store, ids[0], &contains);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(contains == 0);
    std::cout << "✓ VectorStore remove test passed" << std::endl;
    
    // Test clear
    error = llama_mobile_vd_vector_store_clear(store);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    error = llama_mobile_vd_vector_store_size(store, &size);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(size == 0);
    std::cout << "✓ VectorStore clear test passed" << std::endl;
    
    // Destroy VectorStore
    llama_mobile_vd_vector_store_destroy(store);
    
    std::cout << "=== All VectorStore tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Test HNSWIndex functionality
void test_hnsw_index() {
    std::cout << "=== Testing HNSWIndex ===" << std::endl;
    
    const size_t dimension = 128;
    const size_t num_vectors = 100;
    const size_t k = 5;
    
    // Create HNSWIndex
    LLAMA_MOBILE_VD_HNSWIndex index;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_create(dimension, LLAMA_MOBILE_VD_DISTANCE_L2, num_vectors * 2, &index);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Test dimension
    size_t actual_dimension = 0;
    error = llama_mobile_vd_hnsw_index_dimension(index, &actual_dimension);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(actual_dimension == dimension);
    std::cout << "✓ HNSWIndex dimension test passed" << std::endl;
    
    // Test capacity
    size_t capacity = 0;
    error = llama_mobile_vd_hnsw_index_capacity(index, &capacity);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(capacity == num_vectors * 2);
    std::cout << "✓ HNSWIndex capacity test passed" << std::endl;
    
    // Test ef_search
    size_t ef_search = 0;
    error = llama_mobile_vd_hnsw_index_get_ef_search(index, &ef_search);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Set and verify ef_search
    error = llama_mobile_vd_hnsw_index_set_ef_search(index, 100);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    error = llama_mobile_vd_hnsw_index_get_ef_search(index, &ef_search);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(ef_search == 100);
    std::cout << "✓ HNSWIndex ef_search test passed" << std::endl;
    
    // Add vectors
    std::vector<float> vectors(num_vectors * dimension);
    std::vector<uint64_t> ids(num_vectors);
    
    for (size_t i = 0; i < num_vectors; ++i) {
        ids[i] = i + 1;
        float* vec = &vectors[i * dimension];
        create_random_vector(vec, dimension);
        
        error = llama_mobile_vd_hnsw_index_add(index, ids[i], vec);
        assert(error == LLAMA_MOBILE_VD_OK);
    }
    
    // Test size
    size_t size = 0;
    error = llama_mobile_vd_hnsw_index_size(index, &size);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(size == num_vectors);
    std::cout << "✓ HNSWIndex add and size test passed" << std::endl;
    
    // Test search
    float query[dimension];
    create_random_vector(query, dimension);
    
    LLAMA_MOBILE_VD_SearchResult results[k];
    error = llama_mobile_vd_hnsw_index_search(index, query, k, results, k);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Verify results are sorted
    for (size_t i = 0; i < k - 1; ++i) {
        assert(results[i].distance <= results[i + 1].distance);
    }
    std::cout << "✓ HNSWIndex search test passed" << std::endl;
    
    // Test save and load (temporary file)
    const char* temp_file = "/tmp/llama_mobile_vd_test_index.bin";
    
    error = llama_mobile_vd_hnsw_index_save(index, temp_file);
    assert(error == LLAMA_MOBILE_VD_OK);
    std::cout << "✓ HNSWIndex save test passed" << std::endl;
    
    // Create a new index and load from file
    LLAMA_MOBILE_VD_HNSWIndex loaded_index;
    error = llama_mobile_vd_hnsw_index_load(temp_file, &loaded_index);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Verify loaded index has the same properties
    size_t loaded_size = 0;
    error = llama_mobile_vd_hnsw_index_size(loaded_index, &loaded_size);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(loaded_size == num_vectors);
    
    size_t loaded_dimension = 0;
    error = llama_mobile_vd_hnsw_index_dimension(loaded_index, &loaded_dimension);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(loaded_dimension == dimension);
    
    // Test search on loaded index
    LLAMA_MOBILE_VD_SearchResult loaded_results[k];
    error = llama_mobile_vd_hnsw_index_search(loaded_index, query, k, loaded_results, k);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    std::cout << "✓ HNSWIndex load test passed" << std::endl;
    
    // Clean up temporary file
    std::remove(temp_file);
    
    // Destroy indexes
    llama_mobile_vd_hnsw_index_destroy(index);
    llama_mobile_vd_hnsw_index_destroy(loaded_index);
    
    std::cout << "=== All HNSWIndex tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Test error handling
void test_error_handling() {
    std::cout << "=== Testing Error Handling ===" << std::endl;
    
    const size_t dimension = 128;
    
    // Test invalid metric
    LLAMA_MOBILE_VD_VectorStore store;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_create(dimension, static_cast<LLAMA_MOBILE_VD_DistanceMetric>(999), &store);
    assert(error != LLAMA_MOBILE_VD_OK);
    
    // Test valid creation
    error = llama_mobile_vd_vector_store_create(dimension, LLAMA_MOBILE_VD_DISTANCE_L2, &store);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Test duplicate ID
    float vector[dimension] = {0};
    error = llama_mobile_vd_vector_store_add(store, 1, vector);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    error = llama_mobile_vd_vector_store_add(store, 1, vector);
    assert(error == LLAMA_MOBILE_VD_DUPLICATE_ID);
    
    // Test ID not found
    int removed = 0;
    error = llama_mobile_vd_vector_store_remove(store, 9999, &removed);
    assert(error == LLAMA_MOBILE_VD_ID_NOT_FOUND);
    
    float retrieved[dimension] = {0};
    error = llama_mobile_vd_vector_store_get(store, 9999, retrieved, dimension);
    assert(error == LLAMA_MOBILE_VD_ID_NOT_FOUND);
    
    error = llama_mobile_vd_vector_store_update(store, 9999, vector);
    assert(error == LLAMA_MOBILE_VD_ID_NOT_FOUND);
    
    // Destroy store
    llama_mobile_vd_vector_store_destroy(store);
    
    std::cout << "=== All Error Handling tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Test version information
void test_version() {
    std::cout << "=== Testing Version Information ===" << std::endl;
    
    const char* version = llama_mobile_vd_version();
    assert(version != nullptr);
    
    int major = llama_mobile_vd_version_major();
    int minor = llama_mobile_vd_version_minor();
    int patch = llama_mobile_vd_version_patch();
    
    std::cout << "✓ Version: " << version << std::endl;
    std::cout << "✓ Version components: " << major << "." << minor << "." << patch << std::endl;
    
    std::cout << "=== All Version tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Comprehensive VectorStore tests
void test_vector_store_comprehensive() {
    std::cout << "=== Testing VectorStore - Comprehensive ===" << std::endl;
    
    const size_t dimension = 64;
    const size_t num_vectors = 200;
    const size_t k = 10;
    
    // Test with different batch sizes
    for (size_t batch_size : {1, 10, 50}) {
        LLAMA_MOBILE_VD_VectorStore store;
        LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_create(dimension, LLAMA_MOBILE_VD_DISTANCE_L2, &store);
        assert(error == LLAMA_MOBILE_VD_OK);
        
        std::cout << "  Testing VectorStore with batch size " << batch_size << "..." << std::endl;
        
        // Add vectors in batches
        std::vector<float> vectors(num_vectors * dimension);
        std::vector<uint64_t> ids(num_vectors);
        
        size_t added = 0;
        while (added < num_vectors) {
            size_t current_batch = std::min(batch_size, num_vectors - added);
            
            for (size_t i = 0; i < current_batch; ++i) {
                size_t idx = added + i;
                ids[idx] = idx + 1;
                float* vec = &vectors[idx * dimension];
                create_random_vector(vec, dimension);
                
                error = llama_mobile_vd_vector_store_add(store, ids[idx], vec);
                assert(error == LLAMA_MOBILE_VD_OK);
            }
            
            added += current_batch;
        }
        
        // Test multiple searches
        for (size_t i = 0; i < 5; ++i) {
            float query[dimension];
            create_random_vector(query, dimension);
            
            LLAMA_MOBILE_VD_SearchResult results[k];
            error = llama_mobile_vd_vector_store_search(store, query, k, results, k);
            assert(error == LLAMA_MOBILE_VD_OK);
            
            // Verify results are sorted
            for (size_t j = 0; j < k - 1; ++j) {
                assert(results[j].distance <= results[j + 1].distance);
            }
        }
        
        // Test remove in batches
        size_t removed = 0;
        while (removed < num_vectors / 2) {
            size_t current_batch = std::min(batch_size, (num_vectors / 2) - removed);
            
            for (size_t i = 0; i < current_batch; ++i) {
                size_t idx = removed + i;
                int removed_flag = 0;
                
                error = llama_mobile_vd_vector_store_remove(store, ids[idx], &removed_flag);
                assert(error == LLAMA_MOBILE_VD_OK);
                assert(removed_flag == 1);
            }
            
            removed += current_batch;
        }
        
        // Verify size after removal
        size_t size = 0;
        error = llama_mobile_vd_vector_store_size(store, &size);
        assert(error == LLAMA_MOBILE_VD_OK);
        assert(size == num_vectors - (num_vectors / 2));
        
        llama_mobile_vd_vector_store_destroy(store);
    }
    
    std::cout << "✓ VectorStore comprehensive batch operations test passed" << std::endl;
    std::cout << "=== All VectorStore comprehensive tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Test different distance metrics
void test_distance_metrics() {
    std::cout << "=== Testing Different Distance Metrics ===" << std::endl;
    
    const size_t dimension = 32;
    const size_t num_vectors = 50;
    const size_t k = 3;
    
    // Test with L2 distance
    std::cout << "  Testing L2 distance metric..." << std::endl;
    LLAMA_MOBILE_VD_VectorStore store_l2;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_create(dimension, LLAMA_MOBILE_VD_DISTANCE_L2, &store_l2);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Test with cosine distance
    std::cout << "  Testing cosine distance metric..." << std::endl;
    LLAMA_MOBILE_VD_VectorStore store_cosine;
    error = llama_mobile_vd_vector_store_create(dimension, LLAMA_MOBILE_VD_DISTANCE_COSINE, &store_cosine);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Test with dot product
    std::cout << "  Testing dot product distance metric..." << std::endl;
    LLAMA_MOBILE_VD_VectorStore store_dot;
    error = llama_mobile_vd_vector_store_create(dimension, LLAMA_MOBILE_VD_DISTANCE_DOT, &store_dot);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Add vectors to all stores
    std::vector<float> vectors(num_vectors * dimension);
    std::vector<uint64_t> ids(num_vectors);
    
    for (size_t i = 0; i < num_vectors; ++i) {
        ids[i] = i + 1;
        float* vec = &vectors[i * dimension];
        create_random_vector(vec, dimension);
        
        error = llama_mobile_vd_vector_store_add(store_l2, ids[i], vec);
        assert(error == LLAMA_MOBILE_VD_OK);
        
        error = llama_mobile_vd_vector_store_add(store_cosine, ids[i], vec);
        assert(error == LLAMA_MOBILE_VD_OK);
        
        error = llama_mobile_vd_vector_store_add(store_dot, ids[i], vec);
        assert(error == LLAMA_MOBILE_VD_OK);
    }
    
    // Create a query vector
    float query[dimension];
    create_random_vector(query, dimension);
    
    // Search in all stores
    LLAMA_MOBILE_VD_SearchResult results_l2[k];
    error = llama_mobile_vd_vector_store_search(store_l2, query, k, results_l2, k);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    LLAMA_MOBILE_VD_SearchResult results_cosine[k];
    error = llama_mobile_vd_vector_store_search(store_cosine, query, k, results_cosine, k);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    LLAMA_MOBILE_VD_SearchResult results_dot[k];
    error = llama_mobile_vd_vector_store_search(store_dot, query, k, results_dot, k);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Verify results are sorted for each metric
    for (size_t i = 0; i < k - 1; ++i) {
        assert(results_l2[i].distance <= results_l2[i + 1].distance);
        assert(results_cosine[i].distance <= results_cosine[i + 1].distance);
        assert(results_dot[i].distance <= results_dot[i + 1].distance);
    }
    
    // Test that we get different distances for different metrics
    bool all_same = true;
    for (size_t i = 0; i < k; ++i) {
        if (results_l2[i].distance != results_cosine[i].distance || 
            results_l2[i].distance != results_dot[i].distance) {
            all_same = false;
            break;
        }
    }
    
    // Depending on the vectors, distances might be the same in some cases,
    // so we don't assert here, just log
    if (all_same) {
        std::cout << "  Note: All distance metrics returned the same results for this query" << std::endl;
    } else {
        std::cout << "  ✓ Different distance metrics returned different results as expected" << std::endl;
    }
    
    // Verify metric retrieval
    LLAMA_MOBILE_VD_DistanceMetric metric = LLAMA_MOBILE_VD_DISTANCE_L2;
    error = llama_mobile_vd_vector_store_metric(store_l2, &metric);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(metric == LLAMA_MOBILE_VD_DISTANCE_L2);
    
    error = llama_mobile_vd_vector_store_metric(store_cosine, &metric);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(metric == LLAMA_MOBILE_VD_DISTANCE_COSINE);
    
    error = llama_mobile_vd_vector_store_metric(store_dot, &metric);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(metric == LLAMA_MOBILE_VD_DISTANCE_DOT);
    
    // Cleanup
    llama_mobile_vd_vector_store_destroy(store_l2);
    llama_mobile_vd_vector_store_destroy(store_cosine);
    llama_mobile_vd_vector_store_destroy(store_dot);
    
    std::cout << "✓ All distance metrics tests passed" << std::endl;
    std::cout << "=== All Distance Metrics tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Test edge cases
void test_edge_cases() {
    std::cout << "=== Testing Edge Cases ===" << std::endl;
    
    const size_t dimension = 128;
    
    // Test 1: Empty vector store operations
    std::cout << "  Testing empty VectorStore operations..." << std::endl;
    LLAMA_MOBILE_VD_VectorStore empty_store;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_create(dimension, LLAMA_MOBILE_VD_DISTANCE_L2, &empty_store);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Test size on empty store
    size_t size = 0;
    error = llama_mobile_vd_vector_store_size(empty_store, &size);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(size == 0);
    
    // Test search on empty store
    float query[dimension] = {0};
    const size_t k = 5;
    LLAMA_MOBILE_VD_SearchResult results[k];
    error = llama_mobile_vd_vector_store_search(empty_store, query, k, results, k);
    // Should not crash, but behavior depends on implementation
    
    // Test remove on empty store
    int removed_flag = 0;
    error = llama_mobile_vd_vector_store_remove(empty_store, 1, &removed_flag);
    assert(error == LLAMA_MOBILE_VD_ID_NOT_FOUND);
    assert(removed_flag == 0);
    
    // Test get on empty store
    float retrieved[dimension] = {0};
    error = llama_mobile_vd_vector_store_get(empty_store, 1, retrieved, dimension);
    assert(error == LLAMA_MOBILE_VD_ID_NOT_FOUND);
    
    // Test update on empty store
    float updated[dimension] = {0};
    error = llama_mobile_vd_vector_store_update(empty_store, 1, updated);
    assert(error == LLAMA_MOBILE_VD_ID_NOT_FOUND);
    
    // Test contains on empty store
    int contains = 0;
    error = llama_mobile_vd_vector_store_contains(empty_store, 1, &contains);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(contains == 0);
    
    // Test clear on empty store
    error = llama_mobile_vd_vector_store_clear(empty_store);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Test dimension on empty store
    size_t actual_dimension = 0;
    error = llama_mobile_vd_vector_store_dimension(empty_store, &actual_dimension);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(actual_dimension == dimension);
    
    llama_mobile_vd_vector_store_destroy(empty_store);
    
    // Test 2: Large dimension vectors
    std::cout << "  Testing large dimension vectors..." << std::endl;
    const size_t large_dimension = 1024;
    
    LLAMA_MOBILE_VD_VectorStore large_store;
    error = llama_mobile_vd_vector_store_create(large_dimension, LLAMA_MOBILE_VD_DISTANCE_L2, &large_store);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Add a few large vectors
    std::vector<float> large_vectors(3 * large_dimension);
    for (size_t i = 0; i < 3; ++i) {
        float* vec = &large_vectors[i * large_dimension];
        create_random_vector(vec, large_dimension);
        
        error = llama_mobile_vd_vector_store_add(large_store, i + 1, vec);
        assert(error == LLAMA_MOBILE_VD_OK);
    }
    
    // Test search with large vector
    float large_query[large_dimension];
    create_random_vector(large_query, large_dimension);
    
    LLAMA_MOBILE_VD_SearchResult large_results[k];
    error = llama_mobile_vd_vector_store_search(large_store, large_query, k, large_results, k);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    llama_mobile_vd_vector_store_destroy(large_store);
    
    // Test 3: Reserve functionality
    std::cout << "  Testing reserve functionality..." << std::endl;
    LLAMA_MOBILE_VD_VectorStore reserve_store;
    error = llama_mobile_vd_vector_store_create(dimension, LLAMA_MOBILE_VD_DISTANCE_L2, &reserve_store);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Test reserve
    const size_t reserve_size = 1000;
    error = llama_mobile_vd_vector_store_reserve(reserve_store, reserve_size);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    llama_mobile_vd_vector_store_destroy(reserve_store);
    
    std::cout << "✓ All edge cases tests passed" << std::endl;
    std::cout << "=== All Edge Cases tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Test comprehensive CRUD operations with different dimensions and dataset sizes
void test_comprehensive_crud_different_dimensions() {
    std::cout << "=== Testing Comprehensive CRUD with Different Dimensions ===" << std::endl;
    
    // Test different vector dimensions (small to large)
    std::vector<size_t> dimensions = {8, 32, 64, 256, 1024, 2048, 3096};
    
    // Test different dataset sizes (small to large)
    std::vector<size_t> dataset_sizes = {100, 1000, 5000}; //, 10000}; // Uncomment for larger test
    
    const size_t k = 10;
    
    for (size_t dimension : dimensions) {
        std::cout << "\n  Testing with vector dimension: " << dimension << std::endl;
        
        for (size_t num_vectors : dataset_sizes) {
            std::cout << "    Testing dataset size: " << num_vectors << " vectors..." << std::endl;
            
            // Create VectorStore
            LLAMA_MOBILE_VD_VectorStore store;
            LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_create(dimension, LLAMA_MOBILE_VD_DISTANCE_L2, &store);
            assert(error == LLAMA_MOBILE_VD_OK);
            
            // Reserve space for better performance
            error = llama_mobile_vd_vector_store_reserve(store, num_vectors);
            assert(error == LLAMA_MOBILE_VD_OK);
            
            // Add vectors
            std::vector<float> vectors(num_vectors * dimension);
            std::vector<uint64_t> ids(num_vectors);
            
            for (size_t i = 0; i < num_vectors; ++i) {
                ids[i] = i + 1;
                float* vec = &vectors[i * dimension];
                create_random_vector(vec, dimension);
                
                error = llama_mobile_vd_vector_store_add(store, ids[i], vec);
                assert(error == LLAMA_MOBILE_VD_OK);
            }
            
            // Verify all vectors were added
            size_t actual_size = 0;
            error = llama_mobile_vd_vector_store_size(store, &actual_size);
            assert(error == LLAMA_MOBILE_VD_OK);
            assert(actual_size == num_vectors);
            
            // Get random vectors to verify
            for (size_t i = 0; i < 5; ++i) {
                size_t random_idx = rand() % num_vectors;
                uint64_t random_id = ids[random_idx];
                
                std::vector<float> retrieved(dimension, 0.0f);
                error = llama_mobile_vd_vector_store_get(store, random_id, retrieved.data(), dimension);
                assert(error == LLAMA_MOBILE_VD_OK);
                
                // Verify retrieved vector matches
                bool matches = true;
                for (size_t j = 0; j < dimension; ++j) {
                    if (retrieved[j] != vectors[random_idx * dimension + j]) {
                        matches = false;
                        break;
                    }
                }
                assert(matches);
            }
            
            // Update some vectors
            for (size_t i = 0; i < 10; ++i) {
                size_t update_idx = rand() % num_vectors;
                uint64_t update_id = ids[update_idx];
                
                std::vector<float> updated(dimension);
                create_random_vector(updated.data(), dimension);
                
                error = llama_mobile_vd_vector_store_update(store, update_id, updated.data());
                assert(error == LLAMA_MOBILE_VD_OK);
                
                // Verify update
                std::vector<float> retrieved(dimension, 0.0f);
                error = llama_mobile_vd_vector_store_get(store, update_id, retrieved.data(), dimension);
                assert(error == LLAMA_MOBILE_VD_OK);
                
                bool matches = true;
                for (size_t j = 0; j < dimension; ++j) {
                    if (retrieved[j] != updated[j]) {
                        matches = false;
                        break;
                    }
                }
                assert(matches);
            }
            
            // Test search with multiple queries
            for (size_t i = 0; i < 3; ++i) {
                std::vector<float> query(dimension);
                create_random_vector(query.data(), dimension);
                
                LLAMA_MOBILE_VD_SearchResult results[k];
                error = llama_mobile_vd_vector_store_search(store, query.data(), k, results, k);
                assert(error == LLAMA_MOBILE_VD_OK);
                
                // Verify results are sorted
                for (size_t j = 0; j < k - 1; ++j) {
                    assert(results[j].distance <= results[j + 1].distance);
                }
            }
            
            // Test deletion of unique random vectors
            size_t vectors_to_delete = num_vectors / 10; // Delete 10%
            size_t actual_deletions = 0;
            
            // Delete every 10th vector to ensure unique IDs
            for (size_t i = 0; i < num_vectors; i += 10) {
                if (actual_deletions >= vectors_to_delete) break;
                
                uint64_t delete_id = ids[i];
                
                int removed = 0;
                error = llama_mobile_vd_vector_store_remove(store, delete_id, &removed);
                assert(error == LLAMA_MOBILE_VD_OK);
                assert(removed == 1);
                
                actual_deletions++;
                
                // Verify deletion
                error = llama_mobile_vd_vector_store_contains(store, delete_id, &removed);
                assert(error == LLAMA_MOBILE_VD_OK);
                assert(removed == 0);
            }
            
            // Verify size after deletion
            error = llama_mobile_vd_vector_store_size(store, &actual_size);
            assert(error == LLAMA_MOBILE_VD_OK);
            assert(actual_size == num_vectors - actual_deletions);
            
            // Test contains operation - check vectors that haven't been deleted
            for (size_t i = 0; i < 10; ++i) {
                // Find a vector that hasn't been deleted (avoid every 10th index)
                size_t test_idx = rand() % num_vectors;
                // Skip the indices we know we deleted
                while (test_idx % 10 == 0 && i < vectors_to_delete) {
                    test_idx = rand() % num_vectors;
                }
                
                uint64_t test_id = ids[test_idx];
                
                int contains = 0;
                error = llama_mobile_vd_vector_store_contains(store, test_id, &contains);
                assert(error == LLAMA_MOBILE_VD_OK);
                assert(contains == 1); // Should still exist
            }
            
            // Clear and verify
            error = llama_mobile_vd_vector_store_clear(store);
            assert(error == LLAMA_MOBILE_VD_OK);
            
            error = llama_mobile_vd_vector_store_size(store, &actual_size);
            assert(error == LLAMA_MOBILE_VD_OK);
            assert(actual_size == 0);
            
            // Destroy store
            llama_mobile_vd_vector_store_destroy(store);
            
            std::cout << "    ✓ Dataset size " << num_vectors << " passed" << std::endl;
        }
        
        std::cout << "  ✓ Dimension " << dimension << " passed all dataset sizes" << std::endl;
    }
    
    std::cout << "\n=== All Comprehensive CRUD tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Comprehensive HNSWIndex tests with different parameters
void test_hnsw_index_comprehensive() {
    std::cout << "=== Testing HNSWIndex - Comprehensive ===" << std::endl;
    
    const size_t dimension = 64;
    const size_t num_vectors = 100;
    const size_t k = 5;
    
    // Test with different construction parameters
    struct { size_t M; size_t ef_construction; } params[] = {
        {4, 10},  // Small parameters
        {8, 20},  // Medium parameters
        {16, 40}, // Larger parameters
    };
    
    for (const auto& p : params) {
        std::cout << "  Testing HNSWIndex with M=" << p.M << ", ef_construction=" << p.ef_construction << "..." << std::endl;
        
        // Create HNSWIndex with custom parameters
        LLAMA_MOBILE_VD_HNSWIndex index;
        LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_create_with_params(
            dimension, LLAMA_MOBILE_VD_DISTANCE_L2, num_vectors * 2, p.M, p.ef_construction, 42, &index);
        assert(error == LLAMA_MOBILE_VD_OK);
        
        // Add vectors
        std::vector<float> vectors(num_vectors * dimension);
        std::vector<uint64_t> ids(num_vectors);
        
        for (size_t i = 0; i < num_vectors; ++i) {
            ids[i] = i + 1;
            float* vec = &vectors[i * dimension];
            create_random_vector(vec, dimension);
            
            error = llama_mobile_vd_hnsw_index_add(index, ids[i], vec);
            assert(error == LLAMA_MOBILE_VD_OK);
        }
        
        // Test different ef_search values
        for (size_t ef_search : {10, 20, 50}) {
            error = llama_mobile_vd_hnsw_index_set_ef_search(index, ef_search);
            assert(error == LLAMA_MOBILE_VD_OK);
            
            size_t actual_ef_search = 0;
            error = llama_mobile_vd_hnsw_index_get_ef_search(index, &actual_ef_search);
            assert(error == LLAMA_MOBILE_VD_OK);
            assert(actual_ef_search == ef_search);
            
            // Test search
            float query[dimension];
            create_random_vector(query, dimension);
            
            LLAMA_MOBILE_VD_SearchResult results[k];
            error = llama_mobile_vd_hnsw_index_search(index, query, k, results, k);
            assert(error == LLAMA_MOBILE_VD_OK);
            
            // Verify results are sorted
            for (size_t j = 0; j < k - 1; ++j) {
                assert(results[j].distance <= results[j + 1].distance);
            }
        }
        
        llama_mobile_vd_hnsw_index_destroy(index);
    }
    
    std::cout << "✓ HNSWIndex comprehensive parameter tests passed" << std::endl;
    std::cout << "=== All HNSWIndex comprehensive tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Test MMapVectorStore functionality
void test_mmap_vector_store() {
    std::cout << "=== Testing MMapVectorStore ===" << std::endl;
    
    const size_t dimension = 128;
    const size_t num_vectors = 100;
    const size_t k = 5;
    
    // Create a temporary file name
    const char* temp_file = "/tmp/llama_mobile_vd_test_mmap.bin";
    
    // Create MMapVectorStoreBuilder
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_builder_create(dimension, LLAMA_MOBILE_VD_DISTANCE_L2, &builder);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Test dimension
    size_t actual_dimension = 0;
    error = llama_mobile_vd_mmap_vector_store_builder_dimension(builder, &actual_dimension);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(actual_dimension == dimension);
    std::cout << "✓ MMapVectorStoreBuilder dimension test passed" << std::endl;
    
    // Add vectors
    std::vector<float> vectors(num_vectors * dimension);
    std::vector<uint64_t> ids(num_vectors);
    
    for (size_t i = 0; i < num_vectors; ++i) {
        ids[i] = i + 1;
        float* vec = &vectors[i * dimension];
        create_random_vector(vec, dimension);
        
        error = llama_mobile_vd_mmap_vector_store_builder_add(builder, ids[i], vec);
        assert(error == LLAMA_MOBILE_VD_OK);
    }
    
    // Test size
    size_t size = 0;
    error = llama_mobile_vd_mmap_vector_store_builder_size(builder, &size);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(size == num_vectors);
    std::cout << "✓ MMapVectorStoreBuilder add and size test passed" << std::endl;
    
    // Test reserve
    error = llama_mobile_vd_mmap_vector_store_builder_reserve(builder, num_vectors * 2);
    assert(error == LLAMA_MOBILE_VD_OK);
    std::cout << "✓ MMapVectorStoreBuilder reserve test passed" << std::endl;
    
    // Save to file
    error = llama_mobile_vd_mmap_vector_store_builder_save(builder, temp_file);
    assert(error == LLAMA_MOBILE_VD_OK);
    std::cout << "✓ MMapVectorStoreBuilder save test passed" << std::endl;
    
    // Destroy builder
    llama_mobile_vd_mmap_vector_store_builder_destroy(builder);
    
    // Open MMapVectorStore from file
    LLAMA_MOBILE_VD_MMapVectorStore store;
    error = llama_mobile_vd_mmap_vector_store_open(temp_file, &store);
    assert(error == LLAMA_MOBILE_VD_OK);
    std::cout << "✓ MMapVectorStore open test passed" << std::endl;
    
    // Test size
    size_t store_size = 0;
    error = llama_mobile_vd_mmap_vector_store_size(store, &store_size);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(store_size == num_vectors);
    std::cout << "✓ MMapVectorStore size test passed" << std::endl;
    
    // Test dimension
    size_t store_dimension = 0;
    error = llama_mobile_vd_mmap_vector_store_dimension(store, &store_dimension);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(store_dimension == dimension);
    std::cout << "✓ MMapVectorStore dimension test passed" << std::endl;
    
    // Test metric
    LLAMA_MOBILE_VD_DistanceMetric metric;
    error = llama_mobile_vd_mmap_vector_store_metric(store, &metric);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(metric == LLAMA_MOBILE_VD_DISTANCE_L2);
    std::cout << "✓ MMapVectorStore metric test passed" << std::endl;
    
    // Test contains
    int contains = 0;
    error = llama_mobile_vd_mmap_vector_store_contains(store, ids[0], &contains);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(contains == 1);
    
    error = llama_mobile_vd_mmap_vector_store_contains(store, 9999, &contains);
    assert(error == LLAMA_MOBILE_VD_OK);
    assert(contains == 0);
    std::cout << "✓ MMapVectorStore contains test passed" << std::endl;
    
    // Test get
    float retrieved[dimension];
    error = llama_mobile_vd_mmap_vector_store_get(store, ids[0], retrieved, dimension);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Verify the retrieved vector matches
    bool matches = true;
    for (size_t i = 0; i < dimension; ++i) {
        if (retrieved[i] != vectors[i]) {
            matches = false;
            break;
        }
    }
    assert(matches);
    std::cout << "✓ MMapVectorStore get test passed" << std::endl;
    
    // Test search
    float query[dimension];
    create_random_vector(query, dimension);
    
    LLAMA_MOBILE_VD_SearchResult results[k];
    error = llama_mobile_vd_mmap_vector_store_search(store, query, k, results, k);
    assert(error == LLAMA_MOBILE_VD_OK);
    
    // Verify results are sorted
    for (size_t i = 0; i < k - 1; ++i) {
        assert(results[i].distance <= results[i + 1].distance);
    }
    std::cout << "✓ MMapVectorStore search test passed" << std::endl;
    
    // Close store
    llama_mobile_vd_mmap_vector_store_close(store);
    
    // Clean up temporary file
    std::remove(temp_file);
    
    std::cout << "=== All MMapVectorStore tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

int main() {
    std::cout << "Running QuiverDB Wrapper API Tests..." << std::endl;
    std::cout << "" << std::endl;
    
    // Seed random number generator
    srand(static_cast<unsigned int>(time(nullptr)));
    
    // Run all tests
    test_vector_store();
    test_vector_store_comprehensive();
    test_hnsw_index();
    test_hnsw_index_comprehensive();
    test_mmap_vector_store();
    test_distance_metrics();
    test_error_handling();
    test_edge_cases();
    test_comprehensive_crud_different_dimensions();
    test_version();
    
    std::cout << "=====================================" << std::endl;
    std::cout << "All tests passed successfully!" << std::endl;
    std::cout << "=====================================" << std::endl;
    
    return 0;
}