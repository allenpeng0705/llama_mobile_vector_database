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
      searchVectorStore: jest.fn(),
      searchHNSWIndex: jest.fn(),
      countVectorStore: jest.fn(),
      countHNSWIndex: jest.fn(),
      clearVectorStore: jest.fn(),
      clearHNSWIndex: jest.fn(),
      releaseVectorStore: jest.fn(),
      releaseHNSWIndex: jest.fn(),
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
    it('should call the native module with the correct parameters', async () => {
      const mockId = 'test-vector-store-id';
      const mockVector = Array(128).fill(0.5);
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.addVectorToStore.mockResolvedValue();
      
      const params = {
        id: mockId,
        vector: mockVector,
      };
      
      await LlamaMobileVD.addVectorToStore(params);
      
      expect(NativeModules.LlamaMobileVD.addVectorToStore).toHaveBeenCalledWith(params);
    });

    it('should call the native module with an optional label', async () => {
      const mockId = 'test-vector-store-id';
      const mockVector = Array(128).fill(0.5);
      const mockLabel = 'test-label';
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.addVectorToStore.mockResolvedValue();
      
      const params = {
        id: mockId,
        vector: mockVector,
        label: mockLabel,
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
    it('should call addVectorToHNSW with the correct parameters', async () => {
      const mockId = 'test-hnsw-index-id';
      const mockVector = Array(128).fill(0.5);
      
      // Mock the native module response
      const { NativeModules } = require('react-native');
      NativeModules.LlamaMobileVD.addVectorToHNSW.mockResolvedValue();
      
      const params = {
        id: mockId,
        vector: mockVector,
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
});
