/**
 * Tests for LlamaMobileVD React Native SDK
 * These tests focus on the JavaScript interface and basic functionality
 */

import LlamaMobileVD, { DistanceMetric } from '../lib/index';

// Mock the native module
jest.mock('react-native', () => {
  const NativeModules = {
    LlamaMobileVD: {
      createVectorStore: jest.fn(),
      createHNSWIndex: jest.fn(),
      addVectorToStore: jest.fn(),
      addVectorToHNSW: jest.fn(),
      removeVectorFromStore: jest.fn(),
      getVectorFromStore: jest.fn(),
      updateVectorInStore: jest.fn(),
      containsVectorInStore: jest.fn(),
      reserveVectorStore: jest.fn(),
      getVectorStoreDimension: jest.fn(),
      getVectorStoreMetric: jest.fn(),
      searchVectorStore: jest.fn(),
      searchHNSWIndex: jest.fn(),
      setHNSWEfSearch: jest.fn(),
      getHNSWEfSearch: jest.fn(),
      containsVectorInHNSW: jest.fn(),
      getVectorFromHNSW: jest.fn(),
      getHNSWDimension: jest.fn(),
      getHNSWCapacity: jest.fn(),
      saveHNSWIndex: jest.fn(),
      loadHNSWIndex: jest.fn(),
      countVectorStore: jest.fn(),
      countHNSWIndex: jest.fn(),
      clearVectorStore: jest.fn(),
      clearHNSWIndex: jest.fn(),
      releaseVectorStore: jest.fn(),
      releaseHNSWIndex: jest.fn(),
      getVersion: jest.fn(),
      getVersionMajor: jest.fn(),
      getVersionMinor: jest.fn(),
      getVersionPatch: jest.fn(),
    },
  };
  
  return { NativeModules };
});

describe('LlamaMobileVD', () => {
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
    it('should call the native module with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockResponse = { id: mockId };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.createVectorStore.mockResolvedValue(mockResponse);
      
      const options = {
        dimension: 128,
        metric: DistanceMetric.L2,
      };
      
      const result = await LlamaMobileVD.createVectorStore(options);
      
      expect(NativeModules.LlamaMobileVD.createVectorStore).toHaveBeenCalledWith(options);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('createHNSWIndex', () => {
    it('should call the native module with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockResponse = { id: mockId };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.createHNSWIndex.mockResolvedValue(mockResponse);
      
      const options = {
        dimension: 128,
        metric: DistanceMetric.COSINE,
        m: 16,
        efConstruction: 200,
      };
      
      const result = await LlamaMobileVD.createHNSWIndex(options);
      
      expect(NativeModules.LlamaMobileVD.createHNSWIndex).toHaveBeenCalledWith(options);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('addVectorToStore', () => {
    it('should call the native module with the correct parameters (including vectorId)', async () => {
      const mockId = 'test-vector-store-id';
      const mockVector = Array(128).fill(0.5);
      const mockVectorId = 1;
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.addVectorToStore.mockResolvedValue();
      
      const params = {
        id: mockId,
        vector: mockVector,
        vectorId: mockVectorId,
      };
      
      await LlamaMobileVD.addVectorToStore(params);
      
      expect(NativeModules.LlamaMobileVD.addVectorToStore).toHaveBeenCalledWith(params);
    });
  });

  describe('searchVectorStore', () => {
    it('should call the native module with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockQueryVector = Array(128).fill(0.5);
      const mockK = 5;
      const mockResults = [
        { index: 0, distance: 0.1 },
        { index: 1, distance: 0.2 },
        { index: 2, distance: 0.3 },
      ];
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.searchVectorStore.mockResolvedValue(mockResults);
      
      const params = {
        id: mockId,
        queryVector: mockQueryVector,
        k: mockK,
      };
      
      const results = await LlamaMobileVD.searchVectorStore(params);
      
      expect(NativeModules.LlamaMobileVD.searchVectorStore).toHaveBeenCalledWith(params);
      expect(results).toEqual(mockResults);
    });
  });

  describe('countVectorStore', () => {
    it('should call the native module with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockCount = 10;
      const mockResponse = { count: mockCount };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.countVectorStore.mockResolvedValue(mockResponse);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.countVectorStore(params);
      
      expect(NativeModules.LlamaMobileVD.countVectorStore).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('clearVectorStore', () => {
    it('should call the native module with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.clearVectorStore.mockResolvedValue();
      
      const params = { id: mockId };
      
      await LlamaMobileVD.clearVectorStore(params);
      
      expect(NativeModules.LlamaMobileVD.clearVectorStore).toHaveBeenCalledWith(params);
    });
  });

  describe('releaseVectorStore', () => {
    it('should call the native module with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.releaseVectorStore.mockResolvedValue();
      
      const params = { id: mockId };
      
      await LlamaMobileVD.releaseVectorStore(params);
      
      expect(NativeModules.LlamaMobileVD.releaseVectorStore).toHaveBeenCalledWith(params);
    });
  });

  describe('HNSWIndex methods', () => {
    it('should call addVectorToHNSW with the correct parameters (including vectorId)', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockVector = Array(128).fill(0.5);
      const mockVectorId = 1;
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.addVectorToHNSW.mockResolvedValue();
      
      const params = {
        id: mockId,
        vector: mockVector,
        vectorId: mockVectorId,
      };
      
      await LlamaMobileVD.addVectorToHNSW(params);
      
      expect(NativeModules.LlamaMobileVD.addVectorToHNSW).toHaveBeenCalledWith(params);
    });

    it('should call searchHNSWIndex with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockQueryVector = Array(128).fill(0.5);
      const mockK = 5;
      const mockResults = [
        { index: 0, distance: 0.1 },
        { index: 1, distance: 0.2 },
        { index: 2, distance: 0.3 },
      ];
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.searchHNSWIndex.mockResolvedValue(mockResults);
      
      const params = {
        id: mockId,
        queryVector: mockQueryVector,
        k: mockK,
      };
      
      const results = await LlamaMobileVD.searchHNSWIndex(params);
      
      expect(NativeModules.LlamaMobileVD.searchHNSWIndex).toHaveBeenCalledWith(params);
      expect(results).toEqual(mockResults);
    });

    it('should call countHNSWIndex with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockCount = 10;
      const mockResponse = { count: mockCount };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.countHNSWIndex.mockResolvedValue(mockResponse);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.countHNSWIndex(params);
      
      expect(NativeModules.LlamaMobileVD.countHNSWIndex).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });

    it('should call clearHNSWIndex with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.clearHNSWIndex.mockResolvedValue();
      
      const params = { id: mockId };
      
      await LlamaMobileVD.clearHNSWIndex(params);
      
      expect(NativeModules.LlamaMobileVD.clearHNSWIndex).toHaveBeenCalledWith(params);
    });

    it('should call releaseHNSWIndex with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.releaseHNSWIndex.mockResolvedValue();
      
      const params = { id: mockId };
      
      await LlamaMobileVD.releaseHNSWIndex(params);
      
      expect(NativeModules.LlamaMobileVD.releaseHNSWIndex).toHaveBeenCalledWith(params);
    });
  });

  describe('Additional VectorStore methods', () => {
    it('should call removeVectorFromStore with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVectorId = 1;
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.removeVectorFromStore.mockResolvedValue(true);
      
      const params = {
        id: mockId,
        vectorId: mockVectorId,
      };
      
      const result = await LlamaMobileVD.removeVectorFromStore(params);
      
      expect(NativeModules.LlamaMobileVD.removeVectorFromStore).toHaveBeenCalledWith(params);
      expect(result).toBe(true);
    });

    it('should call getVectorFromStore with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVectorId = 1;
      const mockVector = Array(128).fill(0.5);
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getVectorFromStore.mockResolvedValue(mockVector);
      
      const params = {
        id: mockId,
        vectorId: mockVectorId,
      };
      
      const result = await LlamaMobileVD.getVectorFromStore(params);
      
      expect(NativeModules.LlamaMobileVD.getVectorFromStore).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockVector);
    });

    it('should call updateVectorInStore with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVectorId = 1;
      const mockVector = Array(128).fill(0.75);
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.updateVectorInStore.mockResolvedValue(true);
      
      const params = {
        id: mockId,
        vectorId: mockVectorId,
        vector: mockVector,
      };
      
      const result = await LlamaMobileVD.updateVectorInStore(params);
      
      expect(NativeModules.LlamaMobileVD.updateVectorInStore).toHaveBeenCalledWith(params);
      expect(result).toBe(true);
    });

    it('should call containsVectorInStore with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVectorId = 1;
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.containsVectorInStore.mockResolvedValue(true);
      
      const params = {
        id: mockId,
        vectorId: mockVectorId,
      };
      
      const result = await LlamaMobileVD.containsVectorInStore(params);
      
      expect(NativeModules.LlamaMobileVD.containsVectorInStore).toHaveBeenCalledWith(params);
      expect(result).toBe(true);
    });

    it('should call reserveVectorStore with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockCapacity = 100;
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.reserveVectorStore.mockResolvedValue();
      
      const params = {
        id: mockId,
        capacity: mockCapacity,
      };
      
      await LlamaMobileVD.reserveVectorStore(params);
      
      expect(NativeModules.LlamaMobileVD.reserveVectorStore).toHaveBeenCalledWith(params);
    });

    it('should call getVectorStoreDimension with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockDimension = 128;
      const mockResponse = { dimension: mockDimension };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getVectorStoreDimension.mockResolvedValue(mockResponse);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getVectorStoreDimension(params);
      
      expect(NativeModules.LlamaMobileVD.getVectorStoreDimension).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });

    it('should call getVectorStoreMetric with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockMetric = 'L2';
      const mockResponse = { metric: mockMetric };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getVectorStoreMetric.mockResolvedValue(mockResponse);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getVectorStoreMetric(params);
      
      expect(NativeModules.LlamaMobileVD.getVectorStoreMetric).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('Additional HNSWIndex methods', () => {
    it('should call searchHNSWIndex with efSearch parameter', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockQueryVector = Array(128).fill(0.5);
      const mockK = 5;
      const mockEfSearch = 100;
      const mockResults = [
        { index: 0, distance: 0.1 },
        { index: 1, distance: 0.2 },
        { index: 2, distance: 0.3 },
      ];
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.searchHNSWIndex.mockResolvedValue(mockResults);
      
      const params = {
        id: mockId,
        queryVector: mockQueryVector,
        k: mockK,
        efSearch: mockEfSearch,
      };
      
      const results = await LlamaMobileVD.searchHNSWIndex(params);
      
      expect(NativeModules.LlamaMobileVD.searchHNSWIndex).toHaveBeenCalledWith(params);
      expect(results).toEqual(mockResults);
    });

    it('should call setHNSWEfSearch with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockEfSearch = 100;
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.setHNSWEfSearch.mockResolvedValue();
      
      const params = {
        id: mockId,
        efSearch: mockEfSearch,
      };
      
      await LlamaMobileVD.setHNSWEfSearch(params);
      
      expect(NativeModules.LlamaMobileVD.setHNSWEfSearch).toHaveBeenCalledWith(params);
    });

    it('should call getHNSWEfSearch with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockEfSearch = 100;
      const mockResponse = { efSearch: mockEfSearch };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getHNSWEfSearch.mockResolvedValue(mockResponse);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getHNSWEfSearch(params);
      
      expect(NativeModules.LlamaMobileVD.getHNSWEfSearch).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });

    it('should call containsVectorInHNSW with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockVectorId = 1;
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.containsVectorInHNSW.mockResolvedValue(true);
      
      const params = {
        id: mockId,
        vectorId: mockVectorId,
      };
      
      const result = await LlamaMobileVD.containsVectorInHNSW(params);
      
      expect(NativeModules.LlamaMobileVD.containsVectorInHNSW).toHaveBeenCalledWith(params);
      expect(result).toBe(true);
    });

    it('should call getVectorFromHNSW with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockVectorId = 1;
      const mockVector = Array(128).fill(0.5);
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getVectorFromHNSW.mockResolvedValue(mockVector);
      
      const params = {
        id: mockId,
        vectorId: mockVectorId,
      };
      
      const result = await LlamaMobileVD.getVectorFromHNSW(params);
      
      expect(NativeModules.LlamaMobileVD.getVectorFromHNSW).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockVector);
    });

    it('should call getHNSWDimension with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockDimension = 128;
      const mockResponse = { dimension: mockDimension };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getHNSWDimension.mockResolvedValue(mockResponse);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getHNSWDimension(params);
      
      expect(NativeModules.LlamaMobileVD.getHNSWDimension).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });

    it('should call getHNSWCapacity with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockCapacity = 1000;
      const mockResponse = { capacity: mockCapacity };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getHNSWCapacity.mockResolvedValue(mockResponse);
      
      const params = { id: mockId };
      
      const result = await LlamaMobileVD.getHNSWCapacity(params);
      
      expect(NativeModules.LlamaMobileVD.getHNSWCapacity).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });

    it('should call saveHNSWIndex with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockPath = '/path/to/index';
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.saveHNSWIndex.mockResolvedValue(true);
      
      const params = {
        id: mockId,
        path: mockPath,
      };
      
      const result = await LlamaMobileVD.saveHNSWIndex(params);
      
      expect(NativeModules.LlamaMobileVD.saveHNSWIndex).toHaveBeenCalledWith(params);
      expect(result).toBe(true);
    });

    it('should call loadHNSWIndex with the correct parameters', async () => {
      const mockPath = '/path/to/index';
      const mockId = 'test-loaded-hnsw-index-id';
      const mockResponse = { id: mockId };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.loadHNSWIndex.mockResolvedValue(mockResponse);
      
      const params = { path: mockPath };
      
      const result = await LlamaMobileVD.loadHNSWIndex(params);
      
      expect(NativeModules.LlamaMobileVD.loadHNSWIndex).toHaveBeenCalledWith(params);
      expect(result).toEqual(mockResponse);
    });
  });

  describe('Version methods', () => {
    it('should call getVersion with the correct parameters', async () => {
      const mockVersion = '1.2.3';
      const mockResponse = { version: mockVersion };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getVersion.mockResolvedValue(mockResponse);
      
      const result = await LlamaMobileVD.getVersion();
      
      expect(NativeModules.LlamaMobileVD.getVersion).toHaveBeenCalled();
      expect(result).toEqual(mockResponse);
    });

    it('should call getVersionMajor with the correct parameters', async () => {
      const mockMajor = 1;
      const mockResponse = { major: mockMajor };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getVersionMajor.mockResolvedValue(mockResponse);
      
      const result = await LlamaMobileVD.getVersionMajor();
      
      expect(NativeModules.LlamaMobileVD.getVersionMajor).toHaveBeenCalled();
      expect(result).toEqual(mockResponse);
    });

    it('should call getVersionMinor with the correct parameters', async () => {
      const mockMinor = 2;
      const mockResponse = { minor: mockMinor };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getVersionMinor.mockResolvedValue(mockResponse);
      
      const result = await LlamaMobileVD.getVersionMinor();
      
      expect(NativeModules.LlamaMobileVD.getVersionMinor).toHaveBeenCalled();
      expect(result).toEqual(mockResponse);
    });

    it('should call getVersionPatch with the correct parameters', async () => {
      const mockPatch = 3;
      const mockResponse = { patch: mockPatch };
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.getVersionPatch.mockResolvedValue(mockResponse);
      
      const result = await LlamaMobileVD.getVersionPatch();
      
      expect(NativeModules.LlamaMobileVD.getVersionPatch).toHaveBeenCalled();
      expect(result).toEqual(mockResponse);
    });
  });
});
