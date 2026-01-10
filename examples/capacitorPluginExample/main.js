import { LlamaMobileVDPlugin } from 'llama_mobile_vd-capacitor-plugin';
import { Plugins } from '@capacitor/core';

// Get the plugin instance
const { LlamaMobileVD } = Plugins;

// DOM elements
const statusMessage = document.getElementById('status-message');
const loadingIndicator = document.getElementById('loading-indicator');
const dimensionSlider = document.getElementById('dimension-slider');
const dimensionValue = document.getElementById('dimension-value');
const metricSelect = document.getElementById('metric-select');
const hnswMSlider = document.getElementById('hnsw-m-slider');
const hnswMValue = document.getElementById('hnsw-m-value');
const hnswEfConstructionSlider = document.getElementById('hnsw-ef-construction-slider');
const hnswEfConstructionValue = document.getElementById('hnsw-ef-construction-value');
const searchKSlider = document.getElementById('search-k-slider');
const searchKValue = document.getElementById('search-k-value');

const createVectorStoreButton = document.getElementById('create-vector-store-button');
const addVectorsToStoreButton = document.getElementById('add-vectors-to-store-button');
const searchVectorStoreButton = document.getElementById('search-vector-store-button');
const clearVectorStoreButton = document.getElementById('clear-vector-store-button');
const releaseVectorStoreButton = document.getElementById('release-vector-store-button');
const vectorStoreInfo = document.getElementById('vector-store-info');
const vectorStoreResults = document.getElementById('vector-store-results');

const createHNSWIndexButton = document.getElementById('create-hnsw-index-button');
const addVectorsToHNSWButton = document.getElementById('add-vectors-to-hnsw-button');
const searchHNSWIndexButton = document.getElementById('search-hnsw-index-button');
const clearHNSWIndexButton = document.getElementById('clear-hnsw-index-button');
const releaseHNSWIndexButton = document.getElementById('release-hnsw-index-button');
const hnswIndexInfo = document.getElementById('hnsw-index-info');
const hnswIndexResults = document.getElementById('hnsw-index-results');

// State variables
let vectorStoreId = null;
let vectorStoreCount = 0;
let hnswIndexId = null;
let hnswIndexCount = 0;
let dimension = 128;
let selectedMetric = 'l2';
let hnswM = 16;
let hnswEfConstruction = 200;
let searchK = 5;
let isLoading = false;

// Loading state functions
function showLoading() {
  isLoading = true;
  loadingIndicator.classList.add('active');
}

function hideLoading() {
  isLoading = false;
  loadingIndicator.classList.remove('active');
}

// Update status message
function updateStatus(message) {
  statusMessage.textContent = message;
}

// Create a vector with random values
function createRandomVector(dimension) {
  const vector = [];
  for (let i = 0; i < dimension; i++) {
    vector.push(Math.random() * 2 - 1); // Values between -1 and 1
  }
  return vector;
}

// Update vector store info
function updateVectorStoreInfo() {
  const storeIdText = vectorStoreId ? `${vectorStoreId.substring(0, 10)}...` : 'None';
  vectorStoreInfo.innerHTML = `VectorStore ID: ${storeIdText}<br>Vector count: ${vectorStoreCount}`;
}

// Update HNSW index info
function updateHNSWIndexInfo() {
  const indexIdText = hnswIndexId ? `${hnswIndexId.substring(0, 10)}...` : 'None';
  hnswIndexInfo.innerHTML = `HNSWIndex ID: ${indexIdText}<br>Vector count: ${hnswIndexCount}`;
}

// Display search results
function displayResults(resultsContainer, results) {
  if (results.length === 0) {
    resultsContainer.innerHTML = '';
    return;
  }
  
  let html = '<div class="results-title">Search Results:</div>';
  results.forEach((result, index) => {
    html += `
      <div class="result-item">
        <div class="result-index">Vector ${result.index}</div>
        <div class="result-distance">Distance: ${result.distance.toFixed(6)}</div>
      </div>
    `;
  });
  
  resultsContainer.innerHTML = html;
}

// VectorStore operations
async function createVectorStore() {
  try {
    showLoading();
    updateStatus('Creating VectorStore...');
    
    const options = {
      dimension,
      metric: selectedMetric
    };
    
    const result = await LlamaMobileVD.createVectorStore(options);
    vectorStoreId = result.id;
    vectorStoreCount = 0;
    
    updateVectorStoreInfo();
    displayResults(vectorStoreResults, []);
    updateStatus('VectorStore created successfully');
  } catch (error) {
    updateStatus(`Error creating VectorStore: ${error.message}`);
  } finally {
    hideLoading();
  }
}

async function addVectorsToStore() {
  if (!vectorStoreId) {
    updateStatus('Please create a VectorStore first');
    return;
  }
  
  try {
    showLoading();
    updateStatus('Adding 100 vectors to VectorStore...');
    
    for (let i = 0; i < 100; i++) {
      const vector = createRandomVector(dimension);
      const params = {
        id: vectorStoreId,
        vector,
        label: `vector-${i}`
      };
      await LlamaMobileVD.addVectorToStore(params);
    }
    
    const countParams = { id: vectorStoreId };
    const countResult = await LlamaMobileVD.countVectorStore(countParams);
    vectorStoreCount = countResult.count;
    
    updateVectorStoreInfo();
    updateStatus('Added 100 vectors to VectorStore');
  } catch (error) {
    updateStatus(`Error adding vectors to VectorStore: ${error.message}`);
  } finally {
    hideLoading();
  }
}

async function searchVectorStore() {
  if (!vectorStoreId) {
    updateStatus('Please create a VectorStore first');
    return;
  }
  
  if (vectorStoreCount === 0) {
    updateStatus('Please add vectors to the VectorStore first');
    return;
  }
  
  try {
    showLoading();
    updateStatus('Searching VectorStore...');
    
    const queryVector = createRandomVector(dimension);
    const params = {
      id: vectorStoreId,
      queryVector,
      k: searchK
    };
    
    const results = await LlamaMobileVD.searchVectorStore(params);
    displayResults(vectorStoreResults, results);
    updateStatus('Search completed successfully');
  } catch (error) {
    updateStatus(`Error searching VectorStore: ${error.message}`);
  } finally {
    hideLoading();
  }
}

async function clearVectorStore() {
  if (!vectorStoreId) {
    updateStatus('Please create a VectorStore first');
    return;
  }
  
  try {
    showLoading();
    updateStatus('Clearing VectorStore...');
    
    const params = { id: vectorStoreId };
    await LlamaMobileVD.clearVectorStore(params);
    vectorStoreCount = 0;
    
    updateVectorStoreInfo();
    displayResults(vectorStoreResults, []);
    updateStatus('VectorStore cleared successfully');
  } catch (error) {
    updateStatus(`Error clearing VectorStore: ${error.message}`);
  } finally {
    hideLoading();
  }
}

async function releaseVectorStore() {
  if (!vectorStoreId) {
    updateStatus('Please create a VectorStore first');
    return;
  }
  
  try {
    showLoading();
    updateStatus('Releasing VectorStore...');
    
    const params = { id: vectorStoreId };
    await LlamaMobileVD.releaseVectorStore(params);
    vectorStoreId = null;
    vectorStoreCount = 0;
    
    updateVectorStoreInfo();
    displayResults(vectorStoreResults, []);
    updateStatus('VectorStore released successfully');
  } catch (error) {
    updateStatus(`Error releasing VectorStore: ${error.message}`);
  } finally {
    hideLoading();
  }
}

// HNSWIndex operations
async function createHNSWIndex() {
  try {
    showLoading();
    updateStatus('Creating HNSWIndex...');
    
    const options = {
      dimension,
      metric: selectedMetric,
      m: hnswM,
      efConstruction: hnswEfConstruction
    };
    
    const result = await LlamaMobileVD.createHNSWIndex(options);
    hnswIndexId = result.id;
    hnswIndexCount = 0;
    
    updateHNSWIndexInfo();
    displayResults(hnswIndexResults, []);
    updateStatus('HNSWIndex created successfully');
  } catch (error) {
    updateStatus(`Error creating HNSWIndex: ${error.message}`);
  } finally {
    hideLoading();
  }
}

async function addVectorsToHNSW() {
  if (!hnswIndexId) {
    updateStatus('Please create a HNSWIndex first');
    return;
  }
  
  try {
    showLoading();
    updateStatus('Adding 100 vectors to HNSWIndex...');
    
    for (let i = 0; i < 100; i++) {
      const vector = createRandomVector(dimension);
      const params = {
        id: hnswIndexId,
        vector,
        label: `vector-${i}`
      };
      await LlamaMobileVD.addVectorToHNSW(params);
    }
    
    const countParams = { id: hnswIndexId };
    const countResult = await LlamaMobileVD.countHNSWIndex(countParams);
    hnswIndexCount = countResult.count;
    
    updateHNSWIndexInfo();
    updateStatus('Added 100 vectors to HNSWIndex');
  } catch (error) {
    updateStatus(`Error adding vectors to HNSWIndex: ${error.message}`);
  } finally {
    hideLoading();
  }
}

async function searchHNSWIndex() {
  if (!hnswIndexId) {
    updateStatus('Please create a HNSWIndex first');
    return;
  }
  
  if (hnswIndexCount === 0) {
    updateStatus('Please add vectors to the HNSWIndex first');
    return;
  }
  
  try {
    showLoading();
    updateStatus('Searching HNSWIndex...');
    
    const queryVector = createRandomVector(dimension);
    const params = {
      id: hnswIndexId,
      queryVector,
      k: searchK
    };
    
    const results = await LlamaMobileVD.searchHNSWIndex(params);
    displayResults(hnswIndexResults, results);
    updateStatus('Search completed successfully');
  } catch (error) {
    updateStatus(`Error searching HNSWIndex: ${error.message}`);
  } finally {
    hideLoading();
  }
}

async function clearHNSWIndex() {
  if (!hnswIndexId) {
    updateStatus('Please create a HNSWIndex first');
    return;
  }
  
  try {
    showLoading();
    updateStatus('Clearing HNSWIndex...');
    
    const params = { id: hnswIndexId };
    await LlamaMobileVD.clearHNSWIndex(params);
    hnswIndexCount = 0;
    
    updateHNSWIndexInfo();
    displayResults(hnswIndexResults, []);
    updateStatus('HNSWIndex cleared successfully');
  } catch (error) {
    updateStatus(`Error clearing HNSWIndex: ${error.message}`);
  } finally {
    hideLoading();
  }
}

async function releaseHNSWIndex() {
  if (!hnswIndexId) {
    updateStatus('Please create a HNSWIndex first');
    return;
  }
  
  try {
    showLoading();
    updateStatus('Releasing HNSWIndex...');
    
    const params = { id: hnswIndexId };
    await LlamaMobileVD.releaseHNSWIndex(params);
    hnswIndexId = null;
    hnswIndexCount = 0;
    
    updateHNSWIndexInfo();
    displayResults(hnswIndexResults, []);
    updateStatus('HNSWIndex released successfully');
  } catch (error) {
    updateStatus(`Error releasing HNSWIndex: ${error.message}`);
  } finally {
    hideLoading();
  }
}

// Event listeners
function setupEventListeners() {
  // Configuration listeners
  dimensionSlider.addEventListener('input', (e) => {
    dimension = parseInt(e.target.value);
    dimensionValue.textContent = dimension;
  });
  
  metricSelect.addEventListener('change', (e) => {
    selectedMetric = e.target.value;
  });
  
  hnswMSlider.addEventListener('input', (e) => {
    hnswM = parseInt(e.target.value);
    hnswMValue.textContent = hnswM;
  });
  
  hnswEfConstructionSlider.addEventListener('input', (e) => {
    hnswEfConstruction = parseInt(e.target.value);
    hnswEfConstructionValue.textContent = hnswEfConstruction;
  });
  
  searchKSlider.addEventListener('input', (e) => {
    searchK = parseInt(e.target.value);
    searchKValue.textContent = searchK;
  });
  
  // VectorStore listeners
  createVectorStoreButton.addEventListener('click', createVectorStore);
  addVectorsToStoreButton.addEventListener('click', addVectorsToStore);
  searchVectorStoreButton.addEventListener('click', searchVectorStore);
  clearVectorStoreButton.addEventListener('click', clearVectorStore);
  releaseVectorStoreButton.addEventListener('click', releaseVectorStore);
  
  // HNSWIndex listeners
  createHNSWIndexButton.addEventListener('click', createHNSWIndex);
  addVectorsToHNSWButton.addEventListener('click', addVectorsToHNSW);
  searchHNSWIndexButton.addEventListener('click', searchHNSWIndex);
  clearHNSWIndexButton.addEventListener('click', clearHNSWIndex);
  releaseHNSWIndexButton.addEventListener('click', releaseHNSWIndex);
}

// Initialize the app
function init() {
  setupEventListeners();
  updateVectorStoreInfo();
  updateHNSWIndexInfo();
}

// Start the app when DOM is ready
document.addEventListener('DOMContentLoaded', init);
