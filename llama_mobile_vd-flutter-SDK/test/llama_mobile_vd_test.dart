import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:llama_mobile_vd/llama_mobile_vd.dart';

void main() {
  const MethodChannel channel = MethodChannel('llama_mobile_vd');

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      // Mock responses based on method calls
      switch (methodCall.method) {
        case 'vectorStoreCreate':
          return 1; // Return mock store ID
        case 'vectorStoreAddVector':
          return null;
        case 'vectorStoreSearch':
          return [
            {'id': 1, 'distance': 0.1},
            {'id': 2, 'distance': 0.2},
          ];
        case 'vectorStoreCount':
          return 2;
        case 'vectorStoreClear':
          return null;
        case 'vectorStoreDestroy':
          return null;
        case 'hnswIndexCreate':
          return 1; // Return mock index ID
        case 'hnswIndexAddVector':
          return null;
        case 'hnswIndexSearch':
          return [
            {'id': 1, 'distance': 0.1},
            {'id': 2, 'distance': 0.2},
          ];
        case 'hnswIndexCount':
          return 2;
        case 'hnswIndexClear':
          return null;
        case 'hnswIndexDestroy':
          return null;
        default:
          throw MissingPluginException(
              'No implementation found for method ${methodCall.method} on channel $channel');
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('DistanceMetric', () {
    test('should have correct values', () {
      expect(DistanceMetric.l2.value, 0);
      expect(DistanceMetric.cosine.value, 1);
      expect(DistanceMetric.dot.value, 2);
    });

    test('should convert to correct string representation', () {
      expect(DistanceMetric.l2.toString(), 'DistanceMetric.l2');
      expect(DistanceMetric.cosine.toString(), 'DistanceMetric.cosine');
      expect(DistanceMetric.dot.toString(), 'DistanceMetric.dot');
    });
  });

  group('VectorStore', () {
    test('should create a vector store', () async {
      final vectorStore = await VectorStore.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );
      expect(vectorStore, isNotNull);
    });

    test('should add a vector to the store', () async {
      final vectorStore = await VectorStore.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );

      final vector = List<double>.generate(512, (_) => 0.5);
      expect(() => vectorStore.addVector(vector, 1), returnsNormally);
    });

    test('should search for vectors', () async {
      final vectorStore = await VectorStore.create(
        dimension: 512,
        metric: DistanceMetric.cosine,
      );

      final vector = List<double>.generate(512, (_) => 0.5);
      await vectorStore.addVector(vector, 1);

      final queryVector = List<double>.generate(512, (_) => 0.6);
      final results = await vectorStore.search(queryVector, 2);

      expect(results, isA<List<SearchResult>>());
      expect(results.length, 2);
      expect(results[0].id, 1);
      expect(results[0].distance, 0.1);
    });

    test('should get correct count of vectors', () async {
      final vectorStore = await VectorStore.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );

      final count = await vectorStore.count;
      expect(count, 2); // Matches mock response
    });

    test('should clear vectors from the store', () async {
      final vectorStore = await VectorStore.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );

      expect(() => vectorStore.clear(), returnsNormally);
    });

    test('should dispose of the store', () async {
      final vectorStore = await VectorStore.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );

      expect(() => vectorStore.dispose(), returnsNormally);
    });

    test('should handle large dimensions', () async {
      final vectorStore = await VectorStore.create(
        dimension: 3072, // Common for large models
        metric: DistanceMetric.cosine,
      );

      final vector = List<double>.generate(3072, (_) => 0.5);
      expect(() => vectorStore.addVector(vector, 1), returnsNormally);
    });

    test('should support different distance metrics', () async {
      // Test L2
      final vectorStoreL2 = await VectorStore.create(
        dimension: 128,
        metric: DistanceMetric.l2,
      );
      expect(vectorStoreL2, isNotNull);

      // Test Cosine
      final vectorStoreCosine = await VectorStore.create(
        dimension: 128,
        metric: DistanceMetric.cosine,
      );
      expect(vectorStoreCosine, isNotNull);

      // Test Dot
      final vectorStoreDot = await VectorStore.create(
        dimension: 128,
        metric: DistanceMetric.dot,
      );
      expect(vectorStoreDot, isNotNull);
    });
  });

  group('HNSWIndex', () {
    test('should create an HNSW index with default parameters', () async {
      final hnswIndex = await HNSWIndex.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );
      expect(hnswIndex, isNotNull);
    });

    test('should create an HNSW index with custom parameters', () async {
      final hnswIndex = await HNSWIndex.create(
        dimension: 512,
        metric: DistanceMetric.l2,
        m: 16,
        efConstruction: 200,
      );
      expect(hnswIndex, isNotNull);
    });

    test('should add a vector to the index', () async {
      final hnswIndex = await HNSWIndex.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );

      final vector = List<double>.generate(512, (_) => 0.5);
      expect(() => hnswIndex.addVector(vector, 1), returnsNormally);
    });

    test('should search for vectors with default efSearch', () async {
      final hnswIndex = await HNSWIndex.create(
        dimension: 512,
        metric: DistanceMetric.cosine,
      );

      final vector = List<double>.generate(512, (_) => 0.5);
      await hnswIndex.addVector(vector, 1);

      final queryVector = List<double>.generate(512, (_) => 0.6);
      final results = await hnswIndex.search(queryVector, 2);

      expect(results, isA<List<SearchResult>>());
      expect(results.length, 2);
      expect(results[0].id, 1);
      expect(results[0].distance, 0.1);
    });

    test('should search for vectors with custom efSearch', () async {
      final hnswIndex = await HNSWIndex.create(
        dimension: 512,
        metric: DistanceMetric.cosine,
      );

      final vector = List<double>.generate(512, (_) => 0.5);
      await hnswIndex.addVector(vector, 1);

      final queryVector = List<double>.generate(512, (_) => 0.6);
      final results = await hnswIndex.search(queryVector, 2, efSearch: 100);

      expect(results, isA<List<SearchResult>>());
      expect(results.length, 2);
    });

    test('should get correct count of vectors', () async {
      final hnswIndex = await HNSWIndex.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );

      final count = await hnswIndex.count;
      expect(count, 2); // Matches mock response
    });

    test('should clear vectors from the index', () async {
      final hnswIndex = await HNSWIndex.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );

      expect(() => hnswIndex.clear(), returnsNormally);
    });

    test('should dispose of the index', () async {
      final hnswIndex = await HNSWIndex.create(
        dimension: 512,
        metric: DistanceMetric.l2,
      );

      expect(() => hnswIndex.dispose(), returnsNormally);
    });

    test('should handle large dimensions', () async {
      final hnswIndex = await HNSWIndex.create(
        dimension: 3072, // Common for large models
        metric: DistanceMetric.cosine,
      );

      final vector = List<double>.generate(3072, (_) => 0.5);
      expect(() => hnswIndex.addVector(vector, 1), returnsNormally);
    });

    test('should support different distance metrics', () async {
      // Test L2
      final hnswIndexL2 = await HNSWIndex.create(
        dimension: 128,
        metric: DistanceMetric.l2,
      );
      expect(hnswIndexL2, isNotNull);

      // Test Cosine
      final hnswIndexCosine = await HNSWIndex.create(
        dimension: 128,
        metric: DistanceMetric.cosine,
      );
      expect(hnswIndexCosine, isNotNull);

      // Test Dot
      final hnswIndexDot = await HNSWIndex.create(
        dimension: 128,
        metric: DistanceMetric.dot,
      );
      expect(hnswIndexDot, isNotNull);
    });
  });

  group('SearchResult', () {
    test('should create with correct properties', () {
      const result = SearchResult(id: 1, distance: 0.1);
      expect(result.id, 1);
      expect(result.distance, 0.1);
    });

    test('should create from map', () {
      final map = {'id': 1, 'distance': 0.1};
      final result = SearchResult.fromMap(map);
      expect(result.id, 1);
      expect(result.distance, 0.1);
    });

    test('should have correct string representation', () {
      const result = SearchResult(id: 1, distance: 0.1);
      expect(result.toString(), 'SearchResult(id: 1, distance: 0.1)');
    });
  });
}
