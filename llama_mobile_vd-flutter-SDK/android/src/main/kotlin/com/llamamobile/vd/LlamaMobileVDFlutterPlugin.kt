package com.llamamobile.vd

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class LlamaMobileVDFlutterPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "llama_mobile_vd_flutter_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android {android.os.Build.VERSION.RELEASE}")
      }
      // VectorStore methods
      "vectorStoreCreate" -> handleVectorStoreCreate(call, result)
      "vectorStoreAddVector" -> handleVectorStoreAddVector(call, result)
      "vectorStoreSearch" -> handleVectorStoreSearch(call, result)
      "vectorStoreGetVector" -> handleVectorStoreGetVector(call, result)
      "vectorStoreRemoveVector" -> handleVectorStoreRemoveVector(call, result)
      "vectorStoreContains" -> handleVectorStoreContains(call, result)
      "vectorStoreGetSize" -> handleVectorStoreGetSize(call, result)
      "vectorStoreGetDimension" -> handleVectorStoreGetDimension(call, result)
      "vectorStoreGetMetric" -> handleVectorStoreGetMetric(call, result)
      "vectorStoreUpdateVector" -> handleVectorStoreUpdateVector(call, result)
      "vectorStoreReserve" -> handleVectorStoreReserve(call, result)
      "vectorStoreClear" -> handleVectorStoreClear(call, result)
      "vectorStoreDestroy" -> handleVectorStoreDestroy(call, result)
      // VectorStore async methods
      "vectorStoreCreateAsync" -> handleVectorStoreCreateAsync(call, result)
      "vectorStoreAddVectorAsync" -> handleVectorStoreAddVectorAsync(call, result)
      "vectorStoreSearchAsync" -> handleVectorStoreSearchAsync(call, result)
      "vectorStoreRemoveVectorAsync" -> handleVectorStoreRemoveVectorAsync(call, result)
      "vectorStoreUpdateVectorAsync" -> handleVectorStoreUpdateVectorAsync(call, result)
      "vectorStoreReserveAsync" -> handleVectorStoreReserveAsync(call, result)
      "vectorStoreClearAsync" -> handleVectorStoreClearAsync(call, result)
      // HNSWIndex methods
      "hnswIndexCreate" -> handleHNSWIndexCreate(call, result)
      "hnswIndexCreateWithParams" -> handleHNSWIndexCreateWithParams(call, result)
      "hnswIndexAddVector" -> handleHNSWIndexAddVector(call, result)
      "hnswIndexSearch" -> handleHNSWIndexSearch(call, result)
      "hnswIndexSetEfSearch" -> handleHNSWIndexSetEfSearch(call, result)
      "hnswIndexGetEfSearch" -> handleHNSWIndexGetEfSearch(call, result)
      "hnswIndexGetSize" -> handleHNSWIndexGetSize(call, result)
      "hnswIndexGetDimension" -> handleHNSWIndexGetDimension(call, result)
      "hnswIndexGetCapacity" -> handleHNSWIndexGetCapacity(call, result)
      "hnswIndexContains" -> handleHNSWIndexContains(call, result)
      "hnswIndexGetVector" -> handleHNSWIndexGetVector(call, result)
      "hnswIndexSave" -> handleHNSWIndexSave(call, result)
      "hnswIndexLoad" -> handleHNSWIndexLoad(call, result)
      "hnswIndexDestroy" -> handleHNSWIndexDestroy(call, result)
      // HNSWIndex async methods
      "hnswIndexCreateAsync" -> handleHNSWIndexCreateAsync(call, result)
      "hnswIndexCreateWithParamsAsync" -> handleHNSWIndexCreateWithParamsAsync(call, result)
      "hnswIndexAddVectorAsync" -> handleHNSWIndexAddVectorAsync(call, result)
      "hnswIndexSearchAsync" -> handleHNSWIndexSearchAsync(call, result)
      "hnswIndexSaveAsync" -> handleHNSWIndexSaveAsync(call, result)
      "hnswIndexLoadAsync" -> handleHNSWIndexLoadAsync(call, result)
      // MMapVectorStoreBuilder methods
      "mmapVectorStoreBuilderCreate" -> handleMMapVectorStoreBuilderCreate(call, result)
      "mmapVectorStoreBuilderAddVector" -> handleMMapVectorStoreBuilderAddVector(call, result)
      "mmapVectorStoreBuilderReserve" -> handleMMapVectorStoreBuilderReserve(call, result)
      "mmapVectorStoreBuilderSave" -> handleMMapVectorStoreBuilderSave(call, result)
      "mmapVectorStoreBuilderGetSize" -> handleMMapVectorStoreBuilderGetSize(call, result)
      "mmapVectorStoreBuilderGetDimension" -> handleMMapVectorStoreBuilderGetDimension(call, result)
      "mmapVectorStoreBuilderDestroy" -> handleMMapVectorStoreBuilderDestroy(call, result)
      // MMapVectorStoreBuilder async methods
      "mmapVectorStoreBuilderCreateAsync" -> handleMMapVectorStoreBuilderCreateAsync(call, result)
      "mmapVectorStoreBuilderAddVectorAsync" -> handleMMapVectorStoreBuilderAddVectorAsync(call, result)
      "mmapVectorStoreBuilderReserveAsync" -> handleMMapVectorStoreBuilderReserveAsync(call, result)
      "mmapVectorStoreBuilderSaveAsync" -> handleMMapVectorStoreBuilderSaveAsync(call, result)
      // MMapVectorStore methods
      "mmapVectorStoreOpen" -> handleMMapVectorStoreOpen(call, result)
      "mmapVectorStoreGetVector" -> handleMMapVectorStoreGetVector(call, result)
      "mmapVectorStoreContains" -> handleMMapVectorStoreContains(call, result)
      "mmapVectorStoreSearch" -> handleMMapVectorStoreSearch(call, result)
      "mmapVectorStoreGetSize" -> handleMMapVectorStoreGetSize(call, result)
      "mmapVectorStoreGetDimension" -> handleMMapVectorStoreGetDimension(call, result)
      "mmapVectorStoreGetMetric" -> handleMMapVectorStoreGetMetric(call, result)
      "mmapVectorStoreClose" -> handleMMapVectorStoreClose(call, result)
      // MMapVectorStore async methods
      "mmapVectorStoreOpenAsync" -> handleMMapVectorStoreOpenAsync(call, result)
      "mmapVectorStoreSearchAsync" -> handleMMapVectorStoreSearchAsync(call, result)
      // Version methods
      "getVersion" -> handleGetVersion(call, result)
      "getVersionMajor" -> handleGetVersionMajor(call, result)
      "getVersionMinor" -> handleGetVersionMinor(call, result)
      "getVersionPatch" -> handleGetVersionPatch(call, result)
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // MARK: - VectorStore methods
  private fun handleVectorStoreCreate(call: MethodCall, result: Result) {
    val dimension = call.argument<Int>("dimension") ?: run {
      result.error("INVALID_ARGUMENTS", "Dimension is required", null)
      return
    }
    val metric = call.argument<Int>("metric") ?: run {
      result.error("INVALID_ARGUMENTS", "Metric is required", null)
      return
    }

    val storeId = LlamaMobileVD.nativeVectorStoreCreate(dimension, metric)
    if (storeId == 0L) {
      result.error("CREATE_FAILED", "Failed to create vector store", null)
      return
    }

    result.success(storeId)
  }

  private fun handleVectorStoreAddVector(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }
    val vector = call.argument<List<Double>>("vector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "Vector is required", null)
      return
    }

    try {
      LlamaMobileVD.nativeVectorStoreAddVector(storeId, id, vector)
      result.success(true)
    } catch (e: Exception) {
      result.error("ADD_FAILED", "Failed to add vector: {e.message}", null)
    }
  }

  private fun handleVectorStoreSearch(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val queryVector = call.argument<List<Double>>("queryVector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "QueryVector is required", null)
      return
    }
    val k = call.argument<Int>("k") ?: run {
      result.error("INVALID_ARGUMENTS", "k is required", null)
      return
    }

    try {
      val searchResults = LlamaMobileVD.nativeVectorStoreSearch(storeId, queryVector, k)
      val flutterResults = searchResults.map { mapOf("id" to it.id, "distance" to it.distance) }
      result.success(flutterResults)
    } catch (e: Exception) {
      result.error("SEARCH_FAILED", "Search failed: {e.message}", null)
    }
  }

  private fun handleVectorStoreGetVector(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }

    try {
      val vector = LlamaMobileVD.nativeVectorStoreGetVector(storeId, id)
      if (vector == null) {
        result.success(null)
      } else {
        result.success(vector.map { it.toDouble() })
      }
    } catch (e: Exception) {
      result.error("GET_FAILED", "Failed to get vector: {e.message}", null)
    }
  }

  private fun handleVectorStoreRemoveVector(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }

    try {
      val removed = LlamaMobileVD.nativeVectorStoreRemoveVector(storeId, id)
      result.success(removed)
    } catch (e: Exception) {
      result.error("REMOVE_FAILED", "Failed to remove vector: {e.message}", null)
    }
  }

  private fun handleVectorStoreContains(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }

    try {
      val contains = LlamaMobileVD.nativeVectorStoreContains(storeId, id)
      result.success(contains)
    } catch (e: Exception) {
      result.error("CONTAINS_FAILED", "Failed to check if vector exists: {e.message}", null)
    }
  }

  private fun handleVectorStoreGetSize(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    try {
      val size = LlamaMobileVD.nativeVectorStoreGetSize(storeId)
      result.success(size)
    } catch (e: Exception) {
      result.error("SIZE_FAILED", "Failed to get size: {e.message}", null)
    }
  }

  private fun handleVectorStoreGetDimension(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    try {
      val dimension = LlamaMobileVD.nativeVectorStoreGetDimension(storeId)
      result.success(dimension)
    } catch (e: Exception) {
      result.error("DIMENSION_FAILED", "Failed to get dimension: {e.message}", null)
    }
  }

  private fun handleVectorStoreGetMetric(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    try {
      val metric = LlamaMobileVD.nativeVectorStoreGetMetric(storeId)
      result.success(metric)
    } catch (e: Exception) {
      result.error("METRIC_FAILED", "Failed to get metric: {e.message}", null)
    }
  }

  private fun handleVectorStoreUpdateVector(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }
    val vector = call.argument<List<Double>>("vector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "Vector is required", null)
      return
    }

    try {
      val updated = LlamaMobileVD.nativeVectorStoreUpdateVector(storeId, id, vector)
      result.success(updated)
    } catch (e: Exception) {
      result.error("UPDATE_FAILED", "Failed to update vector: {e.message}", null)
    }
  }

  private fun handleVectorStoreReserve(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val capacity = call.argument<Number>("capacity")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Capacity is required", null)
      return
    }

    try {
      val reserved = LlamaMobileVD.nativeVectorStoreReserve(storeId, capacity)
      result.success(reserved)
    } catch (e: Exception) {
      result.error("RESERVE_FAILED", "Failed to reserve capacity: {e.message}", null)
    }
  }

  private fun handleVectorStoreClear(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    try {
      LlamaMobileVD.nativeVectorStoreClear(storeId)
      result.success(true)
    } catch (e: Exception) {
      result.error("CLEAR_FAILED", "Failed to clear vector store: {e.message}", null)
    }
  }

  private fun handleVectorStoreDestroy(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    try {
      LlamaMobileVD.nativeVectorStoreDestroy(storeId)
      result.success(true)
    } catch (e: Exception) {
      result.error("DESTROY_FAILED", "Failed to destroy vector store: {e.message}", null)
    }
  }

  // MARK: - VectorStore async methods
  private fun handleVectorStoreCreateAsync(call: MethodCall, result: Result) {
    val dimension = call.argument<Int>("dimension") ?: run {
      result.error("INVALID_ARGUMENTS", "Dimension is required", null)
      return
    }
    val metric = call.argument<Int>("metric") ?: run {
      result.error("INVALID_ARGUMENTS", "Metric is required", null)
      return
    }

    Thread {
      try {
        val storeId = LlamaMobileVD.nativeVectorStoreCreate(dimension, metric)
        if (storeId == 0L) {
          result.error("CREATE_FAILED", "Failed to create vector store", null)
          return@Thread
        }
        result.success(storeId)
      } catch (e: Exception) {
        result.error("CREATE_FAILED", "Failed to create vector store: {e.message}", null)
      }
    }.start()
  }

  private fun handleVectorStoreAddVectorAsync(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }
    val vector = call.argument<List<Double>>("vector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "Vector is required", null)
      return
    }

    Thread {
      try {
        LlamaMobileVD.nativeVectorStoreAddVector(storeId, id, vector)
        result.success(true)
      } catch (e: Exception) {
        result.error("ADD_FAILED", "Failed to add vector: {e.message}", null)
      }
    }.start()
  }

  private fun handleVectorStoreSearchAsync(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val queryVector = call.argument<List<Double>>("queryVector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "QueryVector is required", null)
      return
    }
    val k = call.argument<Int>("k") ?: run {
      result.error("INVALID_ARGUMENTS", "k is required", null)
      return
    }

    Thread {
      try {
        val searchResults = LlamaMobileVD.nativeVectorStoreSearch(storeId, queryVector, k)
        val flutterResults = searchResults.map { mapOf("id" to it.id, "distance" to it.distance) }
        result.success(flutterResults)
      } catch (e: Exception) {
        result.error("SEARCH_FAILED", "Search failed: {e.message}", null)
      }
    }.start()
  }

  private fun handleVectorStoreRemoveVectorAsync(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }

    Thread {
      try {
        val removed = LlamaMobileVD.nativeVectorStoreRemoveVector(storeId, id)
        result.success(removed)
      } catch (e: Exception) {
        result.error("REMOVE_FAILED", "Failed to remove vector: {e.message}", null)
      }
    }.start()
  }

  private fun handleVectorStoreUpdateVectorAsync(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }
    val vector = call.argument<List<Double>>("vector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "Vector is required", null)
      return
    }

    Thread {
      try {
        val updated = LlamaMobileVD.nativeVectorStoreUpdateVector(storeId, id, vector)
        result.success(updated)
      } catch (e: Exception) {
        result.error("UPDATE_FAILED", "Failed to update vector: {e.message}", null)
      }
    }.start()
  }

  private fun handleVectorStoreReserveAsync(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val capacity = call.argument<Number>("capacity")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Capacity is required", null)
      return
    }

    Thread {
      try {
        val reserved = LlamaMobileVD.nativeVectorStoreReserve(storeId, capacity)
        result.success(reserved)
      } catch (e: Exception) {
        result.error("RESERVE_FAILED", "Failed to reserve capacity: {e.message}", null)
      }
    }.start()
  }

  private fun handleVectorStoreClearAsync(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    Thread {
      try {
        LlamaMobileVD.nativeVectorStoreClear(storeId)
        result.success(true)
      } catch (e: Exception) {
        result.error("CLEAR_FAILED", "Failed to clear vector store: {e.message}", null)
      }
    }.start()
  }

  // MARK: - HNSWIndex methods
  private fun handleHNSWIndexCreate(call: MethodCall, result: Result) {
    val dimension = call.argument<Int>("dimension") ?: run {
      result.error("INVALID_ARGUMENTS", "Dimension is required", null)
      return
    }
    val metric = call.argument<Int>("metric") ?: run {
      result.error("INVALID_ARGUMENTS", "Metric is required", null)
      return
    }
    val maxElements = call.argument<Number>("maxElements")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "MaxElements is required", null)
      return
    }

    try {
      val indexId = LlamaMobileVD.nativeHNSWIndexCreate(dimension, metric, maxElements)
      if (indexId == 0L) {
        result.error("CREATE_FAILED", "Failed to create HNSW index", null)
        return
      }
      result.success(indexId)
    } catch (e: Exception) {
      result.error("CREATE_FAILED", "Failed to create HNSW index: {e.message}", null)
    }
  }

  private fun handleHNSWIndexCreateWithParams(call: MethodCall, result: Result) {
    val dimension = call.argument<Int>("dimension") ?: run {
      result.error("INVALID_ARGUMENTS", "Dimension is required", null)
      return
    }
    val metric = call.argument<Int>("metric") ?: run {
      result.error("INVALID_ARGUMENTS", "Metric is required", null)
      return
    }
    val maxElements = call.argument<Number>("maxElements")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "MaxElements is required", null)
      return
    }
    val M = call.argument<Int>("M") ?: run {
      result.error("INVALID_ARGUMENTS", "M is required", null)
      return
    }
    val efConstruction = call.argument<Int>("efConstruction") ?: run {
      result.error("INVALID_ARGUMENTS", "EfConstruction is required", null)
      return
    }
    val seed = call.argument<Int>("seed") ?: 42

    try {
      val indexId = LlamaMobileVD.nativeHNSWIndexCreateWithParams(dimension, metric, maxElements, M, efConstruction, seed)
      if (indexId == 0L) {
        result.error("CREATE_FAILED", "Failed to create HNSW index with params", null)
        return
      }
      result.success(indexId)
    } catch (e: Exception) {
      result.error("CREATE_FAILED", "Failed to create HNSW index with params: {e.message}", null)
    }
  }

  private fun handleHNSWIndexAddVector(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }
    val vector = call.argument<List<Double>>("vector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "Vector is required", null)
      return
    }

    try {
      val added = LlamaMobileVD.nativeHNSWIndexAddVector(indexId, id, vector)
      result.success(added)
    } catch (e: Exception) {
      result.error("ADD_FAILED", "Failed to add vector to HNSW index: {e.message}", null)
    }
  }

  private fun handleHNSWIndexSearch(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }
    val queryVector = call.argument<List<Double>>("queryVector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "QueryVector is required", null)
      return
    }
    val k = call.argument<Int>("k") ?: run {
      result.error("INVALID_ARGUMENTS", "k is required", null)
      return
    }

    try {
      val searchResults = LlamaMobileVD.nativeHNSWIndexSearch(indexId, queryVector, k)
      val flutterResults = searchResults.map { mapOf("id" to it.id, "distance" to it.distance) }
      result.success(flutterResults)
    } catch (e: Exception) {
      result.error("SEARCH_FAILED", "Search failed: {e.message}", null)
    }
  }

  private fun handleHNSWIndexSetEfSearch(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }
    val efSearch = call.argument<Int>("efSearch") ?: run {
      result.error("INVALID_ARGUMENTS", "EfSearch is required", null)
      return
    }

    try {
      val set = LlamaMobileVD.nativeHNSWIndexSetEfSearch(indexId, efSearch)
      result.success(set)
    } catch (e: Exception) {
      result.error("SET_EF_SEARCH_FAILED", "Failed to set ef_search: {e.message}", null)
    }
  }

  private fun handleHNSWIndexGetEfSearch(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }

    try {
      val efSearch = LlamaMobileVD.nativeHNSWIndexGetEfSearch(indexId)
      result.success(efSearch)
    } catch (e: Exception) {
      result.error("GET_EF_SEARCH_FAILED", "Failed to get ef_search: {e.message}", null)
    }
  }

  private fun handleHNSWIndexGetSize(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }

    try {
      val size = LlamaMobileVD.nativeHNSWIndexGetSize(indexId)
      result.success(size)
    } catch (e: Exception) {
      result.error("SIZE_FAILED", "Failed to get size: {e.message}", null)
    }
  }

  private fun handleHNSWIndexGetDimension(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }

    try {
      val dimension = LlamaMobileVD.nativeHNSWIndexGetDimension(indexId)
      result.success(dimension)
    } catch (e: Exception) {
      result.error("DIMENSION_FAILED", "Failed to get dimension: {e.message}", null)
    }
  }

  private fun handleHNSWIndexGetCapacity(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }

    try {
      val capacity = LlamaMobileVD.nativeHNSWIndexGetCapacity(indexId)
      result.success(capacity)
    } catch (e: Exception) {
      result.error("CAPACITY_FAILED", "Failed to get capacity: {e.message}", null)
    }
  }

  private fun handleHNSWIndexContains(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }

    try {
      val contains = LlamaMobileVD.nativeHNSWIndexContains(indexId, id)
      result.success(contains)
    } catch (e: Exception) {
      result.error("CONTAINS_FAILED", "Failed to check if vector exists: {e.message}", null)
    }
  }

  private fun handleHNSWIndexGetVector(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }

    try {
      val vector = LlamaMobileVD.nativeHNSWIndexGetVector(indexId, id)
      if (vector == null) {
        result.success(null)
      } else {
        result.success(vector.map { it.toDouble() })
      }
    } catch (e: Exception) {
      result.error("GET_FAILED", "Failed to get vector: {e.message}", null)
    }
  }

  private fun handleHNSWIndexSave(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }
    val filename = call.argument<String>("filename") ?: run {
      result.error("INVALID_ARGUMENTS", "Filename is required", null)
      return
    }

    try {
      val saved = LlamaMobileVD.nativeHNSWIndexSave(indexId, filename)
      result.success(saved)
    } catch (e: Exception) {
      result.error("SAVE_FAILED", "Failed to save HNSW index: {e.message}", null)
    }
  }

  private fun handleHNSWIndexLoad(call: MethodCall, result: Result) {
    val filename = call.argument<String>("filename") ?: run {
      result.error("INVALID_ARGUMENTS", "Filename is required", null)
      return
    }

    try {
      val indexId = LlamaMobileVD.nativeHNSWIndexLoad(filename)
      if (indexId == 0L) {
        result.error("LOAD_FAILED", "Failed to load HNSW index", null)
        return
      }
      result.success(indexId)
    } catch (e: Exception) {
      result.error("LOAD_FAILED", "Failed to load HNSW index: {e.message}", null)
    }
  }

  private fun handleHNSWIndexDestroy(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }

    try {
      LlamaMobileVD.nativeHNSWIndexDestroy(indexId)
      result.success(true)
    } catch (e: Exception) {
      result.error("DESTROY_FAILED", "Failed to destroy HNSW index: {e.message}", null)
    }
  }

  // MARK: - HNSWIndex async methods
  private fun handleHNSWIndexCreateAsync(call: MethodCall, result: Result) {
    val dimension = call.argument<Int>("dimension") ?: run {
      result.error("INVALID_ARGUMENTS", "Dimension is required", null)
      return
    }
    val metric = call.argument<Int>("metric") ?: run {
      result.error("INVALID_ARGUMENTS", "Metric is required", null)
      return
    }
    val maxElements = call.argument<Number>("maxElements")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "MaxElements is required", null)
      return
    }

    Thread {
      try {
        val indexId = LlamaMobileVD.nativeHNSWIndexCreate(dimension, metric, maxElements)
        if (indexId == 0L) {
          result.error("CREATE_FAILED", "Failed to create HNSW index", null)
          return@Thread
        }
        result.success(indexId)
      } catch (e: Exception) {
        result.error("CREATE_FAILED", "Failed to create HNSW index: {e.message}", null)
      }
    }.start()
  }

  private fun handleHNSWIndexCreateWithParamsAsync(call: MethodCall, result: Result) {
    val dimension = call.argument<Int>("dimension") ?: run {
      result.error("INVALID_ARGUMENTS", "Dimension is required", null)
      return
    }
    val metric = call.argument<Int>("metric") ?: run {
      result.error("INVALID_ARGUMENTS", "Metric is required", null)
      return
    }
    val maxElements = call.argument<Number>("maxElements")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "MaxElements is required", null)
      return
    }
    val M = call.argument<Int>("M") ?: run {
      result.error("INVALID_ARGUMENTS", "M is required", null)
      return
    }
    val efConstruction = call.argument<Int>("efConstruction") ?: run {
      result.error("INVALID_ARGUMENTS", "EfConstruction is required", null)
      return
    }
    val seed = call.argument<Int>("seed") ?: 42

    Thread {
      try {
        val indexId = LlamaMobileVD.nativeHNSWIndexCreateWithParams(dimension, metric, maxElements, M, efConstruction, seed)
        if (indexId == 0L) {
          result.error("CREATE_FAILED", "Failed to create HNSW index with params", null)
          return@Thread
        }
        result.success(indexId)
      } catch (e: Exception) {
        result.error("CREATE_FAILED", "Failed to create HNSW index with params: {e.message}", null)
      }
    }.start()
  }

  private fun handleHNSWIndexAddVectorAsync(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }
    val vector = call.argument<List<Double>>("vector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "Vector is required", null)
      return
    }

    Thread {
      try {
        val added = LlamaMobileVD.nativeHNSWIndexAddVector(indexId, id, vector)
        result.success(added)
      } catch (e: Exception) {
        result.error("ADD_FAILED", "Failed to add vector to HNSW index: {e.message}", null)
      }
    }.start()
  }

  private fun handleHNSWIndexSearchAsync(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }
    val queryVector = call.argument<List<Double>>("queryVector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "QueryVector is required", null)
      return
    }
    val k = call.argument<Int>("k") ?: run {
      result.error("INVALID_ARGUMENTS", "k is required", null)
      return
    }

    Thread {
      try {
        val searchResults = LlamaMobileVD.nativeHNSWIndexSearch(indexId, queryVector, k)
        val flutterResults = searchResults.map { mapOf("id" to it.id, "distance" to it.distance) }
        result.success(flutterResults)
      } catch (e: Exception) {
        result.error("SEARCH_FAILED", "Search failed: {e.message}", null)
      }
    }.start()
  }

  private fun handleHNSWIndexSaveAsync(call: MethodCall, result: Result) {
    val indexId = call.argument<Number>("indexId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "IndexId is required", null)
      return
    }
    val filename = call.argument<String>("filename") ?: run {
      result.error("INVALID_ARGUMENTS", "Filename is required", null)
      return
    }

    Thread {
      try {
        val saved = LlamaMobileVD.nativeHNSWIndexSave(indexId, filename)
        result.success(saved)
      } catch (e: Exception) {
        result.error("SAVE_FAILED", "Failed to save HNSW index: {e.message}", null)
      }
    }.start()
  }

  private fun handleHNSWIndexLoadAsync(call: MethodCall, result: Result) {
    val filename = call.argument<String>("filename") ?: run {
      result.error("INVALID_ARGUMENTS", "Filename is required", null)
      return
    }

    Thread {
      try {
        val indexId = LlamaMobileVD.nativeHNSWIndexLoad(filename)
        if (indexId == 0L) {
          result.error("LOAD_FAILED", "Failed to load HNSW index", null)
          return@Thread
        }
        result.success(indexId)
      } catch (e: Exception) {
        result.error("LOAD_FAILED", "Failed to load HNSW index: {e.message}", null)
      }
    }.start()
  }

  // MARK: - MMapVectorStoreBuilder methods
  private fun handleMMapVectorStoreBuilderCreate(call: MethodCall, result: Result) {
    val dimension = call.argument<Int>("dimension") ?: run {
      result.error("INVALID_ARGUMENTS", "Dimension is required", null)
      return
    }
    val metric = call.argument<Int>("metric") ?: run {
      result.error("INVALID_ARGUMENTS", "Metric is required", null)
      return
    }

    try {
      val builderId = LlamaMobileVD.nativeMMapVectorStoreBuilderCreate(dimension, metric)
      if (builderId == 0L) {
        result.error("CREATE_FAILED", "Failed to create MMapVectorStoreBuilder", null)
        return
      }
      result.success(builderId)
    } catch (e: Exception) {
      result.error("CREATE_FAILED", "Failed to create MMapVectorStoreBuilder: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreBuilderAddVector(call: MethodCall, result: Result) {
    val builderId = call.argument<Number>("builderId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "BuilderId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }
    val vector = call.argument<List<Double>>("vector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "Vector is required", null)
      return
    }

    try {
      val added = LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, id, vector)
      result.success(added)
    } catch (e: Exception) {
      result.error("ADD_FAILED", "Failed to add vector to builder: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreBuilderReserve(call: MethodCall, result: Result) {
    val builderId = call.argument<Number>("builderId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "BuilderId is required", null)
      return
    }
    val capacity = call.argument<Number>("capacity")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Capacity is required", null)
      return
    }

    try {
      val reserved = LlamaMobileVD.nativeMMapVectorStoreBuilderReserve(builderId, capacity)
      result.success(reserved)
    } catch (e: Exception) {
      result.error("RESERVE_FAILED", "Failed to reserve capacity: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreBuilderSave(call: MethodCall, result: Result) {
    val builderId = call.argument<Number>("builderId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "BuilderId is required", null)
      return
    }
    val filename = call.argument<String>("filename") ?: run {
      result.error("INVALID_ARGUMENTS", "Filename is required", null)
      return
    }

    try {
      val saved = LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderId, filename)
      result.success(saved)
    } catch (e: Exception) {
      result.error("SAVE_FAILED", "Failed to save builder: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreBuilderGetSize(call: MethodCall, result: Result) {
    val builderId = call.argument<Number>("builderId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "BuilderId is required", null)
      return
    }

    try {
      val size = LlamaMobileVD.nativeMMapVectorStoreBuilderGetSize(builderId)
      result.success(size)
    } catch (e: Exception) {
      result.error("SIZE_FAILED", "Failed to get size: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreBuilderGetDimension(call: MethodCall, result: Result) {
    val builderId = call.argument<Number>("builderId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "BuilderId is required", null)
      return
    }

    try {
      val dimension = LlamaMobileVD.nativeMMapVectorStoreBuilderGetDimension(builderId)
      result.success(dimension)
    } catch (e: Exception) {
      result.error("DIMENSION_FAILED", "Failed to get dimension: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreBuilderDestroy(call: MethodCall, result: Result) {
    val builderId = call.argument<Number>("builderId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "BuilderId is required", null)
      return
    }

    try {
      LlamaMobileVD.nativeMMapVectorStoreBuilderDestroy(builderId)
      result.success(true)
    } catch (e: Exception) {
      result.error("DESTROY_FAILED", "Failed to destroy builder: {e.message}", null)
    }
  }

  // MARK: - MMapVectorStoreBuilder async methods
  private fun handleMMapVectorStoreBuilderCreateAsync(call: MethodCall, result: Result) {
    val dimension = call.argument<Int>("dimension") ?: run {
      result.error("INVALID_ARGUMENTS", "Dimension is required", null)
      return
    }
    val metric = call.argument<Int>("metric") ?: run {
      result.error("INVALID_ARGUMENTS", "Metric is required", null)
      return
    }

    Thread {
      try {
        val builderId = LlamaMobileVD.nativeMMapVectorStoreBuilderCreate(dimension, metric)
        if (builderId == 0L) {
          result.error("CREATE_FAILED", "Failed to create MMapVectorStoreBuilder", null)
          return@Thread
        }
        result.success(builderId)
      } catch (e: Exception) {
        result.error("CREATE_FAILED", "Failed to create MMapVectorStoreBuilder: {e.message}", null)
      }
    }.start()
  }

  private fun handleMMapVectorStoreBuilderAddVectorAsync(call: MethodCall, result: Result) {
    val builderId = call.argument<Number>("builderId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "BuilderId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }
    val vector = call.argument<List<Double>>("vector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "Vector is required", null)
      return
    }

    Thread {
      try {
        val added = LlamaMobileVD.nativeMMapVectorStoreBuilderAddVector(builderId, id, vector)
        result.success(added)
      } catch (e: Exception) {
        result.error("ADD_FAILED", "Failed to add vector to builder: {e.message}", null)
      }
    }.start()
  }

  private fun handleMMapVectorStoreBuilderReserveAsync(call: MethodCall, result: Result) {
    val builderId = call.argument<Number>("builderId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "BuilderId is required", null)
      return
    }
    val capacity = call.argument<Number>("capacity")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Capacity is required", null)
      return
    }

    Thread {
      try {
        val reserved = LlamaMobileVD.nativeMMapVectorStoreBuilderReserve(builderId, capacity)
        result.success(reserved)
      } catch (e: Exception) {
        result.error("RESERVE_FAILED", "Failed to reserve capacity: {e.message}", null)
      }
    }.start()
  }

  private fun handleMMapVectorStoreBuilderSaveAsync(call: MethodCall, result: Result) {
    val builderId = call.argument<Number>("builderId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "BuilderId is required", null)
      return
    }
    val filename = call.argument<String>("filename") ?: run {
      result.error("INVALID_ARGUMENTS", "Filename is required", null)
      return
    }

    Thread {
      try {
        val saved = LlamaMobileVD.nativeMMapVectorStoreBuilderSave(builderId, filename)
        result.success(saved)
      } catch (e: Exception) {
        result.error("SAVE_FAILED", "Failed to save builder: {e.message}", null)
      }
    }.start()
  }

  // MARK: - MMapVectorStore methods
  private fun handleMMapVectorStoreOpen(call: MethodCall, result: Result) {
    val filename = call.argument<String>("filename") ?: run {
      result.error("INVALID_ARGUMENTS", "Filename is required", null)
      return
    }

    try {
      val storeId = LlamaMobileVD.nativeMMapVectorStoreOpen(filename)
      if (storeId == 0L) {
        result.error("OPEN_FAILED", "Failed to open MMapVectorStore", null)
        return
      }
      result.success(storeId)
    } catch (e: Exception) {
      result.error("OPEN_FAILED", "Failed to open MMapVectorStore: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreGetVector(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }

    try {
      val vector = LlamaMobileVD.nativeMMapVectorStoreGetVector(storeId, id)
      if (vector == null) {
        result.success(null)
      } else {
        result.success(vector.map { it.toDouble() })
      }
    } catch (e: Exception) {
      result.error("GET_FAILED", "Failed to get vector: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreContains(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val id = call.argument<Number>("id")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "Id is required", null)
      return
    }

    try {
      val contains = LlamaMobileVD.nativeMMapVectorStoreContains(storeId, id)
      result.success(contains)
    } catch (e: Exception) {
      result.error("CONTAINS_FAILED", "Failed to check if vector exists: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreSearch(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val queryVector = call.argument<List<Double>>("queryVector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "QueryVector is required", null)
      return
    }
    val k = call.argument<Int>("k") ?: run {
      result.error("INVALID_ARGUMENTS", "k is required", null)
      return
    }

    try {
      val searchResults = LlamaMobileVD.nativeMMapVectorStoreSearch(storeId, queryVector, k)
      val flutterResults = searchResults.map { mapOf("id" to it.id, "distance" to it.distance) }
      result.success(flutterResults)
    } catch (e: Exception) {
      result.error("SEARCH_FAILED", "Search failed: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreGetSize(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    try {
      val size = LlamaMobileVD.nativeMMapVectorStoreGetSize(storeId)
      result.success(size)
    } catch (e: Exception) {
      result.error("SIZE_FAILED", "Failed to get size: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreGetDimension(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    try {
      val dimension = LlamaMobileVD.nativeMMapVectorStoreGetDimension(storeId)
      result.success(dimension)
    } catch (e: Exception) {
      result.error("DIMENSION_FAILED", "Failed to get dimension: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreGetMetric(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    try {
      val metric = LlamaMobileVD.nativeMMapVectorStoreGetMetric(storeId)
      result.success(metric)
    } catch (e: Exception) {
      result.error("METRIC_FAILED", "Failed to get metric: {e.message}", null)
    }
  }

  private fun handleMMapVectorStoreClose(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }

    try {
      LlamaMobileVD.nativeMMapVectorStoreClose(storeId)
      result.success(true)
    } catch (e: Exception) {
      result.error("CLOSE_FAILED", "Failed to close store: {e.message}", null)
    }
  }

  // MARK: - MMapVectorStore async methods
  private fun handleMMapVectorStoreOpenAsync(call: MethodCall, result: Result) {
    val filename = call.argument<String>("filename") ?: run {
      result.error("INVALID_ARGUMENTS", "Filename is required", null)
      return
    }

    Thread {
      try {
        val storeId = LlamaMobileVD.nativeMMapVectorStoreOpen(filename)
        if (storeId == 0L) {
          result.error("OPEN_FAILED", "Failed to open MMapVectorStore", null)
          return@Thread
        }
        result.success(storeId)
      } catch (e: Exception) {
        result.error("OPEN_FAILED", "Failed to open MMapVectorStore: {e.message}", null)
      }
    }.start()
  }

  private fun handleMMapVectorStoreSearchAsync(call: MethodCall, result: Result) {
    val storeId = call.argument<Number>("storeId")?.toLong() ?: run {
      result.error("INVALID_ARGUMENTS", "StoreId is required", null)
      return
    }
    val queryVector = call.argument<List<Double>>("queryVector")?.map { it.toFloat() }?.toFloatArray() ?: run {
      result.error("INVALID_ARGUMENTS", "QueryVector is required", null)
      return
    }
    val k = call.argument<Int>("k") ?: run {
      result.error("INVALID_ARGUMENTS", "k is required", null)
      return
    }

    Thread {
      try {
        val searchResults = LlamaMobileVD.nativeMMapVectorStoreSearch(storeId, queryVector, k)
        val flutterResults = searchResults.map { mapOf("id" to it.id, "distance" to it.distance) }
        result.success(flutterResults)
      } catch (e: Exception) {
        result.error("SEARCH_FAILED", "Search failed: {e.message}", null)
      }
    }.start()
  }

  // MARK: - Version methods
  private fun handleGetVersion(call: MethodCall, result: Result) {
    try {
      val version = LlamaMobileVD.getVersion()
      result.success(version)
    } catch (e: Exception) {
      result.error("VERSION_FAILED", "Failed to get version: {e.message}", null)
    }
  }

  private fun handleGetVersionMajor(call: MethodCall, result: Result) {
    try {
      val major = LlamaMobileVD.getVersionMajor()
      result.success(major)
    } catch (e: Exception) {
      result.error("VERSION_FAILED", "Failed to get version major: {e.message}", null)
    }
  }

  private fun handleGetVersionMinor(call: MethodCall, result: Result) {
    try {
      val minor = LlamaMobileVD.getVersionMinor()
      result.success(minor)
    } catch (e: Exception) {
      result.error("VERSION_FAILED", "Failed to get version minor: {e.message}", null)
    }
  }

  private fun handleGetVersionPatch(call: MethodCall, result: Result) {
    try {
      val patch = LlamaMobileVD.getVersionPatch()
      result.success(patch)
    } catch (e: Exception) {
      result.error("VERSION_FAILED", "Failed to get version patch: {e.message}", null)
    }
  }
}
