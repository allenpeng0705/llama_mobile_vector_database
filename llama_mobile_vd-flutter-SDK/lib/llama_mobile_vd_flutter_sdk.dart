import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class LlamaMobileVDFlutterSdk {
  static const MethodChannel _channel =
      MethodChannel('llama_mobile_vd_flutter_sdk');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> get version async {
    final String? version = await _channel.invokeMethod('getVersion');
    return version;
  }

  static Future<int?> get versionMajor async {
    final int? major = await _channel.invokeMethod('getVersionMajor');
    return major;
  }

  static Future<int?> get versionMinor async {
    final int? minor = await _channel.invokeMethod('getVersionMinor');
    return minor;
  }

  static Future<int?> get versionPatch async {
    final int? patch = await _channel.invokeMethod('getVersionPatch');
    return patch;
  }
}

enum DistanceMetric { l2, cosine, dot }

extension DistanceMetricExtension on DistanceMetric {
  int get value {
    switch (this) {
      case DistanceMetric.l2:
        return 0;
      case DistanceMetric.cosine:
        return 1;
      case DistanceMetric.dot:
        return 2;
      default:
        return 0;
    }
  }

  static DistanceMetric fromValue(int value) {
    switch (value) {
      case 0:
        return DistanceMetric.l2;
      case 1:
        return DistanceMetric.cosine;
      case 2:
        return DistanceMetric.dot;
      default:
        return DistanceMetric.l2;
    }
  }
}

class SearchResult {
  final int id;
  final double distance;

  SearchResult(this.id, this.distance);

  @override
  String toString() {
    return 'SearchResult(id: $id, distance: $distance)';
  }
}

class VectorStore {
  final int storeId;

  VectorStore(this.storeId);

  static Future<VectorStore> create(
      int dimension, DistanceMetric metric) async {
    final int storeId = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'vectorStoreCreate', {'dimension': dimension, 'metric': metric.value});
    return VectorStore(storeId);
  }

  static Future<VectorStore> createAsync(
      int dimension, DistanceMetric metric) async {
    final int storeId = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'vectorStoreCreateAsync',
        {'dimension': dimension, 'metric': metric.value});
    return VectorStore(storeId);
  }

  Future<void> addVector(int id, List<double> vector) async {
    await LlamaMobileVDFlutterSdk._channel.invokeMethod('vectorStoreAddVector',
        {'storeId': storeId, 'id': id, 'vector': vector});
  }

  Future<void> addVectorAsync(int id, List<double> vector) async {
    await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'vectorStoreAddVectorAsync',
        {'storeId': storeId, 'id': id, 'vector': vector});
  }

  Future<List<SearchResult>> search(List<double> queryVector, int k) async {
    final List<dynamic> results = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreSearch',
            {'storeId': storeId, 'queryVector': queryVector, 'k': k});

    return results.map((result) {
      final Map<Object?, Object?> map = result as Map<Object?, Object?>;
      return SearchResult(map['id'] as int, map['distance'] as double);
    }).toList();
  }

  Future<List<SearchResult>> searchAsync(
      List<double> queryVector, int k) async {
    final List<dynamic> results = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreSearchAsync',
            {'storeId': storeId, 'queryVector': queryVector, 'k': k});

    return results.map((result) {
      final Map<Object?, Object?> map = result as Map<Object?, Object?>;
      return SearchResult(map['id'] as int, map['distance'] as double);
    }).toList();
  }

  Future<List<double>?> getVector(int id) async {
    final dynamic result = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreGetVector', {'storeId': storeId, 'id': id});
    if (result == null) {
      return null;
    }
    final List<Object?> list = result as List<Object?>;
    return list.map((item) => (item as num).toDouble()).toList();
  }

  Future<bool> removeVector(int id) async {
    final bool removed = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'vectorStoreRemoveVector', {'storeId': storeId, 'id': id});
    return removed;
  }

  Future<bool> removeVectorAsync(int id) async {
    final bool removed = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'vectorStoreRemoveVectorAsync', {'storeId': storeId, 'id': id});
    return removed;
  }

  Future<bool> contains(int id) async {
    final bool contains = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreContains', {'storeId': storeId, 'id': id});
    return contains;
  }

  Future<int> getSize() async {
    final int size = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreGetSize', {'storeId': storeId});
    return size;
  }

  Future<int> getDimension() async {
    final int dimension = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreGetDimension', {'storeId': storeId});
    return dimension;
  }

  Future<DistanceMetric> getMetric() async {
    final int metricValue = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreGetMetric', {'storeId': storeId});
    return DistanceMetricExtension.fromValue(metricValue);
  }

  Future<bool> updateVector(int id, List<double> vector) async {
    final bool updated = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'vectorStoreUpdateVector',
        {'storeId': storeId, 'id': id, 'vector': vector});
    return updated;
  }

  Future<bool> updateVectorAsync(int id, List<double> vector) async {
    final bool updated = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'vectorStoreUpdateVectorAsync',
        {'storeId': storeId, 'id': id, 'vector': vector});
    return updated;
  }

  Future<bool> reserve(int capacity) async {
    final bool reserved = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'vectorStoreReserve', {'storeId': storeId, 'capacity': capacity});
    return reserved;
  }

  Future<bool> reserveAsync(int capacity) async {
    final bool reserved = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'vectorStoreReserveAsync', {'storeId': storeId, 'capacity': capacity});
    return reserved;
  }

  Future<void> clear() async {
    await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreClear', {'storeId': storeId});
  }

  Future<void> clearAsync() async {
    await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreClearAsync', {'storeId': storeId});
  }

  Future<void> destroy() async {
    await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('vectorStoreDestroy', {'storeId': storeId});
  }
}

class HNSWIndex {
  final int indexId;

  HNSWIndex(this.indexId);

  static Future<HNSWIndex> create(
      int dimension, DistanceMetric metric, int maxElements) async {
    final int indexId = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'hnswIndexCreate', {
      'dimension': dimension,
      'metric': metric.value,
      'maxElements': maxElements
    });
    return HNSWIndex(indexId);
  }

  static Future<HNSWIndex> createAsync(
      int dimension, DistanceMetric metric, int maxElements) async {
    final int indexId = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'hnswIndexCreateAsync', {
      'dimension': dimension,
      'metric': metric.value,
      'maxElements': maxElements
    });
    return HNSWIndex(indexId);
  }

  static Future<HNSWIndex> createWithParams(
      int dimension,
      DistanceMetric metric,
      int maxElements,
      int M,
      int efConstruction,
      int seed) async {
    final int indexId = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexCreateWithParams', {
      'dimension': dimension,
      'metric': metric.value,
      'maxElements': maxElements,
      'M': M,
      'efConstruction': efConstruction,
      'seed': seed
    });
    return HNSWIndex(indexId);
  }

  static Future<HNSWIndex> createWithParamsAsync(
      int dimension,
      DistanceMetric metric,
      int maxElements,
      int M,
      int efConstruction,
      int seed) async {
    final int indexId = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexCreateWithParamsAsync', {
      'dimension': dimension,
      'metric': metric.value,
      'maxElements': maxElements,
      'M': M,
      'efConstruction': efConstruction,
      'seed': seed
    });
    return HNSWIndex(indexId);
  }

  Future<bool> addVector(int id, List<double> vector) async {
    final bool added = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'hnswIndexAddVector', {'indexId': indexId, 'id': id, 'vector': vector});
    return added;
  }

  Future<bool> addVectorAsync(int id, List<double> vector) async {
    final bool added = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'hnswIndexAddVectorAsync',
        {'indexId': indexId, 'id': id, 'vector': vector});
    return added;
  }

  Future<List<SearchResult>> search(List<double> queryVector, int k) async {
    final List<dynamic> results = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexSearch',
            {'indexId': indexId, 'queryVector': queryVector, 'k': k});

    return results.map((result) {
      final Map<Object?, Object?> map = result as Map<Object?, Object?>;
      return SearchResult(map['id'] as int, map['distance'] as double);
    }).toList();
  }

  Future<List<SearchResult>> searchAsync(
      List<double> queryVector, int k) async {
    final List<dynamic> results = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexSearchAsync',
            {'indexId': indexId, 'queryVector': queryVector, 'k': k});

    return results.map((result) {
      final Map<Object?, Object?> map = result as Map<Object?, Object?>;
      return SearchResult(map['id'] as int, map['distance'] as double);
    }).toList();
  }

  Future<bool> setEfSearch(int efSearch) async {
    final bool set = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'hnswIndexSetEfSearch', {'indexId': indexId, 'efSearch': efSearch});
    return set;
  }

  Future<int> getEfSearch() async {
    final int efSearch = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexGetEfSearch', {'indexId': indexId});
    return efSearch;
  }

  Future<int> getSize() async {
    final int size = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexGetSize', {'indexId': indexId});
    return size;
  }

  Future<int> getDimension() async {
    final int dimension = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexGetDimension', {'indexId': indexId});
    return dimension;
  }

  Future<int> getCapacity() async {
    final int capacity = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexGetCapacity', {'indexId': indexId});
    return capacity;
  }

  Future<bool> contains(int id) async {
    final bool contains = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexContains', {'indexId': indexId, 'id': id});
    return contains;
  }

  Future<List<double>?> getVector(int id) async {
    final List<double>? vector = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexGetVector', {'indexId': indexId, 'id': id});
    return vector;
  }

  Future<bool> save(String filename) async {
    final bool saved = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'hnswIndexSave', {'indexId': indexId, 'filename': filename});
    return saved;
  }

  Future<bool> saveAsync(String filename) async {
    final bool saved = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'hnswIndexSaveAsync', {'indexId': indexId, 'filename': filename});
    return saved;
  }

  static Future<HNSWIndex> load(String filename) async {
    final int indexId = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexLoad', {'filename': filename});
    return HNSWIndex(indexId);
  }

  static Future<HNSWIndex> loadAsync(String filename) async {
    final int indexId = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexLoadAsync', {'filename': filename});
    return HNSWIndex(indexId);
  }

  Future<void> destroy() async {
    await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('hnswIndexDestroy', {'indexId': indexId});
  }
}

class MMapVectorStoreBuilder {
  final int builderId;

  MMapVectorStoreBuilder(this.builderId);

  static Future<MMapVectorStoreBuilder> create(
      int dimension, DistanceMetric metric) async {
    final int builderId = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderCreate',
        {'dimension': dimension, 'metric': metric.value});
    return MMapVectorStoreBuilder(builderId);
  }

  static Future<MMapVectorStoreBuilder> createAsync(
      int dimension, DistanceMetric metric) async {
    final int builderId = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderCreateAsync',
        {'dimension': dimension, 'metric': metric.value});
    return MMapVectorStoreBuilder(builderId);
  }

  Future<bool> addVector(int id, List<double> vector) async {
    final bool added = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderAddVector',
        {'builderId': builderId, 'id': id, 'vector': vector});
    return added;
  }

  Future<bool> addVectorAsync(int id, List<double> vector) async {
    final bool added = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderAddVectorAsync',
        {'builderId': builderId, 'id': id, 'vector': vector});
    return added;
  }

  Future<bool> reserve(int capacity) async {
    final bool reserved = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderReserve',
        {'builderId': builderId, 'capacity': capacity});
    return reserved;
  }

  Future<bool> reserveAsync(int capacity) async {
    final bool reserved = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderReserveAsync',
        {'builderId': builderId, 'capacity': capacity});
    return reserved;
  }

  Future<bool> save(String filename) async {
    final bool saved = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderSave',
        {'builderId': builderId, 'filename': filename});
    return saved;
  }

  Future<bool> saveAsync(String filename) async {
    final bool saved = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderSaveAsync',
        {'builderId': builderId, 'filename': filename});
    return saved;
  }

  Future<int> getSize() async {
    final int size = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderGetSize', {'builderId': builderId});
    return size;
  }

  Future<int> getDimension() async {
    final int dimension = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderGetDimension', {'builderId': builderId});
    return dimension;
  }

  Future<void> destroy() async {
    await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreBuilderDestroy', {'builderId': builderId});
  }
}

class MMapVectorStore {
  final int storeId;

  MMapVectorStore(this.storeId);

  static Future<MMapVectorStore> open(String filename) async {
    final int storeId = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('mmapVectorStoreOpen', {'filename': filename});
    return MMapVectorStore(storeId);
  }

  static Future<MMapVectorStore> openAsync(String filename) async {
    final int storeId = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('mmapVectorStoreOpenAsync', {'filename': filename});
    return MMapVectorStore(storeId);
  }

  Future<List<double>?> getVector(int id) async {
    final dynamic result = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreGetVector', {'storeId': storeId, 'id': id});
    if (result == null) {
      return null;
    }
    final List<Object?> list = result as List<Object?>;
    return list.map((item) => (item as num).toDouble()).toList();
  }

  Future<bool> contains(int id) async {
    final bool contains = await LlamaMobileVDFlutterSdk._channel.invokeMethod(
        'mmapVectorStoreContains', {'storeId': storeId, 'id': id});
    return contains;
  }

  Future<List<SearchResult>> search(List<double> queryVector, int k) async {
    final List<dynamic> results = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('mmapVectorStoreSearch',
            {'storeId': storeId, 'queryVector': queryVector, 'k': k});

    return results.map((result) {
      final Map<Object?, Object?> map = result as Map<Object?, Object?>;
      return SearchResult(map['id'] as int, map['distance'] as double);
    }).toList();
  }

  Future<List<SearchResult>> searchAsync(
      List<double> queryVector, int k) async {
    final List<dynamic> results = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('mmapVectorStoreSearchAsync',
            {'storeId': storeId, 'queryVector': queryVector, 'k': k});

    return results.map((result) {
      final Map<Object?, Object?> map = result as Map<Object?, Object?>;
      return SearchResult(map['id'] as int, map['distance'] as double);
    }).toList();
  }

  Future<int> getSize() async {
    final int size = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('mmapVectorStoreGetSize', {'storeId': storeId});
    return size;
  }

  Future<int> getDimension() async {
    final int dimension = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('mmapVectorStoreGetDimension', {'storeId': storeId});
    return dimension;
  }

  Future<DistanceMetric> getMetric() async {
    final int metricValue = await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('mmapVectorStoreGetMetric', {'storeId': storeId});
    return DistanceMetricExtension.fromValue(metricValue);
  }

  Future<void> close() async {
    await LlamaMobileVDFlutterSdk._channel
        .invokeMethod('mmapVectorStoreClose', {'storeId': storeId});
  }
}
