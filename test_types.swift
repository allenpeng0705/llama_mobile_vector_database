import llama_mobile_vd

// Test vector store create
func testVectorStoreCreate() {
    var storePtr: LLAMA_MOBILE_VD_VectorStore?
    let dimension: Int = 128
    let metric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
    
    // This will fail to compile but will show us the expected types
    let error = llama_mobile_vd_vector_store_create(dimension, metric, &storePtr)
}

// Test HNSW index create
func testHNSWIndexCreate() {
    var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
    let dimension: Int = 128
    let metric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
    let maxElements: Int = 1000
    
    // This will fail to compile but will show us the expected types
    let error = llama_mobile_vd_hnsw_index_create(dimension, metric, maxElements, &indexPtr)
}

// Test MMap vector store builder create
func testMMapVectorStoreBuilderCreate() {
    var builderPtr: LLAMA_MOBILE_VD_MMapVectorStoreBuilder?
    let dimension: Int = 128
    let metric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
    
    // This will fail to compile but will show us the expected types
    let error = llama_mobile_vd_mmap_vector_store_builder_create(dimension, metric, &builderPtr)
}
