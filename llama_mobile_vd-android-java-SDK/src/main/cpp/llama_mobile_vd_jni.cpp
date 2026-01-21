#include <jni.h>
#include <string>
#include <vector>
#include <memory>
#include <unordered_map>
#include "llama_mobile_vd_wrapper.h"

// JNI namespace
namespace {
    // Helper function to convert Java float array to C++ vector
    std::vector<float> jfloatArrayToVector(JNIEnv* env, jfloatArray jarray) {
        std::vector<float> result;
        if (jarray == nullptr) {
            return result;
        }
        
        jsize length = env->GetArrayLength(jarray);
        result.resize(length);
        
        jfloat* elements = env->GetFloatArrayElements(jarray, nullptr);
        if (elements == nullptr) {
            return result;
        }
        
        for (jsize i = 0; i < length; i++) {
            result[i] = elements[i];
        }
        
        env->ReleaseFloatArrayElements(jarray, elements, JNI_ABORT);
        return result;
    }

    // Helper function to convert C++ vector to Java float array
    jfloatArray vectorToJfloatArray(JNIEnv* env, const std::vector<float>& vec) {
        jfloatArray jarray = env->NewFloatArray(vec.size());
        if (jarray == nullptr) {
            return nullptr;
        }
        
        env->SetFloatArrayRegion(jarray, 0, vec.size(), vec.data());
        return jarray;
    }

    // Helper function to throw Java exception
    void throwLlamaMobileVDException(JNIEnv* env, const char* message, int errorCode) {
    jclass exceptionClass = env->FindClass("com/llamamobile/vd/LlamaMobileVD$LlamaMobileVDException");
    if (exceptionClass != nullptr) {
        env->ThrowNew(exceptionClass, message);
    }
}

    // Map to store native pointers
    std::unordered_map<jlong, void*> nativePointers;
    jlong nextPointerId = 1;

    // Get native pointer from ID
    void* getNativePointer(jlong id) {
        auto it = nativePointers.find(id);
        if (it != nativePointers.end()) {
            return it->second;
        }
        return nullptr;
    }

    // Register native pointer and return ID
    jlong registerNativePointer(void* ptr) {
        jlong id = nextPointerId++;
        nativePointers[id] = ptr;
        return id;
    }

    // Remove native pointer
    void removeNativePointer(jlong id) {
        nativePointers.erase(id);
    }
}

// ==========================
// DistanceMetric enum mapping
// ==========================
static const std::unordered_map<int, LLAMA_MOBILE_VD_DistanceMetric> distanceMetricMap = {
    {0, LLAMA_MOBILE_VD_DISTANCE_L2},
    {1, LLAMA_MOBILE_VD_DISTANCE_COSINE},
    {2, LLAMA_MOBILE_VD_DISTANCE_DOT}
};

// ==========================
// VectorStore JNI methods
// ==========================

#ifdef __cplusplus
extern "C" {
#endif

// Create VectorStore
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreCreate(
        JNIEnv* env,
        jclass clazz,
        jint dimension,
        jint metric) {
    
    auto it = distanceMetricMap.find(metric);
    if (it == distanceMetricMap.end()) {
        throwLlamaMobileVDException(env, "Invalid distance metric", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    LLAMA_MOBILE_VD_VectorStore store = nullptr;
    LLAMA_MOBILE_VD_Error error = LLAMA_MOBILE_VD_ERROR;
    
    // Call the C function to create the vector store
    error = llama_mobile_vd_vector_store_create(static_cast<size_t>(dimension), it->second, &store);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to create vector store", error);
        return 0;
    }
    
    return registerNativePointer(store);
}

// Add vector to VectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreAddVector(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id,
        jfloatArray vector) {    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }    
    // Convert Java float array to C++ vector
    std::vector<float> vec = jfloatArrayToVector(env, vector);
    if (vec.empty()) {
        throwLlamaMobileVDException(env, "Invalid vector", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }    
    // Call the C function to add the vector
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_add(store, static_cast<uint64_t>(id), vec.data());    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to add vector", error);
    }
}

// Search vectors in VectorStore
JNIEXPORT jobjectArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreSearch(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jfloatArray queryVector,
        jint k) {    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }    
    // Convert Java float array to C++ vector
    std::vector<float> queryVec = jfloatArrayToVector(env, queryVector);
    if (queryVec.empty()) {
        throwLlamaMobileVDException(env, "Invalid query vector", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }    
    // Allocate memory for search results
    std::vector<LLAMA_MOBILE_VD_SearchResult> results(static_cast<size_t>(k));    
    // Call the C function to search vectors
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_search(store, queryVec.data(), static_cast<size_t>(k), results.data(), static_cast<size_t>(k));    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Search failed", error);
        return nullptr;
    }    
    // Create Java SearchResult objects
    jclass resultClass = env->FindClass("com/llamamobile/vd/LlamaMobileVD$SearchResult");
    jmethodID constructor = env->GetMethodID(resultClass, "<init>", "(JF)V");    
    jobjectArray resultArray = env->NewObjectArray(static_cast<jsize>(k), resultClass, nullptr);    
    for (size_t i = 0; i < static_cast<size_t>(k); i++) {
        jobject resultObj = env->NewObject(resultClass, constructor, static_cast<jlong>(results[i].id), static_cast<jfloat>(results[i].distance));
        env->SetObjectArrayElement(resultArray, static_cast<jsize>(i), resultObj);
    }    
    return resultArray;
}

// Get vector by ID from VectorStore
JNIEXPORT jfloatArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetVector(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }    
    // Get vector dimension
    size_t dimension;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_dimension(store, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector dimension", error);
        return nullptr;
    }    
    // Allocate memory for vector
    float* vector = new float[dimension];
    if (vector == nullptr) {
        throwLlamaMobileVDException(env, "Memory allocation failed", LLAMA_MOBILE_VD_OUT_OF_MEMORY);
        return nullptr;
    }    
    // Call the C function to get the vector
    error = llama_mobile_vd_vector_store_get(store, static_cast<uint64_t>(id), vector, dimension);    
    if (error != LLAMA_MOBILE_VD_OK) {
        delete[] vector;
        throwLlamaMobileVDException(env, "Failed to get vector", error);
        return nullptr;
    }    
    // Convert C++ vector to Java float array
    jfloatArray result = env->NewFloatArray(static_cast<jsize>(dimension));
    if (result == nullptr) {
        delete[] vector;
        throwLlamaMobileVDException(env, "Failed to create Java array", LLAMA_MOBILE_VD_OUT_OF_MEMORY);
        return nullptr;
    }    
    env->SetFloatArrayRegion(result, 0, static_cast<jsize>(dimension), vector);    
    // Free the native vector
    delete[] vector;    
    return result;
}

// Remove vector from VectorStore
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreRemoveVector(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }    
    // Call the C function to remove the vector
    int removed = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_remove(store, static_cast<uint64_t>(id), &removed);    
    if (error != LLAMA_MOBILE_VD_OK && error != LLAMA_MOBILE_VD_ID_NOT_FOUND) {
        return JNI_FALSE;
    }    
    return removed != 0 ? JNI_TRUE : JNI_FALSE;
}

// Contains vector in VectorStore
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreContains(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Call the C function to check if vector exists
    int exists = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_contains(store, static_cast<uint64_t>(id), &exists);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return JNI_FALSE;
    }
    
    return exists ? JNI_TRUE : JNI_FALSE;
}

// Get VectorStore size
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetSize(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the size
    size_t size = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_size(store, &size);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector store size", error);
        return 0;
    }
    
    return static_cast<jlong>(size);
}

// Get VectorStore dimension
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetDimension(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the dimension
    size_t dimension = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_dimension(store, &dimension);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector store dimension", error);
        return 0;
    }
    
    return static_cast<jint>(dimension);
}

// Get VectorStore metric
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetMetric(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the metric
    LLAMA_MOBILE_VD_DistanceMetric metric;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_metric(store, &metric);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector store metric", error);
        return 0;
    }
    
    return static_cast<jint>(metric);
}

// Update vector in VectorStore
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreUpdateVector(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id,
        jfloatArray vector) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Convert Java float array to C++ vector
    std::vector<float> vec = jfloatArrayToVector(env, vector);
    if (vec.empty()) {
        throwLlamaMobileVDException(env, "Invalid vector", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Call the C function to update the vector
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_update(store, static_cast<uint64_t>(id), vec.data());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return JNI_FALSE;
    }
    
    return JNI_TRUE;
}

// Reserve capacity in VectorStore
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreReserve(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong capacity) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Call the C function to reserve capacity
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_reserve(store, static_cast<size_t>(capacity));
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return JNI_FALSE;
    }
    
    return JNI_TRUE;
}

// Clear VectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreClear(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    // Call the C function to clear the vector store
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_clear(store);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to clear vector store", error);
    }
}

// Destroy VectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreDestroy(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_VectorStore store = static_cast<LLAMA_MOBILE_VD_VectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        return;
    }
    
    // Call the C function to destroy the vector store
    llama_mobile_vd_vector_store_destroy(store);
    
    // Remove the native pointer from the map
    removeNativePointer(storeId);
}

// ==========================
// MMapVectorStore JNI methods
// ==========================

// Open MMapVectorStore
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreOpen(
        JNIEnv* env,
        jclass clazz,
        jstring filePath) {
    
    // Convert Java string to C++ string
    const char* filePathStr = env->GetStringUTFChars(filePath, nullptr);
    if (filePathStr == nullptr) {
        return 0;
    }
    
    LLAMA_MOBILE_VD_MMapVectorStore store = nullptr;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_open(filePathStr, &store);
    
    env->ReleaseStringUTFChars(filePath, filePathStr);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to open MMap vector store", error);
        return 0;
    }
    
    return registerNativePointer(store);
}

// Search vectors in MMapVectorStore
JNIEXPORT jobjectArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreSearch(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jfloatArray queryVector,
        jint k) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_MMapVectorStore store = static_cast<LLAMA_MOBILE_VD_MMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    // Convert Java float array to C++ vector
    std::vector<float> queryVec = jfloatArrayToVector(env, queryVector);
    if (queryVec.empty()) {
        throwLlamaMobileVDException(env, "Invalid query vector", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    // Allocate memory for search results
    std::vector<LLAMA_MOBILE_VD_SearchResult> results(static_cast<size_t>(k));
    
    // Call the C function to search vectors
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_search(store, queryVec.data(), static_cast<size_t>(k), results.data(), static_cast<size_t>(k));
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Search failed", error);
        return nullptr;
    }
    
    // Create Java SearchResult objects
    jclass resultClass = env->FindClass("com/llamamobile/vd/LlamaMobileVD$SearchResult");
    jmethodID constructor = env->GetMethodID(resultClass, "<init>", "(JF)V");
    
    jobjectArray resultArray = env->NewObjectArray(static_cast<jsize>(k), resultClass, nullptr);
    
    for (size_t i = 0; i < static_cast<size_t>(k); i++) {
        jobject resultObj = env->NewObject(resultClass, constructor, static_cast<jlong>(results[i].id), static_cast<jfloat>(results[i].distance));
        env->SetObjectArrayElement(resultArray, static_cast<jsize>(i), resultObj);
    }
    
    return resultArray;
}

// Get vector by ID from MMapVectorStore
JNIEXPORT jfloatArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetVector(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_MMapVectorStore store = static_cast<LLAMA_MOBILE_VD_MMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    // Get vector dimension
    size_t dimension;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector dimension", error);
        return nullptr;
    }
    
    // Allocate memory for vector
    float* vector = new float[dimension];
    if (vector == nullptr) {
        throwLlamaMobileVDException(env, "Memory allocation failed", LLAMA_MOBILE_VD_OUT_OF_MEMORY);
        return nullptr;
    }
    
    // Call the C function to get the vector
    error = llama_mobile_vd_mmap_vector_store_get(store, static_cast<uint64_t>(id), vector, dimension);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        delete[] vector;
        throwLlamaMobileVDException(env, "Failed to get vector", error);
        return nullptr;
    }
    
    // Convert C++ vector to Java float array
    jfloatArray result = env->NewFloatArray(static_cast<jsize>(dimension));
    if (result == nullptr) {
        delete[] vector;
        throwLlamaMobileVDException(env, "Failed to create Java array", LLAMA_MOBILE_VD_OUT_OF_MEMORY);
        return nullptr;
    }
    
    env->SetFloatArrayRegion(result, 0, static_cast<jsize>(dimension), vector);
    
    // Free the native vector
    delete[] vector;
    
    return result;
}

// Get MMapVectorStore size
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetSize(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_MMapVectorStore store = static_cast<LLAMA_MOBILE_VD_MMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the size
    size_t size;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_size(store, &size);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector store size", error);
        return 0;
    }
    
    return static_cast<jlong>(size);
}

// Get MMapVectorStore dimension
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetDimension(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_MMapVectorStore store = static_cast<LLAMA_MOBILE_VD_MMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the dimension
    size_t dimension;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector store dimension", error);
        return 0;
    }
    
    return static_cast<jint>(dimension);
}

// Get MMapVectorStore metric
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetMetric(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_MMapVectorStore store = static_cast<LLAMA_MOBILE_VD_MMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the metric
    LLAMA_MOBILE_VD_DistanceMetric metric;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_metric(store, &metric);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector store metric", error);
        return 0;
    }
    
    return static_cast<jint>(metric);
}

// Close MMapVectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreClose(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_MMapVectorStore store = static_cast<LLAMA_MOBILE_VD_MMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        return;
    }
    
    // Call the C function to close the MMap vector store
    llama_mobile_vd_mmap_vector_store_close(store);
    
    // Remove the native pointer from the map
    removeNativePointer(storeId);
}

// Check if MMapVectorStore contains vector
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreContains(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {
    
    // Get the native vector store pointer
    LLAMA_MOBILE_VD_MMapVectorStore store = static_cast<LLAMA_MOBILE_VD_MMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Call the C function to check if vector exists
    int exists = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_contains(store, static_cast<uint64_t>(id), &exists);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return JNI_FALSE;
    }
    
    return exists != 0 ? JNI_TRUE : JNI_FALSE;
}

// ==========================
// HNSWIndex JNI methods
// ==========================

// Create HNSWIndex
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCreate(
        JNIEnv* env,
        jclass clazz,
        jint dimension,
        jint metric,
        jlong maxElements) {
    
    auto it = distanceMetricMap.find(metric);
    if (it == distanceMetricMap.end()) {
        throwLlamaMobileVDException(env, "Invalid distance metric", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    LLAMA_MOBILE_VD_HNSWIndex index = nullptr;
    LLAMA_MOBILE_VD_Error error = LLAMA_MOBILE_VD_ERROR;
    
    // Call the C function to create the HNSW index
    error = llama_mobile_vd_hnsw_index_create(static_cast<size_t>(dimension), it->second, static_cast<size_t>(maxElements), &index);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to create HNSW index", error);
        return 0;
    }
    
    return registerNativePointer(index);
}

// Create HNSWIndex with parameters
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCreateWithParams(
        JNIEnv* env,
        jclass clazz,
        jint dimension,
        jint metric,
        jlong maxElements,
        jint M,
        jint efConstruction,
        jint seed) {
    
    auto it = distanceMetricMap.find(metric);
    if (it == distanceMetricMap.end()) {
        throwLlamaMobileVDException(env, "Invalid distance metric", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    LLAMA_MOBILE_VD_HNSWIndex index = nullptr;
    LLAMA_MOBILE_VD_Error error = LLAMA_MOBILE_VD_ERROR;
    
    // Call the C function to create the HNSW index with parameters
    error = llama_mobile_vd_hnsw_index_create_with_params(
        static_cast<size_t>(dimension),
        it->second,
        static_cast<size_t>(maxElements),
        static_cast<size_t>(M),
        static_cast<size_t>(efConstruction),
        static_cast<uint32_t>(seed),
        &index);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to create HNSW index", error);
        return 0;
    }
    
    return registerNativePointer(index);
}

// Add vector to HNSWIndex
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexAddVector(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jlong id,
        jfloatArray vector) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Convert Java float array to C++ vector
    std::vector<float> vec = jfloatArrayToVector(env, vector);
    if (vec.empty()) {
        throwLlamaMobileVDException(env, "Invalid vector", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Call the C function to add the vector
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_add(index, static_cast<uint64_t>(id), vec.data());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return JNI_FALSE;
    }
    
    return JNI_TRUE;
}

// Search vectors in HNSWIndex
JNIEXPORT jobjectArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSearch(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jfloatArray queryVector,
        jint k) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    // Convert Java float array to C++ vector
    std::vector<float> queryVec = jfloatArrayToVector(env, queryVector);
    if (queryVec.empty()) {
        throwLlamaMobileVDException(env, "Invalid query vector", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    // Allocate memory for search results
    std::vector<LLAMA_MOBILE_VD_SearchResult> results(static_cast<size_t>(k));
    
    // Call the C function to search vectors
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_search(index, queryVec.data(), static_cast<size_t>(k), results.data(), static_cast<size_t>(k));
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Search failed", error);
        return nullptr;
    }
    
    // Create Java SearchResult objects
    jclass resultClass = env->FindClass("com/llamamobile/vd/LlamaMobileVD$SearchResult");
    jmethodID constructor = env->GetMethodID(resultClass, "<init>", "(JF)V");
    
    jobjectArray resultArray = env->NewObjectArray(static_cast<jsize>(k), resultClass, nullptr);
    
    for (size_t i = 0; i < static_cast<size_t>(k); i++) {
        jobject resultObj = env->NewObject(resultClass, constructor, static_cast<jlong>(results[i].id), static_cast<jfloat>(results[i].distance));
        env->SetObjectArrayElement(resultArray, static_cast<jsize>(i), resultObj);
    }
    
    return resultArray;
}

// Set efSearch for HNSWIndex
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSetEfSearch(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jint efSearch) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Call the C function to set efSearch
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_set_ef_search(index, static_cast<size_t>(efSearch));
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return JNI_FALSE;
    }
    
    return JNI_TRUE;
}

// Get efSearch from HNSWIndex
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetEfSearch(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get efSearch
    size_t efSearch = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_get_ef_search(index, &efSearch);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get efSearch", error);
        return 0;
    }
    
    return static_cast<jint>(efSearch);
}

// Get HNSWIndex size
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetSize(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the size
    size_t size = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_size(index, &size);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get HNSW index size", error);
        return 0;
    }
    
    return static_cast<jlong>(size);
}

// Get HNSWIndex dimension
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetDimension(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the dimension
    size_t dimension = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_dimension(index, &dimension);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get HNSW index dimension", error);
        return 0;
    }
    
    return static_cast<jint>(dimension);
}

// Get HNSWIndex capacity
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetCapacity(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the capacity
    size_t capacity = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_capacity(index, &capacity);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get HNSW index capacity", error);
        return 0;
    }
    
    return static_cast<jlong>(capacity);
}

// Check if HNSWIndex contains vector
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexContains(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jlong id) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Call the C function to check if vector exists
    int exists = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_contains(index, static_cast<uint64_t>(id), &exists);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return JNI_FALSE;
    }
    
    return exists != 0 ? JNI_TRUE : JNI_FALSE;
}

// Get vector by ID from HNSWIndex
JNIEXPORT jfloatArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetVector(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jlong id) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    // Get vector dimension
    size_t dimension;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_dimension(index, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector dimension", error);
        return nullptr;
    }
    
    // Allocate memory for vector
    float* vector = new float[dimension];
    if (vector == nullptr) {
        throwLlamaMobileVDException(env, "Memory allocation failed", LLAMA_MOBILE_VD_OUT_OF_MEMORY);
        return nullptr;
    }
    
    // Call the C function to get the vector
    error = llama_mobile_vd_hnsw_index_get_vector(index, static_cast<uint64_t>(id), vector, dimension);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        delete[] vector;
        throwLlamaMobileVDException(env, "Failed to get vector", error);
        return nullptr;
    }
    
    // Convert C++ vector to Java float array
    jfloatArray result = env->NewFloatArray(static_cast<jsize>(dimension));
    if (result == nullptr) {
        delete[] vector;
        throwLlamaMobileVDException(env, "Failed to create Java array", LLAMA_MOBILE_VD_OUT_OF_MEMORY);
        return nullptr;
    }
    
    env->SetFloatArrayRegion(result, 0, static_cast<jsize>(dimension), vector);
    
    // Free the native vector
    delete[] vector;
    
    return result;
}

// Save HNSWIndex to file
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSave(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jstring filename) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Convert Java string to C++ string
    const char* filenameStr = env->GetStringUTFChars(filename, nullptr);
    if (filenameStr == nullptr) {
        return JNI_FALSE;
    }
    
    // Call the C function to save the HNSW index
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_save(index, filenameStr);
    
    env->ReleaseStringUTFChars(filename, filenameStr);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return JNI_FALSE;
    }
    
    return JNI_TRUE;
}

// Load HNSWIndex from file
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexLoad(
        JNIEnv* env,
        jclass clazz,
        jstring filename) {
    
    // Convert Java string to C++ string
    const char* filenameStr = env->GetStringUTFChars(filename, nullptr);
    if (filenameStr == nullptr) {
        return 0;
    }
    
    LLAMA_MOBILE_VD_HNSWIndex index = nullptr;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_load(filenameStr, &index);
    
    env->ReleaseStringUTFChars(filename, filenameStr);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to load HNSW index", error);
        return 0;
    }
    
    return registerNativePointer(index);
}

// Destroy HNSWIndex
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexDestroy(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    // Get the native HNSW index pointer
    LLAMA_MOBILE_VD_HNSWIndex index = static_cast<LLAMA_MOBILE_VD_HNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        return;
    }
    
    // Call the C function to destroy the HNSW index
    llama_mobile_vd_hnsw_index_destroy(index);
    
    // Remove the native pointer from the map
    removeNativePointer(indexId);
}

// ==========================
// MMapVectorStoreBuilder JNI methods
// ==========================

// Create MMapVectorStoreBuilder
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderCreate(
        JNIEnv* env,
        jclass clazz,
        jint dimension,
        jint metric) {
    
    auto it = distanceMetricMap.find(metric);
    if (it == distanceMetricMap.end()) {
        throwLlamaMobileVDException(env, "Invalid distance metric", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = nullptr;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_builder_create(
        static_cast<size_t>(dimension),
        it->second,
        &builder);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to create MMap vector store builder", error);
        return 0;
    }
    
    return registerNativePointer(builder);
}

// Add vector to MMapVectorStoreBuilder
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderAddVector(
        JNIEnv* env,
        jclass clazz,
        jlong builderId,
        jlong id,
        jfloatArray vector) {
    
    // Get the native builder pointer
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMap vector store builder", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Convert Java float array to C++ vector
    std::vector<float> vec = jfloatArrayToVector(env, vector);
    if (vec.empty()) {
        throwLlamaMobileVDException(env, "Invalid vector", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Call the C function to add the vector
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_builder_add(builder, static_cast<uint64_t>(id), vec.data());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to add vector to MMap vector store builder", error);
        return JNI_FALSE;
    }
    
    return JNI_TRUE;
}

// Reserve capacity in MMapVectorStoreBuilder
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderReserve(
        JNIEnv* env,
        jclass clazz,
        jlong builderId,
        jlong capacity) {
    
    // Get the native builder pointer
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMap vector store builder", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Call the C function to reserve capacity
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_builder_reserve(builder, static_cast<size_t>(capacity));
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to reserve capacity in MMap vector store builder", error);
        return JNI_FALSE;
    }
    
    return JNI_TRUE;
}

// Save MMapVectorStoreBuilder
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderSave(
        JNIEnv* env,
        jclass clazz,
        jlong builderId,
        jstring filename) {
    
    // Get the native builder pointer
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMap vector store builder", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    // Convert Java string to C++ string
    const char* filenameStr = env->GetStringUTFChars(filename, nullptr);
    if (filenameStr == nullptr) {
        return JNI_FALSE;
    }
    
    // Call the C function to save the MMap vector store
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_builder_save(builder, filenameStr);
    
    env->ReleaseStringUTFChars(filename, filenameStr);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to save MMap vector store", error);
        return JNI_FALSE;
    }
    
    return JNI_TRUE;
}

// Get MMapVectorStoreBuilder size
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderGetSize(
        JNIEnv* env,
        jclass clazz,
        jlong builderId) {
    
    // Get the native builder pointer
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMap vector store builder", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the size
    size_t size = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_builder_size(builder, &size);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get MMap vector store builder size", error);
        return 0;
    }
    
    return static_cast<jlong>(size);
}

// Get MMapVectorStoreBuilder dimension
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderGetDimension(
        JNIEnv* env,
        jclass clazz,
        jlong builderId) {
    
    // Get the native builder pointer
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMap vector store builder", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    // Call the C function to get the dimension
    size_t dimension = 0;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_builder_dimension(builder, &dimension);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get MMap vector store builder dimension", error);
        return 0;
    }
    
    return static_cast<jint>(dimension);
}

// Destroy MMapVectorStoreBuilder
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderDestroy(
        JNIEnv* env,
        jclass clazz,
        jlong builderId) {
    
    // Get the native builder pointer
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        return;
    }
    
    // Call the C function to destroy the builder
    llama_mobile_vd_mmap_vector_store_builder_destroy(builder);
    
    // Remove the native pointer from the map
    removeNativePointer(builderId);
}

// ==========================
// Version information JNI methods
// ==========================

// Get version string
JNIEXPORT jstring JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeGetVersion(
        JNIEnv* env,
        jclass clazz) {
    
    // Call the C function to get the version string
    const char* version = llama_mobile_vd_version();
    
    // Convert C string to Java string
    return env->NewStringUTF(version);
}

// Get version major
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeGetVersionMajor(
        JNIEnv* env,
        jclass clazz) {
    
    // Call the C function to get the version major
    return static_cast<jint>(llama_mobile_vd_version_major());
}

// Get version minor
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeGetVersionMinor(
        JNIEnv* env,
        jclass clazz) {
    
    // Call the C function to get the version minor
    return static_cast<jint>(llama_mobile_vd_version_minor());
}

// Get version patch
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeGetVersionPatch(
        JNIEnv* env,
        jclass clazz) {
    
    // Call the C function to get the version patch
    return static_cast<jint>(llama_mobile_vd_version_patch());
}

#ifdef __cplusplus
}
#endif
