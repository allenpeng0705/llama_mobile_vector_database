import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:llama_mobile_vd_flutter_sdk/llama_mobile_vd_flutter_sdk.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LlamaMobileVDFlutterSdk Integration Tests', () {
    testWidgets('get platform version', (WidgetTester tester) async {
      final String? version = await LlamaMobileVDFlutterSdk.platformVersion;
      expect(version, isNotNull);
      print('Platform version: $version');
    });

    testWidgets('get version', (WidgetTester tester) async {
      final String? version = await LlamaMobileVDFlutterSdk.version;
      expect(version, isNotNull);
      print('SDK version: $version');
    });

    // Test VectorStore basic functionality
    testWidgets('VectorStore create and basic operations', (
      WidgetTester tester,
    ) async {
      // Create a VectorStore
      final vectorStore = await VectorStore.create(64, DistanceMetric.l2);
      expect(vectorStore, isNotNull);

      // Add a vector
      const id = 1;
      final vector = List.generate(64, (index) => index.toDouble());
      await vectorStore.addVector(id, vector);

      // Get the vector
      final retrievedVector = await vectorStore.getVector(id);
      expect(retrievedVector, isNotNull);
      expect(retrievedVector!.length, equals(64));

      // Search for the vector
      final results = await vectorStore.search(vector, 1);
      expect(results, isNotEmpty);
      expect(results.first.id, equals(id));

      // Get size, dimension, and metric
      final size = await vectorStore.getSize();
      expect(size, equals(1));

      final dimension = await vectorStore.getDimension();
      expect(dimension, equals(64));

      final metric = await vectorStore.getMetric();
      expect(metric, equals(DistanceMetric.l2));

      // Destroy the vector store
      await vectorStore.destroy();
    });

    // Test HNSWIndex basic functionality
    testWidgets('HNSWIndex create and basic operations', (
      WidgetTester tester,
    ) async {
      // Create an HNSWIndex
      final hnswIndex = await HNSWIndex.create(64, DistanceMetric.cosine, 100);
      expect(hnswIndex, isNotNull);

      // Add a vector
      const id = 1;
      final vector = List.generate(64, (index) => index.toDouble());
      await hnswIndex.addVector(id, vector);

      // Search for the vector
      final results = await hnswIndex.search(vector, 1);
      expect(results, isNotEmpty);
      expect(results.first.id, equals(id));

      // Get size, dimension, and capacity
      final size = await hnswIndex.getSize();
      expect(size, equals(1));

      final dimension = await hnswIndex.getDimension();
      expect(dimension, equals(64));

      final capacity = await hnswIndex.getCapacity();
      expect(capacity, equals(100));

      // Destroy the HNSW index
      await hnswIndex.destroy();
    });

    // Test MMapVectorStore basic functionality
    testWidgets('MMapVectorStore create and basic operations', (
      WidgetTester tester,
    ) async {
      // Create a temporary file path
      final tempDir = await Directory.systemTemp.createTemp();
      final tempPath = '${tempDir.path}/test_mmap_vector_store.bin';

      // Create and save MMapVectorStore
      final builder = await MMapVectorStoreBuilder.create(
        64,
        DistanceMetric.dot,
      );
      expect(builder, isNotNull);

      // Add vectors
      for (int i = 0; i < 5; i++) {
        final vector = List.generate(
          64,
          (index) => (i * 100 + index).toDouble(),
        );
        await builder.addVector(i.toUInt64(), vector);
      }

      // Save the builder
      await builder.save(tempPath);

      // Open the MMapVectorStore
      final mmapVectorStore = await MMapVectorStore.open(tempPath);
      expect(mmapVectorStore, isNotNull);

      // Get size and dimension
      final size = await mmapVectorStore.getSize();
      expect(size, equals(5));

      final dimension = await mmapVectorStore.getDimension();
      expect(dimension, equals(64));

      // Get a vector
      final vector = await mmapVectorStore.getVector(2.toUInt64());
      expect(vector, isNotNull);

      // Search for a vector
      final queryVector = List.generate(
        64,
        (index) => (2 * 100 + index).toDouble(),
      );
      final results = await mmapVectorStore.search(queryVector, 1);
      expect(results, isNotEmpty);

      // Close the MMapVectorStore
      await mmapVectorStore.close();

      // Clean up - no need to destroy builder as it's already removed after save
    });
  });
}

// Extension to convert int to UInt64
extension IntToUInt64 on int {
  int toUInt64() => this;
}
