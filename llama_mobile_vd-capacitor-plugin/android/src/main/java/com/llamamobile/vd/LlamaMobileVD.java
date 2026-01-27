package com.llamamobile.vd;

import java.util.List;

public class LlamaMobileVD {
    
    static {
        System.loadLibrary("llama_mobile_vd");
    }
    
    public static native String getVersion();
    
    public static native long nativeVectorStoreCreate(int dimension, int metric);
    public static native void nativeVectorStoreDestroy(long storeId);
    public static native void nativeVectorStoreAddVectors(long storeId, List<double[]> vectors);
    public static native void nativeVectorStoreAddVectors(long storeId, List<double[]> vectors, int[] ids);
    public static native double[] nativeVectorStoreGetVector(long storeId, int id);
    public static native void nativeVectorStoreSearch(long storeId, double[] queryVector, int k, int[] ids, double[] distances);
    public static native void nativeVectorStoreRemoveVectors(long storeId, int[] ids);
    public static native int nativeVectorStoreGetCount(long storeId);
    public static native void nativeVectorStoreClear(long storeId);
    
    public static native long nativeHNSWIndexCreate(int dimension, int metric, long maxElements);
    public static native long nativeHNSWIndexCreateWithParams(int dimension, int metric, long maxElements, int m, int efConstruction, int seed);
    public static native void nativeHNSWIndexDestroy(long indexId);
    public static native void nativeHNSWIndexSearch(long indexId, double[] queryVector, int k, int[] ids, double[] distances);
    public static native void nativeHNSWIndexSearch(long indexId, double[] queryVector, int k, int efSearch, int[] ids, double[] distances);
    public static native void nativeHNSWIndexAddVectors(long indexId, List<double[]> vectors);
    public static native void nativeHNSWIndexAddVectors(long indexId, List<double[]> vectors, int[] ids);
    public static native int nativeHNSWIndexGetCount(long indexId);
    
    public static native long nativeMMapVectorStoreBuilderCreate(int dimension, int metric);
    public static native void nativeMMapVectorStoreBuilderDestroy(long builderId);
    public static native void nativeMMapVectorStoreBuilderAddVectors(long builderId, List<double[]> vectors);
    public static native void nativeMMapVectorStoreBuilderAddVectors(long builderId, List<double[]> vectors, int[] ids);
    public static native void nativeMMapVectorStoreBuilderSave(long builderId, String path);
    
    public static native long nativeMMapVectorStoreOpen(String path);
    public static native void nativeMMapVectorStoreClose(long storeId);
    public static native double[] nativeMMapVectorStoreGetVector(long storeId, int id);
    public static native void nativeMMapVectorStoreSearch(long storeId, double[] queryVector, int k, int[] ids, double[] distances);
    public static native int nativeMMapVectorStoreGetCount(long storeId);
}
