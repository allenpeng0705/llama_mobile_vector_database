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
      
      <div class="api-operations">
        <h3>Advanced VectorStore Operations</h3>
        
        <div class="operation-group">
          <div class="input-group">
            <label for="vectorIdInput">Vector ID:</label>
            <input type="number" id="vectorIdInput" value="1" min="1" />
          </div>
          
          <div class="button-group small">
            <button id="getVectorFromStore">Get Vector</button>
            <button id="removeVectorFromStore">Remove Vector</button>
            <button id="containsVectorInStore">Contains Vector</button>
          </div>
        </div>
        
        <div class="operation-group">
          <div class="button-group small">
            <button id="updateVectorInStore">Update Vector</button>
            <button id="reserveVectorStore">Reserve Space</button>
            <button id="getVectorStoreDimension">Get Dimension</button>
            <button id="getVectorStoreMetric">Get Metric</button>
          </div>
        </div>
      </div>
      
      <div id="vectorStoreInfo" class="info">
        VectorStore Status: None
        Vector Count: 0
      </div>
      
      <div id="vectorStoreResults" class="results">
        <h3>Search Results:</h3>
        <div class="no-results">No results yet</div>
      </div>
      
      <div id="vectorStoreAdvancedResults" class="results">
        <h3>Advanced Operation Results:</h3>
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
      
      <div class="api-operations">
        <h3>Advanced HNSWIndex Operations</h3>
        
        <div class="operation-group">
          <div class="input-group">
            <label for="hnswVectorIdInput">Vector ID:</label>
            <input type="number" id="hnswVectorIdInput" value="1" min="1" />
          </div>
          
          <div class="input-group">
            <label for="efSearchInput">efSearch:</label>
            <input type="number" id="efSearchInput" value="50" min="10" max="200" />
          </div>
          
          <div class="button-group small">
            <button id="getVectorFromHNSW">Get Vector</button>
            <button id="containsVectorInHNSW">Contains Vector</button>
            <button id="setHNSWEfSearch">Set efSearch</button>
            <button id="getHNSWEfSearch">Get efSearch</button>
          </div>
        </div>
        
        <div class="operation-group">
          <div class="input-group">
            <label for="hnswPathInput">File Path:</label>
            <input type="text" id="hnswPathInput" value="/tmp/hnsw_index.ann" placeholder="/tmp/hnsw_index.ann" />
          </div>
          
          <div class="button-group small">
            <button id="getHNSWDimension">Get Dimension</button>
            <button id="getHNSWCapacity">Get Capacity</button>
            <button id="saveHNSWIndex">Save Index</button>
            <button id="loadHNSWIndex">Load Index</button>
          </div>
        </div>
      </div>
      
      <div id="hnswIndexInfo" class="info">
        HNSWIndex Status: None
        Vector Count: 0
      </div>
      
      <div id="hnswIndexResults" class="results">
        <h3>Search Results:</h3>
        <div class="no-results">No results yet</div>
      </div>
      
      <div id="hnswIndexAdvancedResults" class="results">
        <h3>Advanced Operation Results:</h3>
        <div class="no-results">No results yet</div>
      </div>
    </div>
    
    <!-- Version APIs section -->
    <div class="section">
      <h2>Version Information</h2>
      
      <div class="button-group">
        <button id="getVersion">Get Full Version</button>
        <button id="getVersionMajor">Get Major Version</button>
        <button id="getVersionMinor">Get Minor Version</button>
        <button id="getVersionPatch">Get Patch Version</button>
      </div>
      
      <div id="versionInfo" class="info">
        Version information will be displayed here
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

// VectorStore advanced elements
const vectorIdInputEl = document.getElementById('vectorIdInput');
const getVectorFromStoreBtn = document.getElementById('getVectorFromStore');
const removeVectorFromStoreBtn = document.getElementById('removeVectorFromStore');
const containsVectorInStoreBtn = document.getElementById('containsVectorInStore');
const updateVectorInStoreBtn = document.getElementById('updateVectorInStore');
const reserveVectorStoreBtn = document.getElementById('reserveVectorStore');
const getVectorStoreDimensionBtn = document.getElementById('getVectorStoreDimension');
const getVectorStoreMetricBtn = document.getElementById('getVectorStoreMetric');
const vectorStoreAdvancedResultsEl = document.getElementById('vectorStoreAdvancedResults');

// HNSWIndex elements
const createHNSWIndexBtn = document.getElementById('createHNSWIndex');
const addVectorsToHNSWBtn = document.getElementById('addVectorsToHNSW');
const searchHNSWIndexBtn = document.getElementById('searchHNSWIndex');
const clearHNSWIndexBtn = document.getElementById('clearHNSWIndex');
const releaseHNSWIndexBtn = document.getElementById('releaseHNSWIndex');
const hnswIndexInfoEl = document.getElementById('hnswIndexInfo');
const hnswIndexResultsEl = document.getElementById('hnswIndexResults');

// HNSWIndex advanced elements
const hnswVectorIdInputEl = document.getElementById('hnswVectorIdInput');
const efSearchInputEl = document.getElementById('efSearchInput');
const getVectorFromHNSWBtn = document.getElementById('getVectorFromHNSW');
const containsVectorInHNSWBtn = document.getElementById('containsVectorInHNSW');
const setHNSWEfSearchBtn = document.getElementById('setHNSWEfSearch');
const getHNSWEfSearchBtn = document.getElementById('getHNSWEfSearch');
const hnswPathInputEl = document.getElementById('hnswPathInput');
const getHNSWDimensionBtn = document.getElementById('getHNSWDimension');
const getHNSWCapacityBtn = document.getElementById('getHNSWCapacity');
const saveHNSWIndexBtn = document.getElementById('saveHNSWIndex');
const loadHNSWIndexBtn = document.getElementById('loadHNSWIndex');
const hnswIndexAdvancedResultsEl = document.getElementById('hnswIndexAdvancedResults');

// Version elements
const getVersionBtn = document.getElementById('getVersion');
const getVersionMajorBtn = document.getElementById('getVersionMajor');
const getVersionMinorBtn = document.getElementById('getVersionMinor');
const getVersionPatchBtn = document.getElementById('getVersionPatch');
const versionInfoEl = document.getElementById('versionInfo');

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

// Display advanced operation results
function displayAdvancedResult(container, operation, result) {
  let resultHTML;
  
  if (typeof result === 'object' && result !== null) {
    // Handle vector results specially
    if (result.vector) {
      const vectorPreview = result.vector.slice(0, 5).map(v => v.toFixed(4)).join(', ');
      resultHTML = `
        <div class="operation-name">${operation}</div>
        <div class="result-object">
          <div class="result-field">Vector ID: ${result.id}</div>
          <div class="result-field">Vector: [${vectorPreview}${result.vector.length > 5 ? ', ...' : ''}]</div>
        </div>
      `;
    } else {
      // Handle other objects
      const fields = Object.entries(result).map(([key, value]) => {
        return `<div class="result-field">${key}: ${value}</div>`;
      }).join('');
      
      resultHTML = `
        <div class="operation-name">${operation}</div>
        <div class="result-object">${fields}</div>
      `;
    }
  } else {
    // Handle primitive values
    resultHTML = `
      <div class="operation-name">${operation}</div>
      <div class="result-value">${result}</div>
    `;
  }
  
  container.innerHTML = `
    <h3>Advanced Operation Results:</h3>
    <div class="operation-result">${resultHTML}</div>
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

// Advanced VectorStore operations
getVectorFromStoreBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    const vectorId = parseInt(vectorIdInputEl.value);
    updateStatus(`Getting vector ${vectorId} from VectorStore...`);
    
    const result = await LlamaMobileVD.getVectorFromStore({ id: vectorStoreId, vectorId });
    displayAdvancedResult(vectorStoreAdvancedResultsEl, `Get Vector ${vectorId}`, result);
    updateStatus('Vector retrieved successfully');
  } catch (error) {
    updateStatus(`Error getting vector: ${error.message}`);
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Get Vector', { error: error.message });
  }
});

removeVectorFromStoreBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    const vectorId = parseInt(vectorIdInputEl.value);
    updateStatus(`Removing vector ${vectorId} from VectorStore...`);
    
    await LlamaMobileVD.removeVectorFromStore({ id: vectorStoreId, vectorId });
    
    // Update count
    const countResult = await LlamaMobileVD.countVectorStore({ id: vectorStoreId });
    vectorStoreCount = countResult.count;
    updateVectorStoreInfo();
    
    displayAdvancedResult(vectorStoreAdvancedResultsEl, `Remove Vector ${vectorId}`, { success: true });
    updateStatus('Vector removed successfully');
  } catch (error) {
    updateStatus(`Error removing vector: ${error.message}`);
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Remove Vector', { error: error.message });
  }
});

containsVectorInStoreBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    const vectorId = parseInt(vectorIdInputEl.value);
    updateStatus(`Checking if vector ${vectorId} exists in VectorStore...`);
    
    const result = await LlamaMobileVD.containsVectorInStore({ id: vectorStoreId, vectorId });
    displayAdvancedResult(vectorStoreAdvancedResultsEl, `Contains Vector ${vectorId}`, { exists: result.result });
    updateStatus(`Vector ${vectorId} ${result.result ? 'exists' : 'does not exist'}`);
  } catch (error) {
    updateStatus(`Error checking vector: ${error.message}`);
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Contains Vector', { error: error.message });
  }
});

updateVectorInStoreBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    const vectorId = parseInt(vectorIdInputEl.value);
    const newVector = createRandomVector(dimension);
    updateStatus(`Updating vector ${vectorId} in VectorStore...`);
    
    await LlamaMobileVD.updateVectorInStore({ id: vectorStoreId, vectorId, vector: newVector });
    displayAdvancedResult(vectorStoreAdvancedResultsEl, `Update Vector ${vectorId}`, { success: true });
    updateStatus('Vector updated successfully');
  } catch (error) {
    updateStatus(`Error updating vector: ${error.message}`);
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Update Vector', { error: error.message });
  }
});

reserveVectorStoreBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    const reserveCount = 1000;
    updateStatus(`Reserving space for ${reserveCount} vectors in VectorStore...`);
    
    await LlamaMobileVD.reserveVectorStore({ id: vectorStoreId, capacity: reserveCount });
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Reserve VectorStore', { capacity: reserveCount });
    updateStatus(`Reserved space for ${reserveCount} vectors`);
  } catch (error) {
    updateStatus(`Error reserving space: ${error.message}`);
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Reserve VectorStore', { error: error.message });
  }
});

getVectorStoreDimensionBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    updateStatus('Getting VectorStore dimension...');
    
    const result = await LlamaMobileVD.getVectorStoreDimension({ id: vectorStoreId });
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Get VectorStore Dimension', { dimension: result.dimension });
    updateStatus(`VectorStore dimension: ${result.dimension}`);
  } catch (error) {
    updateStatus(`Error getting dimension: ${error.message}`);
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Get VectorStore Dimension', { error: error.message });
  }
});

getVectorStoreMetricBtn.addEventListener('click', async () => {
  try {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first');
      return;
    }
    
    updateStatus('Getting VectorStore metric...');
    
    const result = await LlamaMobileVD.getVectorStoreMetric({ id: vectorStoreId });
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Get VectorStore Metric', { metric: result.metric });
    updateStatus(`VectorStore metric: ${result.metric}`);
  } catch (error) {
    updateStatus(`Error getting metric: ${error.message}`);
    displayAdvancedResult(vectorStoreAdvancedResultsEl, 'Get VectorStore Metric', { error: error.message });
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

// Advanced HNSWIndex operations
getVectorFromHNSWBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    const vectorId = parseInt(hnswVectorIdInputEl.value);
    updateStatus(`Getting vector ${vectorId} from HNSWIndex...`);
    
    const result = await LlamaMobileVD.getVectorFromHNSW({ id: hnswIndexId, vectorId });
    displayAdvancedResult(hnswIndexAdvancedResultsEl, `Get Vector ${vectorId}`, result);
    updateStatus('Vector retrieved successfully');
  } catch (error) {
    updateStatus(`Error getting vector: ${error.message}`);
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Get Vector', { error: error.message });
  }
});

containsVectorInHNSWBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    const vectorId = parseInt(hnswVectorIdInputEl.value);
    updateStatus(`Checking if vector ${vectorId} exists in HNSWIndex...`);
    
    const result = await LlamaMobileVD.containsVectorInHNSW({ id: hnswIndexId, vectorId });
    displayAdvancedResult(hnswIndexAdvancedResultsEl, `Contains Vector ${vectorId}`, { exists: result.result });
    updateStatus(`Vector ${vectorId} ${result.result ? 'exists' : 'does not exist'}`);
  } catch (error) {
    updateStatus(`Error checking vector: ${error.message}`);
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Contains Vector', { error: error.message });
  }
});

setHNSWEfSearchBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    const efSearchValue = parseInt(efSearchInputEl.value);
    updateStatus(`Setting HNSW efSearch to ${efSearchValue}...`);
    
    await LlamaMobileVD.setHNSWEfSearch({ id: hnswIndexId, efSearch: efSearchValue });
    
    // Update global efSearch value
    efSearch = efSearchValue;
    efSearchEl.value = efSearchValue;
    updateConfiguration();
    
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Set HNSW efSearch', { efSearch: efSearchValue });
    updateStatus(`HNSW efSearch set to ${efSearchValue}`);
  } catch (error) {
    updateStatus(`Error setting efSearch: ${error.message}`);
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Set HNSW efSearch', { error: error.message });
  }
});

getHNSWEfSearchBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    updateStatus('Getting HNSW efSearch...');
    
    const result = await LlamaMobileVD.getHNSWEfSearch({ id: hnswIndexId });
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Get HNSW efSearch', { efSearch: result.efSearch });
    updateStatus(`HNSW efSearch: ${result.efSearch}`);
  } catch (error) {
    updateStatus(`Error getting efSearch: ${error.message}`);
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Get HNSW efSearch', { error: error.message });
  }
});

getHNSWDimensionBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    updateStatus('Getting HNSWIndex dimension...');
    
    const result = await LlamaMobileVD.getHNSWDimension({ id: hnswIndexId });
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Get HNSW Dimension', { dimension: result.dimension });
    updateStatus(`HNSWIndex dimension: ${result.dimension}`);
  } catch (error) {
    updateStatus(`Error getting dimension: ${error.message}`);
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Get HNSW Dimension', { error: error.message });
  }
});

getHNSWCapacityBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    updateStatus('Getting HNSWIndex capacity...');
    
    const result = await LlamaMobileVD.getHNSWCapacity({ id: hnswIndexId });
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Get HNSW Capacity', { capacity: result.capacity });
    updateStatus(`HNSWIndex capacity: ${result.capacity}`);
  } catch (error) {
    updateStatus(`Error getting capacity: ${error.message}`);
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Get HNSW Capacity', { error: error.message });
  }
});

saveHNSWIndexBtn.addEventListener('click', async () => {
  try {
    if (!hnswIndexId) {
      updateStatus('Please create a HNSWIndex first');
      return;
    }
    
    const path = hnswPathInputEl.value;
    updateStatus(`Saving HNSWIndex to ${path}...`);
    
    await LlamaMobileVD.saveHNSWIndex({ id: hnswIndexId, path });
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Save HNSWIndex', { path });
    updateStatus(`HNSWIndex saved to ${path}`);
  } catch (error) {
    updateStatus(`Error saving index: ${error.message}`);
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Save HNSWIndex', { error: error.message });
  }
});

loadHNSWIndexBtn.addEventListener('click', async () => {
  try {
    const path = hnswPathInputEl.value;
    updateStatus(`Loading HNSWIndex from ${path}...`);
    
    // First release any existing HNSW index
    if (hnswIndexId) {
      await LlamaMobileVD.releaseHNSWIndex({ id: hnswIndexId });
    }
    
    const result = await LlamaMobileVD.loadHNSWIndex({ path, dimension, metric: selectedMetric });
    hnswIndexId = result.id;
    
    // Get count and update info
    const countResult = await LlamaMobileVD.countHNSWIndex({ id: hnswIndexId });
    hnswIndexCount = countResult.count;
    updateHNSWIndexInfo();
    
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Load HNSWIndex', { id: result.id, path });
    updateStatus(`HNSWIndex loaded from ${path}`);
  } catch (error) {
    updateStatus(`Error loading index: ${error.message}`);
    displayAdvancedResult(hnswIndexAdvancedResultsEl, 'Load HNSWIndex', { error: error.message });
  }
});

// Version API operations
getVersionBtn.addEventListener('click', async () => {
  try {
    updateStatus('Getting full version...');
    
    const result = await LlamaMobileVD.getVersion({});
    versionInfoEl.innerHTML = `
      <h3>Version Information:</h3>
      <div class="version-info">
        <div class="version-item">Full Version: ${result.version}</div>
      </div>
    `;
    updateStatus('Version retrieved successfully');
  } catch (error) {
    updateStatus(`Error getting version: ${error.message}`);
    versionInfoEl.innerHTML = `Error: ${error.message}`;
  }
});

getVersionMajorBtn.addEventListener('click', async () => {
  try {
    updateStatus('Getting major version...');
    
    const result = await LlamaMobileVD.getVersionMajor({});
    versionInfoEl.innerHTML = `
      <h3>Version Information:</h3>
      <div class="version-info">
        <div class="version-item">Major Version: ${result.versionMajor}</div>
      </div>
    `;
    updateStatus('Major version retrieved successfully');
  } catch (error) {
    updateStatus(`Error getting major version: ${error.message}`);
    versionInfoEl.innerHTML = `Error: ${error.message}`;
  }
});

getVersionMinorBtn.addEventListener('click', async () => {
  try {
    updateStatus('Getting minor version...');
    
    const result = await LlamaMobileVD.getVersionMinor({});
    versionInfoEl.innerHTML = `
      <h3>Version Information:</h3>
      <div class="version-info">
        <div class="version-item">Minor Version: ${result.versionMinor}</div>
      </div>
    `;
    updateStatus('Minor version retrieved successfully');
  } catch (error) {
    updateStatus(`Error getting minor version: ${error.message}`);
    versionInfoEl.innerHTML = `Error: ${error.message}`;
  }
});

getVersionPatchBtn.addEventListener('click', async () => {
  try {
    updateStatus('Getting patch version...');
    
    const result = await LlamaMobileVD.getVersionPatch({});
    versionInfoEl.innerHTML = `
      <h3>Version Information:</h3>
      <div class="version-info">
        <div class="version-item">Patch Version: ${result.versionPatch}</div>
      </div>
    `;
    updateStatus('Patch version retrieved successfully');
  } catch (error) {
    updateStatus(`Error getting patch version: ${error.message}`);
    versionInfoEl.innerHTML = `Error: ${error.message}`;
  }
});

// Initialize info displays
updateVectorStoreInfo();
updateHNSWIndexInfo();
