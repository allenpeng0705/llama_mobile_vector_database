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
     * Remove a vector from the store by ID
     *
     * @param id The ID of the vector to remove
     * @return true if the vector was removed, false otherwise
     */
    fun remove(id: Int): Boolean {
        val removed = IntArray(1)
        return remove(pointer, id, removed)
    }

    /**
     * Get a vector from the store by ID
     *
     * @param id The ID of the vector to get
     * @return The vector if found, null otherwise
     */
    fun get(id: Int): FloatArray? {
        val dimension = dimension
        val vector = FloatArray(dimension)
        return if (get(pointer, id, vector)) vector else null
    }

    /**
     * Update a vector in the store by ID
     *
     * @param id The ID of the vector to update
     * @param vector The new vector data
     * @return true if the vector was updated, false otherwise
     * @throws IllegalArgumentException If the vector dimension doesn't match the store dimension
     */
    fun update(id: Int, vector: FloatArray): Boolean {
        if (vector.size != dimension) {
            throw IllegalArgumentException("Vector dimension must match store dimension")
        }
        return update(pointer, id, vector, vector.size)
    }

    /**
     * Get the dimension of the vectors in the store
     *
     * @return The dimension of the vectors
     */
    val dimension: Int
        get() = dimension(pointer)

    /**
     * Get the distance metric used by the store
     *
     * @return The distance metric
     */
    val metric: DistanceMetric
        get() {
            val metricValue = metric(pointer)
            return when (metricValue) {
                0 -> DistanceMetric.L2
                1 -> DistanceMetric.COSINE
                2 -> DistanceMetric.DOT
                else -> DistanceMetric.L2
            }
        }

    /**
     * Check if the store contains a vector with the given ID
     *
     * @param id The ID to check
     * @return true if the vector exists, false otherwise
     */
    fun contains(id: Int): Boolean {
        val contains = IntArray(1)
        return contains(pointer, id, contains)
    }

    /**
     * Reserve space for the specified number of vectors
     *
     * @param capacity The number of vectors to reserve space for
     */
    fun reserve(capacity: Int) {
        reserve(pointer, capacity)
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
    private external fun remove(store: Long, id: Int, removed: IntArray): Boolean
    private external fun get(store: Long, id: Int, vector: FloatArray): Boolean
    private external fun update(store: Long, id: Int, vector: FloatArray, vectorSize: Int): Boolean
    private external fun search(store: Long, queryVector: FloatArray, vectorSize: Int, k: Int, resultCount: IntArray): Long
    private external fun dimension(store: Long): Int
    private external fun metric(store: Long): Int
    private external fun contains(store: Long, id: Int, contains: IntArray): Boolean
    private external fun reserve(store: Long, capacity: Int)
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
 * Get the version string of the LlamaMobileVD SDK
 *
 * @return The version string in the format "major.minor.patch"
 */
fun getLlamaMobileVDVersion(): String {
    return getVersion()
}

/**
 * Get the major version number of the LlamaMobileVD SDK
 *
 * @return The major version number
 */
fun getLlamaMobileVDVersionMajor(): Int {
    return getVersionMajor()
}

/**
 * Get the minor version number of the LlamaMobileVD SDK
 *
 * @return The minor version number
 */
fun getLlamaMobileVDVersionMinor(): Int {
    return getVersionMinor()
}

/**
 * Get the patch version number of the LlamaMobileVD SDK
 *
 * @return The patch version number
 */
fun getLlamaMobileVDVersionPatch(): Int {
    return getVersionPatch()
}

// Version JNI methods
private external fun getVersion(): String
private external fun getVersionMajor(): Int
private external fun getVersionMinor(): Int
private external fun getVersionPatch(): Int

// Load the native library for top-level functions
init {
    System.loadLibrary("quiverdb_wrapper")
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
     * Set the efSearch parameter for search operations
     *
     * @param efSearch The new efSearch value
     */
    fun setEfSearch(efSearch: Int) {
        setEfSearch(pointer, efSearch)
    }

    /**
     * Get the current efSearch parameter
     *
     * @return The current efSearch value
     */
    fun getEfSearch(): Int {
        return getEfSearch(pointer)
    }

    /**
     * Get the dimension of the vectors in the index
     *
     * @return The dimension of the vectors
     */
    val dimension: Int
        get() = dimension(pointer)

    /**
     * Get the maximum capacity of the index
     *
     * @return The maximum capacity
     */
    val capacity: Int
        get() = capacity(pointer)

    /**
     * Check if the index contains a vector with the given ID
     *
     * @param id The ID to check
     * @return true if the vector exists, false otherwise
     */
    fun contains(id: Int): Boolean {
        val contains = IntArray(1)
        return contains(pointer, id, contains)
    }

    /**
     * Get a vector from the index by ID
     *
     * @param id The ID of the vector to get
     * @return The vector if found, null otherwise
     */
    fun getVector(id: Int): FloatArray? {
        val dimension = dimension
        val vector = FloatArray(dimension)
        return if (getVector(pointer, id, vector)) vector else null
    }

    /**
     * Save the index to a file
     *
     * @param filename The path to the file where the index should be saved
     * @return true if the index was saved successfully, false otherwise
     */
    fun save(filename: String): Boolean {
        return save(pointer, filename)
    }

    /**
     * Close the index and free resources
     */
    override fun close() {
        destroyHNSWIndex(pointer)
    }

    companion object {
        /**
         * Load an HNSW index from a file
         *
         * @param filename The path to the file containing the saved index
         * @return The loaded HNSW index
         * @throws IllegalStateException If the index could not be loaded
         */
        fun load(filename: String): HNSWIndex {
            val indexPointer = load(filename)
            if (indexPointer == 0L) {
                throw IllegalStateException("Failed to load HNSW index from file: $filename")
            }
            
            // Create a new HNSWIndex instance with the loaded pointer
            val index = HNSWIndex::class.java.getDeclaredConstructor(Long::class.java).newInstance(indexPointer)
            return index
        }
        
        // Private constructor for loading an existing index pointer
        private constructor(pointer: Long) : this(0, DistanceMetric.L2) {
            this.pointer = pointer
        }
    }

    // JNI methods
    private external fun createHNSWIndex(dimension: Int, metric: Int, m: Int, efConstruction: Int): Long
    private external fun destroyHNSWIndex(index: Long)
    private external fun addVector(index: Long, vector: FloatArray, vectorSize: Int, id: Int): Boolean
    private external fun search(index: Long, queryVector: FloatArray, vectorSize: Int, k: Int, efSearch: Int, resultCount: IntArray): Long
    private external fun setEfSearch(index: Long, efSearch: Int)
    private external fun getEfSearch(index: Long): Int
    private external fun dimension(index: Long): Int
    private external fun capacity(index: Long): Int
    private external fun contains(index: Long, id: Int, contains: IntArray): Boolean
    private external fun getVector(index: Long, id: Int, vector: FloatArray): Boolean
    private external fun save(index: Long, filename: String): Boolean
    private external fun load(filename: String): Long
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
