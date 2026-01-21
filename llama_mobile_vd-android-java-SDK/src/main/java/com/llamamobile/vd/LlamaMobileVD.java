package com.llamamobile.vd;

public class LlamaMobileVD {
    static {
        System.loadLibrary("llama_mobile_vd_jni");
    }
    
    // Distance Metric enum
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
    
    // VectorStore native methods
    public static native long nativeVectorStoreCreate(int dimension, int metric);
    public static native void nativeVectorStoreAddVector(long storeId, long id, float[] vector);
    public static native SearchResult[] nativeVectorStoreSearch(long storeId, float[] queryVector, int k);
    public static native float[] nativeVectorStoreGetVector(long storeId, long id);
    public static native boolean nativeVectorStoreRemoveVector(long storeId, long id);
    public static native boolean nativeVectorStoreContains(long storeId, long id);
    public static native long nativeVectorStoreGetSize(long storeId);
    public static native int nativeVectorStoreGetDimension(long storeId);
    public static native int nativeVectorStoreGetMetric(long storeId);
    public static native boolean nativeVectorStoreUpdateVector(long storeId, long id, float[] vector);
    public static native boolean nativeVectorStoreReserve(long storeId, long capacity);
    public static native void nativeVectorStoreClear(long storeId);
    public static native void nativeVectorStoreDestroy(long storeId);
    
    // HNSWIndex native methods
    public static native long nativeHNSWIndexCreate(int dimension, int metric, long maxElements);
    public static native long nativeHNSWIndexCreateWithParams(int dimension, int metric, long maxElements, int M, int efConstruction, int seed);
    public static native boolean nativeHNSWIndexAddVector(long indexId, long id, float[] vector);
    public static native SearchResult[] nativeHNSWIndexSearch(long indexId, float[] queryVector, int k);
    public static native boolean nativeHNSWIndexSetEfSearch(long indexId, int efSearch);
    public static native int nativeHNSWIndexGetEfSearch(long indexId);
    public static native long nativeHNSWIndexGetSize(long indexId);
    public static native int nativeHNSWIndexGetDimension(long indexId);
    public static native long nativeHNSWIndexGetCapacity(long indexId);
    public static native boolean nativeHNSWIndexContains(long indexId, long id);
    public static native float[] nativeHNSWIndexGetVector(long indexId, long id);
    public static native boolean nativeHNSWIndexSave(long indexId, String filename);
    public static native long nativeHNSWIndexLoad(String filename);
    public static native void nativeHNSWIndexDestroy(long indexId);
    
    // MMapVectorStoreBuilder native methods
    public static native long nativeMMapVectorStoreBuilderCreate(int dimension, int metric);
    public static native boolean nativeMMapVectorStoreBuilderAddVector(long builderId, long id, float[] vector);
    public static native boolean nativeMMapVectorStoreBuilderReserve(long builderId, long capacity);
    public static native boolean nativeMMapVectorStoreBuilderSave(long builderId, String filename);
    public static native long nativeMMapVectorStoreBuilderGetSize(long builderId);
    public static native int nativeMMapVectorStoreBuilderGetDimension(long builderId);
    public static native void nativeMMapVectorStoreBuilderDestroy(long builderId);
    
    // MMapVectorStore native methods
    public static native long nativeMMapVectorStoreOpen(String filename);
    public static native float[] nativeMMapVectorStoreGetVector(long storeId, long id);
    public static native boolean nativeMMapVectorStoreContains(long storeId, long id);
    public static native SearchResult[] nativeMMapVectorStoreSearch(long storeId, float[] queryVector, int k);
    public static native long nativeMMapVectorStoreGetSize(long storeId);
    public static native int nativeMMapVectorStoreGetDimension(long storeId);
    public static native int nativeMMapVectorStoreGetMetric(long storeId);
    public static native void nativeMMapVectorStoreClose(long storeId);
    
    // Version information native methods
    public static native String nativeGetVersion();
    public static native int nativeGetVersionMajor();
    public static native int nativeGetVersionMinor();
    public static native int nativeGetVersionPatch();
    
    // Convenience methods for VectorStore
    public static long createVectorStore(int dimension, DistanceMetric metric) {
        return nativeVectorStoreCreate(dimension, metric.getValue());
    }
    
    public static long createVectorStore(int dimension) {
        return createVectorStore(dimension, DistanceMetric.COSINE);
    }
    
    // Convenience methods for HNSWIndex
    public static long createHNSWIndex(int dimension, DistanceMetric metric, long maxElements) {
        return nativeHNSWIndexCreate(dimension, metric.getValue(), maxElements);
    }
    
    public static long createHNSWIndex(int dimension, DistanceMetric metric, long maxElements, int M, int efConstruction, int seed) {
        return nativeHNSWIndexCreateWithParams(dimension, metric.getValue(), maxElements, M, efConstruction, seed);
    }
    
    public static long createHNSWIndex(int dimension, long maxElements) {
        return createHNSWIndex(dimension, DistanceMetric.COSINE, maxElements);
    }
    
    // Convenience methods for MMapVectorStoreBuilder
    public static long createMMapVectorStoreBuilder(int dimension, DistanceMetric metric) {
        return nativeMMapVectorStoreBuilderCreate(dimension, metric.getValue());
    }
    
    public static long createMMapVectorStoreBuilder(int dimension) {
        return createMMapVectorStoreBuilder(dimension, DistanceMetric.COSINE);
    }
    
    public static void saveMMapVectorStoreBuilder(long builderId, String filename) {
        nativeMMapVectorStoreBuilderSave(builderId, filename);
    }
    
    // Convenience methods for MMapVectorStore
    public static long openMMapVectorStore(String filePath) {
        return nativeMMapVectorStoreOpen(filePath);
    }
    
    // Version information methods
    public static String getVersion() {
        return nativeGetVersion();
    }
    
    public static int getVersionMajor() {
        return nativeGetVersionMajor();
    }
    
    public static int getVersionMinor() {
        return nativeGetVersionMinor();
    }
    
    public static int getVersionPatch() {
        return nativeGetVersionPatch();
    }
    
    // SearchResult class for search query results
    public static class SearchResult {
        private final long id;
        private final float distance;
        
        public SearchResult(long id, float distance) {
            this.id = id;
            this.distance = distance;
        }
        
        public long getId() {
            return id;
        }
        
        public float getDistance() {
            return distance;
        }
        
        @Override
        public String toString() {
            return "SearchResult{id=" + id + ", distance=" + distance + "}";
        }
    }
    
    // LlamaMobileVDException class for error handling
    public static class LlamaMobileVDException extends RuntimeException {
        public LlamaMobileVDException(String message) {
            super(message);
        }
        
        public LlamaMobileVDException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
