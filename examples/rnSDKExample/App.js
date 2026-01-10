import React, { useState } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  TouchableOpacity,
  Slider,
  Picker,
  Platform,
  ActivityIndicator,
} from 'react-native';
import LlamaMobileVD, { DistanceMetric } from 'llama_mobile_vd-react-native-SDK';

const App = () => {
  // Vector Store state
  const [vectorStore, setVectorStore] = useState(null);
  const [vectorStoreCount, setVectorStoreCount] = useState(0);
  const [vectorStoreResults, setVectorStoreResults] = useState([]);
  
  // HNSW Index state
  const [hnswIndex, setHnswIndex] = useState(null);
  const [hnswIndexCount, setHnswIndexCount] = useState(0);
  const [hnswIndexResults, setHnswIndexResults] = useState([]);
  
  // Configuration state
  const [dimension, setDimension] = useState(128);
  const [selectedMetric, setSelectedMetric] = useState(DistanceMetric.L2);
  const [hnswM, setHnswM] = useState(16);
  const [hnswEfConstruction, setHnswEfConstruction] = useState(200);
  const [searchK, setSearchK] = useState(5);
  const [efSearch, setEfSearch] = useState(50);
  
  // Status state
  const [statusMessage, setStatusMessage] = useState('Ready');
  const [isLoading, setIsLoading] = useState(false);
  
  // Create a vector with random values
  const createRandomVector = (dimension) => {
    const vector = [];
    for (let i = 0; i < dimension; i++) {
      vector.push(Math.random() * 2 - 1); // Values between -1 and 1
    }
    return vector;
  };
  
  // Show loading indicator
  const showLoading = () => {
    setIsLoading(true);
  };
  
  // Hide loading indicator
  const hideLoading = () => {
    setIsLoading(false);
  };
  
  // VectorStore operations
  const createVectorStore = async () => {
    try {
      showLoading();
      setStatusMessage('Creating VectorStore...');
      
      const options = {
        dimension,
        metric: selectedMetric,
      };
      
      const vectorStoreInstance = await LlamaMobileVD.createVectorStore(options);
      
      setVectorStore(vectorStoreInstance);
      setVectorStoreCount(0);
      setVectorStoreResults([]);
      setStatusMessage('VectorStore created successfully');
    } catch (error) {
      setStatusMessage(`Error creating VectorStore: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  const addVectorsToStore = async () => {
    if (!vectorStore) {
      setStatusMessage('Please create a VectorStore first');
      return;
    }
    
    try {
      showLoading();
      setStatusMessage('Adding 100 vectors to VectorStore...');
      
      for (let i = 0; i < 100; i++) {
        const vector = createRandomVector(dimension);
        await vectorStore.addVector({ vector, vectorId: i + 1 });
      }
      
      const count = await vectorStore.count();
      
      setVectorStoreCount(count);
      setStatusMessage('Added 100 vectors to VectorStore');
    } catch (error) {
      setStatusMessage(`Error adding vectors to VectorStore: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  const searchVectorStore = async () => {
    if (!vectorStore) {
      setStatusMessage('Please create a VectorStore first');
      return;
    }
    
    if (vectorStoreCount === 0) {
      setStatusMessage('Please add vectors to the VectorStore first');
      return;
    }
    
    try {
      showLoading();
      setStatusMessage('Searching VectorStore...');
      
      const queryVector = createRandomVector(dimension);
      const results = await vectorStore.search({ queryVector, k: searchK });
      
      setVectorStoreResults(results);
      setStatusMessage('Search completed successfully');
    } catch (error) {
      setStatusMessage(`Error searching VectorStore: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  const clearVectorStore = async () => {
    if (!vectorStore) {
      setStatusMessage('Please create a VectorStore first');
      return;
    }
    
    try {
      showLoading();
      setStatusMessage('Clearing VectorStore...');
      
      await vectorStore.clear();
      
      setVectorStoreCount(0);
      setVectorStoreResults([]);
      setStatusMessage('VectorStore cleared successfully');
    } catch (error) {
      setStatusMessage(`Error clearing VectorStore: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  const releaseVectorStore = async () => {
    if (!vectorStore) {
      setStatusMessage('Please create a VectorStore first');
      return;
    }
    
    try {
      showLoading();
      setStatusMessage('Releasing VectorStore...');
      
      await vectorStore.release();
      
      setVectorStore(null);
      setVectorStoreCount(0);
      setVectorStoreResults([]);
      setStatusMessage('VectorStore released successfully');
    } catch (error) {
      setStatusMessage(`Error releasing VectorStore: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  // HNSWIndex operations
  const createHNSWIndex = async () => {
    try {
      showLoading();
      setStatusMessage('Creating HNSWIndex...');
      
      const options = {
        dimension,
        metric: selectedMetric,
        m: hnswM,
        efConstruction: hnswEfConstruction,
      };
      
      const hnswIndexInstance = await LlamaMobileVD.createHNSWIndex(options);
      
      setHnswIndex(hnswIndexInstance);
      setHnswIndexCount(0);
      setHnswIndexResults([]);
      setStatusMessage('HNSWIndex created successfully');
    } catch (error) {
      setStatusMessage(`Error creating HNSWIndex: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  const addVectorsToHNSW = async () => {
    if (!hnswIndex) {
      setStatusMessage('Please create a HNSWIndex first');
      return;
    }
    
    try {
      showLoading();
      setStatusMessage('Adding 100 vectors to HNSWIndex...');
      
      for (let i = 0; i < 100; i++) {
        const vector = createRandomVector(dimension);
        await hnswIndex.addVector({ vector, vectorId: i + 1 });
      }
      
      const count = await hnswIndex.count();
      
      setHnswIndexCount(count);
      setStatusMessage('Added 100 vectors to HNSWIndex');
    } catch (error) {
      setStatusMessage(`Error adding vectors to HNSWIndex: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  const searchHNSWIndex = async () => {
    if (!hnswIndex) {
      setStatusMessage('Please create a HNSWIndex first');
      return;
    }
    
    if (hnswIndexCount === 0) {
      setStatusMessage('Please add vectors to the HNSWIndex first');
      return;
    }
    
    try {
      showLoading();
      setStatusMessage('Searching HNSWIndex...');
      
      const queryVector = createRandomVector(dimension);
      const results = await hnswIndex.search({ queryVector, k: searchK, efSearch });
      
      setHnswIndexResults(results);
      setStatusMessage('Search completed successfully');
    } catch (error) {
      setStatusMessage(`Error searching HNSWIndex: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  const clearHNSWIndex = async () => {
    if (!hnswIndex) {
      setStatusMessage('Please create a HNSWIndex first');
      return;
    }
    
    try {
      showLoading();
      setStatusMessage('Clearing HNSWIndex...');
      
      await hnswIndex.clear();
      
      setHnswIndexCount(0);
      setHnswIndexResults([]);
      setStatusMessage('HNSWIndex cleared successfully');
    } catch (error) {
      setStatusMessage(`Error clearing HNSWIndex: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  const releaseHNSWIndex = async () => {
    if (!hnswIndex) {
      setStatusMessage('Please create a HNSWIndex first');
      return;
    }
    
    try {
      showLoading();
      setStatusMessage('Releasing HNSWIndex...');
      
      await hnswIndex.release();
      
      setHnswIndex(null);
      setHnswIndexCount(0);
      setHnswIndexResults([]);
      setStatusMessage('HNSWIndex released successfully');
    } catch (error) {
      setStatusMessage(`Error releasing HNSWIndex: ${error.message}`);
    } finally {
      hideLoading();
    }
  };
  
  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        {/* Status message */}
        <View style={styles.statusContainer}>
          {isLoading ? (
            <ActivityIndicator size="small" color="#0000ff" />
          ) : null}
          <Text style={styles.statusText}>{statusMessage}</Text>
        </View>
        
        {/* Configuration section */}
        <Text style={styles.sectionTitle}>Configuration</Text>
        
        {/* Dimension slider */}
        <View style={styles.sliderContainer}>
          <Text style={styles.sliderLabel}>Vector Dimension: {dimension}</Text>
          <Slider
            style={styles.slider}
            minimumValue={10}
            maximumValue={256}
            step={1}
            value={dimension}
            onValueChange={setDimension}
          />
        </View>
        
        {/* Distance metric picker */}
        <View style={styles.pickerContainer}>
          <Text style={styles.pickerLabel}>Distance Metric</Text>
          {Platform.OS === 'ios' ? (
            <Picker
              selectedValue={selectedMetric}
              style={styles.picker}
              onValueChange={(itemValue) => setSelectedMetric(itemValue)}
            >
              <Picker.Item label="L2" value={DistanceMetric.L2} />
              <Picker.Item label="COSINE" value={DistanceMetric.COSINE} />
              <Picker.Item label="DOT" value={DistanceMetric.DOT} />
            </Picker>
          ) : (
            <Picker
              selectedValue={selectedMetric}
              style={styles.picker}
              onValueChange={(itemValue) => setSelectedMetric(itemValue)}
            >
              <Picker.Item label="L2" value={DistanceMetric.L2} />
              <Picker.Item label="COSINE" value={DistanceMetric.COSINE} />
              <Picker.Item label="DOT" value={DistanceMetric.DOT} />
            </Picker>
          )}
        </View>
        
        {/* HNSW parameters */}
        <Text style={styles.sectionTitle}>HNSW Parameters</Text>
        
        {/* HNSW M slider */}
        <View style={styles.sliderContainer}>
          <Text style={styles.sliderLabel}>M (Connections per node): {hnswM}</Text>
          <Slider
            style={styles.slider}
            minimumValue={5}
            maximumValue={50}
            step={1}
            value={hnswM}
            onValueChange={setHnswM}
          />
        </View>
        
        {/* HNSW efConstruction slider */}
        <View style={styles.sliderContainer}>
          <Text style={styles.sliderLabel}>efConstruction: {hnswEfConstruction}</Text>
          <Slider
            style={styles.slider}
            minimumValue={50}
            maximumValue={500}
            step={1}
            value={hnswEfConstruction}
            onValueChange={setHnswEfConstruction}
          />
        </View>
        
        {/* Search K slider */}
        <View style={styles.sliderContainer}>
          <Text style={styles.sliderLabel}>Search k: {searchK}</Text>
          <Slider
            style={styles.slider}
            minimumValue={1}
            maximumValue={20}
            step={1}
            value={searchK}
            onValueChange={setSearchK}
          />
        </View>
        
        {/* efSearch slider */}
        <View style={styles.sliderContainer}>
          <Text style={styles.sliderLabel}>HNSW efSearch: {efSearch}</Text>
          <Slider
            style={styles.slider}
            minimumValue={10}
            maximumValue={200}
            step={1}
            value={efSearch}
            onValueChange={setEfSearch}
          />
        </View>
        
        {/* VectorStore section */}
        <Text style={styles.sectionTitle}>VectorStore (Exact Search)</Text>
        
        <View style={styles.buttonRow}>
          <TouchableOpacity
            style={styles.button}
            onPress={createVectorStore}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Create VectorStore</Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={styles.button}
            onPress={addVectorsToStore}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Add 100 Vectors</Text>
          </TouchableOpacity>
        </View>
        
        <View style={styles.buttonRow}>
          <TouchableOpacity
            style={styles.button}
            onPress={searchVectorStore}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Search</Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={styles.button}
            onPress={clearVectorStore}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Clear</Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={styles.button}
            onPress={releaseVectorStore}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Release</Text>
          </TouchableOpacity>
        </View>
        
        <View style={styles.infoContainer}>
          <Text style={styles.infoText}>
            VectorStore Status: {vectorStore ? 'Created' : 'None'}
          </Text>
          <Text style={styles.infoText}>Vector count: {vectorStoreCount}</Text>
        </View>
        
        {vectorStoreResults.length > 0 && (
          <View style={styles.resultsContainer}>
            <Text style={styles.resultsTitle}>Search Results:</Text>
            {vectorStoreResults.map((result, index) => (
              <View key={index} style={styles.resultItem}>
                <Text style={styles.resultIndex}>Vector {result.index}</Text>
                <Text style={styles.resultDistance}>Distance: {result.distance.toFixed(6)}</Text>
              </View>
            ))}
          </View>
        )}
        
        {/* HNSWIndex section */}
        <Text style={styles.sectionTitle}>HNSWIndex (Approximate Search)</Text>
        
        <View style={styles.buttonRow}>
          <TouchableOpacity
            style={styles.button}
            onPress={createHNSWIndex}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Create HNSWIndex</Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={styles.button}
            onPress={addVectorsToHNSW}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Add 100 Vectors</Text>
          </TouchableOpacity>
        </View>
        
        <View style={styles.buttonRow}>
          <TouchableOpacity
            style={styles.button}
            onPress={searchHNSWIndex}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Search</Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={styles.button}
            onPress={clearHNSWIndex}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Clear</Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={styles.button}
            onPress={releaseHNSWIndex}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>Release</Text>
          </TouchableOpacity>
        </View>
        
        <View style={styles.infoContainer}>
          <Text style={styles.infoText}>
            HNSWIndex Status: {hnswIndex ? 'Created' : 'None'}
          </Text>
          <Text style={styles.infoText}>Vector count: {hnswIndexCount}</Text>
        </View>
        
        {hnswIndexResults.length > 0 && (
          <View style={styles.resultsContainer}>
            <Text style={styles.resultsTitle}>Search Results:</Text>
            {hnswIndexResults.map((result, index) => (
              <View key={index} style={styles.resultItem}>
                <Text style={styles.resultIndex}>Vector {result.index}</Text>
                <Text style={styles.resultDistance}>Distance: {result.distance.toFixed(6)}</Text>
              </View>
            ))}
          </View>
        )}
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    padding: 16,
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#E3F2FD',
    padding: 12,
    borderRadius: 8,
    marginBottom: 16,
  },
  statusText: {
    fontSize: 16,
    marginLeft: 8,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  sliderContainer: {
    marginBottom: 16,
  },
  sliderLabel: {
    fontSize: 14,
    marginBottom: 4,
  },
  slider: {
    width: '100%',
    height: 40,
  },
  pickerContainer: {
    marginBottom: 16,
  },
  pickerLabel: {
    fontSize: 14,
    marginBottom: 4,
  },
  picker: {
    height: 50,
    width: '100%',
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  button: {
    flex: 1,
    backgroundColor: '#2196F3',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
    marginHorizontal: 4,
  },
  buttonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  infoContainer: {
    marginBottom: 16,
  },
  infoText: {
    fontSize: 14,
    marginBottom: 4,
  },
  resultsContainer: {
    marginBottom: 24,
  },
  resultsTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  resultItem: {
    backgroundColor: '#F5F5F5',
    padding: 8,
    borderRadius: 4,
    marginBottom: 4,
  },
  resultIndex: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  resultDistance: {
    fontSize: 12,
    color: '#666',
  },
});

export default App;
