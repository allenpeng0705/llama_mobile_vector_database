package com.llamamobile.vd

/**
 * JNI interface for LlamaMobileVD
 * This class contains the native methods that bridge between Kotlin and C++
 */
internal class JNIInterface {
    companion object {
        // Vector Store native methods
        external fun createVectorStore(dimension: Int, metric: Int): Long
        external fun destroyVectorStore(store: Long)
        external fun addVector(store: Long, vector: FloatArray, vectorSize: Int, id: Int): Boolean
        external fun search(store: Long, queryVector: FloatArray, vectorSize: Int, k: Int, resultCount: IntArray): Long
        external fun freeSearchResults(results: Long)
        external fun getResultId(results: Long, index: Int): Int
        external fun getResultDistance(results: Long, index: Int): Float
        external fun getCount(store: Long): Int
        external fun clear(store: Long)

        // HNSW Index native methods
        external fun createHNSWIndex(dimension: Int, metric: Int, m: Int, efConstruction: Int): Long
        external fun destroyHNSWIndex(index: Long)
        external fun addVector(index: Long, vector: FloatArray, vectorSize: Int, id: Int): Boolean
        external fun search(index: Long, queryVector: FloatArray, vectorSize: Int, k: Int, efSearch: Int, resultCount: IntArray): Long
        external fun freeSearchResults(results: Long)
        external fun getResultId(results: Long, index: Int): Int
        external fun getResultDistance(results: Long, index: Int): Float
        external fun getCount(index: Long): Int
        external fun clear(index: Long)

        init {
            System.loadLibrary("quiverdb_wrapper")
        }
    }
}
