package com.llamamobile.vd

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Instrumented test for LlamaMobileVD Android SDK (Kotlin)
 * Runs on an Android device or emulator.
 */
@RunWith(AndroidJUnit4::class)
class LlamaMobileVDInstrumentedTests {
    private val appContext = InstrumentationRegistry.getInstrumentation().targetContext

    // Test VectorStore with all APIs
    @Test
    fun testVectorStoreFullAPI() {
        // Test with small dimension
        val smallDimension = 32
        val storeId = LlamaMobileVD.Companion.nativeVectorStoreCreate(smallDimension, LlamaMobileVD.Companion.DistanceMetric.L2.value)
        assertNotNull(storeId)
        assertTrue(storeId > 0)
        
        // Test getMetric
        assertEquals(LlamaMobileVD.Companion.DistanceMetric.L2.value, LlamaMobileVD.Companion.nativeVectorStoreGetMetric(storeId))
        
        // Test reserve
        assertTrue(LlamaMobileVD.Companion.nativeVectorStoreReserve(storeId, 100))
        
        // Test add vectors
        val vector1 = FloatArray(smallDimension) { 1.0f }
        val vector2 = FloatArray(smallDimension) { 2.0f }
        LlamaMobileVD.Companion.nativeVectorStoreAddVector(storeId, 1, vector1)
        LlamaMobileVD.Companion.nativeVectorStoreAddVector(storeId, 2, vector2)
        
        // Test size
        assertEquals(2L, LlamaMobileVD.Companion.nativeVectorStoreGetSize(storeId))
        
        // Test update vector
        val updatedVector = FloatArray(smallDimension) { 1.5f }
        assertTrue(LlamaMobileVD.Companion.nativeVectorStoreUpdateVector(storeId, 1, updatedVector))
        
        // Test get updated vector
        val retrievedVector = LlamaMobileVD.Companion.nativeVectorStoreGetVector(storeId, 1)
        assertNotNull(retrievedVector)
        assertEquals(smallDimension, retrievedVector?.size)
        retrievedVector?.let {
            for (i in 0 until smallDimension) {
                assertEquals(1.5f, it[i], 0.0001f)
            }
        }
        
        // Test search
        val query = FloatArray(smallDimension) { 1.0f }
        val results = LlamaMobileVD.Companion.nativeVectorStoreSearch(storeId, query, 2)
        assertEquals(2, results.size)
        
        // Test clear
        LlamaMobileVD.Companion.nativeVectorStoreClear(storeId)
        assertEquals(0L, LlamaMobileVD.Companion.nativeVectorStoreGetSize(storeId))
        
        LlamaMobileVD.Companion.nativeVectorStoreDestroy(storeId)
    }

    // Test VectorStore with different dimensions
    @Test
    fun testVectorStoreWithDifferentDimensions() {
        // Test with small dimension
        val smallDimension = 64
        val smallStoreId = LlamaMobileVD.Companion.nativeVectorStoreCreate(smallDimension, LlamaMobileVD.Companion.DistanceMetric.COSINE.value)
        assertTrue(smallStoreId > 0)
        
        // Test with medium dimension
        val mediumDimension = 256
        val mediumStoreId = LlamaMobileVD.Companion.nativeVectorStoreCreate(mediumDimension, LlamaMobileVD.Companion.DistanceMetric.COSINE.value)
        assertTrue(mediumStoreId > 0)
        
        // Test with large dimension
        val largeDimension = 512
        val largeStoreId = LlamaMobileVD.Companion.nativeVectorStoreCreate(largeDimension, LlamaMobileVD.Companion.DistanceMetric.COSINE.value)
        assertTrue(largeStoreId > 0)
        
        // Clean up
        LlamaMobileVD.Companion.nativeVectorStoreDestroy(smallStoreId)
        LlamaMobileVD.Companion.nativeVectorStoreDestroy(mediumStoreId)
        LlamaMobileVD.Companion.nativeVectorStoreDestroy(largeStoreId)
    }

    // Test VectorStore with different dataset sizes
    @Test
    fun testVectorStoreWithDifferentDatasetSizes() {
        val dimension = 64
        val storeId = LlamaMobileVD.Companion.nativeVectorStoreCreate(dimension, LlamaMobileVD.Companion.DistanceMetric.L2.value)
        
        // Test with small dataset (100 vectors)
        val smallDatasetSize = 100
        for (i in 0 until smallDatasetSize) {
            val vector = FloatArray(dimension) { i.toFloat() }
            LlamaMobileVD.Companion.nativeVectorStoreAddVector(storeId, i.toLong(), vector)
        }
        assertEquals(smallDatasetSize.toLong(), LlamaMobileVD.Companion.nativeVectorStoreGetSize(storeId))
        
        // Test search with small dataset
        val query = FloatArray(dimension) { 0.0f }
        val smallResults = LlamaMobileVD.Companion.nativeVectorStoreSearch(storeId, query, 10)
        assertEquals(10, smallResults.size)
        
        // Clean up
        LlamaMobileVD.Companion.nativeVectorStoreDestroy(storeId)
    }

    // Test HNSWIndex with all APIs
    @Test
    fun testHNSWIndexFullAPI() {
        val dimension = 64
        val maxElements = 1000L
        
        // Create HNSWIndex
        val indexId = LlamaMobileVD.Companion.nativeHNSWIndexCreate(dimension, LlamaMobileVD.Companion.DistanceMetric.COSINE.value, maxElements)
        assertTrue(indexId > 0)
        
        // Test getDimension
        assertEquals(dimension, LlamaMobileVD.Companion.nativeHNSWIndexGetDimension(indexId))
        
        // Test getCapacity
        assertEquals(maxElements.toLong(), LlamaMobileVD.Companion.nativeHNSWIndexGetCapacity(indexId))
        
        // Test setEfSearch
        val efSearch = 64
        assertTrue(LlamaMobileVD.Companion.nativeHNSWIndexSetEfSearch(indexId, efSearch))
        assertEquals(efSearch, LlamaMobileVD.Companion.nativeHNSWIndexGetEfSearch(indexId))
        
        // Test add vectors
        for (i in 0 until 100) {
            val vector = FloatArray(dimension) { i.toFloat() }
            assertTrue(LlamaMobileVD.Companion.nativeHNSWIndexAddVector(indexId, i.toLong(), vector))
        }
        
        // Test size
        assertEquals(100L, LlamaMobileVD.Companion.nativeHNSWIndexGetSize(indexId))
        
        // Test contains
        assertTrue(LlamaMobileVD.Companion.nativeHNSWIndexContains(indexId, 50))
        assertFalse(LlamaMobileVD.Companion.nativeHNSWIndexContains(indexId, 1000))
        
        // Test getVector
        val retrievedVector = LlamaMobileVD.Companion.nativeHNSWIndexGetVector(indexId, 50)
        assertNotNull(retrievedVector)
        assertEquals(dimension, retrievedVector?.size)
        
        // Test search
        val query = FloatArray(dimension) { 0.0f }
        val results = LlamaMobileVD.Companion.nativeHNSWIndexSearch(indexId, query, 10)
        assertEquals(10, results.size)
        
        // Test save and load (using temp file)
        val tempDir = appContext.cacheDir.absolutePath
        val filePath = "$tempDir/test_hnsw_index.bin"
        assertTrue(LlamaMobileVD.Companion.nativeHNSWIndexSave(indexId, filePath))
        
        val loadedIndexId = LlamaMobileVD.Companion.nativeHNSWIndexLoad(filePath)
        assertTrue(loadedIndexId > 0)
        assertEquals(100L, LlamaMobileVD.Companion.nativeHNSWIndexGetSize(loadedIndexId))
        
        // Clean up
        LlamaMobileVD.Companion.nativeHNSWIndexDestroy(indexId)
        LlamaMobileVD.Companion.nativeHNSWIndexDestroy(loadedIndexId)
        java.io.File(filePath).delete()
    }

    // Test MMapVectorStoreBuilder and MMapVectorStore
    @Test
    fun testMMapVectorStoreFullAPI() {
        val dimension = 64
        val tempDir = appContext.cacheDir.absolutePath
        val filePath = "$tempDir/test_mmap_store.bin"
        
        // Create builder
        val builderId = LlamaMobileVD.Companion.nativeMMapVectorStoreBuilderCreate(dimension, LlamaMobileVD.Companion.DistanceMetric.L2.value)
        assertTrue(builderId > 0)
        
        // Test builder getDimension
        assertEquals(dimension, LlamaMobileVD.Companion.nativeMMapVectorStoreBuilderGetDimension(builderId))
        
        // Test builder reserve
        assertTrue(LlamaMobileVD.Companion.nativeMMapVectorStoreBuilderReserve(builderId, 100))
        
        // Test builder add vectors
        for (i in 0 until 50) {
            val vector = FloatArray(dimension) { i.toFloat() }
            assertTrue(LlamaMobileVD.Companion.nativeMMapVectorStoreBuilderAddVector(builderId, i.toLong(), vector))
        }
        
        // Test builder getSize
        assertEquals(50L, LlamaMobileVD.Companion.nativeMMapVectorStoreBuilderGetSize(builderId))
        
        // Test builder save
        assertTrue(LlamaMobileVD.Companion.nativeMMapVectorStoreBuilderSave(builderId, filePath))
        
        // Destroy builder
        LlamaMobileVD.Companion.nativeMMapVectorStoreBuilderDestroy(builderId)
        
        // Open MMapVectorStore
        val storeId = LlamaMobileVD.Companion.nativeMMapVectorStoreOpen(filePath)
        assertTrue(storeId > 0)
        
        // Test MMapVectorStore getMetric
        assertEquals(LlamaMobileVD.Companion.DistanceMetric.L2.value, LlamaMobileVD.Companion.nativeMMapVectorStoreGetMetric(storeId))
        
        // Test MMapVectorStore getDimension
        assertEquals(dimension, LlamaMobileVD.Companion.nativeMMapVectorStoreGetDimension(storeId))
        
        // Test MMapVectorStore getSize
        assertEquals(50L, LlamaMobileVD.Companion.nativeMMapVectorStoreGetSize(storeId))
        
        // Test MMapVectorStore contains
        assertTrue(LlamaMobileVD.Companion.nativeMMapVectorStoreContains(storeId, 25))
        
        // Test MMapVectorStore getVector
        val retrievedVector = LlamaMobileVD.Companion.nativeMMapVectorStoreGetVector(storeId, 25)
        assertNotNull(retrievedVector)
        assertEquals(dimension, retrievedVector?.size)
        
        // Test MMapVectorStore search
        val query = FloatArray(dimension) { 0.0f }
        val results = LlamaMobileVD.Companion.nativeMMapVectorStoreSearch(storeId, query, 10)
        assertEquals(10, results.size)
        
        // Close MMapVectorStore
        LlamaMobileVD.Companion.nativeMMapVectorStoreClose(storeId)
        
        // Clean up
        java.io.File(filePath).delete()
    }

    // Test version information
    @Test
    fun testVersionInformation() {
        // Test getVersion
        val version = LlamaMobileVD.Companion.nativeGetVersion()
        assertNotNull(version)
        assertFalse(version.isEmpty())
        
        // Test getVersionMajor
        val major = LlamaMobileVD.Companion.nativeGetVersionMajor()
        assertTrue(major >= 0)
        
        // Test getVersionMinor
        val minor = LlamaMobileVD.Companion.nativeGetVersionMinor()
        assertTrue(minor >= 0)
        
        // Test getVersionPatch
        val patch = LlamaMobileVD.Companion.nativeGetVersionPatch()
        assertTrue(patch >= 0)
    }

    // Test with large dimension (up to 3096)
    @Test
    fun testWithLargeDimension() {
        val largeDimension = 1024 // Using 1024 instead of 3096 for faster testing
        
        // Test VectorStore with large dimension
        val storeId = LlamaMobileVD.Companion.nativeVectorStoreCreate(largeDimension, LlamaMobileVD.Companion.DistanceMetric.COSINE.value)
        assertTrue(storeId > 0)
        
        // Add a vector
        val vector = FloatArray(largeDimension) { 1.0f }
        LlamaMobileVD.Companion.nativeVectorStoreAddVector(storeId, 1, vector)
        
        // Test search
        val query = FloatArray(largeDimension) { 1.0f }
        val results = LlamaMobileVD.Companion.nativeVectorStoreSearch(storeId, query, 1)
        assertEquals(1, results.size)
        
        LlamaMobileVD.Companion.nativeVectorStoreDestroy(storeId)
    }
}  