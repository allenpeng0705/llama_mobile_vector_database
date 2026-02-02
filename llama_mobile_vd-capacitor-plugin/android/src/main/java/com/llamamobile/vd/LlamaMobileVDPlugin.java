package com.llamamobile.vd;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@CapacitorPlugin(name = "LlamaMobileVD")
public class LlamaMobileVDPlugin extends Plugin {

    private Map<Integer, Long> vectorStoreIds = new HashMap<>();
    private Map<Integer, Long> hnswIndexIds = new HashMap<>();
    private Map<Integer, Long> mmapBuilderIds = new HashMap<>();
    private Map<Integer, Long> mmapStoreIds = new HashMap<>();
    private int nextId = 1;

    @PluginMethod
    public void getVersion(PluginCall call) {
        String version = LlamaMobileVD.getVersion();
        JSObject result = new JSObject();
        result.put("version", version);
        call.resolve(result);
    }

    @PluginMethod
    public void getVersionMajor(PluginCall call) {
        int major = LlamaMobileVD.getVersionMajor();
        JSObject result = new JSObject();
        result.put("major", major);
        call.resolve(result);
    }

    @PluginMethod
    public void getVersionMinor(PluginCall call) {
        int minor = LlamaMobileVD.getVersionMinor();
        JSObject result = new JSObject();
        result.put("minor", minor);
        call.resolve(result);
    }

    @PluginMethod
    public void getVersionPatch(PluginCall call) {
        int patch = LlamaMobileVD.getVersionPatch();
        JSObject result = new JSObject();
        result.put("patch", patch);
        call.resolve(result);
    }

    @PluginMethod
    public void createVectorStore(PluginCall call) {
        int dimension = call.getInt("dimension", -1);
        if (dimension < 0) {
            call.reject("Missing or invalid dimension parameter");
            return;
        }

        String metricStr = call.getString("metric", "cosine");
        int metric;
        switch (metricStr) {
            case "l2":
                metric = 0;
                break;
            case "cosine":
                metric = 1;
                break;
            case "dot":
                metric = 2;
                break;
            default:
                call.reject("Invalid metric: " + metricStr);
                return;
        }

        try {
            long storeId = LlamaMobileVD.nativeVectorStoreCreate(dimension, metric);
            int id = nextId++;
            vectorStoreIds.put(id, storeId);
            JSObject result = new JSObject();
            result.put("storeId", id);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to create vector store: " + e.getMessage());
        }
    }

    @PluginMethod
    public void destroyVectorStore(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || !vectorStoreIds.containsKey(id)) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        try {
            long storeId = vectorStoreIds.get(id);
            LlamaMobileVD.nativeVectorStoreDestroy(storeId);
            vectorStoreIds.remove(id);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to destroy vector store: " + e.getMessage());
        }
    }

    @PluginMethod
    public void addVectors(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        JSArray vectorsArray = call.getArray("vectors");
        if (vectorsArray == null || vectorsArray.length() == 0) {
            call.reject("Missing or invalid vectors parameter");
            return;
        }

        try {
            if (mmapStoreIds.containsKey(id)) {
                call.reject("Cannot add vectors to MMap vector store - it's read-only");
                return;
            }

            long storeId = vectorStoreIds.get(id);
            JSArray idsArray = call.getArray("ids");
            
            for (int i = 0; i < vectorsArray.length(); i++) {
                JSONArray vectorArray = vectorsArray.getJSONArray(i);
                float[] vector = new float[vectorArray.length()];
                for (int j = 0; j < vectorArray.length(); j++) {
                    vector[j] = (float) vectorArray.getDouble(j);
                }
                
                long vectorId;
                if (idsArray != null && i < idsArray.length()) {
                    vectorId = idsArray.getLong(i);
                } else {
                    vectorId = i;
                }
                
                LlamaMobileVD.nativeVectorStoreAddVector(storeId, vectorId, vector);
            }
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to add vectors: " + e.getMessage());
        }
    }

    @PluginMethod
    public void getVector(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        long vectorId = call.getLong("id", -1L);
        if (vectorId < 0) {
            call.reject("Missing or invalid id parameter");
            return;
        }

        try {
            long storeId;
            float[] vector;
            if (vectorStoreIds.containsKey(id)) {
                storeId = vectorStoreIds.get(id);
                vector = LlamaMobileVD.nativeVectorStoreGetVector(storeId, vectorId);
            } else {
                storeId = mmapStoreIds.get(id);
                vector = LlamaMobileVD.nativeMMapVectorStoreGetVector(storeId, vectorId);
            }
            JSObject result = new JSObject();
            JSArray vectorArray = new JSArray();
            for (float value : vector) {
                vectorArray.put(value);
            }
            result.put("vector", vectorArray);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to get vector: " + e.getMessage());
        }
    }

    @PluginMethod
    public void search(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        JSArray queryVectorArray = call.getArray("queryVector");
        if (queryVectorArray == null || queryVectorArray.length() == 0) {
            call.reject("Missing or invalid queryVector parameter");
            return;
        }

        int k = call.getInt("k", -1);
        if (k < 0) {
            call.reject("Missing or invalid k parameter");
            return;
        }

        try {
            long storeId;
            long count;
            if (vectorStoreIds.containsKey(id)) {
                storeId = vectorStoreIds.get(id);
                count = LlamaMobileVD.nativeVectorStoreGetSize(storeId);
            } else {
                storeId = mmapStoreIds.get(id);
                count = LlamaMobileVD.nativeMMapVectorStoreGetSize(storeId);
            }
            
            if (count == 0) {
                call.reject("Cannot search an empty vector store");
                return;
            }
            
            // Process the queryVector array correctly
            float[] queryVector;
            try {
                // Check if the first element is a Number (flat array) or JSONArray (nested array)
                if (queryVectorArray.length() > 0) {
                    Object firstElement = queryVectorArray.get(0);
                    System.out.println("DEBUG: First element type: " + (firstElement != null ? firstElement.getClass().getName() : "null"));
                    
                    if (firstElement instanceof Number) {
                        // Handle flat array: [0.1, 0.2, 0.3]
                        queryVector = new float[queryVectorArray.length()];
                        for (int i = 0; i < queryVectorArray.length(); i++) {
                            Object value = queryVectorArray.get(i);
                            if (value instanceof Number) {
                                queryVector[i] = ((Number) value).floatValue();
                                System.out.println("DEBUG: Flat array element " + i + ": " + queryVector[i]);
                            } else {
                                call.reject("Invalid value in queryVector at index " + i + ": " + value);
                                return;
                            }
                        }
                    } else if (firstElement instanceof JSONArray) {
                        // Handle nested array: [[0.1, 0.2, 0.3]]
                        JSONArray innerArray = (JSONArray) firstElement;
                        queryVector = new float[innerArray.length()];
                        for (int j = 0; j < innerArray.length(); j++) {
                            queryVector[j] = (float) innerArray.getDouble(j);
                            System.out.println("DEBUG: Nested array element " + j + ": " + queryVector[j]);
                        }
                    } else {
                        call.reject("Invalid queryVector format: expected array of numbers");
                        return;
                    }
                } else {
                    call.reject("Empty queryVector array");
                    return;
                }
            } catch (Exception e) {
                System.out.println("ERROR: Failed to process queryVector: " + e.getMessage());
                e.printStackTrace();
                call.reject("Failed to process queryVector: " + e.getMessage());
                return;
            }

            // Debug: Log the processed query vector
            System.out.print("DEBUG: Processed query vector: [");
            for (int i = 0; i < queryVector.length; i++) {
                System.out.print(queryVector[i]);
                if (i < queryVector.length - 1) System.out.print(", ");
            }
            System.out.println("]");

            LlamaMobileVD.SearchResult[] results;
            if (vectorStoreIds.containsKey(id)) {
                System.out.println("DEBUG: Calling nativeVectorStoreSearch with storeId: " + storeId + ", k: " + k + ", queryVector length: " + queryVector.length);
                try {
                    results = LlamaMobileVD.nativeVectorStoreSearch(storeId, queryVector, k);
                    System.out.println("DEBUG: nativeVectorStoreSearch completed successfully");
                } catch (Exception e) {
                    System.out.println("ERROR: nativeVectorStoreSearch failed: " + e.getMessage());
                    e.printStackTrace();
                    call.reject("Native search failed: " + e.getMessage());
                    return;
                }
            } else {
                System.out.println("DEBUG: Calling nativeMMapVectorStoreSearch with storeId: " + storeId + ", k: " + k + ", queryVector length: " + queryVector.length);
                try {
                    results = LlamaMobileVD.nativeMMapVectorStoreSearch(storeId, queryVector, k);
                    System.out.println("DEBUG: nativeMMapVectorStoreSearch completed successfully");
                } catch (Exception e) {
                    System.out.println("ERROR: nativeMMapVectorStoreSearch failed: " + e.getMessage());
                    e.printStackTrace();
                    call.reject("Native MMap search failed: " + e.getMessage());
                    return;
                }
            }

            // Debug: Log the search results
            System.out.println("DEBUG: Search results:");
            for (int i = 0; i < results.length; i++) {
                System.out.println("DEBUG:  " + i + ". id: " + results[i].getId() + ", distance: " + results[i].getDistance());
            }

            JSObject result = new JSObject();
            JSArray idsArray = new JSArray();
            JSArray distancesArray = new JSArray();
            
            for (int i = 0; i < results.length; i++) {
                idsArray.put(results[i].getId());
                distancesArray.put(results[i].getDistance());
            }
            
            result.put("ids", idsArray);
            result.put("distances", distancesArray);
            System.out.println("DEBUG: Resolving search call with result: " + result.toString());
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to search: " + e.getMessage());
        }
    }

    @PluginMethod
    public void removeVectors(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        JSArray idsArray = call.getArray("ids");
        if (idsArray == null || idsArray.length() == 0) {
            call.reject("Missing or invalid ids parameter");
            return;
        }

        try {
            if (mmapStoreIds.containsKey(id)) {
                call.reject("Cannot remove vectors from MMap vector store - it's read-only");
                return;
            }

            long storeId = vectorStoreIds.get(id);
            for (int i = 0; i < idsArray.length(); i++) {
                long vectorId = idsArray.getLong(i);
                LlamaMobileVD.nativeVectorStoreRemoveVector(storeId, vectorId);
            }
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to remove vectors: " + e.getMessage());
        }
    }

    @PluginMethod
    public void getVectorCount(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        try {
            long storeId;
            long count;
            if (vectorStoreIds.containsKey(id)) {
                storeId = vectorStoreIds.get(id);
                count = LlamaMobileVD.nativeVectorStoreGetSize(storeId);
            } else {
                storeId = mmapStoreIds.get(id);
                count = LlamaMobileVD.nativeMMapVectorStoreGetSize(storeId);
            }
            JSObject result = new JSObject();
            result.put("count", count);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to get vector count: " + e.getMessage());
        }
    }

    @PluginMethod
    public void clearVectors(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        try {
            if (mmapStoreIds.containsKey(id)) {
                call.reject("Cannot clear vectors from MMap vector store - it's read-only");
                return;
            }

            long storeId = vectorStoreIds.get(id);
            LlamaMobileVD.nativeVectorStoreClear(storeId);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to clear vectors: " + e.getMessage());
        }
    }

    @PluginMethod
    public void createHNSWIndex(PluginCall call) {
        int dimension = call.getInt("dimension", -1);
        if (dimension < 0) {
            call.reject("Missing or invalid dimension parameter");
            return;
        }

        String metricStr = call.getString("metric", "cosine");
        int metric;
        switch (metricStr) {
            case "l2":
                metric = 0;
                break;
            case "cosine":
                metric = 1;
                break;
            case "dot":
                metric = 2;
                break;
            default:
                call.reject("Invalid metric: " + metricStr);
                return;
        }

        int maxElements = call.getInt("maxElements", -1);
        if (maxElements < 0) {
            call.reject("Missing or invalid maxElements parameter");
            return;
        }

        int m = call.getInt("m", -1);
        if (m < 0) {
            call.reject("Missing or invalid m parameter");
            return;
        }

        int efConstruction = call.getInt("efConstruction", -1);
        if (efConstruction < 0) {
            call.reject("Missing or invalid efConstruction parameter");
            return;
        }

        try {
            long indexId = LlamaMobileVD.nativeHNSWIndexCreateWithParams(dimension, metric, (long) maxElements, m, efConstruction, 42);
            if (indexId == 0) {
                call.reject("Failed to create HNSW index: Invalid parameters");
                return;
            }
            int newId = nextId++;
            hnswIndexIds.put(newId, indexId);
            JSObject result = new JSObject();
            result.put("indexId", newId);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to create HNSW index: " + e.getMessage());
        }
    }

    @PluginMethod
    public void destroyHNSWIndex(PluginCall call) {
        int id = call.getInt("indexId", -1);
        if (id < 0 || !hnswIndexIds.containsKey(id)) {
            call.reject("Missing or invalid indexId parameter");
            return;
        }

        try {
            long indexId = hnswIndexIds.get(id);
            LlamaMobileVD.nativeHNSWIndexDestroy(indexId);
            hnswIndexIds.remove(id);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to destroy HNSW index: " + e.getMessage());
        }
    }

    @PluginMethod
    public void destroyMMapVectorStore(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || !mmapStoreIds.containsKey(id)) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        try {
            long storeId = mmapStoreIds.get(id);
            LlamaMobileVD.nativeMMapVectorStoreClose(storeId);
            mmapStoreIds.remove(id);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to destroy MMap vector store: " + e.getMessage());
        }
    }

    @PluginMethod
    public void searchHNSW(PluginCall call) {
        int id = call.getInt("indexId", -1);
        if (id < 0 || !hnswIndexIds.containsKey(id)) {
            call.reject("Missing or invalid indexId parameter");
            return;
        }

        JSArray queryVectorArray = call.getArray("queryVector");
        if (queryVectorArray == null || queryVectorArray.length() == 0) {
            call.reject("Missing or invalid queryVector parameter");
            return;
        }

        int k = call.getInt("k", -1);
        if (k < 0) {
            call.reject("Missing or invalid k parameter");
            return;
        }

        Integer efSearch = call.getInt("efSearch");

        try {
            long indexId = hnswIndexIds.get(id);
            
            long count = LlamaMobileVD.nativeHNSWIndexGetSize(indexId);
            if (count == 0) {
                call.reject("Cannot search an empty HNSW index");
                return;
            }
            
            // Set efSearch if provided
            if (efSearch != null) {
                LlamaMobileVD.nativeHNSWIndexSetEfSearch(indexId, efSearch);
            }
            
            // Process the queryVector array correctly
            float[] queryVector;
            try {
                // Check if the first element is a Number (flat array) or JSONArray (nested array)
                if (queryVectorArray.length() > 0) {
                    Object firstElement = queryVectorArray.get(0);
                    System.out.println("DEBUG: HNSW First element type: " + (firstElement != null ? firstElement.getClass().getName() : "null"));
                    
                    if (firstElement instanceof Number) {
                        // Handle flat array: [0.1, 0.2, 0.3]
                        queryVector = new float[queryVectorArray.length()];
                        for (int i = 0; i < queryVectorArray.length(); i++) {
                            Object value = queryVectorArray.get(i);
                            if (value instanceof Number) {
                                queryVector[i] = ((Number) value).floatValue();
                                System.out.println("DEBUG: HNSW Flat array element " + i + ": " + queryVector[i]);
                            } else {
                                call.reject("Invalid value in queryVector at index " + i + ": " + value);
                                return;
                            }
                        }
                    } else if (firstElement instanceof JSONArray) {
                        // Handle nested array: [[0.1, 0.2, 0.3]]
                        JSONArray innerArray = (JSONArray) firstElement;
                        queryVector = new float[innerArray.length()];
                        for (int j = 0; j < innerArray.length(); j++) {
                            queryVector[j] = (float) innerArray.getDouble(j);
                            System.out.println("DEBUG: HNSW Nested array element " + j + ": " + queryVector[j]);
                        }
                    } else {
                        call.reject("Invalid queryVector format: expected array of numbers");
                        return;
                    }
                } else {
                    call.reject("Empty queryVector array");
                    return;
                }
            } catch (Exception e) {
                System.out.println("ERROR: HNSW Failed to process queryVector: " + e.getMessage());
                e.printStackTrace();
                call.reject("Failed to process queryVector: " + e.getMessage());
                return;
            }

            // Debug: Log the processed query vector
            System.out.print("DEBUG: HNSW Processed query vector: [");
            for (int i = 0; i < queryVector.length; i++) {
                System.out.print(queryVector[i]);
                if (i < queryVector.length - 1) System.out.print(", ");
            }
            System.out.println("]");

            // Call the native search method
            LlamaMobileVD.SearchResult[] results = LlamaMobileVD.nativeHNSWIndexSearch(indexId, queryVector, k);

            // Debug: Log the search results
            System.out.println("DEBUG: HNSW Search results:");
            for (int i = 0; i < results.length; i++) {
                System.out.println("DEBUG: HNSW  " + i + ". id: " + results[i].getId() + ", distance: " + results[i].getDistance());
            }

            JSObject result = new JSObject();
            JSArray idsArray = new JSArray();
            JSArray distancesArray = new JSArray();
            
            for (int i = 0; i < results.length; i++) {
                idsArray.put(results[i].getId());
                distancesArray.put(results[i].getDistance());
            }
            
            result.put("ids", idsArray);
            result.put("distances", distancesArray);
            System.out.println("DEBUG: HNSW Resolving search call with result: " + result.toString());
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to search HNSW: " + e.getMessage());
        }
    }

    @PluginMethod
    public void addVectorsToHNSW(PluginCall call) {
        int id = call.getInt("indexId", -1);
        if (id < 0 || !hnswIndexIds.containsKey(id)) {
            call.reject("Missing or invalid indexId parameter");
            return;
        }

        JSArray vectorsArray = call.getArray("vectors");
        if (vectorsArray == null || vectorsArray.length() == 0) {
            call.reject("Missing or invalid vectors parameter");
            return;
        }

        try {
            long indexId = hnswIndexIds.get(id);
            JSArray idsArray = call.getArray("ids");
            
            for (int i = 0; i < vectorsArray.length(); i++) {
                JSONArray vectorArray = vectorsArray.getJSONArray(i);
                float[] vector = new float[vectorArray.length()];
                for (int j = 0; j < vectorArray.length(); j++) {
                    vector[j] = (float) vectorArray.getDouble(j);
                }
                
                long vectorId;
                if (idsArray != null && i < idsArray.length()) {
                    vectorId = idsArray.getLong(i);
                } else {
                    vectorId = i;
                }
                
                LlamaMobileVD.nativeHNSWIndexAddVector(indexId, vectorId, vector);
            }
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to add vectors to HNSW: " + e.getMessage());
        }
    }

    @PluginMethod
    public void createMMapVectorStoreBuilder(PluginCall call) {
        System.out.println("DEBUG: createMMapVectorStoreBuilder called");
        int dimension = call.getInt("dimension", -1);
        if (dimension < 0) {
            System.out.println("ERROR: Missing or invalid dimension parameter");
            call.reject("Missing or invalid dimension parameter");
            return;
        }

        String metricStr = call.getString("metric", "cosine");
        int metric;
        switch (metricStr) {
            case "l2":
                metric = 0;
                break;
            case "cosine":
                metric = 1;
                break;
            case "dot":
                metric = 2;
                break;
            default:
                System.out.println("ERROR: Invalid metric: " + metricStr);
                call.reject("Invalid metric: " + metricStr);
                return;
        }

        try {
            System.out.println("DEBUG: Calling nativeMMapVectorStoreBuilderCreate with dimension: " + dimension + ", metric: " + metric);
            long builderId = LlamaMobileVD.nativeMMapVectorStoreBuilderCreate(dimension, metric);
            System.out.println("DEBUG: nativeMMapVectorStoreBuilderCreate returned: " + builderId);
            if (builderId == 0) {
                System.out.println("ERROR: Failed to create MMap vector store builder: Invalid builderId");
                call.reject("Failed to create MMap vector store builder: Invalid builderId");
                return;
            }
            int id = nextId++;
            mmapBuilderIds.put(id, builderId);
            System.out.println("DEBUG: Created MMap vector store builder with id: " + id + ", native id: " + builderId);
            JSObject result = new JSObject();
            result.put("builderId", id);
            call.resolve(result);
        } catch (Exception e) {
            System.out.println("ERROR: Failed to create MMap vector store builder: " + e.getMessage());
            e.printStackTrace();
            call.reject("Failed to create MMap vector store builder: " + e.getMessage());
        }
    }

    @PluginMethod
    public void destroyMMapVectorStoreBuilder(PluginCall call) {
        int id = call.getInt("builderId", -1);
        if (id < 0 || !mmapBuilderIds.containsKey(id)) {
            call.reject("Missing or invalid builderId parameter");
            return;
        }

        try {
            long builderId = mmapBuilderIds.get(id);
            LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderId);
            mmapBuilderIds.remove(id);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to destroy MMap vector store builder: " + e.getMessage());
        }
    }

    @PluginMethod
    public void addVectorsToMMapBuilder(PluginCall call) {
        int id = call.getInt("builderId", -1);
        if (id < 0 || !mmapBuilderIds.containsKey(id)) {
            call.reject("Missing or invalid builderId parameter");
            return;
        }

        JSArray vectorsArray = call.getArray("vectors");
        if (vectorsArray == null || vectorsArray.length() == 0) {
            call.reject("Missing or invalid vectors parameter");
            return;
        }

        try {
            long builderId = mmapBuilderIds.get(id);
            JSArray idsArray = call.getArray("ids");
            
            for (int i = 0; i < vectorsArray.length(); i++) {
                JSONArray vectorArray = vectorsArray.getJSONArray(i);
                float[] vector = new float[vectorArray.length()];
                for (int j = 0; j < vectorArray.length(); j++) {
                    vector[j] = (float) vectorArray.getDouble(j);
                }
                
                long vectorId;
                if (idsArray != null && i < idsArray.length()) {
                    vectorId = idsArray.getLong(i);
                } else {
                    vectorId = i;
                }
                
                LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, vectorId, vector);
            }
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to add vectors to MMap builder: " + e.getMessage());
        }
    }

    @PluginMethod
    public void buildMMapVectorStore(PluginCall call) {
        int id = call.getInt("builderId", -1);
        if (id < 0 || !mmapBuilderIds.containsKey(id)) {
            call.reject("Missing or invalid builderId parameter");
            return;
        }

        String path = call.getString("path");
        if (path == null || path.isEmpty()) {
            call.reject("Missing or invalid path parameter");
            return;
        }

        try {
            long builderId = mmapBuilderIds.get(id);
            LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderId, path);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to build MMap vector store: " + e.getMessage());
        }
    }

    @PluginMethod
    public void openMMapVectorStore(PluginCall call) {
        String path = call.getString("path");
        if (path == null || path.isEmpty()) {
            call.reject("Missing or invalid path parameter");
            return;
        }

        try {
            long storeId = LlamaMobileVD.nativeMMapVectorStoreOpen(path);
            if (storeId == 0) {
                call.reject("Failed to open MMap vector store: Invalid path or store");
                return;
            }
            int id = nextId++;
            mmapStoreIds.put(id, storeId);
            JSObject result = new JSObject();
            result.put("storeId", id);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to open MMap vector store: " + e.getMessage());
        }
    }

    @PluginMethod
    public void closeMMapVectorStore(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || !mmapStoreIds.containsKey(id)) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        try {
            long storeId = mmapStoreIds.get(id);
            LlamaMobileVD.nativeMMapVectorStoreClose(storeId);
            mmapStoreIds.remove(id);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to close MMap vector store: " + e.getMessage());
        }
    }

    // MARK: - VectorStore async methods
    @PluginMethod
    public void createVectorStoreAsync(PluginCall call) {
        int dimension = call.getInt("dimension", -1);
        if (dimension < 0) {
            call.reject("Missing or invalid dimension parameter");
            return;
        }

        String metricStr = call.getString("metric", "cosine");
        int metric;
        switch (metricStr) {
            case "l2":
                metric = 0;
                break;
            case "cosine":
                metric = 1;
                break;
            case "dot":
                metric = 2;
                break;
            default:
                call.reject("Invalid metric: " + metricStr);
                return;
        }

        new Thread(() -> {
            try {
                long storeId = LlamaMobileVD.nativeVectorStoreCreate(dimension, metric);
                int id = nextId++;
                vectorStoreIds.put(id, storeId);
                JSObject result = new JSObject();
                result.put("storeId", id);
                call.resolve(result);
            } catch (Exception e) {
                call.reject("Failed to create vector store: " + e.getMessage());
            }
        }).start();
    }

    @PluginMethod
    public void addVectorsAsync(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        JSArray vectorsArray = call.getArray("vectors");
        if (vectorsArray == null || vectorsArray.length() == 0) {
            call.reject("Missing or invalid vectors parameter");
            return;
        }

        new Thread(() -> {
            try {
                if (mmapStoreIds.containsKey(id)) {
                    call.reject("Cannot add vectors to MMap vector store - it's read-only");
                    return;
                }

                long storeId = vectorStoreIds.get(id);
                JSArray idsArray = call.getArray("ids");
                
                for (int i = 0; i < vectorsArray.length(); i++) {
                    JSONArray vectorArray = vectorsArray.getJSONArray(i);
                    float[] vector = new float[vectorArray.length()];
                    for (int j = 0; j < vectorArray.length(); j++) {
                        vector[j] = (float) vectorArray.getDouble(j);
                    }
                    
                    long vectorId;
                    if (idsArray != null && i < idsArray.length()) {
                        vectorId = idsArray.getLong(i);
                    } else {
                        vectorId = i;
                    }
                    
                    LlamaMobileVD.nativeVectorStoreAddVector(storeId, vectorId, vector);
                }
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to add vectors: " + e.getMessage());
            }
        }).start();
    }

    @PluginMethod
    public void searchAsync(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        JSArray queryVectorArray = call.getArray("queryVector");
        if (queryVectorArray == null || queryVectorArray.length() == 0) {
            call.reject("Missing or invalid queryVector parameter");
            return;
        }

        int k = call.getInt("k", -1);
        if (k < 0) {
            call.reject("Missing or invalid k parameter");
            return;
        }

        new Thread(() -> {
            try {
                long storeId;
                long count;
                if (vectorStoreIds.containsKey(id)) {
                    storeId = vectorStoreIds.get(id);
                    count = LlamaMobileVD.nativeVectorStoreGetSize(storeId);
                } else {
                    storeId = mmapStoreIds.get(id);
                    count = LlamaMobileVD.nativeMMapVectorStoreGetSize(storeId);
                }
                
                if (count == 0) {
                    call.reject("Cannot search an empty vector store");
                    return;
                }
                
                float[] queryVector;
                try {
                    if (queryVectorArray.length() > 0) {
                        Object firstElement = queryVectorArray.get(0);
                        
                        if (firstElement instanceof Number) {
                            queryVector = new float[queryVectorArray.length()];
                            for (int i = 0; i < queryVectorArray.length(); i++) {
                                Object value = queryVectorArray.get(i);
                                if (value instanceof Number) {
                                    queryVector[i] = ((Number) value).floatValue();
                                } else {
                                    call.reject("Invalid value in queryVector at index " + i + ": " + value);
                                    return;
                                }
                            }
                        } else if (firstElement instanceof JSONArray) {
                            JSONArray innerArray = (JSONArray) firstElement;
                            queryVector = new float[innerArray.length()];
                            for (int j = 0; j < innerArray.length(); j++) {
                                queryVector[j] = (float) innerArray.getDouble(j);
                            }
                        } else {
                            call.reject("Invalid queryVector format: expected array of numbers");
                            return;
                        }
                    } else {
                        call.reject("Empty queryVector array");
                        return;
                    }
                } catch (Exception e) {
                    call.reject("Failed to process queryVector: " + e.getMessage());
                    return;
                }

                LlamaMobileVD.SearchResult[] results;
                if (vectorStoreIds.containsKey(id)) {
                    results = LlamaMobileVD.nativeVectorStoreSearch(storeId, queryVector, k);
                } else {
                    results = LlamaMobileVD.nativeMMapVectorStoreSearch(storeId, queryVector, k);
                }

                JSObject result = new JSObject();
                JSArray idsArray = new JSArray();
                JSArray distancesArray = new JSArray();
                
                for (int i = 0; i < results.length; i++) {
                    idsArray.put(results[i].getId());
                    distancesArray.put(results[i].getDistance());
                }
                
                result.put("ids", idsArray);
                result.put("distances", distancesArray);
                call.resolve(result);
            } catch (Exception e) {
                call.reject("Failed to search: " + e.getMessage());
            }
        }).start();
    }

    @PluginMethod
    public void removeVectorsAsync(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        JSArray idsArray = call.getArray("ids");
        if (idsArray == null || idsArray.length() == 0) {
            call.reject("Missing or invalid ids parameter");
            return;
        }

        new Thread(() -> {
            try {
                if (mmapStoreIds.containsKey(id)) {
                    call.reject("Cannot remove vectors from MMap vector store - it's read-only");
                    return;
                }

                long storeId = vectorStoreIds.get(id);
                for (int i = 0; i < idsArray.length(); i++) {
                    long vectorId = idsArray.getLong(i);
                    LlamaMobileVD.nativeVectorStoreRemoveVector(storeId, vectorId);
                }
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to remove vectors: " + e.getMessage());
            }
        }).start();
    }

    @PluginMethod
    public void clearVectorsAsync(PluginCall call) {
        int id = call.getInt("storeId", -1);
        if (id < 0 || (!vectorStoreIds.containsKey(id) && !mmapStoreIds.containsKey(id))) {
            call.reject("Missing or invalid storeId parameter");
            return;
        }

        new Thread(() -> {
            try {
                if (mmapStoreIds.containsKey(id)) {
                    call.reject("Cannot clear vectors from MMap vector store - it's read-only");
                    return;
                }

                long storeId = vectorStoreIds.get(id);
                LlamaMobileVD.nativeVectorStoreClear(storeId);
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to clear vectors: " + e.getMessage());
            }
        }).start();
    }

    // MARK: - HNSWIndex async methods
    @PluginMethod
    public void createHNSWIndexAsync(PluginCall call) {
        int dimension = call.getInt("dimension", -1);
        if (dimension < 0) {
            call.reject("Missing or invalid dimension parameter");
            return;
        }

        String metricStr = call.getString("metric", "cosine");
        int metric;
        switch (metricStr) {
            case "l2":
                metric = 0;
                break;
            case "cosine":
                metric = 1;
                break;
            case "dot":
                metric = 2;
                break;
            default:
                call.reject("Invalid metric: " + metricStr);
                return;
        }

        int maxElements = call.getInt("maxElements", -1);
        if (maxElements < 0) {
            call.reject("Missing or invalid maxElements parameter");
            return;
        }

        int m = call.getInt("m", -1);
        if (m < 0) {
            call.reject("Missing or invalid m parameter");
            return;
        }

        int efConstruction = call.getInt("efConstruction", -1);
        if (efConstruction < 0) {
            call.reject("Missing or invalid efConstruction parameter");
            return;
        }

        new Thread(() -> {
            try {
                long indexId = LlamaMobileVD.nativeHNSWIndexCreateWithParams(dimension, metric, (long) maxElements, m, efConstruction, 42);
                if (indexId == 0) {
                    call.reject("Failed to create HNSW index: Invalid parameters");
                    return;
                }
                int newId = nextId++;
                hnswIndexIds.put(newId, indexId);
                JSObject result = new JSObject();
                result.put("indexId", newId);
                call.resolve(result);
            } catch (Exception e) {
                call.reject("Failed to create HNSW index: " + e.getMessage());
            }
        }).start();
    }

    @PluginMethod
    public void searchHNSWAsync(PluginCall call) {
        int id = call.getInt("indexId", -1);
        if (id < 0 || !hnswIndexIds.containsKey(id)) {
            call.reject("Missing or invalid indexId parameter");
            return;
        }

        JSArray queryVectorArray = call.getArray("queryVector");
        if (queryVectorArray == null || queryVectorArray.length() == 0) {
            call.reject("Missing or invalid queryVector parameter");
            return;
        }

        int k = call.getInt("k", -1);
        if (k < 0) {
            call.reject("Missing or invalid k parameter");
            return;
        }

        Integer efSearch = call.getInt("efSearch");

        new Thread(() -> {
            try {
                long indexId = hnswIndexIds.get(id);
                
                long count = LlamaMobileVD.nativeHNSWIndexGetSize(indexId);
                if (count == 0) {
                    call.reject("Cannot search an empty HNSW index");
                    return;
                }
                
                if (efSearch != null) {
                    LlamaMobileVD.nativeHNSWIndexSetEfSearch(indexId, efSearch);
                }
                
                float[] queryVector;
                try {
                    if (queryVectorArray.length() > 0) {
                        Object firstElement = queryVectorArray.get(0);
                        
                        if (firstElement instanceof Number) {
                            queryVector = new float[queryVectorArray.length()];
                            for (int i = 0; i < queryVectorArray.length(); i++) {
                                Object value = queryVectorArray.get(i);
                                if (value instanceof Number) {
                                    queryVector[i] = ((Number) value).floatValue();
                                } else {
                                    call.reject("Invalid value in queryVector at index " + i + ": " + value);
                                    return;
                                }
                            }
                        } else if (firstElement instanceof JSONArray) {
                            JSONArray innerArray = (JSONArray) firstElement;
                            queryVector = new float[innerArray.length()];
                            for (int j = 0; j < innerArray.length(); j++) {
                                queryVector[j] = (float) innerArray.getDouble(j);
                            }
                        } else {
                            call.reject("Invalid queryVector format: expected array of numbers");
                            return;
                        }
                    } else {
                        call.reject("Empty queryVector array");
                        return;
                    }
                } catch (Exception e) {
                    call.reject("Failed to process queryVector: " + e.getMessage());
                    return;
                }

                LlamaMobileVD.SearchResult[] results = LlamaMobileVD.nativeHNSWIndexSearch(indexId, queryVector, k);

                JSObject result = new JSObject();
                JSArray idsArray = new JSArray();
                JSArray distancesArray = new JSArray();
                
                for (int i = 0; i < results.length; i++) {
                    idsArray.put(results[i].getId());
                    distancesArray.put(results[i].getDistance());
                }
                
                result.put("ids", idsArray);
                result.put("distances", distancesArray);
                call.resolve(result);
            } catch (Exception e) {
                call.reject("Failed to search HNSW index: " + e.getMessage());
            }
        }).start();
    }

    @PluginMethod
    public void addVectorsToHNSWAsync(PluginCall call) {
        int id = call.getInt("indexId", -1);
        if (id < 0 || !hnswIndexIds.containsKey(id)) {
            call.reject("Missing or invalid indexId parameter");
            return;
        }

        JSArray vectorsArray = call.getArray("vectors");
        if (vectorsArray == null || vectorsArray.length() == 0) {
            call.reject("Missing or invalid vectors parameter");
            return;
        }

        new Thread(() -> {
            try {
                long indexId = hnswIndexIds.get(id);
                JSArray idsArray = call.getArray("ids");
                
                for (int i = 0; i < vectorsArray.length(); i++) {
                    JSONArray vectorArray = vectorsArray.getJSONArray(i);
                    float[] vector = new float[vectorArray.length()];
                    for (int j = 0; j < vectorArray.length(); j++) {
                        vector[j] = (float) vectorArray.getDouble(j);
                    }
                    
                    long vectorId;
                    if (idsArray != null && i < idsArray.length()) {
                        vectorId = idsArray.getLong(i);
                    } else {
                        vectorId = i;
                    }
                    
                    LlamaMobileVD.nativeHNSWIndexAddVector(indexId, vectorId, vector);
                }
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to add vectors to HNSW index: " + e.getMessage());
            }
        }).start();
    }

    // MARK: - MMapVectorStoreBuilder async methods
    @PluginMethod
    public void createMMapVectorStoreBuilderAsync(PluginCall call) {
        int dimension = call.getInt("dimension", -1);
        if (dimension < 0) {
            call.reject("Missing or invalid dimension parameter");
            return;
        }

        String metricStr = call.getString("metric", "cosine");
        int metric;
        switch (metricStr) {
            case "l2":
                metric = 0;
                break;
            case "cosine":
                metric = 1;
                break;
            case "dot":
                metric = 2;
                break;
            default:
                call.reject("Invalid metric: " + metricStr);
                return;
        }

        new Thread(() -> {
            try {
                long builderId = LlamaMobileVD.nativeMMapVectorStoreBuilderCreate(dimension, metric);
                int id = nextId++;
                mmapBuilderIds.put(id, builderId);
                JSObject result = new JSObject();
                result.put("builderId", id);
                call.resolve(result);
            } catch (Exception e) {
                call.reject("Failed to create MMap vector store builder: " + e.getMessage());
            }
        }).start();
    }

    @PluginMethod
    public void addVectorsToMMapBuilderAsync(PluginCall call) {
        int id = call.getInt("builderId", -1);
        if (id < 0 || !mmapBuilderIds.containsKey(id)) {
            call.reject("Missing or invalid builderId parameter");
            return;
        }

        JSArray vectorsArray = call.getArray("vectors");
        if (vectorsArray == null || vectorsArray.length() == 0) {
            call.reject("Missing or invalid vectors parameter");
            return;
        }

        new Thread(() -> {
            try {
                long builderId = mmapBuilderIds.get(id);
                JSArray idsArray = call.getArray("ids");
                
                for (int i = 0; i < vectorsArray.length(); i++) {
                    JSONArray vectorArray = vectorsArray.getJSONArray(i);
                    float[] vector = new float[vectorArray.length()];
                    for (int j = 0; j < vectorArray.length(); j++) {
                        vector[j] = (float) vectorArray.getDouble(j);
                    }
                    
                    long vectorId;
                    if (idsArray != null && i < idsArray.length()) {
                        vectorId = idsArray.getLong(i);
                    } else {
                        vectorId = i;
                    }
                    
                    LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, vectorId, vector);
                }
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to add vectors to MMap builder: " + e.getMessage());
            }
        }).start();
    }

    @PluginMethod
    public void buildMMapVectorStoreAsync(PluginCall call) {
        int id = call.getInt("builderId", -1);
        if (id < 0 || !mmapBuilderIds.containsKey(id)) {
            call.reject("Missing or invalid builderId parameter");
            return;
        }

        String path = call.getString("path");
        if (path == null || path.isEmpty()) {
            call.reject("Missing or invalid path parameter");
            return;
        }

        new Thread(() -> {
            try {
                long builderId = mmapBuilderIds.get(id);
                LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderId, path);
                mmapBuilderIds.remove(id);
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to build MMap vector store: " + e.getMessage());
            }
        }).start();
    }

    @PluginMethod
    public void openMMapVectorStoreAsync(PluginCall call) {
        String path = call.getString("path");
        if (path == null || path.isEmpty()) {
            call.reject("Missing or invalid path parameter");
            return;
        }

        new Thread(() -> {
            try {
                long storeId = LlamaMobileVD.nativeMMapVectorStoreOpen(path);
                int id = nextId++;
                mmapStoreIds.put(id, storeId);
                JSObject result = new JSObject();
                result.put("storeId", id);
                call.resolve(result);
            } catch (Exception e) {
                call.reject("Failed to open MMap vector store: " + e.getMessage());
            }
        }).start();
    }
}
