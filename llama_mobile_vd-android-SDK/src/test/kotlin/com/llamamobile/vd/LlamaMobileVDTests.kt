package com.llamamobile.vd

import java.io.File
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

/**
 * Comprehensive test suite for the LlamaMobileVD Android Kotlin SDK
 * Tests cover VectorStore and HNSWIndex APIs with various dimensions and distance metrics
 */
class LlamaMobileVDTests {
    
    // Test vector dimensions (including common sizes like 384, 768, 1024)
    private val testDimensions = intArrayOf(384, 768, 1024)
    
    // Test distance metrics
    private val testMetrics = arrayOf(DistanceMetric.L2, DistanceMetric.COSINE, DistanceMetric.DOT)
    
    // Test objects that need to be closed after tests
    private val resourcesToClose = mutableListOf<AutoCloseable>()
    
    @Before
    fun setUp() {
        // Clear resources list before each test
        resourcesToClose.clear()
    }
    
    @After
    fun tearDown() {
        // Close all resources after each test
        resourcesToClose.forEach { it.close() }
    }
    
    private fun <T : AutoCloseable> T.track(): T {
        resourcesToClose.add(this)
        return this
    }
    
    @Test
    fun testVectorStoreCreation() {
        for (dimension in testDimensions) {
            for (metric in testMetrics) {
                val vectorStore = VectorStore(dimension, metric).track()
                assertEquals(0, vectorStore.getCount())
            }
        }
    }
    
    @Test
    fun testVectorStoreAddVector() {
        val dimension = 512
        val metric = DistanceMetric.L2
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Test adding a single vector
        val vector = FloatArray(dimension) { 0.5f }
        vectorStore.addVector(vector, 1)
        assertEquals(1, vectorStore.getCount())
        
        // Test adding multiple vectors
        for (i in 2..10) {
            val vec = FloatArray(dimension) { (i / 10.0f) }
            vectorStore.addVector(vec, i)
        }
        assertEquals(10, vectorStore.getCount())
    }
    
    @Test
    fun testVectorStoreSearch() {
        val dimension = 512
        val metric = DistanceMetric.COSINE
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Add known vectors for predictable search results
        val vector1 = FloatArray(dimension) { 1.0f }
        val vector2 = FloatArray(dimension) { 0.5f }
        val vector3 = FloatArray(dimension) { 0.25f }
        
        vectorStore.addVector(vector1, 1)
        vectorStore.addVector(vector2, 2)
        vectorStore.addVector(vector3, 3)
        
        // Search for the most similar vector
        val queryVector = FloatArray(dimension) { 0.6f }
        val results = vectorStore.search(queryVector, 2)
        
        // With cosine similarity, vector2 (0.5) should be closer to 0.6 than vector1 (1.0) or vector3 (0.25)
        assertEquals(2, results.size)
        assertEquals(2, results[0].id) // Most similar
        assertEquals(1, results[1].id) // Second most similar
    }
    
    @Test
    fun testVectorStoreClear() {
        val dimension = 256
        val metric = DistanceMetric.DOT
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Add some vectors
        for (i in 1..5) {
            val vector = FloatArray(dimension) { i.toFloat() }
            vectorStore.addVector(vector, i)
        }
        assertEquals(5, vectorStore.getCount())
        
        // Clear the store
        vectorStore.clear()
        assertEquals(0, vectorStore.getCount())
        
        // Verify we can still use the cleared store
        val vector = FloatArray(dimension) { 0.5f }
        vectorStore.addVector(vector, 1)
        assertEquals(1, vectorStore.getCount())
    }
    
    @Test
    fun testHNSWIndexCreation() {
        for (dimension in testDimensions) {
            for (metric in testMetrics) {
                val hnswIndex = HNSWIndex(dimension, metric, 16, 200).track()
                assertEquals(0, hnswIndex.getCount())
            }
        }
    }
    
    @Test
    fun testHNSWIndexCreationWithDefaultParameters() {
        val dimension = 512
        val metric = DistanceMetric.L2
        
        // Test with default m and efConstruction parameters
        val hnswIndex = HNSWIndex(dimension, metric).track()
        assertEquals(0, hnswIndex.getCount())
    }
    
    @Test
    fun testHNSWIndexAddVector() {
        val dimension = 768
        val metric = DistanceMetric.L2
        
        val hnswIndex = HNSWIndex(dimension, metric).track()
        
        // Test adding a single vector
        val vector = FloatArray(dimension) { 0.5f }
        hnswIndex.addVector(vector, 1)
        assertEquals(1, hnswIndex.getCount())
        
        // Test adding multiple vectors (simulating embedding vectors)
        for (i in 2..20) {
            val vec = FloatArray(dimension) { Math.random().toFloat() * 2.0f - 1.0f }
            hnswIndex.addVector(vec, i)
        }
        assertEquals(20, hnswIndex.getCount())
    }
    
    @Test
    fun testHNSWIndexSearch() {
        val dimension = 1024
        val metric = DistanceMetric.COSINE
        
        val hnswIndex = HNSWIndex(dimension, metric, 16, 100).track()
        
        // Add known vectors for predictable search results
        val baseVector = FloatArray(dimension) { 0.5f }
        val similarVector = FloatArray(dimension) { 0.6f }
        val dissimilarVector = FloatArray(dimension) { -0.5f }
        
        hnswIndex.addVector(baseVector, 1)
        hnswIndex.addVector(similarVector, 2)
        hnswIndex.addVector(dissimilarVector, 3)
        
        // Add some random vectors to make the search more realistic
        for (i in 4..10) {
            val vec = FloatArray(dimension) { Math.random().toFloat() * 2.0f - 1.0f }
            hnswIndex.addVector(vec, i)
        }
        
        // Search with default efSearch
        val queryVector = FloatArray(dimension) { 0.55f }
        val results1 = hnswIndex.search(queryVector, 3)
        assertEquals(3, results1.size)
        
        // Search with custom efSearch
        val results2 = hnswIndex.search(queryVector, 3, 100)
        assertEquals(3, results2.size)
        
        // Both searches should return vector 2 (similarVector) as one of the results
        assertTrue(results1.any { it.id == 2 })
        assertTrue(results2.any { it.id == 2 })
    }
    
    @Test
    fun testHNSWIndexClear() {
        val dimension = 384
        val metric = DistanceMetric.L2
        
        val hnswIndex = HNSWIndex(dimension, metric).track()
        
        // Add some vectors
        for (i in 1..10) {
            val vector = FloatArray(dimension) { (i / 10.0f) }
            hnswIndex.addVector(vector, i)
        }
        assertEquals(10, hnswIndex.getCount())
        
        // Clear the index
        hnswIndex.clear()
        assertEquals(0, hnswIndex.getCount())
        
        // Verify we can still use the cleared index
        val vector = FloatArray(dimension) { 0.7f }
        hnswIndex.addVector(vector, 1)
        assertEquals(1, hnswIndex.getCount())
    }
    
    @Test
    fun testDistanceMetrics() {
        val dimension = 128
        
        // Test L2 distance
        val vectorStoreL2 = VectorStore(dimension, DistanceMetric.L2).track()
        vectorStoreL2.addVector(FloatArray(dimension) { 1.0f }, 1)
        
        // Test Cosine distance
        val vectorStoreCosine = VectorStore(dimension, DistanceMetric.COSINE).track()
        vectorStoreCosine.addVector(FloatArray(dimension) { 1.0f }, 1)
        
        // Test Dot product distance
        val vectorStoreDot = VectorStore(dimension, DistanceMetric.DOT).track()
        vectorStoreDot.addVector(FloatArray(dimension) { 1.0f }, 1)
    }
    
    @Test
    fun testLargeDimensions() {
        // Test with 3072 dimension (common for large models like Claude)
        val dimension = 3072
        val metric = DistanceMetric.COSINE
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Add a large dimension vector
        val vector = FloatArray(dimension) { 0.5f }
        vectorStore.addVector(vector, 1)
        assertEquals(1, vectorStore.getCount())
        
        // Search with the same vector should return itself as the closest
        val results = vectorStore.search(vector, 1)
        assertEquals(1, results.size)
        assertEquals(1, results[0].id)
        assertTrue(results[0].distance < 0.001f)
    }
    
    @Test
    fun testEdgeCases() {
        val dimension = 16
        val metric = DistanceMetric.L2
        
        // Test adding vectors with different IDs
        val vectorStore = VectorStore(dimension, metric).track()
        val vector = FloatArray(dimension) { 0.5f }
        
        // Add vectors with positive IDs
        vectorStore.addVector(vector, 1)
        vectorStore.addVector(vector, 1000)
        
        // Add vectors with negative IDs
        vectorStore.addVector(vector, -1)
        vectorStore.addVector(vector, -1000)
        
        assertEquals(4, vectorStore.getCount())
        
        // Test searching with k larger than the number of vectors
        val results = vectorStore.search(vector, 5)
        assertEquals(4, results.size)
    }
    
    @Test
    fun testAutoCloseable() {
        val dimension = 32
        val metric = DistanceMetric.COSINE
        
        // Test that VectorStore implements AutoCloseable correctly
        var vectorStore: VectorStore? = null
        
        try {
            vectorStore = VectorStore(dimension, metric)
            vectorStore.addVector(FloatArray(dimension) { 0.5f }, 1)
            assertEquals(1, vectorStore.getCount())
        } finally {
            vectorStore?.close()
        }
        
        // Test that HNSWIndex implements AutoCloseable correctly
        var hnswIndex: HNSWIndex? = null
        
        try {
            hnswIndex = HNSWIndex(dimension, metric)
            hnswIndex.addVector(FloatArray(dimension) { 0.5f }, 1)
            assertEquals(1, hnswIndex.getCount())
        } finally {
            hnswIndex?.close()
        }
        
        // Test with Kotlin's use() function
        VectorStore(dimension, metric).use { vs ->
            vs.addVector(FloatArray(dimension) { 0.5f }, 1)
            assertEquals(1, vs.getCount())
        }
        
        HNSWIndex(dimension, metric).use { hi ->
            hi.addVector(FloatArray(dimension) { 0.5f }, 1)
            assertEquals(1, hi.getCount())
        }
    }
    
    @Test
    fun testErrorHandling() {
        val dimension = 16
        val metric = DistanceMetric.L2
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Test adding vector with wrong dimension
        val wrongDimensionVector = FloatArray(dimension + 1) { 0.5f }
        assertThrows(IllegalArgumentException::class.java) {
            vectorStore.addVector(wrongDimensionVector, 1)
        }
        
        // Test searching with wrong dimension vector
        assertThrows(IllegalArgumentException::class.java) {
            vectorStore.search(wrongDimensionVector, 1)
        }
        
        val hnswIndex = HNSWIndex(dimension, metric).track()
        
        // Test adding vector with wrong dimension to HNSW
        assertThrows(IllegalArgumentException::class.java) {
            hnswIndex.addVector(wrongDimensionVector, 1)
        }
        
        // Test searching with wrong dimension vector in HNSW
        assertThrows(IllegalArgumentException::class.java) {
            hnswIndex.search(wrongDimensionVector, 1)
        }
    }
    
    @Test
    fun testSearchResultsOrder() {
        val dimension = 64
        val metric = DistanceMetric.L2
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Create vectors at increasing distances from the origin
        val vector0 = FloatArray(dimension) { 0.0f }
        val vector1 = FloatArray(dimension) { 1.0f }
        val vector2 = FloatArray(dimension) { 2.0f }
        val vector3 = FloatArray(dimension) { 3.0f }
        val vector4 = FloatArray(dimension) { 4.0f }
        
        vectorStore.addVector(vector0, 0)
        vectorStore.addVector(vector1, 1)
        vectorStore.addVector(vector2, 2)
        vectorStore.addVector(vector3, 3)
        vectorStore.addVector(vector4, 4)
        
        // Search from the origin - results should be in order of increasing distance
        val results = vectorStore.search(vector0, 5)
        
        assertEquals(5, results.size)
        
        // Check that results are in order of increasing distance
        val distances = results.map { it.distance }
        for (i in 0 until distances.size - 1) {
            assertTrue(distances[i] <= distances[i + 1])
        }
        
        // Check that vector IDs match expected order
        assertEquals(0, results[0].id) // Closest (distance 0)
        assertEquals(1, results[1].id) // Next (distance sqrt(64*1) = 8)
        assertEquals(2, results[2].id) // Next (distance sqrt(64*4) = 16)
        assertEquals(3, results[3].id) // Next (distance sqrt(64*9) = 24)
        assertEquals(4, results[4].id) // Farthest (distance sqrt(64*16) = 32)
    }
    
    @Test
    fun testVectorStoreRemove() {
        val dimension = 128
        val metric = DistanceMetric.L2
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Add some vectors
        for (i in 1..5) {
            vectorStore.addVector(FloatArray(dimension) { i.toFloat() }, i)
        }
        assertEquals(5, vectorStore.getCount())
        
        // Remove a vector
        assertTrue(vectorStore.remove(3))
        assertEquals(4, vectorStore.getCount())
        
        // Remove a non-existent vector
        assertFalse(vectorStore.remove(10))
        assertEquals(4, vectorStore.getCount())
        
        // Remove remaining vectors
        for (i in 1..5) {
            vectorStore.remove(i)
        }
        assertEquals(0, vectorStore.getCount())
    }
    
    @Test
    fun testVectorStoreGet() {
        val dimension = 64
        val metric = DistanceMetric.COSINE
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Add a vector
        val originalVector = FloatArray(dimension) { 0.5f }
        vectorStore.addVector(originalVector, 1)
        
        // Get the vector
        val retrievedVector = vectorStore.get(1)
        assertNotNull(retrievedVector)
        assertEquals(dimension, retrievedVector?.size)
        
        // Check that the retrieved vector matches the original
        for (i in 0 until dimension) {
            assertEquals(originalVector[i], retrievedVector!![i], 0.001f)
        }
        
        // Get a non-existent vector
        assertNull(vectorStore.get(2))
    }
    
    @Test
    fun testVectorStoreUpdate() {
        val dimension = 32
        val metric = DistanceMetric.DOT
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Add a vector
        val originalVector = FloatArray(dimension) { 0.5f }
        vectorStore.addVector(originalVector, 1)
        
        // Update the vector
        val updatedVector = FloatArray(dimension) { 0.75f }
        assertTrue(vectorStore.update(1, updatedVector))
        
        // Get the updated vector and verify
        val retrievedVector = vectorStore.get(1)
        assertNotNull(retrievedVector)
        for (i in 0 until dimension) {
            assertEquals(updatedVector[i], retrievedVector!![i], 0.001f)
        }
        
        // Update a non-existent vector
        assertFalse(vectorStore.update(2, updatedVector))
    }
    
    @Test
    fun testVectorStoreDimensionAndMetric() {
        for (dimension in testDimensions) {
            for (metric in testMetrics) {
                val vectorStore = VectorStore(dimension, metric).track()
                assertEquals(dimension, vectorStore.dimension)
                assertEquals(metric, vectorStore.metric)
            }
        }
    }
    
    @Test
    fun testVectorStoreContains() {
        val dimension = 16
        val metric = DistanceMetric.L2
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Add some vectors
        vectorStore.addVector(FloatArray(dimension) { 0.5f }, 1)
        vectorStore.addVector(FloatArray(dimension) { 0.75f }, 2)
        
        // Check contains
        assertTrue(vectorStore.contains(1))
        assertTrue(vectorStore.contains(2))
        assertFalse(vectorStore.contains(3))
        assertFalse(vectorStore.contains(-1))
        
        // Remove a vector and check again
        vectorStore.remove(1)
        assertFalse(vectorStore.contains(1))
        assertTrue(vectorStore.contains(2))
    }
    
    @Test
    fun testVectorStoreReserve() {
        val dimension = 256
        val metric = DistanceMetric.COSINE
        
        val vectorStore = VectorStore(dimension, metric).track()
        
        // Reserve space
        vectorStore.reserve(100)
        
        // Add vectors up to and beyond the reserved capacity
        for (i in 1..150) {
            vectorStore.addVector(FloatArray(dimension) { Math.random().toFloat() }, i)
        }
        
        assertEquals(150, vectorStore.getCount())
    }
    
    @Test
    fun testHNSWIndexEfSearch() {
        val dimension = 512
        val metric = DistanceMetric.L2
        
        val hnswIndex = HNSWIndex(dimension, metric).track()
        
        // Check default efSearch
        assertEquals(50, hnswIndex.getEfSearch())
        
        // Set and check different efSearch values
        val efSearchValues = intArrayOf(10, 50, 100, 200, 500)
        for (efSearch in efSearchValues) {
            hnswIndex.setEfSearch(efSearch)
            assertEquals(efSearch, hnswIndex.getEfSearch())
        }
    }
    
    @Test
    fun testHNSWIndexDimensionAndCapacity() {
        val dimension = 768
        val metric = DistanceMetric.COSINE
        val m = 16
        val efConstruction = 200
        
        val hnswIndex = HNSWIndex(dimension, metric, m, efConstruction).track()
        
        // Check dimension
        assertEquals(dimension, hnswIndex.dimension)
        
        // Check capacity (should be greater than 0)
        assertTrue(hnswIndex.capacity > 0)
    }
    
    @Test
    fun testHNSWIndexContains() {
        val dimension = 128
        val metric = DistanceMetric.L2
        
        val hnswIndex = HNSWIndex(dimension, metric).track()
        
        // Add some vectors
        for (i in 1..5) {
            hnswIndex.addVector(FloatArray(dimension) { i.toFloat() }, i)
        }
        
        // Check contains
        for (i in 1..5) {
            assertTrue(hnswIndex.contains(i))
        }
        assertFalse(hnswIndex.contains(6))
        assertFalse(hnswIndex.contains(-1))
    }
    
    @Test
    fun testHNSWIndexGetVector() {
        val dimension = 384
        val metric = DistanceMetric.COSINE
        
        val hnswIndex = HNSWIndex(dimension, metric).track()
        
        // Add a vector
        val originalVector = FloatArray(dimension) { 0.5f }
        hnswIndex.addVector(originalVector, 1)
        
        // Get the vector
        val retrievedVector = hnswIndex.getVector(1)
        assertNotNull(retrievedVector)
        assertEquals(dimension, retrievedVector?.size)
        
        // Check that the retrieved vector matches the original
        for (i in 0 until dimension) {
            assertEquals(originalVector[i], retrievedVector!![i], 0.001f)
        }
        
        // Get a non-existent vector
        assertNull(hnswIndex.getVector(2))
    }
    
    @Test
    fun testHNSWIndexSaveAndLoad() {
        val dimension = 128
        val metric = DistanceMetric.L2
        val m = 16
        val efConstruction = 100
        
        // Create and populate an index
        val hnswIndex = HNSWIndex(dimension, metric, m, efConstruction).track()
        
        // Add some vectors
        val testVectors = mutableListOf<FloatArray>()
        for (i in 1..10) {
            val vector = FloatArray(dimension) { Math.random().toFloat() }
            testVectors.add(vector)
            hnswIndex.addVector(vector, i)
        }
        
        // Set a custom efSearch
        hnswIndex.setEfSearch(75)
        
        // Create a temporary file path for testing
        val tempFilePath = File.createTempFile("hnsw_test", ".index").absolutePath
        
        try {
            // Save the index
            assertTrue(hnswIndex.save(tempFilePath))
            
            // Close the original index
            hnswIndex.close()
            resourcesToClose.remove(hnswIndex)
            
            // Load the index
            val loadedIndex = HNSWIndex.load(tempFilePath).track()
            
            // Verify the loaded index
            assertEquals(10, loadedIndex.getCount())
            assertEquals(dimension, loadedIndex.dimension)
            assertEquals(75, loadedIndex.getEfSearch())
            
            // Check that all vectors are present and correct
            for ((index, originalVector) in testVectors.withIndex()) {
                val vectorId = index + 1
                val retrievedVector = loadedIndex.getVector(vectorId)
                assertNotNull(retrievedVector)
                for (i in 0 until dimension) {
                    assertEquals(originalVector[i], retrievedVector!![i], 0.001f)
                }
            }
            
            // Test search on the loaded index
            val queryVector = testVectors[0]
            val results = loadedIndex.search(queryVector, 3, 75)
            assertEquals(3, results.size)
            assertEquals(1, results[0].id) // The first vector should be the closest
        } finally {
            // Clean up the temporary file
            File(tempFilePath).delete()
        }
    }
    
    @Test
    fun testVersionInformation() {
        // Test version string
        val versionString = getLlamaMobileVDVersion()
        assertNotNull(versionString)
        assertTrue(versionString.isNotEmpty())
        
        // Test version components
        val versionMajor = getLlamaMobileVDVersionMajor()
        val versionMinor = getLlamaMobileVDVersionMinor()
        val versionPatch = getLlamaMobileVDVersionPatch()
        
        assertTrue(versionMajor >= 0)
        assertTrue(versionMinor >= 0)
        assertTrue(versionPatch >= 0)
        
        // Verify version string format (should be major.minor.patch)
        val versionParts = versionString.split(".")
        assertEquals(3, versionParts.size)
        assertEquals(versionMajor, versionParts[0].toIntOrNull())
        assertEquals(versionMinor, versionParts[1].toIntOrNull())
        assertEquals(versionPatch, versionParts[2].toIntOrNull())
    }
    
    @Test
    fun testMMapVectorStoreBuilderCreation() {
        for (dimension in testDimensions) {
            for (metric in testMetrics) {
                val builder = MMapVectorStoreBuilder(dimension, metric).track()
                assertEquals(0, builder.getCount())
                assertEquals(dimension, builder.dimension)
            }
        }
    }
    
    @Test
    fun testMMapVectorStoreBuilderOperations() {
        val dimension = 512
        val metric = DistanceMetric.L2
        
        val builder = MMapVectorStoreBuilder(dimension, metric).track()
        
        // Test adding vectors
        val vector1 = FloatArray(dimension) { 1.0f }
        val vector2 = FloatArray(dimension) { 0.5f }
        val vector3 = FloatArray(dimension) { 0.25f }
        
        builder.addVector(vector1, 1)
        assertEquals(1, builder.getCount())
        
        builder.addVector(vector2, 2)
        assertEquals(2, builder.getCount())
        
        builder.addVector(vector3, 3)
        assertEquals(3, builder.getCount())
        
        // Test reserve
        builder.reserve(100)
        assertEquals(3, builder.getCount())
        
        // Test adding more vectors after reserve
        for (i in 4..10) {
            val vector = FloatArray(dimension) { (i / 10.0f) }
            builder.addVector(vector, i)
        }
        assertEquals(10, builder.getCount())
    }
    
    @Test
    fun testMMapVectorStoreSaveLoad() {
        val dimension = 256
        val metric = DistanceMetric.COSINE
        
        // Create a temporary file path for testing
        val tempFilePath = File.createTempFile("mmap_test", ".store").absolutePath
        
        try {
            // Create and populate the builder
            val builder = MMapVectorStoreBuilder(dimension, metric).track()
            
            // Add some vectors
            val vector1 = FloatArray(dimension) { 1.0f }
            val vector2 = FloatArray(dimension) { 0.5f }
            val vector3 = FloatArray(dimension) { 0.25f }
            
            builder.addVector(vector1, 1)
            builder.addVector(vector2, 2)
            builder.addVector(vector3, 3)
            
            // Save to file
            assertTrue(builder.save(tempFilePath))
            
            // Close the builder
            builder.close()
            resourcesToClose.remove(builder)
            
            // Open the MMapVectorStore
            val vectorStore = MMapVectorStore.open(tempFilePath).track()
            
            // Verify store properties
            assertEquals(dimension, vectorStore.dimension)
            assertEquals(metric, vectorStore.metric)
            assertEquals(3, vectorStore.getCount())
            
            // Verify vectors can be retrieved
            val retrieved1 = vectorStore.get(1)
            assertNotNull(retrieved1)
            assertEquals(dimension, retrieved1?.size)
            for (i in 0 until dimension) {
                assertEquals(vector1[i], retrieved1!![i], 0.001f)
            }
            
            val retrieved2 = vectorStore.get(2)
            assertNotNull(retrieved2)
            for (i in 0 until dimension) {
                assertEquals(vector2[i], retrieved2!![i], 0.001f)
            }
            
            val retrieved3 = vectorStore.get(3)
            assertNotNull(retrieved3)
            for (i in 0 until dimension) {
                assertEquals(vector3[i], retrieved3!![i], 0.001f)
            }
            
            // Verify contains functionality
            assertTrue(vectorStore.contains(1))
            assertTrue(vectorStore.contains(2))
            assertTrue(vectorStore.contains(3))
            assertFalse(vectorStore.contains(4))
        } finally {
            // Clean up the temporary file
            File(tempFilePath).delete()
        }
    }
    
    @Test
    fun testMMapVectorStoreSearch() {
        val dimension = 512
        val metric = DistanceMetric.cosine
        
        // Create a temporary file path for testing
        val tempFilePath = File.createTempFile("mmap_search_test", ".store").absolutePath
        
        try {
            // Create and populate the store
            val builder = MMapVectorStoreBuilder(dimension, metric).track()
            
            // Add known vectors for predictable search results
            val vector1 = FloatArray(dimension) { 1.0f }  // ID 1
            val vector2 = FloatArray(dimension) { 0.9f }  // ID 2 - very similar to vector1
            val vector3 = FloatArray(dimension) { 0.5f }  // ID 3 - somewhat similar
            val vector4 = FloatArray(dimension) { 0.1f }  // ID 4 - less similar
            val vector5 = FloatArray(dimension) { -1.0f } // ID 5 - very dissimilar
            
            builder.addVector(vector1, 1)
            builder.addVector(vector2, 2)
            builder.addVector(vector3, 3)
            builder.addVector(vector4, 4)
            builder.addVector(vector5, 5)
            
            // Save the store
            assertTrue(builder.save(tempFilePath))
            
            // Close the builder
            builder.close()
            resourcesToClose.remove(builder)
            
            // Open and search
            val vectorStore = MMapVectorStore.open(tempFilePath).track()
            
            // Test search for vector1 - should find itself first
            val results1 = vectorStore.search(vector1, 3)
            assertEquals(3, results1.size)
            assertEquals(1, results1[0].id)  // Exact match
            assertEquals(2, results1[1].id)  // Very similar
            assertEquals(3, results1[2].id)  // Somewhat similar
            
            // Test search for vector3 - should find itself first, then similar vectors
            val results2 = vectorStore.search(vector3, 2)
            assertEquals(2, results2.size)
            assertEquals(3, results2[0].id)  // Exact match
            assertTrue(listOf(2, 4).contains(results2[1].id))  // Should be either 2 or 4 depending on metric
            
            // Test search with k larger than the number of vectors
            val results3 = vectorStore.search(vector1, 10)
            assertEquals(5, results3.size)  // Only 5 vectors available
        } finally {
            // Clean up the temporary file
            File(tempFilePath).delete()
        }
    }
    
    @Test
    fun testMMapVectorStoreErrorHandling() {
        val dimension = 16
        val metric = DistanceMetric.L2
        
        // Test builder creation with invalid parameters
        assertThrows(IllegalStateException::class.java) {
            // Invalid dimension (negative)
            MMapVectorStoreBuilder(-1, metric)
        }
        
        // Test adding vector with wrong dimension
        val builder = MMapVectorStoreBuilder(dimension, metric).track()
        val wrongDimensionVector = FloatArray(dimension + 1) { 0.5f }
        assertThrows(IllegalArgumentException::class.java) {
            builder.addVector(wrongDimensionVector, 1)
        }
        
        // Test opening non-existent file
        val nonExistentPath = "non_existent_file.store"
        assertThrows(IllegalStateException::class.java) {
            MMapVectorStore.open(nonExistentPath)
        }
    }
}
