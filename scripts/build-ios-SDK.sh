#!/bin/bash -e

# ============================================================================
# IOS SDK BUILD SCRIPT
# Takes pre-built iOS framework from llama_mobile-ios and creates iOS SDK
# Output: llama_mobile_vector_database/llama_mobile_vd-ios-SDK/
# ============================================================================

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp="$(date '+%H:%M:%S')"
    echo "[$timestamp] [$level] $message"
}

# Directory paths
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FRAMEWORK_DIR="$ROOT_DIR/llama_mobile_vd-ios"
SDK_DIR="$ROOT_DIR/llama_mobile_vd-ios-SDK"
FRAMEWORK_NAME="LlamaMobileVD"
XCFRAMEWORK_NAME="llama_mobile_vd.xcframework"

# Main script execution

log_message "INFO" "Starting iOS SDK build process..."

# Check if framework exists
if [ ! -d "$FRAMEWORK_DIR/llama_mobile_vd.xcframework" ]; then
    log_message "ERROR" "Framework not found at $FRAMEWORK_DIR/llama_mobile_vd.xcframework"
    log_message "INFO" "Please run build-ios-framework.sh first to build the iOS framework"
    exit 1
fi

log_message "INFO" "Found pre-built framework at $FRAMEWORK_DIR/llama_mobile_vd.xcframework"

# Create SDK directory if it doesn't exist
if [ ! -d "$SDK_DIR" ]; then
    log_message "INFO" "Creating SDK directory at $SDK_DIR"
    mkdir -p "$SDK_DIR"
fi

# Clean SDK directory
log_message "INFO" "Cleaning SDK directory..."
rm -rf "$SDK_DIR/$XCFRAMEWORK_NAME"
rm -rf "$SDK_DIR/.build" 2>/dev/null
rm -rf "$SDK_DIR/build" 2>/dev/null
rm -f "$SDK_DIR/CMakeCache.txt" 2>/dev/null
rm -rf "$SDK_DIR/CMakeFiles" 2>/dev/null
rm -f "$SDK_DIR/cmake_install.cmake" 2>/dev/null
rm -f "$SDK_DIR/Makefile" 2>/dev/null
rm -f "$SDK_DIR/*.xcodeproj" 2>/dev/null

# Copy the framework to SDK directory
log_message "INFO" "Copying framework to SDK directory..."
cp -R "$FRAMEWORK_DIR/llama_mobile_vd.xcframework" "$SDK_DIR/llama_mobile_vd.xcframework"

# Verify the Swift wrapper exists
if [ ! -d "$SDK_DIR/Sources/$FRAMEWORK_NAME" ]; then
    log_message "INFO" "Creating Swift wrapper directory structure..."
    mkdir -p "$SDK_DIR/Sources/$FRAMEWORK_NAME"
fi

# Create Swift wrapper file if it doesn't exist
if [ ! -f "$SDK_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift" ]; then
    log_message "INFO" "Creating basic Swift wrapper..."
    cat > "$SDK_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift" << 'EOF'
//
//  llama_mobile_vd.swift
//  llama_mobile_vd
//
//  Created by llama_mobile_vd team
//

import Foundation
import LlamaMobileVD

/// Swift wrapper for the llama_mobile_vd vector database
public class LlamaMobileVD {
    
    /// Error types for vector database operations
    public enum Error: Swift.Error {
        case operationFailed(String)
        case invalidParameter(String)
        case idNotFound
        case duplicateId
        case indexFull
    }
    
    /// Distance metrics for vector similarity
    public enum DistanceMetric {
        case l2
        case cosine
        case dot
        
        internal func toCEnum() -> LLAMA_MOBILE_VD_DistanceMetric {
            switch self {
            case .l2:
                return LLAMA_MOBILE_VD_DISTANCE_L2
            case .cosine:
                return LLAMA_MOBILE_VD_DISTANCE_COSINE
            case .dot:
                return LLAMA_MOBILE_VD_DISTANCE_DOT
            }
        }
    }
    
    /// Vector store class for managing vectors
    public class VectorStore {
        private var store: LLAMA_MOBILE_VD_VectorStore?
        
        /// Create a new vector store
        /// - Parameters:
        ///   - dimension: The dimension of vectors to store
        ///   - metric: The distance metric to use for similarity search
        public init(dimension: Int, metric: DistanceMetric = .l2) throws {
            var storePtr: LLAMA_MOBILE_VD_VectorStore?
            let error = llama_mobile_vd_vector_store_create(UInt64(dimension), metric.toCEnum(), &storePtr)
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to create vector store")
            }
            
            self.store = storePtr
        }
        
        /// Add a vector to the store
        /// - Parameters:
        ///   - id: Unique identifier for the vector
        ///   - vector: Array of float values representing the vector
        public func addVector(id: UInt64, vector: [Float]) throws {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            guard vector.count > 0 else { throw Error.invalidParameter("Empty vector") }
            
            let error = llama_mobile_vd_vector_store_add(store, id, vector)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to add vector")
            }
        }
        
        /// Search for similar vectors
        /// - Parameters:
        ///   - query: Query vector to search for
        ///   - k: Number of results to return
        /// - Returns: Array of (id, distance) tuples sorted by distance
        public func search(query: [Float], k: Int) throws -> [(id: UInt64, distance: Float)] {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            guard k > 0 else { throw Error.invalidParameter("Invalid k value") }
            
            var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
            let error = llama_mobile_vd_vector_store_search(store, query, UInt64(k), &results, UInt64(results.count))
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Search failed")
            }
            
            return results.map { ($0.id, $0.distance) }
        }
        
        /// Remove a vector by ID
        /// - Parameter id: Unique identifier of the vector to remove
        /// - Returns: True if the vector was found and removed, false otherwise
        public func removeVector(id: UInt64) throws -> Bool {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var removed = 0
            let error = llama_mobile_vd_vector_store_remove(store, id, &removed)
            
            if error != LLAMA_MOBILE_VD_OK && error != LLAMA_MOBILE_VD_ID_NOT_FOUND {
                throw mapError(error, message: "Failed to remove vector")
            }
            
            return removed != 0
        }
        
        /// Get a vector by ID
        /// - Parameter id: Unique identifier of the vector
        /// - Returns: Array of float values representing the vector
        public func getVector(id: UInt64) throws -> [Float] {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var dimension: UInt64 = 0
            let dimError = llama_mobile_vd_vector_store_dimension(store, &dimension)
            if dimError != LLAMA_MOBILE_VD_OK {
                throw mapError(dimError, message: "Failed to get dimension")
            }
            
            var vector = [Float](repeating: 0, count: Int(dimension))
            let error = llama_mobile_vd_vector_store_get(store, id, &vector, dimension)
            
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get vector")
            }
            
            return vector
        }
        
        /// Clear all vectors from the store
        public func clear() throws {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            let error = llama_mobile_vd_vector_store_clear(store)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to clear store")
            }
        }
        
        /// Get the number of vectors in the store
        public func count() throws -> UInt64 {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var count: UInt64 = 0
            let error = llama_mobile_vd_vector_store_size(store, &count)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get count")
            }
            
            return count
        }
        
        /// Get the dimension of vectors in the store
        public func dimension() throws -> UInt64 {
            guard let store = store else { throw Error.operationFailed("Store not initialized") }
            
            var dimension: UInt64 = 0
            let error = llama_mobile_vd_vector_store_dimension(store, &dimension)
            if error != LLAMA_MOBILE_VD_OK {
                throw mapError(error, message: "Failed to get dimension")
            }
            
            return dimension
        }
        
        /// Deinitialize the vector store
        deinit {
            if let store = store {
                llama_mobile_vd_vector_store_destroy(store)
            }
        }
    }
    
    /// Map C error codes to Swift errors
    private static func mapError(_ error: LLAMA_MOBILE_VD_Error, message: String) -> Error {
        switch error {
        case LLAMA_MOBILE_VD_OK:
            return Error.operationFailed(message)
        case LLAMA_MOBILE_VD_INVALID_ARGUMENT:
            return Error.invalidParameter(message)
        case LLAMA_MOBILE_VD_DUPLICATE_ID:
            return Error.duplicateId
        case LLAMA_MOBILE_VD_ID_NOT_FOUND:
            return Error.idNotFound
        case LLAMA_MOBILE_VD_INDEX_FULL:
            return Error.indexFull
        default:
            return Error.operationFailed(message)
        }
    }
}
EOF
fi

# Create Package.swift if it doesn't exist
if [ ! -f "$SDK_DIR/Package.swift" ]; then
    log_message "INFO" "Creating Package.swift file..."
    cat > "$SDK_DIR/Package.swift" << 'EOF'
// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LlamaMobileVD",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "LlamaMobileVD",
            targets: ["LlamaMobileVD"]
        )
    ],
    targets: [
        .target(
            name: "LlamaMobileVD",
            path: "Sources/LlamaMobileVD"
        )
    ]
)
EOF
fi

# Create README if it doesn't exist
if [ ! -f "$SDK_DIR/README.md" ]; then
    log_message "INFO" "Creating README.md file..."
    cat > "$SDK_DIR/README.md" << 'EOF'
# Llama Mobile VD - iOS SDK

iOS SDK for the Llama Mobile Vector Database (llama_mobile_vd).

## Features

- VectorStore implementation for efficient vector storage and retrieval
- Support for multiple distance metrics (L2, Cosine, Dot Product)
- Swift-friendly API with automatic memory management
- iOS 14.0+ support
- Metal-accelerated operations

## Installation

### Swift Package Manager

To integrate using Swift Package Manager:

1. In Xcode, go to File > Swift Packages > Add Package Dependency
2. Enter the package repository URL
3. Select the version you want to use

## Usage

### Creating a Vector Store

```swift
import LlamaMobileVD

do {
    // Create a vector store for 128-dimensional vectors
    let store = try LlamaMobileVD.VectorStore(dimension: 128, metric: .cosine)
    
    // Add vectors
    let vector1: [Float] = Array(repeating: 0.5, count: 128)
    let vector2: [Float] = Array(repeating: 1.0, count: 128)
    
    try store.addVector(id: 1, vector: vector1)
    try store.addVector(id: 2, vector: vector2)
    
    // Search for similar vectors
    let queryVector: [Float] = Array(repeating: 0.75, count: 128)
    let results = try store.search(query: queryVector, k: 1)
    
    print("Found similar vector with ID: \(results.first?.id ?? 0)")
    print("Distance: \(results.first?.distance ?? 0)")
    
    // Remove a vector
    try store.removeVector(id: 1)
    
    // Get vector count
    let count = try store.count()
    print("Vector count: \(count)")
    
    // Clear the store
    try store.clear()
    
} catch let error as LlamaMobileVD.Error {
    print("Vector database error: \(error)")
} catch {
    print("Unexpected error: \(error)")
}
```

## API Reference

### VectorStore

- `init(dimension: Int, metric: DistanceMetric = .l2)` - Create a new vector store
- `addVector(id: UInt64, vector: [Float])` - Add a vector to the store
- `search(query: [Float], k: Int)` - Search for k nearest vectors
- `removeVector(id: UInt64)` - Remove a vector by ID
- `getVector(id: UInt64)` - Retrieve a vector by ID
- `clear()` - Clear all vectors
- `count()` - Get number of vectors
- `dimension()` - Get vector dimension

### DistanceMetric

- `.l2` - Euclidean distance
- `.cosine` - Cosine similarity
- `.dot` - Dot product similarity

## Requirements

- iOS 14.0+
- Swift 5.3+

## License

MIT
EOF
fi

# Removed unnecessary src/ directory creation

# Create test directory if it doesn't exist
if [ ! -d "$SDK_DIR/Tests/LlamaMobileVDTests" ]; then
    log_message "INFO" "Creating test directory structure..."
    mkdir -p "$SDK_DIR/Tests/LlamaMobileVDTests"
    
    cat > "$SDK_DIR/Tests/LlamaMobileVDTests/LlamaMobileVDTests.swift" << 'EOF'
import XCTest
import LlamaMobileVD

class LlamaMobileVDTests: XCTestCase {
    
    func testVectorStoreCreation() {
        do {
            let store = try LlamaMobileVD.VectorStore(dimension: 64)
            XCTAssertEqual(try store.dimension(), 64)
            XCTAssertEqual(try store.count(), 0)
        } catch {
            XCTFail("Failed to create vector store: \(error)")
        }
    }
    
    func testAddAndSearchVectors() {
        do {
            let store = try LlamaMobileVD.VectorStore(dimension: 16)
            
            // Create similar vectors
            let vector1: [Float] = Array(repeating: 1.0, count: 16)
            let vector2: [Float] = Array(repeating: 1.1, count: 16)
            let vector3: [Float] = Array(repeating: 0.0, count: 16)
            
            // Add vectors
            try store.addVector(id: 1, vector: vector1)
            try store.addVector(id: 2, vector: vector2)
            try store.addVector(id: 3, vector: vector3)
            
            XCTAssertEqual(try store.count(), 3)
            
            // Search for similar vectors
            let results = try store.search(query: vector1, k: 2)
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].id, 1)
            XCTAssertEqual(results[1].id, 2)
            XCTAssertLessThan(results[0].distance, results[1].distance)
            
        } catch {
            XCTFail("Vector operations failed: \(error)")
        }
    }
    
    func testRemoveVector() {
        do {
            let store = try LlamaMobileVD.VectorStore(dimension: 8)
            
            let vector: [Float] = Array(repeating: 0.5, count: 8)
            try store.addVector(id: 1, vector: vector)
            
            XCTAssertEqual(try store.count(), 1)
            
            let removed = try store.removeVector(id: 1)
            XCTAssertTrue(removed)
            XCTAssertEqual(try store.count(), 0)
            
            // Removing non-existent ID should return false
            let removedAgain = try store.removeVector(id: 1)
            XCTAssertFalse(removedAgain)
            
        } catch {
            XCTFail("Remove operation failed: \(error)")
        }
    }
    
    func testClearStore() {
        do {
            let store = try LlamaMobileVD.VectorStore(dimension: 12)
            
            // Add multiple vectors
            for i in 1...5 {
                let vector: [Float] = Array(repeating: Float(i), count: 12)
                try store.addVector(id: UInt64(i), vector: vector)
            }
            
            XCTAssertEqual(try store.count(), 5)
            
            // Clear the store
            try store.clear()
            XCTAssertEqual(try store.count(), 0)
            
        } catch {
            XCTFail("Clear operation failed: \(error)")
        }
    }
    
    func testDistanceMetrics() {
        do {
            // Test different distance metrics
            let l2Store = try LlamaMobileVD.VectorStore(dimension: 4, metric: .l2)
            let cosineStore = try LlamaMobileVD.VectorStore(dimension: 4, metric: .cosine)
            let dotStore = try LlamaMobileVD.VectorStore(dimension: 4, metric: .dot)
            
            let vector1: [Float] = [1.0, 2.0, 3.0, 4.0]
            let vector2: [Float] = [2.0, 3.0, 4.0, 5.0]
            
            try l2Store.addVector(id: 1, vector: vector1)
            try l2Store.addVector(id: 2, vector: vector2)
            
            try cosineStore.addVector(id: 1, vector: vector1)
            try cosineStore.addVector(id: 2, vector: vector2)
            
            try dotStore.addVector(id: 1, vector: vector1)
            try dotStore.addVector(id: 2, vector: vector2)
            
            let queryVector: [Float] = [1.5, 2.5, 3.5, 4.5]
            
            let l2Results = try l2Store.search(query: queryVector, k: 2)
            let cosineResults = try cosineStore.search(query: queryVector, k: 2)
            let dotResults = try dotStore.search(query: queryVector, k: 2)
            
            // All should find the same vectors but with different distances
            XCTAssertEqual(l2Results.count, 2)
            XCTAssertEqual(cosineResults.count, 2)
            XCTAssertEqual(dotResults.count, 2)
            
            XCTAssertEqual(l2Results.map { $0.id }, [1, 2])
            XCTAssertEqual(cosineResults.map { $0.id }, [1, 2])
            XCTAssertEqual(dotResults.map { $0.id }, [1, 2])
            
        } catch {
            XCTFail("Distance metric test failed: \(error)")
        }
    }
}
EOF
fi

# Check framework structure
if [ -f "$SDK_DIR/llama_mobile_vd.xcframework/ios-arm64/llama_mobile_vd.framework/Headers/llama_mobile_vd_wrapper.h" ] && \
   [ -f "$SDK_DIR/llama_mobile_vd.xcframework/ios-arm64_x86_64-simulator/llama_mobile_vd.framework/Headers/llama_mobile_vd_wrapper.h" ]; then
    log_message "SUCCESS" "Framework headers are accessible"
else
    log_message "ERROR" "Framework headers not found"
    exit 1
fi

# Check Swift wrapper
if grep -q "import llama_mobile_vd" "$SDK_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift" || grep -q "import LlamaMobileVD" "$SDK_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift"; then
    log_message "SUCCESS" "Swift wrapper properly imports LlamaMobileVD module"
else
    log_message "ERROR" "Swift wrapper does not import LlamaMobileVD module"
    exit 1
fi

# Verify the framework has the correct dependency information
log_message "INFO" "Verifying framework dependencies..."

if grep -q "RequiredFrameworks" "$SDK_DIR/llama_mobile_vd.xcframework/Info.plist" && grep -q "Accelerate" "$SDK_DIR/llama_mobile_vd.xcframework/Info.plist" && grep -q "libc++" "$SDK_DIR/llama_mobile_vd.xcframework/Info.plist"; then
    log_message "SUCCESS" "Framework has correct dependency information (Accelerate, libc++)"
else
    log_message "WARNING" "Framework is missing dependency information. Ensure build-ios-framework.sh was run with dependency updates."
fi

log_message "INFO" "iOS SDK build completed successfully!"
log_message "INFO" ""
log_message "INFO" "SDK Location: $SDK_DIR"
log_message "INFO" "Framework: $SDK_DIR/llama_mobile_vd.xcframework"
log_message "INFO" "Swift Wrapper: $SDK_DIR/Sources/$FRAMEWORK_NAME/$FRAMEWORK_NAME.swift"
log_message "INFO" ""
log_message "INFO" "To use the SDK in your project:"
log_message "INFO" "1. Add the llama_mobile_vd.xcframework to your Xcode project"
log_message "INFO" "2. Add the LlamaMobileVD.swift file to your project"
log_message "INFO" "3. Import LlamaMobileVD in your Swift files"
log_message "INFO" "4. Use the vector database API as demonstrated in README.md"
log_message "INFO" ""
