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
}