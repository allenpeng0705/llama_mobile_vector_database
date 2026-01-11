/**
 * LlamaMobileVD React Native Example App
 * Demonstrates all VectorStore, HNSWIndex, and Version APIs
 */

import React, { useState } from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  Switch,
  ActivityIndicator,
  Alert,
} from 'react-native';

import LlamaMobileVD, { DistanceMetric } from 'llama-mobile-vd';

function App(): JSX.Element {
  // Configuration state
  const [dimension, setDimension] = useState(128);
  const [metric, setMetric] = useState(DistanceMetric.L2);
  const [vectorCount, setVectorCount] = useState(100);
  
  // VectorStore state
  const [vectorStoreId, setVectorStoreId] = useState<string | null>(null);
  const [vectorStoreCount, setVectorStoreCount] = useState(0);
  const [vectorStoreResults, setVectorStoreResults] = useState<any[]>([]);
  
  // Advanced VectorStore state
  const [vectorId, setVectorId] = useState(1);
  const [vectorStoreAdvancedResult, setVectorStoreAdvancedResult] = useState<string | null>(null);
  const [vectorStoreLoading, setVectorStoreLoading] = useState(false);
  
  // HNSWIndex configuration state
  const [hnswM, setHnswM] = useState(16);
  const [hnswEfConstruction, setHnswEfConstruction] = useState(200);
  const [hnswEfSearch, setHnswEfSearch] = useState(100);
  
  // HNSWIndex state
  const [hnswIndexId, setHnswIndexId] = useState<string | null>(null);
  const [hnswIndexCount, setHnswIndexCount] = useState(0);
  const [hnswIndexResults, setHnswIndexResults] = useState<any[]>([]);
  const [hnswIndexAdvancedResult, setHnswIndexAdvancedResult] = useState<string | null>(null);
  const [hnswIndexLoading, setHnswIndexLoading] = useState(false);
  
  // Version state
  const [versionInfo, setVersionInfo] = useState<string | null>(null);
  
  // Status message
  const [status, setStatus] = useState('Ready');

  // Create a random vector
  const createRandomVector = (dim: number): number[] => {
    const vector: number[] = [];
    for (let i = 0; i < dim; i++) {
      vector.push(Math.random() * 2 - 1); // Values between -1 and 1
    }
    return vector;
  };

  // Create VectorStore
  const handleCreateVectorStore = async () => {
    try {
      setStatus('Creating VectorStore...');
      const result = await LlamaMobileVD.createVectorStore({
        dimension,
        metric,
      });
      setVectorStoreId(result.id);
      setVectorStoreCount(0);
      setVectorStoreResults([]);
      setVectorStoreAdvancedResult(null);
      setStatus(`VectorStore created with ID: ${result.id}`);
    } catch (error) {
      setStatus(`Error creating VectorStore: ${error}`);
      Alert.alert('Error', `Failed to create VectorStore: ${error}`);
    }
  };

  // Add vectors to VectorStore
  const handleAddVectorsToStore = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus(`Adding ${vectorCount} vectors to VectorStore...`);
      setVectorStoreLoading(true);

      // Add vectors sequentially
      for (let i = 0; i < vectorCount; i++) {
        const vector = createRandomVector(dimension);
        await LlamaMobileVD.addVectorToStore({
          id: vectorStoreId,
          vector,
          vectorId: i + 1,
        });
      }

      // Update vector count
      const countResult = await LlamaMobileVD.countVectorStore({ id: vectorStoreId });
      setVectorStoreCount(countResult.count);
      setStatus(`Added ${vectorCount} vectors to VectorStore`);
    } catch (error) {
      setStatus(`Error adding vectors: ${error}`);
      Alert.alert('Error', `Failed to add vectors: ${error}`);
    } finally {
      setVectorStoreLoading(false);
    }
  };

  // Search VectorStore
  const handleSearchVectorStore = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus('Searching VectorStore...');
      setVectorStoreLoading(true);

      const queryVector = createRandomVector(dimension);
      const results = await LlamaMobileVD.searchVectorStore({
        id: vectorStoreId,
        queryVector,
        k: 5,
      });

      setVectorStoreResults(results);
      setStatus('Search completed successfully');
    } catch (error) {
      setStatus(`Error searching VectorStore: ${error}`);
      Alert.alert('Error', `Failed to search VectorStore: ${error}`);
    } finally {
      setVectorStoreLoading(false);
    }
  };

  // Clear VectorStore
  const handleClearVectorStore = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus('Clearing VectorStore...');
      await LlamaMobileVD.clearVectorStore({ id: vectorStoreId });
      setVectorStoreCount(0);
      setVectorStoreResults([]);
      setVectorStoreAdvancedResult(null);
      setStatus('VectorStore cleared successfully');
    } catch (error) {
      setStatus(`Error clearing VectorStore: ${error}`);
      Alert.alert('Error', `Failed to clear VectorStore: ${error}`);
    }
  };

  // Release VectorStore
  const handleReleaseVectorStore = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus('Releasing VectorStore...');
      await LlamaMobileVD.releaseVectorStore({ id: vectorStoreId });
      setVectorStoreId(null);
      setVectorStoreCount(0);
      setVectorStoreResults([]);
      setVectorStoreAdvancedResult(null);
      setStatus('VectorStore released successfully');
    } catch (error) {
      setStatus(`Error releasing VectorStore: ${error}`);
      Alert.alert('Error', `Failed to release VectorStore: ${error}`);
    }
  };

  // Advanced VectorStore Operations
  
  // Get vector from VectorStore
  const handleGetVectorFromStore = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus(`Getting vector ${vectorId} from VectorStore...`);
      setVectorStoreLoading(true);

      const result = await LlamaMobileVD.getVectorFromStore({
        id: vectorStoreId,
        vectorId,
      });

      if (result) {
        const vectorPreview = result.slice(0, 5).map((v: number) => v.toFixed(4)).join(', ');
        setVectorStoreAdvancedResult(`Vector ${vectorId}: [${vectorPreview}${result.length > 5 ? ', ...' : ''}]`);
      } else {
        setVectorStoreAdvancedResult(`Vector ${vectorId} not found`);
      }
      setStatus('Vector retrieved successfully');
    } catch (error) {
      setStatus(`Error getting vector: ${error}`);
      setVectorStoreAdvancedResult(`Error: ${error}`);
    } finally {
      setVectorStoreLoading(false);
    }
  };

  // Remove vector from VectorStore
  const handleRemoveVectorFromStore = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus(`Removing vector ${vectorId} from VectorStore...`);
      const result = await LlamaMobileVD.removeVectorFromStore({
        id: vectorStoreId,
        vectorId,
      });

      if (result) {
        // Update count
        const countResult = await LlamaMobileVD.countVectorStore({ id: vectorStoreId });
        setVectorStoreCount(countResult.count);
        setVectorStoreAdvancedResult(`Vector ${vectorId} removed successfully`);
        setStatus('Vector removed successfully');
      } else {
        setVectorStoreAdvancedResult(`Vector ${vectorId} not found`);
        setStatus(`Vector ${vectorId} not found`);
      }
    } catch (error) {
      setStatus(`Error removing vector: ${error}`);
      setVectorStoreAdvancedResult(`Error: ${error}`);
    }
  };

  // Contains vector in VectorStore
  const handleContainsVectorInStore = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus(`Checking if vector ${vectorId} exists in VectorStore...`);
      const result = await LlamaMobileVD.containsVectorInStore({
        id: vectorStoreId,
        vectorId,
      });

      setVectorStoreAdvancedResult(`Vector ${vectorId} ${result ? 'exists' : 'does not exist'}`);
      setStatus(result ? 'Vector exists' : 'Vector does not exist');
    } catch (error) {
      setStatus(`Error checking vector: ${error}`);
      setVectorStoreAdvancedResult(`Error: ${error}`);
    }
  };

  // Update vector in VectorStore
  const handleUpdateVectorInStore = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus(`Updating vector ${vectorId} in VectorStore...`);
      setVectorStoreLoading(true);

      const newVector = createRandomVector(dimension);
      const result = await LlamaMobileVD.updateVectorInStore({
        id: vectorStoreId,
        vectorId,
        vector: newVector,
      });

      if (result) {
        const vectorPreview = newVector.slice(0, 5).map((v: number) => v.toFixed(4)).join(', ');
        setVectorStoreAdvancedResult(`Vector ${vectorId} updated successfully: [${vectorPreview}, ...]`);
        setStatus('Vector updated successfully');
      } else {
        setVectorStoreAdvancedResult(`Vector ${vectorId} not found`);
        setStatus(`Vector ${vectorId} not found`);
      }
    } catch (error) {
      setStatus(`Error updating vector: ${error}`);
      setVectorStoreAdvancedResult(`Error: ${error}`);
    } finally {
      setVectorStoreLoading(false);
    }
  };

  // Reserve space in VectorStore
  const handleReserveVectorStore = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus('Reserving space in VectorStore...');
      await LlamaMobileVD.reserveVectorStore({
        id: vectorStoreId,
        capacity: 1000,
      });
      setVectorStoreAdvancedResult('Reserved space for 1000 vectors');
      setStatus('Space reserved successfully');
    } catch (error) {
      setStatus(`Error reserving space: ${error}`);
      setVectorStoreAdvancedResult(`Error: ${error}`);
    }
  };

  // Get VectorStore dimension
  const handleGetVectorStoreDimension = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus('Getting VectorStore dimension...');
      const result = await LlamaMobileVD.getVectorStoreDimension({ id: vectorStoreId });
      setVectorStoreAdvancedResult(`VectorStore dimension: ${result.dimension}`);
      setStatus('Dimension retrieved successfully');
    } catch (error) {
      setStatus(`Error getting dimension: ${error}`);
      setVectorStoreAdvancedResult(`Error: ${error}`);
    }
  };

  // Get VectorStore metric
  const handleGetVectorStoreMetric = async () => {
    if (!vectorStoreId) {
      Alert.alert('Error', 'Please create a VectorStore first');
      return;
    }

    try {
      setStatus('Getting VectorStore metric...');
      const result = await LlamaMobileVD.getVectorStoreMetric({ id: vectorStoreId });
      setVectorStoreAdvancedResult(`VectorStore metric: ${result.metric}`);
      setStatus('Metric retrieved successfully');
    } catch (error) {
      setStatus(`Error getting metric: ${error}`);
      setVectorStoreAdvancedResult(`Error: ${error}`);
    }
  };

  // HNSWIndex Methods
  
  // Create HNSWIndex
  const handleCreateHNSWIndex = async () => {
    try {
      setStatus('Creating HNSWIndex...');
      const result = await LlamaMobileVD.createHNSWIndex({
        dimension,
        metric,
        m: hnswM,
        efConstruction: hnswEfConstruction,
      });
      setHnswIndexId(result.id);
      setHnswIndexCount(0);
      setHnswIndexResults([]);
      setHnswIndexAdvancedResult(null);
      setStatus(`HNSWIndex created with ID: ${result.id}`);
    } catch (error) {
      setStatus(`Error creating HNSWIndex: ${error}`);
      Alert.alert('Error', `Failed to create HNSWIndex: ${error}`);
    }
  };

  // Add vectors to HNSWIndex
  const handleAddVectorsToHNSW = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus(`Adding ${vectorCount} vectors to HNSWIndex...`);
      setHnswIndexLoading(true);

      // Add vectors sequentially
      for (let i = 0; i < vectorCount; i++) {
        const vector = createRandomVector(dimension);
        await LlamaMobileVD.addVectorToHNSW({
          id: hnswIndexId,
          vector,
          vectorId: i + 1,
        });
      }

      // Update vector count
      const countResult = await LlamaMobileVD.countHNSWIndex({ id: hnswIndexId });
      setHnswIndexCount(countResult.count);
      setStatus(`Added ${vectorCount} vectors to HNSWIndex`);
    } catch (error) {
      setStatus(`Error adding vectors: ${error}`);
      Alert.alert('Error', `Failed to add vectors: ${error}`);
    } finally {
      setHnswIndexLoading(false);
    }
  };

  // Search HNSWIndex
  const handleSearchHNSWIndex = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus('Searching HNSWIndex...');
      setHnswIndexLoading(true);

      const queryVector = createRandomVector(dimension);
      const results = await LlamaMobileVD.searchHNSWIndex({
        id: hnswIndexId,
        queryVector,
        k: 5,
        efSearch: hnswEfSearch,
      });

      setHnswIndexResults(results);
      setStatus('Search completed successfully');
    } catch (error) {
      setStatus(`Error searching HNSWIndex: ${error}`);
      Alert.alert('Error', `Failed to search HNSWIndex: ${error}`);
    } finally {
      setHnswIndexLoading(false);
    }
  };

  // Set efSearch for HNSWIndex
  const handleSetHNSWEfSearch = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus(`Setting efSearch to ${hnswEfSearch}...`);
      await LlamaMobileVD.setHNSWEfSearch({
        id: hnswIndexId,
        efSearch: hnswEfSearch,
      });
      setHnswIndexAdvancedResult(`efSearch set to ${hnswEfSearch}`);
      setStatus('efSearch updated successfully');
    } catch (error) {
      setStatus(`Error setting efSearch: ${error}`);
      setHnswIndexAdvancedResult(`Error: ${error}`);
    }
  };

  // Get efSearch from HNSWIndex
  const handleGetHNSWEfSearch = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus('Getting efSearch from HNSWIndex...');
      const result = await LlamaMobileVD.getHNSWEfSearch({ id: hnswIndexId });
      setHnswIndexAdvancedResult(`Current efSearch: ${result.efSearch}`);
      setStatus('efSearch retrieved successfully');
    } catch (error) {
      setStatus(`Error getting efSearch: ${error}`);
      setHnswIndexAdvancedResult(`Error: ${error}`);
    }
  };

  // Check if vector exists in HNSWIndex
  const handleContainsVectorInHNSW = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus(`Checking if vector ${vectorId} exists in HNSWIndex...`);
      const result = await LlamaMobileVD.containsVectorInHNSW({
        id: hnswIndexId,
        vectorId,
      });

      setHnswIndexAdvancedResult(`Vector ${vectorId} ${result ? 'exists' : 'does not exist'}`);
      setStatus(result ? 'Vector exists' : 'Vector does not exist');
    } catch (error) {
      setStatus(`Error checking vector: ${error}`);
      setHnswIndexAdvancedResult(`Error: ${error}`);
    }
  };

  // Get vector from HNSWIndex
  const handleGetVectorFromHNSW = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus(`Getting vector ${vectorId} from HNSWIndex...`);
      setHnswIndexLoading(true);

      const result = await LlamaMobileVD.getVectorFromHNSW({
        id: hnswIndexId,
        vectorId,
      });

      if (result) {
        const vectorPreview = result.slice(0, 5).map((v: number) => v.toFixed(4)).join(', ');
        setHnswIndexAdvancedResult(`Vector ${vectorId}: [${vectorPreview}${result.length > 5 ? ', ...' : ''}]`);
      } else {
        setHnswIndexAdvancedResult(`Vector ${vectorId} not found`);
      }
      setStatus('Vector retrieved successfully');
    } catch (error) {
      setStatus(`Error getting vector: ${error}`);
      setHnswIndexAdvancedResult(`Error: ${error}`);
    } finally {
      setHnswIndexLoading(false);
    }
  };

  // Get HNSWIndex dimension
  const handleGetHNSWDimension = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus('Getting HNSWIndex dimension...');
      const result = await LlamaMobileVD.getHNSWDimension({ id: hnswIndexId });
      setHnswIndexAdvancedResult(`HNSWIndex dimension: ${result.dimension}`);
      setStatus('Dimension retrieved successfully');
    } catch (error) {
      setStatus(`Error getting dimension: ${error}`);
      setHnswIndexAdvancedResult(`Error: ${error}`);
    }
  };

  // Get HNSWIndex capacity
  const handleGetHNSWCapacity = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus('Getting HNSWIndex capacity...');
      const result = await LlamaMobileVD.getHNSWCapacity({ id: hnswIndexId });
      setHnswIndexAdvancedResult(`HNSWIndex capacity: ${result.capacity}`);
      setStatus('Capacity retrieved successfully');
    } catch (error) {
      setStatus(`Error getting capacity: ${error}`);
      setHnswIndexAdvancedResult(`Error: ${error}`);
    }
  };

  // Clear HNSWIndex
  const handleClearHNSWIndex = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus('Clearing HNSWIndex...');
      await LlamaMobileVD.clearHNSWIndex({ id: hnswIndexId });
      setHnswIndexCount(0);
      setHnswIndexResults([]);
      setHnswIndexAdvancedResult(null);
      setStatus('HNSWIndex cleared successfully');
    } catch (error) {
      setStatus(`Error clearing HNSWIndex: ${error}`);
      Alert.alert('Error', `Failed to clear HNSWIndex: ${error}`);
    }
  };

  // Release HNSWIndex
  const handleReleaseHNSWIndex = async () => {
    if (!hnswIndexId) {
      Alert.alert('Error', 'Please create a HNSWIndex first');
      return;
    }

    try {
      setStatus('Releasing HNSWIndex...');
      await LlamaMobileVD.releaseHNSWIndex({ id: hnswIndexId });
      setHnswIndexId(null);
      setHnswIndexCount(0);
      setHnswIndexResults([]);
      setHnswIndexAdvancedResult(null);
      setStatus('HNSWIndex released successfully');
    } catch (error) {
      setStatus(`Error releasing HNSWIndex: ${error}`);
      Alert.alert('Error', `Failed to release HNSWIndex: ${error}`);
    }
  };

  // Version Methods
  
  // Get SDK version
  const handleGetVersion = async () => {
    try {
      setStatus('Getting SDK version...');
      const version = await LlamaMobileVD.getVersion();
      setVersionInfo(`Version: ${version.version}`);
      setStatus('Version retrieved successfully');
    } catch (error) {
      setStatus(`Error getting version: ${error}`);
      setVersionInfo(`Error: ${error}`);
    }
  };

  // Get detailed version information
  const handleGetVersionDetailed = async () => {
    try {
      setStatus('Getting detailed version information...');
      
      const major = await LlamaMobileVD.getVersionMajor();
      const minor = await LlamaMobileVD.getVersionMinor();
      const patch = await LlamaMobileVD.getVersionPatch();
      
      setVersionInfo(`Version: ${major.major}.${minor.minor}.${patch.patch}`);
      setStatus('Detailed version retrieved successfully');
    } catch (error) {
      setStatus(`Error getting detailed version: ${error}`);
      setVersionInfo(`Error: ${error}`);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#f5f5f5" />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={styles.scrollView}>
        <View style={styles.content}>
          <Text style={styles.title}>LlamaMobileVD React Native Example</Text>
          
          {/* Status message */}
          <View style={styles.statusContainer}>
            <Text style={styles.statusLabel}>Status:</Text>
            <Text style={styles.statusText}>{status}</Text>
          </View>

          {/* Configuration section */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Configuration</Text>
            
            <View style={styles.inputGroup}>
              <Text style={styles.label}>Vector Dimension:</Text>
              <TextInput
                style={styles.input}
                value={dimension.toString()}
                onChangeText={(text) => setDimension(parseInt(text) || 128)}
                keyboardType="number-pad"
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>Distance Metric:</Text>
              <View style={styles.metricButtons}>
                <TouchableOpacity
                  style={[styles.metricButton, metric === DistanceMetric.L2 && styles.metricButtonActive]}
                  onPress={() => setMetric(DistanceMetric.L2)}
                >
                  <Text style={[styles.metricButtonText, metric === DistanceMetric.L2 && styles.metricButtonTextActive]}>
                    L2
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.metricButton, metric === DistanceMetric.COSINE && styles.metricButtonActive]}
                  onPress={() => setMetric(DistanceMetric.COSINE)}
                >
                  <Text style={[styles.metricButtonText, metric === DistanceMetric.COSINE && styles.metricButtonTextActive]}>
                    Cosine
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.metricButton, metric === DistanceMetric.DOT && styles.metricButtonActive]}
                  onPress={() => setMetric(DistanceMetric.DOT)}
                >
                  <Text style={[styles.metricButtonText, metric === DistanceMetric.DOT && styles.metricButtonTextActive]}>
                    Dot
                  </Text>
                </TouchableOpacity>
              </View>
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>Vectors to Add:</Text>
              <TextInput
                style={styles.input}
                value={vectorCount.toString()}
                onChangeText={(text) => setVectorCount(parseInt(text) || 100)}
                keyboardType="number-pad"
              />
            </View>
          </View>

          {/* VectorStore section */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>VectorStore (Exact Search)</Text>
            
            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonPrimary]}
                onPress={handleCreateVectorStore}
              >
                <Text style={styles.buttonText}>Create VectorStore</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSecondary, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleAddVectorsToStore}
                disabled={!vectorStoreId || vectorStoreLoading}
              >
                <Text style={styles.buttonText}>{vectorStoreLoading ? 'Adding...' : `Add ${vectorCount} Vectors`}</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonSecondary, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleSearchVectorStore}
                disabled={!vectorStoreId || vectorStoreLoading}
              >
                <Text style={styles.buttonText}>{vectorStoreLoading ? 'Searching...' : 'Search'}</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSecondary, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleClearVectorStore}
                disabled={!vectorStoreId}
              >
                <Text style={styles.buttonText}>Clear</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonDanger, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleReleaseVectorStore}
                disabled={!vectorStoreId}
              >
                <Text style={styles.buttonText}>Release</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.infoContainer}>
              <Text style={styles.infoText}>
                VectorStore Status: {vectorStoreId ? `Created (ID: ${vectorStoreId})` : 'None'}
              </Text>
              <Text style={styles.infoText}>
                Vector Count: {vectorStoreCount}
              </Text>
            </View>

            {/* VectorStore search results */}
            {vectorStoreResults.length > 0 && (
              <View style={styles.resultsContainer}>
                <Text style={styles.resultsTitle}>Search Results:</Text>
                {vectorStoreResults.map((result, index) => (
                  <View key={index} style={styles.resultItem}>
                    <Text style={styles.resultIndex}>Result {index + 1}</Text>
                    <Text style={styles.resultId}>Vector ID: {result.id}</Text>
                    <Text style={styles.resultDistance}>Distance: {result.distance.toFixed(6)}</Text>
                  </View>
                ))}
              </View>
            )}
          </View>

          {/* Advanced VectorStore operations */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Advanced VectorStore Operations</Text>
            
            <View style={styles.inputGroup}>
              <Text style={styles.label}>Vector ID:</Text>
              <TextInput
                style={styles.input}
                value={vectorId.toString()}
                onChangeText={(text) => setVectorId(parseInt(text) || 1)}
                keyboardType="number-pad"
              />
            </View>

            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleGetVectorFromStore}
                disabled={!vectorStoreId || vectorStoreLoading}
              >
                <Text style={styles.buttonSmallText}>{vectorStoreLoading ? 'Getting...' : 'Get Vector'}</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleRemoveVectorFromStore}
                disabled={!vectorStoreId}
              >
                <Text style={styles.buttonSmallText}>Remove Vector</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleContainsVectorInStore}
                disabled={!vectorStoreId}
              >
                <Text style={styles.buttonSmallText}>Contains Vector</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleUpdateVectorInStore}
                disabled={!vectorStoreId || vectorStoreLoading}
              >
                <Text style={styles.buttonSmallText}>{vectorStoreLoading ? 'Updating...' : 'Update Vector'}</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleReserveVectorStore}
                disabled={!vectorStoreId}
              >
                <Text style={styles.buttonSmallText}>Reserve Space</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleGetVectorStoreDimension}
                disabled={!vectorStoreId}
              >
                <Text style={styles.buttonSmallText}>Get Dimension</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !vectorStoreId && styles.buttonDisabled]}
                onPress={handleGetVectorStoreMetric}
                disabled={!vectorStoreId}
              >
                <Text style={styles.buttonSmallText}>Get Metric</Text>
              </TouchableOpacity>
            </View>

            {/* Advanced operation result */}
            {vectorStoreAdvancedResult && (
              <View style={styles.resultContainer}>
                <Text style={styles.resultLabel}>Result:</Text>
                <Text style={styles.resultText}>{vectorStoreAdvancedResult}</Text>
              </View>
            )}
          </View>

          {/* HNSWIndex section */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>HNSWIndex (Approximate Search)</Text>
            
            <View style={styles.inputGroup}>
              <Text style={styles.label}>HNSW M (connections per node):</Text>
              <TextInput
                style={styles.input}
                value={hnswM.toString()}
                onChangeText={(text) => setHnswM(parseInt(text) || 16)}
                keyboardType="number-pad"
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>HNSW efConstruction:</Text>
              <TextInput
                style={styles.input}
                value={hnswEfConstruction.toString()}
                onChangeText={(text) => setHnswEfConstruction(parseInt(text) || 200)}
                keyboardType="number-pad"
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>HNSW efSearch:</Text>
              <TextInput
                style={styles.input}
                value={hnswEfSearch.toString()}
                onChangeText={(text) => setHnswEfSearch(parseInt(text) || 100)}
                keyboardType="number-pad"
              />
            </View>
            
            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonPrimary]}
                onPress={handleCreateHNSWIndex}
              >
                <Text style={styles.buttonText}>Create HNSWIndex</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSecondary, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleAddVectorsToHNSW}
                disabled={!hnswIndexId || hnswIndexLoading}
              >
                <Text style={styles.buttonText}>{hnswIndexLoading ? 'Adding...' : `Add ${vectorCount} Vectors`}</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonSecondary, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleSearchHNSWIndex}
                disabled={!hnswIndexId || hnswIndexLoading}
              >
                <Text style={styles.buttonText}>{hnswIndexLoading ? 'Searching...' : 'Search'}</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSecondary, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleClearHNSWIndex}
                disabled={!hnswIndexId}
              >
                <Text style={styles.buttonText}>Clear</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonDanger, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleReleaseHNSWIndex}
                disabled={!hnswIndexId}
              >
                <Text style={styles.buttonText}>Release</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.infoContainer}>
              <Text style={styles.infoText}>
                HNSWIndex Status: {hnswIndexId ? `Created (ID: ${hnswIndexId})` : 'None'}
              </Text>
              <Text style={styles.infoText}>
                Vector Count: {hnswIndexCount}
              </Text>
            </View>

            {/* HNSWIndex search results */}
            {hnswIndexResults.length > 0 && (
              <View style={styles.resultsContainer}>
                <Text style={styles.resultsTitle}>Search Results:</Text>
                {hnswIndexResults.map((result, index) => (
                  <View key={index} style={styles.resultItem}>
                    <Text style={styles.resultIndex}>Result {index + 1}</Text>
                    <Text style={styles.resultId}>Vector ID: {result.id}</Text>
                    <Text style={styles.resultDistance}>Distance: {result.distance.toFixed(6)}</Text>
                  </View>
                ))}
              </View>
            )}
          </View>

          {/* Advanced HNSWIndex operations */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Advanced HNSWIndex Operations</Text>
            
            <View style={styles.inputGroup}>
              <Text style={styles.label}>Vector ID:</Text>
              <TextInput
                style={styles.input}
                value={vectorId.toString()}
                onChangeText={(text) => setVectorId(parseInt(text) || 1)}
                keyboardType="number-pad"
              />
            </View>

            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleSetHNSWEfSearch}
                disabled={!hnswIndexId}
              >
                <Text style={styles.buttonSmallText}>Set efSearch</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleGetHNSWEfSearch}
                disabled={!hnswIndexId}
              >
                <Text style={styles.buttonSmallText}>Get efSearch</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleGetVectorFromHNSW}
                disabled={!hnswIndexId || hnswIndexLoading}
              >
                <Text style={styles.buttonSmallText}>{hnswIndexLoading ? 'Getting...' : 'Get Vector'}</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleContainsVectorInHNSW}
                disabled={!hnswIndexId}
              >
                <Text style={styles.buttonSmallText}>Contains Vector</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleGetHNSWDimension}
                disabled={!hnswIndexId}
              >
                <Text style={styles.buttonSmallText}>Get Dimension</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSmall, !hnswIndexId && styles.buttonDisabled]}
                onPress={handleGetHNSWCapacity}
                disabled={!hnswIndexId}
              >
                <Text style={styles.buttonSmallText}>Get Capacity</Text>
              </TouchableOpacity>
            </View>

            {/* Advanced operation result */}
            {hnswIndexAdvancedResult && (
              <View style={styles.resultContainer}>
                <Text style={styles.resultLabel}>Result:</Text>
                <Text style={styles.resultText}>{hnswIndexAdvancedResult}</Text>
              </View>
            )}
          </View>

          {/* Version section */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Version Information</Text>
            
            <View style={styles.buttonGroup}>
              <TouchableOpacity
                style={[styles.button, styles.buttonPrimary]}
                onPress={handleGetVersion}
              >
                <Text style={styles.buttonText}>Get Version</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.buttonSecondary]}
                onPress={handleGetVersionDetailed}
              >
                <Text style={styles.buttonText}>Get Detailed Version</Text>
              </TouchableOpacity>
            </View>

            {/* Version information */}
            {versionInfo && (
              <View style={styles.resultContainer}>
                <Text style={styles.resultLabel}>Version Info:</Text>
                <Text style={styles.resultText}>{versionInfo}</Text>
              </View>
            )}
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 24,
    textAlign: 'center',
    color: '#333',
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#e3f2fd',
    padding: 12,
    borderRadius: 8,
    marginBottom: 24,
  },
  statusLabel: {
    fontWeight: 'bold',
    marginRight: 8,
    color: '#1565c0',
  },
  statusText: {
    flex: 1,
    color: '#0d47a1',
  },
  section: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 8,
    marginBottom: 24,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#333',
  },
  inputGroup: {
    marginBottom: 16,
  },
  label: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 8,
    color: '#555',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 4,
    padding: 12,
    fontSize: 16,
    backgroundColor: '#fafafa',
  },
  metricButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  metricButton: {
    flex: 1,
    padding: 12,
    borderRadius: 4,
    backgroundColor: '#f5f5f5',
    marginHorizontal: 4,
    alignItems: 'center',
  },
  metricButtonActive: {
    backgroundColor: '#2196f3',
  },
  metricButtonText: {
    fontSize: 14,
    color: '#555',
  },
  metricButtonTextActive: {
    color: '#fff',
    fontWeight: 'bold',
  },
  buttonGroup: {
    flexDirection: 'row',
    marginBottom: 12,
  },
  button: {
    flex: 1,
    padding: 14,
    borderRadius: 4,
    alignItems: 'center',
    marginHorizontal: 4,
  },
  buttonSmall: {
    padding: 10,
  },
  buttonPrimary: {
    backgroundColor: '#2196f3',
  },
  buttonSecondary: {
    backgroundColor: '#4caf50',
  },
  buttonDanger: {
    backgroundColor: '#f44336',
  },
  buttonDisabled: {
    backgroundColor: '#ccc',
    opacity: 0.5,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  buttonSmallText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  infoContainer: {
    backgroundColor: '#f5f5f5',
    padding: 12,
    borderRadius: 4,
    marginBottom: 16,
  },
  infoText: {
    color: '#555',
    marginBottom: 4,
  },
  resultsContainer: {
    marginTop: 16,
    padding: 12,
    backgroundColor: '#f5f5f5',
    borderRadius: 4,
  },
  resultsTitle: {
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#333',
  },
  resultItem: {
    padding: 12,
    backgroundColor: '#fff',
    borderRadius: 4,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  resultIndex: {
    fontWeight: 'bold',
    marginBottom: 4,
    color: '#333',
  },
  resultId: {
    marginBottom: 2,
    color: '#555',
  },
  resultDistance: {
    color: '#777',
  },
  resultContainer: {
    marginTop: 16,
    padding: 12,
    backgroundColor: '#e8f5e9',
    borderRadius: 4,
    borderWidth: 1,
    borderColor: '#c8e6c9',
  },
  resultLabel: {
    fontWeight: 'bold',
    marginBottom: 4,
    color: '#2e7d32',
  },
  resultText: {
    color: '#2e7d32',
  },
});

export default App;
