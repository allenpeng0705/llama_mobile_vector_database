package com.llamamobile.vd

/**
 * LlamaMobileVD Android Kotlin SDK
 * A high-performance vector database for mobile applications
 */

/**
 * Distance metrics supported by LlamaMobileVD
 */
enum class DistanceMetric {
    L2,
    COSINE,
    DOT
}

/**
 * A result from a vector search operation
 *
 * @property id The ID of the vector
 * @property distance The distance between the query vector and the result vector
 */
data class SearchResult(
    val id: Int,
    val distance: Float
)

/**
 * A vector store for efficiently storing and searching vectors
 *
 * @property dimension The dimension of the vectors
 * @property metric The distance metric to use for similarity search
 */
class VectorStore(dimension: Int, metric: DistanceMetric) : AutoCloseable {
    private val pointer: Long

    init {
        val metricValue = when (metric) {
            DistanceMetric.L2 -> 0
            DistanceMetric.COSINE -> 1
            DistanceMetric.DOT -> 2
        }
        pointer = createVectorStore(dimension, metricValue)
        if (pointer == 0L) {
            throw IllegalStateException("Failed to create vector store")
        }
    }

    /**
     * Add a vector to the store
     *
     * @param vector The vector to add
     * @param id The ID to associate with the vector
     * @throws IllegalArgumentException If the vector dimension doesn't match the store dimension
     */
    fun addVector(vector: FloatArray, id: Int) {
        if (!addVector(pointer, vector, vector.size, id)) {
            throw IllegalArgumentException("Failed to add vector")
        }
    }

    /**
     * Search for the nearest neighbors of a query vector
     *
     * @param queryVector The query vector
     * @param k The number of nearest neighbors to return
     * @return An array of search results sorted by distance
     * @throws IllegalArgumentException If the query vector dimension doesn't match the store dimension
     */
    fun search(queryVector: FloatArray, k: Int): Array<SearchResult> {
        val resultCount = IntArray(1)
        val resultsPtr = search(pointer, queryVector, queryVector.size, k, resultCount)
        if (resultsPtr == 0L) {
            throw IllegalArgumentException("Failed to search vectors")
        }

        try {
            val results = mutableListOf<SearchResult>()
            for (i in 0 until resultCount[0]) {
                val id = getResultId(resultsPtr, i)
                val distance = getResultDistance(resultsPtr, i)
                results.add(SearchResult(id, distance))
            }
            return results.toTypedArray()
        } finally {
            freeSearchResults(resultsPtr)
        }
    }

    /**
     * Get the number of vectors in the store
     *
     * @return The number of vectors in the store
     */
    fun getCount(): Int {
        return getCount(pointer)
    }

    /**
     * Clear all vectors from the store
     */
    fun clear() {
        clear(pointer)
    }

    /**
     * Close the vector store and free resources
     */
    override fun close() {
        destroyVectorStore(pointer)
    }

    // JNI methods
    private external fun createVectorStore(dimension: Int, metric: Int): Long
    private external fun destroyVectorStore(store: Long)
    private external fun addVector(store: Long, vector: FloatArray, vectorSize: Int, id: Int): Boolean
    private external fun search(store: Long, queryVector: FloatArray, vectorSize: Int, k: Int, resultCount: IntArray): Long
    private external fun freeSearchResults(results: Long)
    private external fun getResultId(results: Long, index: Int): Int
    private external fun getResultDistance(results: Long, index: Int): Float
    private external fun getCount(store: Long): Int
    private external fun clear(store: Long)

    companion object {
        // Load the native library
        init {
            System.loadLibrary("quiverdb_wrapper")
        }
    }
}

/**
 * A high-performance approximate nearest neighbor search index using the HNSW algorithm
 *
 * @property dimension The dimension of the vectors
 * @property metric The distance metric to use
 * @property m The maximum number of connections per node
 * @property efConstruction The size of the dynamic list for candidate selection during construction
 */
class HNSWIndex(
    dimension: Int,
    metric: DistanceMetric,
    m: Int = 16,
    efConstruction: Int = 200
) : AutoCloseable {
    private val pointer: Long

    init {
        val metricValue = when (metric) {
            DistanceMetric.L2 -> 0
            DistanceMetric.COSINE -> 1
            DistanceMetric.DOT -> 2
        }
        pointer = createHNSWIndex(dimension, metricValue, m, efConstruction)
        if (pointer == 0L) {
            throw IllegalStateException("Failed to create HNSW index")
        }
    }

    /**
     * Add a vector to the index
     *
     * @param vector The vector to add
     * @param id The ID to associate with the vector
     * @throws IllegalArgumentException If the vector dimension doesn't match the index dimension
     */
    fun addVector(vector: FloatArray, id: Int) {
        if (!addVector(pointer, vector, vector.size, id)) {
            throw IllegalArgumentException("Failed to add vector")
        }
    }

    /**
     * Search for the nearest neighbors of a query vector
     *
     * @param queryVector The query vector
     * @param k The number of nearest neighbors to return
     * @param efSearch The size of the dynamic list for candidate selection during search
     * @return An array of search results sorted by distance
     * @throws IllegalArgumentException If the query vector dimension doesn't match the index dimension
     */
    fun search(queryVector: FloatArray, k: Int, efSearch: Int = 50): Array<SearchResult> {
        val resultCount = IntArray(1)
        val resultsPtr = search(pointer, queryVector, queryVector.size, k, efSearch, resultCount)
        if (resultsPtr == 0L) {
            throw IllegalArgumentException("Failed to search HNSW index")
        }

        try {
            val results = mutableListOf<SearchResult>()
            for (i in 0 until resultCount[0]) {
                val id = getResultId(resultsPtr, i)
                val distance = getResultDistance(resultsPtr, i)
                results.add(SearchResult(id, distance))
            }
            return results.toTypedArray()
        } finally {
            freeSearchResults(resultsPtr)
        }
    }

    /**
     * Get the number of vectors in the index
     *
     * @return The number of vectors in the index
     */
    fun getCount(): Int {
        return getCount(pointer)
    }

    /**
     * Clear all vectors from the index
     */
    fun clear() {
        clear(pointer)
    }

    /**
     * Close the index and free resources
     */
    override fun close() {
        destroyHNSWIndex(pointer)
    }

    // JNI methods
    private external fun createHNSWIndex(dimension: Int, metric: Int, m: Int, efConstruction: Int): Long
    private external fun destroyHNSWIndex(index: Long)
    private external fun addVector(index: Long, vector: FloatArray, vectorSize: Int, id: Int): Boolean
    private external fun search(index: Long, queryVector: FloatArray, vectorSize: Int, k: Int, efSearch: Int, resultCount: IntArray): Long
    private external fun freeSearchResults(results: Long)
    private external fun getResultId(results: Long, index: Int): Int
    private external fun getResultDistance(results: Long, index: Int): Float
    private external fun getCount(index: Long): Int
    private external fun clear(index: Long)

    companion object {
        // Load the native library
        init {
            System.loadLibrary("quiverdb_wrapper")
        }
    }
}
