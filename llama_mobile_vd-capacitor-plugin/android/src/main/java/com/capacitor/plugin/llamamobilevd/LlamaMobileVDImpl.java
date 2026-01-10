/**
 * Implementation of the LlamaMobileVD Capacitor Plugin for Android
 * A high-performance vector database for mobile applications
 */

package com.capacitor.plugin.llamamobilevd;

import android.content.Context;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;
import com.llamamobile.vd.DistanceMetric;
import com.llamamobile.vd.HNSWIndex;
import com.llamamobile.vd.SearchResult;
import com.llamamobile.vd.VectorStore;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Implementation of the LlamaMobileVD plugin functionality
 */
public class LlamaMobileVDImpl {
    /**
     * Context for the plugin
     */
    private final Context context;
    
    /**
     * Map of VectorStore instances by ID
     */
    private final Map<String, VectorStore> vectorStores = new HashMap<>();
    
    /**
     * Map of HNSWIndex instances by ID
     */
    private final Map<String, HNSWIndex> hnswIndexes = new HashMap<>();

    /**
     * Constructor for the implementation
     * 
     * @param context Context for the plugin
     */
    public LlamaMobileVDImpl(Context context) {
        this.context = context;
    }

    /**
     * Convert a string distance metric to the native Android enum
     * 
     * @param metricStr String representation of the distance metric
     * @return DistanceMetric enum value
     * @throws IllegalArgumentException if the metric string is invalid
     */
    private DistanceMetric stringToDistanceMetric(String metricStr) {
        switch (metricStr.toUpperCase()) {
            case "L2":
                return DistanceMetric.L2;
            case "COSINE":
                return DistanceMetric.COSINE;
            case "DOT":
                return DistanceMetric.DOT;
            default:
                throw new IllegalArgumentException("Invalid distance metric: " + metricStr);
        }
    }

    /**
     * Generate a unique ID for a VectorStore or HNSWIndex
     * 
     * @return A unique string ID
     */
    private String generateUniqueId() {
        return UUID.randomUUID().toString();
    }

    /**
     * Convert a JSArray to a float array
     * 
     * @param jsArray JSArray containing numbers
     * @return Float array
     */
    private float[] convertToFloatArray(JSArray jsArray) {
        List<Object> objList = jsArray.toList();
        float[] floatArray = new float[objList.size()];
        
        for (int i = 0; i < objList.size(); i++) {
            Object obj = objList.get(i);
            if (obj instanceof Number) {
                floatArray[i] = ((Number) obj).floatValue();
            } else {
                throw new IllegalArgumentException("Vector contains non-numeric values");
            }
        }
        
        return floatArray;
    }

    // MARK: VectorStore Methods

    /**
     * Create a new vector store
     * 
     * @param call Plugin call with options
     * @return JSObject with the created store ID
     */
    public JSObject createVectorStore(PluginCall call) {
        Integer dimension = call.getInt("dimension");
        String metricStr = call.getString("metric");
        
        if (dimension == null || metricStr == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        DistanceMetric metric = stringToDistanceMetric(metricStr);
        VectorStore store = new VectorStore(dimension, metric);
        
        String id = generateUniqueId();
        vectorStores.put(id, store);
        
        JSObject result = new JSObject();
        result.put("id", id);
        return result;
    }

    /**
     * Add a vector to a vector store
     * 
     * @param call Plugin call with parameters
     */
    public void addVectorToStore(PluginCall call) {
        String id = call.getString("id");
        JSArray vectorArray = call.getArray("vector");
        Integer vectorId = call.getInt("vectorId");
        
        if (id == null || vectorArray == null || vectorId == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        float[] vector = convertToFloatArray(vectorArray);
        store.addVector(vector, vectorId);
    }

    /**
     * Search for nearest neighbors in a vector store
     * 
     * @param call Plugin call with parameters
     * @return JSObject with search results
     */
    public JSObject searchVectorStore(PluginCall call) {
        String id = call.getString("id");
        JSArray queryVectorArray = call.getArray("queryVector");
        Integer k = call.getInt("k");
        
        if (id == null || queryVectorArray == null || k == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        float[] queryVector = convertToFloatArray(queryVectorArray);
        SearchResult[] results = store.search(queryVector, k);
        
        return convertSearchResultsToJSObject(results);
    }

    /**
     * Get the number of vectors in a vector store
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the count of vectors
     */
    public JSObject getVectorStoreCount(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        int count = store.getCount();
        JSObject result = new JSObject();
        result.put("count", count);
        return result;
    }

    /**
     * Clear all vectors from a vector store
     * 
     * @param call Plugin call with parameters
     */
    public void clearVectorStore(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        store.clear();
    }

    /**
     * Release a vector store and free resources
     * 
     * @param call Plugin call with parameters
     */
    public void releaseVectorStore(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        VectorStore store = vectorStores.remove(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        store.close();
    }

    // MARK: HNSWIndex Methods

    /**
     * Create a new HNSW index
     * 
     * @param call Plugin call with options
     * @return JSObject with the created index ID
     */
    public JSObject createHNSWIndex(PluginCall call) {
        Integer dimension = call.getInt("dimension");
        String metricStr = call.getString("metric");
        
        if (dimension == null || metricStr == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        DistanceMetric metric = stringToDistanceMetric(metricStr);
        Integer m = call.getInt("m", 16);
        Integer efConstruction = call.getInt("efConstruction", 200);
        
        HNSWIndex index = new HNSWIndex(dimension, metric, m, efConstruction);
        
        String id = generateUniqueId();
        hnswIndexes.put(id, index);
        
        JSObject result = new JSObject();
        result.put("id", id);
        return result;
    }

    /**
     * Add a vector to an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    public void addVectorToIndex(PluginCall call) {
        String id = call.getString("id");
        JSArray vectorArray = call.getArray("vector");
        Integer vectorId = call.getInt("vectorId");
        
        if (id == null || vectorArray == null || vectorId == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        float[] vector = convertToFloatArray(vectorArray);
        index.addVector(vector, vectorId);
    }

    /**
     * Search for nearest neighbors in an HNSW index
     * 
     * @param call Plugin call with parameters
     * @return JSObject with search results
     */
    public JSObject searchHNSWIndex(PluginCall call) {
        String id = call.getString("id");
        JSArray queryVectorArray = call.getArray("queryVector");
        Integer k = call.getInt("k");
        
        if (id == null || queryVectorArray == null || k == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        float[] queryVector = convertToFloatArray(queryVectorArray);
        Integer efSearch = call.getInt("efSearch", 50);
        
        SearchResult[] results = index.search(queryVector, k, efSearch);
        
        return convertSearchResultsToJSObject(results);
    }

    /**
     * Get the number of vectors in an HNSW index
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the count of vectors
     */
    public JSObject getHNSWIndexCount(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        int count = index.getCount();
        JSObject result = new JSObject();
        result.put("count", count);
        return result;
    }

    /**
     * Clear all vectors from an HNSW index
     * 
     * @param call Plugin call with parameters
     */
    public void clearHNSWIndex(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        index.clear();
    }

    /**
     * Release an HNSW index and free resources
     * 
     * @param call Plugin call with parameters
     */
    public void releaseHNSWIndex(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        HNSWIndex index = hnswIndexes.remove(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        index.close();
    }

    // MARK: Helper Methods

    /**
     * Convert SearchResult array to JSObject
     * 
     * @param results SearchResult array
     * @return JSObject with search results
     */
    private JSObject convertSearchResultsToJSObject(SearchResult[] results) {
        JSArray jsResults = new JSArray();
        
        for (SearchResult result : results) {
            JSObject jsResult = new JSObject();
            jsResult.put("id", result.getId());
            jsResult.put("distance", result.getDistance());
            jsResults.put(jsResult);
        }
        
        JSObject result = new JSObject();
        result.put("results", jsResults);
        return result;
    }
}