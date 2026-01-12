package com.llamamobile.vd;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Comprehensive test suite for the LlamaMobileVD Android Java SDK
 * Tests cover VectorStore, HNSWIndex, and MMapVectorStore APIs with various dimensions and distance metrics
 */
public class LlamaMobileVDJavaTests {

    // Test vector dimensions (including common sizes like 384, 768, 1024)
    private final int[] testDimensions = {384, 768, 1024};

    // Test distance metrics
    private final DistanceMetric[] testMetrics = {DistanceMetric.L2, DistanceMetric.COSINE, DistanceMetric.DOT};

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
        for (int dimension : testDimensions) {
            for (DistanceMetric metric : testMetrics) {
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
                vec[j] = (i / 10.0f);
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
        for (int i = 0; i < dimension; i++) {
            vector1[i] = 1.0f;
        }

        float[] vector2 = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector2[i] = 0.5f;
        }

        float[] vector3 = new float[dimension];
        for (int i = 0; i < dimension; i++) {
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
    public void testHNSWIndexCreation() {
        for (int dimension : testDimensions) {
            for (DistanceMetric metric : testMetrics) {
                HNSWIndex hnswIndex = track(new HNSWIndex(dimension, metric));
                Assert.assertEquals(0, hnswIndex.getCount());
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

        // Test adding multiple vectors
        for (int i = 2; i <= 20; i++) {
            float[] vec = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vec[j] = (float) (Math.random() * 2.0f - 1.0f);
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
        for (int i = 0; i < dimension; i++) {
            baseVector[i] = 0.5f;
        }

        float[] similarVector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            similarVector[i] = 0.6f;
        }

        float[] dissimilarVector = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            dissimilarVector[i] = -0.5f;
        }

        hnswIndex.addVector(baseVector, 1);
        hnswIndex.addVector(similarVector, 2);
        hnswIndex.addVector(dissimilarVector, 3);

        // Add some random vectors
        for (int i = 4; i <= 10; i++) {
            float[] vec = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vec[j] = (float) (Math.random() * 2.0f - 1.0f);
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
        boolean foundId2InResults1 = false;
        for (SearchResult result : results1) {
            if (result.getId() == 2) {
                foundId2InResults1 = true;
                break;
            }
        }
        Assert.assertTrue(foundId2InResults1);

        boolean foundId2InResults2 = false;
        for (SearchResult result : results2) {
            if (result.getId() == 2) {
                foundId2InResults2 = true;
                break;
            }
        }
        Assert.assertTrue(foundId2InResults2);
    }

    @Test
    public void testMMapVectorStoreBuilderCreation() {
        for (int dimension : testDimensions) {
            for (DistanceMetric metric : testMetrics) {
                MMapVectorStoreBuilder builder = track(new MMapVectorStoreBuilder(dimension, metric));
                Assert.assertEquals(0, builder.getCount());
            }
        }
    }

    @Test
    public void testMMapVectorStoreBuilderOperations() {
        int dimension = 512;
        DistanceMetric metric = DistanceMetric.L2;

        MMapVectorStoreBuilder builder = track(new MMapVectorStoreBuilder(dimension, metric));

        // Test adding vectors
        float[] vector1 = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector1[i] = 1.0f;
        }
        float[] vector2 = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector2[i] = 0.5f;
        }
        float[] vector3 = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector3[i] = 0.25f;
        }

        builder.addVector(vector1, 1);
        Assert.assertEquals(1, builder.getCount());

        builder.addVector(vector2, 2);
        Assert.assertEquals(2, builder.getCount());

        builder.addVector(vector3, 3);
        Assert.assertEquals(3, builder.getCount());

        // Test reserve
        builder.reserve(100);
        Assert.assertEquals(3, builder.getCount());

        // Test adding more vectors after reserve
        for (int i = 4; i <= 10; i++) {
            float[] vector = new float[dimension];
            for (int j = 0; j < dimension; j++) {
                vector[j] = (i / 10.0f);
            }
            builder.addVector(vector, i);
        }
        Assert.assertEquals(10, builder.getCount());
    }

    @Test
    public void testMMapVectorStoreSaveLoad() throws Exception {
        int dimension = 256;
        DistanceMetric metric = DistanceMetric.COSINE;

        // Create a temporary file path for testing
        File tempFile = File.createTempFile("mmap_test", ".store");
        String tempFilePath = tempFile.getAbsolutePath();

        try {
            // Create and populate the builder
            MMapVectorStoreBuilder builder = track(new MMapVectorStoreBuilder(dimension, metric));

            // Add some vectors
            float[] vector1 = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector1[i] = 1.0f;
            }
            float[] vector2 = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector2[i] = 0.5f;
            }
            float[] vector3 = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector3[i] = 0.25f;
            }

            builder.addVector(vector1, 1);
            builder.addVector(vector2, 2);
            builder.addVector(vector3, 3);

            // Save to file
            Assert.assertTrue(builder.save(tempFilePath));

            // Close the builder
            builder.close();
            resourcesToClose.remove(builder);

            // Open the MMapVectorStore
            MMapVectorStore vectorStore = track(MMapVectorStore.open(tempFilePath));

            // Verify store properties
            Assert.assertEquals(dimension, vectorStore.getDimension());
            Assert.assertEquals(metric, vectorStore.getMetric());
            Assert.assertEquals(3, vectorStore.getCount());

            // Verify vectors can be retrieved
            float[] retrieved1 = vectorStore.get(1);
            Assert.assertNotNull(retrieved1);
            Assert.assertEquals(dimension, retrieved1.length);
            for (int i = 0; i < dimension; i++) {
                Assert.assertEquals(vector1[i], retrieved1[i], 0.001f);
            }

            float[] retrieved2 = vectorStore.get(2);
            Assert.assertNotNull(retrieved2);
            for (int i = 0; i < dimension; i++) {
                Assert.assertEquals(vector2[i], retrieved2[i], 0.001f);
            }

            float[] retrieved3 = vectorStore.get(3);
            Assert.assertNotNull(retrieved3);
            for (int i = 0; i < dimension; i++) {
                Assert.assertEquals(vector3[i], retrieved3[i], 0.001f);
            }

            // Verify contains functionality
            Assert.assertTrue(vectorStore.contains(1));
            Assert.assertTrue(vectorStore.contains(2));
            Assert.assertTrue(vectorStore.contains(3));
            Assert.assertFalse(vectorStore.contains(4));
        } finally {
            // Clean up the temporary file
            tempFile.delete();
        }
    }

    @Test
    public void testMMapVectorStoreSearch() throws Exception {
        int dimension = 512;
        DistanceMetric metric = DistanceMetric.COSINE;

        // Create a temporary file path for testing
        File tempFile = File.createTempFile("mmap_search_test", ".store");
        String tempFilePath = tempFile.getAbsolutePath();

        try {
            // Create and populate the store
            MMapVectorStoreBuilder builder = track(new MMapVectorStoreBuilder(dimension, metric));

            // Add known vectors for predictable search results
            float[] vector1 = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector1[i] = 1.0f;  // ID 1
            }
            float[] vector2 = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector2[i] = 0.9f;  // ID 2 - very similar to vector1
            }
            float[] vector3 = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector3[i] = 0.5f;  // ID 3 - somewhat similar
            }
            float[] vector4 = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector4[i] = 0.1f;  // ID 4 - less similar
            }
            float[] vector5 = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector5[i] = -1.0f; // ID 5 - very dissimilar
            }

            builder.addVector(vector1, 1);
            builder.addVector(vector2, 2);
            builder.addVector(vector3, 3);
            builder.addVector(vector4, 4);
            builder.addVector(vector5, 5);

            // Save the store
            Assert.assertTrue(builder.save(tempFilePath));

            // Close the builder
            builder.close();
            resourcesToClose.remove(builder);

            // Open and search
            MMapVectorStore vectorStore = track(MMapVectorStore.open(tempFilePath));

            // Test search for vector1 - should find itself first
            SearchResult[] results1 = vectorStore.search(vector1, 3);
            Assert.assertEquals(3, results1.length);
            Assert.assertEquals(1, results1[0].getId());  // Exact match
            Assert.assertEquals(2, results1[1].getId());  // Very similar
            Assert.assertEquals(3, results1[2].getId());  // Somewhat similar

            // Test search for vector3
            SearchResult[] results2 = vectorStore.search(vector3, 2);
            Assert.assertEquals(2, results2.length);
            Assert.assertEquals(3, results2[0].getId());  // Exact match
        } finally {
            // Clean up the temporary file
            tempFile.delete();
        }
    }

    @Test
    public void testDistanceMetrics() {
        int dimension = 128;

        // Test L2 distance
        VectorStore vectorStoreL2 = track(new VectorStore(dimension, DistanceMetric.L2));
        float[] vectorL2 = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vectorL2[i] = 1.0f;
        }
        vectorStoreL2.addVector(vectorL2, 1);

        // Test Cosine distance
        VectorStore vectorStoreCosine = track(new VectorStore(dimension, DistanceMetric.COSINE));
        float[] vectorCosine = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vectorCosine[i] = 1.0f;
        }
        vectorStoreCosine.addVector(vectorCosine, 1);

        // Test Dot product distance
        VectorStore vectorStoreDot = track(new VectorStore(dimension, DistanceMetric.DOT));
        float[] vectorDot = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vectorDot[i] = 1.0f;
        }
        vectorStoreDot.addVector(vectorDot, 1);
    }

    @Test
    public void testErrorHandling() {
        int dimension = 16;
        DistanceMetric metric = DistanceMetric.L2;

        // Test vector store with wrong dimension vector
        VectorStore vectorStore = track(new VectorStore(dimension, metric));
        float[] wrongDimensionVector = new float[dimension + 1];
        for (int i = 0; i < wrongDimensionVector.length; i++) {
            wrongDimensionVector[i] = 0.5f;
        }

        try {
            vectorStore.addVector(wrongDimensionVector, 1);
            Assert.fail("Expected IllegalArgumentException");
        } catch (IllegalArgumentException e) {
            // Expected
        }

        // Test MMapVectorStoreBuilder with wrong dimension vector
        MMapVectorStoreBuilder builder = track(new MMapVectorStoreBuilder(dimension, metric));
        try {
            builder.addVector(wrongDimensionVector, 1);
            Assert.fail("Expected IllegalArgumentException");
        } catch (IllegalArgumentException e) {
            // Expected
        }
    }

    @Test
    public void testAutoCloseable() {
        int dimension = 32;
        DistanceMetric metric = DistanceMetric.COSINE;

        // Test that VectorStore implements AutoCloseable correctly
        try (VectorStore vs = new VectorStore(dimension, metric)) {
            float[] vector = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector[i] = 0.5f;
            }
            vs.addVector(vector, 1);
            Assert.assertEquals(1, vs.getCount());
        } catch (Exception e) {
            Assert.fail("AutoCloseable test failed for VectorStore");
        }

        // Test that MMapVectorStoreBuilder implements AutoCloseable correctly
        try (MMapVectorStoreBuilder builder = new MMapVectorStoreBuilder(dimension, metric)) {
            float[] vector = new float[dimension];
            for (int i = 0; i < dimension; i++) {
                vector[i] = 0.5f;
            }
            builder.addVector(vector, 1);
            Assert.assertEquals(1, builder.getCount());
        } catch (Exception e) {
            Assert.fail("AutoCloseable test failed for MMapVectorStoreBuilder");
        }
    }
}
