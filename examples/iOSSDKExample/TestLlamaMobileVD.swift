import Foundation

// Import the LlamaMobileVD module
import LlamaMobileVD

// Test function
func testLlamaMobileVD() {
    do {
        // Create a vector store
        let vectorStore = try LlamaMobileVD.VectorStore(dimension: 128, metric: .l2)
        print("Vector store created successfully")
    } catch {
        print("Error creating vector store: \(error)")
    }
}

// Run the test
testLlamaMobileVD()
