/**
 * A high-performance vector database for React Native applications using LlamaMobileVD
 */

declare module 'llama-mobile-vd' {
  /**
   * Distance metrics supported by the vector database
   */
  export enum DistanceMetric {
    /**
     * Euclidean distance (L2)
     */
    L2 = 'L2',
    /**
     * Cosine similarity (converted to distance)
     */
    COSINE = 'COSINE',
    /**
     * Dot product (converted to distance)
     */
    DOT = 'DOT'
  }

  /**
   * Options for creating a VectorStore
   */
  export interface VectorStoreOptions {
    /**
     * The dimension of the vectors to be stored
     */
    dimension: number;
    /**
     * The distance metric to use for similarity calculations
     */
    metric: DistanceMetric;
  }

  /**
   * Options for creating an HNSW Index
   */
  export interface HNSWIndexOptions {
    /**
     * The dimension of the vectors to be indexed
     */
    dimension: number;
    /**
     * The distance metric to use for similarity calculations
     */
    metric: DistanceMetric;
    /**
     * The maximum number of connections per node in the HNSW graph
     */
    m: number;
    /**
     * The size of the dynamic list used during construction
     */
    efConstruction: number;
  }

  /**
   * Parameters for adding a vector to a VectorStore
   */
  export interface AddVectorParams {
    /**
     * The ID of the VectorStore or HNSWIndex
     */
    id: string;
    /**
     * The vector to add
     */
    vector: number[];
    /**
     * The label (optional) for the vector
     */
    label?: string;
  }

  /**
   * Parameters for searching a VectorStore or HNSWIndex
   */
  export interface SearchParams {
    /**
     * The ID of the VectorStore or HNSWIndex
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
   * Parameters for releasing a VectorStore or HNSWIndex
   */
  export interface ReleaseParams {
    /**
     * The ID of the VectorStore or HNSWIndex to release
     */
    id: string;
  }

  /**
   * Parameters for counting items in a VectorStore or HNSWIndex
   */
  export interface CountParams {
    /**
     * The ID of the VectorStore or HNSWIndex
     */
    id: string;
  }

  /**
   * Parameters for clearing items from a VectorStore or HNSWIndex
   */
  export interface ClearParams {
    /**
     * The ID of the VectorStore or HNSWIndex to clear
     */
    id: string;
  }

  /**
   * Result of creating a VectorStore or HNSWIndex
   */
  export interface CreateResult {
    /**
     * The ID of the created VectorStore or HNSWIndex
     */
    id: string;
  }

  /**
   * Result of a search operation
   */
  export interface SearchResult {
    /**
     * The index of the matched vector
     */
    index: number;
    /**
     * The label of the matched vector (if any)
     */
    label?: string;
    /**
     * The distance to the query vector
     */
    distance: number;
  }

  /**
   * Result of a count operation
   */
  export interface CountResult {
    /**
     * The number of vectors in the store or index
     */
    count: number;
  }

  /**
   * LlamaMobileVD API
   */
  /**
   * Parameters for opening an MMapVectorStore
   */
  export interface OpenMMapParams {
    /**
     * The path to the MMapVectorStore file
     */
    path: string;
  }

  export interface LlamaMobileVD {
    /**
     * Create a new VectorStore
     * @param options Options for creating the VectorStore
     * @returns Promise with the ID of the created VectorStore
     */
    createVectorStore(options: VectorStoreOptions): Promise<CreateResult>;

    /**
     * Create a new HNSWIndex
     * @param options Options for creating the HNSWIndex
     * @returns Promise with the ID of the created HNSWIndex
     */
    createHNSWIndex(options: HNSWIndexOptions): Promise<CreateResult>;

    /**
     * Add a vector to a VectorStore
     * @param params Parameters for adding the vector
     * @returns Promise that resolves when the vector is added
     */
    addVectorToStore(params: AddVectorParams): Promise<void>;

    /**
     * Add a vector to an HNSWIndex
     * @param params Parameters for adding the vector
     * @returns Promise that resolves when the vector is added
     */
    addVectorToHNSW(params: AddVectorParams): Promise<void>;

    /**
     * Search for vectors in a VectorStore
     * @param params Parameters for searching the VectorStore
     * @returns Promise with the search results
     */
    searchVectorStore(params: SearchParams): Promise<SearchResult[]>;

    /**
     * Search for vectors in an HNSWIndex
     * @param params Parameters for searching the HNSWIndex
     * @returns Promise with the search results
     */
    searchHNSWIndex(params: SearchParams): Promise<SearchResult[]>;

    /**
     * Count the number of vectors in a VectorStore
     * @param params Parameters for counting vectors in the VectorStore
     * @returns Promise with the count of vectors
     */
    countVectorStore(params: CountParams): Promise<CountResult>;

    /**
     * Count the number of vectors in an HNSWIndex
     * @param params Parameters for counting vectors in the HNSWIndex
     * @returns Promise with the count of vectors
     */
    countHNSWIndex(params: CountParams): Promise<CountResult>;

    /**
     * Clear all vectors from a VectorStore
     * @param params Parameters for clearing the VectorStore
     * @returns Promise that resolves when the VectorStore is cleared
     */
    clearVectorStore(params: ClearParams): Promise<void>;

    /**
     * Clear all vectors from an HNSWIndex
     * @param params Parameters for clearing the HNSWIndex
     * @returns Promise that resolves when the HNSWIndex is cleared
     */
    clearHNSWIndex(params: ClearParams): Promise<void>;

    /**
     * Release resources associated with a VectorStore
     * @param params Parameters for releasing the VectorStore
     * @returns Promise that resolves when the VectorStore is released
     */
    releaseVectorStore(params: ReleaseParams): Promise<void>;

    /**
     * Release resources associated with an HNSWIndex
     * @param params Parameters for releasing the HNSWIndex
     * @returns Promise that resolves when the HNSWIndex is released
     */
    releaseHNSWIndex(params: ReleaseParams): Promise<void>;

    /**
     * Open an MMapVectorStore
     * @param params Parameters for opening the MMapVectorStore
     * @returns Promise with the ID of the opened MMapVectorStore
     */
    openMMapVectorStore(params: OpenMMapParams): Promise<CreateResult>;

    /**
     * Search for vectors in an MMapVectorStore
     * @param params Parameters for searching the MMapVectorStore
     * @returns Promise with the search results
     */
    searchMMapVectorStore(params: SearchParams): Promise<SearchResult[]>;

    /**
     * Get the number of vectors in an MMapVectorStore
     * @param params Parameters for counting vectors
     * @returns Promise with the count of vectors
     */
    getMMapVectorStoreCount(params: CountParams): Promise<CountResult>;

    /**
     * Get the dimension of vectors in an MMapVectorStore
     * @param params Parameters for getting the dimension
     * @returns Promise with the dimension information
     */
    getMMapVectorStoreDimension(params: CountParams): Promise<{ dimension: number }>;

    /**
     * Get the distance metric used by an MMapVectorStore
     * @param params Parameters for getting the metric
     * @returns Promise with the metric information
     */
    getMMapVectorStoreMetric(params: CountParams): Promise<{ metric: DistanceMetric }>;

    /**
     * Release resources associated with an MMapVectorStore
     * @param params Parameters for releasing the MMapVectorStore
     * @returns Promise that resolves when the MMapVectorStore is released
     */
    releaseMMapVectorStore(params: ReleaseParams): Promise<void>;
  }

  const LlamaMobileVD: LlamaMobileVD;
  export default LlamaMobileVD;
}