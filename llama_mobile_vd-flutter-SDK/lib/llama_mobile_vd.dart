/// LlamaMobileVD Flutter SDK
/// A high-performance vector database for Flutter applications
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// The method channel used to communicate with the native platforms
const MethodChannel _channel = MethodChannel('llama_mobile_vd');

/// Distance metrics supported by LlamaMobileVD
enum DistanceMetric {
  /// Euclidean distance (L2)
  l2,

  /// Cosine similarity
  cosine,

  /// Dot product
  dot,
}

/// Extension to convert DistanceMetric to int for platform channel communication
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
        throw ArgumentError('Unknown distance metric: $this');
    }
  }
}

/// A result from a vector search operation
class SearchResult {
  /// The ID of the vector
  final int id;

  /// The distance between the query vector and the result vector
  final double distance;

  /// Initialize a new search result
  /// - Parameters:
  ///   - id: The ID of the vector
  ///   - distance: The distance between the query vector and the result vector
  const SearchResult({
    required this.id,
    required this.distance,
  });

  /// Create a SearchResult from a map (used for platform channel communication)
  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      id: map['id'] as int,
      distance: (map['distance'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'SearchResult(id: $id, distance: $distance)';
  }
}

/// A vector store for efficiently storing and searching vectors
class VectorStore {
  final int _storeId;

  /// Initialize a new vector store
  /// - Parameters:
  ///   - dimension: The dimension of the vectors
  ///   - metric: The distance metric to use for similarity search
  /// - Throws: An error if the vector store could not be created
  static Future<VectorStore> create({
    required int dimension,
    required DistanceMetric metric,
  }) async {
    final storeId = await _channel.invokeMethod<int>('vectorStoreCreate', {
      'dimension': dimension,
      'metric': metric.value,
    });

    if (storeId == null) {
      throw Exception('Failed to create vector store');
    }

    return VectorStore._(storeId);
  }

  VectorStore._(this._storeId);

  /// Add a vector to the store
  /// - Parameters:
  ///   - vector: The vector to add
  ///   - id: The ID to associate with the vector
  /// - Throws: An error if the vector could not be added
  Future<void> addVector(List<double> vector, int id) async {
    await _channel.invokeMethod('vectorStoreAddVector', {
      'storeId': _storeId,
      'vector': Float32List.fromList(vector),
      'id': id,
    });
  }

  /// Search for the nearest neighbors of a query vector
  /// - Parameters:
  ///   - queryVector: The query vector
  ///   - k: The number of nearest neighbors to return
  /// - Returns: An array of search results sorted by distance
  /// - Throws: An error if the search could not be performed
  Future<List<SearchResult>> search(List<double> queryVector, int k) async {
    final results =
        await _channel.invokeMethod<List<dynamic>>('vectorStoreSearch', {
      'storeId': _storeId,
      'queryVector': Float32List.fromList(queryVector),
      'k': k,
    });

    if (results == null) {
      return [];
    }

    return results
        .map((result) =>
            SearchResult.fromMap(Map<String, dynamic>.from(result as Map)))
        .toList();
  }

  /// Get the number of vectors in the store
  Future<int> get count async {
    return await _channel.invokeMethod<int>('vectorStoreCount', {
          'storeId': _storeId,
        }) ??
        0;
  }

  /// Clear all vectors from the store
  /// - Throws: An error if the store could not be cleared
  Future<void> clear() async {
    await _channel.invokeMethod('vectorStoreClear', {
      'storeId': _storeId,
    });
  }

  /// Remove a vector from the store by ID
  /// - Parameters:
  ///   - id: The ID of the vector to remove
  /// - Returns: true if the vector was removed, false otherwise
  /// - Throws: An error if the operation fails
  Future<bool> remove(int id) async {
    return await _channel.invokeMethod<bool>('vectorStoreRemove', {
          'storeId': _storeId,
          'id': id,
        }) ??
        false;
  }

  /// Get a vector from the store by ID
  /// - Parameters:
  ///   - id: The ID of the vector to get
  /// - Returns: The vector if found, null otherwise
  /// - Throws: An error if the operation fails
  Future<List<double>?> get(int id) async {
    final vectorData =
        await _channel.invokeMethod<Float32List>('vectorStoreGet', {
      'storeId': _storeId,
      'id': id,
    });

    if (vectorData == null) {
      return null;
    }

    return vectorData.toList();
  }

  /// Update a vector in the store by ID
  /// - Parameters:
  ///   - id: The ID of the vector to update
  ///   - vector: The new vector data
  /// - Returns: true if the vector was updated, false otherwise
  /// - Throws: An error if the operation fails
  Future<bool> update(int id, List<double> vector) async {
    return await _channel.invokeMethod<bool>('vectorStoreUpdate', {
          'storeId': _storeId,
          'id': id,
          'vector': Float32List.fromList(vector),
        }) ??
        false;
  }

  /// Get the dimension of the vectors in the store
  Future<int> get dimension async {
    return await _channel.invokeMethod<int>('vectorStoreDimension', {
          'storeId': _storeId,
        }) ??
        0;
  }

  /// Get the distance metric used by the store
  Future<DistanceMetric> get metric async {
    final metricValue = await _channel.invokeMethod<int>('vectorStoreMetric', {
      'storeId': _storeId,
    });

    switch (metricValue) {
      case 0:
        return DistanceMetric.l2;
      case 1:
        return DistanceMetric.cosine;
      case 2:
        return DistanceMetric.dot;
      default:
        throw ArgumentError('Unknown distance metric: $metricValue');
    }
  }

  /// Check if the store contains a vector with the given ID
  /// - Parameters:
  ///   - id: The ID to check
  /// - Returns: true if the vector exists, false otherwise
  /// - Throws: An error if the operation fails
  Future<bool> contains(int id) async {
    return await _channel.invokeMethod<bool>('vectorStoreContains', {
          'storeId': _storeId,
          'id': id,
        }) ??
        false;
  }

  /// Reserve space for the specified number of vectors
  /// - Parameters:
  ///   - capacity: The number of vectors to reserve space for
  /// - Throws: An error if the operation fails
  Future<void> reserve(int capacity) async {
    await _channel.invokeMethod('vectorStoreReserve', {
      'storeId': _storeId,
      'capacity': capacity,
    });
  }

  /// Destroy the vector store and free resources
  Future<void> dispose() async {
    await _channel.invokeMethod('vectorStoreDestroy', {
      'storeId': _storeId,
    });
  }
}

/// A high-performance approximate nearest neighbor search index using the HNSW algorithm
class HNSWIndex {
  final int _indexId;

  /// Initialize a new HNSW index
  /// - Parameters:
  ///   - dimension: The dimension of the vectors
  ///   - metric: The distance metric to use
  ///   - m: The maximum number of connections per node
  ///   - efConstruction: The size of the dynamic list for candidate selection during construction
  /// - Throws: An error if the index could not be created
  static Future<HNSWIndex> create({
    required int dimension,
    required DistanceMetric metric,
    int m = 16,
    int efConstruction = 200,
  }) async {
    final indexId = await _channel.invokeMethod<int>('hnswIndexCreate', {
      'dimension': dimension,
      'metric': metric.value,
      'm': m,
      'efConstruction': efConstruction,
    });

    if (indexId == null) {
      throw Exception('Failed to create HNSW index');
    }

    return HNSWIndex._(indexId);
  }

  HNSWIndex._(this._indexId);

  /// Add a vector to the index
  /// - Parameters:
  ///   - vector: The vector to add
  ///   - id: The ID to associate with the vector
  /// - Throws: An error if the vector could not be added
  Future<void> addVector(List<double> vector, int id) async {
    await _channel.invokeMethod('hnswIndexAddVector', {
      'indexId': _indexId,
      'vector': Float32List.fromList(vector),
      'id': id,
    });
  }

  /// Search for the nearest neighbors of a query vector
  /// - Parameters:
  ///   - queryVector: The query vector
  ///   - k: The number of nearest neighbors to return
  ///   - efSearch: The size of the dynamic list for candidate selection during search
  /// - Returns: An array of search results sorted by distance
  /// - Throws: An error if the search could not be performed
  Future<List<SearchResult>> search(List<double> queryVector, int k,
      {int efSearch = 50}) async {
    final results =
        await _channel.invokeMethod<List<dynamic>>('hnswIndexSearch', {
      'indexId': _indexId,
      'queryVector': Float32List.fromList(queryVector),
      'k': k,
      'efSearch': efSearch,
    });

    if (results == null) {
      return [];
    }

    return results
        .map((result) =>
            SearchResult.fromMap(Map<String, dynamic>.from(result as Map)))
        .toList();
  }

  /// Get the number of vectors in the index
  Future<int> get count async {
    return await _channel.invokeMethod<int>('hnswIndexCount', {
          'indexId': _indexId,
        }) ??
        0;
  }

  /// Clear all vectors from the index
  /// - Throws: An error if the index could not be cleared
  Future<void> clear() async {
    await _channel.invokeMethod('hnswIndexClear', {
      'indexId': _indexId,
    });
  }

  /// Set the efSearch parameter for search operations
  /// - Parameters:
  ///   - efSearch: The new efSearch value
  /// - Throws: An error if the operation fails
  Future<void> setEfSearch(int efSearch) async {
    await _channel.invokeMethod('hnswIndexSetEfSearch', {
      'indexId': _indexId,
      'efSearch': efSearch,
    });
  }

  /// Get the current efSearch parameter
  /// - Returns: The current efSearch value
  /// - Throws: An error if the operation fails
  Future<int> getEfSearch() async {
    return await _channel.invokeMethod<int>('hnswIndexGetEfSearch', {
          'indexId': _indexId,
        }) ??
        50;
  }

  /// Get the dimension of the vectors in the index
  Future<int> get dimension async {
    return await _channel.invokeMethod<int>('hnswIndexDimension', {
          'indexId': _indexId,
        }) ??
        0;
  }

  /// Get the maximum capacity of the index
  Future<int> get capacity async {
    return await _channel.invokeMethod<int>('hnswIndexCapacity', {
          'indexId': _indexId,
        }) ??
        0;
  }

  /// Check if the index contains a vector with the given ID
  /// - Parameters:
  ///   - id: The ID to check
  /// - Returns: true if the vector exists, false otherwise
  /// - Throws: An error if the operation fails
  Future<bool> contains(int id) async {
    return await _channel.invokeMethod<bool>('hnswIndexContains', {
          'indexId': _indexId,
          'id': id,
        }) ??
        false;
  }

  /// Get a vector from the index by ID
  /// - Parameters:
  ///   - id: The ID of the vector to get
  /// - Returns: The vector if found, null otherwise
  /// - Throws: An error if the operation fails
  Future<List<double>?> getVector(int id) async {
    final vectorData =
        await _channel.invokeMethod<Float32List>('hnswIndexGetVector', {
      'indexId': _indexId,
      'id': id,
    });

    if (vectorData == null) {
      return null;
    }

    return vectorData.toList();
  }

  /// Save the index to a file
  /// - Parameters:
  ///   - filename: The path to the file where the index should be saved
  /// - Returns: true if the index was saved successfully, false otherwise
  /// - Throws: An error if the operation fails
  Future<bool> save(String filename) async {
    return await _channel.invokeMethod<bool>('hnswIndexSave', {
          'indexId': _indexId,
          'filename': filename,
        }) ??
        false;
  }

  /// Load an HNSW index from a file
  /// - Parameters:
  ///   - filename: The path to the file containing the saved index
  /// - Returns: The loaded HNSW index
  /// - Throws: An error if the index could not be loaded
  static Future<HNSWIndex> load(String filename) async {
    final indexId = await _channel.invokeMethod<int>('hnswIndexLoad', {
      'filename': filename,
    });

    if (indexId == null) {
      throw Exception('Failed to load HNSW index from file: $filename');
    }

    return HNSWIndex._(indexId);
  }

  /// Destroy the index and free resources
  Future<void> dispose() async {
    await _channel.invokeMethod('hnswIndexDestroy', {
      'indexId': _indexId,
    });
  }
}

/// Get the version string of the LlamaMobileVD SDK
/// - Returns: The version string in the format "major.minor.patch"
Future<String> getLlamaMobileVDVersion() async {
  final version = await _channel.invokeMethod<String>('getVersion');
  return version ?? 'Unknown';
}

/// Get the major version number of the LlamaMobileVD SDK
/// - Returns: The major version number
Future<int> getLlamaMobileVDVersionMajor() async {
  return await _channel.invokeMethod<int>('getVersionMajor') ?? 0;
}

/// Get the minor version number of the LlamaMobileVD SDK
/// - Returns: The minor version number
Future<int> getLlamaMobileVDVersionMinor() async {
  return await _channel.invokeMethod<int>('getVersionMinor') ?? 0;
}

/// Get the patch version number of the LlamaMobileVD SDK
/// - Returns: The patch version number
Future<int> getLlamaMobileVDVersionPatch() async {
  return await _channel.invokeMethod<int>('getVersionPatch') ?? 0;
}

/// A memory-mapped vector store for efficiently storing and searching large datasets
class MMapVectorStore {
  final int _storeId;

  /// Open an existing MMapVectorStore from a file
  /// - Parameters:
  ///   - path: The path to the MMapVectorStore file
  /// - Throws: An error if the MMapVectorStore could not be opened
  static Future<MMapVectorStore> open({required String path}) async {
    final storeId = await _channel.invokeMethod<int>('mmapVectorStoreOpen', {
      'path': path,
    });

    if (storeId == null) {
      throw Exception('Failed to open MMapVectorStore');
    }

    return MMapVectorStore._(storeId);
  }

  MMapVectorStore._(this._storeId);

  /// Search for the nearest neighbors of a query vector
  /// - Parameters:
  ///   - queryVector: The query vector
  ///   - k: The number of nearest neighbors to return
  /// - Returns: An array of search results sorted by distance
  /// - Throws: An error if the search could not be performed
  Future<List<SearchResult>> search(List<double> queryVector, int k) async {
    final results = await _channel.invokeMethod<List<dynamic>>('mmapVectorStoreSearch', {
      'storeId': _storeId,
      'queryVector': Float32List.fromList(queryVector),
      'k': k,
    });

    if (results == null) {
      return [];
    }

    return results
        .map((result) => SearchResult.fromMap(Map<String, dynamic>.from(result as Map)))
        .toList();
  }

  /// Get the number of vectors in the store
  Future<int> get count async {
    return await _channel.invokeMethod<int>('mmapVectorStoreCount', {
          'storeId': _storeId,
        }) ??
        0;
  }

  /// Get the dimension of the vectors in the store
  Future<int> get dimension async {
    return await _channel.invokeMethod<int>('mmapVectorStoreDimension', {
          'storeId': _storeId,
        }) ??
        0;
  }

  /// Get the distance metric used by the store
  Future<DistanceMetric> get metric async {
    final metricValue = await _channel.invokeMethod<int>('mmapVectorStoreMetric', {
      'storeId': _storeId,
    });

    switch (metricValue) {
      case 0:
        return DistanceMetric.l2;
      case 1:
        return DistanceMetric.cosine;
      case 2:
        return DistanceMetric.dot;
      default:
        throw ArgumentError('Unknown distance metric: $metricValue');
    }
  }

  /// Destroy the vector store and free resources
  Future<void> dispose() async {
    await _channel.invokeMethod('mmapVectorStoreDestroy', {
      'storeId': _storeId,
    });
  }
}
