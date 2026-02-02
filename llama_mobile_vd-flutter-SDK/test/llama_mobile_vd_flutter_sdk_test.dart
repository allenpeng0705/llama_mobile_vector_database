import 'package:flutter_test/flutter_test.dart';
import 'package:llama_mobile_vd_flutter_sdk/llama_mobile_vd_flutter_sdk.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LlamaMobileVDFlutterSdk', () {
    test('get platform version', () async {
      final String? version = await LlamaMobileVDFlutterSdk.platformVersion;
      expect(version, isNotNull);
    });

    test('get version', () async {
      final String? version = await LlamaMobileVDFlutterSdk.version;
      expect(version, isNotNull);
    });

    test('get version major', () async {
      final int? major = await LlamaMobileVDFlutterSdk.versionMajor;
      expect(major, isNotNull);
      expect(major, equals(0));
    });

    test('get version minor', () async {
      final int? minor = await LlamaMobileVDFlutterSdk.versionMinor;
      expect(minor, isNotNull);
      expect(minor, equals(1));
    });

    test('get version patch', () async {
      final int? patch = await LlamaMobileVDFlutterSdk.versionPatch;
      expect(patch, isNotNull);
      expect(patch, equals(0));
    });
  });

  // Test different dimensions and metrics for VectorStore
  for (final dimension in [64, 128, 256, 1024, 3096]) {
    for (final metric in [
      DistanceMetric.l2,
      DistanceMetric.cosine,
      DistanceMetric.dot
    ]) {
      group('VectorStore (${dimension}D, ${metric.name})', () {
        late VectorStore vectorStore;

        setUp(() async {
          vectorStore = await VectorStore.create(dimension, metric);
        });

        tearDown(() async {
          await vectorStore.destroy();
        });

        test('add and get vector', () async {
          const id = 1;
          final vector = List.generate(dimension, (index) => index.toDouble());

          await vectorStore.addVector(id, vector);
          final retrievedVector = await vectorStore.getVector(id);

          expect(retrievedVector, isNotNull);
          expect(retrievedVector!.length, equals(dimension));
          for (int i = 0; i < dimension; i++) {
            expect(retrievedVector[i], closeTo(vector[i], 0.001));
          }
        });

        test('search vectors with 100 vectors', () async {
          // Add 100 vectors
          for (int i = 0; i < 100; i++) {
            final vector = List.generate(
                dimension, (index) => (i * 10 + index).toDouble());
            await vectorStore.addVector(i, vector);
          }

          // Search for the first vector
          final queryVector =
              List.generate(dimension, (index) => index.toDouble());
          final results = await vectorStore.search(queryVector, 5);

          expect(results, isNotEmpty);
          expect(results.length, equals(5));
          expect(results[0].id, equals(0));
        });

        test('search vectors with 1000 vectors', () async {
          // Add 1000 vectors
          for (int i = 0; i < 1000; i++) {
            final vector = List.generate(
                dimension, (index) => (i * 10 + index).toDouble());
            await vectorStore.addVector(i, vector);
          }

          // Search for the first vector
          final queryVector =
              List.generate(dimension, (index) => index.toDouble());
          final results = await vectorStore.search(queryVector, 5);

          expect(results, isNotEmpty);
          expect(results.length, equals(5));
          expect(results[0].id, equals(0));
        });

        test('remove vector', () async {
          const id = 1;
          final vector = List.generate(dimension, (index) => index.toDouble());

          await vectorStore.addVector(id, vector);
          expect(await vectorStore.contains(id), isTrue);

          await vectorStore.removeVector(id);
          expect(await vectorStore.contains(id), isFalse);
        });

        test('get size with 10000 vectors', () async {
          expect(await vectorStore.getSize(), equals(0));

          // Add 10000 vectors
          for (int i = 0; i < 10000; i++) {
            final vector = List.generate(
                dimension, (index) => (i * 10 + index).toDouble());
            await vectorStore.addVector(i, vector);
          }

          expect(await vectorStore.getSize(), equals(10000));
        });

        test('get dimension', () async {
          expect(await vectorStore.getDimension(), equals(dimension));
        });

        test('get metric', () async {
          expect(await vectorStore.getMetric(), equals(metric));
        });

        test('update vector', () async {
          const id = 1;
          final initialVector =
              List.generate(dimension, (index) => index.toDouble());
          final updatedVector =
              List.generate(dimension, (index) => (index * 2).toDouble());

          await vectorStore.addVector(id, initialVector);
          await vectorStore.updateVector(id, updatedVector);

          final retrievedVector = await vectorStore.getVector(id);
          expect(retrievedVector, isNotNull);
          for (int i = 0; i < dimension; i++) {
            expect(retrievedVector![i], closeTo(updatedVector[i], 0.001));
          }
        });

        test('reserve capacity', () async {
          const capacity = 10000;
          final success = await vectorStore.reserve(capacity);
          expect(success, isTrue);
        });

        test('clear vectors', () async {
          // Add 1000 vectors
          for (int i = 0; i < 1000; i++) {
            final vector = List.generate(
                dimension, (index) => (i * 10 + index).toDouble());
            await vectorStore.addVector(i, vector);
          }

          expect(await vectorStore.getSize(), equals(1000));
          await vectorStore.clear();
          expect(await vectorStore.getSize(), equals(0));
        });
      });
    }
  }

  // Test different dimensions and metrics for HNSWIndex
  for (final dimension in [64, 128, 256, 1024, 3096]) {
    for (final metric in [
      DistanceMetric.l2,
      DistanceMetric.cosine,
      DistanceMetric.dot
    ]) {
      group('HNSWIndex (${dimension}D, ${metric.name})', () {
        late HNSWIndex hnswIndex;
        const maxElements = 100000;

        setUp(() async {
          hnswIndex = await HNSWIndex.create(dimension, metric, maxElements);
        });

        tearDown(() async {
          await hnswIndex.destroy();
        });

        test('add and search vectors with 1000 vectors', () async {
          // Add 1000 vectors
          for (int i = 0; i < 1000; i++) {
            final vector = List.generate(
                dimension, (index) => (i * 10 + index).toDouble());
            await hnswIndex.addVector(i, vector);
          }

          // Search for the first vector
          final queryVector =
              List.generate(dimension, (index) => index.toDouble());
          final results = await hnswIndex.search(queryVector, 5);

          expect(results, isNotEmpty);
          expect(results.length, equals(5));
          expect(results[0].id, equals(0));
        });

        test('add and search vectors with 10000 vectors', () async {
          // Add 10000 vectors
          for (int i = 0; i < 10000; i++) {
            final vector = List.generate(
                dimension, (index) => (i * 10 + index).toDouble());
            await hnswIndex.addVector(i, vector);
          }

          // Search for the first vector
          final queryVector =
              List.generate(dimension, (index) => index.toDouble());
          final results = await hnswIndex.search(queryVector, 5);

          expect(results, isNotEmpty);
          expect(results.length, equals(5));
          expect(results[0].id, equals(0));
        });

        test('set and get efSearch', () async {
          const efSearch = 64;
          await hnswIndex.setEfSearch(efSearch);
          expect(await hnswIndex.getEfSearch(), equals(efSearch));
        });

        test('get size and capacity', () async {
          expect(await hnswIndex.getSize(), equals(0));
          expect(await hnswIndex.getCapacity(), equals(maxElements));

          // Add 1000 vectors
          for (int i = 0; i < 1000; i++) {
            final vector = List.generate(
                dimension, (index) => (i * 10 + index).toDouble());
            await hnswIndex.addVector(i, vector);
          }

          expect(await hnswIndex.getSize(), equals(1000));
        });

        test('get dimension', () async {
          expect(await hnswIndex.getDimension(), equals(dimension));
        });

        test('contains and getVector', () async {
          const id = 1;
          final vector = List.generate(dimension, (index) => index.toDouble());

          await hnswIndex.addVector(id, vector);
          expect(await hnswIndex.contains(id), isTrue);

          final retrievedVector = await hnswIndex.getVector(id);
          expect(retrievedVector, isNotNull);
          expect(retrievedVector!.length, equals(dimension));
          for (int i = 0; i < dimension; i++) {
            expect(retrievedVector[i], closeTo(vector[i], 0.001));
          }
        });

        test('save and load', () async {
          const filename = 'test_hnsw_index.dat';

          // Add some vectors
          for (int i = 0; i < 100; i++) {
            final vector = List.generate(
                dimension, (index) => (i * 10 + index).toDouble());
            await hnswIndex.addVector(i, vector);
          }

          // Save index
          final saveSuccess = await hnswIndex.save(filename);
          expect(saveSuccess, isTrue);

          // Destroy and load
          await hnswIndex.destroy();
          final loadedIndex = await HNSWIndex.load(filename);

          // Verify size
          expect(await loadedIndex.getSize(), equals(100));
          expect(await loadedIndex.getDimension(), equals(dimension));

          // Clean up
          await loadedIndex.destroy();
          if (File(filename).existsSync()) {
            File(filename).deleteSync();
          }
        });
      });
    }
  }

  // Test different dimensions and metrics for MMapVectorStore
  for (final dimension in [64, 128, 256, 1024, 3096]) {
    for (final metric in [
      DistanceMetric.l2,
      DistanceMetric.cosine,
      DistanceMetric.dot
    ]) {
      group('MMapVectorStore (${dimension}D, ${metric.name})', () {
        late MMapVectorStoreBuilder builder;
        late MMapVectorStore mmapVectorStore;
        final filename = 'test_mmap_vector_store_${dimension}d.dat';

        setUp(() async {
          // Create and populate builder with 1000 vectors
          builder = await MMapVectorStoreBuilder.create(dimension, metric);

          // Test reserve method
          final reserveSuccess = await builder.reserve(10000);
          expect(reserveSuccess, isTrue);

          for (int i = 0; i < 1000; i++) {
            final vector = List.generate(
                dimension, (index) => (i * 10 + index).toDouble());
            await builder.addVector(i, vector);
          }

          // Save and open MMapVectorStore
          await builder.save(filename);
          await builder.destroy();

          mmapVectorStore = await MMapVectorStore.open(filename);
        });

        tearDown(() async {
          await mmapVectorStore.close();
          if (File(filename).existsSync()) {
            File(filename).deleteSync();
          }
        });

        test('get vector', () async {
          const id = 1;
          final vector = await mmapVectorStore.getVector(id);

          expect(vector, isNotNull);
          expect(vector!.length, equals(dimension));
        });

        test('search vectors', () async {
          // Search for the first vector
          final queryVector =
              List.generate(dimension, (index) => index.toDouble());
          final results = await mmapVectorStore.search(queryVector, 5);

          expect(results, isNotEmpty);
          expect(results.length, equals(5));
          expect(results[0].id, equals(0));
        });

        test('contains vector', () async {
          expect(await mmapVectorStore.contains(1), isTrue);
          expect(await mmapVectorStore.contains(9999), isFalse);
        });

        test('get size, dimension, and metric', () async {
          expect(await mmapVectorStore.getSize(), equals(1000));
          expect(await mmapVectorStore.getDimension(), equals(dimension));
          expect(await mmapVectorStore.getMetric(), equals(metric));
        });

        test('builder getSize and getDimension', () async {
          final testBuilder =
              await MMapVectorStoreBuilder.create(dimension, metric);
          expect(await testBuilder.getSize(), equals(0));
          expect(await testBuilder.getDimension(), equals(dimension));
          await testBuilder.destroy();
        });
      });
    }
  }
}
