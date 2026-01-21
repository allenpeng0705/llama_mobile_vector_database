package com.llamamobile.vd;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Instrumented test for LlamaMobileVD Android SDK (Java)
 * Runs on an Android device or emulator.
 */
@RunWith(AndroidJUnit4.class)
public class LlamaMobileVDInstrumentedTests {
    private final android.content.Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();

    // Test VectorStore with all APIs
    @Test
    public void testVectorStoreFullAPI() {
        // Test with small dimension
        int smallDimension = 32;
        long storeId = LlamaMobileVD.nativeVectorStoreCreate(smallDimension, LlamaMobileVD.DistanceMetric.L2.getValue());
        Assert.assertNotNull(storeId);
        Assert.assertTrue(storeId > 0);
        
        // Test getMetric
        Assert.assertEquals(LlamaMobileVD.DistanceMetric.L2.getValue(), LlamaMobileVD.nativeVectorStoreGetMetric(storeId));
        
        // Test reserve
        Assert.assertTrue(LlamaMobileVD.nativeVectorStoreReserve(storeId, 100));
        
        // Test add vectors
        float[] vector1 = new float[smallDimension];
        float[] vector2 = new float[smallDimension];
        for (int i = 0; i < smallDimension; i++) {
            vector1[i] = 1.0f;
            vector2[i] = 2.0f;
        }
        LlamaMobileVD.nativeVectorStoreAddVector(storeId, 1, vector1);
        LlamaMobileVD.nativeVectorStoreAddVector(storeId, 2, vector2);
        
        // Test size
        Assert.assertEquals(2L, LlamaMobileVD.nativeVectorStoreGetSize(storeId));
        
        // Test update vector
        float[] updatedVector = new float[smallDimension];
        for (int i = 0; i < smallDimension; i++) {
            updatedVector[i] = 1.5f;
        }
        Assert.assertTrue(LlamaMobileVD.nativeVectorStoreUpdateVector(storeId, 1, updatedVector));
        
        // Test get updated vector
        float[] retrievedVector = LlamaMobileVD.nativeVectorStoreGetVector(storeId, 1);
        Assert.assertNotNull(retrievedVector);
        Assert.assertEquals(smallDimension, retrievedVector.length);
        for (int i = 0; i < smallDimension; i++) {
            Assert.assertEquals(1.5f, retrievedVector[i], 0.0001f);
        }
        
        // Test search
        float[] query = new float[smallDimension];
        for (int i = 0; i < smallDimension; i++) {
            query[i] = 1.0f;
        }
        LlamaMobileVD.SearchResult[] results = LlamaMobileVD.nativeVectorStoreSearch(storeId, query, 2);
        Assert.assertEquals(2, results.length);
        
        // Test clear
        LlamaMobileVD.nativeVectorStoreClear(storeId);
        Assert.assertEquals(0L, LlamaMobileVD.nativeVectorStoreGetSize(storeId));
        
        LlamaMobileVD.nativeVectorStoreDestroy(storeId);
    }

    // Test VectorStore with different dimensions
    @Test
    public void testVectorStoreWithDifferentDimensions() {
        // Test with small dimension
        int smallDimension = 64;
        long smallStoreId = LlamaMobileVD.nativeVectorStoreCreate(smallDimension, LlamaMobileVD.DistanceMetric.COSINE.getValue());
        Assert.assertTrue(smallStoreId > 0);
        
        // Test with medium dimension
        int mediumDimension = 256;
        long mediumStoreId = LlamaMobileVD.nativeVectorStoreCreate(mediumDimension, LlamaMobileVD.DistanceMetric.COSINE.getValue());
        Assert.assertTrue(mediumStoreId > 0);
        
        // Test with large dimension
        int largeDimension = 512;
        long largeStoreId = LlamaMobileVD.nativeVectorStoreCreate(largeDimension, LlamaMobileVD.DistanceMetric.COSINE.getValue());
        Assert.assertTrue(largeStoreId > 0);
        
        // Clean up
        LlamaMobileVD.nativeVectorStoreDestroy(smallStoreId);
        LlamaMobileVD.nativeVectorStoreDestroy(mediumStoreId);
        LlamaMobileVD.nativeVectorStoreDestroy(largeStoreId);
    }

    // Test VectorStore with different dataset sizes
    @Test
    public void testVectorStoreWithDifferentDatasetSizes() {
        int dimension = 64;
        long storeId = LlamaMobileVD.nativeVectorStoreCreate(dimension, LlamaMobileVD.DistanceMetric.L2.getValue());
        
        // Test with small dataset (100 vectors)
        int smallDatasetSize = 100;
        for (int i = 0; i < smallDatasetSize; i++) {
            float[] vector = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vector[j] = i;
            }
            LlamaMobileVD.nativeVectorStoreAddVector(storeId, i, vector);
        }
        Assert.assertEquals(smallDatasetSize, LlamaMobileVD.nativeVectorStoreGetSize(storeId));
        
        // Test search with small dataset
        float[] query = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            query[i] = 0.0f;
        }
        LlamaMobileVD.SearchResult[] smallResults = LlamaMobileVD.nativeVectorStoreSearch(storeId, query, 10);
        Assert.assertEquals(10, smallResults.length);
        
        // Clean up
        LlamaMobileVD.nativeVectorStoreDestroy(storeId);
    }

    // Test HNSWIndex with all APIs
    @Test
    public void testHNSWIndexFullAPI() {
        int dimension = 64;
        long maxElements = 1000;
        
        // Create HNSWIndex
        long indexId = LlamaMobileVD.nativeHNSWIndexCreate(dimension, LlamaMobileVD.DistanceMetric.COSINE.getValue(), maxElements);
        Assert.assertTrue(indexId > 0);
        
        // Test getDimension
        Assert.assertEquals(dimension, LlamaMobileVD.nativeHNSWIndexGetDimension(indexId));
        
        // Test getCapacity
        Assert.assertEquals(maxElements, LlamaMobileVD.nativeHNSWIndexGetCapacity(indexId));
        
        // Test setEfSearch
        int efSearch = 64;
        Assert.assertTrue(LlamaMobileVD.nativeHNSWIndexSetEfSearch(indexId, efSearch));
        Assert.assertEquals(efSearch, LlamaMobileVD.nativeHNSWIndexGetEfSearch(indexId));
        
        // Test add vectors
        for (int i = 0; i < 100; i++) {
            float[] vector = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vector[j] = i;
            }
            Assert.assertTrue(LlamaMobileVD.nativeHNSWIndexAddVector(indexId, i, vector));
        }
        
        // Test size
        Assert.assertEquals(100L, LlamaMobileVD.nativeHNSWIndexGetSize(indexId));
        
        // Test contains
        Assert.assertTrue(LlamaMobileVD.nativeHNSWIndexContains(indexId, 50));
        Assert.assertFalse(LlamaMobileVD.nativeHNSWIndexContains(indexId, 1000));
        
        // Test getVector
        float[] retrievedVector = LlamaMobileVD.nativeHNSWIndexGetVector(indexId, 50);
        Assert.assertNotNull(retrievedVector);
        Assert.assertEquals(dimension, retrievedVector.length);
        
        // Test search
        float[] query = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            query[i] = 0.0f;
        }
        LlamaMobileVD.SearchResult[] results = LlamaMobileVD.nativeHNSWIndexSearch(indexId, query, 10);
        Assert.assertEquals(10, results.length);
        
        // Test save and load (using temp file)
        String tempDir = appContext.getCacheDir().getAbsolutePath();
        String filePath = tempDir + "/test_hnsw_index.bin";
        Assert.assertTrue(LlamaMobileVD.nativeHNSWIndexSave(indexId, filePath));
        
        long loadedIndexId = LlamaMobileVD.nativeHNSWIndexLoad(filePath);
        Assert.assertTrue(loadedIndexId > 0);
        Assert.assertEquals(100L, LlamaMobileVD.nativeHNSWIndexGetSize(loadedIndexId));
        
        // Clean up
        LlamaMobileVD.nativeHNSWIndexDestroy(indexId);
        LlamaMobileVD.nativeHNSWIndexDestroy(loadedIndexId);
        java.io.File file = new java.io.File(filePath);
        if (file.exists()) {
            file.delete();
        }
    }

    // Test MMapVectorStoreBuilder and MMapVectorStore
    @Test
    public void testMMapVectorStoreFullAPI() {
        int dimension = 64;
        String tempDir = appContext.getCacheDir().getAbsolutePath();
        String filePath = tempDir + "/test_mmap_store.bin";
        
        // Create builder
        long builderId = LlamaMobileVD.nativeMMapVectorStoreBuilderCreate(dimension, LlamaMobileVD.DistanceMetric.L2.getValue());
        Assert.assertTrue(builderId > 0);
        
        // Test builder getDimension
        Assert.assertEquals(dimension, LlamaMobileVD.nativeMMapVectorStoreBuilderGetDimension(builderId));
        
        // Test builder reserve
        Assert.assertTrue(LlamaMobileVD.nativeMMapVectorStoreBuilderReserve(builderId, 100));
        
        // Test builder add vectors
        for (int i = 0; i < 50; i++) {
            float[] vector = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vector[j] = i;
            }
            Assert.assertTrue(LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, i, vector));
        }
        
        // Test builder getSize
        Assert.assertEquals(50L, LlamaMobileVD.nativeMMapVectorStoreBuilderGetSize(builderId));
        
        // Test builder save
        Assert.assertTrue(LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderId, filePath));
        
        // Destroy builder
        LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderId);
        
        // Open MMapVectorStore
        long storeId = LlamaMobileVD.nativeMMapVectorStoreOpen(filePath);
        Assert.assertTrue(storeId > 0);
        
        // Test MMapVectorStore getMetric
        Assert.assertEquals(LlamaMobileVD.DistanceMetric.L2.getValue(), LlamaMobileVD.nativeMMapVectorStoreGetMetric(storeId));
        
        // Test MMapVectorStore getDimension
        Assert.assertEquals(dimension, LlamaMobileVD.nativeMMapVectorStoreGetDimension(storeId));
        
        // Test MMapVectorStore getSize
        Assert.assertEquals(50L, LlamaMobileVD.nativeMMapVectorStoreGetSize(storeId));
        
        // Test MMapVectorStore contains
        Assert.assertTrue(LlamaMobileVD.nativeMMapVectorStoreContains(storeId, 25));
        
        // Test MMapVectorStore getVector
        float[] retrievedVector = LlamaMobileVD.nativeMMapVectorStoreGetVector(storeId, 25);
        Assert.assertNotNull(retrievedVector);
        Assert.assertEquals(dimension, retrievedVector.length);
        
        // Test MMapVectorStore search
        float[] query = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            query[i] = 0.0f;
        }
        LlamaMobileVD.SearchResult[] results = LlamaMobileVD.nativeMMapVectorStoreSearch(storeId, query, 10);
        Assert.assertEquals(10, results.length);
        
        // Close MMapVectorStore
        LlamaMobileVD.nativeMMapVectorStoreClose(storeId);
        
        // Clean up
        java.io.File file = new java.io.File(filePath);
        if (file.exists()) {
            file.delete();
        }
    }

    // Test version information
    @Test
    public void testVersionInformation() {
        // Test getVersion
        String version = LlamaMobileVD.nativeGetVersion();
        Assert.assertNotNull(version);
        Assert.assertFalse(version.isEmpty());
        
        // Test getVersionMajor
        int major = LlamaMobileVD.nativeGetVersionMajor();
        Assert.assertTrue(major >= 0);
        
        // Test getVersionMinor
        int minor = LlamaMobileVD.nativeGetVersionMinor();
        Assert.assertTrue(minor >= 0);
        
        // Test getVersionPatch
        int patch = LlamaMobileVD.nativeGetVersionPatch();
        Assert.assertTrue(patch >= 0);
    }

    // Test with large dimension (up to 3096)
    @Test
    public void testWithLargeDimension() {
        int largeDimension = 1024; // Using 1024 instead of 3096 for faster testing
        
        // Test VectorStore with large dimension
        long storeId = LlamaMobileVD.nativeVectorStoreCreate(largeDimension, LlamaMobileVD.DistanceMetric.COSINE.getValue());
        Assert.assertTrue(storeId > 0);
        
        // Add a vector
        float[] vector = new float[largeDimension];
        for (int i = 0; i < largeDimension; i++) {
            vector[i] = 1.0f;
        }
        LlamaMobileVD.nativeVectorStoreAddVector(storeId, 1, vector);
        
        // Test search
        float[] query = new float[largeDimension];
        for (int i = 0; i < largeDimension; i++) {
            query[i] = 1.0f;
        }
        LlamaMobileVD.SearchResult[] results = LlamaMobileVD.nativeVectorStoreSearch(storeId, query, 1);
        Assert.assertEquals(1, results.length);
        
        LlamaMobileVD.nativeVectorStoreDestroy(storeId);
    }
}
