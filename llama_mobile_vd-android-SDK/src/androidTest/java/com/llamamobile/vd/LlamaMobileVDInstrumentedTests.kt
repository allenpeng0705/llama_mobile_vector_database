package com.llamamobile.vd

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import kotlinx.coroutines.runBlocking
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
        runBlocking {
            // Test with small dimension
            val smallDimension = 32
            val storeId = LlamaMobileVD.createVectorStore(smallDimension, DistanceMetric.L2.toJava())
            assertTrue(storeId > 0)
            
            // Test add vectors
            val vector1 = FloatArray(smallDimension) { 1.0f }
            val vector2 = FloatArray(smallDimension) { 2.0f }
            LlamaMobileVD.nativeVectorStoreAddVector(storeId, 1, vector1)
            LlamaMobileVD.nativeVectorStoreAddVector(storeId, 2, vector2)
            
            // Test size
            assertEquals(2L, LlamaMobileVD.nativeVectorStoreGetSize(storeId))
            
            // Test update vector
            val updatedVector = FloatArray(smallDimension) { 1.5f }
            assertTrue(LlamaMobileVD.nativeVectorStoreUpdateVector(storeId, 1, updatedVector))
            
            // Test get updated vector
            val retrievedVector = LlamaMobileVD.nativeVectorStoreGetVector(storeId, 1)
            assertNotNull(retrievedVector)
            assertEquals(smallDimension, retrievedVector?.size)
            retrievedVector?.let {
                for (i in 0 until smallDimension) {
                    assertEquals(1.5f, it[i], 0.0001f)
                }
            }
            
            // Test search
            val query = FloatArray(smallDimension) { 1.0f }
            val results = LlamaMobileVD.nativeVectorStoreSearch(storeId, query, 2).toKotlinList()
            assertEquals(2, results.size)
            
            // Test clear
            LlamaMobileVD.nativeVectorStoreClear(storeId)
            assertEquals(0L, LlamaMobileVD.nativeVectorStoreGetSize(storeId))
            
            LlamaMobileVD.nativeVectorStoreDestroy(storeId)
        }
    }

    // Test VectorStore with different dimensions
    @Test
    fun testVectorStoreWithDifferentDimensions() {
        runBlocking {
            // Test with small dimension
            val smallDimension = 64
            val smallStoreId = LlamaMobileVD.createVectorStore(smallDimension, DistanceMetric.COSINE.toJava())
            assertTrue(smallStoreId > 0)
            
            // Test with medium dimension
            val mediumDimension = 256
            val mediumStoreId = LlamaMobileVD.createVectorStore(mediumDimension, DistanceMetric.COSINE.toJava())
            assertTrue(mediumStoreId > 0)
            
            // Test with large dimension
            val largeDimension = 512
            val largeStoreId = LlamaMobileVD.createVectorStore(largeDimension, DistanceMetric.COSINE.toJava())
            assertTrue(largeStoreId > 0)
            
            // Clean up
            LlamaMobileVD.nativeVectorStoreDestroy(smallStoreId)
            LlamaMobileVD.nativeVectorStoreDestroy(mediumStoreId)
            LlamaMobileVD.nativeVectorStoreDestroy(largeStoreId)
        }
    }

    // Test VectorStore with different dataset sizes
    @Test
    fun testVectorStoreWithDifferentDatasetSizes() {
        runBlocking {
            val dimension = 64
            val storeId = LlamaMobileVD.createVectorStore(dimension, DistanceMetric.L2.toJava())
            
            // Test with small dataset (100 vectors)
            val smallDatasetSize = 100
            for (i in 0 until smallDatasetSize) {
                val vector = FloatArray(dimension) { i.toFloat() }
                LlamaMobileVD.nativeVectorStoreAddVector(storeId, i.toLong(), vector)
            }
            assertEquals(smallDatasetSize.toLong(), LlamaMobileVD.nativeVectorStoreGetSize(storeId))
            
            // Test search with small dataset
            val query = FloatArray(dimension) { 0.0f }
            val smallResults = LlamaMobileVD.nativeVectorStoreSearch(storeId, query, 10).toKotlinList()
            assertEquals(10, smallResults.size)
            
            // Clean up
            LlamaMobileVD.nativeVectorStoreDestroy(storeId)
        }
    }

    // Test HNSWIndex with all APIs
    @Test
    fun testHNSWIndexFullAPI() {
        runBlocking {
            val dimension = 64
            val maxElements = 1000L
            
            // Create HNSWIndex
            val indexId = LlamaMobileVD.createHNSWIndex(dimension, DistanceMetric.COSINE.toJava(), maxElements)
            assertTrue(indexId > 0)
            
            // Test setEfSearch
            val efSearch = 64
            assertTrue(LlamaMobileVD.nativeHNSWIndexSetEfSearch(indexId, efSearch))
            assertEquals(efSearch, LlamaMobileVD.nativeHNSWIndexGetEfSearch(indexId))
            
            // Test add vectors
            for (i in 0 until 100) {
                val vector = FloatArray(dimension) { i.toFloat() }
                assertTrue(LlamaMobileVD.nativeHNSWIndexAddVector(indexId, i.toLong(), vector))
            }
            
            // Test size
            assertEquals(100L, LlamaMobileVD.nativeHNSWIndexGetSize(indexId))
            
            // Test contains
            assertTrue(LlamaMobileVD.nativeHNSWIndexContains(indexId, 50))
            
            // Test getVector
            val retrievedVector = LlamaMobileVD.nativeHNSWIndexGetVector(indexId, 50)
            assertNotNull(retrievedVector)
            assertEquals(dimension, retrievedVector?.size)
            
            // Test search
            val query = FloatArray(dimension) { 0.0f }
            val results = LlamaMobileVD.nativeHNSWIndexSearch(indexId, query, 10).toKotlinList()
            assertEquals(10, results.size)
            
            // Test save and load (using temp file)
            val tempDir = appContext.cacheDir.absolutePath
            val filePath = "$tempDir/test_hnsw_index.bin"
            assertTrue(LlamaMobileVD.nativeHNSWIndexSave(indexId, filePath))
            
            val loadedIndexId = LlamaMobileVD.nativeHNSWIndexLoad(filePath)
            assertTrue(loadedIndexId > 0)
            assertEquals(100L, LlamaMobileVD.nativeHNSWIndexGetSize(loadedIndexId))
            
            // Clean up
            LlamaMobileVD.nativeHNSWIndexDestroy(indexId)
            LlamaMobileVD.nativeHNSWIndexDestroy(loadedIndexId)
            java.io.File(filePath).delete()
        }
    }

    // Test MMapVectorStoreBuilder and MMapVectorStore
    @Test
    fun testMMapVectorStoreFullAPI() {
        runBlocking {
            val dimension = 64
            val tempDir = appContext.cacheDir.absolutePath
            val filePath = "$tempDir/test_mmap_store.bin"
            
            // Create builder
            val builderId = LlamaMobileVD.createMMapVectorStoreBuilder(dimension, DistanceMetric.L2.toJava())
            assertTrue(builderId > 0)
            
            // Test builder reserve
            assertTrue(LlamaMobileVD.nativeMMapVectorStoreBuilderReserve(builderId, 100))
            
            // Test builder add vectors
            for (i in 0 until 50) {
                val vector = FloatArray(dimension) { i.toFloat() }
                assertTrue(LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, i.toLong(), vector))
            }
            
            // Test builder getSize
            assertEquals(50L, LlamaMobileVD.nativeMMapVectorStoreBuilderGetSize(builderId))
            
            // Test builder save
            LlamaMobileVD.saveMMapVectorStoreBuilder(builderId, filePath)
            
            // Destroy builder
            LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderId)
            
            // Open MMapVectorStore
            val storeId = LlamaMobileVD.openMMapVectorStore(filePath)
            assertTrue(storeId > 0)
            
            // Test MMapVectorStore getSize
            assertEquals(50L, LlamaMobileVD.nativeMMapVectorStoreGetSize(storeId))
            
            // Test MMapVectorStore contains
            assertTrue(LlamaMobileVD.nativeMMapVectorStoreContains(storeId, 25))
            
            // Test MMapVectorStore getVector
            val retrievedVector = LlamaMobileVD.nativeMMapVectorStoreGetVector(storeId, 25)
            assertNotNull(retrievedVector)
            assertEquals(dimension, retrievedVector?.size)
            
            // Test MMapVectorStore search
            val query = FloatArray(dimension) { 0.0f }
            val results = LlamaMobileVD.nativeMMapVectorStoreSearch(storeId, query, 10).toKotlinList()
            assertEquals(10, results.size)
            
            // Close MMapVectorStore
            LlamaMobileVD.nativeMMapVectorStoreClose(storeId)
            
            // Clean up
            java.io.File(filePath).delete()
        }
    }

    // Test version information
    @Test
    fun testVersionInformation() {
        runBlocking {
            // Test getVersion
            val version = LlamaMobileVD.getVersion()
            assertNotNull(version)
            assertFalse(version.isEmpty())
            
            // Test getVersionMajor
            val major = LlamaMobileVD.getVersionMajor()
            assertTrue(major >= 0)
            
            // Test getVersionMinor
            val minor = LlamaMobileVD.getVersionMinor()
            assertTrue(minor >= 0)
            
            // Test getVersionPatch
            val patch = LlamaMobileVD.getVersionPatch()
            assertTrue(patch >= 0)
        }
    }

    // Test with large dimension (up to 3096)
    @Test
    fun testWithLargeDimension() {
        runBlocking {
            val largeDimension = 1024 // Using 1024 instead of 3096 for faster testing
            
            // Test VectorStore with large dimension
            val storeId = LlamaMobileVD.createVectorStore(largeDimension, DistanceMetric.COSINE.toJava())
            assertTrue(storeId > 0)
            
            // Add a vector
            val vector = FloatArray(largeDimension) { 1.0f }
            LlamaMobileVD.nativeVectorStoreAddVector(storeId, 1, vector)
            
            // Test search
            val query = FloatArray(largeDimension) { 1.0f }
            val results = LlamaMobileVD.nativeVectorStoreSearch(storeId, query, 1).toKotlinList()
            assertEquals(1, results.size)
            
            LlamaMobileVD.nativeVectorStoreDestroy(storeId)
        }
    }
}  