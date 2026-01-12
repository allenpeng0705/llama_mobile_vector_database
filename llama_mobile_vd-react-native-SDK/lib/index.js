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
   * @param {number} params.vectorId - The ID to associate with the vector
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
   * @param {number} params.vectorId - The ID to associate with the vector
   * @returns {Promise<void>} Promise that resolves when the vector is added
   */
  addVectorToHNSW(params) {
    return LlamaMobileVD.addVectorToHNSW(params);
  },

  /**
   * Remove a vector from a VectorStore by ID
   * @param {Object} params - Parameters for removing the vector
   * @param {string} params.id - The ID of the VectorStore
   * @param {number} params.vectorId - The ID of the vector to remove
   * @returns {Promise<boolean>} Promise with true if the vector was removed, false otherwise
   */
  removeVectorFromStore(params) {
    return LlamaMobileVD.removeVectorFromStore(params);
  },

  /**
   * Get a vector from a VectorStore by ID
   * @param {Object} params - Parameters for getting the vector
   * @param {string} params.id - The ID of the VectorStore
   * @param {number} params.vectorId - The ID of the vector to get
   * @returns {Promise<number[]>} Promise with the vector if found, null otherwise
   */
  getVectorFromStore(params) {
    return LlamaMobileVD.getVectorFromStore(params);
  },

  /**
   * Update a vector in a VectorStore by ID
   * @param {Object} params - Parameters for updating the vector
   * @param {string} params.id - The ID of the VectorStore
   * @param {number} params.vectorId - The ID of the vector to update
   * @param {number[]} params.vector - The new vector data
   * @returns {Promise<boolean>} Promise with true if the vector was updated, false otherwise
   */
  updateVectorInStore(params) {
    return LlamaMobileVD.updateVectorInStore(params);
  },

  /**
   * Check if a VectorStore contains a vector with the given ID
   * @param {Object} params - Parameters for checking the vector
   * @param {string} params.id - The ID of the VectorStore
   * @param {number} params.vectorId - The ID of the vector to check
   * @returns {Promise<boolean>} Promise with true if the vector exists, false otherwise
   */
  containsVectorInStore(params) {
    return LlamaMobileVD.containsVectorInStore(params);
  },

  /**
   * Reserve space for vectors in a VectorStore
   * @param {Object} params - Parameters for reserving space
   * @param {string} params.id - The ID of the VectorStore
   * @param {number} params.capacity - The number of vectors to reserve space for
   * @returns {Promise<void>} Promise that resolves when the space is reserved
   */
  reserveVectorStore(params) {
    return LlamaMobileVD.reserveVectorStore(params);
  },

  /**
   * Get the dimension of vectors in a VectorStore
   * @param {Object} params - Parameters for getting the dimension
   * @param {string} params.id - The ID of the VectorStore
   * @returns {Promise<Object>} Promise with the dimension of the vectors
   */
  getVectorStoreDimension(params) {
    return LlamaMobileVD.getVectorStoreDimension(params);
  },

  /**
   * Get the distance metric used by a VectorStore
   * @param {Object} params - Parameters for getting the metric
   * @param {string} params.id - The ID of the VectorStore
   * @returns {Promise<Object>} Promise with the distance metric
   */
  getVectorStoreMetric(params) {
    return LlamaMobileVD.getVectorStoreMetric(params);
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
   * Set the efSearch parameter for an HNSWIndex
   * @param {Object} params - Parameters for setting efSearch
   * @param {string} params.id - The ID of the HNSWIndex
   * @param {number} params.efSearch - The new efSearch value
   * @returns {Promise<void>} Promise that resolves when efSearch is set
   */
  setHNSWEfSearch(params) {
    return LlamaMobileVD.setHNSWEfSearch(params);
  },

  /**
   * Get the current efSearch parameter for an HNSWIndex
   * @param {Object} params - Parameters for getting efSearch
   * @param {string} params.id - The ID of the HNSWIndex
   * @returns {Promise<Object>} Promise with the current efSearch value
   */
  getHNSWEfSearch(params) {
    return LlamaMobileVD.getHNSWEfSearch(params);
  },

  /**
   * Check if an HNSWIndex contains a vector with the given ID
   * @param {Object} params - Parameters for checking the vector
   * @param {string} params.id - The ID of the HNSWIndex
   * @param {number} params.vectorId - The ID of the vector to check
   * @returns {Promise<boolean>} Promise with true if the vector exists, false otherwise
   */
  containsVectorInHNSW(params) {
    return LlamaMobileVD.containsVectorInHNSW(params);
  },

  /**
   * Get a vector from an HNSWIndex by ID
   * @param {Object} params - Parameters for getting the vector
   * @param {string} params.id - The ID of the HNSWIndex
   * @param {number} params.vectorId - The ID of the vector to get
   * @returns {Promise<number[]>} Promise with the vector if found, null otherwise
   */
  getVectorFromHNSW(params) {
    return LlamaMobileVD.getVectorFromHNSW(params);
  },

  /**
   * Get the dimension of vectors in an HNSWIndex
   * @param {Object} params - Parameters for getting the dimension
   * @param {string} params.id - The ID of the HNSWIndex
   * @returns {Promise<Object>} Promise with the dimension of the vectors
   */
  getHNSWDimension(params) {
    return LlamaMobileVD.getHNSWDimension(params);
  },

  /**
   * Get the capacity of an HNSWIndex
   * @param {Object} params - Parameters for getting the capacity
   * @param {string} params.id - The ID of the HNSWIndex
   * @returns {Promise<Object>} Promise with the capacity of the index
   */
  getHNSWCapacity(params) {
    return LlamaMobileVD.getHNSWCapacity(params);
  },

  /**
   * Save an HNSWIndex to a file
   * @param {Object} params - Parameters for saving the index
   * @param {string} params.id - The ID of the HNSWIndex
   * @param {string} params.path - The path where the index should be saved
   * @returns {Promise<boolean>} Promise with true if the index was saved successfully, false otherwise
   */
  saveHNSWIndex(params) {
    return LlamaMobileVD.saveHNSWIndex(params);
  },

  /**
   * Load an HNSWIndex from a file
   * @param {Object} params - Parameters for loading the index
   * @param {string} params.path - The path to the file containing the saved index
   * @returns {Promise<Object>} Promise with the ID of the loaded HNSWIndex
   */
  loadHNSWIndex(params) {
    return LlamaMobileVD.loadHNSWIndex(params);
  },

  /**
   * Search for vectors in an HNSWIndex
   * @param {Object} params - Parameters for searching the HNSWIndex
   * @param {string} params.id - The ID of the HNSWIndex
   * @param {number[]} params.queryVector - The query vector
   * @param {number} params.k - The number of nearest neighbors to return
   * @param {number} [params.efSearch] - The efSearch value to use for this search
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
  },

  /**
   * Get the version of the LlamaMobileVD SDK
   * @returns {Promise<Object>} Promise with the version information
   */
  getVersion() {
    return LlamaMobileVD.getVersion();
  },

  /**
   * Get the major version component
   * @returns {Promise<Object>} Promise with the major version component
   */
  getVersionMajor() {
    return LlamaMobileVD.getVersionMajor();
  },

  /**
   * Get the minor version component
   * @returns {Promise<Object>} Promise with the minor version component
   */
  getVersionMinor() {
    return LlamaMobileVD.getVersionMinor();
  },

  /**
   * Get the patch version component
   * @returns {Promise<Object>} Promise with the patch version component
   */
  getVersionPatch() {
    return LlamaMobileVD.getVersionPatch();
  },

  /**
   * Open an MMapVectorStore
   * @param {Object} params - Parameters for opening the MMapVectorStore
   * @param {string} params.path - The path to the MMapVectorStore file
   * @returns {Promise<Object>} Promise with the ID of the opened MMapVectorStore
   */
  openMMapVectorStore(params) {
    return LlamaMobileVD.openMMapVectorStore(params);
  },

  /**
   * Search for vectors in an MMapVectorStore
   * @param {Object} params - Parameters for searching the MMapVectorStore
   * @param {string} params.id - The ID of the MMapVectorStore
   * @param {number[]} params.queryVector - The query vector
   * @param {number} params.k - The number of nearest neighbors to return
   * @returns {Promise<Object[]>} Promise with the search results
   */
  searchMMapVectorStore(params) {
    return LlamaMobileVD.searchMMapVectorStore(params);
  },

  /**
   * Get the number of vectors in an MMapVectorStore
   * @param {Object} params - Parameters for counting vectors
   * @param {string} params.id - The ID of the MMapVectorStore
   * @returns {Promise<Object>} Promise with the count of vectors
   */
  getMMapVectorStoreCount(params) {
    return LlamaMobileVD.getMMapVectorStoreCount(params);
  },

  /**
   * Get the dimension of vectors in an MMapVectorStore
   * @param {Object} params - Parameters for getting the dimension
   * @param {string} params.id - The ID of the MMapVectorStore
   * @returns {Promise<Object>} Promise with the dimension of the vectors
   */
  getMMapVectorStoreDimension(params) {
    return LlamaMobileVD.getMMapVectorStoreDimension(params);
  },

  /**
   * Get the distance metric used by an MMapVectorStore
   * @param {Object} params - Parameters for getting the metric
   * @param {string} params.id - The ID of the MMapVectorStore
   * @returns {Promise<Object>} Promise with the distance metric
   */
  getMMapVectorStoreMetric(params) {
    return LlamaMobileVD.getMMapVectorStoreMetric(params);
  },

  /**
   * Release resources associated with an MMapVectorStore
   * @param {Object} params - Parameters for releasing the MMapVectorStore
   * @param {string} params.id - The ID of the MMapVectorStore
   * @returns {Promise<void>} Promise that resolves when the MMapVectorStore is released
   */
  releaseMMapVectorStore(params) {
    return LlamaMobileVD.releaseMMapVectorStore(params);
  }
};

export default LlamaMobileVDAPI;