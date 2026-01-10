/// LlamaMobileVD Flutter SDK
/// A high-performance vector database for Flutter applications
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

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
  static const MethodChannel _channel = MethodChannel('llama_mobile_vd');
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
    final results = await _channel.invokeMethod<List<dynamic>>('vectorStoreSearch', {
      'storeId': _storeId,
      'queryVector': Float32List.fromList(queryVector),
      'k': k,
    });
    
    if (results == null) {
      return [];
    }
    
    return results
        .map((result) => SearchResult.fromMap(result as Map<String, dynamic>))
        .toList();
  }
  
  /// Get the number of vectors in the store
  Future<int> get count async {
    return await _channel.invokeMethod<int>('vectorStoreCount', {
      'storeId': _storeId,
    }) ?? 0;
  }
  
  /// Clear all vectors from the store
  /// - Throws: An error if the store could not be cleared
  Future<void> clear() async {
    await _channel.invokeMethod('vectorStoreClear', {
      'storeId': _storeId,
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
  static const MethodChannel _channel = MethodChannel('llama_mobile_vd');
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
  Future<List<SearchResult>> search(
    List<double> queryVector, 
    int k, 
    {int efSearch = 50},
  ) async {
    final results = await _channel.invokeMethod<List<dynamic>>('hnswIndexSearch', {
      'indexId': _indexId,
      'queryVector': Float32List.fromList(queryVector),
      'k': k,
      'efSearch': efSearch,
    });
    
    if (results == null) {
      return [];
    }
    
    return results
        .map((result) => SearchResult.fromMap(result as Map<String, dynamic>))
        .toList();
  }
  
  /// Get the number of vectors in the index
  Future<int> get count async {
    return await _channel.invokeMethod<int>('hnswIndexCount', {
      'indexId': _indexId,
    }) ?? 0;
  }
  
  /// Clear all vectors from the index
  /// - Throws: An error if the index could not be cleared
  Future<void> clear() async {
    await _channel.invokeMethod('hnswIndexClear', {
      'indexId': _indexId,
    });
  }
  
  /// Destroy the index and free resources
  Future<void> dispose() async {
    await _channel.invokeMethod('hnswIndexDestroy', {
      'indexId': _indexId,
    });
  }
}