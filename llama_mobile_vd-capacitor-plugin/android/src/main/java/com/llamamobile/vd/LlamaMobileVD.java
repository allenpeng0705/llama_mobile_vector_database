package com.llamamobile.vd;

/**
 * LlamaMobileVD Android Java SDK
 * A high-performance vector database for mobile applications
 */

/**
 * Distance metrics supported by LlamaMobileVD
 */
public enum DistanceMetric {
    L2(0),
    COSINE(1),
    DOT(2);

    private final int value;

    DistanceMetric(int value) {
        this.value = value;
    }

    public int getValue() {
        return value;
    }
}

/**
 * A result from a vector search operation
 */
public class SearchResult {
    private final int id;
    private final float distance;

    /**
     * Create a new search result
     *
     * @param id The ID of the vector
     * @param distance The distance between the query vector and the result vector
     */
    public SearchResult(int id, float distance) {
        this.id = id;
        this.distance = distance;
    }

    /**
     * Get the ID of the vector
     *
     * @return The ID of the vector
     */
    public int getId() {
        return id;
    }

    /**
     * Get the distance between the query vector and the result vector
     *
     * @return The distance between the query vector and the result vector
     */
    public float getDistance() {
        return distance;
    }

    @Override
    public String toString() {
        return "SearchResult{id=" + id + ", distance=" + distance + "}";
    }
}

/**
 * A vector store for efficiently storing and searching vectors
 */
public class VectorStore implements AutoCloseable {
    private long pointer;

    /**
     * Create a new vector store
     *
     * @param dimension The dimension of the vectors
     * @param metric The distance metric to use for similarity search
     * @throws IllegalStateException If the vector store could not be created
     */
    public VectorStore(int dimension, DistanceMetric metric) {
        pointer = createVectorStore(dimension, metric.getValue());
        if (pointer == 0L) {
            throw new IllegalStateException("Failed to create vector store");
        }
    }

    /**
     * Add a vector to the store
     *
     * @param vector The vector to add
     * @param id The ID to associate with the vector
     * @throws IllegalArgumentException If the vector dimension doesn't match the store dimension
     */
    public void addVector(float[] vector, int id) {
        if (!addVector(pointer, vector, vector.length, id)) {
            throw new IllegalArgumentException("Failed to add vector");
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
    public SearchResult[] search(float[] queryVector, int k) {
        int[] resultCount = new int[1];
        long resultsPtr = search(pointer, queryVector, queryVector.length, k, resultCount);
        if (resultsPtr == 0L) {
            throw new IllegalArgumentException("Failed to search vectors");
        }

        try {
            SearchResult[] results = new SearchResult[resultCount[0]];
            for (int i = 0; i < resultCount[0]; i++) {
                int id = getResultId(resultsPtr, i);
                float distance = getResultDistance(resultsPtr, i);
                results[i] = new SearchResult(id, distance);
            }
            return results;
        } finally {
            freeSearchResults(resultsPtr);
        }
    }

    /**
     * Get the number of vectors in the store
     *
     * @return The number of vectors in the store
     */
    public int getCount() {
        return getCount(pointer);
    }

    /**
     * Clear all vectors from the store
     */
    public void clear() {
        clear(pointer);
    }

    /**
     * Close the vector store and free resources
     */
    @Override
    public void close() {
        if (pointer != 0L) {
            destroyVectorStore(pointer);
            pointer = 0L;
        }
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        close();
    }

    // JNI methods
    private native long createVectorStore(int dimension, int metric);
    private native void destroyVectorStore(long store);
    private native boolean addVector(long store, float[] vector, int vectorSize, int id);
    private native long search(long store, float[] queryVector, int vectorSize, int k, int[] resultCount);
    private native void freeSearchResults(long results);
    private native int getResultId(long results, int index);
    private native float getResultDistance(long results, int index);
    private native int getCount(long store);
    private native void clear(long store);

    static {
        System.loadLibrary("quiverdb_wrapper");
    }
}

/**
 * A high-performance approximate nearest neighbor search index using the HNSW algorithm
 */
public class HNSWIndex implements AutoCloseable {
    private long pointer;

    /**
     * Create a new HNSW index
     *
     * @param dimension The dimension of the vectors
     * @param metric The distance metric to use
     * @param m The maximum number of connections per node
     * @param efConstruction The size of the dynamic list for candidate selection during construction
     * @throws IllegalStateException If the index could not be created
     */
    public HNSWIndex(int dimension, DistanceMetric metric, int m, int efConstruction) {
        pointer = createHNSWIndex(dimension, metric.getValue(), m, efConstruction);
        if (pointer == 0L) {
            throw new IllegalStateException("Failed to create HNSW index");
        }
    }

    /**
     * Create a new HNSW index with default parameters
     *
     * @param dimension The dimension of the vectors
     * @param metric The distance metric to use
     */
    public HNSWIndex(int dimension, DistanceMetric metric) {
        this(dimension, metric, 16, 200);
    }

    /**
     * Add a vector to the index
     *
     * @param vector The vector to add
     * @param id The ID to associate with the vector
     * @throws IllegalArgumentException If the vector dimension doesn't match the index dimension
     */
    public void addVector(float[] vector, int id) {
        if (!addVector(pointer, vector, vector.length, id)) {
            throw new IllegalArgumentException("Failed to add vector");
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
    public SearchResult[] search(float[] queryVector, int k, int efSearch) {
        int[] resultCount = new int[1];
        long resultsPtr = search(pointer, queryVector, queryVector.length, k, efSearch, resultCount);
        if (resultsPtr == 0L) {
            throw new IllegalArgumentException("Failed to search HNSW index");
        }

        try {
            SearchResult[] results = new SearchResult[resultCount[0]];
            for (int i = 0; i < resultCount[0]; i++) {
                int id = getResultId(resultsPtr, i);
                float distance = getResultDistance(resultsPtr, i);
                results[i] = new SearchResult(id, distance);
            }
            return results;
        } finally {
            freeSearchResults(resultsPtr);
        }
    }

    /**
     * Search for the nearest neighbors of a query vector with default efSearch
     *
     * @param queryVector The query vector
     * @param k The number of nearest neighbors to return
     * @return An array of search results sorted by distance
     */
    public SearchResult[] search(float[] queryVector, int k) {
        return search(queryVector, k, 50);
    }

    /**
     * Get the number of vectors in the index
     *
     * @return The number of vectors in the index
     */
    public int getCount() {
        return getCount(pointer);
    }

    /**
     * Clear all vectors from the index
     */
    public void clear() {
        clear(pointer);
    }

    /**
     * Close the index and free resources
     */
    @Override
    public void close() {
        if (pointer != 0L) {
            destroyHNSWIndex(pointer);
            pointer = 0L;
        }
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        close();
    }

    // JNI methods
    private native long createHNSWIndex(int dimension, int metric, int m, int efConstruction);
    private native void destroyHNSWIndex(long index);
    private native boolean addVector(long index, float[] vector, int vectorSize, int id);
    private native long search(long index, float[] queryVector, int vectorSize, int k, int efSearch, int[] resultCount);
    private native void freeSearchResults(long results);
    private native int getResultId(long results, int index);
    private native float getResultDistance(long results, int index);
    private native int getCount(long index);
    private native void clear(long index);

    static {
        System.loadLibrary("quiverdb_wrapper");
    }
}
