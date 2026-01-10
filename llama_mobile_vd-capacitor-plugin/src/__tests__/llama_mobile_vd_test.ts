/**
 * Tests for LlamaMobileVD Capacitor Plugin
 * These tests focus on the TypeScript interface and basic functionality
 */

import { LlamaMobileVD, DistanceMetric } from '../index';

// Mock the Capacitor plugin
jest.mock('@capacitor/core', () => {
  // Mock WebPlugin for the web implementation
  class MockWebPlugin {
    constructor() {}
    addListener() { return { remove: () => {} }; }
    notifyListeners() {}
  }

  const mockPlugin = {
    // VectorStore Methods
    createVectorStore: jest.fn(),
    addVectorToStore: jest.fn(),
    removeVectorFromStore: jest.fn(),
    getVectorFromStore: jest.fn(),
    updateVectorInStore: jest.fn(),
    containsVectorInStore: jest.fn(),
    reserveVectorStore: jest.fn(),
    getVectorStoreDimension: jest.fn(),
    getVectorStoreMetric: jest.fn(),
    searchVectorStore: jest.fn(),
    getVectorStoreCount: jest.fn(),
    clearVectorStore: jest.fn(),
    releaseVectorStore: jest.fn(),
    
    // HNSWIndex Methods
    createHNSWIndex: jest.fn(),
    addVectorToIndex: jest.fn(),
    searchHNSWIndex: jest.fn(),
    setHNSWEfSearch: jest.fn(),
    getHNSWEfSearch: jest.fn(),
    containsVectorInHNSW: jest.fn(),
    getVectorFromHNSW: jest.fn(),
    getHNSWDimension: jest.fn(),
    getHNSWCapacity: jest.fn(),
    saveHNSWIndex: jest.fn(),
    loadHNSWIndex: jest.fn(),
    getHNSWIndexCount: jest.fn(),
    clearHNSWIndex: jest.fn(),
    releaseHNSWIndex: jest.fn(),
    
    // Version Methods
    getVersion: jest.fn(),
    getVersionMajor: jest.fn(),
    getVersionMinor: jest.fn(),
    getVersionPatch: jest.fn(),
  };

  return {
    registerPlugin: jest.fn().mockReturnValue(mockPlugin),
    Plugins: {
      LlamaMobileVD: mockPlugin,
    },
    WebPlugin: MockWebPlugin,
  };
});

// Create test instances
const mockPlugin = LlamaMobileVD as any;

describe('LlamaMobileVD Capacitor Plugin', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
  });

  describe('DistanceMetric', () => {
    it('should export the correct distance metrics', () => {
      expect(DistanceMetric.L2).toBe('L2');
      expect(DistanceMetric.COSINE).toBe('COSINE');
      expect(DistanceMetric.DOT).toBe('DOT');
    });
  });

  describe('createVectorStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockResponse = { id: mockId };
      
      mockPlugin.createVectorStore.mockResolvedValue(mockResponse);
      
      const options = {
        dimension: 512,
        metric: DistanceMetric.L2,
      };
      
      const result = await LlamaMobileVD.createVectorStore(options);
      
      expect(mockPlugin.createVectorStore).toHaveBeenCalledWith(options);
      expect(result).toEqual(mockResponse);
    });

    it('should support all distance metrics', async () => {
      const mockId = 'test-vector-store-id';
      const mockResponse = { id: mockId };
      
      mockPlugin.createVectorStore.mockResolvedValue(mockResponse);
      
      // Test with L2 metric
      await LlamaMobileVD.createVectorStore({
        dimension: 512,
        metric: DistanceMetric.L2,
      });
      
      // Test with COSINE metric
      await LlamaMobileVD.createVectorStore({
        dimension: 512,
        metric: DistanceMetric.COSINE,
      });
      
      // Test with DOT metric
      await LlamaMobileVD.createVectorStore({
        dimension: 512,
        metric: DistanceMetric.DOT,
      });
      
      expect(mockPlugin.createVectorStore).toHaveBeenCalledTimes(3);
    });

    it('should support different dimensions', async () => {
      const mockId = 'test-vector-store-id';
      const mockResponse = { id: mockId };
      
      mockPlugin.createVectorStore.mockResolvedValue(mockResponse);
      
      // Test with common embedding sizes
      const dimensions = [384, 768, 1024, 3072];
      
      for (const dimension of dimensions) {
        await LlamaMobileVD.createVectorStore({
          dimension,
          metric: DistanceMetric.L2,
        });
      }
      
      expect(mockPlugin.createVectorStore).toHaveBeenCalledTimes(dimensions.length);
    });
  });

  describe('createHNSWIndex', () => {
    it('should call the plugin with default parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockResponse = { id: mockId };
      
      mockPlugin.createHNSWIndex.mockResolvedValue(mockResponse);
      
      const options = {
        dimension: 512,
        metric: DistanceMetric.COSINE,
      };
      
      const result = await LlamaMobileVD.createHNSWIndex(options);
      
      expect(mockPlugin.createHNSWIndex).toHaveBeenCalledWith(options);
      expect(result).toEqual(mockResponse);
    });

    it('should call the plugin with custom parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockResponse = { id: mockId };
      
      mockPlugin.createHNSWIndex.mockResolvedValue(mockResponse);
      
      const options = {
        dimension: 512,
        metric: DistanceMetric.L2,
        m: 16,
        efConstruction: 200,
      };
      
      const result = await LlamaMobileVD.createHNSWIndex(options);
      
      expect(mockPlugin.createHNSWIndex).toHaveBeenCalledWith(options);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('addVectorToStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVector = Array(512).fill(0.5);
      const mockVectorId = 1;
      
      mockPlugin.addVectorToStore.mockResolvedValue(undefined);
      
      const params = {
        id: mockId,
        vector: mockVector,
        vectorId: mockVectorId,
      };
      
      await LlamaMobileVD.addVectorToStore(params);
      
      expect(mockPlugin.addVectorToStore).toHaveBeenCalledWith(params);
    });

    it('should handle different vector IDs', async () => {
      const mockId = 'test-vector-store-id';
      const mockVector = Array(512).fill(0.5);
      
      mockPlugin.addVectorToStore.mockResolvedValue(undefined);
      
      // Test with positive IDs
      await LlamaMobileVD.addVectorToStore({
        id: mockId,
        vector: mockVector,
        vectorId: 1,
      });
      
      await LlamaMobileVD.addVectorToStore({
        id: mockId,
        vector: mockVector,
        vectorId: 1000,
      });
      
      // Test with negative IDs
      await LlamaMobileVD.addVectorToStore({
        id: mockId,
        vector: mockVector,
        vectorId: -1,
      });
      
      expect(mockPlugin.addVectorToStore).toHaveBeenCalledTimes(3);
    });
  });

  describe('addVectorToIndex', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockVector = Array(512).fill(0.5);
      const mockVectorId = 1;
      
      mockPlugin.addVectorToIndex.mockResolvedValue(undefined);
      
      const params = {
        id: mockId,
        vector: mockVector,
        vectorId: mockVectorId,
      };
      
      await LlamaMobileVD.addVectorToIndex(params);
      
      expect(mockPlugin.addVectorToIndex).toHaveBeenCalledWith(params);
    });
  });

  describe('searchVectorStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockQueryVector = Array(512).fill(0.5);
      const mockK = 5;
      const mockResults = {
        results: [
          { id: 1, distance: 0.1 },
          { id: 2, distance: 0.2 },
        ],
      };
      
      mockPlugin.searchVectorStore.mockResolvedValue(mockResults);
      
      const params = {
        id: mockId,
        queryVector: mockQueryVector,
        k: mockK,
      };
      
      const results = await LlamaMobileVD.searchVectorStore(params);
      
      expect(mockPlugin.searchVectorStore).toHaveBeenCalledWith(params);
      expect(results).toEqual(mockResults);
    });
  });

  describe('searchHNSWIndex', () => {
    it('should call the plugin with default parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockQueryVector = Array(512).fill(0.5);
      const mockK = 5;
      const mockResults = {
        results: [
          { id: 1, distance: 0.1 },
          { id: 2, distance: 0.2 },
        ],
      };
      
      mockPlugin.searchHNSWIndex.mockResolvedValue(mockResults);
      
      const params = {
        id: mockId,
        queryVector: mockQueryVector,
        k: mockK,
      };
      
      const results = await LlamaMobileVD.searchHNSWIndex(params);
      
      expect(mockPlugin.searchHNSWIndex).toHaveBeenCalledWith(params);
      expect(results).toEqual(mockResults);
    });

    it('should call the plugin with custom efSearch', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockQueryVector = Array(512).fill(0.5);
      const mockK = 5;
      const mockEfSearch = 100;
      const mockResults = {
        results: [
          { id: 1, distance: 0.1 },
          { id: 2, distance: 0.2 },
        ],
      };
      
      mockPlugin.searchHNSWIndex.mockResolvedValue(mockResults);
      
      const params = {
        id: mockId,
        queryVector: mockQueryVector,
        k: mockK,
        efSearch: mockEfSearch,
      };
      
      const results = await LlamaMobileVD.searchHNSWIndex(params);
      
      expect(mockPlugin.searchHNSWIndex).toHaveBeenCalledWith(params);
      expect(results).toEqual(mockResults);
    });
  });

  describe('getVectorStoreCount', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockCount = 10;
      const mockResponse = { count: mockCount };
      
      mockPlugin.getVectorStoreCount.mockResolvedValue(mockResponse);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getVectorStoreCount(params);
      
      expect(mockPlugin.getVectorStoreCount).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('getHNSWIndexCount', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockCount = 10;
      const mockResponse = { count: mockCount };
      
      mockPlugin.getHNSWIndexCount.mockResolvedValue(mockResponse);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getHNSWIndexCount(params);
      
      expect(mockPlugin.getHNSWIndexCount).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('clearVectorStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      
      mockPlugin.clearVectorStore.mockResolvedValue(undefined);
      
      const params = { id: mockId };
      
      await LlamaMobileVD.clearVectorStore(params);
      
      expect(mockPlugin.clearVectorStore).toHaveBeenCalledWith(params);
    });
  });

  describe('clearHNSWIndex', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      
      mockPlugin.clearHNSWIndex.mockResolvedValue(undefined);
      
      const params = { id: mockId };
      
      await LlamaMobileVD.clearHNSWIndex(params);
      
      expect(mockPlugin.clearHNSWIndex).toHaveBeenCalledWith(params);
    });
  });

  describe('releaseVectorStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      
      mockPlugin.releaseVectorStore.mockResolvedValue(undefined);
      
      const params = { id: mockId };
      
      await LlamaMobileVD.releaseVectorStore(params);
      
      expect(mockPlugin.releaseVectorStore).toHaveBeenCalledWith(params);
    });
  });
  
  describe('removeVectorFromStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVectorId = 1;
      const mockResult = { result: true };
      
      mockPlugin.removeVectorFromStore.mockResolvedValue(mockResult);
      
      const params = { id: mockId, vectorId: mockVectorId };
      
      const result = await LlamaMobileVD.removeVectorFromStore(params);
      
      expect(mockPlugin.removeVectorFromStore).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });
  
  describe('getVectorFromStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVectorId = 1;
      const mockVector = Array(512).fill(0.5);
      const mockResult = { vector: mockVector };
      
      mockPlugin.getVectorFromStore.mockResolvedValue(mockResult);
      
      const params = { id: mockId, vectorId: mockVectorId };
      
      const result = await LlamaMobileVD.getVectorFromStore(params);
      
      expect(mockPlugin.getVectorFromStore).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
    
    it('should handle vector not found', async () => {
      const mockId = 'test-vector-store-id';
      const mockVectorId = 999;
      
      mockPlugin.getVectorFromStore.mockResolvedValue(null);
      
      const params = { id: mockId, vectorId: mockVectorId };
      
      const result = await LlamaMobileVD.getVectorFromStore(params);
      
      expect(mockPlugin.getVectorFromStore).toHaveBeenCalledWith(params);
      expect(result).toBeNull();
    });
  });
  
  describe('updateVectorInStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVectorId = 1;
      const mockVector = Array(512).fill(0.75);
      const mockResult = { result: true };
      
      mockPlugin.updateVectorInStore.mockResolvedValue(mockResult);
      
      const params = { id: mockId, vectorId: mockVectorId, vector: mockVector };
      
      const result = await LlamaMobileVD.updateVectorInStore(params);
      
      expect(mockPlugin.updateVectorInStore).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });
  
  describe('containsVectorInStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVectorId = 1;
      const mockResult = { result: true };
      
      mockPlugin.containsVectorInStore.mockResolvedValue(mockResult);
      
      const params = { id: mockId, vectorId: mockVectorId };
      
      const result = await LlamaMobileVD.containsVectorInStore(params);
      
      expect(mockPlugin.containsVectorInStore).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });
  
  describe('reserveVectorStore', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockCapacity = 100;
      
      mockPlugin.reserveVectorStore.mockResolvedValue(undefined);
      
      const params = { id: mockId, capacity: mockCapacity };
      
      await LlamaMobileVD.reserveVectorStore(params);
      
      expect(mockPlugin.reserveVectorStore).toHaveBeenCalledWith(params);
    });
  });
  
  describe('getVectorStoreDimension', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockDimension = 512;
      const mockResult = { dimension: mockDimension };
      
      mockPlugin.getVectorStoreDimension.mockResolvedValue(mockResult);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getVectorStoreDimension(params);
      
      expect(mockPlugin.getVectorStoreDimension).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });
  
  describe('getVectorStoreMetric', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockMetric = DistanceMetric.L2;
      const mockResult = { metric: mockMetric };
      
      mockPlugin.getVectorStoreMetric.mockResolvedValue(mockResult);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getVectorStoreMetric(params);
      
      expect(mockPlugin.getVectorStoreMetric).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });

  describe('releaseHNSWIndex', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      
      mockPlugin.releaseHNSWIndex.mockResolvedValue(undefined);
      
      const params = { id: mockId };
      
      await LlamaMobileVD.releaseHNSWIndex(params);
      
      expect(mockPlugin.releaseHNSWIndex).toHaveBeenCalledWith(params);
    });
  });
  
  describe('setHNSWEfSearch', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockEfSearch = 100;
      
      mockPlugin.setHNSWEfSearch.mockResolvedValue(undefined);
      
      const params = { id: mockId, efSearch: mockEfSearch };
      
      await LlamaMobileVD.setHNSWEfSearch(params);
      
      expect(mockPlugin.setHNSWEfSearch).toHaveBeenCalledWith(params);
    });
  });
  
  describe('getHNSWEfSearch', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockEfSearch = 50;
      const mockResult = { efSearch: mockEfSearch };
      
      mockPlugin.getHNSWEfSearch.mockResolvedValue(mockResult);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getHNSWEfSearch(params);
      
      expect(mockPlugin.getHNSWEfSearch).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });
  
  describe('containsVectorInHNSW', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockVectorId = 1;
      const mockResult = { result: true };
      
      mockPlugin.containsVectorInHNSW.mockResolvedValue(mockResult);
      
      const params = { id: mockId, vectorId: mockVectorId };
      
      const result = await LlamaMobileVD.containsVectorInHNSW(params);
      
      expect(mockPlugin.containsVectorInHNSW).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });
  
  describe('getVectorFromHNSW', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockVectorId = 1;
      const mockVector = Array(512).fill(0.5);
      const mockResult = { vector: mockVector };
      
      mockPlugin.getVectorFromHNSW.mockResolvedValue(mockResult);
      
      const params = { id: mockId, vectorId: mockVectorId };
      
      const result = await LlamaMobileVD.getVectorFromHNSW(params);
      
      expect(mockPlugin.getVectorFromHNSW).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
    
    it('should handle vector not found', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockVectorId = 999;
      
      mockPlugin.getVectorFromHNSW.mockResolvedValue(null);
      
      const params = { id: mockId, vectorId: mockVectorId };
      
      const result = await LlamaMobileVD.getVectorFromHNSW(params);
      
      expect(mockPlugin.getVectorFromHNSW).toHaveBeenCalledWith(params);
      expect(result).toBeNull();
    });
  });
  
  describe('getHNSWDimension', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockDimension = 512;
      const mockResult = { dimension: mockDimension };
      
      mockPlugin.getHNSWDimension.mockResolvedValue(mockResult);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getHNSWDimension(params);
      
      expect(mockPlugin.getHNSWDimension).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });
  
  describe('getHNSWCapacity', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockCapacity = 1000;
      const mockResult = { capacity: mockCapacity };
      
      mockPlugin.getHNSWCapacity.mockResolvedValue(mockResult);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getHNSWCapacity(params);
      
      expect(mockPlugin.getHNSWCapacity).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });
  
  describe('saveHNSWIndex', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockPath = '/path/to/index.ann';
      
      mockPlugin.saveHNSWIndex.mockResolvedValue({ result: true });
      
      const params = { id: mockId, path: mockPath };
      
      await LlamaMobileVD.saveHNSWIndex(params);
      
      expect(mockPlugin.saveHNSWIndex).toHaveBeenCalledWith(params);
    });
  });
  
  describe('loadHNSWIndex', () => {
    it('should call the plugin with the correct parameters', async () => {
      const mockPath = '/path/to/index.ann';
      const mockId = 'loaded-hnsw-index-id';
      const mockResult = { id: mockId };
      
      mockPlugin.loadHNSWIndex.mockResolvedValue(mockResult);
      
      const params = { path: mockPath };
      
      const result = await LlamaMobileVD.loadHNSWIndex(params);
      
      expect(mockPlugin.loadHNSWIndex).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResult);
    });
  });
  
  describe('Version Methods', () => {
    describe('getVersion', () => {
      it('should call the plugin with the correct parameters', async () => {
        const mockVersion = '1.0.0';
        const mockResult = { version: mockVersion };
        
        mockPlugin.getVersion.mockResolvedValue(mockResult);
        
        const result = await LlamaMobileVD.getVersion();
        
        expect(mockPlugin.getVersion).toHaveBeenCalled();
        expect(result).toEqual(mockResult);
      });
    });
    
    describe('getVersionMajor', () => {
      it('should call the plugin with the correct parameters', async () => {
        const mockMajor = 1;
        const mockResult = { major: mockMajor };
        
        mockPlugin.getVersionMajor.mockResolvedValue(mockResult);
        
        const result = await LlamaMobileVD.getVersionMajor();
        
        expect(mockPlugin.getVersionMajor).toHaveBeenCalled();
        expect(result).toEqual(mockResult);
      });
    });
    
    describe('getVersionMinor', () => {
      it('should call the plugin with the correct parameters', async () => {
        const mockMinor = 2;
        const mockResult = { minor: mockMinor };
        
        mockPlugin.getVersionMinor.mockResolvedValue(mockResult);
        
        const result = await LlamaMobileVD.getVersionMinor();
        
        expect(mockPlugin.getVersionMinor).toHaveBeenCalled();
        expect(result).toEqual(mockResult);
      });
    });
    
    describe('getVersionPatch', () => {
      it('should call the plugin with the correct parameters', async () => {
        const mockPatch = 3;
        const mockResult = { patch: mockPatch };
        
        mockPlugin.getVersionPatch.mockResolvedValue(mockResult);
        
        const result = await LlamaMobileVD.getVersionPatch();
        
        expect(mockPlugin.getVersionPatch).toHaveBeenCalled();
        expect(result).toEqual(mockResult);
      });
    });
  });

  describe('large dimensions', () => {
    it('should support 3072 dimensional vectors', async () => {
      const mockId = 'test-vector-store-id';
      const mockResponse = { id: mockId };
      
      mockPlugin.createVectorStore.mockResolvedValue(mockResponse);
      
      const options = {
        dimension: 3072,
        metric: DistanceMetric.COSINE,
      };
      
      const result = await LlamaMobileVD.createVectorStore(options);
      
      expect(mockPlugin.createVectorStore).toHaveBeenCalledWith(options);
      expect(result).toEqual(mockResponse);
    });
  });
});
