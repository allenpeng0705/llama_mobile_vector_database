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
            int vectorId = params.getInt("vectorId");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            float[] vector = convertToFloatArray(vectorArray);
            store.addVector(vector, vectorId);

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
            int vectorId = params.getInt("vectorId");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            float[] vector = convertToFloatArray(vectorArray);
            index.addVector(vector, vectorId);

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
     * Remove a vector from a VectorStore by ID
     * @param params Parameters for removing the vector
     * @param promise Completion handler for successful removal
     */
    @ReactMethod
    public void removeVectorFromStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            int vectorId = params.getInt("vectorId");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            boolean removed = store.remove(vectorId);
            promise.resolve(removed);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get a vector from a VectorStore by ID
     * @param params Parameters for getting the vector
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getVectorFromStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            int vectorId = params.getInt("vectorId");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            float[] vector = store.get(vectorId);
            if (vector != null) {
                // Convert float array to WritableArray
                WritableArray result = new WritableNativeArray();
                for (float value : vector) {
                    result.pushDouble(value);
                }
                promise.resolve(result);
            } else {
                promise.resolve(null);
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Update a vector in a VectorStore by ID
     * @param params Parameters for updating the vector
     * @param promise Completion handler for successful update
     */
    @ReactMethod
    public void updateVectorInStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            int vectorId = params.getInt("vectorId");
            ReadableArray vectorArray = params.getArray("vector");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            float[] vector = convertToFloatArray(vectorArray);
            boolean updated = store.update(vectorId, vector);
            promise.resolve(updated);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Check if a VectorStore contains a vector with the given ID
     * @param params Parameters for checking the vector
     * @param promise Completion handler for successful check
     */
    @ReactMethod
    public void containsVectorInStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            int vectorId = params.getInt("vectorId");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            boolean contains = store.contains(vectorId);
            promise.resolve(contains);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Reserve space for vectors in a VectorStore
     * @param params Parameters for reserving space
     * @param promise Completion handler for successful reservation
     */
    @ReactMethod
    public void reserveVectorStore(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            int capacity = params.getInt("capacity");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            store.reserve(capacity);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get the dimension of vectors in a VectorStore
     * @param params Parameters for getting the dimension
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getVectorStoreDimension(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
            }

            int dimension = store.getDimension();
            WritableMap result = new WritableNativeMap();
            result.putInt("dimension", dimension);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get the distance metric used by a VectorStore
     * @param params Parameters for getting the metric
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getVectorStoreMetric(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            VectorStore store = vectorStores.get(id);
            if (store == null) {
                throw new Exception("VectorStore not found for id: " + id);
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
                    metricStr = "L2";
            }
            WritableMap result = new WritableNativeMap();
            result.putString("metric", metricStr);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Set the efSearch parameter for an HNSWIndex
     * @param params Parameters for setting efSearch
     * @param promise Completion handler for successful setting
     */
    @ReactMethod
    public void setHNSWEfSearch(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            int efSearch = params.getInt("efSearch");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            index.setEfSearch(efSearch);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get the current efSearch parameter for an HNSWIndex
     * @param params Parameters for getting efSearch
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getHNSWEfSearch(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            int efSearch = index.getEfSearch();
            WritableMap result = new WritableNativeMap();
            result.putInt("efSearch", efSearch);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Check if an HNSWIndex contains a vector with the given ID
     * @param params Parameters for checking the vector
     * @param promise Completion handler for successful check
     */
    @ReactMethod
    public void containsVectorInHNSW(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            int vectorId = params.getInt("vectorId");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            boolean contains = index.contains(vectorId);
            promise.resolve(contains);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get a vector from an HNSWIndex by ID
     * @param params Parameters for getting the vector
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getVectorFromHNSW(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            int vectorId = params.getInt("vectorId");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            float[] vector = index.getVector(vectorId);
            if (vector != null) {
                // Convert float array to WritableArray
                WritableArray result = new WritableNativeArray();
                for (float value : vector) {
                    result.pushDouble(value);
                }
                promise.resolve(result);
            } else {
                promise.resolve(null);
            }
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get the dimension of vectors in an HNSWIndex
     * @param params Parameters for getting the dimension
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getHNSWDimension(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            int dimension = index.getDimension();
            WritableMap result = new WritableNativeMap();
            result.putInt("dimension", dimension);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get the capacity of an HNSWIndex
     * @param params Parameters for getting the capacity
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getHNSWCapacity(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            int capacity = index.getCapacity();
            WritableMap result = new WritableNativeMap();
            result.putInt("capacity", capacity);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Save an HNSWIndex to a file
     * @param params Parameters for saving the index
     * @param promise Completion handler for successful saving
     */
    @ReactMethod
    public void saveHNSWIndex(ReadableMap params, Promise promise) {
        try {
            String id = params.getString("id");
            String path = params.getString("path");

            HNSWIndex index = hnswIndexes.get(id);
            if (index == null) {
                throw new Exception("HNSWIndex not found for id: " + id);
            }

            boolean saved = index.save(path);
            promise.resolve(saved);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Load an HNSWIndex from a file
     * @param params Parameters for loading the index
     * @param promise Completion handler for successful loading
     */
    @ReactMethod
    public void loadHNSWIndex(ReadableMap params, Promise promise) {
        try {
            String path = params.getString("path");

            HNSWIndex index = HNSWIndex.load(path);
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
     * Get the version of the LlamaMobileVD SDK
     * @param params Parameters for getting the version
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getVersion(ReadableMap params, Promise promise) {
        try {
            String version = LlamaMobileVD.getVersion();
            WritableMap result = new WritableNativeMap();
            result.putString("version", version);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get the major version component
     * @param params Parameters for getting the major version
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getVersionMajor(ReadableMap params, Promise promise) {
        try {
            int major = LlamaMobileVD.getVersionMajor();
            WritableMap result = new WritableNativeMap();
            result.putInt("major", major);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get the minor version component
     * @param params Parameters for getting the minor version
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getVersionMinor(ReadableMap params, Promise promise) {
        try {
            int minor = LlamaMobileVD.getVersionMinor();
            WritableMap result = new WritableNativeMap();
            result.putInt("minor", minor);
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("ERROR", e.getMessage());
        }
    }

    /**
     * Get the patch version component
     * @param params Parameters for getting the patch version
     * @param promise Completion handler for successful retrieval
     */
    @ReactMethod
    public void getVersionPatch(ReadableMap params, Promise promise) {
        try {
            int patch = LlamaMobileVD.getVersionPatch();
            WritableMap result = new WritableNativeMap();
            result.putInt("patch", patch);
            promise.resolve(result);
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