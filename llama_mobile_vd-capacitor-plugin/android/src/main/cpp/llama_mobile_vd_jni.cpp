#include <jni.h>
#include <vector>
#include "llama_mobile_vd_wrapper.h"

// Helper function to convert Java double array to C float vector
std::vector<float> jdoubleArrayToFloatVector(JNIEnv* env, jdoubleArray jarray) {
    jsize length = env->GetArrayLength(jarray);
    std::vector<float> vec(length);
    jdouble* elements = env->GetDoubleArrayElements(jarray, NULL);
    for (int i = 0; i < length; i++) {
        vec[i] = static_cast<float>(elements[i]);
    }
    env->ReleaseDoubleArrayElements(jarray, elements, JNI_ABORT);
    return vec;
}

// Helper function to convert Java double array to C float array
float* jdoubleArrayToFloatArray(JNIEnv* env, jdoubleArray jarray, int& length) {
    length = env->GetArrayLength(jarray);
    float* array = new float[length];
    jdouble* elements = env->GetDoubleArrayElements(jarray, NULL);
    for (int i = 0; i < length; i++) {
        array[i] = static_cast<float>(elements[i]);
    }
    env->ReleaseDoubleArrayElements(jarray, elements, JNI_ABORT);
    return array;
}

// Helper function to convert C float vector to Java double array
jdoubleArray floatVectorToJDoubleArray(JNIEnv* env, const std::vector<float>& vec) {
    jdoubleArray jarray = env->NewDoubleArray(vec.size());
    jdouble* elements = env->GetDoubleArrayElements(jarray, NULL);
    for (int i = 0; i < vec.size(); i++) {
        elements[i] = static_cast<double>(vec[i]);
    }
    env->ReleaseDoubleArrayElements(jarray, elements, 0);
    return jarray;
}

// Helper function to convert Java int array to C int vector
std::vector<int> jintArrayToIntVector(JNIEnv* env, jintArray jarray) {
    jsize length = env->GetArrayLength(jarray);
    std::vector<int> vec(length);
    jint* elements = env->GetIntArrayElements(jarray, NULL);
    for (int i = 0; i < length; i++) {
        vec[i] = elements[i];
    }
    env->ReleaseIntArrayElements(jarray, elements, JNI_ABORT);
    return vec;
}

// Helper function to convert C search results to Java arrays
void searchResultsToJavaArrays(JNIEnv* env, const std::vector<LLAMA_MOBILE_VD_SearchResult>& results, jintArray& idsArray, jdoubleArray& distancesArray) {
    jint* ids = env->GetIntArrayElements(idsArray, NULL);
    jdouble* distances = env->GetDoubleArrayElements(distancesArray, NULL);
    
    for (int i = 0; i < results.size(); i++) {
        ids[i] = static_cast<int>(results[i].id);
        distances[i] = static_cast<double>(results[i].distance);
    }
    
    env->ReleaseIntArrayElements(idsArray, ids, 0);
    env->ReleaseDoubleArrayElements(distancesArray, distances, 0);
}

// VectorStore functions

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT jstring JNICALL Java_com_llamamobile_vd_LlamaMobileVD_getVersion(JNIEnv* env, jclass clazz) {
    const char* version = llama_mobile_vd_version();
    return env->NewStringUTF(version);
}

JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreCreate(JNIEnv* env, jclass clazz, jint dimension, jint metric) {
    LLAMA_MOBILE_VD_VectorStore store;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_vector_store_create(static_cast<size_t>(dimension), static_cast<LLAMA_MOBILE_VD_DistanceMetric>(metric), &store);
    if (error != LLAMA_MOBILE_VD_OK) {
        return 0;
    }
    return reinterpret_cast<jlong>(store);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreDestroy(JNIEnv* env, jclass clazz, jlong storeId) {
    LLAMA_MOBILE_VD_VectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_VectorStore>(storeId);
    llama_mobile_vd_vector_store_destroy(store);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreAddVectors__JLjava_util_List_2(JNIEnv* env, jclass clazz, jlong storeId, jobject vectors) {
    LLAMA_MOBILE_VD_VectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_VectorStore>(storeId);
    
    // Get the list size
    jmethodID sizeMethod = env->GetMethodID(env->GetObjectClass(vectors), "size", "()I");
    int size = env->CallIntMethod(vectors, sizeMethod);
    
    // Iterate through the list
    jmethodID getMethod = env->GetMethodID(env->GetObjectClass(vectors), "get", "(I)Ljava/lang/Object;");
    for (int i = 0; i < size; i++) {
        jobject element = env->CallObjectMethod(vectors, getMethod, i);
        jdoubleArray jvector = static_cast<jdoubleArray>(element);
        std::vector<float> vector = jdoubleArrayToFloatVector(env, jvector);
        llama_mobile_vd_vector_store_add(store, static_cast<uint64_t>(i), vector.data());
        env->DeleteLocalRef(element);
    }
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreAddVectors__JLjava_util_List_2_3I(JNIEnv* env, jclass clazz, jlong storeId, jobject vectors, jintArray ids) {
    LLAMA_MOBILE_VD_VectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_VectorStore>(storeId);
    
    // Get the list size
    jmethodID sizeMethod = env->GetMethodID(env->GetObjectClass(vectors), "size", "()I");
    int size = env->CallIntMethod(vectors, sizeMethod);
    
    // Get the ids array
    std::vector<int> idVector = jintArrayToIntVector(env, ids);
    
    // Iterate through the list
    jmethodID getMethod = env->GetMethodID(env->GetObjectClass(vectors), "get", "(I)Ljava/lang/Object;");
    for (int i = 0; i < size; i++) {
        jobject element = env->CallObjectMethod(vectors, getMethod, i);
        jdoubleArray jvector = static_cast<jdoubleArray>(element);
        std::vector<float> vector = jdoubleArrayToFloatVector(env, jvector);
        llama_mobile_vd_vector_store_add(store, static_cast<uint64_t>(idVector[i]), vector.data());
        env->DeleteLocalRef(element);
    }
}

JNIEXPORT jdoubleArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetVector(JNIEnv* env, jclass clazz, jlong storeId, jint id) {
    LLAMA_MOBILE_VD_VectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_VectorStore>(storeId);
    
    // Get the dimension
    size_t dimension;
    llama_mobile_vd_vector_store_dimension(store, &dimension);
    
    // Get the vector
    std::vector<float> vector(dimension);
    llama_mobile_vd_vector_store_get(store, static_cast<uint64_t>(id), vector.data(), dimension);
    
    return floatVectorToJDoubleArray(env, vector);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreSearch(JNIEnv* env, jclass clazz, jlong storeId, jdoubleArray queryVector, jint k, jintArray idsArray, jdoubleArray distancesArray) {
    LLAMA_MOBILE_VD_VectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_VectorStore>(storeId);
    
    // Convert query vector
    int queryLength;
    float* query = jdoubleArrayToFloatArray(env, queryVector, queryLength);
    
    // Prepare results
    std::vector<LLAMA_MOBILE_VD_SearchResult> results(static_cast<size_t>(k));
    
    // Search
    llama_mobile_vd_vector_store_search(store, query, static_cast<size_t>(k), results.data(), results.size());
    
    // Convert results to Java arrays
    searchResultsToJavaArrays(env, results, idsArray, distancesArray);
    
    // Clean up
    delete[] query;
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreRemoveVectors(JNIEnv* env, jclass clazz, jlong storeId, jintArray ids) {
    LLAMA_MOBILE_VD_VectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_VectorStore>(storeId);
    
    // Get the ids array
    std::vector<int> idVector = jintArrayToIntVector(env, ids);
    
    // Remove vectors
    for (int id : idVector) {
        int removed;
        llama_mobile_vd_vector_store_remove(store, static_cast<uint64_t>(id), &removed);
    }
}

JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGetCount(JNIEnv* env, jclass clazz, jlong storeId) {
    LLAMA_MOBILE_VD_VectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_VectorStore>(storeId);
    
    // Get the size
    size_t size;
    llama_mobile_vd_vector_store_size(store, &size);
    
    return static_cast<jint>(size);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreClear(JNIEnv* env, jclass clazz, jlong storeId) {
    LLAMA_MOBILE_VD_VectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_VectorStore>(storeId);
    llama_mobile_vd_vector_store_clear(store);
}

// HNSWIndex functions

JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCreate(JNIEnv* env, jclass clazz, jint dimension, jint metric, jlong maxElements) {
    // Create the HNSW index
    LLAMA_MOBILE_VD_HNSWIndex index;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_create(
        static_cast<size_t>(dimension),
        static_cast<LLAMA_MOBILE_VD_DistanceMetric>(metric),
        static_cast<size_t>(maxElements),
        &index
    );
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return 0;
    }
    
    return reinterpret_cast<jlong>(index);
}

JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCreateWithParams(JNIEnv* env, jclass clazz, jint dimension, jint metric, jlong maxElements, jint m, jint efConstruction, jint seed) {
    // Create the HNSW index with parameters
    LLAMA_MOBILE_VD_HNSWIndex index;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_hnsw_index_create_with_params(
        static_cast<size_t>(dimension),
        static_cast<LLAMA_MOBILE_VD_DistanceMetric>(metric),
        static_cast<size_t>(maxElements),
        static_cast<size_t>(m),
        static_cast<size_t>(efConstruction),
        static_cast<uint32_t>(seed),
        &index
    );
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return 0;
    }
    
    return reinterpret_cast<jlong>(index);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexDestroy(JNIEnv* env, jclass clazz, jlong indexId) {
    LLAMA_MOBILE_VD_HNSWIndex index = reinterpret_cast<LLAMA_MOBILE_VD_HNSWIndex>(indexId);
    llama_mobile_vd_hnsw_index_destroy(index);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSearch__J_3D_I_3I_3D(JNIEnv* env, jclass clazz, jlong indexId, jdoubleArray queryVector, jint k, jintArray idsArray, jdoubleArray distancesArray) {
    LLAMA_MOBILE_VD_HNSWIndex index = reinterpret_cast<LLAMA_MOBILE_VD_HNSWIndex>(indexId);
    
    // Convert query vector
    int queryLength;
    float* query = jdoubleArrayToFloatArray(env, queryVector, queryLength);
    
    // Prepare results
    std::vector<LLAMA_MOBILE_VD_SearchResult> results(static_cast<size_t>(k));
    
    // Search
    llama_mobile_vd_hnsw_index_search(index, query, static_cast<size_t>(k), results.data(), results.size());
    
    // Convert results to Java arrays
    searchResultsToJavaArrays(env, results, idsArray, distancesArray);
    
    // Clean up
    delete[] query;
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSearch__J_3DII_3I_3D(JNIEnv* env, jclass clazz, jlong indexId, jdoubleArray queryVector, jint k, jint efSearch, jintArray idsArray, jdoubleArray distancesArray) {
    LLAMA_MOBILE_VD_HNSWIndex index = reinterpret_cast<LLAMA_MOBILE_VD_HNSWIndex>(indexId);
    
    // Set ef_search
    llama_mobile_vd_hnsw_index_set_ef_search(index, static_cast<size_t>(efSearch));
    
    // Convert query vector
    int queryLength;
    float* query = jdoubleArrayToFloatArray(env, queryVector, queryLength);
    
    // Prepare results
    std::vector<LLAMA_MOBILE_VD_SearchResult> results(static_cast<size_t>(k));
    
    // Search
    llama_mobile_vd_hnsw_index_search(index, query, static_cast<size_t>(k), results.data(), results.size());
    
    // Convert results to Java arrays
    searchResultsToJavaArrays(env, results, idsArray, distancesArray);
    
    // Clean up
    delete[] query;
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexAddVectors__JLjava_util_List_2(JNIEnv* env, jclass clazz, jlong indexId, jobject vectors) {
    LLAMA_MOBILE_VD_HNSWIndex index = reinterpret_cast<LLAMA_MOBILE_VD_HNSWIndex>(indexId);
    
    // Get the list size
    jmethodID sizeMethod = env->GetMethodID(env->GetObjectClass(vectors), "size", "()I");
    int size = env->CallIntMethod(vectors, sizeMethod);
    
    // Iterate through the list
    jmethodID getMethod = env->GetMethodID(env->GetObjectClass(vectors), "get", "(I)Ljava/lang/Object;");
    for (int i = 0; i < size; i++) {
        jobject element = env->CallObjectMethod(vectors, getMethod, i);
        jdoubleArray jvector = static_cast<jdoubleArray>(element);
        std::vector<float> vector = jdoubleArrayToFloatVector(env, jvector);
        llama_mobile_vd_hnsw_index_add(index, static_cast<uint64_t>(i), vector.data());
        env->DeleteLocalRef(element);
    }
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexAddVectors__JLjava_util_List_2_3I(JNIEnv* env, jclass clazz, jlong indexId, jobject vectors, jintArray ids) {
    LLAMA_MOBILE_VD_HNSWIndex index = reinterpret_cast<LLAMA_MOBILE_VD_HNSWIndex>(indexId);
    
    // Get the list size
    jmethodID sizeMethod = env->GetMethodID(env->GetObjectClass(vectors), "size", "()I");
    int size = env->CallIntMethod(vectors, sizeMethod);
    
    // Get the ids array
    std::vector<int> idVector = jintArrayToIntVector(env, ids);
    
    // Iterate through the list
    jmethodID getMethod = env->GetMethodID(env->GetObjectClass(vectors), "get", "(I)Ljava/lang/Object;");
    for (int i = 0; i < size; i++) {
        jobject element = env->CallObjectMethod(vectors, getMethod, i);
        jdoubleArray jvector = static_cast<jdoubleArray>(element);
        std::vector<float> vector = jdoubleArrayToFloatVector(env, jvector);
        llama_mobile_vd_hnsw_index_add(index, static_cast<uint64_t>(idVector[i]), vector.data());
        env->DeleteLocalRef(element);
    }
}

JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetCount(JNIEnv* env, jclass clazz, jlong indexId) {
    LLAMA_MOBILE_VD_HNSWIndex index = reinterpret_cast<LLAMA_MOBILE_VD_HNSWIndex>(indexId);
    
    // Get the size
    size_t size;
    llama_mobile_vd_hnsw_index_size(index, &size);
    
    return static_cast<jint>(size);
}

// MMapVectorStoreBuilder functions

JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderCreate(JNIEnv* env, jclass clazz, jint dimension, jint metric) {
    printf("JNI: nativeMMapVectorStoreBuilderCreate called with dimension=%d, metric=%d\n", dimension, metric);
    
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder;
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_builder_create(
        static_cast<size_t>(dimension),
        static_cast<LLAMA_MOBILE_VD_DistanceMetric>(metric),
        &builder
    );
    
    printf("JNI: nativeMMapVectorStoreBuilderCreate error=%d, builder=%p\n", error, builder);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return 0;
    }
    
    return reinterpret_cast<jlong>(builder);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderDestroy(JNIEnv* env, jclass clazz, jlong builderId) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = reinterpret_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(builderId);
    llama_mobile_vd_mmap_vector_store_builder_destroy(builder);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderAddVectors__JLjava_util_List_2(JNIEnv* env, jclass clazz, jlong builderId, jobject vectors) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = reinterpret_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(builderId);
    
    // Get the list size
    jmethodID sizeMethod = env->GetMethodID(env->GetObjectClass(vectors), "size", "()I");
    int size = env->CallIntMethod(vectors, sizeMethod);
    
    // Iterate through the list
    jmethodID getMethod = env->GetMethodID(env->GetObjectClass(vectors), "get", "(I)Ljava/lang/Object;");
    for (int i = 0; i < size; i++) {
        jobject element = env->CallObjectMethod(vectors, getMethod, i);
        jdoubleArray jvector = static_cast<jdoubleArray>(element);
        std::vector<float> vector = jdoubleArrayToFloatVector(env, jvector);
        llama_mobile_vd_mmap_vector_store_builder_add(builder, static_cast<uint64_t>(i), vector.data());
        env->DeleteLocalRef(element);
    }
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderAddVectors__JLjava_util_List_2_3I(JNIEnv* env, jclass clazz, jlong builderId, jobject vectors, jintArray ids) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = reinterpret_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(builderId);
    
    // Get the list size
    jmethodID sizeMethod = env->GetMethodID(env->GetObjectClass(vectors), "size", "()I");
    int size = env->CallIntMethod(vectors, sizeMethod);
    
    // Get the ids array
    std::vector<int> idVector = jintArrayToIntVector(env, ids);
    
    // Iterate through the list
    jmethodID getMethod = env->GetMethodID(env->GetObjectClass(vectors), "get", "(I)Ljava/lang/Object;");
    for (int i = 0; i < size; i++) {
        jobject element = env->CallObjectMethod(vectors, getMethod, i);
        jdoubleArray jvector = static_cast<jdoubleArray>(element);
        std::vector<float> vector = jdoubleArrayToFloatVector(env, jvector);
        llama_mobile_vd_mmap_vector_store_builder_add(builder, static_cast<uint64_t>(idVector[i]), vector.data());
        env->DeleteLocalRef(element);
    }
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderSave(JNIEnv* env, jclass clazz, jlong builderId, jstring path) {
    LLAMA_MOBILE_VD_MMapVectorStoreBuilder builder = reinterpret_cast<LLAMA_MOBILE_VD_MMapVectorStoreBuilder>(builderId);
    const char* cpath = env->GetStringUTFChars(path, NULL);
    llama_mobile_vd_mmap_vector_store_builder_save(builder, cpath);
    env->ReleaseStringUTFChars(path, cpath);
}

// MMapVectorStore functions

JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreOpen(JNIEnv* env, jclass clazz, jstring path) {
    LLAMA_MOBILE_VD_MMapVectorStore store;
    const char* cpath = env->GetStringUTFChars(path, NULL);
    LLAMA_MOBILE_VD_Error error = llama_mobile_vd_mmap_vector_store_open(cpath, &store);
    env->ReleaseStringUTFChars(path, cpath);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        return 0;
    }
    
    return reinterpret_cast<jlong>(store);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreClose(JNIEnv* env, jclass clazz, jlong storeId) {
    LLAMA_MOBILE_VD_MMapVectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_MMapVectorStore>(storeId);
    llama_mobile_vd_mmap_vector_store_close(store);
}

JNIEXPORT jdoubleArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetVector(JNIEnv* env, jclass clazz, jlong storeId, jint id) {
    LLAMA_MOBILE_VD_MMapVectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_MMapVectorStore>(storeId);
    
    // Get the dimension
    size_t dimension;
    llama_mobile_vd_mmap_vector_store_dimension(store, &dimension);
    
    // Get the vector
    std::vector<float> vector(dimension);
    llama_mobile_vd_mmap_vector_store_get(store, static_cast<uint64_t>(id), vector.data(), dimension);
    
    return floatVectorToJDoubleArray(env, vector);
}

JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreSearch(JNIEnv* env, jclass clazz, jlong storeId, jdoubleArray queryVector, jint k, jintArray idsArray, jdoubleArray distancesArray) {
    LLAMA_MOBILE_VD_MMapVectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_MMapVectorStore>(storeId);
    
    // Convert query vector
    int queryLength;
    float* query = jdoubleArrayToFloatArray(env, queryVector, queryLength);
    
    // Prepare results
    std::vector<LLAMA_MOBILE_VD_SearchResult> results(static_cast<size_t>(k));
    
    // Search
    llama_mobile_vd_mmap_vector_store_search(store, query, static_cast<size_t>(k), results.data(), results.size());
    
    // Convert results to Java arrays
    searchResultsToJavaArrays(env, results, idsArray, distancesArray);
    
    // Clean up
    delete[] query;
}

JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGetCount(JNIEnv* env, jclass clazz, jlong storeId) {
    LLAMA_MOBILE_VD_MMapVectorStore store = reinterpret_cast<LLAMA_MOBILE_VD_MMapVectorStore>(storeId);
    
    // Get the size
    size_t size;
    llama_mobile_vd_mmap_vector_store_size(store, &size);
    
    return static_cast<jint>(size);
}

#ifdef __cplusplus
}
#endif