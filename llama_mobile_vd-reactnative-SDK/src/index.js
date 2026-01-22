const { NativeModules } = require('react-native');

const { LlamaMobileVD } = NativeModules;

module.exports = {
  // VectorStore methods
  vectorStoreCreate: (dimension, metric) => LlamaMobileVD.vectorStoreCreate(dimension, metric),
  vectorStoreAddVector: (storeId, id, vector) => LlamaMobileVD.vectorStoreAddVector(storeId, id, vector),
  vectorStoreSearch: (storeId, queryVector, k) => LlamaMobileVD.vectorStoreSearch(storeId, queryVector, k),
  vectorStoreGetVector: (storeId, id) => LlamaMobileVD.vectorStoreGetVector(storeId, id),
  vectorStoreRemoveVector: (storeId, id) => LlamaMobileVD.vectorStoreRemoveVector(storeId, id),
  vectorStoreContains: (storeId, id) => LlamaMobileVD.vectorStoreContains(storeId, id),
  vectorStoreGetSize: (storeId) => LlamaMobileVD.vectorStoreGetSize(storeId),
  vectorStoreGetDimension: (storeId) => LlamaMobileVD.vectorStoreGetDimension(storeId),
  vectorStoreGetMetric: (storeId) => LlamaMobileVD.vectorStoreGetMetric(storeId),
  vectorStoreUpdateVector: (storeId, id, vector) => LlamaMobileVD.vectorStoreUpdateVector(storeId, id, vector),
  vectorStoreReserve: (storeId, capacity) => LlamaMobileVD.vectorStoreReserve(storeId, capacity),
  vectorStoreClear: (storeId) => LlamaMobileVD.vectorStoreClear(storeId),
  vectorStoreDestroy: (storeId) => LlamaMobileVD.vectorStoreDestroy(storeId),

  // HNSWIndex methods
  hnswIndexCreate: (dimension, metric, maxElements) => LlamaMobileVD.hnswIndexCreate(dimension, metric, maxElements),
  hnswIndexCreateWithParams: (dimension, metric, maxElements, M, efConstruction, seed) => 
    LlamaMobileVD.hnswIndexCreateWithParams(dimension, metric, maxElements, M, efConstruction, seed),
  hnswIndexAddVector: (indexId, id, vector) => LlamaMobileVD.hnswIndexAddVector(indexId, id, vector),
  hnswIndexSearch: (indexId, queryVector, k) => LlamaMobileVD.hnswIndexSearch(indexId, queryVector, k),
  hnswIndexSetEfSearch: (indexId, efSearch) => LlamaMobileVD.hnswIndexSetEfSearch(indexId, efSearch),
  hnswIndexGetEfSearch: (indexId) => LlamaMobileVD.hnswIndexGetEfSearch(indexId),
  hnswIndexGetSize: (indexId) => LlamaMobileVD.hnswIndexGetSize(indexId),
  hnswIndexGetDimension: (indexId) => LlamaMobileVD.hnswIndexGetDimension(indexId),
  hnswIndexGetCapacity: (indexId) => LlamaMobileVD.hnswIndexGetCapacity(indexId),
  hnswIndexContains: (indexId, id) => LlamaMobileVD.hnswIndexContains(indexId, id),
  hnswIndexGetVector: (indexId, id) => LlamaMobileVD.hnswIndexGetVector(indexId, id),
  hnswIndexSave: (indexId, filename) => LlamaMobileVD.hnswIndexSave(indexId, filename),
  hnswIndexLoad: (filename) => LlamaMobileVD.hnswIndexLoad(filename),
  hnswIndexDestroy: (indexId) => LlamaMobileVD.hnswIndexDestroy(indexId),

  // MMapVectorStoreBuilder methods
  mmapVectorStoreBuilderCreate: (dimension, metric) => LlamaMobileVD.mmapVectorStoreBuilderCreate(dimension, metric),
  mmapVectorStoreBuilderAddVector: (builderId, id, vector) => LlamaMobileVD.mmapVectorStoreBuilderAddVector(builderId, id, vector),
  mmapVectorStoreBuilderReserve: (builderId, capacity) => LlamaMobileVD.mmapVectorStoreBuilderReserve(builderId, capacity),
  mmapVectorStoreBuilderSave: (builderId, filename) => LlamaMobileVD.mmapVectorStoreBuilderSave(builderId, filename),
  mmapVectorStoreBuilderGetSize: (builderId) => LlamaMobileVD.mmapVectorStoreBuilderGetSize(builderId),
  mmapVectorStoreBuilderGetDimension: (builderId) => LlamaMobileVD.mmapVectorStoreBuilderGetDimension(builderId),
  mmapVectorStoreBuilderDestroy: (builderId) => LlamaMobileVD.mmapVectorStoreBuilderDestroy(builderId),

  // MMapVectorStore methods
  mmapVectorStoreOpen: (filename) => LlamaMobileVD.mmapVectorStoreOpen(filename),
  mmapVectorStoreGetVector: (storeId, id) => LlamaMobileVD.mmapVectorStoreGetVector(storeId, id),
  mmapVectorStoreContains: (storeId, id) => LlamaMobileVD.mmapVectorStoreContains(storeId, id),
  mmapVectorStoreSearch: (storeId, queryVector, k) => LlamaMobileVD.mmapVectorStoreSearch(storeId, queryVector, k),
  mmapVectorStoreGetSize: (storeId) => LlamaMobileVD.mmapVectorStoreGetSize(storeId),
  mmapVectorStoreGetDimension: (storeId) => LlamaMobileVD.mmapVectorStoreGetDimension(storeId),
  mmapVectorStoreGetMetric: (storeId) => LlamaMobileVD.mmapVectorStoreGetMetric(storeId),
  mmapVectorStoreClose: (storeId) => LlamaMobileVD.mmapVectorStoreClose(storeId),
  
  // Version methods
  getVersion: () => LlamaMobileVD.getVersion(),
  getVersionMajor: () => LlamaMobileVD.getVersionMajor(),
  getVersionMinor: () => LlamaMobileVD.getVersionMinor(),
  getVersionPatch: () => LlamaMobileVD.getVersionPatch(),
};
