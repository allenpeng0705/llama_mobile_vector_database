// Test file for QuiverDB Wrapper API
// Copyright (c) 2025 - MIT License

#include <iostream>
#include <cassert>
#include <vector>
#include <algorithm>
#include "quiverdb_wrapper.h"

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
    QuiverDBVectorStore store;
    QuiverDBError error = quiverdb_vector_store_create(dimension, QUIVERDB_DISTANCE_L2, &store);
    assert(error == QUIVERDB_OK);
    
    // Test dimension
    size_t actual_dimension = 0;
    error = quiverdb_vector_store_dimension(store, &actual_dimension);
    assert(error == QUIVERDB_OK);
    assert(actual_dimension == dimension);
    std::cout << "✓ VectorStore dimension test passed" << std::endl;
    
    // Test metric
    QuiverDBDistanceMetric metric;
    error = quiverdb_vector_store_metric(store, &metric);
    assert(error == QUIVERDB_OK);
    assert(metric == QUIVERDB_DISTANCE_L2);
    std::cout << "✓ VectorStore metric test passed" << std::endl;
    
    // Add vectors
    std::vector<float> vectors(num_vectors * dimension);
    std::vector<uint64_t> ids(num_vectors);
    
    for (size_t i = 0; i < num_vectors; ++i) {
        ids[i] = i + 1;
        float* vec = &vectors[i * dimension];
        create_random_vector(vec, dimension);
        
        error = quiverdb_vector_store_add(store, ids[i], vec);
        assert(error == QUIVERDB_OK);
    }
    
    // Test size
    size_t size = 0;
    error = quiverdb_vector_store_size(store, &size);
    assert(error == QUIVERDB_OK);
    assert(size == num_vectors);
    std::cout << "✓ VectorStore add and size test passed" << std::endl;
    
    // Test contains
    int contains = 0;
    error = quiverdb_vector_store_contains(store, ids[0], &contains);
    assert(error == QUIVERDB_OK);
    assert(contains == 1);
    
    error = quiverdb_vector_store_contains(store, 9999, &contains);
    assert(error == QUIVERDB_OK);
    assert(contains == 0);
    std::cout << "✓ VectorStore contains test passed" << std::endl;
    
    // Test get
    float retrieved[dimension];
    error = quiverdb_vector_store_get(store, ids[0], retrieved, dimension);
    assert(error == QUIVERDB_OK);
    
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
    error = quiverdb_vector_store_update(store, ids[0], updated);
    assert(error == QUIVERDB_OK);
    
    // Verify update
    error = quiverdb_vector_store_get(store, ids[0], retrieved, dimension);
    assert(error == QUIVERDB_OK);
    
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
    
    QuiverDBSearchResult results[k];
    error = quiverdb_vector_store_search(store, query, k, results, k);
    assert(error == QUIVERDB_OK);
    
    // Verify results are sorted
    for (size_t i = 0; i < k - 1; ++i) {
        assert(results[i].distance <= results[i + 1].distance);
    }
    std::cout << "✓ VectorStore search test passed" << std::endl;
    
    // Test remove
    int removed = 0;
    error = quiverdb_vector_store_remove(store, ids[0], &removed);
    assert(error == QUIVERDB_OK);
    assert(removed == 1);
    
    // Verify remove
    error = quiverdb_vector_store_size(store, &size);
    assert(error == QUIVERDB_OK);
    assert(size == num_vectors - 1);
    
    error = quiverdb_vector_store_contains(store, ids[0], &contains);
    assert(error == QUIVERDB_OK);
    assert(contains == 0);
    std::cout << "✓ VectorStore remove test passed" << std::endl;
    
    // Test clear
    error = quiverdb_vector_store_clear(store);
    assert(error == QUIVERDB_OK);
    
    error = quiverdb_vector_store_size(store, &size);
    assert(error == QUIVERDB_OK);
    assert(size == 0);
    std::cout << "✓ VectorStore clear test passed" << std::endl;
    
    // Destroy VectorStore
    quiverdb_vector_store_destroy(store);
    
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
    QuiverDBHNSWIndex index;
    QuiverDBError error = quiverdb_hnsw_index_create(dimension, QUIVERDB_DISTANCE_L2, num_vectors * 2, &index);
    assert(error == QUIVERDB_OK);
    
    // Test dimension
    size_t actual_dimension = 0;
    error = quiverdb_hnsw_index_dimension(index, &actual_dimension);
    assert(error == QUIVERDB_OK);
    assert(actual_dimension == dimension);
    std::cout << "✓ HNSWIndex dimension test passed" << std::endl;
    
    // Test capacity
    size_t capacity = 0;
    error = quiverdb_hnsw_index_capacity(index, &capacity);
    assert(error == QUIVERDB_OK);
    assert(capacity == num_vectors * 2);
    std::cout << "✓ HNSWIndex capacity test passed" << std::endl;
    
    // Test ef_search
    size_t ef_search = 0;
    error = quiverdb_hnsw_index_get_ef_search(index, &ef_search);
    assert(error == QUIVERDB_OK);
    
    // Set and verify ef_search
    error = quiverdb_hnsw_index_set_ef_search(index, 100);
    assert(error == QUIVERDB_OK);
    
    error = quiverdb_hnsw_index_get_ef_search(index, &ef_search);
    assert(error == QUIVERDB_OK);
    assert(ef_search == 100);
    std::cout << "✓ HNSWIndex ef_search test passed" << std::endl;
    
    // Add vectors
    std::vector<float> vectors(num_vectors * dimension);
    std::vector<uint64_t> ids(num_vectors);
    
    for (size_t i = 0; i < num_vectors; ++i) {
        ids[i] = i + 1;
        float* vec = &vectors[i * dimension];
        create_random_vector(vec, dimension);
        
        error = quiverdb_hnsw_index_add(index, ids[i], vec);
        assert(error == QUIVERDB_OK);
    }
    
    // Test size
    size_t size = 0;
    error = quiverdb_hnsw_index_size(index, &size);
    assert(error == QUIVERDB_OK);
    assert(size == num_vectors);
    std::cout << "✓ HNSWIndex add and size test passed" << std::endl;
    
    // Test search
    float query[dimension];
    create_random_vector(query, dimension);
    
    QuiverDBSearchResult results[k];
    error = quiverdb_hnsw_index_search(index, query, k, results, k);
    assert(error == QUIVERDB_OK);
    
    // Verify results are sorted
    for (size_t i = 0; i < k - 1; ++i) {
        assert(results[i].distance <= results[i + 1].distance);
    }
    std::cout << "✓ HNSWIndex search test passed" << std::endl;
    
    // Test save and load (temporary file)
    const char* temp_file = "/tmp/quiverdb_test_index.bin";
    
    error = quiverdb_hnsw_index_save(index, temp_file);
    assert(error == QUIVERDB_OK);
    std::cout << "✓ HNSWIndex save test passed" << std::endl;
    
    // Create a new index and load from file
    QuiverDBHNSWIndex loaded_index;
    error = quiverdb_hnsw_index_load(temp_file, &loaded_index);
    assert(error == QUIVERDB_OK);
    
    // Verify loaded index has the same properties
    size_t loaded_size = 0;
    error = quiverdb_hnsw_index_size(loaded_index, &loaded_size);
    assert(error == QUIVERDB_OK);
    assert(loaded_size == num_vectors);
    
    size_t loaded_dimension = 0;
    error = quiverdb_hnsw_index_dimension(loaded_index, &loaded_dimension);
    assert(error == QUIVERDB_OK);
    assert(loaded_dimension == dimension);
    
    // Test search on loaded index
    QuiverDBSearchResult loaded_results[k];
    error = quiverdb_hnsw_index_search(loaded_index, query, k, loaded_results, k);
    assert(error == QUIVERDB_OK);
    
    std::cout << "✓ HNSWIndex load test passed" << std::endl;
    
    // Clean up temporary file
    std::remove(temp_file);
    
    // Destroy indexes
    quiverdb_hnsw_index_destroy(index);
    quiverdb_hnsw_index_destroy(loaded_index);
    
    std::cout << "=== All HNSWIndex tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Test error handling
void test_error_handling() {
    std::cout << "=== Testing Error Handling ===" << std::endl;
    
    const size_t dimension = 128;
    
    // Test invalid metric
    QuiverDBVectorStore store;
    QuiverDBError error = quiverdb_vector_store_create(dimension, static_cast<QuiverDBDistanceMetric>(999), &store);
    assert(error != QUIVERDB_OK);
    
    // Test valid creation
    error = quiverdb_vector_store_create(dimension, QUIVERDB_DISTANCE_L2, &store);
    assert(error == QUIVERDB_OK);
    
    // Test duplicate ID
    float vector[dimension] = {0};
    error = quiverdb_vector_store_add(store, 1, vector);
    assert(error == QUIVERDB_OK);
    
    error = quiverdb_vector_store_add(store, 1, vector);
    assert(error == QUIVERDB_DUPLICATE_ID);
    
    // Test ID not found
    int removed = 0;
    error = quiverdb_vector_store_remove(store, 9999, &removed);
    assert(error == QUIVERDB_ID_NOT_FOUND);
    
    float retrieved[dimension] = {0};
    error = quiverdb_vector_store_get(store, 9999, retrieved, dimension);
    assert(error == QUIVERDB_ID_NOT_FOUND);
    
    error = quiverdb_vector_store_update(store, 9999, vector);
    assert(error == QUIVERDB_ID_NOT_FOUND);
    
    // Destroy store
    quiverdb_vector_store_destroy(store);
    
    std::cout << "=== All Error Handling tests passed! ===" << std::endl;
    std::cout << "" << std::endl;
}

// Test version information
void test_version() {
    std::cout << "=== Testing Version Information ===" << std::endl;
    
    const char* version = quiverdb_version();
    assert(version != nullptr);
    
    int major = quiverdb_version_major();
    int minor = quiverdb_version_minor();
    int patch = quiverdb_version_patch();
    
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
        QuiverDBVectorStore store;
        QuiverDBError error = quiverdb_vector_store_create(dimension, QUIVERDB_DISTANCE_L2, &store);
        assert(error == QUIVERDB_OK);
        
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
                
                error = quiverdb_vector_store_add(store, ids[idx], vec);
                assert(error == QUIVERDB_OK);
            }
            
            added += current_batch;
        }
        
        // Test multiple searches
        for (size_t i = 0; i < 5; ++i) {
            float query[dimension];
            create_random_vector(query, dimension);
            
            QuiverDBSearchResult results[k];
            error = quiverdb_vector_store_search(store, query, k, results, k);
            assert(error == QUIVERDB_OK);
            
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
                
                error = quiverdb_vector_store_remove(store, ids[idx], &removed_flag);
                assert(error == QUIVERDB_OK);
                assert(removed_flag == 1);
            }
            
            removed += current_batch;
        }
        
        // Verify size after removal
        size_t size = 0;
        error = quiverdb_vector_store_size(store, &size);
        assert(error == QUIVERDB_OK);
        assert(size == num_vectors - (num_vectors / 2));
        
        quiverdb_vector_store_destroy(store);
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
    QuiverDBVectorStore store_l2;
    QuiverDBError error = quiverdb_vector_store_create(dimension, QUIVERDB_DISTANCE_L2, &store_l2);
    assert(error == QUIVERDB_OK);
    
    // Test with cosine distance
    std::cout << "  Testing cosine distance metric..." << std::endl;
    QuiverDBVectorStore store_cosine;
    error = quiverdb_vector_store_create(dimension, QUIVERDB_DISTANCE_COSINE, &store_cosine);
    assert(error == QUIVERDB_OK);
    
    // Test with dot product
    std::cout << "  Testing dot product distance metric..." << std::endl;
    QuiverDBVectorStore store_dot;
    error = quiverdb_vector_store_create(dimension, QUIVERDB_DISTANCE_DOT, &store_dot);
    assert(error == QUIVERDB_OK);
    
    // Add vectors to all stores
    std::vector<float> vectors(num_vectors * dimension);
    std::vector<uint64_t> ids(num_vectors);
    
    for (size_t i = 0; i < num_vectors; ++i) {
        ids[i] = i + 1;
        float* vec = &vectors[i * dimension];
        create_random_vector(vec, dimension);
        
        error = quiverdb_vector_store_add(store_l2, ids[i], vec);
        assert(error == QUIVERDB_OK);
        
        error = quiverdb_vector_store_add(store_cosine, ids[i], vec);
        assert(error == QUIVERDB_OK);
        
        error = quiverdb_vector_store_add(store_dot, ids[i], vec);
        assert(error == QUIVERDB_OK);
    }
    
    // Create a query vector
    float query[dimension];
    create_random_vector(query, dimension);
    
    // Search in all stores
    QuiverDBSearchResult results_l2[k];
    error = quiverdb_vector_store_search(store_l2, query, k, results_l2, k);
    assert(error == QUIVERDB_OK);
    
    QuiverDBSearchResult results_cosine[k];
    error = quiverdb_vector_store_search(store_cosine, query, k, results_cosine, k);
    assert(error == QUIVERDB_OK);
    
    QuiverDBSearchResult results_dot[k];
    error = quiverdb_vector_store_search(store_dot, query, k, results_dot, k);
    assert(error == QUIVERDB_OK);
    
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
    QuiverDBDistanceMetric metric = QUIVERDB_DISTANCE_L2;
    error = quiverdb_vector_store_metric(store_l2, &metric);
    assert(error == QUIVERDB_OK);
    assert(metric == QUIVERDB_DISTANCE_L2);
    
    error = quiverdb_vector_store_metric(store_cosine, &metric);
    assert(error == QUIVERDB_OK);
    assert(metric == QUIVERDB_DISTANCE_COSINE);
    
    error = quiverdb_vector_store_metric(store_dot, &metric);
    assert(error == QUIVERDB_OK);
    assert(metric == QUIVERDB_DISTANCE_DOT);
    
    // Cleanup
    quiverdb_vector_store_destroy(store_l2);
    quiverdb_vector_store_destroy(store_cosine);
    quiverdb_vector_store_destroy(store_dot);
    
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
    QuiverDBVectorStore empty_store;
    QuiverDBError error = quiverdb_vector_store_create(dimension, QUIVERDB_DISTANCE_L2, &empty_store);
    assert(error == QUIVERDB_OK);
    
    // Test size on empty store
    size_t size = 0;
    error = quiverdb_vector_store_size(empty_store, &size);
    assert(error == QUIVERDB_OK);
    assert(size == 0);
    
    // Test search on empty store
    float query[dimension] = {0};
    const size_t k = 5;
    QuiverDBSearchResult results[k];
    error = quiverdb_vector_store_search(empty_store, query, k, results, k);
    // Should not crash, but behavior depends on implementation
    
    // Test remove on empty store
    int removed_flag = 0;
    error = quiverdb_vector_store_remove(empty_store, 1, &removed_flag);
    assert(error == QUIVERDB_ID_NOT_FOUND);
    assert(removed_flag == 0);
    
    // Test get on empty store
    float retrieved[dimension] = {0};
    error = quiverdb_vector_store_get(empty_store, 1, retrieved, dimension);
    assert(error == QUIVERDB_ID_NOT_FOUND);
    
    // Test update on empty store
    float updated[dimension] = {0};
    error = quiverdb_vector_store_update(empty_store, 1, updated);
    assert(error == QUIVERDB_ID_NOT_FOUND);
    
    // Test contains on empty store
    int contains = 0;
    error = quiverdb_vector_store_contains(empty_store, 1, &contains);
    assert(error == QUIVERDB_OK);
    assert(contains == 0);
    
    // Test clear on empty store
    error = quiverdb_vector_store_clear(empty_store);
    assert(error == QUIVERDB_OK);
    
    // Test dimension on empty store
    size_t actual_dimension = 0;
    error = quiverdb_vector_store_dimension(empty_store, &actual_dimension);
    assert(error == QUIVERDB_OK);
    assert(actual_dimension == dimension);
    
    quiverdb_vector_store_destroy(empty_store);
    
    // Test 2: Large dimension vectors
    std::cout << "  Testing large dimension vectors..." << std::endl;
    const size_t large_dimension = 1024;
    
    QuiverDBVectorStore large_store;
    error = quiverdb_vector_store_create(large_dimension, QUIVERDB_DISTANCE_L2, &large_store);
    assert(error == QUIVERDB_OK);
    
    // Add a few large vectors
    std::vector<float> large_vectors(3 * large_dimension);
    for (size_t i = 0; i < 3; ++i) {
        float* vec = &large_vectors[i * large_dimension];
        create_random_vector(vec, large_dimension);
        
        error = quiverdb_vector_store_add(large_store, i + 1, vec);
        assert(error == QUIVERDB_OK);
    }
    
    // Test search with large vector
    float large_query[large_dimension];
    create_random_vector(large_query, large_dimension);
    
    QuiverDBSearchResult large_results[k];
    error = quiverdb_vector_store_search(large_store, large_query, k, large_results, k);
    assert(error == QUIVERDB_OK);
    
    quiverdb_vector_store_destroy(large_store);
    
    // Test 3: Reserve functionality
    std::cout << "  Testing reserve functionality..." << std::endl;
    QuiverDBVectorStore reserve_store;
    error = quiverdb_vector_store_create(dimension, QUIVERDB_DISTANCE_L2, &reserve_store);
    assert(error == QUIVERDB_OK);
    
    // Test reserve
    const size_t reserve_size = 1000;
    error = quiverdb_vector_store_reserve(reserve_store, reserve_size);
    assert(error == QUIVERDB_OK);
    
    quiverdb_vector_store_destroy(reserve_store);
    
    std::cout << "✓ All edge cases tests passed" << std::endl;
    std::cout << "=== All Edge Cases tests passed! ===" << std::endl;
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
        QuiverDBHNSWIndex index;
        QuiverDBError error = quiverdb_hnsw_index_create_with_params(
            dimension, QUIVERDB_DISTANCE_L2, num_vectors * 2, p.M, p.ef_construction, 42, &index);
        assert(error == QUIVERDB_OK);
        
        // Add vectors
        std::vector<float> vectors(num_vectors * dimension);
        std::vector<uint64_t> ids(num_vectors);
        
        for (size_t i = 0; i < num_vectors; ++i) {
            ids[i] = i + 1;
            float* vec = &vectors[i * dimension];
            create_random_vector(vec, dimension);
            
            error = quiverdb_hnsw_index_add(index, ids[i], vec);
            assert(error == QUIVERDB_OK);
        }
        
        // Test different ef_search values
        for (size_t ef_search : {10, 20, 50}) {
            error = quiverdb_hnsw_index_set_ef_search(index, ef_search);
            assert(error == QUIVERDB_OK);
            
            size_t actual_ef_search = 0;
            error = quiverdb_hnsw_index_get_ef_search(index, &actual_ef_search);
            assert(error == QUIVERDB_OK);
            assert(actual_ef_search == ef_search);
            
            // Test search
            float query[dimension];
            create_random_vector(query, dimension);
            
            QuiverDBSearchResult results[k];
            error = quiverdb_hnsw_index_search(index, query, k, results, k);
            assert(error == QUIVERDB_OK);
            
            // Verify results are sorted
            for (size_t j = 0; j < k - 1; ++j) {
                assert(results[j].distance <= results[j + 1].distance);
            }
        }
        
        quiverdb_hnsw_index_destroy(index);
    }
    
    std::cout << "✓ HNSWIndex comprehensive parameter tests passed" << std::endl;
    std::cout << "=== All HNSWIndex comprehensive tests passed! ===" << std::endl;
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
    test_distance_metrics();
    test_error_handling();
    test_edge_cases();
    test_version();
    
    std::cout << "=====================================" << std::endl;
    std::cout << "All tests passed successfully!" << std::endl;
    std::cout << "=====================================" << std::endl;
    
    return 0;
}