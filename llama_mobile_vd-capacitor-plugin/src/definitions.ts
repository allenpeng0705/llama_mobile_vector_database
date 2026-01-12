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
 * Parameters for vector ID operations
 */
export interface VectorIdParams {
  /**
   * The ID of the store or index
   */
  id: string;
  /**
   * The ID of the vector
   */
  vectorId: number;
}

/**
 * Parameters for updating a vector
 */
export interface UpdateVectorParams {
  /**
   * The ID of the store or index
   */
  id: string;
  /**
   * The ID of the vector to update
   */
  vectorId: number;
  /**
   * The new vector data
   */
  vector: number[];
}

/**
 * Parameters for reserving space in a vector store
 */
export interface ReserveParams {
  /**
   * The ID of the vector store
   */
  id: string;
  /**
   * The number of vectors to reserve space for
   */
  capacity: number;
}

/**
 * Parameters for setting efSearch in an HNSW index
 */
export interface SetEfSearchParams {
  /**
   * The ID of the HNSW index
   */
  id: string;
  /**
   * The new efSearch value
   */
  efSearch: number;
}

/**
 * Parameters for saving an HNSW index
 */
export interface SaveHNSWParams {
  /**
   * The ID of the HNSW index
   */
  id: string;
  /**
   * The path to save the index to
   */
  path: string;
}

/**
   * Parameters for loading an HNSW index
   */
  export interface LoadHNSWParams {
    /**
     * The path to load the index from
     */
    path: string;
  }

  /**
   * Parameters for opening an MMapVectorStore
   */
  export interface OpenMMapParams {
    /**
     * The path to open the vector store from
     */
    path: string;
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
 * Result containing a vector
 */
export interface VectorResult {
  /**
   * The vector data
   */
  vector: number[];
}

/**
 * Result containing a dimension value
 */
export interface DimensionResult {
  /**
   * The dimension of vectors
   */
  dimension: number;
}

/**
 * Result containing a metric value
 */
export interface MetricResult {
  /**
   * The distance metric used
   */
  metric: string;
}

/**
 * Result containing a capacity value
 */
export interface CapacityResult {
  /**
   * The capacity of the index
   */
  capacity: number;
}

/**
 * Result containing an efSearch value
 */
export interface EfSearchResult {
  /**
   * The efSearch parameter value
   */
  efSearch: number;
}

/**
 * Result containing a boolean value
 */
export interface BooleanResult {
  /**
   * Boolean result value
   */
  result: boolean;
}

/**
 * Result containing version information
 */
export interface VersionResult {
  /**
   * The version string
   */
  version: string;
}

/**
 * Result containing a version component value
 */
export interface VersionComponentResult {
  /**
   * The version component value
   */
  value: number;
}

/**
 * LlamaMobileVD Capacitor Plugin API
 */
export interface LlamaMobileVDPlugin {
  // MARK: VectorStore Methods
  /**
   * Create a new vector store
   *
   * @param options Vector store creation options
   * @returns Promise with the created store ID
   */
  createVectorStore(options: VectorStoreOptions): Promise<CreateResult>;

  /**
   * Add a vector to a vector store
   *
   * @param params Parameters for adding a vector
   * @returns Promise that resolves when the vector is added
   */
  addVectorToStore(params: AddVectorParams): Promise<void>;

  /**
   * Remove a vector from a vector store
   *
   * @param params Parameters for removing a vector
   * @returns Promise with the result of the removal
   */
  removeVectorFromStore(params: VectorIdParams): Promise<BooleanResult>;

  /**
   * Get a vector from a vector store
   *
   * @param params Parameters for getting a vector
   * @returns Promise with the vector if found
   */
  getVectorFromStore(params: VectorIdParams): Promise<VectorResult | null>;

  /**
   * Update a vector in a vector store
   *
   * @param params Parameters for updating a vector
   * @returns Promise with the result of the update
   */
  updateVectorInStore(params: UpdateVectorParams): Promise<BooleanResult>;

  /**
   * Check if a vector exists in a vector store
   *
   * @param params Parameters for checking a vector
   * @returns Promise with the result of the check
   */
  containsVectorInStore(params: VectorIdParams): Promise<BooleanResult>;

  /**
   * Reserve space for vectors in a vector store
   *
   * @param params Parameters for reserving space
   * @returns Promise that resolves when space is reserved
   */
  reserveVectorStore(params: ReserveParams): Promise<void>;

  /**
   * Get the dimension of vectors in a vector store
   *
   * @param params Parameters for getting the dimension
   * @returns Promise with the dimension of vectors
   */
  getVectorStoreDimension(params: CountParams): Promise<DimensionResult>;

  /**
   * Get the distance metric used by a vector store
   *
   * @param params Parameters for getting the metric
   * @returns Promise with the distance metric
   */
  getVectorStoreMetric(params: CountParams): Promise<MetricResult>;

  /**
   * Search for nearest neighbors in a vector store
   *
   * @param params Parameters for searching
   * @returns Promise with search results
   */
  searchVectorStore(params: VectorStoreSearchParams): Promise<SearchResultList>;

  /**
   * Get the number of vectors in a vector store
   *
   * @param params Parameters for getting count
   * @returns Promise with the count of vectors
   */
  getVectorStoreCount(params: CountParams): Promise<CountResult>;

  /**
   * Clear all vectors from a vector store
   *
   * @param params Parameters for clearing
   * @returns Promise that resolves when the store is cleared
   */
  clearVectorStore(params: ClearParams): Promise<void>;

  /**
   * Release a vector store and free resources
   *
   * @param params Parameters for releasing
   * @returns Promise that resolves when the store is released
   */
  releaseVectorStore(params: ReleaseParams): Promise<void>;

  // MARK: HNSWIndex Methods
  /**
   * Create a new HNSW index
   *
   * @param options HNSW index creation options
   * @returns Promise with the created index ID
   */
  createHNSWIndex(options: HNSWIndexOptions): Promise<CreateResult>;

  /**
   * Add a vector to an HNSW index
   *
   * @param params Parameters for adding a vector
   * @returns Promise that resolves when the vector is added
   */
  addVectorToIndex(params: AddVectorParams): Promise<void>;

  /**
   * Search for nearest neighbors in an HNSW index
   *
   * @param params Parameters for searching
   * @returns Promise with search results
   */
  searchHNSWIndex(params: HNSWIndexSearchParams): Promise<SearchResultList>;

  /**
   * Set the efSearch parameter for an HNSW index
   *
   * @param params Parameters for setting efSearch
   * @returns Promise that resolves when efSearch is set
   */
  setHNSWEfSearch(params: SetEfSearchParams): Promise<void>;

  /**
   * Get the efSearch parameter for an HNSW index
   *
   * @param params Parameters for getting efSearch
   * @returns Promise with the efSearch parameter
   */
  getHNSWEfSearch(params: CountParams): Promise<EfSearchResult>;

  /**
   * Check if a vector exists in an HNSW index
   *
   * @param params Parameters for checking a vector
   * @returns Promise with the result of the check
   */
  containsVectorInHNSW(params: VectorIdParams): Promise<BooleanResult>;

  /**
   * Get a vector from an HNSW index
   *
   * @param params Parameters for getting a vector
   * @returns Promise with the vector if found
   */
  getVectorFromHNSW(params: VectorIdParams): Promise<VectorResult | null>;

  /**
   * Get the dimension of vectors in an HNSW index
   *
   * @param params Parameters for getting the dimension
   * @returns Promise with the dimension of vectors
   */
  getHNSWDimension(params: CountParams): Promise<DimensionResult>;

  /**
   * Get the capacity of an HNSW index
   *
   * @param params Parameters for getting the capacity
   * @returns Promise with the capacity of the index
   */
  getHNSWCapacity(params: CountParams): Promise<CapacityResult>;

  /**
   * Save an HNSW index to a file
   *
   * @param params Parameters for saving the index
   * @returns Promise with the result of the save operation
   */
  saveHNSWIndex(params: SaveHNSWParams): Promise<BooleanResult>;

  /**
   * Load an HNSW index from a file
   *
   * @param params Parameters for loading the index
   * @returns Promise with the loaded index ID
   */
  loadHNSWIndex(params: LoadHNSWParams): Promise<CreateResult>;

  /**
   * Get the number of vectors in an HNSW index
   *
   * @param params Parameters for getting count
   * @returns Promise with the count of vectors
   */
  getHNSWIndexCount(params: CountParams): Promise<CountResult>;

  /**
   * Clear all vectors from an HNSW index
   *
   * @param params Parameters for clearing
   * @returns Promise that resolves when the index is cleared
   */
  clearHNSWIndex(params: ClearParams): Promise<void>;

  /**
   * Release an HNSW index and free resources
   *
   * @param params Parameters for releasing
   * @returns Promise that resolves when the index is released
   */
  releaseHNSWIndex(params: ReleaseParams): Promise<void>;

  // MARK: MMapVectorStore Methods
  /**
   * Open an existing MMapVectorStore from a file
   *
   * @param params Parameters for opening the store
   * @returns Promise with the opened store ID
   */
  openMMapVectorStore(params: OpenMMapParams): Promise<CreateResult>;

  /**
   * Search for nearest neighbors in an MMapVectorStore
   *
   * @param params Parameters for searching
   * @returns Promise with search results
   */
  searchMMapVectorStore(params: VectorStoreSearchParams): Promise<SearchResultList>;

  /**
   * Get the number of vectors in an MMapVectorStore
   *
   * @param params Parameters for getting count
   * @returns Promise with the count of vectors
   */
  getMMapVectorStoreCount(params: CountParams): Promise<CountResult>;

  /**
   * Get the dimension of vectors in an MMapVectorStore
   *
   * @param params Parameters for getting the dimension
   * @returns Promise with the dimension of vectors
   */
  getMMapVectorStoreDimension(params: CountParams): Promise<DimensionResult>;

  /**
   * Get the distance metric used by an MMapVectorStore
   *
   * @param params Parameters for getting the metric
   * @returns Promise with the distance metric
   */
  getMMapVectorStoreMetric(params: CountParams): Promise<MetricResult>;

  /**
   * Release an MMapVectorStore and free resources
   *
   * @param params Parameters for releasing
   * @returns Promise that resolves when the store is released
   */
  releaseMMapVectorStore(params: ReleaseParams): Promise<void>;

  // MARK: Version Methods
  /**
   * Get the version of the LlamaMobileVD SDK
   *
   * @returns Promise with the version string
   */
  getVersion(): Promise<VersionResult>;

  /**
   * Get the major version component
   *
   * @returns Promise with the major version component
   */
  getVersionMajor(): Promise<VersionComponentResult>;

  /**
   * Get the minor version component
   *
   * @returns Promise with the minor version component
   */
  getVersionMinor(): Promise<VersionComponentResult>;

  /**
   * Get the patch version component
   *
   * @returns Promise with the patch version component
   */
  getVersionPatch(): Promise<VersionComponentResult>;
}