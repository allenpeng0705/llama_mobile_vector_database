package com.llamamobile.vd;

import android.content.Context;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * React Native module for LlamaMobileVD vector database
 * Implements ReactContextBaseJavaModule to bridge JavaScript calls to native Android functionality
 */
public class LlamaMobileVDModule extends ReactContextBaseJavaModule {

    private static ReactApplicationContext reactContext;
    
    /**
     * Map of VectorStore instances by ID
     */
    private final Map<String, VectorStore> vectorStores = new HashMap<>();
    
    /**
     * Map of HNSWIndex instances by ID
     */
    private final Map<String, HNSWIndex> hnswIndexes = new HashMap<>();

    /**
     * Constructor for the module
     * @param reactContext The React application context
     */
    LlamaMobileVDModule(ReactApplicationContext context) {
        super(context);
        reactContext = context;
    }

    /**
     * Returns the name of the module exposed to JavaScript
     * @return The module name
     */
    @Override
    public String getName() {
        return "LlamaMobileVD";
    }

    /**
     * Generate a unique ID for a VectorStore or HNSWIndex
     * @return A unique string ID
     */
    private String generateUniqueId() {
        return UUID.randomUUID().toString();
    }

    /**
     * Convert a string to DistanceMetric enum
     * @param metricStr The string representation of the distance metric
     * @return The corresponding DistanceMetric enum value
     * @throws Exception if the string is not a valid distance metric
     */
    private DistanceMetric stringToDistanceMetric(String metricStr) throws Exception {
        switch (metricStr) {
            case "L2":
                return DistanceMetric.L2;
            case "COSINE":
                return DistanceMetric.COSINE;
            case "DOT":
                return DistanceMetric.DOT;
            default:
                throw new Exception("Invalid distance metric: " + metricStr);
        }
    }

    /**
     * Convert a ReadableArray to float array
     * @param array The ReadableArray to convert
     * @return The corresponding float array
     */
    private float[] convertToFloatArray(ReadableArray array) {
        float[] floatArray = new float[array.size()];
        for (int i = 0; i < array.size(); i++) {
            floatArray[i] = (float) array.getDouble(i);
        }
        return floatArray;
    }

    /**
     * Create a new VectorStore
     * @param options Options for creating the VectorStore
     * @param promise Completion handler for successful creation
     */
    @ReactMethod
    public void createVectorStore(ReadableMap options, Promise promise) {
        try {
            int dimension = options.getInt("dimension");
            String metricStr = options.getString("metric");
            DistanceMetric metric = stringToDistanceMetric(metricStr);

            VectorStore store = new VectorStore(dimension, metric);
            String id = generateUniqueId();
            vectorStores.put(id, store);

            WritableMap result = new WritableNativeMap();
            result.putString("id", id);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Create a new HNSWIndex
     * @param options Options for creating the HNSWIndex
     * @param promise Completion handler for successful creation
     */
    @ReactMethod
    public void createHNSWIndex(ReadableMap options, Promise promise) {
        try {
            int dimension = options.getInt("dimension");
            String metricStr = options.getString("metric");
            DistanceMetric metric = stringToDistanceMetric(metricStr);
            int m = options.getInt("m");
            int efConstruction = options.getInt("efConstruction");

            HNSWIndex index = new HNSWIndex(dimension, metric, m, efConstruction);
            String id = generateUniqueId();
            hnswIndexes.put(id, index);

            WritableMap result = new WritableNativeMap();
            result.putString("id", id);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Add a vector to a VectorStore
     * @param params Parameters for adding the vector
     * @param promise Completion handler for successful addition
     */
    @ReactMethod
    public void addVectorToStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            ReadableArray vectorArray = params.getArray("vector");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            float[] vector = convertToFloatArray(vectorArray);
            store.addVector(vector);

            promise.resolve(null);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Add a vector to an HNSWIndex
     * @param params Parameters for adding the vector
     * @param promise Completion handler for successful addition
     */
    @ReactMethod
    public void addVectorToHNSW(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            ReadableArray vectorArray = params.getArray("vector");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            float[] vector = convertToFloatArray(vectorArray);
            index.addVector(vector);

            promise.resolve(null);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Search for vectors in a VectorStore
     * @param params Parameters for searching the VectorStore
     * @param promise Completion handler for successful search
     */
    @ReactMethod
    public void searchVectorStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            ReadableArray queryVectorArray = params.getArray("queryVector");
            int k = params.getInt("k");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            float[] queryVector = convertToFloatArray(queryVectorArray);
            SearchResult[] results = store.search(queryVector, k);

            // Convert results to JSON compatible format
            WritableArray jsonResults = new WritableNativeArray();
            for (SearchResult result : results) {
                WritableMap resultMap = new WritableNativeMap();
                resultMap.putInt("index", result.getIndex());
                resultMap.putDouble("distance", result.getDistance());
                jsonResults.pushMap(resultMap);
            }

            promise.resolve(jsonResults);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Search for vectors in an HNSWIndex
     * @param params Parameters for searching the HNSWIndex
     * @param promise Completion handler for successful search
     */
    @ReactMethod
    public void searchHNSWIndex(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            ReadableArray queryVectorArray = params.getArray("queryVector");
            int k = params.getInt("k");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            float[] queryVector = convertToFloatArray(queryVectorArray);
            SearchResult[] results = index.search(queryVector, k, k);

            // Convert results to JSON compatible format
            WritableArray jsonResults = new WritableNativeArray();
            for (SearchResult result : results) {
                WritableMap resultMap = new WritableNativeMap();
                resultMap.putInt("index", result.getIndex());
                resultMap.putDouble("distance", result.getDistance());
                jsonResults.pushMap(resultMap);
            }

            promise.resolve(jsonResults);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Count the number of vectors in a VectorStore
     * @param params Parameters for counting vectors
     * @param promise Completion handler for successful count
     */
    @ReactMethod
    public void countVectorStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            int count = store.count();
            WritableMap result = new WritableNativeMap();
            result.putInt("count", count);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Count the number of vectors in an HNSWIndex
     * @param params Parameters for counting vectors
     * @param promise Completion handler for successful count
     */
    @ReactMethod
    public void countHNSWIndex(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            int count = index.count();
            WritableMap result = new WritableNativeMap();
            result.putInt("count", count);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Clear all vectors from a VectorStore
     * @param params Parameters for clearing the VectorStore
     * @param promise Completion handler for successful clearing
     */
    @ReactMethod
    public void clearVectorStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            store.clear();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Clear all vectors from an HNSWIndex
     * @param params Parameters for clearing the HNSWIndex
     * @param promise Completion handler for successful clearing
     */
    @ReactMethod
    public void clearHNSWIndex(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            index.clear();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Release resources associated with a VectorStore
     * @param params Parameters for releasing the VectorStore
     * @param promise Completion handler for successful release
     */
    @ReactMethod
    public void releaseVectorStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            if (vectorStores.remove(id) == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            promise.resolve(null);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Release resources associated with an HNSWIndex
     * @param params Parameters for releasing the HNSWIndex
     * @param promise Completion handler for successful release
     */
    @ReactMethod
    public void releaseHNSWIndex(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            if (hnswIndexes.remove(id) == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            promise.resolve(null);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }
}