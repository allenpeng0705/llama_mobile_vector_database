/**
 * A high-performance vector database for React Native applications using LlamaMobileVD
 */

import { NativeModules } from 'react-native';

const { LlamaMobileVD } = NativeModules;

/**
 * Distance metrics supported by the vector database
 */
export const DistanceMetric = {
  /**
   * Euclidean distance (L2)
   */
  L2: 'L2',
  /**
   * Cosine similarity (converted to distance)
   */
  COSINE: 'COSINE',
  /**
   * Dot product (converted to distance)
   */
  DOT: 'DOT'
};

/**
 * LlamaMobileVD API implementation
 */
const LlamaMobileVDAPI = {
  /**
   * Create a new VectorStore
   * @param {Object} options - Options for creating the VectorStore
   * @param {number} options.dimension - The dimension of the vectors to be stored
   * @param {DistanceMetric} options.metric - The distance metric to use
   * @returns {Promise<Object>} Promise with the ID of the created VectorStore
   */
  createVectorStore(options) {
    return LlamaMobileVD.createVectorStore(options);
  },

  /**
   * Create a new HNSWIndex
   * @param {Object} options - Options for creating the HNSWIndex
   * @param {number} options.dimension - The dimension of the vectors to be indexed
   * @param {DistanceMetric} options.metric - The distance metric to use
   * @param {number} options.m - The maximum number of connections per node
   * @param {number} options.efConstruction - The size of the dynamic list used during construction
   * @returns {Promise<Object>} Promise with the ID of the created HNSWIndex
   */
  createHNSWIndex(options) {
    return LlamaMobileVD.createHNSWIndex(options);
  },

  /**
   * Add a vector to a VectorStore
   * @param {Object} params - Parameters for adding the vector
   * @param {string} params.id - The ID of the VectorStore
   * @param {number[]} params.vector - The vector to add
   * @param {string} [params.label] - The label for the vector (optional)
   * @returns {Promise<void>} Promise that resolves when the vector is added
   */
  addVectorToStore(params) {
    return LlamaMobileVD.addVectorToStore(params);
  },

  /**
   * Add a vector to an HNSWIndex
   * @param {Object} params - Parameters for adding the vector
   * @param {string} params.id - The ID of the HNSWIndex
   * @param {number[]} params.vector - The vector to add
   * @param {string} [params.label] - The label for the vector (optional)
   * @returns {Promise<void>} Promise that resolves when the vector is added
   */
  addVectorToHNSW(params) {
    return LlamaMobileVD.addVectorToHNSW(params);
  },

  /**
   * Search for vectors in a VectorStore
   * @param {Object} params - Parameters for searching the VectorStore
   * @param {string} params.id - The ID of the VectorStore
   * @param {number[]} params.queryVector - The query vector
   * @param {number} params.k - The number of nearest neighbors to return
   * @returns {Promise<Object[]>} Promise with the search results
   */
  searchVectorStore(params) {
    return LlamaMobileVD.searchVectorStore(params);
  },

  /**
   * Search for vectors in an HNSWIndex
   * @param {Object} params - Parameters for searching the HNSWIndex
   * @param {string} params.id - The ID of the HNSWIndex
   * @param {number[]} params.queryVector - The query vector
   * @param {number} params.k - The number of nearest neighbors to return
   * @returns {Promise<Object[]>} Promise with the search results
   */
  searchHNSWIndex(params) {
    return LlamaMobileVD.searchHNSWIndex(params);
  },

  /**
   * Count the number of vectors in a VectorStore
   * @param {Object} params - Parameters for counting vectors
   * @param {string} params.id - The ID of the VectorStore
   * @returns {Promise<Object>} Promise with the count of vectors
   */
  countVectorStore(params) {
    return LlamaMobileVD.countVectorStore(params);
  },

  /**
   * Count the number of vectors in an HNSWIndex
   * @param {Object} params - Parameters for counting vectors
   * @param {string} params.id - The ID of the HNSWIndex
   * @returns {Promise<Object>} Promise with the count of vectors
   */
  countHNSWIndex(params) {
    return LlamaMobileVD.countHNSWIndex(params);
  },

  /**
   * Clear all vectors from a VectorStore
   * @param {Object} params - Parameters for clearing the VectorStore
   * @param {string} params.id - The ID of the VectorStore
   * @returns {Promise<void>} Promise that resolves when the VectorStore is cleared
   */
  clearVectorStore(params) {
    return LlamaMobileVD.clearVectorStore(params);
  },

  /**
   * Clear all vectors from an HNSWIndex
   * @param {Object} params - Parameters for clearing the HNSWIndex
   * @param {string} params.id - The ID of the HNSWIndex
   * @returns {Promise<void>} Promise that resolves when the HNSWIndex is cleared
   */
  clearHNSWIndex(params) {
    return LlamaMobileVD.clearHNSWIndex(params);
  },

  /**
   * Release resources associated with a VectorStore
   * @param {Object} params - Parameters for releasing the VectorStore
   * @param {string} params.id - The ID of the VectorStore
   * @returns {Promise<void>} Promise that resolves when the VectorStore is released
   */
  releaseVectorStore(params) {
    return LlamaMobileVD.releaseVectorStore(params);
  },

  /**
   * Release resources associated with an HNSWIndex
   * @param {Object} params - Parameters for releasing the HNSWIndex
   * @param {string} params.id - The ID of the HNSWIndex
   * @returns {Promise<void>} Promise that resolves when the HNSWIndex is released
   */
  releaseHNSWIndex(params) {
    return LlamaMobileVD.releaseHNSWIndex(params);
  }
};

export default LlamaMobileVDAPI;