import llama_mobile_vd

// Test the enum mapping
func testEnumMapping() {
    let metric: Int = 0
    
    // This will fail to compile but will show us the expected types
    let cMetric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DistanceMetric(metric)
}
