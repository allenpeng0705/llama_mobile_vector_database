import 'package:flutter/material.dart';
import 'package:llama_mobile_vd_flutter_sdk/llama_mobile_vd_flutter_sdk.dart';
import 'dart:io';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LlamaMobileVD Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Vector Store state
  VectorStore? _vectorStore;
  int _vectorStoreCount = 0;
  List<SearchResult> _vectorStoreResults = [];

  // HNSW Index state
  HNSWIndex? _hnswIndex;
  int _hnswIndexCount = 0;
  List<SearchResult> _hnswIndexResults = [];

  // MMapVectorStore state
  MMapVectorStore? _mmapVectorStore;
  int _mmapVectorStoreCount = 0;
  int _mmapVectorStoreDimension = 0;
  String _mmapVectorStoreMetric = "";
  List<SearchResult> _mmapVectorStoreResults = [];

  // Configuration state
  int _dimension = 128;
  DistanceMetric _selectedMetric = DistanceMetric.cosine;
  int _hnswM = 16;
  int _hnswEfConstruction = 200;
  int _searchK = 5;
  int _efSearch = 50;

  // MMap file path
  String _mmapFilePath = "";

  // Status message
  String _statusMessage = "Ready";

  @override
  void initState() {
    super.initState();
    _initializeMMapFilePath();
  }

  void _initializeMMapFilePath() {
    final directory = Directory.systemTemp.path;
    _mmapFilePath = '$directory/vector_store.mmap';
  }

  List<double> _createRandomVector(int dimension) {
    final random = Random();
    return List.generate(dimension, (i) => random.nextDouble() * 100);
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  void _updateVectorStoreInfo() {
    setState(() {
      // Vector store info updated implicitly
    });
  }

  void _updateHNSWIndexInfo() {
    setState(() {
      // HNSW index info updated implicitly
    });
  }

  void _updateMMapVectorStoreInfo() {
    setState(() {
      // MMap vector store info updated implicitly
    });
  }

  // VectorStore operations
  Future<void> _createVectorStore() async {
    _updateStatus("Creating VectorStore...");

    try {
      _vectorStore = await VectorStore.create(_dimension, _selectedMetric);
      _vectorStoreCount = 0;
      _vectorStoreResults.clear();
      _updateVectorStoreInfo();
      _updateStatus("VectorStore created successfully");
    } catch (e) {
      _updateStatus("Error creating VectorStore: $e");
    }
  }

  Future<void> _addVectorsToStore() async {
    if (_vectorStore == null) {
      _updateStatus("Please create a VectorStore first");
      return;
    }

    _updateStatus("Adding 100 vectors to VectorStore...");

    try {
      for (int i = 0; i < 100; i++) {
        await _vectorStore!.addVector(i + 1, _createRandomVector(_dimension));
      }

      _vectorStoreCount = await _vectorStore!.getSize();
      _updateVectorStoreInfo();
      _updateStatus("Added 100 vectors to VectorStore");
    } catch (e) {
      _updateStatus("Error adding vectors to VectorStore: $e");
    }
  }

  Future<void> _searchVectorStore() async {
    if (_vectorStore == null) {
      _updateStatus("Please create a VectorStore first");
      return;
    }

    if (_vectorStoreCount == 0) {
      _updateStatus("Please add vectors to the VectorStore first");
      return;
    }

    _updateStatus("Searching VectorStore...");

    try {
      final queryVector = _createRandomVector(_dimension);
      _vectorStoreResults = await _vectorStore!.search(queryVector, _searchK);
      _updateStatus("Search completed successfully");
    } catch (e) {
      _updateStatus("Error searching VectorStore: $e");
    }
  }

  Future<void> _clearVectorStore() async {
    if (_vectorStore == null) {
      _updateStatus("Please create a VectorStore first");
      return;
    }

    try {
      await _vectorStore!.clear();
      _vectorStoreCount = 0;
      _vectorStoreResults.clear();
      _updateVectorStoreInfo();
      _updateStatus("VectorStore cleared successfully");
    } catch (e) {
      _updateStatus("Error clearing VectorStore: $e");
    }
  }

  Future<void> _releaseVectorStore() async {
    if (_vectorStore == null) {
      _updateStatus("Please create a VectorStore first");
      return;
    }

    try {
      await _vectorStore!.destroy();
      _vectorStore = null;
      _vectorStoreCount = 0;
      _vectorStoreResults.clear();
      _updateVectorStoreInfo();
      _updateStatus("VectorStore released successfully");
    } catch (e) {
      _updateStatus("Error releasing VectorStore: $e");
    }
  }

  // HNSWIndex operations
  Future<void> _createHNSWIndex() async {
    _updateStatus("Creating HNSWIndex...");

    try {
      _hnswIndex = await HNSWIndex.createWithParams(
        _dimension,
        _selectedMetric,
        1000,
        _hnswM,
        _hnswEfConstruction,
        42,
      );
      _hnswIndexCount = 0;
      _hnswIndexResults.clear();
      _updateHNSWIndexInfo();
      _updateStatus("HNSWIndex created successfully");
    } catch (e) {
      _updateStatus("Error creating HNSWIndex: $e");
    }
  }

  Future<void> _addVectorsToHNSW() async {
    if (_hnswIndex == null) {
      _updateStatus("Please create a HNSWIndex first");
      return;
    }

    _updateStatus("Adding 100 vectors to HNSWIndex...");

    try {
      for (int i = 0; i < 100; i++) {
        await _hnswIndex!.addVector(i + 1, _createRandomVector(_dimension));
      }

      _hnswIndexCount = await _hnswIndex!.getSize();
      _updateHNSWIndexInfo();
      _updateStatus("Added 100 vectors to HNSWIndex");
    } catch (e) {
      _updateStatus("Error adding vectors to HNSWIndex: $e");
    }
  }

  Future<void> _searchHNSWIndex() async {
    if (_hnswIndex == null) {
      _updateStatus("Please create a HNSWIndex first");
      return;
    }

    if (_hnswIndexCount == 0) {
      _updateStatus("Please add vectors to the HNSWIndex first");
      return;
    }

    _updateStatus("Searching HNSWIndex...");

    try {
      final queryVector = _createRandomVector(_dimension);
      await _hnswIndex!.setEfSearch(_efSearch);
      _hnswIndexResults = await _hnswIndex!.search(queryVector, _searchK);
      _updateStatus("Search completed successfully");
    } catch (e) {
      _updateStatus("Error searching HNSWIndex: $e");
    }
  }

  Future<void> _clearHNSWIndex() async {
    if (_hnswIndex == null) {
      _updateStatus("Please create a HNSWIndex first");
      return;
    }

    try {
      await _hnswIndex!.destroy();
      _hnswIndex = await HNSWIndex.createWithParams(
        _dimension,
        _selectedMetric,
        1000,
        _hnswM,
        _hnswEfConstruction,
        42,
      );
      _hnswIndexCount = 0;
      _hnswIndexResults.clear();
      _updateHNSWIndexInfo();
      _updateStatus("HNSWIndex cleared successfully");
    } catch (e) {
      _updateStatus("Error clearing HNSWIndex: $e");
    }
  }

  Future<void> _releaseHNSWIndex() async {
    if (_hnswIndex == null) {
      _updateStatus("Please create a HNSWIndex first");
      return;
    }

    try {
      await _hnswIndex!.destroy();
      _hnswIndex = null;
      _hnswIndexCount = 0;
      _hnswIndexResults.clear();
      _updateHNSWIndexInfo();
      _updateStatus("HNSWIndex released successfully");
    } catch (e) {
      _updateStatus("Error releasing HNSWIndex: $e");
    }
  }

  // MMapVectorStore operations
  Future<void> _createMMapVectorStore() async {
    _updateStatus("Creating MMapVectorStore...");

    try {
      final builder = await MMapVectorStoreBuilder.create(
        _dimension,
        _selectedMetric,
      );

      // Add some vectors
      for (int i = 0; i < 100; i++) {
        await builder.addVector(i + 1, _createRandomVector(_dimension));
      }

      await builder.save(_mmapFilePath);
      await builder.destroy();

      _updateStatus("MMapVectorStore created successfully");
    } catch (e) {
      _updateStatus("Error creating MMapVectorStore: $e");
    }
  }

  Future<void> _openMMapVectorStore() async {
    _updateStatus("Opening MMapVectorStore...");

    try {
      _mmapVectorStore = await MMapVectorStore.open(_mmapFilePath);
      _mmapVectorStoreCount = await _mmapVectorStore!.getSize();
      _mmapVectorStoreDimension = _dimension;
      _mmapVectorStoreMetric = _selectedMetric.toString();
      _mmapVectorStoreResults.clear();
      _updateMMapVectorStoreInfo();
      _updateStatus("MMapVectorStore opened successfully");
    } catch (e) {
      _updateStatus("Error opening MMapVectorStore: $e");
    }
  }

  Future<void> _searchMMapVectorStore() async {
    if (_mmapVectorStore == null) {
      _updateStatus("Please open a MMapVectorStore first");
      return;
    }

    _updateStatus("Searching MMapVectorStore...");

    try {
      final queryVector = _createRandomVector(_dimension);
      _mmapVectorStoreResults = await _mmapVectorStore!.search(
        queryVector,
        _searchK,
      );
      _updateStatus("Search completed successfully");
    } catch (e) {
      _updateStatus("Error searching MMapVectorStore: $e");
    }
  }

  Future<void> _releaseMMapVectorStore() async {
    if (_mmapVectorStore == null) {
      _updateStatus("Please open a MMapVectorStore first");
      return;
    }

    try {
      await _mmapVectorStore!.close();
      _mmapVectorStore = null;
      _mmapVectorStoreCount = 0;
      _mmapVectorStoreDimension = 0;
      _mmapVectorStoreMetric = "";
      _mmapVectorStoreResults.clear();
      _updateMMapVectorStoreInfo();
      _updateStatus("MMapVectorStore released successfully");
    } catch (e) {
      _updateStatus("Error releasing MMapVectorStore: $e");
    }
  }

  Widget _buildStatusSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Configuration",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // Dimension slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Vector Dimension: $_dimension"),
              Slider(
                value: _dimension.toDouble(),
                min: 10,
                max: 256,
                onChanged: (value) {
                  setState(() {
                    _dimension = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),

        // Distance metric
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Distance Metric:"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<DistanceMetric>(
                      title: const Text("L2"),
                      value: DistanceMetric.l2,
                      groupValue: _selectedMetric,
                      onChanged: (value) {
                        setState(() {
                          _selectedMetric = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<DistanceMetric>(
                      title: const Text("Cosine"),
                      value: DistanceMetric.cosine,
                      groupValue: _selectedMetric,
                      onChanged: (value) {
                        setState(() {
                          _selectedMetric = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<DistanceMetric>(
                      title: const Text("Dot"),
                      value: DistanceMetric.dot,
                      groupValue: _selectedMetric,
                      onChanged: (value) {
                        setState(() {
                          _selectedMetric = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHNSWParametersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "HNSW Parameters",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // HNSW M slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("M (Connections per node): $_hnswM"),
              Slider(
                value: _hnswM.toDouble(),
                min: 5,
                max: 50,
                onChanged: (value) {
                  setState(() {
                    _hnswM = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),

        // HNSW efConstruction slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("efConstruction: $_hnswEfConstruction"),
              Slider(
                value: _hnswEfConstruction.toDouble(),
                min: 50,
                max: 500,
                onChanged: (value) {
                  setState(() {
                    _hnswEfConstruction = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),

        // Search K slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Search k: $_searchK"),
              Slider(
                value: _searchK.toDouble(),
                min: 1,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    _searchK = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),

        // efSearch slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("HNSW efSearch: $_efSearch"),
              Slider(
                value: _efSearch.toDouble(),
                min: 10,
                max: 200,
                onChanged: (value) {
                  setState(() {
                    _efSearch = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVectorStoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "VectorStore (Exact Search)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // VectorStore buttons row 1
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _createVectorStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Create VectorStore"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addVectorsToStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Add 100 Vectors"),
                ),
              ),
            ],
          ),
        ),

        // VectorStore buttons row 2
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _searchVectorStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Search"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearVectorStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Clear"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _releaseVectorStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Release"),
                ),
              ),
            ],
          ),
        ),

        // VectorStore info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "VectorStore Status: ${_vectorStore != null ? "Created" : "None"}\n"
            "Vector count: $_vectorStoreCount",
            style: const TextStyle(fontSize: 14),
          ),
        ),

        // VectorStore results
        if (_vectorStoreResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _vectorStoreResults.length,
                itemBuilder: (context, index) {
                  final result = _vectorStoreResults[index];
                  return ListTile(
                    title: Text("ID: ${result.id}"),
                    subtitle: Text("Distance: ${result.distance}"),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHNSWIndexSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "HNSWIndex (Approximate Search)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // HNSWIndex buttons row 1
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _createHNSWIndex,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Create HNSWIndex"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addVectorsToHNSW,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Add 100 Vectors"),
                ),
              ),
            ],
          ),
        ),

        // HNSWIndex buttons row 2
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _searchHNSWIndex,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Search"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearHNSWIndex,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Clear"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _releaseHNSWIndex,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Release"),
                ),
              ),
            ],
          ),
        ),

        // HNSWIndex info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "HNSWIndex Status: ${_hnswIndex != null ? "Created" : "None"}\n"
            "Vector count: $_hnswIndexCount",
            style: const TextStyle(fontSize: 14),
          ),
        ),

        // HNSWIndex results
        if (_hnswIndexResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _hnswIndexResults.length,
                itemBuilder: (context, index) {
                  final result = _hnswIndexResults[index];
                  return ListTile(
                    title: Text("ID: ${result.id}"),
                    subtitle: Text("Distance: ${result.distance}"),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMMapVectorStoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "MMapVectorStore (Memory-Mapped Vector Store)",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // MMap file path
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: TextEditingController(text: _mmapFilePath),
            onChanged: (value) {
              _mmapFilePath = value;
            },
            decoration: const InputDecoration(
              labelText: "File Path",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        // Create MMapVectorStore button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: _createMMapVectorStore,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Create MMapVectorStore"),
          ),
        ),

        // MMapVectorStore buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _openMMapVectorStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Open MMapVectorStore"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _searchMMapVectorStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Search"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _releaseMMapVectorStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Release"),
                ),
              ),
            ],
          ),
        ),

        // MMapVectorStore info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "MMapVectorStore Status: ${_mmapVectorStore != null ? "Opened" : "None"}\n"
            "Vector count: $_mmapVectorStoreCount\n"
            "Dimension: $_mmapVectorStoreDimension\n"
            "Metric: $_mmapVectorStoreMetric",
            style: const TextStyle(fontSize: 14),
          ),
        ),

        // MMapVectorStore results
        if (_mmapVectorStoreResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _mmapVectorStoreResults.length,
                itemBuilder: (context, index) {
                  final result = _mmapVectorStoreResults[index];
                  return ListTile(
                    title: Text("ID: ${result.id}"),
                    subtitle: Text("Distance: ${result.distance}"),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LlamaMobileVD Flutter Example"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusSection(),
            _buildConfigurationSection(),
            _buildHNSWParametersSection(),
            _buildVectorStoreSection(),
            _buildHNSWIndexSection(),
            _buildMMapVectorStoreSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
