//
//  LlamaMobileVD.mm
//  LlamaMobileVD
//
//  Created by LlamaMobile Team on 2025-01-09.
//

#import "LlamaMobileVD.h"
#include "quiverdb_wrapper.h"

// Error domain
static NSString *const LlamaMobileVDErrorDomain = @"com.llamamobile.vd.error";

// Convert error codes to NSError
static NSError *errorFromCode(QuiverDBError code, NSString *message) {
    return [NSError errorWithDomain:LlamaMobileVDErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: message ?: @"Unknown error"}];
}

// Convert distance metric between Objective-C and C
static QuiverDBDistanceMetric convertDistanceMetric(LlamaMobileVDDistanceMetric metric) {
    switch (metric) {
        case LlamaMobileVDDistanceMetricL2:
            return QUIVERDB_DISTANCE_L2;
        case LlamaMobileVDDistanceMetricCosine:
            return QUIVERDB_DISTANCE_COSINE;
        case LlamaMobileVDDistanceMetricDot:
            return QUIVERDB_DISTANCE_DOT;
        default:
            return QUIVERDB_DISTANCE_L2;
    }
}

static LlamaMobileVDDistanceMetric convertDistanceMetricBack(QuiverDBDistanceMetric metric) {
    switch (metric) {
        case QUIVERDB_DISTANCE_L2:
            return LlamaMobileVDDistanceMetricL2;
        case QUIVERDB_DISTANCE_COSINE:
            return LlamaMobileVDDistanceMetricCosine;
        case QUIVERDB_DISTANCE_DOT:
            return LlamaMobileVDDistanceMetricDot;
        default:
            return LlamaMobileVDDistanceMetricL2;
    }
}

// SearchResult implementation
@implementation LlamaMobileVDSearchResult
@end

// VectorStore implementation
@interface LlamaMobileVDVectorStore () {
    QuiverDBVectorStore _store;
    NSUInteger _dimension;
}
@end

@implementation LlamaMobileVDVectorStore

- (instancetype)initWithDimension:(NSUInteger)dimension metric:(LlamaMobileVDDistanceMetric)metric {
    self = [super init];
    if (self) {
        QuiverDBVectorStore store;
        QuiverDBError result = quiverdb_vector_store_create(dimension, convertDistanceMetric(metric), &store);
        if (result != QUIVERDB_OK) {
            NSError *error = errorFromCode(result, @"Failed to create vector store");
            NSLog(@"Error creating vector store: %@", error);
            return nil;
        }
        _store = store;
        _dimension = dimension;
    }
    return self;
}

- (void)dealloc {
    if (_store) {
        quiverdb_vector_store_destroy(_store);
    }
}

- (BOOL)addIdentifier:(uint64_t)identifier vector:(const float *)vector error:(NSError **)error {
    QuiverDBError result = quiverdb_vector_store_add(_store, identifier, vector);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to add vector");
        }
        return NO;
    }
    return YES;
}

- (BOOL)removeIdentifier:(uint64_t)identifier removed:(BOOL *)removed error:(NSError **)error {
    int removedInt = 0;
    QuiverDBError result = quiverdb_vector_store_remove(_store, identifier, &removedInt);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to remove vector");
        }
        return NO;
    }
    if (removed) {
        *removed = removedInt != 0;
    }
    return YES;
}

- (BOOL)getVectorForIdentifier:(uint64_t)identifier vector:(float *)vector vectorSize:(NSUInteger)vectorSize error:(NSError **)error {
    QuiverDBError result = quiverdb_vector_store_get(_store, identifier, vector, vectorSize);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get vector");
        }
        return NO;
    }
    return YES;
}

- (BOOL)updateIdentifier:(uint64_t)identifier vector:(const float *)vector error:(NSError **)error {
    QuiverDBError result = quiverdb_vector_store_update(_store, identifier, vector);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to update vector");
        }
        return NO;
    }
    return YES;
}

- (NSArray<LlamaMobileVDSearchResult *> *)searchVector:(const float *)query k:(NSUInteger)k error:(NSError **)error {
    NSMutableArray<LlamaMobileVDSearchResult *> *results = [NSMutableArray arrayWithCapacity:k];
    
    QuiverDBSearchResult *cResults = new QuiverDBSearchResult[k];
    if (!cResults) {
        if (error) {
            *error = errorFromCode(QUIVERDB_OUT_OF_MEMORY, @"Failed to allocate memory for search results");
        }
        return nil;
    }
    
    QuiverDBError result = quiverdb_vector_store_search(_store, query, k, cResults, k);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to search vectors");
        }
        delete[] cResults;
        return nil;
    }
    
    for (NSUInteger i = 0; i < k; i++) {
        LlamaMobileVDSearchResult *searchResult = [[LlamaMobileVDSearchResult alloc] init];
        searchResult.identifier = cResults[i].id;
        searchResult.distance = cResults[i].distance;
        [results addObject:searchResult];
    }
    
    delete[] cResults;
    return results;
}

- (NSUInteger)size:(NSError **)error {
    size_t size = 0;
    QuiverDBError result = quiverdb_vector_store_size(_store, &size);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get vector store size");
        }
        return 0;
    }
    return size;
}

- (NSUInteger)dimension:(NSError **)error {
    size_t dimension = 0;
    QuiverDBError result = quiverdb_vector_store_dimension(_store, &dimension);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get vector store dimension");
        }
        return 0;
    }
    return dimension;
}

- (LlamaMobileVDDistanceMetric)metric:(NSError **)error {
    QuiverDBDistanceMetric metric;
    QuiverDBError result = quiverdb_vector_store_metric(_store, &metric);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get vector store metric");
        }
        return LlamaMobileVDDistanceMetricL2;
    }
    return convertDistanceMetricBack(metric);
}

- (BOOL)containsIdentifier:(uint64_t)identifier contains:(BOOL *)contains error:(NSError **)error {
    int containsInt = 0;
    QuiverDBError result = quiverdb_vector_store_contains(_store, identifier, &containsInt);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to check if identifier exists in vector store");
        }
        return NO;
    }
    if (contains) {
        *contains = containsInt != 0;
    }
    return YES;
}

- (BOOL)reserveCapacity:(NSUInteger)capacity error:(NSError **)error {
    QuiverDBError result = quiverdb_vector_store_reserve(_store, capacity);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to reserve vector store capacity");
        }
        return NO;
    }
    return YES;
}

- (BOOL)clear:(NSError **)error {
    QuiverDBError result = quiverdb_vector_store_clear(_store);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to clear vector store");
        }
        return NO;
    }
    return YES;
}

@end

// HNSWIndex implementation
@interface LlamaMobileVDHNSWIndex () {
    QuiverDBHNSWIndex _index;
}
@end

@implementation LlamaMobileVDHNSWIndex

- (instancetype)initWithDimension:(NSUInteger)dimension metric:(LlamaMobileVDDistanceMetric)metric maxElements:(NSUInteger)maxElements {
    return [self initWithDimension:dimension metric:metric maxElements:maxElements M:16 efConstruction:200 seed:42];
}

- (instancetype)initWithDimension:(NSUInteger)dimension metric:(LlamaMobileVDDistanceMetric)metric maxElements:(NSUInteger)maxElements M:(NSUInteger)M efConstruction:(NSUInteger)efConstruction seed:(uint32_t)seed {
    self = [super init];
    if (self) {
        QuiverDBHNSWIndex index;
        QuiverDBError result = quiverdb_hnsw_index_create_with_params(
            dimension,
            convertDistanceMetric(metric),
            maxElements,
            M,
            efConstruction,
            seed,
            &index
        );
        if (result != QUIVERDB_OK) {
            NSError *error = errorFromCode(result, @"Failed to create HNSW index");
            NSLog(@"Error creating HNSW index: %@", error);
            return nil;
        }
        _index = index;
    }
    return self;
}

- (void)dealloc {
    if (_index) {
        quiverdb_hnsw_index_destroy(_index);
    }
}

- (BOOL)addIdentifier:(uint64_t)identifier vector:(const float *)vector error:(NSError **)error {
    QuiverDBError result = quiverdb_hnsw_index_add(_index, identifier, vector);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to add vector to HNSW index");
        }
        return NO;
    }
    return YES;
}

- (NSArray<LlamaMobileVDSearchResult *> *)searchVector:(const float *)query k:(NSUInteger)k error:(NSError **)error {
    NSMutableArray<LlamaMobileVDSearchResult *> *results = [NSMutableArray arrayWithCapacity:k];
    
    QuiverDBSearchResult *cResults = new QuiverDBSearchResult[k];
    if (!cResults) {
        if (error) {
            *error = errorFromCode(QUIVERDB_OUT_OF_MEMORY, @"Failed to allocate memory for search results");
        }
        return nil;
    }
    
    QuiverDBError result = quiverdb_hnsw_index_search(_index, query, k, cResults, k);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to search HNSW index");
        }
        delete[] cResults;
        return nil;
    }
    
    for (NSUInteger i = 0; i < k; i++) {
        LlamaMobileVDSearchResult *searchResult = [[LlamaMobileVDSearchResult alloc] init];
        searchResult.identifier = cResults[i].id;
        searchResult.distance = cResults[i].distance;
        [results addObject:searchResult];
    }
    
    delete[] cResults;
    return results;
}

- (BOOL)setEfSearch:(NSUInteger)efSearch error:(NSError **)error {
    QuiverDBError result = quiverdb_hnsw_index_set_ef_search(_index, efSearch);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to set efSearch for HNSW index");
        }
        return NO;
    }
    return YES;
}

- (NSUInteger)efSearch:(NSError **)error {
    size_t efSearch;
    QuiverDBError result = quiverdb_hnsw_index_get_ef_search(_index, &efSearch);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get efSearch from HNSW index");
        }
        return 0;
    }
    return efSearch;
}

- (NSUInteger)size:(NSError **)error {
    size_t size;
    QuiverDBError result = quiverdb_hnsw_index_size(_index, &size);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get HNSW index size");
        }
        return 0;
    }
    return size;
}

- (NSUInteger)dimension:(NSError **)error {
    size_t dimension;
    QuiverDBError result = quiverdb_hnsw_index_dimension(_index, &dimension);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get HNSW index dimension");
        }
        return 0;
    }
    return dimension;
}

- (NSUInteger)capacity:(NSError **)error {
    size_t capacity;
    QuiverDBError result = quiverdb_hnsw_index_capacity(_index, &capacity);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get HNSW index capacity");
        }
        return 0;
    }
    return capacity;
}

- (BOOL)containsIdentifier:(uint64_t)identifier contains:(BOOL *)contains error:(NSError **)error {
    int containsInt = 0;
    QuiverDBError result = quiverdb_hnsw_index_contains(_index, identifier, &containsInt);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to check if identifier exists in HNSW index");
        }
        return NO;
    }
    if (contains) {
        *contains = containsInt != 0;
    }
    return YES;
}

- (BOOL)getVectorForIdentifier:(uint64_t)identifier vector:(float *)vector vectorSize:(NSUInteger)vectorSize error:(NSError **)error {
    QuiverDBError result = quiverdb_hnsw_index_get_vector(_index, identifier, vector, vectorSize);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get vector from HNSW index");
        }
        return NO;
    }
    return YES;
}

- (BOOL)saveToFile:(NSString *)filename error:(NSError **)error {
    const char *cFilename = [filename UTF8String];
    QuiverDBError result = quiverdb_hnsw_index_save(_index, cFilename);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to save HNSW index to file");
        }
        return NO;
    }
    return YES;
}

+ (nullable instancetype)loadFromFile:(NSString *)filename error:(NSError **)error {
    LlamaMobileVDHNSWIndex *index = [[LlamaMobileVDHNSWIndex alloc] init];
    if (index) {
        const char *cFilename = [filename UTF8String];
        QuiverDBHNSWIndex hnswIndex;
        QuiverDBError result = quiverdb_hnsw_index_load(cFilename, &hnswIndex);
        if (result != QUIVERDB_OK) {
            if (error) {
                *error = errorFromCode(result, [NSString stringWithFormat:@"Failed to load HNSW index from file: %@", filename]);
            }
            return nil;
        }
        index->_index = hnswIndex;
    }
    return index;
}

@end

// MMapVectorStoreBuilder implementation
@interface LlamaMobileVDMMapVectorStoreBuilder () {
    QuiverDBMMapVectorStoreBuilder _builder;
    NSUInteger _dimension;
}
@end

@implementation LlamaMobileVDMMapVectorStoreBuilder

- (instancetype)initWithDimension:(NSUInteger)dimension metric:(LlamaMobileVDDistanceMetric)metric {
    self = [super init];
    if (self) {
        QuiverDBMMapVectorStoreBuilder builder;
        QuiverDBError result = quiverdb_mmap_vector_store_builder_create(dimension, convertDistanceMetric(metric), &builder);
        if (result != QUIVERDB_OK) {
            NSError *error = errorFromCode(result, @"Failed to create MMap vector store builder");
            NSLog(@"Error creating MMap vector store builder: %@", error);
            return nil;
        }
        _builder = builder;
        _dimension = dimension;
    }
    return self;
}

- (void)dealloc {
    if (_builder) {
        quiverdb_mmap_vector_store_builder_destroy(_builder);
    }
}

- (BOOL)addIdentifier:(uint64_t)identifier vector:(const float *)vector error:(NSError **)error {
    QuiverDBError result = quiverdb_mmap_vector_store_builder_add(_builder, identifier, vector);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to add vector to MMap vector store builder");
        }
        return NO;
    }
    return YES;
}

- (BOOL)reserveCapacity:(NSUInteger)capacity error:(NSError **)error {
    QuiverDBError result = quiverdb_mmap_vector_store_builder_reserve(_builder, capacity);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to reserve capacity in MMap vector store builder");
        }
        return NO;
    }
    return YES;
}

- (BOOL)saveToFile:(NSString *)filename error:(NSError **)error {
    const char *cFilename = [filename UTF8String];
    QuiverDBError result = quiverdb_mmap_vector_store_builder_save(_builder, cFilename);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to save MMap vector store to file");
        }
        return NO;
    }
    return YES;
}

- (NSUInteger)size:(NSError **)error {
    size_t size = 0;
    QuiverDBError result = quiverdb_mmap_vector_store_builder_size(_builder, &size);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get size of MMap vector store builder");
        }
        return 0;
    }
    return size;
}

- (NSUInteger)dimension:(NSError **)error {
    size_t dimension = 0;
    QuiverDBError result = quiverdb_mmap_vector_store_builder_dimension(_builder, &dimension);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get dimension of MMap vector store builder");
        }
        return 0;
    }
    return dimension;
}

@end

// MMapVectorStore implementation
@interface LlamaMobileVDMMapVectorStore () {
    QuiverDBMMapVectorStore _store;
}
@end

@implementation LlamaMobileVDMMapVectorStore

+ (nullable instancetype)openFromFile:(NSString *)filename error:(NSError **)error {
    LlamaMobileVDMMapVectorStore *store = [[LlamaMobileVDMMapVectorStore alloc] init];
    if (store) {
        const char *cFilename = [filename UTF8String];
        QuiverDBMMapVectorStore mmapStore;
        QuiverDBError result = quiverdb_mmap_vector_store_open(cFilename, &mmapStore);
        if (result != QUIVERDB_OK) {
            if (error) {
                *error = errorFromCode(result, [NSString stringWithFormat:@"Failed to open MMap vector store from file: %@", filename]);
            }
            return nil;
        }
        store->_store = mmapStore;
    }
    return store;
}

- (void)dealloc {
    if (_store) {
        quiverdb_mmap_vector_store_close(_store);
    }
}

- (BOOL)getVectorForIdentifier:(uint64_t)identifier vector:(float *)vector vectorSize:(NSUInteger)vectorSize error:(NSError **)error {
    QuiverDBError result = quiverdb_mmap_vector_store_get(_store, identifier, vector, vectorSize);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get vector from MMap vector store");
        }
        return NO;
    }
    return YES;
}

- (BOOL)containsIdentifier:(uint64_t)identifier contains:(BOOL *)contains error:(NSError **)error {
    int containsInt = 0;
    QuiverDBError result = quiverdb_mmap_vector_store_contains(_store, identifier, &containsInt);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to check if vector exists in MMap vector store");
        }
        return NO;
    }
    if (contains) {
        *contains = containsInt != 0;
    }
    return YES;
}

- (NSArray<LlamaMobileVDSearchResult *> *)searchVector:(const float *)query k:(NSUInteger)k error:(NSError **)error {
    NSMutableArray<LlamaMobileVDSearchResult *> *results = [NSMutableArray arrayWithCapacity:k];
    
    QuiverDBSearchResult *cResults = new QuiverDBSearchResult[k];
    if (!cResults) {
        if (error) {
            *error = errorFromCode(QUIVERDB_OUT_OF_MEMORY, @"Failed to allocate memory for search results");
        }
        return nil;
    }
    
    QuiverDBError result = quiverdb_mmap_vector_store_search(_store, query, k, cResults, k);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to search vectors in MMap vector store");
        }
        delete[] cResults;
        return nil;
    }
    
    for (NSUInteger i = 0; i < k; i++) {
        LlamaMobileVDSearchResult *searchResult = [[LlamaMobileVDSearchResult alloc] init];
        searchResult.identifier = cResults[i].id;
        searchResult.distance = cResults[i].distance;
        [results addObject:searchResult];
    }
    
    delete[] cResults;
    return results;
}

- (NSUInteger)size:(NSError **)error {
    size_t size = 0;
    QuiverDBError result = quiverdb_mmap_vector_store_size(_store, &size);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get size of MMap vector store");
        }
        return 0;
    }
    return size;
}

- (NSUInteger)dimension:(NSError **)error {
    size_t dimension = 0;
    QuiverDBError result = quiverdb_mmap_vector_store_dimension(_store, &dimension);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get dimension of MMap vector store");
        }
        return 0;
    }
    return dimension;
}

- (LlamaMobileVDDistanceMetric)metric:(NSError **)error {
    QuiverDBDistanceMetric metric;
    QuiverDBError result = quiverdb_mmap_vector_store_metric(_store, &metric);
    if (result != QUIVERDB_OK) {
        if (error) {
            *error = errorFromCode(result, @"Failed to get metric of MMap vector store");
        }
        return LlamaMobileVDDistanceMetricL2;
    }
    return convertDistanceMetricBack(metric);
}

@end

// Version information implementation
@implementation LlamaMobileVD

+ (NSString *)version {
    return [NSString stringWithUTF8String:quiverdb_version()];
}

+ (NSInteger)versionMajor {
    return quiverdb_version_major();
}

+ (NSInteger)versionMinor {
    return quiverdb_version_minor();
}

+ (NSInteger)versionPatch {
    return quiverdb_version_patch();
}

@end