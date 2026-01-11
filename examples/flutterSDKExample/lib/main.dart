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
  int _vectorId = 1;
  String _advancedOperationResult = '';
  bool _isGettingVector = false;
  List<double>? _currentVector;
  int _reserveCapacity = 1000;

  // HNSW Index state
  HNSWIndex? _hnswIndex;
  List<SearchResult> _hnswIndexResults = [];
  int _hnswVectorId = 1;
  int _hnswEfSearchValue = 50;
  String _hnswAdvancedResult = '';
  bool _isGettingHNSWVector = false;
  List<double>? _currentHNSWVector;
  String _hnswFilePath = '/tmp/hnsw_index.ann';

  // UI state
  int _dimension = 128;
  DistanceMetric _selectedMetric = DistanceMetric.l2;
  int _hnswM = 16;
  int _hnswEfConstruction = 200;
  int _searchK = 5;
  int _efSearch = 50;
  String _statusMessage = 'Ready';

  // Version info state
  String _versionInfo = '';

  // Create a vector with random values
  List<double> _createRandomVector(int dimension) {
    final List<double> vector = [];
    for (int i = 0; i < dimension; i++) {
      vector.add(Math.random() * 2 - 1); // Values between -1 and 1
    }
    return vector;
  }

  // Get vector from VectorStore
  Future<void> _getVectorFromStore() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Getting vector $_vectorId from VectorStore...';
        _isGettingVector = true;
      });

      final vector = await _vectorStore!.get(_vectorId);

      setState(() {
        _currentVector = vector;
        _advancedOperationResult = 'Vector $_vectorId retrieved successfully';
        _statusMessage = 'Vector retrieved successfully';
        _isGettingVector = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting vector: $e';
        _advancedOperationResult = 'Error: $e';
        _isGettingVector = false;
      });
    }
  }

  // Remove vector from VectorStore
  Future<void> _removeVectorFromStore() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Removing vector $_vectorId from VectorStore...';
      });

      await _vectorStore!.remove(_vectorId);

      setState(() {
        _advancedOperationResult = 'Vector $_vectorId removed successfully';
        _statusMessage = 'Vector removed successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error removing vector: $e';
        _advancedOperationResult = 'Error: $e';
      });
    }
  }

  // Contains vector in VectorStore
  Future<void> _containsVectorInStore() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage =
            'Checking if vector $_vectorId exists in VectorStore...';
      });

      final exists = await _vectorStore!.contains(_vectorId);

      setState(() {
        _advancedOperationResult =
            'Vector $_vectorId ${exists ? 'exists' : 'does not exist'}';
        _statusMessage = exists ? 'Vector exists' : 'Vector does not exist';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking vector: $e';
        _advancedOperationResult = 'Error: $e';
      });
    }
  }

  // Update vector in VectorStore
  Future<void> _updateVectorInStore() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Updating vector $_vectorId in VectorStore...';
      });

      final newVector = _createRandomVector(_dimension);
      await _vectorStore!.update(_vectorId, newVector);

      setState(() {
        _currentVector = newVector;
        _advancedOperationResult = 'Vector $_vectorId updated successfully';
        _statusMessage = 'Vector updated successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error updating vector: $e';
        _advancedOperationResult = 'Error: $e';
      });
    }
  }

  // Reserve space in VectorStore
  Future<void> _reserveVectorStore() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage =
            'Reserving space for $_reserveCapacity vectors in VectorStore...';
      });

      await _vectorStore!.reserve(_reserveCapacity);

      setState(() {
        _advancedOperationResult =
            'Reserved space for $_reserveCapacity vectors';
        _statusMessage = 'Reserved space successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error reserving space: $e';
        _advancedOperationResult = 'Error: $e';
      });
    }
  }

  // Get VectorStore dimension
  Future<void> _getVectorStoreDimension() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Getting VectorStore dimension...';
      });

      final dimension = await _vectorStore!.dimension;

      setState(() {
        _advancedOperationResult = 'VectorStore dimension: $dimension';
        _statusMessage = 'Dimension retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting dimension: $e';
        _advancedOperationResult = 'Error: $e';
      });
    }
  }

  // Get VectorStore metric
  Future<void> _getVectorStoreMetric() async {
    if (_vectorStore == null) {
      setState(() {
        _statusMessage = 'Please create a VectorStore first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Getting VectorStore metric...';
      });

      final metric = await _vectorStore!.metric;

      setState(() {
        _advancedOperationResult =
            'VectorStore metric: ${metric.toString().split('.').last}';
        _statusMessage = 'Metric retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting metric: $e';
        _advancedOperationResult = 'Error: $e';
      });
    }
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

  // Get vector from HNSWIndex
  Future<void> _getVectorFromHNSW() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Getting vector $_hnswVectorId from HNSWIndex...';
        _isGettingHNSWVector = true;
      });

      final vector = await _hnswIndex!.getVector(_hnswVectorId);

      setState(() {
        _currentHNSWVector = vector;
        _hnswAdvancedResult = 'Vector $_hnswVectorId retrieved successfully';
        _statusMessage = 'Vector retrieved successfully';
        _isGettingHNSWVector = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting vector: $e';
        _hnswAdvancedResult = 'Error: $e';
        _isGettingHNSWVector = false;
      });
    }
  }

  // Contains vector in HNSWIndex
  Future<void> _containsVectorInHNSW() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage =
            'Checking if vector $_hnswVectorId exists in HNSWIndex...';
      });

      final exists = await _hnswIndex!.contains(_hnswVectorId);

      setState(() {
        _hnswAdvancedResult =
            'Vector $_hnswVectorId ${exists ? 'exists' : 'does not exist'}';
        _statusMessage = exists ? 'Vector exists' : 'Vector does not exist';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking vector: $e';
        _hnswAdvancedResult = 'Error: $e';
      });
    }
  }

  // Get HNSW efSearch
  Future<void> _getHNSWEfSearch() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Getting HNSW efSearch...';
      });

      final efSearch = await _hnswIndex!.getEfSearch();

      setState(() {
        _hnswEfSearchValue = efSearch;
        _hnswAdvancedResult = 'HNSW efSearch: $efSearch';
        _statusMessage = 'efSearch retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting efSearch: $e';
        _hnswAdvancedResult = 'Error: $e';
      });
    }
  }

  // Set HNSW efSearch
  Future<void> _setHNSWEfSearch() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Setting HNSW efSearch to $_hnswEfSearchValue...';
      });

      await _hnswIndex!.setEfSearch(_hnswEfSearchValue);

      setState(() {
        _efSearch = _hnswEfSearchValue;
        _hnswAdvancedResult = 'HNSW efSearch set to $_hnswEfSearchValue';
        _statusMessage = 'efSearch set successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error setting efSearch: $e';
        _hnswAdvancedResult = 'Error: $e';
      });
    }
  }

  // Get HNSW dimension
  Future<void> _getHNSWDimension() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Getting HNSW dimension...';
      });

      final dimension = await _hnswIndex!.dimension;

      setState(() {
        _hnswAdvancedResult = 'HNSW dimension: $dimension';
        _statusMessage = 'Dimension retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting dimension: $e';
        _hnswAdvancedResult = 'Error: $e';
      });
    }
  }

  // Get HNSW capacity
  Future<void> _getHNSWCapacity() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Getting HNSW capacity...';
      });

      final capacity = await _hnswIndex!.capacity;

      setState(() {
        _hnswAdvancedResult = 'HNSW capacity: $capacity';
        _statusMessage = 'Capacity retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting capacity: $e';
        _hnswAdvancedResult = 'Error: $e';
      });
    }
  }

  // Save HNSWIndex
  Future<void> _saveHNSWIndex() async {
    if (_hnswIndex == null) {
      setState(() {
        _statusMessage = 'Please create a HNSWIndex first';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Saving HNSWIndex to $_hnswFilePath...';
      });

      await _hnswIndex!.save(_hnswFilePath);

      setState(() {
        _hnswAdvancedResult = 'HNSWIndex saved to $_hnswFilePath';
        _statusMessage = 'HNSWIndex saved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error saving HNSWIndex: $e';
        _hnswAdvancedResult = 'Error: $e';
      });
    }
  }

  // Load HNSWIndex
  Future<void> _loadHNSWIndex() async {
    try {
      setState(() {
        _statusMessage = 'Loading HNSWIndex from $_hnswFilePath...';
      });

      // Release any existing HNSW index
      if (_hnswIndex != null) {
        await _hnswIndex!.dispose();
      }

      final hnswIndex = await HNSWIndex.load(_hnswFilePath);

      setState(() {
        _hnswIndex = hnswIndex;
        _hnswIndexResults.clear();
        _hnswAdvancedResult = 'HNSWIndex loaded from $_hnswFilePath';
        _statusMessage = 'HNSWIndex loaded successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading HNSWIndex: $e';
        _hnswAdvancedResult = 'Error: $e';
      });
    }
  }

  // Get full version
  Future<void> _getVersion() async {
    try {
      setState(() {
        _statusMessage = 'Getting full version...';
      });

      final version = await getLlamaMobileVDVersion();

      setState(() {
        _versionInfo = 'Full Version: $version';
        _statusMessage = 'Version retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting version: $e';
        _versionInfo = 'Error: $e';
      });
    }
  }

  // Get major version
  Future<void> _getVersionMajor() async {
    try {
      setState(() {
        _statusMessage = 'Getting major version...';
      });

      final major = await getLlamaMobileVDVersionMajor();

      setState(() {
        _versionInfo = 'Major Version: $major';
        _statusMessage = 'Major version retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting major version: $e';
        _versionInfo = 'Error: $e';
      });
    }
  }

  // Get minor version
  Future<void> _getVersionMinor() async {
    try {
      setState(() {
        _statusMessage = 'Getting minor version...';
      });

      final minor = await getLlamaMobileVDVersionMinor();

      setState(() {
        _versionInfo = 'Minor Version: $minor';
        _statusMessage = 'Minor version retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting minor version: $e';
        _versionInfo = 'Error: $e';
      });
    }
  }

  // Get patch version
  Future<void> _getVersionPatch() async {
    try {
      setState(() {
        _statusMessage = 'Getting patch version...';
      });

      final patch = await getLlamaMobileVDVersionPatch();

      setState(() {
        _versionInfo = 'Patch Version: $patch';
        _statusMessage = 'Patch version retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting patch version: $e';
        _versionInfo = 'Error: $e';
      });
    }
  }

  // Get detailed version info
  Future<void> _getVersionDetailed() async {
    try {
      setState(() {
        _statusMessage = 'Getting detailed version info...';
      });

      final version = await getLlamaMobileVDVersion();
      final major = await getLlamaMobileVDVersionMajor();
      final minor = await getLlamaMobileVDVersionMinor();
      final patch = await getLlamaMobileVDVersionPatch();

      setState(() {
        _versionInfo =
            'Version: $version\nMajor: $major\nMinor: $minor\nPatch: $patch';
        _statusMessage = 'Detailed version info retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting detailed version info: $e';
        _versionInfo = 'Error: $e';
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

            const SizedBox(height: 16.0),

            // Advanced VectorStore operations
            if (_vectorStore != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced VectorStore Operations',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Vector ID input
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: _vectorId.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final id = int.tryParse(value);
                            if (id != null) {
                              setState(() {
                                _vectorId = id;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Vector ID',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _getVectorFromStore,
                          child: const Text('Get Vector'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // Basic operations row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _removeVectorFromStore,
                          child: const Text('Remove Vector'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _containsVectorInStore,
                          child: const Text('Contains Vector'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _updateVectorInStore,
                          child: const Text('Update Vector'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // VectorStore properties row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _getVectorStoreDimension,
                          child: const Text('Get Dimension'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _getVectorStoreMetric,
                          child: const Text('Get Metric'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _reserveVectorStore,
                          child: const Text('Reserve Space'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // Advanced operation result
                  if (_advancedOperationResult.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        _advancedOperationResult,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ),

                  // Current vector preview
                  if (_isGettingVector)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (_currentVector != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12.0),
                        const Text(
                          'Vector Preview:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            '[${_currentVector!.take(5).map((v) => v.toStringAsFixed(4)).join(', ')}${_currentVector!.length > 5 ? ', ...' : ''}]',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16.0),
                ],
              ),

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

            const SizedBox(height: 16.0),

            // Advanced HNSWIndex operations
            if (_hnswIndex != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced HNSWIndex Operations',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Vector ID input
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: _hnswVectorId.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final id = int.tryParse(value);
                            if (id != null) {
                              setState(() {
                                _hnswVectorId = id;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Vector ID',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _getVectorFromHNSW,
                          child: const Text('Get Vector'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // Basic operations row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _containsVectorInHNSW,
                          child: const Text('Contains Vector'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _getHNSWEfSearch,
                          child: const Text('Get efSearch'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // efSearch input and set
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: _hnswEfSearchValue.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final efSearch = int.tryParse(value);
                            if (efSearch != null) {
                              setState(() {
                                _hnswEfSearchValue = efSearch;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'efSearch',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _setHNSWEfSearch,
                          child: const Text('Set efSearch'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // HNSW properties row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _getHNSWDimension,
                          child: const Text('Get Dimension'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _getHNSWCapacity,
                          child: const Text('Get Capacity'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // File operations section
                  const Text(
                    'File Operations',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // File path input
                  TextFormField(
                    initialValue: _hnswFilePath,
                    onChanged: (value) {
                      setState(() {
                        _hnswFilePath = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'File Path'),
                  ),

                  const SizedBox(height: 8.0),

                  // Save/Load buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveHNSWIndex,
                          child: const Text('Save Index'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loadHNSWIndex,
                          child: const Text('Load Index'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // Advanced operation result
                  if (_hnswAdvancedResult.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        _hnswAdvancedResult,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ),

                  // Current HNSW vector preview
                  if (_isGettingHNSWVector)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (_currentHNSWVector != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12.0),
                        const Text(
                          'Vector Preview:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            '[${_currentHNSWVector!.take(5).map((v) => v.toStringAsFixed(4)).join(', ')}${_currentHNSWVector!.length > 5 ? ', ...' : ''}]',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16.0),
                ],
              ),

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

            const SizedBox(height: 24.0),

            // Version APIs section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Version Information',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),

                // Version buttons row 1
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _getVersion,
                        child: const Text('Get Full Version'),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _getVersionDetailed,
                        child: const Text('Get Detailed Info'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8.0),

                // Version buttons row 2
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _getVersionMajor,
                        child: const Text('Get Major'),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _getVersionMinor,
                        child: const Text('Get Minor'),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _getVersionPatch,
                        child: const Text('Get Patch'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12.0),

                // Version info display
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    _versionInfo.isEmpty
                        ? 'Version information will be displayed here'
                        : _versionInfo,
                    style: const TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32.0),
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
