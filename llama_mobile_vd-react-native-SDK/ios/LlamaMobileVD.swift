//
//  LlamaMobileVD.swift
//  llama-mobile-vd
//
//  Created by Llama Mobile Team on 2026-01-10.
//

import Foundation
import React
import LlamaMobileVD

/**
 * React Native module for LlamaMobileVD vector database
 * Implements RCTBridgeModule protocol to bridge JavaScript calls to native iOS functionality
 */
@objc(LlamaMobileVD)
class LlamaMobileVD: NSObject, RCTBridgeModule {
  /**
   * Static property required by RCTBridgeModule
   * Specifies the module name exposed to JavaScript
   */
  static func moduleName() -> String! {
    return "LlamaMobileVD"
  }

  /**
   * Static property required by RCTBridgeModule
   * Specifies that this module provides constants to JavaScript
   */
  static func requiresMainQueueSetup() -> Bool {
    return false
  }

  /**
   * Map of VectorStore instances by ID
   */
  private var vectorStores: [String: VectorStore] = [:]

  /**
   * Map of HNSWIndex instances by ID
   */
  private var hnswIndexes: [String: HNSWIndex] = [:]

  /**
   * Generate a unique ID for a VectorStore or HNSWIndex
   * @returns A unique string ID
   */
  private func generateUniqueId() -> String {
    return UUID().uuidString
  }

  /**
   * Convert a string to DistanceMetric enum
   * @param metricStr The string representation of the distance metric
   * @returns The corresponding DistanceMetric enum value
   * @throws Error if the string is not a valid distance metric
   */
  private func stringToDistanceMetric(_ metricStr: String) throws -> DistanceMetric {
    switch metricStr {
    case "L2":
      return .l2
    case "COSINE":
      return .cosine
    case "DOT":
      return .dot
    default:
      throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid distance metric: \(metricStr)"])
    }
  }

  /**
   * Create a new VectorStore
   * @param options Options for creating the VectorStore
   * @param resolve Completion handler for successful creation
   * @param reject Completion handler for errors
   */
  @objc(
    createVectorStore: 
    resolver: 
    rejecter:)
  func createVectorStore(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let dimension = options["dimension"] as? Int,
            let metricStr = options["metric"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      let metric = try stringToDistanceMetric(metricStr)
      let store = try VectorStore(dimension: dimension, metric: metric)
      let id = generateUniqueId()
      vectorStores[id] = store

      resolve(["id": id])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Create a new HNSWIndex
   * @param options Options for creating the HNSWIndex
   * @param resolve Completion handler for successful creation
   * @param reject Completion handler for errors
   */
  @objc(
    createHNSWIndex: 
    resolver: 
    rejecter:)
  func createHNSWIndex(
    _ options: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let dimension = options["dimension"] as? Int,
            let metricStr = options["metric"] as? String,
            let m = options["m"] as? Int,
            let efConstruction = options["efConstruction"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      let metric = try stringToDistanceMetric(metricStr)
      let index = try HNSWIndex(dimension: dimension, metric: metric, m: m, efConstruction: efConstruction)
      let id = generateUniqueId()
      hnswIndexes[id] = index

      resolve(["id": id])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Add a vector to a VectorStore
   * @param params Parameters for adding the vector
   * @param resolve Completion handler for successful addition
   * @param reject Completion handler for errors
   */
  @objc(
    addVectorToStore: 
    resolver: 
    rejecter:)
  func addVectorToStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let vectorArray = params["vector"] as? [NSNumber],
            let vectorId = params["vectorId"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      let vector = vectorArray.map { Float($0.doubleValue) }
      try store.addVector(vector, id: vectorId)

      resolve(nil)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Add a vector to an HNSWIndex
   * @param params Parameters for adding the vector
   * @param resolve Completion handler for successful addition
   * @param reject Completion handler for errors
   */
  @objc(
    addVectorToHNSW: 
    resolver: 
    rejecter:)
  func addVectorToHNSW(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let vectorArray = params["vector"] as? [NSNumber],
            let vectorId = params["vectorId"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      let vector = vectorArray.map { Float($0.doubleValue) }
      try index.addVector(vector, id: vectorId)

      resolve(nil)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Search for vectors in a VectorStore
   * @param params Parameters for searching the VectorStore
   * @param resolve Completion handler for successful search
   * @param reject Completion handler for errors
   */
  @objc(
    searchVectorStore: 
    resolver: 
    rejecter:)
  func searchVectorStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let queryVectorArray = params["queryVector"] as? [NSNumber],
            let k = params["k"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      let queryVector = queryVectorArray.map { $0.doubleValue }
      let results = try store.search(queryVector, k: k)

      // Convert results to JSON compatible format
      let jsonResults = results.map { result in
        return [
          "index": result.index,
          "distance": result.distance
        ] as [String: Any]
      }

      resolve(jsonResults)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Search for vectors in an HNSWIndex
   * @param params Parameters for searching the HNSWIndex
   * @param resolve Completion handler for successful search
   * @param reject Completion handler for errors
   */
  @objc(
    searchHNSWIndex: 
    resolver: 
    rejecter:)
  func searchHNSWIndex(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let queryVectorArray = params["queryVector"] as? [NSNumber],
            let k = params["k"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      let queryVector = queryVectorArray.map { $0.doubleValue }
      let results = try index.search(queryVector, k: k, efSearch: k)

      // Convert results to JSON compatible format
      let jsonResults = results.map { result in
        return [
          "index": result.index,
          "distance": result.distance
        ] as [String: Any]
      }

      resolve(jsonResults)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Count the number of vectors in a VectorStore
   * @param params Parameters for counting vectors
   * @param resolve Completion handler for successful count
   * @param reject Completion handler for errors
   */
  @objc(
    countVectorStore: 
    resolver: 
    rejecter:)
  func countVectorStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      let count = try store.count()
      resolve(["count": count])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Count the number of vectors in an HNSWIndex
   * @param params Parameters for counting vectors
   * @param resolve Completion handler for successful count
   * @param reject Completion handler for errors
   */
  @objc(
    countHNSWIndex: 
    resolver: 
    rejecter:)
  func countHNSWIndex(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      let count = try index.count()
      resolve(["count": count])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Clear all vectors from a VectorStore
   * @param params Parameters for clearing the VectorStore
   * @param resolve Completion handler for successful clearing
   * @param reject Completion handler for errors
   */
  @objc(
    clearVectorStore: 
    resolver: 
    rejecter:)
  func clearVectorStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      try store.clear()
      resolve(nil)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Clear all vectors from an HNSWIndex
   * @param params Parameters for clearing the HNSWIndex
   * @param resolve Completion handler for successful clearing
   * @param reject Completion handler for errors
   */
  @objc(
    clearHNSWIndex: 
    resolver: 
    rejecter:)
  func clearHNSWIndex(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      try index.clear()
      resolve(nil)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Release resources associated with a VectorStore
   * @param params Parameters for releasing the VectorStore
   * @param resolve Completion handler for successful release
   * @param reject Completion handler for errors
   */
  @objc(
    releaseVectorStore: 
    resolver: 
    rejecter:)
  func releaseVectorStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      if vectorStores.removeValue(forKey: id) == nil {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      resolve(nil)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Release resources associated with an HNSWIndex
   * @param params Parameters for releasing the HNSWIndex
   * @param resolve Completion handler for successful release
   * @param reject Completion handler for errors
   */
  @objc(
    releaseHNSWIndex: 
    resolver: 
    rejecter:)
  func releaseHNSWIndex(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      if hnswIndexes.removeValue(forKey: id) == nil {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      resolve(nil)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  // MARK: - VectorStore Additional Methods

  /**
   * Remove a vector from a VectorStore by ID
   * @param params Parameters for removing the vector
   * @param resolve Completion handler for successful removal
   * @param reject Completion handler for errors
   */
  @objc(
    removeVectorFromStore: 
    resolver: 
    rejecter:)
  func removeVectorFromStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let vectorId = params["vectorId"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      let removed = try store.remove(id: vectorId)
      resolve(removed)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get a vector from a VectorStore by ID
   * @param params Parameters for getting the vector
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getVectorFromStore: 
    resolver: 
    rejecter:)
  func getVectorFromStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let vectorId = params["vectorId"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      if let vector = try store.get(id: vectorId) {
        resolve(vector.map { NSNumber(value: $0) })
      } else {
        resolve(nil)
      }
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Update a vector in a VectorStore by ID
   * @param params Parameters for updating the vector
   * @param resolve Completion handler for successful update
   * @param reject Completion handler for errors
   */
  @objc(
    updateVectorInStore: 
    resolver: 
    rejecter:)
  func updateVectorInStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let vectorId = params["vectorId"] as? Int,
            let vectorArray = params["vector"] as? [NSNumber] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      let vector = vectorArray.map { Float($0.doubleValue) }
      let updated = try store.update(id: vectorId, vector: vector)
      resolve(updated)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Check if a VectorStore contains a vector with the given ID
   * @param params Parameters for checking the vector
   * @param resolve Completion handler for successful check
   * @param reject Completion handler for errors
   */
  @objc(
    containsVectorInStore: 
    resolver: 
    rejecter:)
  func containsVectorInStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let vectorId = params["vectorId"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      let contains = try store.contains(id: vectorId)
      resolve(contains)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Reserve space for vectors in a VectorStore
   * @param params Parameters for reserving space
   * @param resolve Completion handler for successful reservation
   * @param reject Completion handler for errors
   */
  @objc(
    reserveVectorStore: 
    resolver: 
    rejecter:)
  func reserveVectorStore(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let capacity = params["capacity"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      try store.reserve(capacity: capacity)
      resolve(nil)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get the dimension of vectors in a VectorStore
   * @param params Parameters for getting the dimension
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getVectorStoreDimension: 
    resolver: 
    rejecter:)
  func getVectorStoreDimension(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      let dimension = store.dimension
      resolve(["dimension": dimension])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get the distance metric used by a VectorStore
   * @param params Parameters for getting the metric
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getVectorStoreMetric: 
    resolver: 
    rejecter:)
  func getVectorStoreMetric(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      let metric = store.metric
      let metricStr: String
      switch metric {
      case .l2:
        metricStr = "L2"
      case .cosine:
        metricStr = "COSINE"
      case .dot:
        metricStr = "DOT"
      }
      resolve(["metric": metricStr])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  // MARK: - HNSWIndex Additional Methods

  /**
   * Set the efSearch parameter for an HNSWIndex
   * @param params Parameters for setting efSearch
   * @param resolve Completion handler for successful setting
   * @param reject Completion handler for errors
   */
  @objc(
    setHNSWEfSearch: 
    resolver: 
    rejecter:)
  func setHNSWEfSearch(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let efSearch = params["efSearch"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      try index.setEfSearch(efSearch)
      resolve(nil)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get the current efSearch parameter for an HNSWIndex
   * @param params Parameters for getting efSearch
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getHNSWEfSearch: 
    resolver: 
    rejecter:)
  func getHNSWEfSearch(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      let efSearch = try index.getEfSearch()
      resolve(["efSearch": efSearch])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Check if an HNSWIndex contains a vector with the given ID
   * @param params Parameters for checking the vector
   * @param resolve Completion handler for successful check
   * @param reject Completion handler for errors
   */
  @objc(
    containsVectorInHNSW: 
    resolver: 
    rejecter:)
  func containsVectorInHNSW(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let vectorId = params["vectorId"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      let contains = try index.contains(id: vectorId)
      resolve(contains)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get a vector from an HNSWIndex by ID
   * @param params Parameters for getting the vector
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getVectorFromHNSW: 
    resolver: 
    rejecter:)
  func getVectorFromHNSW(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let vectorId = params["vectorId"] as? Int else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      if let vector = try index.getVector(id: vectorId) {
        resolve(vector.map { NSNumber(value: $0) })
      } else {
        resolve(nil)
      }
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get the dimension of vectors in an HNSWIndex
   * @param params Parameters for getting the dimension
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getHNSWDimension: 
    resolver: 
    rejecter:)
  func getHNSWDimension(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      let dimension = index.dimension
      resolve(["dimension": dimension])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get the capacity of an HNSWIndex
   * @param params Parameters for getting the capacity
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getHNSWCapacity: 
    resolver: 
    rejecter:)
  func getHNSWCapacity(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: id"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      let capacity = index.capacity
      resolve(["capacity": capacity])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Save an HNSWIndex to a file
   * @param params Parameters for saving the index
   * @param resolve Completion handler for successful saving
   * @param reject Completion handler for errors
   */
  @objc(
    saveHNSWIndex: 
    resolver: 
    rejecter:)
  func saveHNSWIndex(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let id = params["id"] as? String,
            let path = params["path"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      let saved = try index.save(filename: path)
      resolve(saved)
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Load an HNSWIndex from a file
   * @param params Parameters for loading the index
   * @param resolve Completion handler for successful loading
   * @param reject Completion handler for errors
   */
  @objc(
    loadHNSWIndex: 
    resolver: 
    rejecter:)
  func loadHNSWIndex(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      guard let path = params["path"] as? String else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameter: path"])
      }

      let index = try HNSWIndex.load(filename: path)
      let id = generateUniqueId()
      hnswIndexes[id] = index
      resolve(["id": id])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  // MARK: - Version Methods

  /**
   * Get the version of the LlamaMobileVD SDK
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getVersion: 
    resolver: 
    rejecter:)
  func getVersion(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let version = LlamaMobileVDVersion.getVersion()
      resolve(["version": version])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get the major version component
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getVersionMajor: 
    resolver: 
    rejecter:)
  func getVersionMajor(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let major = LlamaMobileVDVersion.getVersionMajor()
      resolve(["major": major])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get the minor version component
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getVersionMinor: 
    resolver: 
    rejecter:)
  func getVersionMinor(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let minor = LlamaMobileVDVersion.getVersionMinor()
      resolve(["minor": minor])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }

  /**
   * Get the patch version component
   * @param resolve Completion handler for successful retrieval
   * @param reject Completion handler for errors
   */
  @objc(
    getVersionPatch: 
    resolver: 
    rejecter:)
  func getVersionPatch(
    _ params: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let patch = LlamaMobileVDVersion.getVersionPatch()
      resolve(["patch": patch])
    } catch {
      reject("ERROR", error.localizedDescription, error)
    }
  }
}