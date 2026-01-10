// QuiverDB Wrapper - Copyright (c) 2025 - MIT License
#include "quiverdb_wrapper.h"
#include "core/vector_store.h"
#include "core/hnsw_index.h"
#include "core/version.h"

#include <cstring>
#include <stdexcept>
#include <memory>

using namespace quiverdb;

// VectorStore implementation

static DistanceMetric convert_metric(QuiverDBDistanceMetric metric) {
    switch (metric) {
        case QUIVERDB_DISTANCE_L2: return DistanceMetric::L2;
        case QUIVERDB_DISTANCE_COSINE: return DistanceMetric::COSINE;
        case QUIVERDB_DISTANCE_DOT: return DistanceMetric::DOT;
        default: return DistanceMetric::L2;
    }
}

static QuiverDBDistanceMetric convert_metric_back(DistanceMetric metric) {
    switch (metric) {
        case DistanceMetric::L2: return QUIVERDB_DISTANCE_L2;
        case DistanceMetric::COSINE: return QUIVERDB_DISTANCE_COSINE;
        case DistanceMetric::DOT: return QUIVERDB_DISTANCE_DOT;
        default: return QUIVERDB_DISTANCE_L2;
    }
}

static HNSWDistanceMetric convert_hnsw_metric(QuiverDBDistanceMetric metric) {
    switch (metric) {
        case QUIVERDB_DISTANCE_L2: return HNSWDistanceMetric::L2;
        case QUIVERDB_DISTANCE_COSINE: return HNSWDistanceMetric::COSINE;
        case QUIVERDB_DISTANCE_DOT: return HNSWDistanceMetric::DOT;
        default: return HNSWDistanceMetric::L2;
    }
}

QuiverDBError quiverdb_vector_store_create(size_t dimension, QuiverDBDistanceMetric metric, QuiverDBVectorStore* store) {
    try {
        auto vector_store = new VectorStore(dimension, convert_metric(metric));
        *store = vector_store;
        return QUIVERDB_OK;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_add(QuiverDBVectorStore store, uint64_t id, const float* vector) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        vector_store->add(id, vector);
        return QUIVERDB_OK;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_remove(QuiverDBVectorStore store, uint64_t id, int* removed) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        bool result = vector_store->remove(id);
        *removed = result ? 1 : 0;
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_get(QuiverDBVectorStore store, uint64_t id, float* vector, size_t vector_size) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        size_t dimension = vector_store->dimension();
        if (vector_size < dimension) {
            return QUIVERDB_INVALID_ARGUMENT;
        }
        
        const float* stored_vector = vector_store->get(id);
        if (!stored_vector) {
            return QUIVERDB_ID_NOT_FOUND;
        }
        
        std::memcpy(vector, stored_vector, dimension * sizeof(float));
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_update(QuiverDBVectorStore store, uint64_t id, const float* vector) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        bool result = vector_store->update(id, vector);
        if (!result) {
            return QUIVERDB_ID_NOT_FOUND;
        }
        return QUIVERDB_OK;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_search(QuiverDBVectorStore store, const float* query, size_t k, QuiverDBSearchResult* results, size_t results_size) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        
        if (results_size < k) {
            return QUIVERDB_INVALID_ARGUMENT;
        }
        
        auto search_results = vector_store->search(query, k);
        
        for (size_t i = 0; i < search_results.size(); ++i) {
            results[i].id = search_results[i].id;
            results[i].distance = search_results[i].distance;
        }
        
        return QUIVERDB_OK;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_size(QuiverDBVectorStore store, size_t* size) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        *size = vector_store->size();
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_dimension(QuiverDBVectorStore store, size_t* dimension) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        *dimension = vector_store->dimension();
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_metric(QuiverDBVectorStore store, QuiverDBDistanceMetric* metric) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        *metric = convert_metric_back(vector_store->metric());
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_contains(QuiverDBVectorStore store, uint64_t id, int* contains) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        bool result = vector_store->contains(id);
        *contains = result ? 1 : 0;
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_reserve(QuiverDBVectorStore store, size_t capacity) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        vector_store->reserve(capacity);
        return QUIVERDB_OK;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_vector_store_clear(QuiverDBVectorStore store) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        vector_store->clear();
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

void quiverdb_vector_store_destroy(QuiverDBVectorStore store) {
    auto vector_store = static_cast<VectorStore*>(store);
    delete vector_store;
}

// HNSWIndex implementation

QuiverDBError quiverdb_hnsw_index_create(size_t dimension, QuiverDBDistanceMetric metric, size_t max_elements, QuiverDBHNSWIndex* index) {
    try {
        auto hnsw_index = new HNSWIndex(dimension, convert_hnsw_metric(metric), max_elements);
        *index = hnsw_index;
        return QUIVERDB_OK;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_create_with_params(size_t dimension, QuiverDBDistanceMetric metric, size_t max_elements, size_t M, size_t ef_construction, uint32_t seed, QuiverDBHNSWIndex* index) {
    try {
        auto hnsw_index = new HNSWIndex(dimension, convert_hnsw_metric(metric), max_elements, M, ef_construction, seed);
        *index = hnsw_index;
        return QUIVERDB_OK;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_add(QuiverDBHNSWIndex index, uint64_t id, const float* vector) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        hnsw_index->add(id, vector);
        return QUIVERDB_OK;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (const std::runtime_error& e) {
        if (std::strstr(e.what(), "exists")) {
            return QUIVERDB_DUPLICATE_ID;
        } else if (std::strstr(e.what(), "full")) {
            return QUIVERDB_INDEX_FULL;
        }
        return QUIVERDB_ERROR;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_search(QuiverDBHNSWIndex index, const float* query, size_t k, QuiverDBSearchResult* results, size_t results_size) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        
        if (results_size < k) {
            return QUIVERDB_INVALID_ARGUMENT;
        }
        
        auto search_results = hnsw_index->search(query, k);
        
        for (size_t i = 0; i < search_results.size(); ++i) {
            results[i].id = search_results[i].id;
            results[i].distance = search_results[i].distance;
        }
        
        return QUIVERDB_OK;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_set_ef_search(QuiverDBHNSWIndex index, size_t ef_search) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        hnsw_index->set_ef_search(ef_search);
        return QUIVERDB_OK;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_get_ef_search(QuiverDBHNSWIndex index, size_t* ef_search) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        *ef_search = hnsw_index->get_ef_search();
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_size(QuiverDBHNSWIndex index, size_t* size) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        *size = hnsw_index->size();
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_dimension(QuiverDBHNSWIndex index, size_t* dimension) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        *dimension = hnsw_index->dimension();
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_capacity(QuiverDBHNSWIndex index, size_t* capacity) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        *capacity = hnsw_index->capacity();
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_contains(QuiverDBHNSWIndex index, uint64_t id, int* contains) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        bool result = hnsw_index->contains(id);
        *contains = result ? 1 : 0;
        return QUIVERDB_OK;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_get_vector(QuiverDBHNSWIndex index, uint64_t id, float* vector, size_t vector_size) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        size_t dimension = hnsw_index->dimension();
        
        if (vector_size < dimension) {
            return QUIVERDB_INVALID_ARGUMENT;
        }
        
        std::vector<float> stored_vector = hnsw_index->get_vector(id);
        std::memcpy(vector, stored_vector.data(), dimension * sizeof(float));
        
        return QUIVERDB_OK;
    } catch (const std::runtime_error& e) {
        if (std::strstr(e.what(), "not found")) {
            return QUIVERDB_ID_NOT_FOUND;
        }
        return QUIVERDB_ERROR;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_save(QuiverDBHNSWIndex index, const char* filename) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        hnsw_index->save(filename);
        return QUIVERDB_OK;
    } catch (const std::ios_base::failure&) {
        return QUIVERDB_FILE_ERROR;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

QuiverDBError quiverdb_hnsw_index_load(const char* filename, QuiverDBHNSWIndex* index) {
    try {
        auto hnsw_index = HNSWIndex::load(filename);
        *index = hnsw_index.release();
        return QUIVERDB_OK;
    } catch (const std::ios_base::failure&) {
        return QUIVERDB_FILE_ERROR;
    } catch (const std::invalid_argument&) {
        return QUIVERDB_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return QUIVERDB_OUT_OF_MEMORY;
    } catch (...) {
        return QUIVERDB_ERROR;
    }
}

void quiverdb_hnsw_index_destroy(QuiverDBHNSWIndex index) {
    auto hnsw_index = static_cast<HNSWIndex*>(index);
    delete hnsw_index;
}

// Version information

const char* quiverdb_version() {
    return VERSION_STRING;
}

int quiverdb_version_major() {
    return VERSION_MAJOR;
}

int quiverdb_version_minor() {
    return VERSION_MINOR;
}

int quiverdb_version_patch() {
    return VERSION_PATCH;
}
