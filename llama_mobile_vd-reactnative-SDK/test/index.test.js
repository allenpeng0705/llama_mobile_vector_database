const LlamaMobileVD = require('../src/index');

// Helper function to generate random vector of specified dimension
function generateRandomVector(dimension) {
  return Array(dimension).fill(0).map(() => Math.random());
}

// Helper function to generate multiple vectors
function generateVectors(count, dimension) {
  return Array(count).fill(0).map((_, i) => ({
    id: i + 1,
    vector: generateRandomVector(dimension)
  }));
}

describe('LlamaMobileVD ReactNative SDK', () => {
  // Test different dimensions
  const dimensions = [128, 512, 1024, 2048, 3096];
  const datasetSizes = [100, 1000, 5000, 10000];
  
  describe('Version Methods', () => {
    test('get version', async () => {
      const version = await LlamaMobileVD.getVersion();
      expect(typeof version).toBe('string');
    });
    
    test('get version major', async () => {
      const major = await LlamaMobileVD.getVersionMajor();
      expect(typeof major).toBe('number');
    });
    
    test('get version minor', async () => {
      const minor = await LlamaMobileVD.getVersionMinor();
      expect(typeof minor).toBe('number');
    });
    
    test('get version patch', async () => {
      const patch = await LlamaMobileVD.getVersionPatch();
      expect(typeof patch).toBe('number');
    });
  });
  
  // Test VectorStore with different dimensions
  dimensions.forEach(dimension => {
    describe(`VectorStore - Dimension ${dimension}`, () => {
      let storeId;
      
      beforeAll(async () => {
        storeId = await LlamaMobileVD.vectorStoreCreate(dimension, 0); // 0 = L2 distance
      });
      
      afterAll(async () => {
        if (storeId) {
          await LlamaMobileVD.vectorStoreDestroy(storeId);
        }
      });
      
      test('add vector', async () => {
        const vector = generateRandomVector(dimension);
        const result = await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);
        expect(result).toBe(true);
      });
      
      test('search vector', async () => {
        const queryVector = generateRandomVector(dimension);
        const results = await LlamaMobileVD.vectorStoreSearch(storeId, queryVector, 1);
        expect(Array.isArray(results)).toBe(true);
      });
      
      test('get vector', async () => {
        const vector = await LlamaMobileVD.vectorStoreGetVector(storeId, 1);
        expect(Array.isArray(vector)).toBe(true);
        expect(vector.length).toBe(dimension);
      });
      
      test('contains vector', async () => {
        const contains = await LlamaMobileVD.vectorStoreContains(storeId, 1);
        expect(contains).toBe(true);
      });
      
      test('remove vector', async () => {
        const removed = await LlamaMobileVD.vectorStoreRemoveVector(storeId, 1);
        expect(removed).toBe(true);
      });
      
      test('get size', async () => {
        const size = await LlamaMobileVD.vectorStoreGetSize(storeId);
        expect(typeof size).toBe('number');
      });
      
      test('get dimension', async () => {
        const resultDimension = await LlamaMobileVD.vectorStoreGetDimension(storeId);
        expect(resultDimension).toBe(dimension);
      });
      
      test('get metric', async () => {
        const metric = await LlamaMobileVD.vectorStoreGetMetric(storeId);
        expect(typeof metric).toBe('number');
      });
      
      test('update vector', async () => {
        const vector = generateRandomVector(dimension);
        await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);
        const updatedVector = generateRandomVector(dimension);
        const updated = await LlamaMobileVD.vectorStoreUpdateVector(storeId, 1, updatedVector);
        expect(updated).toBe(true);
      });
      
      test('reserve capacity', async () => {
        const reserved = await LlamaMobileVD.vectorStoreReserve(storeId, 100);
        expect(reserved).toBe(true);
      });
      
      test('clear vector store', async () => {
        const cleared = await LlamaMobileVD.vectorStoreClear(storeId);
        expect(cleared).toBe(true);
      });
    });
  });
  
  // Test VectorStore with different dataset sizes
  datasetSizes.forEach(size => {
    describe(`VectorStore - Dataset Size ${size}`, () => {
      let storeId;
      const dimension = 128; // Use fixed dimension for size tests
      
      beforeAll(async () => {
        storeId = await LlamaMobileVD.vectorStoreCreate(dimension, 0);
        
        // Add vectors
        const vectors = generateVectors(size, dimension);
        for (const { id, vector } of vectors) {
          await LlamaMobileVD.vectorStoreAddVector(storeId, id, vector);
        }
      });
      
      afterAll(async () => {
        if (storeId) {
          await LlamaMobileVD.vectorStoreDestroy(storeId);
        }
      });
      
      test('verify size', async () => {
        const resultSize = await LlamaMobileVD.vectorStoreGetSize(storeId);
        expect(resultSize).toBe(size);
      });
      
      test('search with large dataset', async () => {
        const queryVector = generateRandomVector(dimension);
        const results = await LlamaMobileVD.vectorStoreSearch(storeId, queryVector, 5);
        expect(Array.isArray(results)).toBe(true);
        expect(results.length).toBeLessThanOrEqual(5);
      });
      
      test('batch operations', async () => {
        // Test multiple operations in sequence
        const testId = size + 1;
        const testVector = generateRandomVector(dimension);
        
        // Add
        await LlamaMobileVD.vectorStoreAddVector(storeId, testId, testVector);
        
        // Verify
        const contains = await LlamaMobileVD.vectorStoreContains(storeId, testId);
        expect(contains).toBe(true);
        
        // Remove
        const removed = await LlamaMobileVD.vectorStoreRemoveVector(storeId, testId);
        expect(removed).toBe(true);
      });
    });
  });
  
  describe('HNSWIndex', () => {
    let indexId;
    const testFilename = 'test_hnsw_index.bin';
    
    beforeAll(async () => {
      indexId = await LlamaMobileVD.hnswIndexCreate(128, 0, 1000); // 0 = L2 distance
    });
    
    afterAll(async () => {
      if (indexId) {
        await LlamaMobileVD.hnswIndexDestroy(indexId);
      }
      
      // Clean up test file
      const fs = require('fs');
      if (fs.existsSync(testFilename)) {
        try {
          fs.unlinkSync(testFilename);
        } catch (error) {
          console.log('Error deleting test file:', error);
        }
      }
    });
    
    test('add vector', async () => {
      const vector = generateRandomVector(128);
      const result = await LlamaMobileVD.hnswIndexAddVector(indexId, 1, vector);
      expect(result).toBe(true);
    });
    
    test('search vector', async () => {
      const queryVector = generateRandomVector(128);
      const results = await LlamaMobileVD.hnswIndexSearch(indexId, queryVector, 1);
      expect(Array.isArray(results)).toBe(true);
    });
    
    test('set and get efSearch', async () => {
      await LlamaMobileVD.hnswIndexSetEfSearch(indexId, 100);
      const efSearch = await LlamaMobileVD.hnswIndexGetEfSearch(indexId);
      expect(efSearch).toBe(100);
    });
    
    test('get size', async () => {
      const size = await LlamaMobileVD.hnswIndexGetSize(indexId);
      expect(typeof size).toBe('number');
    });
    
    test('get dimension', async () => {
      const dimension = await LlamaMobileVD.hnswIndexGetDimension(indexId);
      expect(dimension).toBe(128);
    });
    
    test('get capacity', async () => {
      const capacity = await LlamaMobileVD.hnswIndexGetCapacity(indexId);
      expect(typeof capacity).toBe('number');
    });
    
    test('contains vector', async () => {
      const contains = await LlamaMobileVD.hnswIndexContains(indexId, 1);
      expect(contains).toBe(true);
    });
    
    test('get vector', async () => {
      const vector = await LlamaMobileVD.hnswIndexGetVector(indexId, 1);
      expect(Array.isArray(vector)).toBe(true);
      expect(vector.length).toBe(128);
    });
    
    test('save and load index', async () => {
      // Save index
      const saved = await LlamaMobileVD.hnswIndexSave(indexId, testFilename);
      expect(saved).toBe(true);
      
      // Load index
      const loadedIndexId = await LlamaMobileVD.hnswIndexLoad(testFilename);
      expect(typeof loadedIndexId).toBe('number');
      expect(loadedIndexId).not.toBe(0);
      
      // Clean up loaded index
      if (loadedIndexId) {
        await LlamaMobileVD.hnswIndexDestroy(loadedIndexId);
      }
    });
  });
  
  describe('MMapVectorStore', () => {
    let builderId;
    let storeId;
    const filename = 'test_mmap_vector_store.bin';
    
    beforeAll(async () => {
      // Create builder
      builderId = await LlamaMobileVD.mmapVectorStoreBuilderCreate(128, 0); // 0 = L2 distance
      
      // Reserve capacity
      const reserved = await LlamaMobileVD.mmapVectorStoreBuilderReserve(builderId, 100);
      expect(reserved).toBe(true);
      
      // Add vector to builder
      const vector = generateRandomVector(128);
      await LlamaMobileVD.mmapVectorStoreBuilderAddVector(builderId, 1, vector);
      
      // Save builder to file
      await LlamaMobileVD.mmapVectorStoreBuilderSave(builderId, filename);
      
      // Open MMapVectorStore from file
      storeId = await LlamaMobileVD.mmapVectorStoreOpen(filename);
    });
    
    afterAll(async () => {
      // Close and clean up
      if (storeId) {
        await LlamaMobileVD.mmapVectorStoreClose(storeId);
      }
      if (builderId) {
        await LlamaMobileVD.mmapVectorStoreBuilderDestroy(builderId);
      }
      
      // Delete test file
      const fs = require('fs');
      if (fs.existsSync(filename)) {
        try {
          fs.unlinkSync(filename);
        } catch (error) {
          console.log('Error deleting test file:', error);
        }
      }
    });
    
    test('contains vector', async () => {
      const contains = await LlamaMobileVD.mmapVectorStoreContains(storeId, 1);
      expect(contains).toBe(true);
    });
    
    test('search vector', async () => {
      const queryVector = generateRandomVector(128);
      const results = await LlamaMobileVD.mmapVectorStoreSearch(storeId, queryVector, 1);
      expect(Array.isArray(results)).toBe(true);
    });
    
    test('get vector', async () => {
      const vector = await LlamaMobileVD.mmapVectorStoreGetVector(storeId, 1);
      expect(Array.isArray(vector)).toBe(true);
      expect(vector.length).toBe(128);
    });
    
    test('get size', async () => {
      const size = await LlamaMobileVD.mmapVectorStoreGetSize(storeId);
      expect(typeof size).toBe('number');
    });
    
    test('get dimension', async () => {
      const dimension = await LlamaMobileVD.mmapVectorStoreGetDimension(storeId);
      expect(dimension).toBe(128);
    });
    
    test('get metric', async () => {
      const metric = await LlamaMobileVD.mmapVectorStoreGetMetric(storeId);
      expect(typeof metric).toBe('number');
    });
  });
  
  // Test MMapVectorStoreBuilder with different dimensions
  dimensions.forEach(dimension => {
    describe(`MMapVectorStoreBuilder - Dimension ${dimension}`, () => {
      let builderId;
      const filename = `test_mmap_builder_${dimension}.bin`;
      
      beforeAll(async () => {
        builderId = await LlamaMobileVD.mmapVectorStoreBuilderCreate(dimension, 0);
      });
      
      afterAll(async () => {
        if (builderId) {
          await LlamaMobileVD.mmapVectorStoreBuilderDestroy(builderId);
        }
        
        // Clean up test file
        const fs = require('fs');
        if (fs.existsSync(filename)) {
          try {
            fs.unlinkSync(filename);
          } catch (error) {
            console.log('Error deleting test file:', error);
          }
        }
      });
      
      test('add vector', async () => {
        const vector = generateRandomVector(dimension);
        const added = await LlamaMobileVD.mmapVectorStoreBuilderAddVector(builderId, 1, vector);
        expect(added).toBe(true);
      });
      
      test('get size', async () => {
        const size = await LlamaMobileVD.mmapVectorStoreBuilderGetSize(builderId);
        expect(size).toBe(1);
      });
      
      test('get dimension', async () => {
        const resultDimension = await LlamaMobileVD.mmapVectorStoreBuilderGetDimension(builderId);
        expect(resultDimension).toBe(dimension);
      });
      
      test('save builder', async () => {
        const saved = await LlamaMobileVD.mmapVectorStoreBuilderSave(builderId, filename);
        expect(saved).toBe(true);
      });
    });
  });
});
