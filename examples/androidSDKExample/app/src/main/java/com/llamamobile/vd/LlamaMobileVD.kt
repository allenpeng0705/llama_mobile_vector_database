package com.llamamobile.vd

/**
 * LlamaMobileVD Android SDK - Kotlin Wrapper
 * A high-performance vector database for Android applications.
 */
class LlamaMobileVD {

    companion object {
        init {
            System.loadLibrary("llama_mobile_vd_jni")
        }

        /**
         * Gets the version of the LlamaMobileVD library.
         */
        @JvmStatic
        external fun getVersion(): String
    }

    /**
     * Distance metrics supported by LlamaMobileVD.
     */
    enum class DistanceMetric {
        L2,
        COSINE,
        DOT
    }

    /**
     * Search result containing ID and distance.
     */
    data class SearchResult(val id: Long, val distance: Float)

    /**
     * VectorStore interface for managing vectors in memory.
     */
    class VectorStore(
        dimension: Int,
        metric: DistanceMetric
    ) : AutoCloseable {
        private val handle: Long

        init {
            handle = nativeVectorStoreCreate(dimension, metric.ordinal)
        }

        /**
         * Adds a vector to the store with the specified ID.
         */
        fun add(id: Long, vector: FloatArray) {
            nativeVectorStoreAdd(handle, id, vector)
        }

        /**
         * Removes a vector from the store with the specified ID.
         * @return true if the vector was removed, false otherwise
         */
        fun remove(id: Long): Boolean {
            return nativeVectorStoreRemove(handle, id)
        }

        /**
         * Gets a vector from the store with the specified ID.
         */
        fun get(id: Long): FloatArray {
            return nativeVectorStoreGet(handle, id)
        }

        /**
         * Updates a vector in the store with the specified ID.
         */
        fun update(id: Long, vector: FloatArray) {
            nativeVectorStoreUpdate(handle, id, vector)
        }

        /**
         * Searches for the k nearest neighbors to the query vector.
         */
        fun search(query: FloatArray, k: Int): Array<SearchResult> {
            return nativeVectorStoreSearch(handle, query, k)
        }

        /**
         * Gets the number of vectors in the store.
         */
        fun size(): Int {
            return nativeVectorStoreSize(handle)
        }

        /**
         * Gets the dimension of vectors in the store.
         */
        fun dimension(): Int {
            return nativeVectorStoreDimension(handle)
        }

        /**
         * Gets the distance metric used by the store.
         */
        fun metric(): DistanceMetric {
            return DistanceMetric.values()[nativeVectorStoreMetric(handle)]
        }

        /**
         * Checks if the store contains a vector with the specified ID.
         */
        fun contains(id: Long): Boolean {
            return nativeVectorStoreContains(handle, id)
        }

        /**
         * Reserves capacity for the specified number of vectors.
         */
        fun reserve(capacity: Int) {
            nativeVectorStoreReserve(handle, capacity)
        }

        /**
         * Clears all vectors from the store.
         */
        fun clear() {
            nativeVectorStoreClear(handle)
        }

        /**
         * Releases the native resources.
         */
        override fun close() {
            nativeVectorStoreDestroy(handle)
        }

        private external fun nativeVectorStoreCreate(dimension: Int, metric: Int): Long
        private external fun nativeVectorStoreAdd(handle: Long, id: Long, vector: FloatArray)
        private external fun nativeVectorStoreRemove(handle: Long, id: Long): Boolean
        private external fun nativeVectorStoreGet(handle: Long, id: Long): FloatArray
        private external fun nativeVectorStoreUpdate(handle: Long, id: Long, vector: FloatArray)
        private external fun nativeVectorStoreSearch(handle: Long, query: FloatArray, k: Int): Array<SearchResult>
        private external fun nativeVectorStoreSize(handle: Long): Int
        private external fun nativeVectorStoreDimension(handle: Long): Int
        private external fun nativeVectorStoreMetric(handle: Long): Int
        private external fun nativeVectorStoreContains(handle: Long, id: Long): Boolean
        private external fun nativeVectorStoreReserve(handle: Long, capacity: Int)
        private external fun nativeVectorStoreClear(handle: Long)
        private external fun nativeVectorStoreDestroy(handle: Long)
    }

    /**
     * HNSWIndex interface for efficient approximate nearest neighbor search.
     */
    class HNSWIndex private constructor(private val handle: Long) : AutoCloseable {
        /**
         * Creates a new HNSWIndex with default parameters.
         */
        constructor(
            dimension: Int,
            metric: DistanceMetric,
            maxElements: Int
        ) : this(Companion.nativeHNSWIndexCreate(dimension, metric.ordinal, maxElements))

        /**
         * Creates a new HNSWIndex with custom parameters.
         */
        constructor(
            dimension: Int,
            metric: DistanceMetric,
            maxElements: Int,
            M: Int,
            efConstruction: Int,
            seed: Int
        ) : this(Companion.nativeHNSWIndexCreateWithParams(dimension, metric.ordinal, maxElements, M, efConstruction, seed))

        /**
         * Adds a vector to the index with the specified ID.
         */
        fun add(id: Long, vector: FloatArray) {
            Companion.nativeHNSWIndexAdd(handle, id, vector)
        }

        /**
         * Searches for the k nearest neighbors to the query vector.
         */
        fun search(query: FloatArray, k: Int): Array<SearchResult> {
            return Companion.nativeHNSWIndexSearch(handle, query, k)
        }

        /**
         * Sets the ef_search parameter for the index.
         */
        fun setEfSearch(efSearch: Int) {
            Companion.nativeHNSWIndexSetEfSearch(handle, efSearch)
        }

        /**
         * Gets the current ef_search parameter value.
         */
        fun getEfSearch(): Int {
            return Companion.nativeHNSWIndexGetEfSearch(handle)
        }

        /**
         * Gets the number of vectors in the index.
         */
        fun size(): Int {
            return Companion.nativeHNSWIndexSize(handle)
        }

        /**
         * Gets the dimension of vectors in the index.
         */
        fun dimension(): Int {
            return Companion.nativeHNSWIndexDimension(handle)
        }

        /**
         * Gets the capacity of the index.
         */
        fun capacity(): Int {
            return Companion.nativeHNSWIndexCapacity(handle)
        }

        /**
         * Checks if the index contains a vector with the specified ID.
         */
        fun contains(id: Long): Boolean {
            return Companion.nativeHNSWIndexContains(handle, id)
        }

        /**
         * Gets a vector from the index with the specified ID.
         */
        fun getVector(id: Long): FloatArray {
            return Companion.nativeHNSWIndexGetVector(handle, id)
        }

        /**
         * Saves the index to a file.
         */
        fun save(filename: String) {
            Companion.nativeHNSWIndexSave(handle, filename)
        }

        /**
         * Releases the native resources.
         */
        override fun close() {
            Companion.nativeHNSWIndexDestroy(handle)
        }

        companion object {
            /**
             * Loads an HNSWIndex from a file.
             */
            fun load(filename: String): HNSWIndex {
                val handle = nativeHNSWIndexLoad(filename)
                return HNSWIndex(handle)
            }

            private external fun nativeHNSWIndexCreate(dimension: Int, metric: Int, maxElements: Int): Long
            private external fun nativeHNSWIndexCreateWithParams(dimension: Int, metric: Int, maxElements: Int, M: Int, efConstruction: Int, seed: Int): Long
            private external fun nativeHNSWIndexAdd(handle: Long, id: Long, vector: FloatArray)
            private external fun nativeHNSWIndexSearch(handle: Long, query: FloatArray, k: Int): Array<SearchResult>
            private external fun nativeHNSWIndexSetEfSearch(handle: Long, efSearch: Int)
            private external fun nativeHNSWIndexGetEfSearch(handle: Long): Int
            private external fun nativeHNSWIndexSize(handle: Long): Int
            private external fun nativeHNSWIndexDimension(handle: Long): Int
            private external fun nativeHNSWIndexCapacity(handle: Long): Int
            private external fun nativeHNSWIndexContains(handle: Long, id: Long): Boolean
            private external fun nativeHNSWIndexGetVector(handle: Long, id: Long): FloatArray
            private external fun nativeHNSWIndexSave(handle: Long, filename: String)
            private external fun nativeHNSWIndexLoad(filename: String): Long
            private external fun nativeHNSWIndexDestroy(handle: Long)
        }
    }

    /**
     * MMapVectorStoreBuilder for creating memory-mapped vector stores on disk.
     */
    class MMapVectorStoreBuilder(dimension: Int, metric: DistanceMetric) : AutoCloseable {
        private val handle: Long

        init {
            handle = nativeMMapVectorStoreBuilderCreate(dimension, metric.ordinal)
        }

        /**
         * Adds a vector to the builder.
         */
        fun add(id: Long, vector: FloatArray) {
            nativeMMapVectorStoreBuilderAdd(handle, id, vector)
        }

        /**
         * Reserves capacity for the specified number of vectors.
         */
        fun reserve(capacity: Int) {
            nativeMMapVectorStoreBuilderReserve(handle, capacity)
        }

        /**
         * Saves the builder to a file.
         */
        fun save(filename: String) {
            nativeMMapVectorStoreBuilderSave(handle, filename)
        }

        /**
         * Gets the number of vectors in the builder.
         */
        fun size(): Int {
            return nativeMMapVectorStoreBuilderSize(handle)
        }

        /**
         * Gets the dimension of vectors in the builder.
         */
        fun dimension(): Int {
            return nativeMMapVectorStoreBuilderDimension(handle)
        }

        override fun close() {
            nativeMMapVectorStoreBuilderDestroy(handle)
        }

        private external fun nativeMMapVectorStoreBuilderCreate(dimension: Int, metric: Int): Long
        private external fun nativeMMapVectorStoreBuilderAdd(handle: Long, id: Long, vector: FloatArray)
        private external fun nativeMMapVectorStoreBuilderReserve(handle: Long, capacity: Int)
        private external fun nativeMMapVectorStoreBuilderSave(handle: Long, filename: String)
        private external fun nativeMMapVectorStoreBuilderSize(handle: Long): Int
        private external fun nativeMMapVectorStoreBuilderDimension(handle: Long): Int
        private external fun nativeMMapVectorStoreBuilderDestroy(handle: Long)
    }

    /**
     * MMapVectorStore for accessing memory-mapped vector stores on disk.
     */
    class MMapVectorStore(filename: String) : AutoCloseable {
        private val handle: Long

        init {
            handle = nativeMMapVectorStoreOpen(filename)
        }

        /**
         * Gets a vector by its ID.
         */
        fun get(id: Long): FloatArray {
            return nativeMMapVectorStoreGet(handle, id)
        }

        /**
         * Checks if a vector with the specified ID exists.
         */
        fun contains(id: Long): Boolean {
            return nativeMMapVectorStoreContains(handle, id)
        }

        /**
         * Searches for the k nearest neighbors to the query vector.
         */
        fun search(query: FloatArray, k: Int): Array<SearchResult> {
            return nativeMMapVectorStoreSearch(handle, query, k)
        }

        /**
         * Gets the number of vectors in the store.
         */
        fun size(): Int {
            return nativeMMapVectorStoreSize(handle)
        }

        /**
         * Gets the dimension of vectors in the store.
         */
        fun dimension(): Int {
            return nativeMMapVectorStoreDimension(handle)
        }

        /**
         * Gets the distance metric used by the store.
         */
        fun metric(): DistanceMetric {
            return DistanceMetric.values()[nativeMMapVectorStoreMetric(handle)]
        }

        override fun close() {
            nativeMMapVectorStoreClose(handle)
        }

        private external fun nativeMMapVectorStoreOpen(filename: String): Long
        private external fun nativeMMapVectorStoreGet(handle: Long, id: Long): FloatArray
        private external fun nativeMMapVectorStoreContains(handle: Long, id: Long): Boolean
        private external fun nativeMMapVectorStoreSearch(handle: Long, query: FloatArray, k: Int): Array<SearchResult>
        private external fun nativeMMapVectorStoreSize(handle: Long): Int
        private external fun nativeMMapVectorStoreDimension(handle: Long): Int
        private external fun nativeMMapVectorStoreMetric(handle: Long): Int
        private external fun nativeMMapVectorStoreClose(handle: Long)
    }

    /**
     * Exception thrown by LlamaMobileVD operations.
     */
    class LlamaMobileVDException(message: String) : Exception(message)

    // Native methods
    private external fun nativeGetVersion(): String
}