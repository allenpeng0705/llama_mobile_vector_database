import { registerPlugin } from '@capacitor/core';

export interface LlamaMobileVDPlugin {
  getVersion(): Promise<{ version: string }>;

  createVectorStore(options: {
    dimension: number;
    metric: 'l2' | 'cosine' | 'dot';
  }): Promise<{ storeId: number }>;

  destroyVectorStore(options: { storeId: number }): Promise<void>;

  addVectors(options: {
    storeId: number;
    vectors: number[][];
    ids?: number[];
  }): Promise<void>;

  getVector(options: {
    storeId: number;
    id: number;
  }): Promise<{ vector: number[] }>;

  search(options: {
    storeId: number;
    queryVector: number[];
    k: number;
  }): Promise<{ ids: number[]; distances: number[] }>;

  removeVectors(options: {
    storeId: number;
    ids: number[];
  }): Promise<void>;

  getVectorCount(options: {
    storeId: number;
  }): Promise<{ count: number }>;

  clearVectors(options: {
    storeId: number;
  }): Promise<void>;

  createHNSWIndex(options: {
    dimension: number;
    metric: 'l2' | 'cosine' | 'dot';
    maxElements: number;
    m: number;
    efConstruction: number;
  }): Promise<{ indexId: number }>;

  destroyHNSWIndex(options: { indexId: number }): Promise<void>;

  searchHNSW(options: {
    indexId: number;
    queryVector: number[];
    k: number;
    efSearch?: number;
  }): Promise<{ ids: number[]; distances: number[] }>;

  addVectorsToHNSW(options: {
    indexId: number;
    vectors: number[][];
    ids?: number[];
  }): Promise<void>;

  createMMapVectorStoreBuilder(options: {
    dimension: number;
    metric: 'l2' | 'cosine' | 'dot';
  }): Promise<{ builderId: number }>;

  destroyMMapVectorStoreBuilder(options: { builderId: number }): Promise<void>;

  addVectorsToMMapBuilder(options: {
    builderId: number;
    vectors: number[][];
    ids?: number[];
  }): Promise<void>;

  buildMMapVectorStore(options: {
    builderId: number;
    path: string;
  }): Promise<void>;

  openMMapVectorStore(options: {
    path: string;
  }): Promise<{ storeId: number }>;

  closeMMapVectorStore(options: { storeId: number }): Promise<void>;
}

const LlamaMobileVD = registerPlugin<LlamaMobileVDPlugin>('LlamaMobileVD');

export * from './definitions';
export { LlamaMobileVD };
