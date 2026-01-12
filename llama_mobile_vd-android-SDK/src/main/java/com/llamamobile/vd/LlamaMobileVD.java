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
     * Remove a vector from the store by ID
     *
     * @param id The ID of the vector to remove
     * @return true if the vector was removed, false otherwise
     */
    public boolean remove(int id) {
        int[] removed = new int[1];
        return remove(pointer, id, removed);
    }

    /**
     * Get a vector from the store by ID
     *
     * @param id The ID of the vector to get
     * @return The vector if found, null otherwise
     */
    public float[] get(int id) {
        int dimension = getDimension();
        float[] vector = new float[dimension];
        return get(pointer, id, vector) ? vector : null;
    }

    /**
     * Update a vector in the store by ID
     *
     * @param id The ID of the vector to update
     * @param vector The new vector data
     * @return true if the vector was updated, false otherwise
     * @throws IllegalArgumentException If the vector dimension doesn't match the store dimension
     */
    public boolean update(int id, float[] vector) {
        if (vector.length != getDimension()) {
            throw new IllegalArgumentException("Vector dimension must match store dimension");
        }
        return update(pointer, id, vector, vector.length);
    }

    /**
     * Get the dimension of the vectors in the store
     *
     * @return The dimension of the vectors
     */
    public int getDimension() {
        return getDimension(pointer);
    }

    /**
     * Get the distance metric used by the store
     *
     * @return The distance metric
     */
    public DistanceMetric getMetric() {
        int metricValue = getMetric(pointer);
        switch (metricValue) {
            case 0:
                return DistanceMetric.L2;
            case 1:
                return DistanceMetric.COSINE;
            case 2:
                return DistanceMetric.DOT;
            default:
                return DistanceMetric.L2;
        }
    }

    /**
     * Check if the store contains a vector with the given ID
     *
     * @param id The ID to check
     * @return true if the vector exists, false otherwise
     */
    public boolean contains(int id) {
        int[] contains = new int[1];
        return contains(pointer, id, contains);
    }

    /**
     * Reserve space for the specified number of vectors
     *
     * @param capacity The number of vectors to reserve space for
     */
    public void reserve(int capacity) {
        reserve(pointer, capacity);
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
    private native boolean remove(long store, int id, int[] removed);
    private native boolean get(long store, int id, float[] vector);
    private native boolean update(long store, int id, float[] vector, int vectorSize);
    private native long search(long store, float[] queryVector, int vectorSize, int k, int[] resultCount);
    private native int getDimension(long store);
    private native int getMetric(long store);
    private native boolean contains(long store, int id, int[] contains);
    private native void reserve(long store, int capacity);
    private native void freeSearchResults(long results);
    private native int getResultId(long results, int index);
    private native float getResultDistance(long results, int index);
    private native int getCount(long store);
    private native void clear(long store);

    static {
        System.loadLibrary("llamamobilevd");
    }
}

/**
 * A builder for creating and saving MMapVectorStore instances
 * MMapVectorStore is optimized for large datasets that may exceed RAM capacity
 */
public class MMapVectorStoreBuilder implements AutoCloseable {
    private long pointer;

    /**
     * Create a new MMapVectorStore builder
     *
     * @param dimension The dimension of the vectors
     * @param metric The distance metric to use for similarity search
     * @throws IllegalStateException If the builder could not be created
     */
    public MMapVectorStoreBuilder(int dimension, DistanceMetric metric) {
        pointer = createBuilder(dimension, metric.getValue());
        if (pointer == 0L) {
            throw new IllegalStateException("Failed to create MMap vector store builder");
        }
    }

    /**
     * Add a vector to the builder
     *
     * @param vector The vector to add
     * @param id The ID to associate with the vector
     * @throws IllegalArgumentException If the vector dimension doesn't match the builder dimension
     */
    public void addVector(float[] vector, int id) {
        if (!addVector(pointer, vector, vector.length, id)) {
            throw new IllegalArgumentException("Failed to add vector to MMap vector store builder");
        }
    }

    /**
     * Reserve space for the specified number of vectors
     *
     * @param capacity The number of vectors to reserve space for
     */
    public void reserve(int capacity) {
        reserve(pointer, capacity);
    }

    /**
     * Save the builder's contents to a file, creating an MMapVectorStore
     *
     * @param filename The path to the file where the vector store should be saved
     * @return true if the vector store was saved successfully
     */
    public boolean save(String filename) {
        return save(pointer, filename);
    }

    /**
     * Get the number of vectors in the builder
     *
     * @return The number of vectors in the builder
     */
    public int getCount() {
        return getCount(pointer);
    }

    /**
     * Get the dimension of the vectors in the builder
     *
     * @return The dimension of the vectors
     */
    public int getDimension() {
        return getDimension(pointer);
    }

    /**
     * Close the builder and free resources
     */
    @Override
    public void close() {
        if (pointer != 0L) {
            destroyBuilder(pointer);
            pointer = 0L;
        }
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        close();
    }

    // JNI methods
    private native long createBuilder(int dimension, int metric);
    private native void destroyBuilder(long builder);
    private native boolean addVector(long builder, float[] vector, int vectorSize, int id);
    private native void reserve(long builder, int capacity);
    private native boolean save(long builder, String filename);
    private native int getCount(long builder);
    private native int getDimension(long builder);

    static {
        System.loadLibrary("llamamobilevd");
    }
}

/**
 * A memory-mapped vector store optimized for large datasets that may exceed RAM capacity
 * Uses memory mapping for efficient access to large datasets without loading everything into RAM
 */
public class MMapVectorStore implements AutoCloseable {
    private long pointer;

    /**
     * Create a new MMapVectorStore instance with a loaded pointer
     */
    private MMapVectorStore(long pointer) {
        this.pointer = pointer;
    }

    /**
     * Open an MMapVectorStore from a file
     *
     * @param filename The path to the file containing the saved vector store
     * @return The loaded MMapVectorStore
     * @throws IllegalStateException If the vector store could not be opened
     */
    public static MMapVectorStore open(String filename) {
        long storePointer = nativeOpen(filename);
        if (storePointer == 0L) {
            throw new IllegalStateException("Failed to open MMap vector store from file: " + filename);
        }
        return new MMapVectorStore(storePointer);
    }

    /**
     * Get a vector from the store by ID
     *
     * @param id The ID of the vector to get
     * @return The vector if found, null otherwise
     */
    public float[] get(int id) {
        int dimension = getDimension();
        float[] vector = new float[dimension];
        return nativeGet(pointer, id, vector) ? vector : null;
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
        long resultsPtr = nativeSearch(pointer, queryVector, queryVector.length, k, resultCount);
        if (resultsPtr == 0L) {
            throw new IllegalArgumentException("Failed to search vectors in MMap vector store");
        }

        try {
            SearchResult[] results = new SearchResult[resultCount[0]];
            for (int i = 0; i < resultCount[0]; i++) {
                int id = nativeGetResultId(resultsPtr, i);
                float distance = nativeGetResultDistance(resultsPtr, i);
                results[i] = new SearchResult(id, distance);
            }
            return results;
        } finally {
            nativeFreeSearchResults(resultsPtr);
        }
    }

    /**
     * Check if the store contains a vector with the given ID
     *
     * @param id The ID to check
     * @return true if the vector exists, false otherwise
     */
    public boolean contains(int id) {
        int[] contains = new int[1];
        return nativeContains(pointer, id, contains);
    }

    /**
     * Get the number of vectors in the store
     *
     * @return The number of vectors in the store
     */
    public int getCount() {
        return nativeGetCount(pointer);
    }

    /**
     * Get the dimension of the vectors in the store
     *
     * @return The dimension of the vectors
     */
    public int getDimension() {
        return nativeGetDimension(pointer);
    }

    /**
     * Get the distance metric used by the store
     *
     * @return The distance metric
     */
    public DistanceMetric getMetric() {
        int metricValue = nativeGetMetric(pointer);
        switch (metricValue) {
            case 0:
                return DistanceMetric.L2;
            case 1:
                return DistanceMetric.COSINE;
            case 2:
                return DistanceMetric.DOT;
            default:
                return DistanceMetric.L2;
        }
    }

    /**
     * Close the vector store and free resources
     */
    @Override
    public void close() {
        if (pointer != 0L) {
            nativeClose(pointer);
            pointer = 0L;
        }
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        close();
    }

    // JNI methods
    private static native long nativeOpen(String filename);
    private native boolean nativeGet(long store, int id, float[] vector);
    private native long nativeSearch(long store, float[] queryVector, int vectorSize, int k, int[] resultCount);
    private native boolean nativeContains(long store, int id, int[] contains);
    private native int nativeGetCount(long store);
    private native int nativeGetDimension(long store);
    private native int nativeGetMetric(long store);
    private native void nativeClose(long store);
    private native void nativeFreeSearchResults(long results);
    private native int nativeGetResultId(long results, int index);
    private native float nativeGetResultDistance(long results, int index);

    static {
        System.loadLibrary("llamamobilevd");
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
     * Set the efSearch parameter for search operations
     *
     * @param efSearch The new efSearch value
     */
    public void setEfSearch(int efSearch) {
        setEfSearch(pointer, efSearch);
    }

    /**
     * Get the current efSearch parameter
     *
     * @return The current efSearch value
     */
    public int getEfSearch() {
        return getEfSearch(pointer);
    }

    /**
     * Get the dimension of the vectors in the index
     *
     * @return The dimension of the vectors
     */
    public int getDimension() {
        return getDimension(pointer);
    }

    /**
     * Get the maximum capacity of the index
     *
     * @return The maximum capacity
     */
    public int getCapacity() {
        return getCapacity(pointer);
    }

    /**
     * Check if the index contains a vector with the given ID
     *
     * @param id The ID to check
     * @return true if the vector exists, false otherwise
     */
    public boolean contains(int id) {
        int[] contains = new int[1];
        return contains(pointer, id, contains);
    }

    /**
     * Get a vector from the index by ID
     *
     * @param id The ID of the vector to get
     * @return The vector if found, null otherwise
     */
    public float[] getVector(int id) {
        int dimension = getDimension();
        float[] vector = new float[dimension];
        return getVector(pointer, id, vector) ? vector : null;
    }

    /**
     * Save the index to a file
     *
     * @param filename The path to the file where the index should be saved
     * @return true if the index was saved successfully, false otherwise
     */
    public boolean save(String filename) {
        return save(pointer, filename);
    }

    /**
     * Load an HNSW index from a file
     *
     * @param filename The path to the file containing the saved index
     * @return The loaded HNSW index
     * @throws IllegalStateException If the index could not be loaded
     */
    public static HNSWIndex load(String filename) {
        long indexPointer = nativeLoad(filename);
        if (indexPointer == 0L) {
            throw new IllegalStateException("Failed to load HNSW index from file: " + filename);
        }
        
        // Create a new HNSWIndex instance with the loaded pointer
        try {
            // Use reflection to access the private constructor
            java.lang.reflect.Constructor<HNSWIndex> constructor = HNSWIndex.class.getDeclaredConstructor(long.class);
            constructor.setAccessible(true);
            return constructor.newInstance(indexPointer);
        } catch (Exception e) {
            throw new RuntimeException("Failed to create HNSWIndex instance from loaded pointer", e);
        }
    }

    /**
     * Private constructor for loading an existing index pointer
     */
    private HNSWIndex(long pointer) {
        this.pointer = pointer;
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
    private native void setEfSearch(long index, int efSearch);
    private native int getEfSearch(long index);
    private native int getDimension(long index);
    private native int getCapacity(long index);
    private native boolean contains(long index, int id, int[] contains);
    private native boolean getVector(long index, int id, float[] vector);
    private native boolean save(long index, String filename);
    private static native long nativeLoad(String filename);
    private native void freeSearchResults(long results);
    private native int getResultId(long results, int index);
    private native float getResultDistance(long results, int index);
    private native int getCount(long index);
    private native void clear(long index);

    static {
        System.loadLibrary("llamamobilevd");
    }
}

/**
 * Utility class for LlamaMobileVD
 */
public class LlamaMobileVD {
    /**
     * Get the version of the LlamaMobileVD library
     *
     * @return The version string
     */
    public static String getVersion() {
        return nativeGetVersion();
    }

    // JNI methods
    private static native String nativeGetVersion();

    static {
        System.loadLibrary("llamamobilevd");
    }
}
