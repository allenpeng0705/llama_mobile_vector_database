/**
 * Android implementation of the LlamaMobileVD Capacitor Plugin
 * A high-performance vector database for mobile applications
 */

package com.capacitor.plugin.llamamobilevd;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

/**
 * LlamaMobileVD Capacitor Plugin for Android
 */
@CapacitorPlugin(name = "LlamaMobileVD")
public class LlamaMobileVDPlugin extends Plugin {
    
    /**
     * Implementation of the plugin functionality
     */
    private LlamaMobileVDImpl implementation;

    /**
     * Load the plugin and initialize the implementation
     */
    @Override
    public void load() {
        super.load();
        this.implementation = new LlamaMobileVDImpl(getContext());
    }

    // MARK: VectorStore Methods

    /**
     * Create a new vector store
     * 
     * @param call Plugin call with options
     */
    @PluginMethod
    public void createVectorStore(PluginCall call) {
        try {
            JSObject result = implementation.createVectorStore(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Add a vector to a vector store
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void addVectorToStore(PluginCall call) {
        try {
            implementation.addVectorToStore(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Search for nearest neighbors in a vector store
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void searchVectorStore(PluginCall call) {
        try {
            JSObject result = implementation.searchVectorStore(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Get the number of vectors in a vector store
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getVectorStoreCount(PluginCall call) {
        try {
            JSObject result = implementation.getVectorStoreCount(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Clear all vectors from a vector store
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void clearVectorStore(PluginCall call) {
        try {
            implementation.clearVectorStore(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Release a vector store and free resources
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void releaseVectorStore(PluginCall call) {
        try {
            implementation.releaseVectorStore(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Remove a vector from a vector store by ID
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void removeVectorFromStore(PluginCall call) {
        try {
            JSObject result = implementation.removeVectorFromStore(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get a vector from a vector store by ID
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getVectorFromStore(PluginCall call) {
        try {
            JSObject result = implementation.getVectorFromStore(call);
            if (result != null) {
                call.resolve(result);
            } else {
                call.resolve(null);
            }
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Update a vector in a vector store by ID
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void updateVectorInStore(PluginCall call) {
        try {
            JSObject result = implementation.updateVectorInStore(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Check if a vector exists in a vector store by ID
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void containsVectorInStore(PluginCall call) {
        try {
            JSObject result = implementation.containsVectorInStore(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Reserve space for vectors in a vector store
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void reserveVectorStore(PluginCall call) {
        try {
            implementation.reserveVectorStore(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the dimension of vectors in a vector store
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getVectorStoreDimension(PluginCall call) {
        try {
            JSObject result = implementation.getVectorStoreDimension(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the distance metric used by a vector store
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getVectorStoreMetric(PluginCall call) {
        try {
            JSObject result = implementation.getVectorStoreMetric(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    // MARK: HNSWIndex Methods

    /**
     * Create a new HNSW index
     * 
     * @param call Plugin call with options
     */
    @PluginMethod
    public void createHNSWIndex(PluginCall call) {
        try {
            JSObject result = implementation.createHNSWIndex(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Add a vector to an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void addVectorToIndex(PluginCall call) {
        try {
            implementation.addVectorToIndex(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Search for nearest neighbors in an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void searchHNSWIndex(PluginCall call) {
        try {
            JSObject result = implementation.searchHNSWIndex(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Get the number of vectors in an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getHNSWIndexCount(PluginCall call) {
        try {
            JSObject result = implementation.getHNSWIndexCount(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Clear all vectors from an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void clearHNSWIndex(PluginCall call) {
        try {
            implementation.clearHNSWIndex(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    /**
     * Release an HNSW index and free resources
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void releaseHNSWIndex(PluginCall call) {
        try {
            implementation.releaseHNSWIndex(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Set the efSearch parameter for HNSW index search
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void setHNSWEfSearch(PluginCall call) {
        try {
            implementation.setHNSWEfSearch(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the efSearch parameter for HNSW index search
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getHNSWEfSearch(PluginCall call) {
        try {
            JSObject result = implementation.getHNSWEfSearch(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Check if a vector exists in an HNSW index by ID
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void containsVectorInHNSW(PluginCall call) {
        try {
            JSObject result = implementation.containsVectorInHNSW(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get a vector from an HNSW index by ID
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getVectorFromHNSW(PluginCall call) {
        try {
            JSObject result = implementation.getVectorFromHNSW(call);
            if (result != null) {
                call.resolve(result);
            } else {
                call.resolve(null);
            }
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the dimension of vectors in an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getHNSWDimension(PluginCall call) {
        try {
            JSObject result = implementation.getHNSWDimension(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the capacity of an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getHNSWCapacity(PluginCall call) {
        try {
            JSObject result = implementation.getHNSWCapacity(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Save an HNSW index to a file
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void saveHNSWIndex(PluginCall call) {
        try {
            implementation.saveHNSWIndex(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Load an HNSW index from a file
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void loadHNSWIndex(PluginCall call) {
        try {
            JSObject result = implementation.loadHNSWIndex(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    // MARK: MMapVectorStore Methods
    
    /**
     * Open an existing MMapVectorStore from a file
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void openMMapVectorStore(PluginCall call) {
        try {
            JSObject result = implementation.openMMapVectorStore(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Search for nearest neighbors in an MMapVectorStore
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void searchMMapVectorStore(PluginCall call) {
        try {
            JSObject result = implementation.searchMMapVectorStore(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the number of vectors in an MMapVectorStore
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getMMapVectorStoreCount(PluginCall call) {
        try {
            JSObject result = implementation.getMMapVectorStoreCount(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the dimension of vectors in an MMapVectorStore
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getMMapVectorStoreDimension(PluginCall call) {
        try {
            JSObject result = implementation.getMMapVectorStoreDimension(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the distance metric used by an MMapVectorStore
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getMMapVectorStoreMetric(PluginCall call) {
        try {
            JSObject result = implementation.getMMapVectorStoreMetric(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Release an MMapVectorStore and free resources
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void releaseMMapVectorStore(PluginCall call) {
        try {
            implementation.releaseMMapVectorStore(call);
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    // MARK: Version Methods
    
    /**
     * Get the full version string of the SDK
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getVersion(PluginCall call) {
        try {
            JSObject result = implementation.getVersion(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the major version number
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getVersionMajor(PluginCall call) {
        try {
            JSObject result = implementation.getVersionMajor(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the minor version number
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getVersionMinor(PluginCall call) {
        try {
            JSObject result = implementation.getVersionMinor(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    
    /**
     * Get the patch version number
     * 
     * @param call Plugin call with parameters
     */
    @PluginMethod
    public void getVersionPatch(PluginCall call) {
        try {
            JSObject result = implementation.getVersionPatch(call);
            call.resolve(result);
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
}