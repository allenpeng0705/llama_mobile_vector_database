#include <jni.h>
#include <string.h>
#include <android/log.h>

#include "llama_mobile_vd_wrapper.h"

#define TAG "LlamaMobileVD"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

// VectorStore JNI methods
extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreCreate(
        JNIEnv *env,
        jobject thiz,
        jint dimension,
        jint metric) {
    LLAMA_MOBILE_VD_VectorStore store = nullptr;
    int error = llama_mobile_vd_vector_store_create(static_cast<size_t>(dimension), (LLAMA_MOBILE_VD_DistanceMetric)metric, &store);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to create vector store: %d", error);
        return 0;
    }
    return (jlong)(intptr_t)store;
}

extern "C" JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreAddVector(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jlong id,
        jfloatArray vector) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return;
    }

    jfloat* vectorPtr = env->GetFloatArrayElements(vector, nullptr);
    jsize vectorLength = env->GetArrayLength(vector);

    int error = llama_mobile_vd_vector_store_add(store, (uint64_t)id, vectorPtr);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to add vector: %d", error);
    }

    env->ReleaseFloatArrayElements(vector, vectorPtr, 0);
}

extern "C" JNIEXPORT jobjectArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreSearch(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jfloatArray queryVector,
        jint k) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return nullptr;
    }

    jfloat* queryVectorPtr = env->GetFloatArrayElements(queryVector, nullptr);
    jsize queryVectorLength = env->GetArrayLength(queryVector);

    size_t k_size = static_cast<size_t>(k);
    LLAMA_MOBILE_VD_SearchResult* results = new LLAMA_MOBILE_VD_SearchResult[k_size];
    int error = llama_mobile_vd_vector_store_search(store, queryVectorPtr, k_size, results, k_size);

    env->ReleaseFloatArrayElements(queryVector, queryVectorPtr, 0);

    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to search vector store: %d", error);
        delete[] results;
        return nullptr;
    }

    // Create SearchResult objects
    jclass searchResultClass = env->FindClass("com/llamamobile/vd/SearchResult");
    if (!searchResultClass) {
        LOGE("Failed to find SearchResult class");
        delete[] results;
        return nullptr;
    }

    jmethodID searchResultConstructor = env->GetMethodID(searchResultClass, "<init>", "(JF)V");
    if (!searchResultConstructor) {
        LOGE("Failed to find SearchResult constructor");
        delete[] results;
        return nullptr;
    }

    jobjectArray resultArray = env->NewObjectArray(k, searchResultClass, nullptr);
    if (!resultArray) {
        LOGE("Failed to create result array");
        delete[] results;
        return nullptr;
    }

    for (int i = 0; i < k; i++) {
        jobject searchResult = env->NewObject(searchResultClass, searchResultConstructor, (jlong)results[i].id, results[i].distance);
        if (searchResult) {
            env->SetObjectArrayElement(resultArray, i, searchResult);
            env->DeleteLocalRef(searchResult);
        }
    }

    delete[] results;
    return resultArray;
}

extern "C" JNIEXPORT jfloatArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetVector(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jlong id) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return nullptr;
    }

    size_t dimension = 0;
    int error = llama_mobile_vd_vector_store_dimension(store, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get vector dimension: %d", error);
        return nullptr;
    }

    float* vector = new float[dimension];
    error = llama_mobile_vd_vector_store_get(store, (uint64_t)id, vector, dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get vector: %d", error);
        delete[] vector;
        return nullptr;
    }

    jfloatArray result = env->NewFloatArray(dimension);
    env->SetFloatArrayRegion(result, 0, dimension, vector);

    delete[] vector;
    return result;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreRemoveVector(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jlong id) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return false;
    }

    int removed = 0;
    int error = llama_mobile_vd_vector_store_remove(store, (uint64_t)id, &removed);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to remove vector: %d", error);
        return false;
    }

    return removed != 0;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreContains(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jlong id) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return false;
    }

    int contains = 0;
    int error = llama_mobile_vd_vector_store_contains(store, (uint64_t)id, &contains);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to check if vector exists: %d", error);
        return false;
    }

    return contains != 0;
}

extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetSize(
        JNIEnv *env,
        jobject thiz,
        jlong storeId) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return 0;
    }

    size_t size = 0;
    int error = llama_mobile_vd_vector_store_size(store, &size);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get vector store size: %d", error);
        return 0;
    }

    return size;
}

extern "C" JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetDimension(
        JNIEnv *env,
        jobject thiz,
        jlong storeId) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return 0;
    }

    size_t dimension = 0;
    int error = llama_mobile_vd_vector_store_dimension(store, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get vector dimension: %d", error);
        return 0;
    }

    return dimension;
}

extern "C" JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetMetric(
        JNIEnv *env,
        jobject thiz,
        jlong storeId) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return 0;
    }

    LLAMA_MOBILE_VD_DistanceMetric metric = LLAMA_MOBILE_VD_DISTANCE_L2;
    int error = llama_mobile_vd_vector_store_metric(store, &metric);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get vector metric: %d", error);
        return 0;
    }

    return metric;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreUpdateVector(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jlong id,
        jfloatArray vector) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return false;
    }

    jfloat* vectorPtr = env->GetFloatArrayElements(vector, nullptr);
    jsize vectorLength = env->GetArrayLength(vector);

    int error = llama_mobile_vd_vector_store_update(store, (uint64_t)id, vectorPtr);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to update vector: %d", error);
        env->ReleaseFloatArrayElements(vector, vectorPtr, 0);
        return false;
    }

    env->ReleaseFloatArrayElements(vector, vectorPtr, 0);
    return true;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreReserve(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jlong capacity) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return false;
    }

    int error = llama_mobile_vd_vector_store_reserve(store, static_cast<size_t>(capacity));
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to reserve vector store capacity: %d", error);
        return false;
    }

    return true;
}

extern "C" JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreClear(
        JNIEnv *env,
        jobject thiz,
        jlong storeId) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return;
    }

    int error = llama_mobile_vd_vector_store_clear(store);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to clear vector store: %d", error);
    }
}

extern "C" JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreDestroy(
        JNIEnv *env,
        jobject thiz,
        jlong storeId) {
    LLAMA_MOBILE_VD_VectorStore store = (LLAMA_MOBILE_VD_VectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid vector store");
        return;
    }

    llama_mobile_vd_vector_store_destroy(store);
}

// HNSWIndex JNI methods
extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCreate(
        JNIEnv *env,
        jobject thiz,
        jint dimension,
        jint metric,
        jlong maxElements) {
    LLAMA_MOBILE_VD_HNSWIndex index = nullptr;
    int error = llama_mobile_vd_hnsw_index_create(static_cast<size_t>(dimension), (LLAMA_MOBILE_VD_DistanceMetric)metric, static_cast<size_t>(maxElements), &index);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to create HNSW index: %d", error);
        return 0;
    }
    return (jlong)(intptr_t)index;
}

extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCreateWithParams(
        JNIEnv *env,
        jobject thiz,
        jint dimension,
        jint metric,
        jlong maxElements,
        jint M,
        jint efConstruction,
        jint seed) {
    LLAMA_MOBILE_VD_HNSWIndex index = nullptr;
    int error = llama_mobile_vd_hnsw_index_create_with_params(
        static_cast<size_t>(dimension), 
        static_cast<LLAMA_MOBILE_VD_DistanceMetric>(metric), 
        static_cast<size_t>(maxElements), 
        static_cast<size_t>(M), 
        static_cast<size_t>(efConstruction), 
        static_cast<uint32_t>(seed), 
        &index);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to create HNSW index with params: %d", error);
        return 0;
    }
    return (jlong)(intptr_t)index;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexAddVector(
        JNIEnv *env,
        jobject thiz,
        jlong indexId,
        jlong id,
        jfloatArray vector) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return false;
    }

    jfloat* vectorPtr = env->GetFloatArrayElements(vector, nullptr);
    jsize vectorLength = env->GetArrayLength(vector);

    int error = llama_mobile_vd_hnsw_index_add(index, (uint64_t)id, vectorPtr);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to add vector to HNSW index: %d", error);
        env->ReleaseFloatArrayElements(vector, vectorPtr, 0);
        return false;
    }

    env->ReleaseFloatArrayElements(vector, vectorPtr, 0);
    return true;
}

extern "C" JNIEXPORT jobjectArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSearch(
        JNIEnv *env,
        jobject thiz,
        jlong indexId,
        jfloatArray queryVector,
        jint k) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return nullptr;
    }

    jfloat* queryVectorPtr = env->GetFloatArrayElements(queryVector, nullptr);
    jsize queryVectorLength = env->GetArrayLength(queryVector);

    size_t k_size = static_cast<size_t>(k);
    LLAMA_MOBILE_VD_SearchResult* results = new LLAMA_MOBILE_VD_SearchResult[k_size];
    int error = llama_mobile_vd_hnsw_index_search(index, queryVectorPtr, k_size, results, k_size);

    env->ReleaseFloatArrayElements(queryVector, queryVectorPtr, 0);

    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to search HNSW index: %d", error);
        delete[] results;
        return nullptr;
    }

    // Create SearchResult objects
    jclass searchResultClass = env->FindClass("com/llamamobile/vd/SearchResult");
    if (!searchResultClass) {
        LOGE("Failed to find SearchResult class");
        delete[] results;
        return nullptr;
    }

    jmethodID searchResultConstructor = env->GetMethodID(searchResultClass, "<init>", "(JF)V");
    if (!searchResultConstructor) {
        LOGE("Failed to find SearchResult constructor");
        delete[] results;
        return nullptr;
    }

    jobjectArray resultArray = env->NewObjectArray(k, searchResultClass, nullptr);
    if (!resultArray) {
        LOGE("Failed to create result array");
        delete[] results;
        return nullptr;
    }

    for (int i = 0; i < k; i++) {
        jobject searchResult = env->NewObject(searchResultClass, searchResultConstructor, (jlong)results[i].id, results[i].distance);
        if (searchResult) {
            env->SetObjectArrayElement(resultArray, i, searchResult);
            env->DeleteLocalRef(searchResult);
        }
    }

    delete[] results;
    return resultArray;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSetEfSearch(
        JNIEnv *env,
        jobject thiz,
        jlong indexId,
        jint efSearch) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return false;
    }

    int error = llama_mobile_vd_hnsw_index_set_ef_search(index, static_cast<size_t>(efSearch));
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to set ef_search: %d", error);
        return false;
    }

    return true;
}

extern "C" JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetEfSearch(
        JNIEnv *env,
        jobject thiz,
        jlong indexId) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return 0;
    }

    size_t efSearch = 0;
    int error = llama_mobile_vd_hnsw_index_get_ef_search(index, &efSearch);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get ef_search: %d", error);
        return 0;
    }

    return efSearch;
}

extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetSize(
        JNIEnv *env,
        jobject thiz,
        jlong indexId) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return 0;
    }

    size_t size = 0;
    int error = llama_mobile_vd_hnsw_index_size(index, &size);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get HNSW index size: %d", error);
        return 0;
    }

    return size;
}

extern "C" JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetDimension(
        JNIEnv *env,
        jobject thiz,
        jlong indexId) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return 0;
    }

    size_t dimension = 0;
    int error = llama_mobile_vd_hnsw_index_dimension(index, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get HNSW index dimension: %d", error);
        return 0;
    }

    return dimension;
}

extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetCapacity(
        JNIEnv *env,
        jobject thiz,
        jlong indexId) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return 0;
    }

    size_t capacity = 0;
    int error = llama_mobile_vd_hnsw_index_capacity(index, &capacity);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get HNSW index capacity: %d", error);
        return 0;
    }

    return capacity;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexContains(
        JNIEnv *env,
        jobject thiz,
        jlong indexId,
        jlong id) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return false;
    }

    int contains = 0;
    int error = llama_mobile_vd_hnsw_index_contains(index, (uint64_t)id, &contains);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to check if vector exists in HNSW index: %d", error);
        return false;
    }

    return contains != 0;
}

extern "C" JNIEXPORT jfloatArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetVector(
        JNIEnv *env,
        jobject thiz,
        jlong indexId,
        jlong id) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return nullptr;
    }

    size_t dimension = 0;
    int error = llama_mobile_vd_hnsw_index_dimension(index, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get HNSW index dimension: %d", error);
        return nullptr;
    }

    float* vector = new float[dimension];
    error = llama_mobile_vd_hnsw_index_get_vector(index, (uint64_t)id, vector, dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get vector from HNSW index: %d", error);
        delete[] vector;
        return nullptr;
    }

    jfloatArray result = env->NewFloatArray(dimension);
    env->SetFloatArrayRegion(result, 0, dimension, vector);

    delete[] vector;
    return result;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSave(
        JNIEnv *env,
        jobject thiz,
        jlong indexId,
        jstring filename) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return false;
    }

    const char* filenamePtr = env->GetStringUTFChars(filename, nullptr);
    if (!filenamePtr) {
        LOGE("Failed to get filename");
        return false;
    }

    int error = llama_mobile_vd_hnsw_index_save(index, filenamePtr);
    env->ReleaseStringUTFChars(filename, filenamePtr);

    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to save HNSW index: %d", error);
        return false;
    }

    return true;
}

extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexLoad(
        JNIEnv *env,
        jobject thiz,
        jstring filename) {
    const char* filenamePtr = env->GetStringUTFChars(filename, nullptr);
    if (!filenamePtr) {
        LOGE("Failed to get filename");
        return 0;
    }

    LLAMA_MOBILE_VD_HNSWIndex index = nullptr;
    int error = llama_mobile_vd_hnsw_index_load(filenamePtr, &index);
    env->ReleaseStringUTFChars(filename, filenamePtr);

    if (error != LLAMA_MOBILE_VD_OK || !index) {
        LOGE("Failed to load HNSW index: %d", error);
        return 0;
    }

    return (jlong)(intptr_t)index;
}

extern "C" JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexDestroy(
        JNIEnv *env,
        jobject thiz,
        jlong indexId) {
    LLAMA_MOBILE_VD_HNSWIndex index = (LLAMA_MOBILE_VD_HNSWIndex)(intptr_t)indexId;
    if (!index) {
        LOGE("Invalid HNSW index");
        return;
    }

    llama_mobile_vd_hnsw_index_destroy(index);
}

// MMapVectorStoreBuilder JNI methods
extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderCreate(
        JNIEnv *env,
        jobject thiz,
        jint dimension,
        jint metric) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = nullptr;
    int error = llama_mobile_vd_mmap_vector_store_builder_create(static_cast<size_t>(dimension), static_cast<LLAMA_MOBILE_VD_DistanceMetric>(metric), &builder);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to create MMapVectorStoreBuilder: %d", error);
        return 0;
    }
    return (jlong)(intptr_t)builder;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderAddVector(
        JNIEnv *env,
        jobject thiz,
        jlong builderId,
        jlong id,
        jfloatArray vector) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = (LLAMA_MOBILE_VD_MMapVectorStoreBuilder)(intptr_t)builderId;
    if (!builder) {
        LOGE("Invalid MMapVectorStore builder");
        return false;
    }

    jfloat* vectorPtr = env->GetFloatArrayElements(vector, nullptr);
    jsize vectorLength = env->GetArrayLength(vector);

    int error = llama_mobile_vd_mmap_vector_store_builder_add(builder, (uint64_t)id, vectorPtr);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to add vector to MMapVectorStoreBuilder: %d", error);
        env->ReleaseFloatArrayElements(vector, vectorPtr, 0);
        return false;
    }

    env->ReleaseFloatArrayElements(vector, vectorPtr, 0);
    return true;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderReserve(
        JNIEnv *env,
        jobject thiz,
        jlong builderId,
        jlong capacity) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = (LLAMA_MOBILE_VD_MMapVectorStoreBuilder)(intptr_t)builderId;
    if (!builder) {
        LOGE("Invalid MMapVectorStore builder");
        return false;
    }

    int error = llama_mobile_vd_mmap_vector_store_builder_reserve(builder, static_cast<size_t>(capacity));
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to reserve capacity for MMapVectorStoreBuilder: %d", error);
        return false;
    }

    return true;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderSave(
        JNIEnv *env,
        jobject thiz,
        jlong builderId,
        jstring filename) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = (LLAMA_MOBILE_VD_MMapVectorStoreBuilder)(intptr_t)builderId;
    if (!builder) {
        LOGE("Invalid MMapVectorStore builder");
        return false;
    }

    const char* filenamePtr = env->GetStringUTFChars(filename, nullptr);
    if (!filenamePtr) {
        LOGE("Failed to get filename");
        return false;
    }

    int error = llama_mobile_vd_mmap_vector_store_builder_save(builder, filenamePtr);
    env->ReleaseStringUTFChars(filename, filenamePtr);

    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to save MMapVectorStoreBuilder: %d", error);
        return false;
    }

    return true;
}

extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderGetSize(
        JNIEnv *env,
        jobject thiz,
        jlong builderId) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = (LLAMA_MOBILE_VD_MMapVectorStoreBuilder)(intptr_t)builderId;
    if (!builder) {
        LOGE("Invalid MMapVectorStore builder");
        return 0;
    }

    size_t size = 0;
    int error = llama_mobile_vd_mmap_vector_store_builder_size(builder, &size);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get MMapVectorStoreBuilder size: %d", error);
        return 0;
    }

    return size;
}

extern "C" JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderGetDimension(
        JNIEnv *env,
        jobject thiz,
        jlong builderId) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = (LLAMA_MOBILE_VD_MMapVectorStoreBuilder)(intptr_t)builderId;
    if (!builder) {
        LOGE("Invalid MMapVectorStore builder");
        return 0;
    }

    size_t dimension = 0;
    int error = llama_mobile_vd_mmap_vector_store_builder_dimension(builder, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get MMapVectorStoreBuilder dimension: %d", error);
        return 0;
    }

    return dimension;
}

extern "C" JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderDestroy(
        JNIEnv *env,
        jobject thiz,
        jlong builderId) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = (LLAMA_MOBILE_VD_MMapVectorStoreBuilder)(intptr_t)builderId;
    if (!builder) {
        LOGE("Invalid MMapVectorStore builder");
        return;
    }

    llama_mobile_vd_mmap_vector_store_builder_destroy(builder);
}

// MMapVectorStore JNI methods
extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreOpen(
        JNIEnv *env,
        jobject thiz,
        jstring filename) {
    const char* filenamePtr = env->GetStringUTFChars(filename, nullptr);
    if (!filenamePtr) {
        LOGE("Failed to get filename");
        return 0;
    }

    LLAMA_MOBILE_VD_MMapVectorStore store = nullptr;
    int error = llama_mobile_vd_mmap_vector_store_open(filenamePtr, &store);
    env->ReleaseStringUTFChars(filename, filenamePtr);

    if (error != LLAMA_MOBILE_VD_OK || !store) {
        LOGE("Failed to open MMapVectorStore: %d", error);
        return 0;
    }

    return (jlong)(intptr_t)store;
}

extern "C" JNIEXPORT jfloatArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetVector(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jlong id) {
    LLAMA_MOBILE_VD_MMapVectorStore store = (LLAMA_MOBILE_VD_MMapVectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid MMapVectorStore");
        return nullptr;
    }

    size_t dimension = 0;
    int error = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get MMapVectorStore dimension: %d", error);
        return nullptr;
    }

    float* vector = new float[dimension];
    error = llama_mobile_vd_mmap_vector_store_get(store, (uint64_t)id, vector, dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get vector from MMapVectorStore: %d", error);
        delete[] vector;
        return nullptr;
    }

    jfloatArray result = env->NewFloatArray(dimension);
    env->SetFloatArrayRegion(result, 0, dimension, vector);

    delete[] vector;
    return result;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreContains(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jlong id) {
    LLAMA_MOBILE_VD_MMapVectorStore store = (LLAMA_MOBILE_VD_MMapVectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid MMapVectorStore");
        return false;
    }

    int contains = 0;
    int error = llama_mobile_vd_mmap_vector_store_contains(store, (uint64_t)id, &contains);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to check if vector exists in MMapVectorStore: %d", error);
        return false;
    }

    return contains != 0;
}

extern "C" JNIEXPORT jobjectArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreSearch(
        JNIEnv *env,
        jobject thiz,
        jlong storeId,
        jfloatArray queryVector,
        jint k) {
    LLAMA_MOBILE_VD_MMapVectorStore store = (LLAMA_MOBILE_VD_MMapVectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid MMapVectorStore");
        return nullptr;
    }

    jfloat* queryVectorPtr = env->GetFloatArrayElements(queryVector, nullptr);
    jsize queryVectorLength = env->GetArrayLength(queryVector);

    size_t k_size = static_cast<size_t>(k);
    LLAMA_MOBILE_VD_SearchResult* results = new LLAMA_MOBILE_VD_SearchResult[k_size];
    int error = llama_mobile_vd_mmap_vector_store_search(store, queryVectorPtr, k_size, results, k_size);

    env->ReleaseFloatArrayElements(queryVector, queryVectorPtr, 0);

    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to search MMapVectorStore: %d", error);
        delete[] results;
        return nullptr;
    }

    // Create SearchResult objects
    jclass searchResultClass = env->FindClass("com/llamamobile/vd/SearchResult");
    if (!searchResultClass) {
        LOGE("Failed to find SearchResult class");
        delete[] results;
        return nullptr;
    }

    jmethodID searchResultConstructor = env->GetMethodID(searchResultClass, "<init>", "(JF)V");
    if (!searchResultConstructor) {
        LOGE("Failed to find SearchResult constructor");
        delete[] results;
        return nullptr;
    }

    jobjectArray resultArray = env->NewObjectArray(k, searchResultClass, nullptr);
    if (!resultArray) {
        LOGE("Failed to create result array");
        delete[] results;
        return nullptr;
    }

    for (int i = 0; i < k; i++) {
        jobject searchResult = env->NewObject(searchResultClass, searchResultConstructor, (jlong)results[i].id, results[i].distance);
        if (searchResult) {
            env->SetObjectArrayElement(resultArray, i, searchResult);
            env->DeleteLocalRef(searchResult);
        }
    }

    delete[] results;
    return resultArray;
}

extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetSize(
        JNIEnv *env,
        jobject thiz,
        jlong storeId) {
    LLAMA_MOBILE_VD_MMapVectorStore store = (LLAMA_MOBILE_VD_MMapVectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid MMapVectorStore");
        return 0;
    }

    size_t size = 0;
    int error = llama_mobile_vd_mmap_vector_store_size(store, &size);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get MMapVectorStore size: %d", error);
        return 0;
    }

    return size;
}

extern "C" JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetDimension(
        JNIEnv *env,
        jobject thiz,
        jlong storeId) {
    LLAMA_MOBILE_VD_MMapVectorStore store = (LLAMA_MOBILE_VD_MMapVectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid MMapVectorStore");
        return 0;
    }

    size_t dimension = 0;
    int error = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get MMapVectorStore dimension: %d", error);
        return 0;
    }

    return dimension;
}

extern "C" JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetMetric(
        JNIEnv *env,
        jobject thiz,
        jlong storeId) {
    LLAMA_MOBILE_VD_MMapVectorStore store = (LLAMA_MOBILE_VD_MMapVectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid MMapVectorStore");
        return 0;
    }

    LLAMA_MOBILE_VD_DistanceMetric metric = LLAMA_MOBILE_VD_DISTANCE_L2;
    int error = llama_mobile_vd_mmap_vector_store_metric(store, &metric);
    if (error != LLAMA_MOBILE_VD_OK) {
        LOGE("Failed to get MMapVectorStore metric: %d", error);
        return 0;
    }

    return metric;
}

extern "C" JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreClose(
        JNIEnv *env,
        jobject thiz,
        jlong storeId) {
    LLAMA_MOBILE_VD_MMapVectorStore store = (LLAMA_MOBILE_VD_MMapVectorStore)(intptr_t)storeId;
    if (!store) {
        LOGE("Invalid MMapVectorStore");
        return;
    }

    llama_mobile_vd_mmap_vector_store_close(store);
}

// Version JNI methods
extern "C" JNIEXPORT jstring JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeGetVersion(
        JNIEnv *env,
        jobject thiz) {
    const char* version = llama_mobile_vd_version();
    return env->NewStringUTF(version);
}

// SearchResult class
extern "C" JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_SearchResult_getId(
        JNIEnv *env,
        jobject thiz) {
    jclass cls = env->GetObjectClass(thiz);
    jfieldID fieldId = env->GetFieldID(cls, "id", "J");
    return env->GetLongField(thiz, fieldId);
}

extern "C" JNIEXPORT jfloat JNICALL Java_com_llamamobile_vd_SearchResult_getDistance(
        JNIEnv *env,
        jobject thiz) {
    jclass cls = env->GetObjectClass(thiz);
    jfieldID fieldId = env->GetFieldID(cls, "distance", "F");
    return env->GetFloatField(thiz, fieldId);
}
