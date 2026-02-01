export type DistanceMetric = 'l2' | 'cosine' | 'dot';

export interface CreateVectorStoreOptions {
  dimension: number;
  metric: DistanceMetric;
}

export interface CreateVectorStoreResult {
  storeId: number;
}

export interface DestroyVectorStoreOptions {
  storeId: number;
}

export interface AddVectorsOptions {
  storeId: number;
  vectors: number[][];
  ids?: number[];
}

export interface GetVectorOptions {
  storeId: number;
  id: number;
}

export interface GetVectorResult {
  vector: number[];
}

export interface SearchOptions {
  storeId: number;
  queryVector: number[];
  k: number;
}

export interface SearchResult {
  ids: number[];
  distances: number[];
}

export interface RemoveVectorsOptions {
  storeId: number;
  ids: number[];
}

export interface GetVectorCountOptions {
  storeId: number;
}

export interface GetVectorCountResult {
  count: number;
}

export interface ClearVectorsOptions {
  storeId: number;
}

export interface CreateHNSWIndexOptions {
  storeId: number;
  m: number;
  efConstruction: number;
}

export interface CreateHNSWIndexResult {
  indexId: number;
}

export interface DestroyHNSWIndexOptions {
  indexId: number;
}

export interface SearchHNSWOptions {
  indexId: number;
  queryVector: number[];
  k: number;
  efSearch?: number;
}

export interface AddVectorsToHNSWOptions {
  indexId: number;
  vectors: number[][];
  ids?: number[];
}

export interface CreateMMapVectorStoreBuilderOptions {
  dimension: number;
  metric: DistanceMetric;
}

export interface CreateMMapVectorStoreBuilderResult {
  builderId: number;
}

export interface DestroyMMapVectorStoreBuilderOptions {
  builderId: number;
}

export interface AddVectorsToMMapBuilderOptions {
  builderId: number;
  vectors: number[][];
  ids?: number[];
}

export interface BuildMMapVectorStoreOptions {
  builderId: number;
  path: string;
}

export interface OpenMMapVectorStoreOptions {
  path: string;
}

export interface OpenMMapVectorStoreResult {
  storeId: number;
}

export interface CloseMMapVectorStoreOptions {
  storeId: number;
}

export interface GetVersionResult {
  version: string;
}

// Async method interfaces
export interface CreateVectorStoreAsyncOptions {
  dimension: number;
  metric: DistanceMetric;
}

export interface CreateVectorStoreAsyncResult {
  storeId: number;
}

export interface AddVectorsAsyncOptions {
  storeId: number;
  vectors: number[][];
  ids?: number[];
}

export interface SearchAsyncOptions {
  storeId: number;
  queryVector: number[];
  k: number;
}

export interface RemoveVectorsAsyncOptions {
  storeId: number;
  ids: number[];
}

export interface ClearVectorsAsyncOptions {
  storeId: number;
}

export interface CreateHNSWIndexAsyncOptions {
  dimension: number;
  metric: DistanceMetric;
  maxElements: number;
  m: number;
  efConstruction: number;
}

export interface CreateHNSWIndexAsyncResult {
  indexId: number;
}

export interface SearchHNSWAsyncOptions {
  indexId: number;
  queryVector: number[];
  k: number;
  efSearch?: number;
}

export interface AddVectorsToHNSWAsyncOptions {
  indexId: number;
  vectors: number[][];
  ids?: number[];
}

export interface CreateMMapVectorStoreBuilderAsyncOptions {
  dimension: number;
  metric: DistanceMetric;
}

export interface CreateMMapVectorStoreBuilderAsyncResult {
  builderId: number;
}

export interface AddVectorsToMMapBuilderAsyncOptions {
  builderId: number;
  vectors: number[][];
  ids?: number[];
}

export interface BuildMMapVectorStoreAsyncOptions {
  builderId: number;
  path: string;
}

export interface OpenMMapVectorStoreAsyncOptions {
  path: string;
}

export interface OpenMMapVectorStoreAsyncResult {
  storeId: number;
}
