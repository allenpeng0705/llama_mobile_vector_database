import './style.css'
import { LlamaMobileVD } from 'capacitor-plugin-llamamobilevd';

document.querySelector('#app').innerHTML = `
  <div class="app-container">
    <h1>LlamaMobileVD Capacitor Plugin Example</h1>
    
    <!-- Status message -->
    <div class="status-container">
      <h2>Status</h2>
      <div id="status" class="status-message">Ready</div>
    </div>
    
    <!-- Configuration section -->
    <div class="section">
      <h2>Configuration</h2>
      
      <div class="config-group">
        <label for="dimension">Vector Dimension:</label>
        <input type="number" id="dimension" value="128" min="10" max="256" />
      </div>
      
      <div class="config-group">
        <label>Distance Metric:</label>
        <div class="radio-group">
          <label><input type="radio" name="metric" value="l2" checked /> L2</label>
          <label><input type="radio" name="metric" value="cosine" /> Cosine</label>
          <label><input type="radio" name="metric" value="dot" /> Dot</label>
        </div>
      </div>
      
      <div class="config-group">
        <label for="hnswM">HNSW M (Connections):</label>
        <input type="number" id="hnswM" value="16" min="5" max="50" />
      </div>
      
      <div class="config-group">
        <label for="hnswEfConstruction">HNSW efConstruction:</label>
        <input type="number" id="hnswEfConstruction" value="200" min="50" max="500" />
      </div>
      
      <div class="config-group">
        <label for="searchK">Search K:</label>
        <input type="number" id="searchK" value="5" min="1" max="20" />
      </div>
      
      <div class="config-group">
        <label for="efSearch">HNSW efSearch:</label>
        <input type="number" id="efSearch" value="50" min="10" max="200" />
      </div>
    </div>
    
    <!-- VectorStore section -->
    <div class="section">
      <h2>VectorStore (Exact Search)</h2>
      
      <div class="button-group">
        <button id="createVectorStore">Create VectorStore</button>
        <button id="addVectorsToStore">Add 100 Vectors</button>
        <button id="searchVectorStore">Search</button>
        <button id="clearVectorStore">Clear</button>
        <button id="releaseVectorStore">Release</button>
      </div>
      
      <div id="vectorStoreInfo" class="info">
        VectorStore Status: None
        Vector Count: 0
      </div>
      
      <div id="vectorStoreResults" class="results">
        <h3>Search Results:</h3>
        <div class="no-results">No results yet</div>
      </div>
    </div>
    
    <!-- HNSWIndex section -->
    <div class="section">
      <h2>HNSWIndex (Approximate Search)</h2>
      
      <div class="button-group">
        <button id="createHNSWIndex">Create HNSWIndex</button>
        <button id="addVectorsToHNSW">Add 100 Vectors</button>
        <button id="searchHNSWIndex">Search</button>
        <button id="clearHNSWIndex">Clear</button>
        <button id="releaseHNSWIndex">Release</button>
      </div>
      
      <div id="hnswIndexInfo" class="info">
        HNSWIndex Status: None
        Vector Count: 0
      </div>
      
      <div id="hnswIndexResults" class="results">
        <h3>Search Results:</h3>
        <div class="no-results">No results yet</div>
      </div>
    </div>
  </div>
`;

// Application state
let vectorStoreId = null;
let vectorStoreCount = 0;
let hnswIndexId = null;
let hnswIndexCount = 0;

// Configuration state
let dimension = 128;
let selectedMetric = 'l2';
let hnswM = 16;
let hnswEfConstruction = 200;
let searchK = 5;
let efSearch = 50;

// DOM elements
const statusEl = document.getElementById('status');
const dimensionEl = document.getElementById('dimension');
const metricRadios = document.querySelectorAll('input[name="metric"]');
const hnswMEl = document.getElementById('hnswM');
const hnswEfConstructionEl = document.getElementById('hnswEfConstruction');
const searchKEl = document.getElementById('searchK');
const efSearchEl = document.getElementById('efSearch');

// VectorStore elements
const createVectorStoreBtn = document.getElementById('createVectorStore');
const addVectorsToStoreBtn = document.getElementById('addVectorsToStore');
const searchVectorStoreBtn = document.getElementById('searchVectorStore');
const clearVectorStoreBtn = document.getElementById('clearVectorStore');
const releaseVectorStoreBtn = document.getElementById('releaseVectorStore');
const vectorStoreInfoEl = document.getElementById('vectorStoreInfo');
const vectorStoreResultsEl = document.getElementById('vectorStoreResults');

// HNSWIndex elements
const createHNSWIndexBtn = document.getElementById('createHNSWIndex');
const addVectorsToHNSWBtn = document.getElementById('addVectorsToHNSW');
const searchHNSWIndexBtn = document.getElementById('searchHNSWIndex');
const clearHNSWIndexBtn = document.getElementById('clearHNSWIndex');
const releaseHNSWIndexBtn = document.getElementById('releaseHNSWIndex');
const hnswIndexInfoEl = document.getElementById('hnswIndexInfo');
const hnswIndexResultsEl = document.getElementById('hnswIndexResults');

// Update status message
function updateStatus(message) {
  statusEl.textContent = message;
  console.log(message);
}

// Create random vector
function createRandomVector(dim) {
  const vector = [];
  for (let i = 0; i < dim; i++) {
    vector.push(Math.random() * 2 - 1); // Values between -1 and 1
  }
  return vector;
}

// Update VectorStore info
function updateVectorStoreInfo() {
  const status = vectorStoreId ? 'Created' : 'None';
  vectorStoreInfoEl.innerHTML = `
    VectorStore Status: ${status}<br>
    Vector Count: ${vectorStoreCount}
  `;
}

// Update HNSWIndex info
function updateHNSWIndexInfo() {
  const status = hnswIndexId ? 'Created' : 'None';
  hnswIndexInfoEl.innerHTML = `
    HNSWIndex Status: ${status}<br>
    Vector Count: ${hnswIndexCount}
  `;
}

// Display search results
function displayResults(container, results) {
  if (results.length === 0) {
    container.innerHTML = `
      <h3>Search Results:</h3>
      <div class="no-results">No results found</div>
    `;
    return;
  }
  
  const resultsHTML = results.map((result, index) => `
    <div class="result-item">
      <div class="result-index">Result ${index + 1}</div>
      <div class="result-id">Vector ID: ${result.id}</div>
      <div class="result-distance">Distance: ${result.distance.toFixed(6)}</div>
    </div>
  `).join('');
  
  container.innerHTML = `
    <h3>Search Results:</h3>
    <div class="results-list">${resultsHTML}</div>
  `;
}

// Event listeners for configuration
function updateConfiguration() {
  dimension = parseInt(dimensionEl.value);
  selectedMetric = Array.from(metricRadios).find(r => r.checked).value;
  hnswM = parseInt(hnswMEl.value);
  hnswEfConstruction = parseInt(hnswEfConstructionEl.value);
  searchK = parseInt(searchKEl.value);
  efSearch = parseInt(efSearchEl.value);
}

// Add event listeners for configuration changes
[dimensionEl, hnswMEl, hnswEfConstructionEl, searchKEl, efSearchEl].forEach(el => {
  el.addEventListener('change', updateConfiguration);
});

metricRadios.forEach(radio => {
  radio.addEventListener('change', updateConfiguration);
});

// Initialize configuration
updateConfiguration();

// VectorStore operations
createVectorStoreBtn.addEventListener('click', async () => {
  try {
    updateStatus('Creating VectorStore...');
    
    // First release any existing vector store
    if (vectorStoreId) {
      await LlamaMobileVD.releaseVectorStore({ id: vectorStoreId });
      vectorStoreId = null;
    }
    
    const result = await LlamaMobileVD.createVectorStore({
      dimension,
      metric: selectedMetric
    });
    
    vectorStoreId = result.id;
    vectorStoreCount = 0;
    updateVectorStoreInfo();
    updateStatus('VectorStore created successfully');
  } catch (error) {
    updateStatus(`Error creating VectorStore: ${error.message}`);
  }
});

addVectorsToStoreBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    updateStatus('Adding 100 vectors to VectorStore...');
    
    for (let i = 0; i < 100; i++) {
      const vector = createRandomVector(dimension);
      await LlamaMobileVD.addVectorToStore({
        id: vectorStoreId,
        vector,
        vectorId: i + 1
      });
    }
    
    const countResult = await LlamaMobileVD.countVectorStore({ id: vectorStoreId });
    vectorStoreCount = countResult.count;
    updateVectorStoreInfo();
    updateStatus('Added 100 vectors to VectorStore');
  } catch (error) {
    updateStatus(`Error adding vectors to VectorStore: ${error.message}`);
  }
});

searchVectorStoreBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    updateStatus('Searching VectorStore...');
    
    const queryVector = createRandomVector(dimension);
    const results = await LlamaMobileVD.searchVectorStore({
      id: vectorStoreId,
      vector: queryVector,
      k: searchK
    });
    
    displayResults(vectorStoreResultsEl, results.results);
    updateStatus('Search completed successfully');
  } catch (error) {
    updateStatus(`Error searching VectorStore: ${error.message}`);
  }
});

clearVectorStoreBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    updateStatus('Clearing VectorStore...');
    
    await LlamaMobileVD.clearVectorStore({ id: vectorStoreId });
    vectorStoreCount = 0;
    updateVectorStoreInfo();
    displayResults(vectorStoreResultsEl, []);
    updateStatus('VectorStore cleared successfully');
  } catch (error) {
    updateStatus(`Error clearing VectorStore: ${error.message}`);
  }
});

releaseVectorStoreBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    updateStatus('Releasing VectorStore...');
    
    await LlamaMobileVD.releaseVectorStore({ id: vectorStoreId });
    vectorStoreId = null;
    vectorStoreCount = 0;
    updateVectorStoreInfo();
    displayResults(vectorStoreResultsEl, []);
    updateStatus('VectorStore released successfully');
  } catch (error) {
    updateStatus(`Error releasing VectorStore: ${error.message}`);
  }
});

// HNSWIndex operations
createHNSWIndexBtn.addEventListener('click', async () => {
  try {
    updateStatus('Creating HNSWIndex...');
    
    // First release any existing HNSW index
    if (hnswIndexId) {
      await LlamaMobileVD.releaseHNSWIndex({ id: hnswIndexId });
      hnswIndexId = null;
    }
    
    const result = await LlamaMobileVD.createHNSWIndex({
      dimension,
      metric: selectedMetric,
      m: hnswM,
      efConstruction: hnswEfConstruction
    });
    
    hnswIndexId = result.id;
    hnswIndexCount = 0;
    updateHNSWIndexInfo();
    updateStatus('HNSWIndex created successfully');
  } catch (error) {
    updateStatus(`Error creating HNSWIndex: ${error.message}`);
  }
});

addVectorsToHNSWBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    updateStatus('Adding 100 vectors to HNSWIndex...');
    
    for (let i = 0; i < 100; i++) {
      const vector = createRandomVector(dimension);
      await LlamaMobileVD.addVectorToHNSW({
        id: hnswIndexId,
        vector,
        vectorId: i + 1
      });
    }
    
    const countResult = await LlamaMobileVD.countHNSWIndex({ id: hnswIndexId });
    hnswIndexCount = countResult.count;
    updateHNSWIndexInfo();
    updateStatus('Added 100 vectors to HNSWIndex');
  } catch (error) {
    updateStatus(`Error adding vectors to HNSWIndex: ${error.message}`);
  }
});

searchHNSWIndexBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    updateStatus('Searching HNSWIndex...');
    
    const queryVector = createRandomVector(dimension);
    const results = await LlamaMobileVD.searchHNSWIndex({
      id: hnswIndexId,
      vector: queryVector,
      k: searchK,
      efSearch
    });
    
    displayResults(hnswIndexResultsEl, results.results);
    updateStatus('Search completed successfully');
  } catch (error) {
    updateStatus(`Error searching HNSWIndex: ${error.message}`);
  }
});

clearHNSWIndexBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    updateStatus('Clearing HNSWIndex...');
    
    await LlamaMobileVD.clearHNSWIndex({ id: hnswIndexId });
    hnswIndexCount = 0;
    updateHNSWIndexInfo();
    displayResults(hnswIndexResultsEl, []);
    updateStatus('HNSWIndex cleared successfully');
  } catch (error) {
    updateStatus(`Error clearing HNSWIndex: ${error.message}`);
  }
});

releaseHNSWIndexBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    updateStatus('Releasing HNSWIndex...');
    
    await LlamaMobileVD.releaseHNSWIndex({ id: hnswIndexId });
    hnswIndexId = null;
    hnswIndexCount = 0;
    updateHNSWIndexInfo();
    displayResults(hnswIndexResultsEl, []);
    updateStatus('HNSWIndex released successfully');
  } catch (error) {
    updateStatus(`Error releasing HNSWIndex: ${error.message}`);
  }
});

// Initialize info displays
updateVectorStoreInfo();
updateHNSWIndexInfo();
