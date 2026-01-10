/**
 * LlamaMobileVD Capacitor Plugin
 * A high-performance vector database for mobile applications
 */

/**
 * Distance metrics supported by LlamaMobileVD
 */
export enum DistanceMetric {
  /**
   * Euclidean distance (L2 norm)
   */
  L2 = 'L2',
  /**
   * Cosine similarity
   */
  COSINE = 'COSINE',
  /**
   * Dot product
   */
  DOT = 'DOT',
}

/**
 * A result from a vector search operation
 */
export interface SearchResult {
  /**
   * The ID of the vector
   */
  id: number;
  /**
   * The distance between the query vector and the result vector
   */
  distance: number;
}

/**
 * Options for creating a VectorStore
 */
export interface VectorStoreOptions {
  /**
   * The dimension of the vectors
   */
  dimension: number;
  /**
   * The distance metric to use for similarity search
   */
  metric: DistanceMetric;
}

/**
 * Options for creating an HNSWIndex
 */
export interface HNSWIndexOptions {
  /**
   * The dimension of the vectors
   */
  dimension: number;
  /**
   * The distance metric to use for similarity search
   */
  metric: DistanceMetric;
  /**
   * The maximum number of connections per node
   */
  m?: number;
  /**
   * The size of the dynamic list for candidate selection during construction
   */
  efConstruction?: number;
}

/**
 * Parameters for adding a vector to a store or index
 */
export interface AddVectorParams {
  /**
   * The ID of the store or index
   */
  id: string;
  /**
   * The vector to add
   */
  vector: number[];
  /**
   * The ID to associate with the vector
   */
  vectorId: number;
}

/**
 * Parameters for searching a VectorStore
 */
export interface VectorStoreSearchParams {
  /**
   * The ID of the vector store
   */
  id: string;
  /**
   * The query vector
   */
  queryVector: number[];
  /**
   * The number of nearest neighbors to return
   */
  k: number;
}

/**
 * Parameters for searching an HNSWIndex
 */
export interface HNSWIndexSearchParams {
  /**
   * The ID of the HNSW index
   */
  id: string;
  /**
   * The query vector
   */
  queryVector: number[];
  /**
   * The number of nearest neighbors to return
   */
  k: number;
  /**
   * The size of the dynamic list for candidate selection during search
   */
  efSearch?: number;
}

/**
 * Parameters for getting the count of vectors
 */
export interface CountParams {
  /**
   * The ID of the store or index
   */
  id: string;
}

/**
 * Parameters for clearing vectors
 */
export interface ClearParams {
  /**
   * The ID of the store or index
   */
  id: string;
}

/**
 * Parameters for releasing a store or index
 */
export interface ReleaseParams {
  /**
   * The ID of the store or index
   */
  id: string;
}

/**
 * Result containing the ID of a newly created store or index
 */
export interface CreateResult {
  /**
   * The ID of the created store or index
   */
  id: string;
}

/**
 * Result containing search results
 */
export interface SearchResultList {
  /**
   * Array of search results sorted by distance
   */
  results: SearchResult[];
}

/**
 * Result containing the count of vectors
 */
export interface CountResult {
  /**
   * The number of vectors in the store or index
   */
  count: number;
}

/**
 * LlamaMobileVD Capacitor Plugin API
 */
export interface LlamaMobileVDPlugin {
  /**
   * Create a new vector store
   *
   * @param options Vector store creation options
   * @returns Promise with the created store ID
   */
  createVectorStore(options: VectorStoreOptions): Promise<CreateResult>;

  /**
   * Create a new HNSW index
   *
   * @param options HNSW index creation options
   * @returns Promise with the created index ID
   */
  createHNSWIndex(options: HNSWIndexOptions): Promise<CreateResult>;

  /**
   * Add a vector to a vector store
   *
   * @param params Parameters for adding a vector
   * @returns Promise that resolves when the vector is added
   */
  addVectorToStore(params: AddVectorParams): Promise<void>;

  /**
   * Add a vector to an HNSW index
   *
   * @param params Parameters for adding a vector
   * @returns Promise that resolves when the vector is added
   */
  addVectorToIndex(params: AddVectorParams): Promise<void>;

  /**
   * Search for nearest neighbors in a vector store
   *
   * @param params Parameters for searching
   * @returns Promise with search results
   */
  searchVectorStore(params: VectorStoreSearchParams): Promise<SearchResultList>;

  /**
   * Search for nearest neighbors in an HNSW index
   *
   * @param params Parameters for searching
   * @returns Promise with search results
   */
  searchHNSWIndex(params: HNSWIndexSearchParams): Promise<SearchResultList>;

  /**
   * Get the number of vectors in a vector store
   *
   * @param params Parameters for getting count
   * @returns Promise with the count of vectors
   */
  getVectorStoreCount(params: CountParams): Promise<CountResult>;

  /**
   * Get the number of vectors in an HNSW index
   *
   * @param params Parameters for getting count
   * @returns Promise with the count of vectors
   */
  getHNSWIndexCount(params: CountParams): Promise<CountResult>;

  /**
   * Clear all vectors from a vector store
   *
   * @param params Parameters for clearing
   * @returns Promise that resolves when the store is cleared
   */
  clearVectorStore(params: ClearParams): Promise<void>;

  /**
   * Clear all vectors from an HNSW index
   *
   * @param params Parameters for clearing
   * @returns Promise that resolves when the index is cleared
   */
  clearHNSWIndex(params: ClearParams): Promise<void>;

  /**
   * Release a vector store and free resources
   *
   * @param params Parameters for releasing
   * @returns Promise that resolves when the store is released
   */
  releaseVectorStore(params: ReleaseParams): Promise<void>;

  /**
   * Release an HNSW index and free resources
   *
   * @param params Parameters for releasing
   * @returns Promise that resolves when the index is released
   */
  releaseHNSWIndex(params: ReleaseParams): Promise<void>;
}