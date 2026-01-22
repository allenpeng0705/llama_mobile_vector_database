package com.llamamobile.vd

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableArray

class LlamaMobileVD(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "LlamaMobileVD"
    }

    // VectorStore methods
    @ReactMethod
    fun vectorStoreCreate(dimension: Int, metric: Int, promise: Promise) {
        val storePtr = nativeVectorStoreCreate(dimension, metric)
        if (storePtr != 0L) {
            vectorStoreMap[storePtr] = storePtr
            promise.resolve(storePtr)
        } else {
            promise.reject("CREATE_FAILED", "Failed to create vector store")
        }
    }

    @ReactMethod
    fun vectorStoreAddVector(storeId: Long, id: Long, vector: ReadableArray, promise: Promise) {
        val vectorArray = FloatArray(vector.size()) {
            vector.getDouble(it).toFloat()
        }
        try {
            nativeVectorStoreAddVector(storeId, id, vectorArray)
            promise.resolve(true)
        } catch (e: Exception) {
            promise.reject("ADD_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreSearch(storeId: Long, queryVector: ReadableArray, k: Int, promise: Promise) {
        val vectorArray = FloatArray(queryVector.size()) {
            queryVector.getDouble(it).toFloat()
        }
        try {
            val results = nativeVectorStoreSearch(storeId, vectorArray, k)
            // Convert jobjectArray to Kotlin array
            val searchResults = mutableListOf<Map<String, Any>>()
            if (results != null) {
                for (i in 0 until results.size()) {
                    val result = results[i] as Any
                    // Assuming result is a SearchResult object with id and distance properties
                    // This conversion might need adjustment based on actual implementation
                    searchResults.add(mapOf(
                        "id" to (result.javaClass.getMethod("getId").invoke(result) as Long),
                        "distance" to (result.javaClass.getMethod("getDistance").invoke(result) as Float)
                    ))
                }
            }
            promise.resolve(searchResults)
        } catch (e: Exception) {
            promise.reject("SEARCH_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreGetVector(storeId: Long, id: Long, promise: Promise) {
        try {
            val vector = nativeVectorStoreGetVector(storeId, id)
            // Convert FloatArray to List<Double>
            val result = vector?.map { it.toDouble() }
            promise.resolve(result)
        } catch (e: Exception) {
            promise.reject("GET_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreRemoveVector(storeId: Long, id: Long, promise: Promise) {
        try {
            val success = nativeVectorStoreRemoveVector(storeId, id)
            promise.resolve(success)
        } catch (e: Exception) {
            promise.reject("REMOVE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreContains(storeId: Long, id: Long, promise: Promise) {
        try {
            val contains = nativeVectorStoreContains(storeId, id)
            promise.resolve(contains)
        } catch (e: Exception) {
            promise.reject("CONTAINS_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreGetSize(storeId: Long, promise: Promise) {
        try {
            val size = nativeVectorStoreGetSize(storeId)
            promise.resolve(size)
        } catch (e: Exception) {
            promise.reject("GET_SIZE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreGetDimension(storeId: Long, promise: Promise) {
        try {
            val dimension = nativeVectorStoreGetDimension(storeId)
            promise.resolve(dimension)
        } catch (e: Exception) {
            promise.reject("GET_DIMENSION_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreGetMetric(storeId: Long, promise: Promise) {
        try {
            val metric = nativeVectorStoreGetMetric(storeId)
            promise.resolve(metric)
        } catch (e: Exception) {
            promise.reject("GET_METRIC_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreUpdateVector(storeId: Long, id: Long, vector: ReadableArray, promise: Promise) {
        val vectorArray = FloatArray(vector.size()) {
            vector.getDouble(it).toFloat()
        }
        try {
            val success = nativeVectorStoreUpdateVector(storeId, id, vectorArray)
            promise.resolve(success)
        } catch (e: Exception) {
            promise.reject("UPDATE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreReserve(storeId: Long, capacity: Int, promise: Promise) {
        try {
            val success = nativeVectorStoreReserve(storeId, capacity.toLong())
            promise.resolve(success)
        } catch (e: Exception) {
            promise.reject("RESERVE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreClear(storeId: Long, promise: Promise) {
        try {
            nativeVectorStoreClear(storeId)
            promise.resolve(true)
        } catch (e: Exception) {
            promise.reject("CLEAR_FAILED", e.message)
        }
    }

    @ReactMethod
    fun vectorStoreDestroy(storeId: Long, promise: Promise) {
        try {
            nativeVectorStoreDestroy(storeId)
            vectorStoreMap.remove(storeId)
            promise.resolve(true)
        } catch (e: Exception) {
            promise.reject("DESTROY_FAILED", e.message)
        }
    }

    // HNSWIndex methods
    @ReactMethod
    fun hnswIndexCreate(dimension: Int, metric: Int, maxElements: Int, promise: Promise) {
        try {
            val indexPtr = nativeHNSWIndexCreate(dimension, metric, maxElements.toLong())
            if (indexPtr != 0L) {
                hnswIndexMap[indexPtr] = indexPtr
                promise.resolve(indexPtr)
            } else {
                promise.reject("CREATE_FAILED", "Failed to create HNSW index")
            }
        } catch (e: Exception) {
            promise.reject("CREATE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexCreateWithParams(dimension: Int, metric: Int, maxElements: Int, M: Int, efConstruction: Int, seed: Int, promise: Promise) {
        try {
            val indexPtr = nativeHNSWIndexCreateWithParams(dimension, metric, maxElements.toLong(), M, efConstruction, seed)
            if (indexPtr != 0L) {
                hnswIndexMap[indexPtr] = indexPtr
                promise.resolve(indexPtr)
            } else {
                promise.reject("CREATE_FAILED", "Failed to create HNSW index")
            }
        } catch (e: Exception) {
            promise.reject("CREATE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexAddVector(indexId: Long, id: Long, vector: ReadableArray, promise: Promise) {
        val vectorArray = FloatArray(vector.size()) {
            vector.getDouble(it).toFloat()
        }
        try {
            val success = nativeHNSWIndexAddVector(indexId, id, vectorArray)
            promise.resolve(success)
        } catch (e: Exception) {
            promise.reject("ADD_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexSearch(indexId: Long, queryVector: ReadableArray, k: Int, promise: Promise) {
        val vectorArray = FloatArray(queryVector.size()) {
            queryVector.getDouble(it).toFloat()
        }
        try {
            val results = nativeHNSWIndexSearch(indexId, vectorArray, k)
            // Convert jobjectArray to Kotlin array
            val searchResults = mutableListOf<Map<String, Any>>()
            if (results != null) {
                for (i in 0 until results.size()) {
                    val result = results[i] as Any
                    // Assuming result is a SearchResult object with id and distance properties
                    searchResults.add(mapOf(
                        "id" to (result.javaClass.getMethod("getId").invoke(result) as Long),
                        "distance" to (result.javaClass.getMethod("getDistance").invoke(result) as Float)
                    ))
                }
            }
            promise.resolve(searchResults)
        } catch (e: Exception) {
            promise.reject("SEARCH_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexSetEfSearch(indexId: Long, efSearch: Int, promise: Promise) {
        try {
            val success = nativeHNSWIndexSetEfSearch(indexId, efSearch)
            promise.resolve(success)
        } catch (e: Exception) {
            promise.reject("SET_EF_SEARCH_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexGetEfSearch(indexId: Long, promise: Promise) {
        try {
            val efSearch = nativeHNSWIndexGetEfSearch(indexId)
            promise.resolve(efSearch)
        } catch (e: Exception) {
            promise.reject("GET_EF_SEARCH_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexGetSize(indexId: Long, promise: Promise) {
        try {
            val size = nativeHNSWIndexGetSize(indexId)
            promise.resolve(size)
        } catch (e: Exception) {
            promise.reject("GET_SIZE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexGetDimension(indexId: Long, promise: Promise) {
        try {
            val dimension = nativeHNSWIndexGetDimension(indexId)
            promise.resolve(dimension)
        } catch (e: Exception) {
            promise.reject("GET_DIMENSION_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexGetCapacity(indexId: Long, promise: Promise) {
        try {
            val capacity = nativeHNSWIndexGetCapacity(indexId)
            promise.resolve(capacity)
        } catch (e: Exception) {
            promise.reject("GET_CAPACITY_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexContains(indexId: Long, id: Long, promise: Promise) {
        try {
            val contains = nativeHNSWIndexContains(indexId, id)
            promise.resolve(contains)
        } catch (e: Exception) {
            promise.reject("CONTAINS_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexGetVector(indexId: Long, id: Long, promise: Promise) {
        try {
            val vector = nativeHNSWIndexGetVector(indexId, id)
            // Convert FloatArray to List<Double>
            val result = vector?.map { it.toDouble() }
            promise.resolve(result)
        } catch (e: Exception) {
            promise.reject("GET_VECTOR_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexSave(indexId: Long, filename: String, promise: Promise) {
        try {
            val success = nativeHNSWIndexSave(indexId, filename)
            promise.resolve(success)
        } catch (e: Exception) {
            promise.reject("SAVE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexLoad(filename: String, promise: Promise) {
        try {
            val indexPtr = nativeHNSWIndexLoad(filename)
            if (indexPtr != 0L) {
                hnswIndexMap[indexPtr] = indexPtr
                promise.resolve(indexPtr)
            } else {
                promise.reject("LOAD_FAILED", "Failed to load HNSW index")
            }
        } catch (e: Exception) {
            promise.reject("LOAD_FAILED", e.message)
        }
    }

    @ReactMethod
    fun hnswIndexDestroy(indexId: Long, promise: Promise) {
        try {
            nativeHNSWIndexDestroy(indexId)
            hnswIndexMap.remove(indexId)
            promise.resolve(true)
        } catch (e: Exception) {
            promise.reject("DESTROY_FAILED", e.message)
        }
    }

    // MMapVectorStoreBuilder methods
    @ReactMethod
    fun mmapVectorStoreBuilderCreate(dimension: Int, metric: Int, promise: Promise) {
        try {
            val builderPtr = nativeMMapVectorStoreBuilderCreate(dimension, metric)
            if (builderPtr != 0L) {
                mmapVectorStoreBuilderMap[builderPtr] = builderPtr
                promise.resolve(builderPtr)
            } else {
                promise.reject("CREATE_FAILED", "Failed to create MMapVectorStoreBuilder")
            }
        } catch (e: Exception) {
            promise.reject("CREATE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreBuilderAddVector(builderId: Long, id: Long, vector: ReadableArray, promise: Promise) {
        val vectorArray = FloatArray(vector.size()) {
            vector.getDouble(it).toFloat()
        }
        try {
            val success = nativeMMapVectorStoreBuilderAddVector(builderId, id, vectorArray)
            promise.resolve(success)
        } catch (e: Exception) {
            promise.reject("ADD_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreBuilderReserve(builderId: Long, capacity: Int, promise: Promise) {
        try {
            val success = nativeMMapVectorStoreBuilderReserve(builderId, capacity.toLong())
            promise.resolve(success)
        } catch (e: Exception) {
            promise.reject("RESERVE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreBuilderSave(builderId: Long, filename: String, promise: Promise) {
        try {
            val success = nativeMMapVectorStoreBuilderSave(builderId, filename)
            promise.resolve(success)
        } catch (e: Exception) {
            promise.reject("SAVE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreBuilderGetSize(builderId: Long, promise: Promise) {
        try {
            val size = nativeMMapVectorStoreBuilderGetSize(builderId)
            promise.resolve(size)
        } catch (e: Exception) {
            promise.reject("GET_SIZE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreBuilderGetDimension(builderId: Long, promise: Promise) {
        try {
            val dimension = nativeMMapVectorStoreBuilderGetDimension(builderId)
            promise.resolve(dimension)
        } catch (e: Exception) {
            promise.reject("GET_DIMENSION_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreBuilderDestroy(builderId: Long, promise: Promise) {
        try {
            nativeMMapVectorStoreBuilderDestroy(builderId)
            mmapVectorStoreBuilderMap.remove(builderId)
            promise.resolve(true)
        } catch (e: Exception) {
            promise.reject("DESTROY_FAILED", e.message)
        }
    }

    // MMapVectorStore methods
    @ReactMethod
    fun mmapVectorStoreOpen(filename: String, promise: Promise) {
        try {
            val storePtr = nativeMMapVectorStoreOpen(filename)
            if (storePtr != 0L) {
                mmapVectorStoreMap[storePtr] = storePtr
                promise.resolve(storePtr)
            } else {
                promise.reject("OPEN_FAILED", "Failed to open MMapVectorStore")
            }
        } catch (e: Exception) {
            promise.reject("OPEN_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreGetVector(storeId: Long, id: Long, promise: Promise) {
        try {
            val vector = nativeMMapVectorStoreGetVector(storeId, id)
            // Convert FloatArray to List<Double>
            val result = vector?.map { it.toDouble() }
            promise.resolve(result)
        } catch (e: Exception) {
            promise.reject("GET_VECTOR_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreContains(storeId: Long, id: Long, promise: Promise) {
        try {
            val contains = nativeMMapVectorStoreContains(storeId, id)
            promise.resolve(contains)
        } catch (e: Exception) {
            promise.reject("CONTAINS_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreSearch(storeId: Long, queryVector: ReadableArray, k: Int, promise: Promise) {
        val vectorArray = FloatArray(queryVector.size()) {
            queryVector.getDouble(it).toFloat()
        }
        try {
            val results = nativeMMapVectorStoreSearch(storeId, vectorArray, k)
            // Convert jobjectArray to Kotlin array
            val searchResults = mutableListOf<Map<String, Any>>()
            if (results != null) {
                for (i in 0 until results.size()) {
                    val result = results[i] as Any
                    // Assuming result is a SearchResult object with id and distance properties
                    searchResults.add(mapOf(
                        "id" to (result.javaClass.getMethod("getId").invoke(result) as Long),
                        "distance" to (result.javaClass.getMethod("getDistance").invoke(result) as Float)
                    ))
                }
            }
            promise.resolve(searchResults)
        } catch (e: Exception) {
            promise.reject("SEARCH_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreGetSize(storeId: Long, promise: Promise) {
        try {
            val size = nativeMMapVectorStoreGetSize(storeId)
            promise.resolve(size)
        } catch (e: Exception) {
            promise.reject("GET_SIZE_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreGetDimension(storeId: Long, promise: Promise) {
        try {
            val dimension = nativeMMapVectorStoreGetDimension(storeId)
            promise.resolve(dimension)
        } catch (e: Exception) {
            promise.reject("GET_DIMENSION_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreGetMetric(storeId: Long, promise: Promise) {
        try {
            val metric = nativeMMapVectorStoreGetMetric(storeId)
            promise.resolve(metric)
        } catch (e: Exception) {
            promise.reject("GET_METRIC_FAILED", e.message)
        }
    }

    @ReactMethod
    fun mmapVectorStoreClose(storeId: Long, promise: Promise) {
        try {
            nativeMMapVectorStoreClose(storeId)
            mmapVectorStoreMap.remove(storeId)
            promise.resolve(true)
        } catch (e: Exception) {
            promise.reject("CLOSE_FAILED", e.message)
        }
    }

    // Version methods
    @ReactMethod
    fun getVersion(promise: Promise) {
        try {
            val version = nativeGetVersion()
            promise.resolve(version)
        } catch (e: Exception) {
            promise.reject("GET_VERSION_FAILED", e.message)
        }
    }

    @ReactMethod
    fun getVersionMajor(promise: Promise) {
        try {
            val major = nativeGetVersionMajor()
            promise.resolve(major)
        } catch (e: Exception) {
            promise.reject("GET_VERSION_MAJOR_FAILED", e.message)
        }
    }

    @ReactMethod
    fun getVersionMinor(promise: Promise) {
        try {
            val minor = nativeGetVersionMinor()
            promise.resolve(minor)
        } catch (e: Exception) {
            promise.reject("GET_VERSION_MINOR_FAILED", e.message)
        }
    }

    @ReactMethod
    fun getVersionPatch(promise: Promise) {
        try {
            val patch = nativeGetVersionPatch()
            promise.resolve(patch)
        } catch (e: Exception) {
            promise.reject("GET_VERSION_PATCH_FAILED", e.message)
        }
    }

    // Native methods
    external fun nativeVectorStoreCreate(dimension: Int, metric: Int): Long
    external fun nativeVectorStoreAddVector(storeId: Long, id: Long, vector: FloatArray)
    external fun nativeVectorStoreSearch(storeId: Long, queryVector: FloatArray, k: Int): Any?
    external fun nativeVectorStoreGetVector(storeId: Long, id: Long): FloatArray?
    external fun nativeVectorStoreRemoveVector(storeId: Long, id: Long): Boolean
    external fun nativeVectorStoreContains(storeId: Long, id: Long): Boolean
    external fun nativeVectorStoreGetSize(storeId: Long): Long
    external fun nativeVectorStoreGetDimension(storeId: Long): Int
    external fun nativeVectorStoreGetMetric(storeId: Long): Int
    external fun nativeVectorStoreUpdateVector(storeId: Long, id: Long, vector: FloatArray): Boolean
    external fun nativeVectorStoreReserve(storeId: Long, capacity: Long): Boolean
    external fun nativeVectorStoreClear(storeId: Long)
    external fun nativeVectorStoreDestroy(storeId: Long)

    external fun nativeHNSWIndexCreate(dimension: Int, metric: Int, maxElements: Long): Long
    external fun nativeHNSWIndexCreateWithParams(dimension: Int, metric: Int, maxElements: Long, M: Int, efConstruction: Int, seed: Int): Long
    external fun nativeHNSWIndexAddVector(indexId: Long, id: Long, vector: FloatArray): Boolean
    external fun nativeHNSWIndexSearch(indexId: Long, queryVector: FloatArray, k: Int): Any?
    external fun nativeHNSWIndexSetEfSearch(indexId: Long, efSearch: Int): Boolean
    external fun nativeHNSWIndexGetEfSearch(indexId: Long): Int
    external fun nativeHNSWIndexGetSize(indexId: Long): Long
    external fun nativeHNSWIndexGetDimension(indexId: Long): Int
    external fun nativeHNSWIndexGetCapacity(indexId: Long): Long
    external fun nativeHNSWIndexContains(indexId: Long, id: Long): Boolean
    external fun nativeHNSWIndexGetVector(indexId: Long, id: Long): FloatArray?
    external fun nativeHNSWIndexSave(indexId: Long, filename: String): Boolean
    external fun nativeHNSWIndexLoad(filename: String): Long
    external fun nativeHNSWIndexDestroy(indexId: Long)

    external fun nativeMMapVectorStoreBuilderCreate(dimension: Int, metric: Int): Long
    external fun nativeMMapVectorStoreBuilderAddVector(builderId: Long, id: Long, vector: FloatArray): Boolean
    external fun nativeMMapVectorStoreBuilderReserve(builderId: Long, capacity: Long): Boolean
    external fun nativeMMapVectorStoreBuilderSave(builderId: Long, filename: String): Boolean
    external fun nativeMMapVectorStoreBuilderGetSize(builderId: Long): Long
    external fun nativeMMapVectorStoreBuilderGetDimension(builderId: Long): Int
    external fun nativeMMapVectorStoreBuilderDestroy(builderId: Long)

    external fun nativeMMapVectorStoreOpen(filename: String): Long
    external fun nativeMMapVectorStoreGetVector(storeId: Long, id: Long): FloatArray?
    external fun nativeMMapVectorStoreContains(storeId: Long, id: Long): Boolean
    external fun nativeMMapVectorStoreSearch(storeId: Long, queryVector: FloatArray, k: Int): Any?
    external fun nativeMMapVectorStoreGetSize(storeId: Long): Long
    external fun nativeMMapVectorStoreGetDimension(storeId: Long): Int
    external fun nativeMMapVectorStoreGetMetric(storeId: Long): Int
    external fun nativeMMapVectorStoreClose(storeId: Long)

    // Version methods
    external fun nativeGetVersion(): String
    external fun nativeGetVersionMajor(): Int
    external fun nativeGetVersionMinor(): Int
    external fun nativeGetVersionPatch(): Int

    companion object {
        private val vectorStoreMap = mutableMapOf<Long, Long>()
        private val hnswIndexMap = mutableMapOf<Long, Long>()
        private val mmapVectorStoreBuilderMap = mutableMapOf<Long, Long>()
        private val mmapVectorStoreMap = mutableMapOf<Long, Long>()

        init {
            System.loadLibrary("llama_mobile_vd_jni")
        }
    }
}
