package com.llamamobile.vd;

public class LlamaMobileVD {
    static {
        System.loadLibrary("llamamobilevd");
    }

    public enum DistanceMetric {
        L2, COSINE, DOT
    }

    public static class SearchResult {
        public long id;
        public float distance;

        public SearchResult(long id, float distance) {
            this.id = id;
            this.distance = distance;
        }

        @Override
        public String toString() {
            return "SearchResult{id=" + id + ", distance=" + distance + "}";
        }
    }

    public static class VectorStore {
        private long nativeHandle;
        private final int dimension;
        private final DistanceMetric metric;

        public VectorStore(int dimension, DistanceMetric metric) {
            this.dimension = dimension;
            this.metric = metric;
            this.nativeHandle = nativeCreateVectorStore(dimension, metric.ordinal());
        }

        protected void finalize() throws Throwable {
            try {
                if (nativeHandle != 0) {
                    nativeDestroyVectorStore(nativeHandle);
                    nativeHandle = 0;
                }
            } finally {
                super.finalize();
            }
        }

        public void add(long id, float[] vector) {
            if (vector.length != dimension) {
                throw new IllegalArgumentException("Vector dimension mismatch: expected " + dimension + ", got " + vector.length);
            }
            nativeAddVector(nativeHandle, id, vector);
        }

        public boolean remove(long id) {
            return nativeRemoveVector(nativeHandle, id);
        }

        public float[] get(long id) {
            float[] vector = new float[dimension];
            boolean found = nativeGetVector(nativeHandle, id, vector);
            if (!found) {
                throw new IllegalArgumentException("ID not found: " + id);
            }
            return vector;
        }

        public boolean update(long id, float[] vector) {
            if (vector.length != dimension) {
                throw new IllegalArgumentException("Vector dimension mismatch: expected " + dimension + ", got " + vector.length);
            }
            return nativeUpdateVector(nativeHandle, id, vector);
        }

        public SearchResult[] search(float[] query, int k) {
            if (query.length != dimension) {
                throw new IllegalArgumentException("Query dimension mismatch: expected " + dimension + ", got " + query.length);
            }
            return nativeSearchVectors(nativeHandle, query, k);
        }

        public int size() {
            return nativeVectorStoreSize(nativeHandle);
        }

        public int dimension() {
            return dimension;
        }

        public DistanceMetric metric() {
            return metric;
        }

        public boolean contains(long id) {
            return nativeVectorStoreContains(nativeHandle, id);
        }

        public void reserve(int capacity) {
            nativeVectorStoreReserve(nativeHandle, capacity);
        }

        public void clear() {
            nativeVectorStoreClear(nativeHandle);
        }
    }

    public static class HNSWIndex {
        private long nativeHandle;
        private final int dimension;
        private final DistanceMetric metric;
        private final int maxElements;

        public HNSWIndex(int dimension, DistanceMetric metric, int maxElements) {
            this(dimension, metric, maxElements, 16, 200, 42);
        }

        public HNSWIndex(int dimension, DistanceMetric metric, int maxElements, int M, int efConstruction, int seed) {
            this.dimension = dimension;
            this.metric = metric;
            this.maxElements = maxElements;
            this.nativeHandle = nativeCreateHNSWIndex(dimension, metric.ordinal(), maxElements, M, efConstruction, seed);
        }

        protected void finalize() throws Throwable {
            try {
                if (nativeHandle != 0) {
                    nativeDestroyHNSWIndex(nativeHandle);
                    nativeHandle = 0;
                }
            } finally {
                super.finalize();
            }
        }

        public void add(long id, float[] vector) {
            if (vector.length != dimension) {
                throw new IllegalArgumentException("Vector dimension mismatch: expected " + dimension + ", got " + vector.length);
            }
            nativeAddToHNSWIndex(nativeHandle, id, vector);
        }

        public SearchResult[] search(float[] query, int k) {
            if (query.length != dimension) {
                throw new IllegalArgumentException("Query dimension mismatch: expected " + dimension + ", got " + query.length);
            }
            return nativeSearchHNSWIndex(nativeHandle, query, k);
        }

        public void setEfSearch(int ef) {
            nativeSetEfSearch(nativeHandle, ef);
        }

        public int getEfSearch() {
            return nativeGetEfSearch(nativeHandle);
        }

        public int size() {
            return nativeHNSWIndexSize(nativeHandle);
        }

        public int dimension() {
            return dimension;
        }

        public int capacity() {
            return maxElements;
        }

        public boolean contains(long id) {
            return nativeHNSWIndexContains(nativeHandle, id);
        }

        public float[] getVector(long id) {
            float[] vector = new float[dimension];
            boolean found = nativeGetVectorFromHNSWIndex(nativeHandle, id, vector);
            if (!found) {
                throw new IllegalArgumentException("ID not found: " + id);
            }
            return vector;
        }

        public void save(String filename) {
            nativeSaveHNSWIndex(nativeHandle, filename);
        }

        public static HNSWIndex load(String filename) {
            long handle = nativeLoadHNSWIndex(filename);
            if (handle == 0) {
                throw new IllegalArgumentException("Failed to load HNSW index from: " + filename);
            }
            // Create a dummy instance with basic info
            HNSWIndex index = new HNSWIndex(0, DistanceMetric.L2, 0);
            index.nativeHandle = handle;
            // Update the actual properties
            index.dimension = nativeHNSWIndexDimension(handle);
            index.maxElements = nativeHNSWIndexCapacity(handle);
            index.metric = DistanceMetric.values()[nativeHNSWIndexMetric(handle)];
            return index;
        }
    }

    public static String getVersion() {
        return nativeGetVersion();
    }

    // Native methods
    private static native long nativeCreateVectorStore(int dimension, int metric);
    private static native void nativeDestroyVectorStore(long handle);
    private static native void nativeAddVector(long handle, long id, float[] vector);
    private static native boolean nativeRemoveVector(long handle, long id);
    private static native boolean nativeGetVector(long handle, long id, float[] vector);
    private static native boolean nativeUpdateVector(long handle, long id, float[] vector);
    private static native SearchResult[] nativeSearchVectors(long handle, float[] query, int k);
    private static native int nativeVectorStoreSize(long handle);
    private static native boolean nativeVectorStoreContains(long handle, long id);
    private static native void nativeVectorStoreReserve(long handle, int capacity);
    private static native void nativeVectorStoreClear(long handle);

    private static native long nativeCreateHNSWIndex(int dimension, int metric, int maxElements, int M, int efConstruction, int seed);
    private static native void nativeDestroyHNSWIndex(long handle);
    private static native void nativeAddToHNSWIndex(long handle, long id, float[] vector);
    private static native SearchResult[] nativeSearchHNSWIndex(long handle, float[] query, int k);
    private static native void nativeSetEfSearch(long handle, int ef);
    private static native int nativeGetEfSearch(long handle);
    private static native int nativeHNSWIndexSize(long handle);
    private static native int nativeHNSWIndexDimension(long handle);
    private static native int nativeHNSWIndexCapacity(long handle);
    private static native int nativeHNSWIndexMetric(long handle);
    private static native boolean nativeHNSWIndexContains(long handle, long id);
    private static native boolean nativeGetVectorFromHNSWIndex(long handle, long id, float[] vector);
    private static native void nativeSaveHNSWIndex(long handle, String filename);
    private static native long nativeLoadHNSWIndex(String filename);
    private static native String nativeGetVersion();
}
