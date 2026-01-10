#include <jni.h>
#include <string>
#include <vector>
#include <android/log.h>
#include "quiverdb_wrapper.h"

#define TAG "LlamaMobileVD"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

// Convert Java SearchResult array to C++
static jobjectArray createSearchResultArray(JNIEnv *env, const std::vector<QuiverDBSearchResult> &results) {
    jclass resultClass = env->FindClass("com/llamamobile/vd/LlamaMobileVD$SearchResult");
    if (!resultClass) {
        LOGE("Failed to find SearchResult class");
        return nullptr;
    }

    jmethodID constructor = env->GetMethodID(resultClass, "<init>", "(JF)V");
    if (!constructor) {
        LOGE("Failed to find SearchResult constructor");
        env->DeleteLocalRef(resultClass);
        return nullptr;
    }

    jobjectArray resultArray = env->NewObjectArray(results.size(), resultClass, nullptr);
    if (!resultArray) {
        LOGE("Failed to create SearchResult array");
        env->DeleteLocalRef(resultClass);
        return nullptr;
    }

    for (size_t i = 0; i < results.size(); ++i) {
        jobject result = env->NewObject(resultClass, constructor, results[i].id, results[i].distance);
        if (!result) {
            LOGE("Failed to create SearchResult object");
            env->DeleteLocalRef(resultClass);
            env->DeleteLocalRef(resultArray);
            return nullptr;
        }
        env->SetObjectArrayElement(resultArray, i, result);
        env->DeleteLocalRef(result);
    }

    env->DeleteLocalRef(resultClass);
    return resultArray;
}

// VectorStore native methods

extern "C" JNIEXPORT jlong JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeCreateVectorStore(JNIEnv *env, jclass clazz, jint dimension, jint metric) {
    QuiverDBVectorStore store;
    QuiverDBError result = quiverdb_vector_store_create(dimension, static_cast<QuiverDBDistanceMetric>(metric), &store);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to create vector store: %d", result);
        return 0;
    }
    return reinterpret_cast<jlong>(store);
}

extern "C" JNIEXPORT void JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeDestroyVectorStore(JNIEnv *env, jclass clazz, jlong handle) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    quiverdb_vector_store_destroy(store);
}

extern "C" JNIEXPORT void JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeAddVector(JNIEnv *env, jclass clazz, jlong handle, jlong id, jfloatArray vector) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    jfloat *vectorData = env->GetFloatArrayElements(vector, nullptr);
    if (!vectorData) {
        LOGE("Failed to get vector data");
        return;
    }

    QuiverDBError result = quiverdb_vector_store_add(store, static_cast<uint64_t>(id), vectorData);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to add vector: %d", result);
    }

    env->ReleaseFloatArrayElements(vector, vectorData, JNI_ABORT);
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeRemoveVector(JNIEnv *env, jclass clazz, jlong handle, jlong id) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    int removed = 0;
    QuiverDBError result = quiverdb_vector_store_remove(store, static_cast<uint64_t>(id), &removed);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to remove vector: %d", result);
        return false;
    }
    return static_cast<jboolean>(removed);
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeGetVector(JNIEnv *env, jclass clazz, jlong handle, jlong id, jfloatArray vector) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    jfloat *vectorData = env->GetFloatArrayElements(vector, nullptr);
    if (!vectorData) {
        LOGE("Failed to get vector data");
        return false;
    }

    size_t vectorSize = env->GetArrayLength(vector);
    QuiverDBError result = quiverdb_vector_store_get(store, static_cast<uint64_t>(id), vectorData, vectorSize);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to get vector: %d", result);
        env->ReleaseFloatArrayElements(vector, vectorData, JNI_ABORT);
        return false;
    }

    env->ReleaseFloatArrayElements(vector, vectorData, 0);
    return true;
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeUpdateVector(JNIEnv *env, jclass clazz, jlong handle, jlong id, jfloatArray vector) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    jfloat *vectorData = env->GetFloatArrayElements(vector, nullptr);
    if (!vectorData) {
        LOGE("Failed to get vector data");
        return false;
    }

    QuiverDBError result = quiverdb_vector_store_update(store, static_cast<uint64_t>(id), vectorData);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to update vector: %d", result);
        env->ReleaseFloatArrayElements(vector, vectorData, JNI_ABORT);
        return false;
    }

    env->ReleaseFloatArrayElements(vector, vectorData, JNI_ABORT);
    return true;
}

extern "C" JNIEXPORT jobjectArray JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeSearchVectors(JNIEnv *env, jclass clazz, jlong handle, jfloatArray query, jint k) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    jfloat *queryData = env->GetFloatArrayElements(query, nullptr);
    if (!queryData) {
        LOGE("Failed to get query data");
        return nullptr;
    }

    std::vector<QuiverDBSearchResult> results(k);
    QuiverDBError result = quiverdb_vector_store_search(store, queryData, k, results.data(), results.size());
    env->ReleaseFloatArrayElements(query, queryData, JNI_ABORT);

    if (result != QUIVERDB_OK) {
        LOGE("Failed to search vectors: %d", result);
        return nullptr;
    }

    return createSearchResultArray(env, results);
}

extern "C" JNIEXPORT jint JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreSize(JNIEnv *env, jclass clazz, jlong handle) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    size_t size;
    QuiverDBError result = quiverdb_vector_store_size(store, &size);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to get vector store size: %d", result);
        return 0;
    }
    return static_cast<jint>(size);
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreContains(JNIEnv *env, jclass clazz, jlong handle, jlong id) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    int contains = 0;
    QuiverDBError result = quiverdb_vector_store_contains(store, static_cast<uint64_t>(id), &contains);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to check if ID exists: %d", result);
        return false;
    }
    return static_cast<jboolean>(contains);
}

extern "C" JNIEXPORT void JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreReserve(JNIEnv *env, jclass clazz, jlong handle, jint capacity) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    QuiverDBError result = quiverdb_vector_store_reserve(store, capacity);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to reserve capacity: %d", result);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreClear(JNIEnv *env, jclass clazz, jlong handle) {
    QuiverDBVectorStore store = reinterpret_cast<QuiverDBVectorStore>(handle);
    QuiverDBError result = quiverdb_vector_store_clear(store);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to clear vector store: %d", result);
    }
}

// HNSWIndex native methods

extern "C" JNIEXPORT jlong JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeCreateHNSWIndex(JNIEnv *env, jclass clazz, jint dimension, jint metric, jint maxElements, jint M, jint efConstruction, jint seed) {
    QuiverDBHNSWIndex index;
    QuiverDBError result = quiverdb_hnsw_index_create_with_params(
        dimension, static_cast<QuiverDBDistanceMetric>(metric), maxElements, M, efConstruction, seed, &index);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to create HNSW index: %d", result);
        return 0;
    }
    return reinterpret_cast<jlong>(index);
}

extern "C" JNIEXPORT void JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeDestroyHNSWIndex(JNIEnv *env, jclass clazz, jlong handle) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    quiverdb_hnsw_index_destroy(index);
}

extern "C" JNIEXPORT void JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeAddToHNSWIndex(JNIEnv *env, jclass clazz, jlong handle, jlong id, jfloatArray vector) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    jfloat *vectorData = env->GetFloatArrayElements(vector, nullptr);
    if (!vectorData) {
        LOGE("Failed to get vector data");
        return;
    }

    QuiverDBError result = quiverdb_hnsw_index_add(index, static_cast<uint64_t>(id), vectorData);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to add vector to HNSW index: %d", result);
    }

    env->ReleaseFloatArrayElements(vector, vectorData, JNI_ABORT);
}

extern "C" JNIEXPORT jobjectArray JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeSearchHNSWIndex(JNIEnv *env, jclass clazz, jlong handle, jfloatArray query, jint k) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    jfloat *queryData = env->GetFloatArrayElements(query, nullptr);
    if (!queryData) {
        LOGE("Failed to get query data");
        return nullptr;
    }

    std::vector<QuiverDBSearchResult> results(k);
    QuiverDBError result = quiverdb_hnsw_index_search(index, queryData, k, results.data(), results.size());
    env->ReleaseFloatArrayElements(query, queryData, JNI_ABORT);

    if (result != QUIVERDB_OK) {
        LOGE("Failed to search HNSW index: %d", result);
        return nullptr;
    }

    return createSearchResultArray(env, results);
}

extern "C" JNIEXPORT void JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeSetEfSearch(JNIEnv *env, jclass clazz, jlong handle, jint ef) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    QuiverDBError result = quiverdb_hnsw_index_set_ef_search(index, ef);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to set ef_search: %d", result);
    }
}

extern "C" JNIEXPORT jint JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeGetEfSearch(JNIEnv *env, jclass clazz, jlong handle) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    size_t efSearch;
    QuiverDBError result = quiverdb_hnsw_index_get_ef_search(index, &efSearch);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to get ef_search: %d", result);
        return 0;
    }
    return static_cast<jint>(efSearch);
}

extern "C" JNIEXPORT jint JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSize(JNIEnv *env, jclass clazz, jlong handle) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    size_t size;
    QuiverDBError result = quiverdb_hnsw_index_size(index, &size);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to get HNSW index size: %d", result);
        return 0;
    }
    return static_cast<jint>(size);
}

extern "C" JNIEXPORT jint JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexDimension(JNIEnv *env, jclass clazz, jlong handle) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    size_t dimension;
    QuiverDBError result = quiverdb_hnsw_index_dimension(index, &dimension);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to get HNSW index dimension: %d", result);
        return 0;
    }
    return static_cast<jint>(dimension);
}

extern "C" JNIEXPORT jint JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCapacity(JNIEnv *env, jclass clazz, jlong handle) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    size_t capacity;
    QuiverDBError result = quiverdb_hnsw_index_capacity(index, &capacity);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to get HNSW index capacity: %d", result);
        return 0;
    }
    return static_cast<jint>(capacity);
}

extern "C" JNIEXPORT jint JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexMetric(JNIEnv *env, jclass clazz, jlong handle) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    // We need to get the metric from the index
    // Since there's no direct API for this, we'll return 0 (L2) as default
    // This is a limitation of the current wrapper API
    return 0;
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexContains(JNIEnv *env, jclass clazz, jlong handle, jlong id) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    int contains = 0;
    QuiverDBError result = quiverdb_hnsw_index_contains(index, static_cast<uint64_t>(id), &contains);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to check if ID exists in HNSW index: %d", result);
        return false;
    }
    return static_cast<jboolean>(contains);
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeGetVectorFromHNSWIndex(JNIEnv *env, jclass clazz, jlong handle, jlong id, jfloatArray vector) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    jfloat *vectorData = env->GetFloatArrayElements(vector, nullptr);
    if (!vectorData) {
        LOGE("Failed to get vector data");
        return false;
    }

    size_t vectorSize = env->GetArrayLength(vector);
    QuiverDBError result = quiverdb_hnsw_index_get_vector(index, static_cast<uint64_t>(id), vectorData, vectorSize);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to get vector from HNSW index: %d", result);
        env->ReleaseFloatArrayElements(vector, vectorData, JNI_ABORT);
        return false;
    }

    env->ReleaseFloatArrayElements(vector, vectorData, 0);
    return true;
}

extern "C" JNIEXPORT void JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeSaveHNSWIndex(JNIEnv *env, jclass clazz, jlong handle, jstring filename) {
    QuiverDBHNSWIndex index = reinterpret_cast<QuiverDBHNSWIndex>(handle);
    const char *cFilename = env->GetStringUTFChars(filename, nullptr);
    if (!cFilename) {
        LOGE("Failed to get filename string");
        return;
    }

    QuiverDBError result = quiverdb_hnsw_index_save(index, cFilename);
    if (result != QUIVERDB_OK) {
        LOGE("Failed to save HNSW index: %d", result);
    }

    env->ReleaseStringUTFChars(filename, cFilename);
}

extern "C" JNIEXPORT jlong JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeLoadHNSWIndex(JNIEnv *env, jclass clazz, jstring filename) {
    const char *cFilename = env->GetStringUTFChars(filename, nullptr);
    if (!cFilename) {
        LOGE("Failed to get filename string");
        return 0;
    }

    QuiverDBHNSWIndex index;
    QuiverDBError result = quiverdb_hnsw_index_load(cFilename, &index);
    env->ReleaseStringUTFChars(filename, cFilename);

    if (result != QUIVERDB_OK) {
        LOGE("Failed to load HNSW index: %d", result);
        return 0;
    }
    return reinterpret_cast<jlong>(index);
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_llamamobile_vd_LlamaMobileVD_nativeGetVersion(JNIEnv *env, jclass clazz) {
    const char *version = quiverdb_version();
    return env->NewStringUTF(version);
}
