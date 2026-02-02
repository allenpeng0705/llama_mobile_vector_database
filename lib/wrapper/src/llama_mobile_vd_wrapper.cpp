// QuiverDB Wrapper - Copyright (c) 2025 - MIT License
#include "llama_mobile_vd_wrapper.h"
#include "llama_mobile_vd_version.h"
#include "core/vector_store.h"
#include "core/hnsw_index.h"
#include "core/mmap_vector_store.h"

#include <cstring>
#include <stdexcept>
#include <memory>

using namespace quiverdb;

// VectorStore implementation

static DistanceMetric convert_metric(LLAMA_MOBILE_VD_DistanceMetric metric) {
    switch (metric) {
        case LLAMA_MOBILE_VD_DISTANCE_L2: return DistanceMetric::L2;
        case LLAMA_MOBILE_VD_DISTANCE_COSINE: return DistanceMetric::COSINE;
        case LLAMA_MOBILE_VD_DISTANCE_DOT: return DistanceMetric::DOT;
        default: throw std::invalid_argument("Invalid distance metric");
    }
}

static LLAMA_MOBILE_VD_DistanceMetric convert_metric_back(DistanceMetric metric) {
    switch (metric) {
        case DistanceMetric::L2: return LLAMA_MOBILE_VD_DISTANCE_L2;
        case DistanceMetric::COSINE: return LLAMA_MOBILE_VD_DISTANCE_COSINE;
        case DistanceMetric::DOT: return LLAMA_MOBILE_VD_DISTANCE_DOT;
        default: return LLAMA_MOBILE_VD_DISTANCE_L2;
    }
}

static HNSWDistanceMetric convert_hnsw_metric(LLAMA_MOBILE_VD_DistanceMetric metric) {
    switch (metric) {
        case LLAMA_MOBILE_VD_DISTANCE_L2: return HNSWDistanceMetric::L2;
        case LLAMA_MOBILE_VD_DISTANCE_COSINE: return HNSWDistanceMetric::COSINE;
        case LLAMA_MOBILE_VD_DISTANCE_DOT: return HNSWDistanceMetric::DOT;
        default: return HNSWDistanceMetric::L2;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_create(size_t dimension, LLAMA_MOBILE_VD_DistanceMetric metric, LLAMA_MOBILE_VD_VectorStore* store) {
    try {
        auto vector_store = new VectorStore(dimension, convert_metric(metric));
        *store = vector_store;
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_add(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, const float* vector) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        vector_store->add(id, vector);
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument& e) {
        std::string msg = e.what();
        if (msg.find("exists") != std::string::npos || msg.find("duplicate") != std::string::npos) {
            return LLAMA_MOBILE_VD_DUPLICATE_ID;
        }
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_remove(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, int* removed) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        bool result = vector_store->remove(id);
        *removed = result ? 1 : 0;
        if (!result) {
            return LLAMA_MOBILE_VD_ID_NOT_FOUND;
        }
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_get(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, float* vector, size_t vector_size) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        size_t dimension = vector_store->dimension();
        if (vector_size < dimension) {
            return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
        }
        
        const float* stored_vector = vector_store->get(id);
        if (!stored_vector) {
            return LLAMA_MOBILE_VD_ID_NOT_FOUND;
        }
        
        std::memcpy(vector, stored_vector, dimension * sizeof(float));
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_update(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, const float* vector) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        bool result = vector_store->update(id, vector);
        if (!result) {
            return LLAMA_MOBILE_VD_ID_NOT_FOUND;
        }
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_search(LLAMA_MOBILE_VD_VectorStore store, const float* query, size_t k, LLAMA_MOBILE_VD_SearchResult* results, size_t results_size) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        
        if (results_size < k) {
            return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
        }
        
        auto search_results = vector_store->search(query, k);
        
        for (size_t i = 0; i < search_results.size(); ++i) {
            results[i].id = search_results[i].id;
            results[i].distance = search_results[i].distance;
        }
        
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_size(LLAMA_MOBILE_VD_VectorStore store, size_t* size) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        *size = vector_store->size();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_dimension(LLAMA_MOBILE_VD_VectorStore store, size_t* dimension) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        *dimension = vector_store->dimension();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_metric(LLAMA_MOBILE_VD_VectorStore store, LLAMA_MOBILE_VD_DistanceMetric* metric) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        *metric = convert_metric_back(vector_store->metric());
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_contains(LLAMA_MOBILE_VD_VectorStore store, uint64_t id, int* contains) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        bool result = vector_store->contains(id);
        *contains = result ? 1 : 0;
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_reserve(LLAMA_MOBILE_VD_VectorStore store, size_t capacity) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        vector_store->reserve(capacity);
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_vector_store_clear(LLAMA_MOBILE_VD_VectorStore store) {
    try {
        auto vector_store = static_cast<VectorStore*>(store);
        vector_store->clear();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

void llama_mobile_vd_vector_store_destroy(LLAMA_MOBILE_VD_VectorStore store) {
    auto vector_store = static_cast<VectorStore*>(store);
    delete vector_store;
}

// HNSWIndex implementation

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_create(size_t dimension, LLAMA_MOBILE_VD_DistanceMetric metric, size_t max_elements, LLAMA_MOBILE_VD_HNSWIndex* index) {
    try {
        auto hnsw_index = new HNSWIndex(dimension, convert_hnsw_metric(metric), max_elements);
        *index = hnsw_index;
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_create_with_params(size_t dimension, LLAMA_MOBILE_VD_DistanceMetric metric, size_t max_elements, size_t M, size_t ef_construction, uint32_t seed, LLAMA_MOBILE_VD_HNSWIndex* index) {
    try {
        auto hnsw_index = new HNSWIndex(dimension, convert_hnsw_metric(metric), max_elements, M, ef_construction, seed);
        *index = hnsw_index;
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_add(LLAMA_MOBILE_VD_HNSWIndex index, uint64_t id, const float* vector) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        hnsw_index->add(id, vector);
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::runtime_error& e) {
        if (std::strstr(e.what(), "exists")) {
            return LLAMA_MOBILE_VD_DUPLICATE_ID;
        } else if (std::strstr(e.what(), "full")) {
            return LLAMA_MOBILE_VD_INDEX_FULL;
        }
        return LLAMA_MOBILE_VD_ERROR;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_search(LLAMA_MOBILE_VD_HNSWIndex index, const float* query, size_t k, LLAMA_MOBILE_VD_SearchResult* results, size_t results_size) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        
        if (results_size < k) {
            return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
        }
        
        auto search_results = hnsw_index->search(query, k);
        
        for (size_t i = 0; i < search_results.size(); ++i) {
            results[i].id = search_results[i].id;
            results[i].distance = search_results[i].distance;
        }
        
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_set_ef_search(LLAMA_MOBILE_VD_HNSWIndex index, size_t ef_search) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        hnsw_index->set_ef_search(ef_search);
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_get_ef_search(LLAMA_MOBILE_VD_HNSWIndex index, size_t* ef_search) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        *ef_search = hnsw_index->get_ef_search();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_size(LLAMA_MOBILE_VD_HNSWIndex index, size_t* size) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        *size = hnsw_index->size();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_dimension(LLAMA_MOBILE_VD_HNSWIndex index, size_t* dimension) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        *dimension = hnsw_index->dimension();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_capacity(LLAMA_MOBILE_VD_HNSWIndex index, size_t* capacity) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        *capacity = hnsw_index->capacity();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_contains(LLAMA_MOBILE_VD_HNSWIndex index, uint64_t id, int* contains) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        bool result = hnsw_index->contains(id);
        *contains = result ? 1 : 0;
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_get_vector(LLAMA_MOBILE_VD_HNSWIndex index, uint64_t id, float* vector, size_t vector_size) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        size_t dimension = hnsw_index->dimension();
        
        if (vector_size < dimension) {
            return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
        }
        
        std::vector<float> stored_vector = hnsw_index->get_vector(id);
        std::memcpy(vector, stored_vector.data(), dimension * sizeof(float));
        
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::runtime_error& e) {
        if (std::strstr(e.what(), "not found")) {
            return LLAMA_MOBILE_VD_ID_NOT_FOUND;
        }
        return LLAMA_MOBILE_VD_ERROR;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_save(LLAMA_MOBILE_VD_HNSWIndex index, const char* filename) {
    try {
        auto hnsw_index = static_cast<HNSWIndex*>(index);
        hnsw_index->save(filename);
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::ios_base::failure&) {
        return LLAMA_MOBILE_VD_FILE_ERROR;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_hnsw_index_load(const char* filename, LLAMA_MOBILE_VD_HNSWIndex* index) {
    try {
        auto hnsw_index = HNSWIndex::load(filename);
        *index = hnsw_index.release();
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::ios_base::failure&) {
        return LLAMA_MOBILE_VD_FILE_ERROR;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

void llama_mobile_vd_hnsw_index_destroy(LLAMA_MOBILE_VD_HNSWIndex index) {
    auto hnsw_index = static_cast<HNSWIndex*>(index);
    delete hnsw_index;
}

// MMapVectorStoreBuilder implementation

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_create(size_t dimension, LLAMA_MOBILE_VD_DistanceMetric metric, LLAMA_MOBILE_VD_MMapVectorStoreBuilder* builder) {
    try {
        auto mmap_builder = new MMapVectorStoreBuilder(dimension, convert_metric(metric));
        *builder = mmap_builder;
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_add(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, uint64_t id, const float* vector) {
    try {
        auto mmap_builder = static_cast<MMapVectorStoreBuilder*>(builder);
        mmap_builder->add(id, vector);
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument& e) {
        if (std::strstr(e.what(), "Duplicate ID")) {
            return LLAMA_MOBILE_VD_DUPLICATE_ID;
        }
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_reserve(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, size_t capacity) {
    try {
        auto mmap_builder = static_cast<MMapVectorStoreBuilder*>(builder);
        mmap_builder->reserve(capacity);
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_save(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, const char* filename) {
    try {
        auto mmap_builder = static_cast<MMapVectorStoreBuilder*>(builder);
        mmap_builder->save(filename);
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::ios_base::failure&) {
        return LLAMA_MOBILE_VD_FILE_ERROR;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_size(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, size_t* size) {
    try {
        auto mmap_builder = static_cast<MMapVectorStoreBuilder*>(builder);
        *size = mmap_builder->size();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_builder_dimension(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder, size_t* dimension) {
    try {
        auto mmap_builder = static_cast<MMapVectorStoreBuilder*>(builder);
        *dimension = mmap_builder->dimension();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

void llama_mobile_vd_mmap_vector_store_builder_destroy(LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder) {
    auto mmap_builder = static_cast<MMapVectorStoreBuilder*>(builder);
    delete mmap_builder;
}

// MMapVectorStore implementation

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_open(const char* filename, LLAMA_MOBILE_VD_MMapVectorStore* store) {
    try {
        auto mmap_store = new MMapVectorStore(filename);
        *store = mmap_store;
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::ios_base::failure&) {
        return LLAMA_MOBILE_VD_FILE_ERROR;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_get(LLAMA_MOBILE_VD_MMapVectorStore store, uint64_t id, float* vector, size_t vector_size) {
    try {
        auto mmap_store = static_cast<MMapVectorStore*>(store);
        size_t dimension = mmap_store->dimension();
        
        if (vector_size < dimension) {
            return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
        }
        
        const float* stored_vector = mmap_store->get(id);
        if (!stored_vector) {
            return LLAMA_MOBILE_VD_ID_NOT_FOUND;
        }
        
        std::memcpy(vector, stored_vector, dimension * sizeof(float));
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_contains(LLAMA_MOBILE_VD_MMapVectorStore store, uint64_t id, int* contains) {
    try {
        auto mmap_store = static_cast<MMapVectorStore*>(store);
        bool result = mmap_store->contains(id);
        *contains = result ? 1 : 0;
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_search(LLAMA_MOBILE_VD_MMapVectorStore store, const float* query, size_t k, LLAMA_MOBILE_VD_SearchResult* results, size_t results_size) {
    try {
        auto mmap_store = static_cast<MMapVectorStore*>(store);
        
        if (results_size < k) {
            return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
        }
        
        auto search_results = mmap_store->search(query, k);
        
        for (size_t i = 0; i < search_results.size(); ++i) {
            results[i].id = search_results[i].id;
            results[i].distance = search_results[i].distance;
        }
        
        return LLAMA_MOBILE_VD_OK;
    } catch (const std::invalid_argument&) {
        return LLAMA_MOBILE_VD_INVALID_ARGUMENT;
    } catch (const std::bad_alloc&) {
        return LLAMA_MOBILE_VD_OUT_OF_MEMORY;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_size(LLAMA_MOBILE_VD_MMapVectorStore store, size_t* size) {
    try {
        auto mmap_store = static_cast<MMapVectorStore*>(store);
        *size = mmap_store->size();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_dimension(LLAMA_MOBILE_VD_MMapVectorStore store, size_t* dimension) {
    try {
        auto mmap_store = static_cast<MMapVectorStore*>(store);
        *dimension = mmap_store->dimension();
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

LLAMA_MOBILE_VD_Error llama_mobile_vd_mmap_vector_store_metric(LLAMA_MOBILE_VD_MMapVectorStore store, LLAMA_MOBILE_VD_DistanceMetric* metric) {
    try {
        auto mmap_store = static_cast<MMapVectorStore*>(store);
        *metric = convert_metric_back(mmap_store->metric());
        return LLAMA_MOBILE_VD_OK;
    } catch (...) {
        return LLAMA_MOBILE_VD_ERROR;
    }
}

void llama_mobile_vd_mmap_vector_store_close(LLAMA_MOBILE_VD_MMapVectorStore store) {
    auto mmap_store = static_cast<MMapVectorStore*>(store);
    delete mmap_store;
}

// Version information

const char* llama_mobile_vd_version() {
    return LLAMA_MOBILE_VD_VERSION_STRING;
}

int llama_mobile_vd_version_major() {
    return LLAMA_MOBILE_VD_VERSION_MAJOR;
}

int llama_mobile_vd_version_minor() {
    return LLAMA_MOBILE_VD_VERSION_MINOR;
}

int llama_mobile_vd_version_patch() {
    return LLAMA_MOBILE_VD_VERSION_PATCH;
}
