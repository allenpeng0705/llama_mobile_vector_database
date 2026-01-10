#ifndef Bridging_Header_h
#define Bridging_Header_h

// Import the LlamaMobileVD Objective-C framework
extern void *LlamaMobileVDVectorStoreCreate(int32_t dimension, LlamaMobileVDDistanceMetric metric, NSError **error);
extern void LlamaMobileVDVectorStoreDestroy(void *store);
extern BOOL LlamaMobileVDVectorStoreAddVector(void *store, const float *vector, int32_t vectorSize, int32_t id, NSError **error);
extern BOOL LlamaMobileVDVectorStoreSearch(void *store, const float *queryVector, int32_t vectorSize, int32_t k, void **results, int32_t *resultCount, NSError **error);
extern void LlamaMobileVDVectorStoreFreeSearchResults(void *results);
extern int32_t LlamaMobileVDVectorStoreGetCount(void *store);
extern BOOL LlamaMobileVDVectorStoreClear(void *store, NSError **error);

extern void *LlamaMobileVDHNSWIndexCreate(int32_t dimension, LlamaMobileVDDistanceMetric metric, int32_t m, int32_t efConstruction, NSError **error);
extern void LlamaMobileVDHNSWIndexDestroy(void *index);
extern BOOL LlamaMobileVDHNSWIndexAddVector(void *index, const float *vector, int32_t vectorSize, int32_t id, NSError **error);
extern BOOL LlamaMobileVDHNSWIndexSearch(void *index, const float *queryVector, int32_t vectorSize, int32_t k, int32_t efSearch, void **results, int32_t *resultCount, NSError **error);
extern void LlamaMobileVDHNSWIndexFreeSearchResults(void *results);
extern int32_t LlamaMobileVDHNSWIndexGetCount(void *index);
extern BOOL LlamaMobileVDHNSWIndexClear(void *index, NSError **error);

typedef enum {
    LlamaMobileVDDistanceMetricL2 = 0,
    LlamaMobileVDDistanceMetricCosine = 1,
    LlamaMobileVDDistanceMetricDot = 2
} LlamaMobileVDDistanceMetric;

typedef struct {
    int32_t id;
    float distance;
} LlamaMobileVDSearchResult;

#endif /* Bridging_Header_h */
