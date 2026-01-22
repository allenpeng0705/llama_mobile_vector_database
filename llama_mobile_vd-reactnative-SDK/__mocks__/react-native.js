// Mock react-native module for Jest testing
// Track created objects and their properties
const storeInstances = new Map();
const indexInstances = new Map();
const builderInstances = new Map();

// Generate vector of specified dimension
function generateVector(dimension) {
  return Array(dimension).fill(0).map(() => Math.random());
}

const NativeModules = {
  LlamaMobileVD: {
    // VectorStore methods
    vectorStoreCreate: jest.fn((dimension, metric) => {
      const id = storeInstances.size + 1;
      storeInstances.set(id, { dimension, metric, size: 0 });
      return Promise.resolve(id);
    }),
    vectorStoreAddVector: jest.fn((storeId, id, vector) => {
      if (storeInstances.has(storeId)) {
        const store = storeInstances.get(storeId);
        store.size++;
        storeInstances.set(storeId, store);
      }
      return Promise.resolve(true);
    }),
    vectorStoreSearch: jest.fn(() => Promise.resolve([{ id: 1, distance: 0.0 }])),
    vectorStoreGetVector: jest.fn((storeId, id) => {
      if (storeInstances.has(storeId)) {
        const { dimension } = storeInstances.get(storeId);
        return Promise.resolve(generateVector(dimension));
      }
      return Promise.resolve([0.1, 0.2, 0.3]);
    }),
    vectorStoreRemoveVector: jest.fn((storeId, id) => {
      if (storeInstances.has(storeId)) {
        const store = storeInstances.get(storeId);
        if (store.size > 0) store.size--;
        storeInstances.set(storeId, store);
      }
      return Promise.resolve(true);
    }),
    vectorStoreContains: jest.fn(() => Promise.resolve(true)),
    vectorStoreGetSize: jest.fn((storeId) => {
      if (storeInstances.has(storeId)) {
        return Promise.resolve(storeInstances.get(storeId).size);
      }
      return Promise.resolve(0);
    }),
    vectorStoreGetDimension: jest.fn((storeId) => {
      if (storeInstances.has(storeId)) {
        return Promise.resolve(storeInstances.get(storeId).dimension);
      }
      return Promise.resolve(128);
    }),
    vectorStoreGetMetric: jest.fn((storeId) => {
      if (storeInstances.has(storeId)) {
        return Promise.resolve(storeInstances.get(storeId).metric);
      }
      return Promise.resolve(0);
    }),
    vectorStoreUpdateVector: jest.fn(() => Promise.resolve(true)),
    vectorStoreReserve: jest.fn(() => Promise.resolve(true)),
    vectorStoreClear: jest.fn((storeId) => {
      if (storeInstances.has(storeId)) {
        const store = storeInstances.get(storeId);
        store.size = 0;
        storeInstances.set(storeId, store);
      }
      return Promise.resolve(true);
    }),
    vectorStoreDestroy: jest.fn((storeId) => {
      storeInstances.delete(storeId);
      return Promise.resolve();
    }),

    // HNSWIndex methods
    hnswIndexCreate: jest.fn((dimension, metric, maxElements) => {
      const id = indexInstances.size + 1;
      indexInstances.set(id, { dimension, metric, maxElements, size: 0 });
      return Promise.resolve(id);
    }),
    hnswIndexCreateWithParams: jest.fn((dimension, metric, maxElements) => {
      const id = indexInstances.size + 1;
      indexInstances.set(id, { dimension, metric, maxElements, size: 0 });
      return Promise.resolve(id);
    }),
    hnswIndexAddVector: jest.fn((indexId, id, vector) => {
      if (indexInstances.has(indexId)) {
        const index = indexInstances.get(indexId);
        index.size++;
        indexInstances.set(indexId, index);
      }
      return Promise.resolve(true);
    }),
    hnswIndexSearch: jest.fn(() => Promise.resolve([{ id: 1, distance: 0.0 }])),
    hnswIndexSetEfSearch: jest.fn(() => Promise.resolve(true)),
    hnswIndexGetEfSearch: jest.fn(() => Promise.resolve(100)),
    hnswIndexGetSize: jest.fn((indexId) => {
      if (indexInstances.has(indexId)) {
        return Promise.resolve(indexInstances.get(indexId).size);
      }
      return Promise.resolve(0);
    }),
    hnswIndexGetDimension: jest.fn((indexId) => {
      if (indexInstances.has(indexId)) {
        return Promise.resolve(indexInstances.get(indexId).dimension);
      }
      return Promise.resolve(128);
    }),
    hnswIndexGetCapacity: jest.fn((indexId) => {
      if (indexInstances.has(indexId)) {
        return Promise.resolve(indexInstances.get(indexId).maxElements);
      }
      return Promise.resolve(1000);
    }),
    hnswIndexContains: jest.fn(() => Promise.resolve(true)),
    hnswIndexGetVector: jest.fn((indexId, id) => {
      if (indexInstances.has(indexId)) {
        const { dimension } = indexInstances.get(indexId);
        return Promise.resolve(generateVector(dimension));
      }
      return Promise.resolve(generateVector(128));
    }),
    hnswIndexSave: jest.fn(() => Promise.resolve(true)),
    hnswIndexLoad: jest.fn(() => {
      const id = indexInstances.size + 1;
      indexInstances.set(id, { dimension: 128, metric: 0, maxElements: 1000, size: 1 });
      return Promise.resolve(id);
    }),
    hnswIndexDestroy: jest.fn((indexId) => {
      indexInstances.delete(indexId);
      return Promise.resolve();
    }),

    // MMapVectorStoreBuilder methods
    mmapVectorStoreBuilderCreate: jest.fn((dimension, metric) => {
      const id = builderInstances.size + 1;
      builderInstances.set(id, { dimension, metric, size: 0 });
      return Promise.resolve(id);
    }),
    mmapVectorStoreBuilderAddVector: jest.fn((builderId, id, vector) => {
      if (builderInstances.has(builderId)) {
        const builder = builderInstances.get(builderId);
        builder.size++;
        builderInstances.set(builderId, builder);
      }
      return Promise.resolve(true);
    }),
    mmapVectorStoreBuilderReserve: jest.fn(() => Promise.resolve(true)),
    mmapVectorStoreBuilderSave: jest.fn(() => Promise.resolve(true)),
    mmapVectorStoreBuilderGetSize: jest.fn((builderId) => {
      if (builderInstances.has(builderId)) {
        return Promise.resolve(builderInstances.get(builderId).size);
      }
      return Promise.resolve(0);
    }),
    mmapVectorStoreBuilderGetDimension: jest.fn((builderId) => {
      if (builderInstances.has(builderId)) {
        return Promise.resolve(builderInstances.get(builderId).dimension);
      }
      return Promise.resolve(128);
    }),
    mmapVectorStoreBuilderDestroy: jest.fn((builderId) => {
      builderInstances.delete(builderId);
      return Promise.resolve();
    }),

    // MMapVectorStore methods
    mmapVectorStoreOpen: jest.fn(() => Promise.resolve(1)),
    mmapVectorStoreGetVector: jest.fn(() => Promise.resolve(generateVector(128))),
    mmapVectorStoreContains: jest.fn(() => Promise.resolve(true)),
    mmapVectorStoreSearch: jest.fn(() => Promise.resolve([{ id: 1, distance: 0.0 }])),
    mmapVectorStoreGetSize: jest.fn(() => Promise.resolve(1)),
    mmapVectorStoreGetDimension: jest.fn(() => Promise.resolve(128)),
    mmapVectorStoreGetMetric: jest.fn(() => Promise.resolve(0)),
    mmapVectorStoreClose: jest.fn(() => Promise.resolve()),

    // Version methods
    getVersion: jest.fn(() => Promise.resolve('1.0.0')),
    getVersionMajor: jest.fn(() => Promise.resolve(1)),
    getVersionMinor: jest.fn(() => Promise.resolve(0)),
    getVersionPatch: jest.fn(() => Promise.resolve(0)),
  },
};

module.exports = {
  NativeModules,
};