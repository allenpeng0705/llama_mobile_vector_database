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
            let vectorArray = params["vector"] as? [NSNumber] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let store = vectorStores[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "VectorStore not found for id: \(id)"])
      }

      let vector = vectorArray.map { $0.doubleValue }
      try store.addVector(vector)

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
            let vectorArray = params["vector"] as? [NSNumber] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters"])
      }

      guard let index = hnswIndexes[id] else {
        throw NSError(domain: "LlamaMobileVD", code: 0, userInfo: [NSLocalizedDescriptionKey: "HNSWIndex not found for id: \(id)"])
      }

      let vector = vectorArray.map { $0.doubleValue }
      try index.addVector(vector)

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
}