package com.llamamobile.vd;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;

/**
 * Comprehensive test suite for the LlamaMobileVD Android Java SDK
 * Tests cover VectorStore and HNSWIndex APIs with various dimensions and distance metrics
 */
public class LlamaMobileVDTests {
    
    // Test vector dimensions (including common sizes like 384, 768, 1024)
    private static final int[] TEST_DIMENSIONS = {384, 768, 1024};
    
    // Test distance metrics
    private static final DistanceMetric[] TEST_METRICS = {
        DistanceMetric.L2, 
        DistanceMetric.COSINE, 
        DistanceMetric.DOT
    };
    
    // Test objects that need to be closed after tests
    private final List<AutoCloseable> resourcesToClose = new ArrayList<>();
    
    @Before
    public void setUp() {
        // Clear resources list before each test
        resourcesToClose.clear();
    }
    
    @After
    public void tearDown() {
        // Close all resources after each test
        for (AutoCloseable resource : resourcesToClose) {
            try {
                resource.close();
            } catch (Exception e) {
                // Ignore exceptions during cleanup
            }
        }
    }
    
    private <T extends AutoCloseable> T track(T resource) {
        resourcesToClose.add(resource);
        return resource;
    }
    
    @Test
    public void testVectorStoreCreation() {
        for (int dimension : TEST_DIMENSIONS) {
            for (DistanceMetric metric : TEST_METRICS) {
                VectorStore vectorStore = track(new VectorStore(dimension, metric));
                Assert.assertEquals(0, vectorStore.getCount());
            }
        }
    }
    
    @Test
    public void testVectorStoreAddVector() {
        int dimension = 512;
        DistanceMetric metric = DistanceMetric.L2;
        
        VectorStore vectorStore = track(new VectorStore(dimension, metric));
        
        // Test adding a single vector
        float[] vector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector[i] = 0.5f;
        }
        vectorStore.addVector(vector, 1);
        Assert.assertEquals(1, vectorStore.getCount());
        
        // Test adding multiple vectors
        for (int i = 2; i <= 10; i++) {
            float[] vec = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vec[j] = (float) i / 10.0f;
            }
            vectorStore.addVector(vec, i);
        }
        Assert.assertEquals(10, vectorStore.getCount());
    }
    
    @Test
    public void testVectorStoreSearch() {
        int dimension = 512;
        DistanceMetric metric = DistanceMetric.COSINE;
        
        VectorStore vectorStore = track(new VectorStore(dimension, metric));
        
        // Add known vectors for predictable search results
        float[] vector1 = new float[dimension];
        float[] vector2 = new float[dimension];
        float[] vector3 = new float[dimension];
        
        for (int i = 0; i < dimension; i++) {
            vector1[i] = 1.0f;
            vector2[i] = 0.5f;
            vector3[i] = 0.25f;
        }
        
        vectorStore.addVector(vector1, 1);
        vectorStore.addVector(vector2, 2);
        vectorStore.addVector(vector3, 3);
        
        // Search for the most similar vector
        float[] queryVector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            queryVector[i] = 0.6f;
        }
        
        SearchResult[] results = vectorStore.search(queryVector, 2);
        
        // With cosine similarity, vector2 (0.5) should be closer to 0.6 than vector1 (1.0) or vector3 (0.25)
        Assert.assertEquals(2, results.length);
        Assert.assertEquals(2, results[0].getId()); // Most similar
        Assert.assertEquals(1, results[1].getId()); // Second most similar
    }
    
    @Test
    public void testVectorStoreClear() {
        int dimension = 256;
        DistanceMetric metric = DistanceMetric.DOT;
        
        VectorStore vectorStore = track(new VectorStore(dimension, metric));
        
        // Add some vectors
        for (int i = 1; i <= 5; i++) {
            float[] vector = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vector[j] = (float) i;
            }
            vectorStore.addVector(vector, i);
        }
        Assert.assertEquals(5, vectorStore.getCount());
        
        // Clear the store
        vectorStore.clear();
        Assert.assertEquals(0, vectorStore.getCount());
        
        // Verify we can still use the cleared store
        float[] vector = new float[dimension];
        for (int j = 0; j < dimension; j++) {
            vector[j] = 0.5f;
        }
        vectorStore.addVector(vector, 1);
        Assert.assertEquals(1, vectorStore.getCount());
    }
    
    @Test
    public void testHNSWIndexCreation() {
        for (int dimension : TEST_DIMENSIONS) {
            for (DistanceMetric metric : TEST_METRICS) {
                // Test with default parameters
                HNSWIndex index = track(new HNSWIndex(dimension, metric));
                Assert.assertEquals(0, index.getCount());
                
                // Test with custom parameters
                HNSWIndex customIndex = track(new HNSWIndex(dimension, metric, 16, 200));
                Assert.assertEquals(0, customIndex.getCount());
            }
        }
    }
    
    @Test
    public void testHNSWIndexAddVector() {
        int dimension = 768;
        DistanceMetric metric = DistanceMetric.L2;
        
        HNSWIndex hnswIndex = track(new HNSWIndex(dimension, metric));
        
        // Test adding a single vector
        float[] vector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector[i] = 0.5f;
        }
        hnswIndex.addVector(vector, 1);
        Assert.assertEquals(1, hnswIndex.getCount());
        
        // Test adding multiple vectors (simulating embedding vectors)
        for (int i = 2; i <= 20; i++) {
            float[] vec = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vec[j] = (float) (Math.random() * 2.0 - 1.0);
            }
            hnswIndex.addVector(vec, i);
        }
        Assert.assertEquals(20, hnswIndex.getCount());
    }
    
    @Test
    public void testHNSWIndexSearch() {
        int dimension = 1024;
        DistanceMetric metric = DistanceMetric.COSINE;
        
        HNSWIndex hnswIndex = track(new HNSWIndex(dimension, metric, 16, 100));
        
        // Add known vectors for predictable search results
        float[] baseVector = new float[dimension];
        float[] similarVector = new float[dimension];
        float[] dissimilarVector = new float[dimension];
        
        for (int i = 0; i < dimension; i++) {
            baseVector[i] = 0.5f;
            similarVector[i] = 0.6f;
            dissimilarVector[i] = -0.5f;
        }
        
        hnswIndex.addVector(baseVector, 1);
        hnswIndex.addVector(similarVector, 2);
        hnswIndex.addVector(dissimilarVector, 3);
        
        // Add some random vectors to make the search more realistic
        for (int i = 4; i <= 10; i++) {
            float[] vec = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vec[j] = (float) (Math.random() * 2.0 - 1.0);
            }
            hnswIndex.addVector(vec, i);
        }
        
        // Search with default efSearch
        float[] queryVector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            queryVector[i] = 0.55f;
        }
        
        SearchResult[] results1 = hnswIndex.search(queryVector, 3);
        Assert.assertEquals(3, results1.length);
        
        // Search with custom efSearch
        SearchResult[] results2 = hnswIndex.search(queryVector, 3, 100);
        Assert.assertEquals(3, results2.length);
        
        // Both searches should return vector 2 (similarVector) as one of the results
        Assert.assertTrue(containsId(results1, 2));
        Assert.assertTrue(containsId(results2, 2));
    }
    
    @Test
    public void testHNSWIndexClear() {
        int dimension = 384;
        DistanceMetric metric = DistanceMetric.L2;
        
        HNSWIndex hnswIndex = track(new HNSWIndex(dimension, metric));
        
        // Add some vectors
        for (int i = 1; i <= 10; i++) {
            float[] vector = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vector[j] = (float) i / 10.0f;
            }
            hnswIndex.addVector(vector, i);
        }
        Assert.assertEquals(10, hnswIndex.getCount());
        
        // Clear the index
        hnswIndex.clear();
        Assert.assertEquals(0, hnswIndex.getCount());
        
        // Verify we can still use the cleared index
        float[] vector = new float[dimension];
        for (int j = 0; j < dimension; j++) {
            vector[j] = 0.7f;
        }
        hnswIndex.addVector(vector, 1);
        Assert.assertEquals(1, hnswIndex.getCount());
    }
    
    @Test
    public void testDistanceMetrics() {
        int dimension = 128;
        
        // Test L2 distance
        VectorStore vectorStoreL2 = track(new VectorStore(dimension, DistanceMetric.L2));
        float[] vector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector[i] = 1.0f;
        }
        vectorStoreL2.addVector(vector, 1);
        
        // Test Cosine distance
        VectorStore vectorStoreCosine = track(new VectorStore(dimension, DistanceMetric.COSINE));
        vectorStoreCosine.addVector(vector, 1);
        
        // Test Dot product distance
        VectorStore vectorStoreDot = track(new VectorStore(dimension, DistanceMetric.DOT));
        vectorStoreDot.addVector(vector, 1);
    }
    
    @Test
    public void testLargeDimensions() {
        // Test with 3072 dimension (common for large models like Claude)
        int dimension = 3072;
        DistanceMetric metric = DistanceMetric.COSINE;
        
        VectorStore vectorStore = track(new VectorStore(dimension, metric));
        
        // Add a large dimension vector
        float[] vector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector[i] = 0.5f;
        }
        vectorStore.addVector(vector, 1);
        Assert.assertEquals(1, vectorStore.getCount());
        
        // Search with the same vector should return itself as the closest
        SearchResult[] results = vectorStore.search(vector, 1);
        Assert.assertEquals(1, results.length);
        Assert.assertEquals(1, results[0].getId());
        Assert.assertTrue(results[0].getDistance() < 0.001f);
    }
    
    @Test
    public void testEdgeCases() {
        int dimension = 16;
        DistanceMetric metric = DistanceMetric.L2;
        
        // Test adding vectors with different IDs
        VectorStore vectorStore = track(new VectorStore(dimension, metric));
        float[] vector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector[i] = 0.5f;
        }
        
        // Add vectors with positive IDs
        vectorStore.addVector(vector, 1);
        vectorStore.addVector(vector, 1000);
        
        // Add vectors with negative IDs
        vectorStore.addVector(vector, -1);
        vectorStore.addVector(vector, -1000);
        
        Assert.assertEquals(4, vectorStore.getCount());
        
        // Test searching with k larger than the number of vectors
        SearchResult[] results = vectorStore.search(vector, 5);
        Assert.assertEquals(4, results.length);
    }
    
    @Test
    public void testTryWithResources() {
        int dimension = 32;
        DistanceMetric metric = DistanceMetric.COSINE;
        
        // Test that VectorStore works with try-with-resources
        try (VectorStore vectorStore = new VectorStore(dimension, metric)) {
            float[] vector = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector[i] = 0.5f;
            }
            vectorStore.addVector(vector, 1);
            Assert.assertEquals(1, vectorStore.getCount());
        }
        
        // Test that HNSWIndex works with try-with-resources
        try (HNSWIndex hnswIndex = new HNSWIndex(dimension, metric)) {
            float[] vector = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector[i] = 0.5f;
            }
            hnswIndex.addVector(vector, 1);
            Assert.assertEquals(1, hnswIndex.getCount());
        }
    }
    
    @Test
    public void testErrorHandling() {
        int dimension = 16;
        DistanceMetric metric = DistanceMetric.L2;
        
        try (VectorStore vectorStore = new VectorStore(dimension, metric)) {
            // Test adding vector with wrong dimension
            float[] wrongDimensionVector = new float[dimension + 1];
            for (int i = 0; i < wrongDimensionVector.length; i++) {
                wrongDimensionVector[i] = 0.5f;
            }
            
            Assert.assertThrows(IllegalArgumentException.class, () -> {
                vectorStore.addVector(wrongDimensionVector, 1);
            });
            
            // Test searching with wrong dimension vector
            Assert.assertThrows(IllegalArgumentException.class, () -> {
                vectorStore.search(wrongDimensionVector, 1);
            });
        }
        
        try (HNSWIndex hnswIndex = new HNSWIndex(dimension, metric)) {
            // Test adding vector with wrong dimension to HNSW
            float[] wrongDimensionVector = new float[dimension + 1];
            for (int i = 0; i < wrongDimensionVector.length; i++) {
                wrongDimensionVector[i] = 0.5f;
            }
            
            Assert.assertThrows(IllegalArgumentException.class, () -> {
                hnswIndex.addVector(wrongDimensionVector, 1);
            });
            
            // Test searching with wrong dimension vector in HNSW
            Assert.assertThrows(IllegalArgumentException.class, () -> {
                hnswIndex.search(wrongDimensionVector, 1);
            });
        }
    }
    
    @Test
    public void testSearchResultsOrder() {
        int dimension = 64;
        DistanceMetric metric = DistanceMetric.L2;
        
        try (VectorStore vectorStore = new VectorStore(dimension, metric)) {
            // Create vectors at increasing distances from the origin
            float[] vector0 = new float[dimension];
            float[] vector1 = new float[dimension];
            float[] vector2 = new float[dimension];
            float[] vector3 = new float[dimension];
            float[] vector4 = new float[dimension];
            
            for (int i = 0; i < dimension; i++) {
                vector0[i] = 0.0f;
                vector1[i] = 1.0f;
                vector2[i] = 2.0f;
                vector3[i] = 3.0f;
                vector4[i] = 4.0f;
            }
            
            vectorStore.addVector(vector0, 0);
            vectorStore.addVector(vector1, 1);
            vectorStore.addVector(vector2, 2);
            vectorStore.addVector(vector3, 3);
            vectorStore.addVector(vector4, 4);
            
            // Search from the origin - results should be in order of increasing distance
            SearchResult[] results = vectorStore.search(vector0, 5);
            
            Assert.assertEquals(5, results.length);
            
            // Check that results are in order of increasing distance
            for (int i = 0; i < results.length - 1; i++) {
                Assert.assertTrue(results[i].getDistance() <= results[i + 1].getDistance());
            }
            
            // Check that vector IDs match expected order
            Assert.assertEquals(0, results[0].getId()); // Closest (distance 0)
            Assert.assertEquals(1, results[1].getId()); // Next (distance sqrt(64*1) = 8)
            Assert.assertEquals(2, results[2].getId()); // Next (distance sqrt(64*4) = 16)
            Assert.assertEquals(3, results[3].getId()); // Next (distance sqrt(64*9) = 24)
            Assert.assertEquals(4, results[4].getId()); // Farthest (distance sqrt(64*16) = 32)
        }
    }
    
    @Test
    public void testVectorStoreRemove() {
        int dimension = 128;
        DistanceMetric metric = DistanceMetric.L2;
        
        try (VectorStore vectorStore = new VectorStore(dimension, metric)) {
            // Add some vectors
            for (int i = 1; i <= 5; i++) {
                float[] vector = new float[dimension];
                for (int j = 0; j < dimension; j++) {
                    vector[j] = (float) i;
                }
                vectorStore.addVector(vector, i);
            }
            Assert.assertEquals(5, vectorStore.getCount());
            
            // Remove a vector
            Assert.assertTrue(vectorStore.remove(3));
            Assert.assertEquals(4, vectorStore.getCount());
            
            // Remove a non-existent vector
            Assert.assertFalse(vectorStore.remove(10));
            Assert.assertEquals(4, vectorStore.getCount());
            
            // Remove remaining vectors
            for (int i = 1; i <= 5; i++) {
                vectorStore.remove(i);
            }
            Assert.assertEquals(0, vectorStore.getCount());
        }
    }
    
    @Test
    public void testVectorStoreGet() {
        int dimension = 64;
        DistanceMetric metric = DistanceMetric.COSINE;
        
        try (VectorStore vectorStore = new VectorStore(dimension, metric)) {
            // Add a vector
            float[] originalVector = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                originalVector[i] = 0.5f;
            }
            vectorStore.addVector(originalVector, 1);
            
            // Get the vector
            float[] retrievedVector = vectorStore.get(1);
            Assert.assertNotNull(retrievedVector);
            Assert.assertEquals(dimension, retrievedVector.length);
            
            // Check that the retrieved vector matches the original
            for (int i = 0; i < dimension; i++) {
                Assert.assertEquals(originalVector[i], retrievedVector[i], 0.001f);
            }
            
            // Get a non-existent vector
            Assert.assertNull(vectorStore.get(2));
        }
    }
    
    @Test
    public void testVectorStoreUpdate() {
        int dimension = 32;
        DistanceMetric metric = DistanceMetric.DOT;
        
        try (VectorStore vectorStore = new VectorStore(dimension, metric)) {
            // Add a vector
            float[] originalVector = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                originalVector[i] = 0.5f;
            }
            vectorStore.addVector(originalVector, 1);
            
            // Update the vector
            float[] updatedVector = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                updatedVector[i] = 0.75f;
            }
            Assert.assertTrue(vectorStore.update(1, updatedVector));
            
            // Get the updated vector and verify
            float[] retrievedVector = vectorStore.get(1);
            Assert.assertNotNull(retrievedVector);
            for (int i = 0; i < dimension; i++) {
                Assert.assertEquals(updatedVector[i], retrievedVector[i], 0.001f);
            }
            
            // Update a non-existent vector
            Assert.assertFalse(vectorStore.update(2, updatedVector));
        }
    }
    
    @Test
    public void testVectorStoreDimensionAndMetric() {
        for (int dimension : TEST_DIMENSIONS) {
            for (DistanceMetric metric : TEST_METRICS) {
                try (VectorStore vectorStore = new VectorStore(dimension, metric)) {
                    Assert.assertEquals(dimension, vectorStore.getDimension());
                    Assert.assertEquals(metric, vectorStore.getMetric());
                }
            }
        }
    }
    
    @Test
    public void testVectorStoreContains() {
        int dimension = 16;
        DistanceMetric metric = DistanceMetric.L2;
        
        try (VectorStore vectorStore = new VectorStore(dimension, metric)) {
            // Add some vectors
            float[] vector1 = new float[dimension];
            float[] vector2 = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector1[i] = 0.5f;
                vector2[i] = 0.75f;
            }
            vectorStore.addVector(vector1, 1);
            vectorStore.addVector(vector2, 2);
            
            // Check contains
            Assert.assertTrue(vectorStore.contains(1));
            Assert.assertTrue(vectorStore.contains(2));
            Assert.assertFalse(vectorStore.contains(3));
            Assert.assertFalse(vectorStore.contains(-1));
            
            // Remove a vector and check again
            vectorStore.remove(1);
            Assert.assertFalse(vectorStore.contains(1));
            Assert.assertTrue(vectorStore.contains(2));
        }
    }
    
    @Test
    public void testVectorStoreReserve() {
        int dimension = 256;
        DistanceMetric metric = DistanceMetric.COSINE;
        
        try (VectorStore vectorStore = new VectorStore(dimension, metric)) {
            // Reserve space
            vectorStore.reserve(100);
            
            // Add vectors up to and beyond the reserved capacity
            for (int i = 1; i <= 150; i++) {
                float[] vector = new float[dimension];
                for (int j = 0; j < dimension; j++) {
                    vector[j] = (float) Math.random();
                }
                vectorStore.addVector(vector, i);
            }
            
            Assert.assertEquals(150, vectorStore.getCount());
        }
    }
    
    @Test
    public void testHNSWIndexEfSearch() {
        int dimension = 512;
        DistanceMetric metric = DistanceMetric.L2;
        
        try (HNSWIndex hnswIndex = new HNSWIndex(dimension, metric)) {
            // Check default efSearch
            Assert.assertEquals(50, hnswIndex.getEfSearch());
            
            // Set and check different efSearch values
            int[] efSearchValues = {10, 50, 100, 200, 500};
            for (int efSearch : efSearchValues) {
                hnswIndex.setEfSearch(efSearch);
                Assert.assertEquals(efSearch, hnswIndex.getEfSearch());
            }
        }
    }
    
    @Test
    public void testHNSWIndexDimensionAndCapacity() {
        int dimension = 768;
        DistanceMetric metric = DistanceMetric.COSINE;
        int m = 16;
        int efConstruction = 200;
        
        try (HNSWIndex hnswIndex = new HNSWIndex(dimension, metric, m, efConstruction)) {
            // Check dimension
            Assert.assertEquals(dimension, hnswIndex.getDimension());
            
            // Check capacity (should be greater than 0)
            Assert.assertTrue(hnswIndex.getCapacity() > 0);
        }
    }
    
    @Test
    public void testHNSWIndexContains() {
        int dimension = 128;
        DistanceMetric metric = DistanceMetric.L2;
        
        try (HNSWIndex hnswIndex = new HNSWIndex(dimension, metric)) {
            // Add some vectors
            for (int i = 1; i <= 5; i++) {
                float[] vector = new float[dimension];
                for (int j = 0; j < dimension; j++) {
                    vector[j] = (float) i;
                }
                hnswIndex.addVector(vector, i);
            }
            
            // Check contains
            for (int i = 1; i <= 5; i++) {
                Assert.assertTrue(hnswIndex.contains(i));
            }
            Assert.assertFalse(hnswIndex.contains(6));
            Assert.assertFalse(hnswIndex.contains(-1));
        }
    }
    
    @Test
    public void testHNSWIndexGetVector() {
        int dimension = 384;
        DistanceMetric metric = DistanceMetric.COSINE;
        
        try (HNSWIndex hnswIndex = new HNSWIndex(dimension, metric)) {
            // Add a vector
            float[] originalVector = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                originalVector[i] = 0.5f;
            }
            hnswIndex.addVector(originalVector, 1);
            
            // Get the vector
            float[] retrievedVector = hnswIndex.getVector(1);
            Assert.assertNotNull(retrievedVector);
            Assert.assertEquals(dimension, retrievedVector.length);
            
            // Check that the retrieved vector matches the original
            for (int i = 0; i < dimension; i++) {
                Assert.assertEquals(originalVector[i], retrievedVector[i], 0.001f);
            }
            
            // Get a non-existent vector
            Assert.assertNull(hnswIndex.getVector(2));
        }
    }
    
    @Test
    public void testHNSWIndexSaveAndLoad() throws Exception {
        int dimension = 128;
        DistanceMetric metric = DistanceMetric.L2;
        int m = 16;
        int efConstruction = 100;
        
        // Create and populate an index
        HNSWIndex hnswIndex = new HNSWIndex(dimension, metric, m, efConstruction);
        
        // Add some vectors
        List<float[]> testVectors = new ArrayList<>();
        for (int i = 1; i <= 10; i++) {
            float[] vector = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vector[j] = (float) Math.random();
            }
            testVectors.add(vector);
            hnswIndex.addVector(vector, i);
        }
        
        // Set a custom efSearch
        hnswIndex.setEfSearch(75);
        
        // Create a temporary file path for testing
        java.io.File tempFile = java.io.File.createTempFile("hnsw_test", ".index");
        String tempFilePath = tempFile.getAbsolutePath();
        
        try {
            // Save the index
            Assert.assertTrue(hnswIndex.save(tempFilePath));
            
            // Close the original index
            hnswIndex.close();
            
            // Load the index
            HNSWIndex loadedIndex = HNSWIndex.load(tempFilePath);
            Assert.assertNotNull(loadedIndex);
            
            try {
                // Verify the loaded index
                Assert.assertEquals(10, loadedIndex.getCount());
                Assert.assertEquals(dimension, loadedIndex.getDimension());
                Assert.assertEquals(75, loadedIndex.getEfSearch());
                
                // Check that all vectors are present and correct
                for (int i = 0; i < testVectors.size(); i++) {
                    int vectorId = i + 1;
                    float[] originalVector = testVectors.get(i);
                    float[] retrievedVector = loadedIndex.getVector(vectorId);
                    Assert.assertNotNull(retrievedVector);
                    for (int j = 0; j < dimension; j++) {
                        Assert.assertEquals(originalVector[j], retrievedVector[j], 0.001f);
                    }
                }
                
                // Test search on the loaded index
                float[] queryVector = testVectors.get(0);
                SearchResult[] results = loadedIndex.search(queryVector, 3, 75);
                Assert.assertEquals(3, results.length);
                Assert.assertEquals(1, results[0].getId()); // The first vector should be the closest
            } finally {
                // Close the loaded index
                loadedIndex.close();
            }
        } finally {
            // Clean up the temporary file
            tempFile.delete();
        }
    }
    
    /**
     * Helper method to check if search results contain a vector with the given ID
     */
    private boolean containsId(SearchResult[] results, int id) {
        for (SearchResult result : results) {
            if (result.getId() == id) {
                return true;
            }
        }
        return false;
    }
}
