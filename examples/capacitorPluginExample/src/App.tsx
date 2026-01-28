import { useState, useEffect } from 'react'
import { LlamaMobileVD } from 'llama-mobile-vd-capacitor-plugin'
import './App.css'

interface SearchResult {
  id: number
  distance: number
}

function App() {
  // Vector Store state
  const [vectorStoreId, setVectorStoreId] = useState<number | null>(null)
  const [vectorStoreCount, setVectorStoreCount] = useState(0)
  const [vectorStoreResults, setVectorStoreResults] = useState<SearchResult[]>([])
  
  // HNSW Index state
  const [hnswIndexId, setHnswIndexId] = useState<number | null>(null)
  const [hnswIndexCount, setHnswIndexCount] = useState(0)
  const [hnswIndexResults, setHnswIndexResults] = useState<SearchResult[]>([])
  
  // MMapVectorStore state
  const [mmapVectorStoreId, setMmapVectorStoreId] = useState<number | null>(null)
  const [mmapVectorStoreCount, setMmapVectorStoreCount] = useState(0)
  const [mmapVectorStoreDimension, setMmapVectorStoreDimension] = useState(0)
  const [mmapVectorStoreMetric, setMmapVectorStoreMetric] = useState('')
  const [mmapVectorStoreResults, setMmapVectorStoreResults] = useState<SearchResult[]>([])
  
  // Configuration state
  const [dimension, setDimension] = useState(128)
  const [selectedMetric, setSelectedMetric] = useState<'l2' | 'cosine' | 'dot'>('l2')
  const [hnswM, setHnswM] = useState(16)
  const [hnswEfConstruction, setHnswEfConstruction] = useState(200)
  const [searchK, setSearchK] = useState(5)
  const [efSearch, setEfSearch] = useState(50)
  
  // MMap file path
  const [mmapFilePath, setMmapFilePath] = useState('')
  
  // Status
  const [status, setStatus] = useState('Ready')

  // Set default MMap file path and check plugin version
  useEffect(() => {
    const setupMmapFilePath = async () => {
      try {
        const platform = typeof window !== 'undefined' ? (window as any).Capacitor?.getPlatform() : 'unknown'
        if (platform === 'android') {
          setMmapFilePath('/data/data/com.example.app/files/vector_store.mmap')
          console.log('MMap file path set to Android data directory')
        } else if (platform === 'ios') {
          setMmapFilePath('vector_store.mmap')
          console.log('MMap file path set to iOS relative path (will be resolved to Documents directory)')
        } else {
          setMmapFilePath('vector_store.mmap')
          console.log('MMap file path set to relative path')
        }
      } catch (error) {
        console.error('Error setting up MMap file path:', error)
        setMmapFilePath('vector_store.mmap')
      }
    }
    
    const checkPluginVersion = async () => {
      try {
        console.log('Checking plugin version...')
        const versionResult = await LlamaMobileVD.getVersion()
        console.log('Plugin version:', versionResult.version)
        // Log the version number to the console
        console.log('🚀 Plugin version:', versionResult.version)
        // Also log the platform
        console.log('🚀 Platform:', typeof window !== 'undefined' ? (window as any).Capacitor?.getPlatform() : 'unknown')
        if (versionResult.version === '1.0.0-web') {
          updateStatus('WARNING: Using web fallback implementation, not native iOS!')
        } else {
          updateStatus(`SUCCESS: Using native iOS implementation! Version: ${versionResult.version}`)
        }
      } catch (error) {
        console.error('Error checking plugin version:', error)
        updateStatus(`Error checking plugin version: ${error instanceof Error ? error.message : 'Unknown error'}`)
      }
    }
    
    setupMmapFilePath()
    checkPluginVersion()
  }, [])

  // Helper functions
  const createRandomVector = (dimension: number): number[] => {
    return Array.from({ length: dimension }, () => Math.random() * 2 - 1)
  }

  const updateStatus = (message: string) => {
    setStatus(message)
  }

  // VectorStore operations
  const createVectorStore = async () => {
    updateStatus('Creating VectorStore...')
    
    try {
      const result = await LlamaMobileVD.createVectorStore({
        dimension,
        metric: selectedMetric
      })
      setVectorStoreId(result.storeId)
      setVectorStoreCount(0)
      setVectorStoreResults([])
      updateStatus('VectorStore created successfully')
    } catch (error) {
      updateStatus(`Error creating VectorStore: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const addVectorsToStore = async () => {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first')
      return
    }
    
    updateStatus('Adding 100 vectors to VectorStore...')
    
    try {
      const vectors: number[][] = []
      for (let i = 0; i < 100; i++) {
        vectors.push(createRandomVector(dimension))
      }
      
      await LlamaMobileVD.addVectors({
        storeId: vectorStoreId,
        vectors
      })
      
      const countResult = await LlamaMobileVD.getVectorCount({ storeId: vectorStoreId })
      setVectorStoreCount(countResult.count)
      updateStatus('Added 100 vectors to VectorStore')
    } catch (error) {
      updateStatus(`Error adding vectors to VectorStore: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const searchVectorStore = async () => {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first')
      return
    }
    
    if (vectorStoreCount === 0) {
      updateStatus('Please add vectors to the VectorStore first')
      return
    }
    
    updateStatus('Searching VectorStore...')
    
    try {
      const queryVector = createRandomVector(dimension)
      const result = await LlamaMobileVD.search({
        storeId: vectorStoreId,
        queryVector,
        k: searchK
      })
      
      setVectorStoreResults(
        result.ids.map((id: number, index: number) => ({
          id,
          distance: result.distances[index]
        }))
      )
      updateStatus('Search completed successfully')
    } catch (error) {
      updateStatus(`Error searching VectorStore: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const clearVectorStore = async () => {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first')
      return
    }
    
    updateStatus('Clearing VectorStore...')
    
    try {
      await LlamaMobileVD.clearVectors({ storeId: vectorStoreId })
      setVectorStoreCount(0)
      setVectorStoreResults([])
      updateStatus('VectorStore cleared successfully')
    } catch (error) {
      updateStatus(`Error clearing VectorStore: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const releaseVectorStore = async () => {
    if (!vectorStoreId) {
      updateStatus('Please create a VectorStore first')
      return
    }
    
    updateStatus('Releasing VectorStore...')
    
    try {
      await LlamaMobileVD.destroyVectorStore({ storeId: vectorStoreId })
      setVectorStoreId(null)
      setVectorStoreCount(0)
      setVectorStoreResults([])
      updateStatus('VectorStore released successfully')
    } catch (error) {
      updateStatus(`Error releasing VectorStore: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  // HNSWIndex operations
  const createHNSWIndex = async () => {
    updateStatus('Creating HNSWIndex...')
    
    try {
      const result = await LlamaMobileVD.createHNSWIndex({
        dimension,
        metric: selectedMetric,
        maxElements: 10000,
        m: hnswM,
        efConstruction: hnswEfConstruction
      })
      setHnswIndexId(result.indexId)
      setHnswIndexCount(0)
      setHnswIndexResults([])
      updateStatus('HNSWIndex created successfully')
    } catch (error) {
      updateStatus(`Error creating HNSWIndex: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const addVectorsToHNSW = async () => {
    if (!hnswIndexId) {
      updateStatus('Please create an HNSWIndex first')
      return
    }
    
    updateStatus('Adding 100 vectors to HNSWIndex...')
    
    try {
      const vectors: number[][] = []
      for (let i = 0; i < 100; i++) {
        vectors.push(createRandomVector(dimension))
      }
      
      await LlamaMobileVD.addVectorsToHNSW({
        indexId: hnswIndexId,
        vectors
      })
      
      setHnswIndexCount(prev => prev + 100)
      updateStatus('Added 100 vectors to HNSWIndex')
    } catch (error) {
      updateStatus(`Error adding vectors to HNSWIndex: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const searchHNSWIndex = async () => {
    if (!hnswIndexId) {
      updateStatus('Please create an HNSWIndex first')
      return
    }
    
    if (hnswIndexCount === 0) {
      updateStatus('Please add vectors to the HNSWIndex first')
      return
    }
    
    updateStatus('Searching HNSWIndex...')
    
    try {
      const queryVector = createRandomVector(dimension)
      const result = await LlamaMobileVD.searchHNSW({
        indexId: hnswIndexId,
        queryVector,
        k: searchK,
        efSearch
      })
      
      setHnswIndexResults(
        result.ids.map((id: number, index: number) => ({
          id,
          distance: result.distances[index]
        }))
      )
      updateStatus('HNSWIndex search completed successfully')
    } catch (error) {
      updateStatus(`Error searching HNSWIndex: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const releaseHNSWIndex = async () => {
    if (!hnswIndexId) {
      updateStatus('Please create an HNSWIndex first')
      return
    }
    
    updateStatus('Releasing HNSWIndex...')
    
    try {
      await LlamaMobileVD.destroyHNSWIndex({ indexId: hnswIndexId })
      setHnswIndexId(null)
      setHnswIndexCount(0)
      setHnswIndexResults([])
      updateStatus('HNSWIndex released successfully')
    } catch (error) {
      updateStatus(`Error releasing HNSWIndex: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  // MMapVectorStore operations
  const createMMapVectorStore = async () => {
    updateStatus('Creating MMapVectorStore...')
    
    try {
      const builderResult = await LlamaMobileVD.createMMapVectorStoreBuilder({
        dimension,
        metric: selectedMetric
      })
      
      // Add 100 vectors to the builder
      const vectors: number[][] = []
      for (let i = 0; i < 100; i++) {
        vectors.push(createRandomVector(dimension))
      }
      
      await LlamaMobileVD.addVectorsToMMapBuilder({
        builderId: builderResult.builderId,
        vectors
      })
      
      // Build the MMap vector store
      await LlamaMobileVD.buildMMapVectorStore({ 
        builderId: builderResult.builderId,
        path: mmapFilePath
      })
      
      // Destroy the builder
      await LlamaMobileVD.destroyMMapVectorStoreBuilder({ builderId: builderResult.builderId })
      
      updateStatus('MMapVectorStore created successfully')
    } catch (error) {
      updateStatus(`Error creating MMapVectorStore: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const openMMapVectorStore = async () => {
    updateStatus('Opening MMapVectorStore...')
    
    try {
      const result = await LlamaMobileVD.openMMapVectorStore({
        path: mmapFilePath
      })
      setMmapVectorStoreId(result.storeId)
      setMmapVectorStoreCount(100) // We added 100 vectors when creating
      setMmapVectorStoreDimension(dimension)
      setMmapVectorStoreMetric(selectedMetric)
      updateStatus('MMapVectorStore opened successfully')
    } catch (error) {
      updateStatus(`Error opening MMapVectorStore: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const searchMMapVectorStore = async () => {
    if (!mmapVectorStoreId) {
      updateStatus('Please open a MMapVectorStore first')
      return
    }
    
    updateStatus('Searching MMapVectorStore...')
    
    try {
      const queryVector = createRandomVector(dimension)
      const result = await LlamaMobileVD.search({
        storeId: mmapVectorStoreId,
        queryVector,
        k: searchK
      })
      
      setMmapVectorStoreResults(
        result.ids.map((id: number, index: number) => ({
          id,
          distance: result.distances[index]
        }))
      )
      updateStatus('MMapVectorStore search completed successfully')
    } catch (error) {
      updateStatus(`Error searching MMapVectorStore: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const releaseMMapVectorStore = async () => {
    if (!mmapVectorStoreId) {
      updateStatus('Please open a MMapVectorStore first')
      return
    }
    
    updateStatus('Releasing MMapVectorStore...')
    
    try {
      await LlamaMobileVD.closeMMapVectorStore({ storeId: mmapVectorStoreId })
      setMmapVectorStoreId(null)
      setMmapVectorStoreCount(0)
      setMmapVectorStoreDimension(0)
      setMmapVectorStoreMetric('')
      setMmapVectorStoreResults([])
      updateStatus('MMapVectorStore released successfully')
    } catch (error) {
      updateStatus(`Error releasing MMapVectorStore: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  return (
    <div className="app">
      <header className="app-header">
        <h1>LlamaMobileVD Capacitor Example</h1>
      </header>
      
      <main className="app-content">
        {/* Status */}
        <div className="status-card">
          <h2>Status</h2>
          <div className="status-message">{status}</div>
        </div>

        {/* Configuration */}
        <div className="config-card">
          <h2>Configuration</h2>
          
          <div className="config-item">
            <label>Vector Dimension: {dimension}</label>
            <input
              type="range"
              min="10"
              max="256"
              value={dimension}
              onChange={(e) => setDimension(parseInt(e.target.value))}
            />
          </div>

          <div className="config-item">
            <label>Distance Metric:</label>
            <div className="metric-buttons">
              <button
                className={selectedMetric === 'l2' ? 'active' : ''}
                onClick={() => setSelectedMetric('l2')}
              >
                L2
              </button>
              <button
                className={selectedMetric === 'cosine' ? 'active' : ''}
                onClick={() => setSelectedMetric('cosine')}
              >
                COSINE
              </button>
              <button
                className={selectedMetric === 'dot' ? 'active' : ''}
                onClick={() => setSelectedMetric('dot')}
              >
                DOT
              </button>
            </div>
          </div>

          <h3>HNSW Parameters</h3>
          <div className="config-item">
            <label>M (Connections per node): {hnswM}</label>
            <input
              type="range"
              min="5"
              max="50"
              value={hnswM}
              onChange={(e) => setHnswM(parseInt(e.target.value))}
            />
          </div>

          <div className="config-item">
            <label>efConstruction: {hnswEfConstruction}</label>
            <input
              type="range"
              min="50"
              max="500"
              value={hnswEfConstruction}
              onChange={(e) => setHnswEfConstruction(parseInt(e.target.value))}
            />
          </div>

          <div className="config-item">
            <label>Search k: {searchK}</label>
            <input
              type="range"
              min="1"
              max="20"
              value={searchK}
              onChange={(e) => setSearchK(parseInt(e.target.value))}
            />
          </div>

          <div className="config-item">
            <label>HNSW efSearch: {efSearch}</label>
            <input
              type="range"
              min="10"
              max="200"
              value={efSearch}
              onChange={(e) => setEfSearch(parseInt(e.target.value))}
            />
          </div>
        </div>

        {/* VectorStore */}
        <div className="card">
          <h2>VectorStore (Exact Search)</h2>
          
          <div className="button-grid">
            <button onClick={createVectorStore}>
              Create VectorStore
            </button>
            <button onClick={addVectorsToStore}>
              Add 100 Vectors
            </button>
          </div>

          <div className="button-grid">
            <button onClick={searchVectorStore}>
              Search
            </button>
            <button onClick={clearVectorStore}>
              Clear
            </button>
            <button onClick={releaseVectorStore}>
              Release
            </button>
          </div>

          <div className="info-section">
            <h3>VectorStore Info</h3>
            <p>Status: {vectorStoreId ? 'Created' : 'None'}</p>
            <p>Vector count: {vectorStoreCount}</p>
          </div>

          {vectorStoreResults.length > 0 && (
            <div className="results-section">
              <h3>Search Results</h3>
              <div className="results-list">
                {vectorStoreResults.map((result, index) => (
                  <div key={index} className="result-item">
                    <span>ID: {result.id}</span>
                    <span>Distance: {result.distance.toFixed(6)}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* HNSWIndex */}
        <div className="card">
          <h2>HNSWIndex (Approximate Search)</h2>
          
          <div className="button-grid">
            <button onClick={createHNSWIndex}>
              Create HNSWIndex
            </button>
            <button onClick={addVectorsToHNSW}>
              Add 100 Vectors
            </button>
          </div>

          <div className="button-grid">
            <button onClick={searchHNSWIndex}>
              Search
            </button>
            <button onClick={releaseHNSWIndex}>
              Release
            </button>
          </div>

          <div className="info-section">
            <h3>HNSWIndex Info</h3>
            <p>Status: {hnswIndexId ? 'Created' : 'None'}</p>
            <p>Vector count: {hnswIndexCount}</p>
          </div>

          {hnswIndexResults.length > 0 && (
            <div className="results-section">
              <h3>Search Results</h3>
              <div className="results-list">
                {hnswIndexResults.map((result, index) => (
                  <div key={index} className="result-item">
                    <span>ID: {result.id}</span>
                    <span>Distance: {result.distance.toFixed(6)}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* MMapVectorStore */}
        <div className="card">
          <h2>MMapVectorStore (Memory-Mapped Vector Store)</h2>
          
          <div className="config-item">
            <label>MMap File Path:</label>
            <input
              type="text"
              value={mmapFilePath}
              onChange={(e) => setMmapFilePath(e.target.value)}
              placeholder="Enter file path"
            />
          </div>

          <button className="create-mmap-button" onClick={createMMapVectorStore}>
            Create MMapVectorStore
          </button>

          <div className="button-grid">
            <button onClick={openMMapVectorStore}>
              Open MMapVectorStore
            </button>
            <button onClick={searchMMapVectorStore}>
              Search
            </button>
            <button onClick={releaseMMapVectorStore}>
              Release
            </button>
          </div>

          <div className="info-section">
            <h3>MMapVectorStore Info</h3>
            <p>Status: {mmapVectorStoreId ? 'Opened' : 'None'}</p>
            <p>Vector count: {mmapVectorStoreCount}</p>
            <p>Dimension: {mmapVectorStoreDimension}</p>
            <p>Metric: {mmapVectorStoreMetric}</p>
          </div>

          {mmapVectorStoreResults.length > 0 && (
            <div className="results-section">
              <h3>Search Results</h3>
              <div className="results-list">
                {mmapVectorStoreResults.map((result, index) => (
                  <div key={index} className="result-item">
                    <span>ID: {result.id}</span>
                    <span>Distance: {result.distance.toFixed(6)}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}

export default App
