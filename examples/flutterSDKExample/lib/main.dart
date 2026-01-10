import 'package:flutter/material.dart';
import 'package:llama_mobile_vd/llama_mobile_vd.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LlamaMobileVD Flutter Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'LlamaMobileVD Flutter Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Vector Store state
  VectorStore? _vectorStore;
  List<SearchResult> _vectorStoreResults = [];

  // HNSW Index state
  HNSWIndex? _hnswIndex;
  List<SearchResult> _hnswIndexResults = [];

  // UI state
  int _dimension = 128;
  DistanceMetric _selectedMetric = DistanceMetric.l2;
  int _hnswM = 16;
  int _hnswEfConstruction = 200;
  int _searchK = 5;
  int _efSearch = 50;
  String _statusMessage = 'Ready';

  // Create a vector with random values
  List<double> _createRandomVector(int dimension) {
    final List<double> vector = [];
    for (int i = 0; i < dimension; i++) {
      vector.add(Math.random() * 2 - 1); // Values between -1 and 1
    }
    return vector;
  }

  // Create Vector Store
  Future<void> _createVectorStore() async {
    try {
      setState(() {
        _statusMessage = 'Creating VectorStore...';
      });

      final vectorStore = await VectorStore.create(
        dimension: _dimension,
        metric: _selectedMetric,
      );

      setState(() {
        _vectorStore = vectorStore;
        _vectorStoreResults.clear();
        _statusMessage = 'VectorStore created successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error creating VectorStore: $e';
      });
    }
  }

  // Create HNSW Index
  Future<void> _createHNSWIndex() async {
    try {
      setState(() {
        _statusMessage = 'Creating HNSWIndex...';
      });

      final hnswIndex = await HNSWIndex.create(
        dimension: _dimension,
        metric: _selectedMetric,
        m: _hnswM,
        efConstruction: _hnswEfConstruction,
      );

      setState(() {
        _hnswIndex = hnswIndex;
        _hnswIndexResults.clear();
        _statusMessage = 'HNSWIndex created successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error creating HNSWIndex: $e';
      });
    }
  }

  // Add vectors to VectorStore
  Future<void> _addVectorsToStore() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Adding 100 vectors to VectorStore...';
      });

      for (int i = 0; i < 100; i++) {
        final vector = _createRandomVector(_dimension);
        await _vectorStore!.addVector(vector, i + 1);
      }

      setState(() {
        _statusMessage = 'Added 100 vectors to VectorStore';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error adding vectors to VectorStore: $e';
      });
    }
  }

  // Add vectors to HNSWIndex
  Future<void> _addVectorsToHNSW() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Adding 100 vectors to HNSWIndex...';
      });

      for (int i = 0; i < 100; i++) {
        final vector = _createRandomVector(_dimension);
        await _hnswIndex!.addVector(vector, i + 1);
      }

      setState(() {
        _statusMessage = 'Added 100 vectors to HNSWIndex';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error adding vectors to HNSWIndex: $e';
      });
    }
  }

  // Search VectorStore
  Future<void> _searchVectorStore() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Searching VectorStore...';
      });

      final queryVector = _createRandomVector(_dimension);
      final results = await _vectorStore!.search(queryVector, _searchK);

      setState(() {
        _vectorStoreResults = results;
        _statusMessage = 'Search completed successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error searching VectorStore: $e';
      });
    }
  }

  // Search HNSWIndex
  Future<void> _searchHNSWIndex() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Searching HNSWIndex...';
      });

      final queryVector = _createRandomVector(_dimension);
      final results = await _hnswIndex!.search(
        queryVector,
        _searchK,
        efSearch: _efSearch,
      );

      setState(() {
        _hnswIndexResults = results;
        _statusMessage = 'Search completed successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error searching HNSWIndex: $e';
      });
    }
  }

  // Clear VectorStore
  Future<void> _clearVectorStore() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Clearing VectorStore...';
      });

      await _vectorStore!.clear();

      setState(() {
        _vectorStoreResults.clear();
        _statusMessage = 'VectorStore cleared successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error clearing VectorStore: $e';
      });
    }
  }

  // Clear HNSWIndex
  Future<void> _clearHNSWIndex() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Clearing HNSWIndex...';
      });

      await _hnswIndex!.clear();

      setState(() {
        _hnswIndexResults.clear();
        _statusMessage = 'HNSWIndex cleared successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error clearing HNSWIndex: $e';
      });
    }
  }

  // Release VectorStore
  Future<void> _releaseVectorStore() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Releasing VectorStore...';
      });

      await _vectorStore!.dispose();

      setState(() {
        _vectorStore = null;
        _vectorStoreResults.clear();
        _statusMessage = 'VectorStore released successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error releasing VectorStore: $e';
      });
    }
  }

  // Release HNSWIndex
  Future<void> _releaseHNSWIndex() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Releasing HNSWIndex...';
      });

      await _hnswIndex!.dispose();

      setState(() {
        _hnswIndex = null;
        _hnswIndexResults.clear();
        _statusMessage = 'HNSWIndex released successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error releasing HNSWIndex: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Status message
            Container(
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _statusMessage,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),

            // Configuration section
            const Text(
              'Configuration',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),

            // Dimension slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vector Dimension: $_dimension'),
                Slider(
                  value: _dimension.toDouble(),
                  min: 10.0,
                  max: 256.0,
                  divisions: 246,
                  onChanged: (value) {
                    setState(() {
                      _dimension = value.toInt();
                    });
                  },
                ),
              ],
            ),

            // Distance metric dropdown
            DropdownButtonFormField<DistanceMetric>(
              value: _selectedMetric,
              decoration: const InputDecoration(labelText: 'Distance Metric'),
              items: DistanceMetric.values.map((metric) {
                return DropdownMenuItem(
                  value: metric,
                  child: Text(metric.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMetric = value!;
                });
              },
            ),

            // HNSW parameters
            const SizedBox(height: 16.0),
            const Text(
              'HNSW Parameters',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('M (Connections per node): $_hnswM'),
                Slider(
                  value: _hnswM.toDouble(),
                  min: 5.0,
                  max: 50.0,
                  divisions: 45,
                  onChanged: (value) {
                    setState(() {
                      _hnswM = value.toInt();
                    });
                  },
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('efConstruction: $_hnswEfConstruction'),
                Slider(
                  value: _hnswEfConstruction.toDouble(),
                  min: 50.0,
                  max: 500.0,
                  divisions: 45,
                  onChanged: (value) {
                    setState(() {
                      _hnswEfConstruction = value.toInt();
                    });
                  },
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search k: $_searchK'),
                Slider(
                  value: _searchK.toDouble(),
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  onChanged: (value) {
                    setState(() {
                      _searchK = value.toInt();
                    });
                  },
                ),
              ],
            ),

            // HNSW Search parameters
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HNSW efSearch: $_efSearch'),
                Slider(
                  value: _efSearch.toDouble(),
                  min: 10.0,
                  max: 200.0,
                  divisions: 19,
                  onChanged: (value) {
                    setState(() {
                      _efSearch = value.toInt();
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // VectorStore section
            const Text(
              'VectorStore (Exact Search)',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createVectorStore,
                    child: const Text('Create VectorStore'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addVectorsToStore,
                    child: const Text('Add 100 Vectors'),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _searchVectorStore,
                    child: const Text('Search'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearVectorStore,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _releaseVectorStore,
                    child: const Text('Release'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8.0),

            Text(
              'VectorStore Status: ${_vectorStore != null ? 'Created' : 'None'}',
            ),

            const SizedBox(height: 12.0),

            // VectorStore results
            if (_vectorStoreResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Results:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      itemCount: _vectorStoreResults.length,
                      itemBuilder: (context, index) {
                        final result = _vectorStoreResults[index];
                        return ListTile(
                          title: Text('Vector ID: ${result.id}'),
                          subtitle: Text(
                            'Distance: ${result.distance.toStringAsFixed(6)}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24.0),

            // HNSWIndex section
            const Text(
              'HNSWIndex (Approximate Search)',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createHNSWIndex,
                    child: const Text('Create HNSWIndex'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addVectorsToHNSW,
                    child: const Text('Add 100 Vectors'),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _searchHNSWIndex,
                    child: const Text('Search'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearHNSWIndex,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _releaseHNSWIndex,
                    child: const Text('Release'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8.0),

            Text(
              'HNSWIndex Status: ${_hnswIndex != null ? 'Created' : 'None'}',
            ),

            const SizedBox(height: 12.0),

            // HNSWIndex results
            if (_hnswIndexResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Results:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      itemCount: _hnswIndexResults.length,
                      itemBuilder: (context, index) {
                        final result = _hnswIndexResults[index];
                        return ListTile(
                          title: Text('Vector ID: ${result.id}'),
                          subtitle: Text(
                            'Distance: ${result.distance.toStringAsFixed(6)}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Helper class for math operations
class Math {
  static double random() {
    return DateTime.now().millisecondsSinceEpoch / 10000000.0 % 1.0;
  }
}
