import { LlamaMobileVD } from '../index';

declare global {
  var Capacitor: any;
}

describe('LlamaMobileVD Plugin', () => {
  beforeEach(() => {
    // Clear any existing Capacitor mock
    if (global.Capacitor) {
      delete global.Capacitor;
    }
  });

  describe('getVersion', () => {
    it('should return version string', async () => {
      const result = await LlamaMobileVD.getVersion();
      expect(result).toHaveProperty('version');
      expect(typeof result.version).toBe('string');
    });
  });

  describe('createVectorStore', () => {
    it('should create a vector store with valid parameters', async () => {
      const result = await LlamaMobileVD.createVectorStore({
        dimension: 128,
        metric: 'cosine'
      });

      expect(result).toHaveProperty('storeId');
      expect(typeof result.storeId).toBe('number');
    });

    it('should create vector store with l2 metric', async () => {
      const result = await LlamaMobileVD.createVectorStore({
        dimension: 256,
        metric: 'l2'
      });

      expect(result).toHaveProperty('storeId');
    });

    it('should create vector store with dot metric', async () => {
      const result = await LlamaMobileVD.createVectorStore({
        dimension: 64,
        metric: 'dot'
      });

      expect(result).toHaveProperty('storeId');
    });
  });

  describe('destroyVectorStore', () => {
    it('should destroy a vector store', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 128,
        metric: 'cosine'
      });

      await expect(LlamaMobileVD.destroyVectorStore({ storeId })).resolves.not.toThrow();
    });
  });

  describe('addVectors', () => {
    it('should add vectors without IDs', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 3,
        metric: 'cosine'
      });

      const vectors = [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0]
      ];

      await expect(LlamaMobileVD.addVectors({
        storeId,
        vectors
      })).resolves.not.toThrow();
    });

    it('should add vectors with custom IDs', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 3,
        metric: 'cosine'
      });

      const vectors = [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0]
      ];
      const ids = [100, 200];

      await expect(LlamaMobileVD.addVectors({
        storeId,
        vectors,
        ids
      })).resolves.not.toThrow();
    });
  });

  describe('getVector', () => {
    it('should get a vector by ID', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 3,
        metric: 'cosine'
      });

      const vectors = [[1.0, 2.0, 3.0]];
      await LlamaMobileVD.addVectors({ storeId, vectors });

      const result = await LlamaMobileVD.getVector({ storeId, id: 1 });
      expect(result).toHaveProperty('vector');
      expect(Array.isArray(result.vector)).toBe(true);
    });
  });

  describe('search', () => {
    it('should search for similar vectors', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 3,
        metric: 'cosine'
      });

      const vectors = [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0]
      ];
      await LlamaMobileVD.addVectors({ storeId, vectors });

      const queryVector = [1.0, 2.0, 3.0];

      const result = await LlamaMobileVD.search({
        storeId,
        queryVector,
        k: 2
      });

      expect(result).toHaveProperty('ids');
      expect(result).toHaveProperty('distances');
      expect(Array.isArray(result.ids)).toBe(true);
      expect(Array.isArray(result.distances)).toBe(true);
      expect(result.ids.length).toBe(2);
      expect(result.distances.length).toBe(2);
    });
  });

  describe('removeVectors', () => {
    it('should remove vectors by IDs', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 3,
        metric: 'cosine'
      });

      const vectors = [[1.0, 2.0, 3.0]];
      await LlamaMobileVD.addVectors({ storeId, vectors });

      await expect(LlamaMobileVD.removeVectors({
        storeId,
        ids: [1]
      })).resolves.not.toThrow();
    });
  });

  describe('getVectorCount', () => {
    it('should return vector count', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 3,
        metric: 'cosine'
      });

      const vectors = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]];
      await LlamaMobileVD.addVectors({ storeId, vectors });

      const result = await LlamaMobileVD.getVectorCount({ storeId });
      expect(result).toHaveProperty('count');
      expect(typeof result.count).toBe('number');
      expect(result.count).toBe(2);
    });
  });

  describe('clearVectors', () => {
    it('should clear all vectors from store', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 3,
        metric: 'cosine'
      });

      const vectors = [[1.0, 2.0, 3.0]];
      await LlamaMobileVD.addVectors({ storeId, vectors });

      await expect(LlamaMobileVD.clearVectors({ storeId })).resolves.not.toThrow();

      const { count } = await LlamaMobileVD.getVectorCount({ storeId });
      expect(count).toBe(0);
    });
  });

  describe('createHNSWIndex', () => {
    it('should create HNSW index', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 128,
        metric: 'cosine'
      });

      const indexResult = await LlamaMobileVD.createHNSWIndex({
      dimension: 128,
      metric: 'cosine',
      maxElements: 10000,
      m: 16,
      efConstruction: 200
    });

      expect(indexResult).toHaveProperty('indexId');
      expect(typeof indexResult.indexId).toBe('number');
    });
  });

  describe('destroyHNSWIndex', () => {
    it('should destroy HNSW index', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 128,
        metric: 'cosine'
      });

      const { indexId } = await LlamaMobileVD.createHNSWIndex({
        dimension: 128,
        metric: 'cosine',
        maxElements: 10000,
        m: 16,
        efConstruction: 200
      });

      await expect(LlamaMobileVD.destroyHNSWIndex({ indexId })).resolves.not.toThrow();
    });
  });

  describe('searchHNSW', () => {
    it('should search HNSW index', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 3,
        metric: 'cosine'
      });

      const vectors = [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0]
      ];
      await LlamaMobileVD.addVectors({ storeId, vectors });

      const { indexId } = await LlamaMobileVD.createHNSWIndex({ dimension: 3, metric: 'cosine', maxElements: 10000, m: 4, efConstruction: 100 });

      const queryVector = [1.0, 2.0, 3.0];

      const result = await LlamaMobileVD.searchHNSW({
        indexId,
        queryVector,
        k: 1
      });

      expect(result).toHaveProperty('ids');
      expect(result).toHaveProperty('distances');
    });
  });

  describe('addVectorsToHNSW', () => {
    it('should add vectors to HNSW index', async () => {
      const { storeId } = await LlamaMobileVD.createVectorStore({
        dimension: 3,
        metric: 'cosine'
      });

      const { indexId } = await LlamaMobileVD.createHNSWIndex({ dimension: 3, metric: 'cosine', maxElements: 10000, m: 4, efConstruction: 100 });

      const vectors = [[1.0, 2.0, 3.0]];
      await expect(LlamaMobileVD.addVectorsToHNSW({
        indexId,
        vectors
      })).resolves.not.toThrow();
    });
  });

  describe('createMMapVectorStoreBuilder', () => {
    it('should create MMap vector store builder', async () => {
      const result = await LlamaMobileVD.createMMapVectorStoreBuilder({
        dimension: 128,
        metric: 'cosine'
      });

      expect(result).toHaveProperty('builderId');
      expect(typeof result.builderId).toBe('number');
    });
  });

  describe('destroyMMapVectorStoreBuilder', () => {
    it('should destroy MMap vector store builder', async () => {
      const result = await LlamaMobileVD.createMMapVectorStoreBuilder({
        dimension: 128,
        metric: 'cosine'
      });

      await expect(LlamaMobileVD.destroyMMapVectorStoreBuilder({ builderId: result.builderId })).resolves.not.toThrow();
    });
  });

  describe('addVectorsToMMapBuilder', () => {
    it('should add vectors to MMap builder', async () => {
      const { builderId } = await LlamaMobileVD.createMMapVectorStoreBuilder({
        dimension: 3,
        metric: 'cosine'
      });

      const vectors = [[1.0, 2.0, 3.0]];
      await expect(LlamaMobileVD.addVectorsToMMapBuilder({
        builderId,
        vectors
      })).resolves.not.toThrow();
    });
  });

  describe('buildMMapVectorStore', () => {
    it('should build MMap vector store', async () => {
      const { builderId } = await LlamaMobileVD.createMMapVectorStoreBuilder({
        dimension: 128,
        metric: 'cosine'
      });

      await expect(LlamaMobileVD.buildMMapVectorStore({ builderId, path: '/path/to/store' })).resolves.not.toThrow();
    });
  });

  describe('openMMapVectorStore', () => {
    it('should open MMap vector store', async () => {
      const result = await LlamaMobileVD.openMMapVectorStore({
        path: '/path/to/store'
      });

      expect(result).toHaveProperty('storeId');
      expect(typeof result.storeId).toBe('number');
    });
  });

  describe('closeMMapVectorStore', () => {
    it('should close MMap vector store', async () => {
      const { storeId } = await LlamaMobileVD.openMMapVectorStore({
        path: '/path/to/store'
      });

      await expect(LlamaMobileVD.closeMMapVectorStore({ storeId })).resolves.not.toThrow();
    });
  });
});
