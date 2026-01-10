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
    
    /**
     * Remove a vector from a vector store by ID
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the result
     */
    public JSObject removeVectorFromStore(PluginCall call) {
        String id = call.getString("id");
        Integer vectorId = call.getInt("vectorId");
        
        if (id == null || vectorId == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        boolean removed = store.remove(vectorId);
        JSObject result = new JSObject();
        result.put("result", removed);
        return result;
    }
    
    /**
     * Get a vector from a vector store by ID
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the vector or null
     */
    public JSObject getVectorFromStore(PluginCall call) {
        String id = call.getString("id");
        Integer vectorId = call.getInt("vectorId");
        
        if (id == null || vectorId == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        float[] vector = store.get(vectorId);
        if (vector == null) {
            return null;
        }
        
        JSArray vectorArray = new JSArray();
        for (float f : vector) {
            vectorArray.put(f);
        }
        
        JSObject result = new JSObject();
        result.put("vector", vectorArray);
        return result;
    }
    
    /**
     * Update a vector in a vector store by ID
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the result
     */
    public JSObject updateVectorInStore(PluginCall call) {
        String id = call.getString("id");
        Integer vectorId = call.getInt("vectorId");
        JSArray vectorArray = call.getArray("vector");
        
        if (id == null || vectorId == null || vectorArray == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        float[] vector = convertToFloatArray(vectorArray);
        boolean updated = store.update(vectorId, vector);
        JSObject result = new JSObject();
        result.put("result", updated);
        return result;
    }
    
    /**
     * Check if a vector exists in a vector store by ID
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the result
     */
    public JSObject containsVectorInStore(PluginCall call) {
        String id = call.getString("id");
        Integer vectorId = call.getInt("vectorId");
        
        if (id == null || vectorId == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        boolean contains = store.contains(vectorId);
        JSObject result = new JSObject();
        result.put("result", contains);
        return result;
    }
    
    /**
     * Reserve space for vectors in a vector store
     * 
     * @param call Plugin call with parameters
     */
    public void reserveVectorStore(PluginCall call) {
        String id = call.getString("id");
        Integer capacity = call.getInt("capacity");
        
        if (id == null || capacity == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        store.reserve(capacity);
    }
    
    /**
     * Get the dimension of vectors in a vector store
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the dimension
     */
    public JSObject getVectorStoreDimension(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        int dimension = store.getDimension();
        JSObject result = new JSObject();
        result.put("dimension", dimension);
        return result;
    }
    
    /**
     * Get the distance metric used by a vector store
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the metric
     */
    public JSObject getVectorStoreMetric(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        VectorStore store = vectorStores.get(id);
        if (store == null) {
            throw new IllegalArgumentException("VectorStore not found with id: " + id);
        }
        
        DistanceMetric metric = store.getMetric();
        String metricStr;
        switch (metric) {
            case L2:
                metricStr = "L2";
                break;
            case COSINE:
                metricStr = "COSINE";
                break;
            case DOT:
                metricStr = "DOT";
                break;
            default:
                metricStr = metric.name();
                break;
        }
        
        JSObject result = new JSObject();
        result.put("metric", metricStr);
        return result;
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
    
    /**
     * Set the efSearch parameter for HNSW index search
     * 
     * @param call Plugin call with parameters
     */
    public void setHNSWEfSearch(PluginCall call) {
        String id = call.getString("id");
        Integer efSearch = call.getInt("efSearch");
        
        if (id == null || efSearch == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        index.setEfSearch(efSearch);
    }
    
    /**
     * Get the efSearch parameter for HNSW index search
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the efSearch value
     */
    public JSObject getHNSWEfSearch(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        int efSearch = index.getEfSearch();
        JSObject result = new JSObject();
        result.put("efSearch", efSearch);
        return result;
    }
    
    /**
     * Check if a vector exists in an HNSW index by ID
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the result
     */
    public JSObject containsVectorInHNSW(PluginCall call) {
        String id = call.getString("id");
        Integer vectorId = call.getInt("vectorId");
        
        if (id == null || vectorId == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        boolean contains = index.contains(vectorId);
        JSObject result = new JSObject();
        result.put("result", contains);
        return result;
    }
    
    /**
     * Get a vector from an HNSW index by ID
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the vector or null
     */
    public JSObject getVectorFromHNSW(PluginCall call) {
        String id = call.getString("id");
        Integer vectorId = call.getInt("vectorId");
        
        if (id == null || vectorId == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        float[] vector = index.get(vectorId);
        if (vector == null) {
            return null;
        }
        
        JSArray vectorArray = new JSArray();
        for (float f : vector) {
            vectorArray.put(f);
        }
        
        JSObject result = new JSObject();
        result.put("vector", vectorArray);
        return result;
    }
    
    /**
     * Get the dimension of vectors in an HNSW index
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the dimension
     */
    public JSObject getHNSWDimension(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        int dimension = index.getDimension();
        JSObject result = new JSObject();
        result.put("dimension", dimension);
        return result;
    }
    
    /**
     * Get the capacity of an HNSW index
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the capacity
     */
    public JSObject getHNSWCapacity(PluginCall call) {
        String id = call.getString("id");
        
        if (id == null) {
            throw new IllegalArgumentException("Missing required parameter: id");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        int capacity = index.getCapacity();
        JSObject result = new JSObject();
        result.put("capacity", capacity);
        return result;
    }
    
    /**
     * Save an HNSW index to a file
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the result
     */
    public JSObject saveHNSWIndex(PluginCall call) {
        String id = call.getString("id");
        String path = call.getString("path");
        
        if (id == null || path == null) {
            throw new IllegalArgumentException("Missing required parameters");
        }
        
        HNSWIndex index = hnswIndexes.get(id);
        if (index == null) {
            throw new IllegalArgumentException("HNSWIndex not found with id: " + id);
        }
        
        index.save(path);
        JSObject result = new JSObject();
        result.put("result", true);
        return result;
    }
    
    /**
     * Load an HNSW index from a file
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the loaded index ID
     */
    public JSObject loadHNSWIndex(PluginCall call) {
        String path = call.getString("path");
        
        if (path == null) {
            throw new IllegalArgumentException("Missing required parameter: path");
        }
        
        HNSWIndex index = new HNSWIndex(path);
        String id = generateUniqueId();
        hnswIndexes.put(id, index);
        
        JSObject result = new JSObject();
        result.put("id", id);
        return result;
    }
    
    // MARK: Version Methods
    
    /**
     * Get the full version string of the SDK
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the version
     */
    public JSObject getVersion(PluginCall call) {
        String version = com.llamamobile.vd.LlamaMobileVD.getVersion();
        JSObject result = new JSObject();
        result.put("version", version);
        return result;
    }
    
    /**
     * Get the major version number
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the major version
     */
    public JSObject getVersionMajor(PluginCall call) {
        int major = com.llamamobile.vd.LlamaMobileVD.getVersionMajor();
        JSObject result = new JSObject();
        result.put("major", major);
        return result;
    }
    
    /**
     * Get the minor version number
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the minor version
     */
    public JSObject getVersionMinor(PluginCall call) {
        int minor = com.llamamobile.vd.LlamaMobileVD.getVersionMinor();
        JSObject result = new JSObject();
        result.put("minor", minor);
        return result;
    }
    
    /**
     * Get the patch version number
     * 
     * @param call Plugin call with parameters
     * @return JSObject with the patch version
     */
    public JSObject getVersionPatch(PluginCall call) {
        int patch = com.llamamobile.vd.LlamaMobileVD.getVersionPatch();
        JSObject result = new JSObject();
        result.put("patch", patch);
        return result;
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