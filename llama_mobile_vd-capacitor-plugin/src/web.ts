import { registerPlugin } from '@capacitor/core';

interface VectorStore {
  dimension: number;
  metric: 'l2' | 'cosine' | 'dot';
  vectors: Map<number, number[]>;
  nextId: number;
}

interface HNSWIndex {
  storeId: number;
  m: number;
  efConstruction: number;
}

interface MMapVectorStoreBuilder {
  dimension: number;
  metric: 'l2' | 'cosine' | 'dot';
  vectors: Map<number, number[]>;
  nextId: number;
}

export class LlamaMobileVDWeb {
  private vectorStores: Map<number, VectorStore> = new Map();
  private hnswIndexes: Map<number, HNSWIndex> = new Map();
  private mmapBuilders: Map<number, MMapVectorStoreBuilder> = new Map();
  private mmapStores: Map<number, VectorStore> = new Map();
  private nextStoreId = 1;
  private nextIndexId = 1;
  private nextBuilderId = 1;

  async getVersion(): Promise<{ version: string }> {
    return { version: '1.0.0-web' };
  }

  async createVectorStore(options: {
    dimension: number;
    metric: 'l2' | 'cosine' | 'dot';
  }): Promise<{ storeId: number }> {
    const storeId = this.nextStoreId++;
    this.vectorStores.set(storeId, {
      dimension: options.dimension,
      metric: options.metric,
      vectors: new Map(),
      nextId: 1
    });
    return { storeId };
  }

  async destroyVectorStore(options: { storeId: number }): Promise<void> {
    this.vectorStores.delete(options.storeId);
  }

  async addVectors(options: {
    storeId: number;
    vectors: number[][];
    ids?: number[];
  }): Promise<void> {
    const store = this.vectorStores.get(options.storeId) || this.mmapStores.get(options.storeId);
    if (!store) {
      throw new Error(`Vector store ${options.storeId} not found`);
    }

    for (let i = 0; i < options.vectors.length; i++) {
      const vector = options.vectors[i];
      if (vector.length !== store.dimension) {
        throw new Error(`Vector dimension ${vector.length} does not match store dimension ${store.dimension}`);
      }

      const id = options.ids?.[i] || store.nextId++;
      store.vectors.set(id, vector);
    }
  }

  async getVector(options: {
    storeId: number;
    id: number;
  }): Promise<{ vector: number[] }> {
    const store = this.vectorStores.get(options.storeId) || this.mmapStores.get(options.storeId);
    if (!store) {
      throw new Error(`Vector store ${options.storeId} not found`);
    }

    const vector = store.vectors.get(options.id);
    if (!vector) {
      throw new Error(`Vector with id ${options.id} not found`);
    }

    return { vector };
  }

  async search(options: {
    storeId: number;
    queryVector: number[];
    k: number;
  }): Promise<{ ids: number[]; distances: number[] }> {
    const store = this.vectorStores.get(options.storeId) || this.mmapStores.get(options.storeId);
    if (!store) {
      throw new Error(`Vector store ${options.storeId} not found`);
    }

    if (options.queryVector.length !== store.dimension) {
      throw new Error(`Query vector dimension ${options.queryVector.length} does not match store dimension ${store.dimension}`);
    }

    const results: { id: number; distance: number }[] = [];

    for (const [id, vector] of store.vectors.entries()) {
      const distance = this.calculateDistance(store.metric, options.queryVector, vector);
      results.push({ id, distance });
    }

    results.sort((a, b) => a.distance - b.distance);
    const topK = results.slice(0, options.k);

    return {
      ids: topK.map(r => r.id),
      distances: topK.map(r => r.distance)
    };
  }

  async removeVectors(options: {
    storeId: number;
    ids: number[];
  }): Promise<void> {
    const store = this.vectorStores.get(options.storeId) || this.mmapStores.get(options.storeId);
    if (!store) {
      throw new Error(`Vector store ${options.storeId} not found`);
    }

    for (const id of options.ids) {
      store.vectors.delete(id);
    }
  }

  async getVectorCount(options: {
    storeId: number;
  }): Promise<{ count: number }> {
    const store = this.vectorStores.get(options.storeId) || this.mmapStores.get(options.storeId);
    if (!store) {
      throw new Error(`Vector store ${options.storeId} not found`);
    }

    return { count: store.vectors.size };
  }

  async clearVectors(options: {
    storeId: number;
  }): Promise<void> {
    const store = this.vectorStores.get(options.storeId) || this.mmapStores.get(options.storeId);
    if (!store) {
      throw new Error(`Vector store ${options.storeId} not found`);
    }

    store.vectors.clear();
    store.nextId = 1;
  }

  async createHNSWIndex(options: {
    dimension: number;
    metric: 'l2' | 'cosine' | 'dot';
    maxElements: number;
    m: number;
    efConstruction: number;
  }): Promise<{ indexId: number }> {
    const indexId = this.nextIndexId++;
    this.hnswIndexes.set(indexId, {
      storeId: -1, // Not used in web implementation
      m: options.m,
      efConstruction: options.efConstruction
    });
    return { indexId };
  }

  async destroyHNSWIndex(options: { indexId: number }): Promise<void> {
    this.hnswIndexes.delete(options.indexId);
  }

  async searchHNSW(options: {
    indexId: number;
    queryVector: number[];
    k: number;
    efSearch?: number;
  }): Promise<{ ids: number[]; distances: number[] }> {
    const index = this.hnswIndexes.get(options.indexId);
    if (!index) {
      throw new Error(`HNSW index ${options.indexId} not found`);
    }

    const store = this.vectorStores.get(index.storeId) || this.mmapStores.get(index.storeId);
    if (!store) {
      throw new Error(`Vector store ${index.storeId} not found`);
    }

    return this.search({
      storeId: index.storeId,
      queryVector: options.queryVector,
      k: options.k
    });
  }

  async addVectorsToHNSW(options: {
    indexId: number;
    vectors: number[][];
    ids?: number[];
  }): Promise<void> {
    const index = this.hnswIndexes.get(options.indexId);
    if (!index) {
      throw new Error(`HNSW index ${options.indexId} not found`);
    }

    await this.addVectors({
      storeId: index.storeId,
      vectors: options.vectors,
      ids: options.ids
    });
  }

  async createMMapVectorStoreBuilder(options: {
    dimension: number;
    metric: 'l2' | 'cosine' | 'dot';
  }): Promise<{ builderId: number }> {
    const builderId = this.nextBuilderId++;
    this.mmapBuilders.set(builderId, {
      dimension: options.dimension,
      metric: options.metric,
      vectors: new Map(),
      nextId: 1
    });
    return { builderId };
  }

  async destroyMMapVectorStoreBuilder(options: { builderId: number }): Promise<void> {
    this.mmapBuilders.delete(options.builderId);
  }

  async addVectorsToMMapBuilder(options: {
    builderId: number;
    vectors: number[][];
    ids?: number[];
  }): Promise<void> {
    const builder = this.mmapBuilders.get(options.builderId);
    if (!builder) {
      throw new Error(`MMap builder ${options.builderId} not found`);
    }

    for (let i = 0; i < options.vectors.length; i++) {
      const vector = options.vectors[i];
      if (vector.length !== builder.dimension) {
        throw new Error(`Vector dimension ${vector.length} does not match builder dimension ${builder.dimension}`);
      }

      const id = options.ids?.[i] || builder.nextId++;
      builder.vectors.set(id, vector);
    }
  }

  async buildMMapVectorStore(options: {
    builderId: number;
    path: string;
  }): Promise<void> {
    const builder = this.mmapBuilders.get(options.builderId);
    if (!builder) {
      throw new Error(`MMap builder ${options.builderId} not found`);
    }

    // For web implementation, we'll just store the builder's vectors in mmapStores
    const storeId = this.nextStoreId++;
    this.mmapStores.set(storeId, {
      dimension: builder.dimension,
      metric: builder.metric,
      vectors: builder.vectors,
      nextId: builder.nextId
    });

    this.mmapBuilders.delete(options.builderId);
  }

  async openMMapVectorStore(options: {
    path: string;
  }): Promise<{ storeId: number }> {
    // For web implementation, we'll just create a new store with the given path
    // In a real implementation, this would load from disk
    const storeId = this.nextStoreId++;
    this.mmapStores.set(storeId, {
      dimension: 128,
      metric: 'l2',
      vectors: new Map(),
      nextId: 1
    });
    return { storeId };
  }

  async closeMMapVectorStore(options: { storeId: number }): Promise<void> {
    this.mmapStores.delete(options.storeId);
  }

  private calculateDistance(metric: 'l2' | 'cosine' | 'dot', a: number[], b: number[]): number {
    switch (metric) {
      case 'l2':
        return this.l2Distance(a, b);
      case 'cosine':
        return this.cosineDistance(a, b);
      case 'dot':
        return -this.dotProduct(a, b);
      default:
        throw new Error(`Unknown distance metric: ${metric}`);
    }
  }

  private l2Distance(a: number[], b: number[]): number {
    let sum = 0;
    for (let i = 0; i < a.length; i++) {
      const diff = a[i] - b[i];
      sum += diff * diff;
    }
    return Math.sqrt(sum);
  }

  private cosineDistance(a: number[], b: number[]): number {
    const dot = this.dotProduct(a, b);
    const normA = this.norm(a);
    const normB = this.norm(b);
    return 1 - (dot / (normA * normB));
  }

  private dotProduct(a: number[], b: number[]): number {
    let sum = 0;
    for (let i = 0; i < a.length; i++) {
      sum += a[i] * b[i];
    }
    return sum;
  }

  private norm(a: number[]): number {
    let sum = 0;
    for (const value of a) {
      sum += value * value;
    }
    return Math.sqrt(sum);
  }
}
