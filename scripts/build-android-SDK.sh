#!/bin/bash

# Set JAVA_HOME if not already set
if [ -z "$JAVA_HOME" ]; then
    echo "📁 Setting JAVA_HOME..."
    export JAVA_HOME=$(/usr/libexec/java_home)
    echo "JAVA_HOME set to: $JAVA_HOME"
fi


# ============================================================================
# VECTOR DATABASE ANDROID SDK BUILD SCRIPT
# Takes pre-built Android libraries from llama_mobile_vd-android and creates clean Android SDKs
# Output:
# - llama_mobile_vector_database/llama_mobile_vd-android-SDK/ (Kotlin SDK)
# - llama_mobile_vector_database/llama_mobile_vd-android-java-SDK/ (Java SDK)
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
PREBUILT_DIR="$ROOT_DIR/llama_mobile_vd-android"
KOTLIN_SDK_DIR="$ROOT_DIR/llama_mobile_vd-android-SDK"
JAVA_SDK_DIR="$ROOT_DIR/llama_mobile_vd-android-java-SDK"
SDK_BACKUP_DIR="$ROOT_DIR/scripts/sdk_backup"

# Create backup directory if it doesn't exist
mkdir -p "$SDK_BACKUP_DIR"

# Function to backup SDK
backup_sdk() {
    local sdk_dir="$1"
    local sdk_name="$(basename "$sdk_dir")"
    local timestamp="$(date '+%Y%m%d_%H%M%S')"
    local backup_name="${sdk_name}_${timestamp}"
    local backup_path="$SDK_BACKUP_DIR/$backup_name"
    
    log_message "INFO" "Backing up $sdk_name to $backup_path"
    
    # Create backup as directory copy
    cp -r "$sdk_dir" "$backup_path"
    
    if [ $? -eq 0 ]; then
        log_message "INFO" "Backup completed successfully: $backup_path"
    else
        log_message "ERROR" "Failed to create backup"
    fi
}

# Main script execution

log_message "INFO" "Starting Vector Database Android SDK build process..."

# Backup SDKs if they exist
if [ -d "$KOTLIN_SDK_DIR" ]; then
    backup_sdk "$KOTLIN_SDK_DIR"
fi

if [ -d "$JAVA_SDK_DIR" ]; then
    backup_sdk "$JAVA_SDK_DIR"
fi

# Check if pre-built libraries exist
if [ ! -d "$PREBUILT_DIR/libs/arm64-v8a" ] || [ ! -d "$PREBUILT_DIR/libs/x86_64" ]; then
    log_message "ERROR" "Pre-built libraries not found at $PREBUILT_DIR/libs/[ABI]"
    log_message "INFO" "Please ensure llama_mobile_vd-android/libs contains the arm64-v8a and x86_64 directories with pre-built libraries"
    exit 1
fi

log_message "INFO" "Found pre-built libraries at $PREBUILT_DIR"

# Clean jniLibs directories
log_message "INFO" "Cleaning jniLibs directories..."

for sdk_dir in "$KOTLIN_SDK_DIR" "$JAVA_SDK_DIR"; do
    if [ -d "$sdk_dir" ]; then
        # Clean only jniLibs directories
        for abi_dir in "$sdk_dir/src/main/jniLibs/arm64-v8a" "$sdk_dir/src/main/jniLibs/x86_64"; do
            if [ -d "$abi_dir" ]; then
                rm -f "$abi_dir"/*.a
                log_message "INFO" "Cleaned $abi_dir"
            fi
        done
    fi
done

# Ensure jniLibs directories exist
log_message "INFO" "Ensuring jniLibs directories exist..."

for sdk_dir in "$KOTLIN_SDK_DIR" "$JAVA_SDK_DIR"; do
    if [ -d "$sdk_dir" ]; then
        mkdir -p "$sdk_dir/src/main/jniLibs/arm64-v8a"
        mkdir -p "$sdk_dir/src/main/jniLibs/x86_64"
        mkdir -p "$sdk_dir/src/main/cpp/include"
    fi
done

# Copy pre-built libraries
log_message "INFO" "Copying pre-built libraries..."

for ABI in "arm64-v8a" "x86_64"; do
    # Copy libllama_mobile_vd.a
    SOURCE_LIB="$PREBUILT_DIR/libs/$ABI/libllama_mobile_vd.a"
    if [ ! -f "$SOURCE_LIB" ]; then
        log_message "ERROR" "Library not found for ABI $ABI at $SOURCE_LIB"
        exit 1
    fi
    
    # Copy to Kotlin SDK
    if [ -d "$KOTLIN_SDK_DIR" ]; then
        cp -f "$SOURCE_LIB" "$KOTLIN_SDK_DIR/src/main/jniLibs/$ABI/"
        log_message "INFO" "Copied $ABI library to Kotlin SDK at $KOTLIN_SDK_DIR/src/main/jniLibs/$ABI/"
    fi
    
    # Copy to Java SDK
    if [ -d "$JAVA_SDK_DIR" ]; then
        cp -f "$SOURCE_LIB" "$JAVA_SDK_DIR/src/main/jniLibs/$ABI/"
        log_message "INFO" "Copied $ABI library to Java SDK at $JAVA_SDK_DIR/src/main/jniLibs/$ABI/"
    fi
done

# Copy header files
if [ -d "$PREBUILT_DIR/include" ]; then
    # Process Kotlin SDK
    if [ -d "$KOTLIN_SDK_DIR" ]; then
        # Copy header files
        cp -f "$PREBUILT_DIR/include"/*.h "$KOTLIN_SDK_DIR/src/main/cpp/include/"
        log_message "INFO" "Copied header files to Kotlin SDK at $KOTLIN_SDK_DIR/src/main/cpp/include/"
    fi
    
    # Process Java SDK
    if [ -d "$JAVA_SDK_DIR" ]; then
        # Copy header files
        cp -f "$PREBUILT_DIR/include"/*.h "$JAVA_SDK_DIR/src/main/cpp/include/"
        log_message "INFO" "Copied header files to Java SDK at $JAVA_SDK_DIR/src/main/cpp/include/"
    fi
else
    log_message "WARN" "Header files not found at $PREBUILT_DIR/include"
fi

# Function to run tests and build AAR
run_tests_and_build() {
    local sdk_dir="$1"
    local sdk_name="$(basename "$sdk_dir")"
    
    log_message "INFO" "Running tests and building AAR for $sdk_name"
    
    # Change to SDK directory
    cd "$sdk_dir"
    
    # Run unit tests
    log_message "INFO" "Running unit tests for $sdk_name"
    ./gradlew test
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Unit tests failed for $sdk_name"
        return 1
    fi
    
    # Build both debug and release AARs
    log_message "INFO" "Building debug and release AARs for $sdk_name"
    ./gradlew assembleDebug assembleRelease
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "AAR build failed for $sdk_name"
        return 1
    fi
    
    # Create output directory and copy AARs
    local output_dir="$sdk_dir/output"
    mkdir -p "$output_dir"
    
    # Find and copy all built AARs
    local aar_files=$(find "$sdk_dir/build/outputs/aar" -name "*.aar")
    if [ -n "$aar_files" ]; then
        for aar_file in $aar_files; do
            cp "$aar_file" "$output_dir/"
            log_message "INFO" "AAR copied to $output_dir/$(basename "$aar_file")"
        done
    else
        log_message "WARN" "No AAR files found for $sdk_name"
    fi
    
    # Return to root directory
    cd "$ROOT_DIR"
    
    return 0
}

# Run tests and build AAR for both SDKs
if [ -d "$KOTLIN_SDK_DIR" ]; then
    run_tests_and_build "$KOTLIN_SDK_DIR"
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to build Kotlin SDK"
        exit 1
    fi
fi

if [ -d "$JAVA_SDK_DIR" ]; then
    run_tests_and_build "$JAVA_SDK_DIR"
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to build Java SDK"
        exit 1
    fi
fi

log_message "INFO" "Android SDK build completed successfully!"
log_message "INFO" "Kotlin SDK directory: $KOTLIN_SDK_DIR"
log_message "INFO" "Java SDK directory: $JAVA_SDK_DIR"

# Exit with success
exit 0

# The following code is the JNI template that was moved to jni_template.cpp
# This is just a reference and is no longer used directly in the script

// JNI namespace
namespace {
    // Helper function to convert Java float array to C++ vector
    std::vector<float> jfloatArrayToVector(JNIEnv* env, jfloatArray jarray) {
        std::vector<float> result;
        if (jarray == nullptr) {
            return result;
        }
        
        jsize length = env->GetArrayLength(jarray);
        result.resize(length);
        
        jfloat* elements = env->GetFloatArrayElements(jarray, nullptr);
        if (elements == nullptr) {
            return result;
        }
        
        for (jsize i = 0; i < length; i++) {
            result[i] = elements[i];
        }
        
        env->ReleaseFloatArrayElements(jarray, elements, JNI_ABORT);
        return result;
    }

    // Helper function to convert C++ vector to Java float array
    jfloatArray vectorToJfloatArray(JNIEnv* env, const std::vector<float>& vec) {
        jfloatArray jarray = env->NewFloatArray(vec.size());
        if (jarray == nullptr) {
            return nullptr;
        }
        
        env->SetFloatArrayRegion(jarray, 0, vec.size(), vec.data());
        return jarray;
    }

    // Helper function to throw Java exception
    void throwLlamaMobileVDException(JNIEnv* env, const char* message, int errorCode) {
        jclass exceptionClass = env->FindClass(\"com/llamamobile/vd/LlamaMobileVDException\");
        if (exceptionClass != nullptr) {
            env->ThrowNew(exceptionClass, message);
        }
    }

    // Map to store native pointers
    std::unordered_map<jlong, void*> nativePointers;
    jlong nextPointerId = 1;

    // Get native pointer from ID
    void* getNativePointer(jlong id) {
        auto it = nativePointers.find(id);
        if (it != nativePointers.end()) {
            return it->second;
        }
        return nullptr;
    }

    // Register native pointer and return ID
    jlong registerNativePointer(void* ptr) {
        jlong id = nextPointerId++;
        nativePointers[id] = ptr;
        return id;
    }

    // Remove native pointer
    void removeNativePointer(jlong id) {
        nativePointers.erase(id);
    }
}

// ==========================
// DistanceMetric enum mapping
// ==========================
static const std::unordered_map<int, LLAMA_MOBILE_VD_DistanceMetric> distanceMetricMap = {
    {0, LLAMA_MOBILE_VD_DISTANCE_L2},
    {1, LLAMA_MOBILE_VD_DISTANCE_COSINE},
    {2, LLAMA_MOBILE_VD_DISTANCE_DOT}
};

// ==========================
// VectorStore JNI methods
// ==========================

// Create VectorStore
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreCreate(
        JNIEnv* env,
        jclass clazz,
        jint dimension,
        jint metric) {
    
    auto it = distanceMetricMap.find(metric);
    if (it == distanceMetricMap.end()) {
        throwLlamaMobileVDException(env, \"Invalid distance metric\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    LLAMA_MOBILE_VDVectorStore store = nullptr;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_create(
            static_cast<size_t>(dimension),
            it->second,
            &store);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, \"Failed to create vector store\", error);
        return 0;
    }
    
    return registerNativePointer(store);
}

// Add vector to VectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreAdd(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id,
        jfloatArray vector) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, \"Invalid vector store\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    std::vector<float> vec = jfloatArrayToVector(env, vector);
    if (vec.empty()) {
        throwLlamaMobileVDException(env, \"Invalid vector\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_add(
            store,
            static_cast<uint64_t>(id),
            vec.data());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, \"Failed to add vector\", error);
        return;
    }
}

// Search VectorStore
JNIEXPORT jobjectArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreSearch(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jfloatArray query,
        jint k) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, \"Invalid vector store\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    std::vector<float> queryVec = jfloatArrayToVector(env, query);
    if (queryVec.empty()) {
        throwLlamaMobileVDException(env, \"Invalid query vector\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    std::vector<LLAMA_MOBILE_VDSearchResult> results(k);
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_search(
            store,
            queryVec.data(),
            static_cast<size_t>(k),
            results.data(),
            results.size());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, \"Search failed\", error);
        return nullptr;
    }
    
    // Create array of SearchResult objects
    jclass resultClass = env->FindClass(\"com/llamamobile/vd/SearchResult\");
    jmethodID constructor = env->GetMethodID(resultClass, \"<init>\", \"(JF)V\");
    jobjectArray resultArray = env->NewObjectArray(k, resultClass, nullptr);
    
    for (int i = 0; i < k; i++) {
        jobject resultObj = env->NewObject(
                resultClass,
                constructor,
                static_cast<jlong>(results[i].id),
                static_cast<jfloat>(results[i].distance));
        env->SetObjectArrayElement(resultArray, i, resultObj);
        env->DeleteLocalRef(resultObj);
    }
    
    return resultArray;
}

// Destroy VectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreDestroy(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        return;
    }
    
    llama_mobile_vd_vector_store_destroy(store);
    removeNativePointer(storeId);
}

// Remove vector from VectorStore
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreRemove(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    int removed = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_remove(
            store,
            static_cast<uint64_t>(id),
            &removed);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to remove vector", error);
        return JNI_FALSE;
    }
    
    return removed ? JNI_TRUE : JNI_FALSE;
}

// Get vector from VectorStore
JNIEXPORT jfloatArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreGet(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    // Get the dimension first
    size_t dimension = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_dimension(store, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector dimension", error);
        return nullptr;
    }
    
    std::vector<float> vector(dimension);
    error = llama_mobile_vd_vector_store_get(
            store,
            static_cast<uint64_t>(id),
            vector.data(),
            vector.size());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector", error);
        return nullptr;
    }
    
    return vectorToJfloatArray(env, vector);
}

// Update vector in VectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreUpdate(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id,
        jfloatArray vector) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    std::vector<float> vec = jfloatArrayToVector(env, vector);
    if (vec.empty()) {
        throwLlamaMobileVDException(env, "Invalid vector", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_update(
            store,
            static_cast<uint64_t>(id),
            vec.data());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to update vector", error);
        return;
    }
}

// Get VectorStore size
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreSize(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    size_t size = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_size(store, &size);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector store size", error);
        return 0;
    }
    
    return static_cast<jint>(size);
}

// Get VectorStore dimension
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreDimension(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    size_t dimension = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_dimension(store, &dimension);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector store dimension", error);
        return 0;
    }
    
    return static_cast<jint>(dimension);
}

// Get VectorStore metric
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreMetric(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    LLAMA_MOBILE_VDDistanceMetric metric;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_metric(store, &metric);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector store metric", error);
        return 0;
    }
    
    return static_cast<jint>(metric);
}

// Check if VectorStore contains vector
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreContains(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    int contains = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_contains(
            store,
            static_cast<uint64_t>(id),
            &contains);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to check if vector exists", error);
        return JNI_FALSE;
    }
    
    return contains ? JNI_TRUE : JNI_FALSE;
}

// Reserve capacity in VectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreReserve(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jint capacity) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_reserve(
            store,
            static_cast<size_t>(capacity));
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to reserve capacity", error);
        return;
    }
}

// Clear VectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeVectorStoreClear(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    
    LLAMA_MOBILE_VDVectorStore store = static_cast<LLAMA_MOBILE_VDVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid vector store", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    LLAMA_MOBILE_VDError error = llama_mobile_vd_vector_store_clear(store);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to clear vector store", error);
        return;
    }
}

// ==========================
// HNSWIndex JNI methods
// ==========================

// Create HNSWIndex
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCreate(
        JNIEnv* env,
        jclass clazz,
        jint dimension,
        jint metric,
        jint maxElements) {
    
    auto it = distanceMetricMap.find(metric);
    if (it == distanceMetricMap.end()) {
        throwLlamaMobileVDException(env, \"Invalid distance metric\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    LLAMA_MOBILE_VDHNSWIndex index = nullptr;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_create(
            static_cast<size_t>(dimension),
            it->second,
            static_cast<size_t>(maxElements),
            &index);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, \"Failed to create HNSW index\", error);
        return 0;
    }
    
    return registerNativePointer(index);
}

// Add vector to HNSWIndex
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexAdd(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jlong id,
        jfloatArray vector) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, \"Invalid HNSW index\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    std::vector<float> vec = jfloatArrayToVector(env, vector);
    if (vec.empty()) {
        throwLlamaMobileVDException(env, \"Invalid vector\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_add(
            index,
            static_cast<uint64_t>(id),
            vec.data());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, \"Failed to add vector\", error);
        return;
    }
}

// Search HNSWIndex
JNIEXPORT jobjectArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSearch(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jfloatArray query,
        jint k) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, \"Invalid HNSW index\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    std::vector<float> queryVec = jfloatArrayToVector(env, query);
    if (queryVec.empty()) {
        throwLlamaMobileVDException(env, \"Invalid query vector\", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    std::vector<LLAMA_MOBILE_VDSearchResult> results(k);
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_search(
            index,
            queryVec.data(),
            static_cast<size_t>(k),
            results.data(),
            results.size());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, \"Search failed\", error);
        return nullptr;
    }
    
    // Create array of SearchResult objects
    jclass resultClass = env->FindClass(\"com/llamamobile/vd/SearchResult\");
    jmethodID constructor = env->GetMethodID(resultClass, \"<init>\", \"(JF)V\");
    jobjectArray resultArray = env->NewObjectArray(k, resultClass, nullptr);
    
    for (int i = 0; i < k; i++) {
        jobject resultObj = env->NewObject(
                resultClass,
                constructor,
                static_cast<jlong>(results[i].id),
                static_cast<jfloat>(results[i].distance));
        env->SetObjectArrayElement(resultArray, i, resultObj);
        env->DeleteLocalRef(resultObj);
    }
    
    return resultArray;
}

// Destroy HNSWIndex
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexDestroy(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        return;
    }
    
    llama_mobile_vd_hnsw_index_destroy(index);
    removeNativePointer(indexId);
}

// Create HNSWIndex with custom parameters
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCreateWithParams(
        JNIEnv* env,
        jclass clazz,
        jint dimension,
        jint metric,
        jint maxElements,
        jint M,
        jint efConstruction,
        jint seed) {
    
    LLAMA_MOBILE_VDHNSWIndex index = nullptr;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_create_with_params(
            static_cast<size_t>(dimension),
            static_cast<LLAMA_MOBILE_VDDistanceMetric>(metric),
            static_cast<size_t>(maxElements),
            static_cast<size_t>(M),
            static_cast<size_t>(efConstruction),
            static_cast<uint32_t>(seed),
            &index);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to create HNSWIndex with params", error);
        return 0;
    }
    
    return addNativePointer(index);
}

// Set ef_search parameter for HNSWIndex
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSetEfSearch(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jint efSearch) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_set_ef_search(
            index,
            static_cast<size_t>(efSearch));
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to set ef_search", error);
        return;
    }
}

// Get ef_search parameter from HNSWIndex
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetEfSearch(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    size_t efSearch = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_get_ef_search(index, &efSearch);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get ef_search", error);
        return 0;
    }
    
    return static_cast<jint>(efSearch);
}

// Get HNSWIndex size
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSize(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    size_t size = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_size(index, &size);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get index size", error);
        return 0;
    }
    
    return static_cast<jint>(size);
}

// Get HNSWIndex dimension
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexDimension(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    size_t dimension = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_dimension(index, &dimension);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get index dimension", error);
        return 0;
    }
    
    return static_cast<jint>(dimension);
}

// Get HNSWIndex capacity
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexCapacity(
        JNIEnv* env,
        jclass clazz,
        jlong indexId) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    size_t capacity = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_capacity(index, &capacity);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get index capacity", error);
        return 0;
    }
    
    return static_cast<jint>(capacity);
}

// Check if HNSWIndex contains vector
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexContains(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jlong id) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }
    
    int contains = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_contains(
            index,
            static_cast<uint64_t>(id),
            &contains);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to check if vector exists", error);
        return JNI_FALSE;
    }
    
    return contains ? JNI_TRUE : JNI_FALSE;
}

// Get vector from HNSWIndex
JNIEXPORT jfloatArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexGetVector(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jlong id) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }
    
    // Get the dimension first
    size_t dimension = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_dimension(index, &dimension);
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector dimension", error);
        return nullptr;
    }
    
    std::vector<float> vector(dimension);
    error = llama_mobile_vd_hnsw_index_get_vector(
            index,
            static_cast<uint64_t>(id),
            vector.data(),
            vector.size());
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector", error);
        return nullptr;
    }
    
    return vectorToJfloatArray(env, vector);
}

// Save HNSWIndex to file
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexSave(
        JNIEnv* env,
        jclass clazz,
        jlong indexId,
        jstring filename) {
    
    LLAMA_MOBILE_VDHNSWIndex index = static_cast<LLAMA_MOBILE_VDHNSWIndex>(getNativePointer(indexId));
    if (index == nullptr) {
        throwLlamaMobileVDException(env, "Invalid HNSW index", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    const char* filenameStr = env->GetStringUTFChars(filename, nullptr);
    if (filenameStr == nullptr) {
        throwLlamaMobileVDException(env, "Invalid filename", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }
    
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_save(index, filenameStr);
    env->ReleaseStringUTFChars(filename, filenameStr);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to save index", error);
        return;
    }
}

// Load HNSWIndex from file
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeHNSWIndexLoad(
        JNIEnv* env,
        jclass clazz,
        jstring filename) {
    
    const char* filenameStr = env->GetStringUTFChars(filename, nullptr);
    if (filenameStr == nullptr) {
        throwLlamaMobileVDException(env, "Invalid filename", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }
    
    LLAMA_MOBILE_VDHNSWIndex index = nullptr;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_hnsw_index_load(filenameStr, &index);
    env->ReleaseStringUTFChars(filename, filenameStr);
    
    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to load index", error);
        return 0;
    }
    
    return addNativePointer(index);
}

// ==========================
// MMapVectorStoreBuilder methods
// ==========================

// Create MMapVectorStoreBuilder
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderCreate(
        JNIEnv* env,
        jclass clazz,
        jint dimension,
        jint metric) {
    LLAMA_MOBILE_VDMMapVectorStoreBuilder builder;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_builder_create(
            static_cast<size_t>(dimension),
            static_cast<LLAMA_MOBILE_VDDistanceMetric>(metric),
            &builder);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to create MMapVectorStoreBuilder", error);
        return 0;
    }

    return registerNativePointer(builder);
}

// Add vector to MMapVectorStoreBuilder
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderAdd(
        JNIEnv* env,
        jclass clazz,
        jlong builderId,
        jlong id,
        jfloatArray vector) {
    LLAMA_MOBILE_VDMMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VDMMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStoreBuilder handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }

    std::vector<float> vec = jfloatArrayToVector(env, vector);
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_builder_add(
            builder,
            static_cast<uint64_t>(id),
            vec.data());

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to add vector to MMapVectorStoreBuilder", error);
    }
}

// Reserve capacity for MMapVectorStoreBuilder
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderReserve(
        JNIEnv* env,
        jclass clazz,
        jlong builderId,
        jint capacity) {
    LLAMA_MOBILE_VDMMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VDMMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStoreBuilder handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }

    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_builder_reserve(
            builder,
            static_cast<size_t>(capacity));

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to reserve capacity for MMapVectorStoreBuilder", error);
    }
}

// Save MMapVectorStoreBuilder to file
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderSave(
        JNIEnv* env,
        jclass clazz,
        jlong builderId,
        jstring filename) {
    LLAMA_MOBILE_VDMMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VDMMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStoreBuilder handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return;
    }

    const char* filenameStr = env->GetStringUTFChars(filename, nullptr);
    if (filenameStr == nullptr) {
        return;
    }

    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_builder_save(builder, filenameStr);
    env->ReleaseStringUTFChars(filename, filenameStr);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to save MMapVectorStoreBuilder", error);
    }
}

// Get MMapVectorStoreBuilder size
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderSize(
        JNIEnv* env,
        jclass clazz,
        jlong builderId) {
    LLAMA_MOBILE_VDMMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VDMMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStoreBuilder handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }

    size_t size = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_builder_size(builder, &size);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get MMapVectorStoreBuilder size", error);
        return 0;
    }

    return static_cast<jint>(size);
}

// Get MMapVectorStoreBuilder dimension
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderDimension(
        JNIEnv* env,
        jclass clazz,
        jlong builderId) {
    LLAMA_MOBILE_VDMMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VDMMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStoreBuilder handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }

    size_t dimension = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_builder_dimension(builder, &dimension);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get MMapVectorStoreBuilder dimension", error);
        return 0;
    }

    return static_cast<jint>(dimension);
}

// Destroy MMapVectorStoreBuilder
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreBuilderDestroy(
        JNIEnv* env,
        jclass clazz,
        jlong builderId) {
    LLAMA_MOBILE_VDMMapVectorStoreBuilder builder = static_cast<LLAMA_MOBILE_VDMMapVectorStoreBuilder>(getNativePointer(builderId));
    if (builder == nullptr) {
        return;
    }

    llama_mobile_vd_mmap_vector_store_builder_destroy(builder);
    removeNativePointer(builderId);
}

// ==========================
// MMapVectorStore methods
// ==========================

// Open MMapVectorStore
JNIEXPORT jlong JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreOpen(
        JNIEnv* env,
        jclass clazz,
        jstring filename) {
    const char* filenameStr = env->GetStringUTFChars(filename, nullptr);
    if (filenameStr == nullptr) {
        return 0;
    }

    LLAMA_MOBILE_VDMMapVectorStore store;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_open(filenameStr, &store);
    env->ReleaseStringUTFChars(filename, filenameStr);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to open MMapVectorStore", error);
        return 0;
    }

    return registerNativePointer(store);
}

// Get vector from MMapVectorStore
JNIEXPORT jfloatArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreGet(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {
    LLAMA_MOBILE_VDMMapVectorStore store = static_cast<LLAMA_MOBILE_VDMMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStore handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }

    const float* vector = nullptr;
    size_t dimension = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_get(
            store,
            static_cast<uint64_t>(id),
            &vector,
            &dimension);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get vector from MMapVectorStore", error);
        return nullptr;
    }

    jfloatArray result = env->NewFloatArray(static_cast<jsize>(dimension));
    if (result == nullptr) {
        return nullptr;
    }

    env->SetFloatArrayRegion(result, 0, static_cast<jsize>(dimension), vector);
    return result;
}

// Check if vector exists in MMapVectorStore
JNIEXPORT jboolean JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreContains(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jlong id) {
    LLAMA_MOBILE_VDMMapVectorStore store = static_cast<LLAMA_MOBILE_VDMMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStore handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return JNI_FALSE;
    }

    bool contains = false;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_contains(
            store,
            static_cast<uint64_t>(id),
            &contains);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to check if vector exists in MMapVectorStore", error);
        return JNI_FALSE;
    }

    return contains ? JNI_TRUE : JNI_FALSE;
}

// Search in MMapVectorStore
JNIEXPORT jobjectArray JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreSearch(
        JNIEnv* env,
        jclass clazz,
        jlong storeId,
        jfloatArray jquery,
        jint k) {
    LLAMA_MOBILE_VDMMapVectorStore store = static_cast<LLAMA_MOBILE_VDMMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStore handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return nullptr;
    }

    std::vector<float> query = jfloatArrayToVector(env, jquery);
    std::vector<LLAMA_MOBILE_VDSearchResult> results(static_cast<size_t>(k));

    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_search(
            store,
            query.data(),
            static_cast<size_t>(k),
            results.data(),
            results.size());

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Search failed", error);
        return nullptr;
    }

    // Create array of SearchResult objects
    jclass resultClass = env->FindClass("com/llamamobile/vd/SearchResult");
    jmethodID constructor = env->GetMethodID(resultClass, "<init>", "(JF)V");
    jobjectArray resultArray = env->NewObjectArray(k, resultClass, nullptr);

    for (int i = 0; i < k; i++) {
        jobject resultObj = env->NewObject(
                resultClass,
                constructor,
                static_cast<jlong>(results[i].id),
                static_cast<jfloat>(results[i].distance));
        env->SetObjectArrayElement(resultArray, i, resultObj);
        env->DeleteLocalRef(resultObj);
    }

    return resultArray;
}

// Get MMapVectorStore size
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreSize(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    LLAMA_MOBILE_VDMMapVectorStore store = static_cast<LLAMA_MOBILE_VDMMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStore handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }

    size_t size = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_size(store, &size);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get MMapVectorStore size", error);
        return 0;
    }

    return static_cast<jint>(size);
}

// Get MMapVectorStore dimension
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreDimension(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    LLAMA_MOBILE_VDMMapVectorStore store = static_cast<LLAMA_MOBILE_VDMMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStore handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }

    size_t dimension = 0;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get MMapVectorStore dimension", error);
        return 0;
    }

    return static_cast<jint>(dimension);
}

// Get MMapVectorStore metric
JNIEXPORT jint JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreMetric(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    LLAMA_MOBILE_VDMMapVectorStore store = static_cast<LLAMA_MOBILE_VDMMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        throwLlamaMobileVDException(env, "Invalid MMapVectorStore handle", LLAMA_MOBILE_VD_INVALID_ARGUMENT);
        return 0;
    }

    LLAMA_MOBILE_VDDistanceMetric metric;
    LLAMA_MOBILE_VDError error = llama_mobile_vd_mmap_vector_store_metric(store, &metric);

    if (error != LLAMA_MOBILE_VD_OK) {
        throwLlamaMobileVDException(env, "Failed to get MMapVectorStore metric", error);
        return 0;
    }

    return static_cast<jint>(metric);
}

// Close MMapVectorStore
JNIEXPORT void JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeMMapVectorStoreClose(
        JNIEnv* env,
        jclass clazz,
        jlong storeId) {
    LLAMA_MOBILE_VDMMapVectorStore store = static_cast<LLAMA_MOBILE_VDMMapVectorStore>(getNativePointer(storeId));
    if (store == nullptr) {
        return;
    }

    llama_mobile_vd_mmap_vector_store_close(store);
    removeNativePointer(storeId);
}

// ==========================
// Version methods
// ==========================

// Get version string
JNIEXPORT jstring JNICALL Java_com_llamamobile_vd_LlamaMobileVD_nativeGetVersion(
        JNIEnv* env,
        jclass clazz) {
    const char* version = llama_mobile_vd_version();
    return env->NewStringUTF(version);
}
EOF
)

# Write JNI bridge file for both SDKs
echo "$JNI_CPP_CONTENT" > "$KOTLIN_SDK_DIR/src/main/cpp/llama_mobile_vd_jni.cpp"
echo "$JNI_CPP_CONTENT" > "$JAVA_SDK_DIR/src/main/cpp/llama_mobile_vd_jni.cpp"
log_message "INFO" "Created JNI bridge file for both SDKs"

# Create the Kotlin wrapper
KOTLIN_WRAPPER_CONTENT=$(cat << 'EOF'
package com.llamamobile.vd

/**
 * LlamaMobileVD Android SDK - Kotlin Wrapper
 * A high-performance vector database for Android applications.
 */
class LlamaMobileVD {

    companion object {
        init {
            System.loadLibrary(\"llama_mobile_vd_jni\")
        }
    }

    /**
     * Distance metrics supported by LlamaMobileVD.
     */
    enum class DistanceMetric {
        L2,
        COSINE,
        DOT
    }

    /**
     * Search result containing ID and distance.
     */
    data class SearchResult(val id: Long, val distance: Float)

    /**
     * VectorStore interface for managing vectors in memory.
     */
    class VectorStore(
        dimension: Int,
        metric: DistanceMetric
    ) : AutoCloseable {
        private val handle: Long

        init {
            handle = nativeVectorStoreCreate(dimension, metric.ordinal)
        }

        /**
         * Adds a vector to the store with the specified ID.
         */
        fun add(id: Long, vector: FloatArray) {
            nativeVectorStoreAdd(handle, id, vector)
        }

        /**
         * Removes a vector from the store with the specified ID.
         * @return true if the vector was removed, false otherwise
         */
        fun remove(id: Long): Boolean {
            return nativeVectorStoreRemove(handle, id)
        }

        /**
         * Gets a vector from the store with the specified ID.
         */
        fun get(id: Long): FloatArray {
            return nativeVectorStoreGet(handle, id)
        }

        /**
         * Updates a vector in the store with the specified ID.
         */
        fun update(id: Long, vector: FloatArray) {
            nativeVectorStoreUpdate(handle, id, vector)
        }

        /**
         * Searches for the k nearest neighbors to the query vector.
         */
        fun search(query: FloatArray, k: Int): Array<SearchResult> {
            return nativeVectorStoreSearch(handle, query, k)
        }

        /**
         * Gets the number of vectors in the store.
         */
        fun size(): Int {
            return nativeVectorStoreSize(handle)
        }

        /**
         * Gets the dimension of vectors in the store.
         */
        fun dimension(): Int {
            return nativeVectorStoreDimension(handle)
        }

        /**
         * Gets the distance metric used by the store.
         */
        fun metric(): DistanceMetric {
            return DistanceMetric.values()[nativeVectorStoreMetric(handle)]
        }

        /**
         * Checks if the store contains a vector with the specified ID.
         */
        fun contains(id: Long): Boolean {
            return nativeVectorStoreContains(handle, id)
        }

        /**
         * Reserves capacity for the specified number of vectors.
         */
        fun reserve(capacity: Int) {
            nativeVectorStoreReserve(handle, capacity)
        }

        /**
         * Clears all vectors from the store.
         */
        fun clear() {
            nativeVectorStoreClear(handle)
        }

        /**
         * Releases the native resources.
         */
        override fun close() {
            nativeVectorStoreDestroy(handle)
        }

        private external fun nativeVectorStoreCreate(dimension: Int, metric: Int): Long
        private external fun nativeVectorStoreAdd(handle: Long, id: Long, vector: FloatArray)
        private external fun nativeVectorStoreRemove(handle: Long, id: Long): Boolean
        private external fun nativeVectorStoreGet(handle: Long, id: Long): FloatArray
        private external fun nativeVectorStoreUpdate(handle: Long, id: Long, vector: FloatArray)
        private external fun nativeVectorStoreSearch(handle: Long, query: FloatArray, k: Int): Array<SearchResult>
        private external fun nativeVectorStoreSize(handle: Long): Int
        private external fun nativeVectorStoreDimension(handle: Long): Int
        private external fun nativeVectorStoreMetric(handle: Long): Int
        private external fun nativeVectorStoreContains(handle: Long, id: Long): Boolean
        private external fun nativeVectorStoreReserve(handle: Long, capacity: Int)
        private external fun nativeVectorStoreClear(handle: Long)
        private external fun nativeVectorStoreDestroy(handle: Long)
    }

    /**
     * HNSWIndex interface for efficient approximate nearest neighbor search.
     */
    class HNSWIndex private constructor(private val handle: Long) : AutoCloseable {
        /**
         * Creates a new HNSWIndex with default parameters.
         */
        constructor(
            dimension: Int,
            metric: DistanceMetric,
            maxElements: Int
        ) : this(nativeHNSWIndexCreate(dimension, metric.ordinal, maxElements))

        /**
         * Creates a new HNSWIndex with custom parameters.
         */
        constructor(
            dimension: Int,
            metric: DistanceMetric,
            maxElements: Int,
            M: Int,
            efConstruction: Int,
            seed: Int
        ) : this(nativeHNSWIndexCreateWithParams(dimension, metric.ordinal, maxElements, M, efConstruction, seed))

        /**
         * Adds a vector to the index with the specified ID.
         */
        fun add(id: Long, vector: FloatArray) {
            nativeHNSWIndexAdd(handle, id, vector)
        }

        /**
         * Searches for the k nearest neighbors to the query vector.
         */
        fun search(query: FloatArray, k: Int): Array<SearchResult> {
            return nativeHNSWIndexSearch(handle, query, k)
        }

        /**
         * Sets the ef_search parameter for the index.
         */
        fun setEfSearch(efSearch: Int) {
            nativeHNSWIndexSetEfSearch(handle, efSearch)
        }

        /**
         * Gets the current ef_search parameter value.
         */
        fun getEfSearch(): Int {
            return nativeHNSWIndexGetEfSearch(handle)
        }

        /**
         * Gets the number of vectors in the index.
         */
        fun size(): Int {
            return nativeHNSWIndexSize(handle)
        }

        /**
         * Gets the dimension of vectors in the index.
         */
        fun dimension(): Int {
            return nativeHNSWIndexDimension(handle)
        }

        /**
         * Gets the capacity of the index.
         */
        fun capacity(): Int {
            return nativeHNSWIndexCapacity(handle)
        }

        /**
         * Checks if the index contains a vector with the specified ID.
         */
        fun contains(id: Long): Boolean {
            return nativeHNSWIndexContains(handle, id)
        }

        /**
         * Gets a vector from the index with the specified ID.
         */
        fun getVector(id: Long): FloatArray {
            return nativeHNSWIndexGetVector(handle, id)
        }

        /**
         * Saves the index to a file.
         */
        fun save(filename: String) {
            nativeHNSWIndexSave(handle, filename)
        }

        /**
         * Releases the native resources.
         */
        override fun close() {
            nativeHNSWIndexDestroy(handle)
        }

        companion object {
            /**
             * Loads an HNSWIndex from a file.
             */
            fun load(filename: String): HNSWIndex {
                val handle = nativeHNSWIndexLoad(filename)
                return HNSWIndex(handle)
            }
        }

        private external fun nativeHNSWIndexCreate(dimension: Int, metric: Int, maxElements: Int): Long
        private external fun nativeHNSWIndexCreateWithParams(dimension: Int, metric: Int, maxElements: Int, M: Int, efConstruction: Int, seed: Int): Long
        private external fun nativeHNSWIndexAdd(handle: Long, id: Long, vector: FloatArray)
        private external fun nativeHNSWIndexSearch(handle: Long, query: FloatArray, k: Int): Array<SearchResult>
        private external fun nativeHNSWIndexSetEfSearch(handle: Long, efSearch: Int)
        private external fun nativeHNSWIndexGetEfSearch(handle: Long): Int
        private external fun nativeHNSWIndexSize(handle: Long): Int
        private external fun nativeHNSWIndexDimension(handle: Long): Int
        private external fun nativeHNSWIndexCapacity(handle: Long): Int
        private external fun nativeHNSWIndexContains(handle: Long, id: Long): Boolean
        private external fun nativeHNSWIndexGetVector(handle: Long, id: Long): FloatArray
        private external fun nativeHNSWIndexSave(handle: Long, filename: String)
        private external fun nativeHNSWIndexLoad(filename: String): Long
        private external fun nativeHNSWIndexDestroy(handle: Long)
    }

    /**
     * MMapVectorStoreBuilder for creating memory-mapped vector stores on disk.
     */
    class MMapVectorStoreBuilder(dimension: Int, metric: DistanceMetric) : AutoCloseable {
        private val handle: Long

        init {
            handle = nativeMMapVectorStoreBuilderCreate(dimension, metric.ordinal)
        }

        /**
         * Adds a vector to the builder.
         */
        fun add(id: Long, vector: FloatArray) {
            nativeMMapVectorStoreBuilderAdd(handle, id, vector)
        }

        /**
         * Reserves capacity for the specified number of vectors.
         */
        fun reserve(capacity: Int) {
            nativeMMapVectorStoreBuilderReserve(handle, capacity)
        }

        /**
         * Saves the builder to a file.
         */
        fun save(filename: String) {
            nativeMMapVectorStoreBuilderSave(handle, filename)
        }

        /**
         * Gets the number of vectors in the builder.
         */
        fun size(): Int {
            return nativeMMapVectorStoreBuilderSize(handle)
        }

        /**
         * Gets the dimension of vectors in the builder.
         */
        fun dimension(): Int {
            return nativeMMapVectorStoreBuilderDimension(handle)
        }

        override fun close() {
            nativeMMapVectorStoreBuilderDestroy(handle)
        }

        private external fun nativeMMapVectorStoreBuilderCreate(dimension: Int, metric: Int): Long
        private external fun nativeMMapVectorStoreBuilderAdd(handle: Long, id: Long, vector: FloatArray)
        private external fun nativeMMapVectorStoreBuilderReserve(handle: Long, capacity: Int)
        private external fun nativeMMapVectorStoreBuilderSave(handle: Long, filename: String)
        private external fun nativeMMapVectorStoreBuilderSize(handle: Long): Int
        private external fun nativeMMapVectorStoreBuilderDimension(handle: Long): Int
        private external fun nativeMMapVectorStoreBuilderDestroy(handle: Long)
    }

    /**
     * MMapVectorStore for accessing memory-mapped vector stores on disk.
     */
    class MMapVectorStore(filename: String) : AutoCloseable {
        private val handle: Long

        init {
            handle = nativeMMapVectorStoreOpen(filename)
        }

        /**
         * Gets a vector by its ID.
         */
        fun get(id: Long): FloatArray {
            return nativeMMapVectorStoreGet(handle, id)
        }

        /**
         * Checks if a vector with the specified ID exists.
         */
        fun contains(id: Long): Boolean {
            return nativeMMapVectorStoreContains(handle, id)
        }

        /**
         * Searches for the k nearest neighbors to the query vector.
         */
        fun search(query: FloatArray, k: Int): Array<SearchResult> {
            return nativeMMapVectorStoreSearch(handle, query, k)
        }

        /**
         * Gets the number of vectors in the store.
         */
        fun size(): Int {
            return nativeMMapVectorStoreSize(handle)
        }

        /**
         * Gets the dimension of vectors in the store.
         */
        fun dimension(): Int {
            return nativeMMapVectorStoreDimension(handle)
        }

        /**
         * Gets the distance metric used by the store.
         */
        fun metric(): DistanceMetric {
            return DistanceMetric.values()[nativeMMapVectorStoreMetric(handle)]
        }

        override fun close() {
            nativeMMapVectorStoreClose(handle)
        }

        private external fun nativeMMapVectorStoreOpen(filename: String): Long
        private external fun nativeMMapVectorStoreGet(handle: Long, id: Long): FloatArray
        private external fun nativeMMapVectorStoreContains(handle: Long, id: Long): Boolean
        private external fun nativeMMapVectorStoreSearch(handle: Long, query: FloatArray, k: Int): Array<SearchResult>
        private external fun nativeMMapVectorStoreSize(handle: Long): Int
        private external fun nativeMMapVectorStoreDimension(handle: Long): Int
        private external fun nativeMMapVectorStoreMetric(handle: Long): Int
        private external fun nativeMMapVectorStoreClose(handle: Long)
    }

    /**
     * Exception thrown by LlamaMobileVD operations.
     */
    class LlamaMobileVDException(message: String) : Exception(message)

    /**
     * Gets the version of the LlamaMobileVD library.
     */
    companion object {
        @JvmStatic
        external fun getVersion(): String
    }

    // Native methods
    private external fun nativeGetVersion(): String
}
EOF
)

# Write Kotlin wrapper
echo "$KOTLIN_WRAPPER_CONTENT" > "$KOTLIN_SDK_DIR/src/main/java/com/llamamobile/vd/LlamaMobileVD.kt"
log_message "INFO" "Created Kotlin wrapper"

# Create the Java wrapper
JAVA_WRAPPER_CONTENT=$(cat << 'EOF'
package com.llamamobile.vd;

/**
 * LlamaMobileVD Android SDK - Java Wrapper
 * A high-performance vector database for Android applications.
 */
public class LlamaMobileVD {

    static {
        System.loadLibrary(\"llama_mobile_vd_jni\");
    }

    /**
     * Distance metrics supported by LlamaMobileVD.
     */
    public enum DistanceMetric {
        L2,
        COSINE,
        DOT
    }

    /**
     * Search result containing ID and distance.
     */
    public static class SearchResult {
        public final long id;
        public final float distance;

        public SearchResult(long id, float distance) {
            this.id = id;
            this.distance = distance;
        }

        @Override
        public String toString() {
            return \"SearchResult{id=\" + id + \", distance=\" + distance + \"}\";
        }
    }

    /**
     * VectorStore interface for managing vectors in memory.
     */
    public static class VectorStore implements AutoCloseable {
        private final long handle;

        /**
         * Creates a new VectorStore.
         * @param dimension Dimension of vectors
         * @param metric Distance metric to use
         */
        public VectorStore(int dimension, DistanceMetric metric) {
            this.handle = nativeVectorStoreCreate(dimension, metric.ordinal());
        }

        /**
         * Adds a vector to the store with the specified ID.
         * @param id Unique identifier for the vector
         * @param vector Vector data
         */
        public void add(long id, float[] vector) {
            nativeVectorStoreAdd(handle, id, vector);
        }

        /**
         * Removes a vector from the store with the specified ID.
         * @param id Unique identifier for the vector
         * @return true if the vector was removed, false otherwise
         */
        public boolean remove(long id) {
            return nativeVectorStoreRemove(handle, id);
        }

        /**
         * Gets a vector from the store with the specified ID.
         * @param id Unique identifier for the vector
         * @return Vector data
         */
        public float[] get(long id) {
            return nativeVectorStoreGet(handle, id);
        }

        /**
         * Updates a vector in the store with the specified ID.
         * @param id Unique identifier for the vector
         * @param vector Vector data
         */
        public void update(long id, float[] vector) {
            nativeVectorStoreUpdate(handle, id, vector);
        }

        /**
         * Searches for the k nearest neighbors to the query vector.
         * @param query Query vector
         * @param k Number of results to return
         * @return Array of SearchResult objects
         */
        public SearchResult[] search(float[] query, int k) {
            return nativeVectorStoreSearch(handle, query, k);
        }

        /**
         * Gets the number of vectors in the store.
         * @return Number of vectors
         */
        public int size() {
            return nativeVectorStoreSize(handle);
        }

        /**
         * Gets the dimension of vectors in the store.
         * @return Vector dimension
         */
        public int dimension() {
            return nativeVectorStoreDimension(handle);
        }

        /**
         * Gets the distance metric used by the store.
         * @return Distance metric
         */
        public DistanceMetric metric() {
            return DistanceMetric.values()[nativeVectorStoreMetric(handle)];
        }

        /**
         * Checks if the store contains a vector with the specified ID.
         * @param id Unique identifier for the vector
         * @return true if the vector exists, false otherwise
         */
        public boolean contains(long id) {
            return nativeVectorStoreContains(handle, id);
        }

        /**
         * Reserves capacity for the specified number of vectors.
         * @param capacity Number of vectors to reserve capacity for
         */
        public void reserve(int capacity) {
            nativeVectorStoreReserve(handle, capacity);
        }

        /**
         * Clears all vectors from the store.
         */
        public void clear() {
            nativeVectorStoreClear(handle);
        }

        @Override
        public void close() {
            nativeVectorStoreDestroy(handle);
        }

        private native long nativeVectorStoreCreate(int dimension, int metric);
        private native void nativeVectorStoreAdd(long handle, long id, float[] vector);
        private native boolean nativeVectorStoreRemove(long handle, long id);
        private native float[] nativeVectorStoreGet(long handle, long id);
        private native void nativeVectorStoreUpdate(long handle, long id, float[] vector);
        private native SearchResult[] nativeVectorStoreSearch(long handle, float[] query, int k);
        private native int nativeVectorStoreSize(long handle);
        private native int nativeVectorStoreDimension(long handle);
        private native int nativeVectorStoreMetric(long handle);
        private native boolean nativeVectorStoreContains(long handle, long id);
        private native void nativeVectorStoreReserve(long handle, int capacity);
        private native void nativeVectorStoreClear(long handle);
        private native void nativeVectorStoreDestroy(long handle);
    }

    /**
     * HNSWIndex interface for efficient approximate nearest neighbor search.
     */
    public static class HNSWIndex implements AutoCloseable {
        private final long handle;

        /**
         * Private constructor to create an HNSWIndex with an existing handle.
         * @param handle Native handle to the HNSWIndex
         */
        private HNSWIndex(long handle) {
            this.handle = handle;
        }

        /**
         * Creates a new HNSWIndex with default parameters.
         * @param dimension Dimension of vectors
         * @param metric Distance metric to use
         * @param maxElements Maximum number of elements the index can hold
         */
        public HNSWIndex(int dimension, DistanceMetric metric, int maxElements) {
            this.handle = nativeHNSWIndexCreate(dimension, metric.ordinal(), maxElements);
        }

        /**
         * Creates a new HNSWIndex with custom parameters.
         * @param dimension Dimension of vectors
         * @param metric Distance metric to use
         * @param maxElements Maximum number of elements the index can hold
         * @param M Maximum number of connections per node
         * @param efConstruction Construction-time ef parameter
         * @param seed Random seed for index construction
         */
        public HNSWIndex(int dimension, DistanceMetric metric, int maxElements, int M, int efConstruction, int seed) {
            this.handle = nativeHNSWIndexCreateWithParams(dimension, metric.ordinal(), maxElements, M, efConstruction, seed);
        }

        /**
         * Adds a vector to the index with the specified ID.
         * @param id Unique identifier for the vector
         * @param vector Vector data
         */
        public void add(long id, float[] vector) {
            nativeHNSWIndexAdd(handle, id, vector);
        }

        /**
         * Searches for the k nearest neighbors to the query vector.
         * @param query Query vector
         * @param k Number of results to return
         * @return Array of SearchResult objects
         */
        public SearchResult[] search(float[] query, int k) {
            return nativeHNSWIndexSearch(handle, query, k);
        }

        /**
         * Sets the ef_search parameter for the index.
         * @param efSearch The ef_search parameter value
         */
        public void setEfSearch(int efSearch) {
            nativeHNSWIndexSetEfSearch(handle, efSearch);
        }

        /**
         * Gets the current ef_search parameter value.
         * @return The ef_search parameter value
         */
        public int getEfSearch() {
            return nativeHNSWIndexGetEfSearch(handle);
        }

        /**
         * Gets the number of vectors in the index.
         * @return Number of vectors
         */
        public int size() {
            return nativeHNSWIndexSize(handle);
        }

        /**
         * Gets the dimension of vectors in the index.
         * @return Vector dimension
         */
        public int dimension() {
            return nativeHNSWIndexDimension(handle);
        }

        /**
         * Gets the capacity of the index.
         * @return Index capacity
         */
        public int capacity() {
            return nativeHNSWIndexCapacity(handle);
        }

        /**
         * Checks if the index contains a vector with the specified ID.
         * @param id Unique identifier for the vector
         * @return true if the vector exists, false otherwise
         */
        public boolean contains(long id) {
            return nativeHNSWIndexContains(handle, id);
        }

        /**
         * Gets a vector from the index with the specified ID.
         * @param id Unique identifier for the vector
         * @return Vector data
         */
        public float[] getVector(long id) {
            return nativeHNSWIndexGetVector(handle, id);
        }

        /**
         * Saves the index to a file.
         * @param filename Path to the file
         */
        public void save(String filename) {
            nativeHNSWIndexSave(handle, filename);
        }

        /**
         * Loads an HNSWIndex from a file.
         * @param filename Path to the file
         * @return HNSWIndex instance
         */
        public static HNSWIndex load(String filename) {
            long handle = nativeHNSWIndexLoad(filename);
            return new HNSWIndex(handle);
        }

        @Override
        public void close() {
            nativeHNSWIndexDestroy(handle);
        }

        private native long nativeHNSWIndexCreate(int dimension, int metric, int maxElements);
        private native long nativeHNSWIndexCreateWithParams(int dimension, int metric, int maxElements, int M, int efConstruction, int seed);
        private native void nativeHNSWIndexAdd(long handle, long id, float[] vector);
        private native SearchResult[] nativeHNSWIndexSearch(long handle, float[] query, int k);
        private native void nativeHNSWIndexSetEfSearch(long handle, int efSearch);
        private native int nativeHNSWIndexGetEfSearch(long handle);
        private native int nativeHNSWIndexSize(long handle);
        private native int nativeHNSWIndexDimension(long handle);
        private native int nativeHNSWIndexCapacity(long handle);
        private native boolean nativeHNSWIndexContains(long handle, long id);
        private native float[] nativeHNSWIndexGetVector(long handle, long id);
        private native void nativeHNSWIndexSave(long handle, String filename);
        private native long nativeHNSWIndexLoad(String filename);
        private native void nativeHNSWIndexDestroy(long handle);
    }

    /**
     * MMapVectorStoreBuilder for creating memory-mapped vector stores on disk.
     */
    public static class MMapVectorStoreBuilder implements AutoCloseable {
        private final long handle;

        /**
         * Creates a new MMapVectorStoreBuilder.
         * @param dimension Dimension of vectors
         * @param metric Distance metric to use
         */
        public MMapVectorStoreBuilder(int dimension, DistanceMetric metric) {
            this.handle = nativeMMapVectorStoreBuilderCreate(dimension, metric.ordinal());
        }

        /**
         * Adds a vector to the builder.
         * @param id Unique identifier for the vector
         * @param vector Vector data
         */
        public void add(long id, float[] vector) {
            nativeMMapVectorStoreBuilderAdd(handle, id, vector);
        }

        /**
         * Reserves capacity for the specified number of vectors.
         * @param capacity Capacity to reserve
         */
        public void reserve(int capacity) {
            nativeMMapVectorStoreBuilderReserve(handle, capacity);
        }

        /**
         * Saves the builder to a file.
         * @param filename Path to save the vector store
         */
        public void save(String filename) {
            nativeMMapVectorStoreBuilderSave(handle, filename);
        }

        /**
         * Gets the number of vectors in the builder.
         * @return Number of vectors
         */
        public int size() {
            return nativeMMapVectorStoreBuilderSize(handle);
        }

        /**
         * Gets the dimension of vectors in the builder.
         * @return Vector dimension
         */
        public int dimension() {
            return nativeMMapVectorStoreBuilderDimension(handle);
        }

        @Override
        public void close() {
            nativeMMapVectorStoreBuilderDestroy(handle);
        }

        private native long nativeMMapVectorStoreBuilderCreate(int dimension, int metric);
        private native void nativeMMapVectorStoreBuilderAdd(long handle, long id, float[] vector);
        private native void nativeMMapVectorStoreBuilderReserve(long handle, int capacity);
        private native void nativeMMapVectorStoreBuilderSave(long handle, String filename);
        private native int nativeMMapVectorStoreBuilderSize(long handle);
        private native int nativeMMapVectorStoreBuilderDimension(long handle);
        private native void nativeMMapVectorStoreBuilderDestroy(long handle);
    }

    /**
     * MMapVectorStore for accessing memory-mapped vector stores on disk.
     */
    public static class MMapVectorStore implements AutoCloseable {
        private final long handle;

        /**
         * Opens an existing MMapVectorStore.
         * @param filename Path to the vector store file
         */
        public MMapVectorStore(String filename) {
            this.handle = nativeMMapVectorStoreOpen(filename);
        }

        /**
         * Gets a vector by its ID.
         * @param id ID of the vector to retrieve
         * @return The vector
         */
        public float[] get(long id) {
            return nativeMMapVectorStoreGet(handle, id);
        }

        /**
         * Checks if a vector with the specified ID exists.
         * @param id ID to check
         * @return True if the vector exists, false otherwise
         */
        public boolean contains(long id) {
            return nativeMMapVectorStoreContains(handle, id);
        }

        /**
         * Searches for the k nearest neighbors to the query vector.
         * @param query Query vector
         * @param k Number of results to return
         * @return Array of SearchResult objects
         */
        public SearchResult[] search(float[] query, int k) {
            return nativeMMapVectorStoreSearch(handle, query, k);
        }

        /**
         * Gets the number of vectors in the store.
         * @return Number of vectors
         */
        public int size() {
            return nativeMMapVectorStoreSize(handle);
        }

        /**
         * Gets the dimension of vectors in the store.
         * @return Vector dimension
         */
        public int dimension() {
            return nativeMMapVectorStoreDimension(handle);
        }

        /**
         * Gets the distance metric used by the store.
         * @return Distance metric
         */
        public DistanceMetric metric() {
            return DistanceMetric.values()[nativeMMapVectorStoreMetric(handle)];
        }

        @Override
        public void close() {
            nativeMMapVectorStoreClose(handle);
        }

        private native long nativeMMapVectorStoreOpen(String filename);
        private native float[] nativeMMapVectorStoreGet(long handle, long id);
        private native boolean nativeMMapVectorStoreContains(long handle, long id);
        private native SearchResult[] nativeMMapVectorStoreSearch(long handle, float[] query, int k);
        private native int nativeMMapVectorStoreSize(long handle);
        private native int nativeMMapVectorStoreDimension(long handle);
        private native int nativeMMapVectorStoreMetric(long handle);
        private native void nativeMMapVectorStoreClose(long handle);
    }

    /**
     * Exception thrown by LlamaMobileVD operations.
     */
    public static class LlamaMobileVDException extends RuntimeException {
        public LlamaMobileVDException(String message) {
            super(message);
        }
    }

    /**
     * Gets the version of the LlamaMobileVD library.
     * @return Version string
     */
    public static native String getVersion();

    // Version method wrapper
    private native static String nativeGetVersion();
}
EOF
)

# Write Java wrapper
echo "$JAVA_WRAPPER_CONTENT" > "$JAVA_SDK_DIR/src/main/java/com/llamamobile/vd/LlamaMobileVD.java"
log_message "INFO" "Created Java wrapper"

# Create AndroidManifest.xml for both SDKs
MANIFEST_CONTENT="<?xml version=\"1.0\" encoding=\"utf-8\"?>
<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\" 
    package=\"com.llamamobile.qdb\">

    <uses-sdk
        android:minSdkVersion=\"21\" 
        android:targetSdkVersion=\"34\" />
</manifest>";

echo "$MANIFEST_CONTENT" > "$KOTLIN_SDK_DIR/src/main/AndroidManifest.xml"
echo "$MANIFEST_CONTENT" > "$JAVA_SDK_DIR/src/main/AndroidManifest.xml"
log_message "INFO" "Created AndroidManifest.xml for both SDKs"

# Create build.gradle for Kotlin SDK
KOTLIN_BUILD_GRADLE="plugins {
    id 'com.android.library'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.llamamobile.vd'
    compileSdk 36
    buildToolsVersion \"36.1.0\"

    defaultConfig {
        minSdk 21
        targetSdk 36

        testInstrumentationRunner \"androidx.test.runner.AndroidJUnitRunner\"
        consumerProguardFiles \"consumer-rules.pro\"
        
        ndk {
            abiFilters 'arm64-v8a', 'x86_64'
            stl \"c++_shared\"
        }
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = '1.8'
    }

    externalNativeBuild {
        cmake {
            path \"src/main/cpp/CMakeLists.txt\"
            version \"3.18.1\"
        }
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}"

echo "$KOTLIN_BUILD_GRADLE" > "$KOTLIN_SDK_DIR/build.gradle"

# Create build.gradle for Java SDK
JAVA_BUILD_GRADLE="plugins {
    id 'com.android.library'
}

android {
    namespace 'com.llamamobile.qdb'
    compileSdk 36
    buildToolsVersion \"36.1.0\"

    defaultConfig {
        minSdk 21
        targetSdk 36

        testInstrumentationRunner \"androidx.test.runner.AndroidJUnitRunner\"
        consumerProguardFiles \"consumer-rules.pro\"
        
        ndk {
            abiFilters 'arm64-v8a', 'x86_64'
            stl \"c++_shared\"
        }
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    externalNativeBuild {
        cmake {
            path \"src/main/cpp/CMakeLists.txt\"
            version \"3.18.1\"
        }
    }
}

dependencies {
    implementation 'androidx.core:core:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}"

echo "$JAVA_BUILD_GRADLE" > "$JAVA_SDK_DIR/build.gradle"
log_message "INFO" "Created build.gradle files for both SDKs"

# Create settings.gradle for both SDKs
SETTINGS_GRADLE="pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id 'com.android.library' version '8.5.0'
        id 'org.jetbrains.kotlin.android' version '1.9.20'
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = \"llama_mobile_vd\""

echo "$SETTINGS_GRADLE" > "$KOTLIN_SDK_DIR/settings.gradle"
echo "$SETTINGS_GRADLE" > "$JAVA_SDK_DIR/settings.gradle"
log_message "INFO" "Created settings.gradle files for both SDKs"

# Create README.md for both SDKs
cat > "$KOTLIN_SDK_DIR/README.md" << 'EOF'
# LlamaMobileVD Android SDK

A high-performance vector database library for Android applications, providing efficient storage and similarity search capabilities.

## Features

- **Efficient Similarity Search**: Fast nearest neighbor search using HNSW (Hierarchical Navigable Small World) algorithm
- **Multiple Distance Metrics**: Support for L2, Cosine, and Dot product distances
- **In-Memory Storage**: VectorStore for managing vectors in memory
- **JNI Integration**: Native C++ implementation for maximum performance
- **Kotlin & Java Support**: Available in both programming languages
- **Android Optimized**: Designed for Android platform with NEON SIMD support

## Installation

### Option 1: Import as Module in Android Studio

1. Open your Android project in Android Studio
2. Select `File > New > Import Module`
3. Navigate to the SDK directory (`llama_mobile_vd-android-SDK` or `llama_mobile_vd-android-java-SDK`)
4. Click `Finish` to import
5. Add the dependency in your app's build.gradle:

```gradle
implementation project(":llama_mobile_vd-android-SDK")  // For Kotlin
// or
implementation project(":llama_mobile_vd-android-java-SDK")  // For Java
```

## Usage

### Kotlin Example

```kotlin
import com.llamamobile.qdb.LLAMA_MOBILE_VD

// Create a VectorStore with L2 distance metric
val vectorStore = LlamaMobileVD.VectorStore(
    dimension = 128,
    metric = LlamaMobileVD.DistanceMetric.L2
)

// Add vectors
val vector1 = FloatArray(128) { Math.random().toFloat() }
val vector2 = FloatArray(128) { Math.random().toFloat() }
vectorStore.add(1L, vector1)
vectorStore.add(2L, vector2)

// Search for nearest neighbors
val queryVector = FloatArray(128) { Math.random().toFloat() }
val results = vectorStore.search(queryVector, k = 10)

// Print results
results.forEachIndexed { index, result ->
    println(\"Result \$index: ID=\" + result.id + \", Distance=\" + result.distance)
}

// Close the store when done
vectorStore.close()
```

### Java Example

```java
import com.llamamobile.qdb.LLAMA_MOBILE_VD;

// Create a VectorStore with L2 distance metric
LlamaMobileVD.VectorStore vectorStore = new LlamaMobileVD.VectorStore(
    128,
    LlamaMobileVD.DistanceMetric.L2
);

// Add vectors
float[] vector1 = new float[128];
float[] vector2 = new float[128];
for (int i = 0; i < 128; i++) {
    vector1[i] = (float) Math.random();
    vector2[i] = (float) Math.random();
}
vectorStore.add(1L, vector1);
vectorStore.add(2L, vector2);

// Search for nearest neighbors
float[] queryVector = new float[128];
for (int i = 0; i < 128; i++) {
    queryVector[i] = (float) Math.random();
}
LlamaMobileVD.SearchResult[] results = vectorStore.search(queryVector, 10);

// Print results
for (int i = 0; i < results.length; i++) {
    System.out.println(\"Result \" + i + \": ID=\" + results[i].id + \", Distance=\" + results[i].distance);
}

// Close the store when done
vectorStore.close();
```

### HNSW Index Example

```kotlin
// Create an HNSW index with maximum 1000 elements
val hnswIndex = LlamaMobileVD.HNSWIndex(
    dimension = 128,
    metric = LlamaMobileVD.DistanceMetric.COSINE,
    maxElements = 1000
)

// Add vectors and search as with VectorStore
// ...

// Close the index when done
hnswIndex.close()
```

## API Reference

### DistanceMetric
- `L2`: Euclidean distance
- `COSINE`: Cosine similarity
- `DOT`: Dot product

### VectorStore
- `add(id: Long, vector: FloatArray)`: Adds a vector to the store
- `search(query: FloatArray, k: Int)`: Searches for k nearest neighbors
- `close()`: Releases native resources

### HNSWIndex
- `add(id: Long, vector: FloatArray)`: Adds a vector to the index
- `search(query: FloatArray, k: Int)`: Searches for k nearest neighbors
- `close()`: Releases native resources

## Performance Notes

- The library is optimized for ARM64 architecture with NEON SIMD instructions
- HNSW index provides faster search performance for large datasets compared to brute-force search
- For optimal performance, match the vector dimension to your use case (common dimensions: 128, 256, 512, 1024)

## Testing

The SDK includes both unit tests and instrumented tests:

### Running Unit Tests

```bash
cd llama_mobile_vd-android-SDK
./gradlew test
```

### Running Instrumented Tests

```bash
cd llama_mobile_vd-android-SDK
./gradlew connectedAndroidTest
```

## License

MIT License - see LICENSE file for details.
EOF

# Copy README to Java SDK as well
cp "$KOTLIN_SDK_DIR/README.md" "$JAVA_SDK_DIR/README.md"
log_message "INFO" "Created README.md for both SDKs"

# Create proguard files
PROGUARD_CONTENT="# ProGuard rules for LlamaMobileVD Android SDK
# Add project specific ProGuard rules here.

# Keep all public classes and methods in the SDK
dontwarn com.llamamobile.qdb.**
-keep class com.llamamobile.qdb.** { *; }";

echo "$PROGUARD_CONTENT" > "$KOTLIN_SDK_DIR/proguard-rules.pro"
echo "$PROGUARD_CONTENT" > "$JAVA_SDK_DIR/proguard-rules.pro"
echo "$PROGUARD_CONTENT" > "$KOTLIN_SDK_DIR/consumer-rules.pro"
echo "$PROGUARD_CONTENT" > "$JAVA_SDK_DIR/consumer-rules.pro"
log_message "INFO" "Created proguard files for both SDKs"

# Create test directories and files

# Kotlin Unit Tests
mkdir -p "$KOTLIN_SDK_DIR/src/test/java/com/llamamobile/vd"
kotlin_unit_test="package com.llamamobile.vd

import org.junit.Assert.*
import org.junit.Test
import org.mockito.Mockito.mock

/**
 * Unit tests for LlamaMobileVD Android SDK (Kotlin)
 * Runs on the JVM, not on an Android device.
 */
class LlamaMobileVDUnitTests {

    @Test
    fun testDistanceMetricEnum() {
        // Test that DistanceMetric enum values are correctly defined
        assertEquals(0, LlamaMobileVD.DistanceMetric.L2.ordinal)
        assertEquals(1, LlamaMobileVD.DistanceMetric.COSINE.ordinal)
        assertEquals(2, LlamaMobileVD.DistanceMetric.DOT.ordinal)
    }

    @Test
    fun testSearchResultEquality() {
        // Test SearchResult data class equality
        val result1 = LlamaMobileVD.SearchResult(1L, 0.5f)
        val result2 = LlamaMobileVD.SearchResult(1L, 0.5f)
        val result3 = LlamaMobileVD.SearchResult(2L, 0.5f)
        val result4 = LlamaMobileVD.SearchResult(1L, 1.0f)

        assertEquals(result1, result2)
        assertNotEquals(result1, result3)
        assertNotEquals(result1, result4)
    }

    @Test
    fun testSearchResultToString() {
        // Test SearchResult string representation
        val result = LlamaMobileVD.SearchResult(123L, 0.75f)
        val resultStr = result.toString()
        
        assertTrue(resultStr.contains(\"id=123\"))
        assertTrue(resultStr.contains(\"distance=0.75\"))
    }

    @Test
    fun testSearchResultHashCode() {
        // Test SearchResult hash code generation
        val result1 = LlamaMobileVD.SearchResult(1L, 0.5f)
        val result2 = LlamaMobileVD.SearchResult(1L, 0.5f)
        val result3 = LlamaMobileVD.SearchResult(2L, 0.5f)

        assertEquals(result1.hashCode(), result2.hashCode())
        assertNotEquals(result1.hashCode(), result3.hashCode())
    }

    @Test
    fun testLlamaMobileVDException() {
        // Test LlamaMobileVDException class
        val exception = LlamaMobileVD.LlamaMobileVDException(\"Test error message\")
        assertEquals(\"Test error message\", exception.message)
        assertTrue(exception is Exception)
    }

    @Test
    fun testAllDistanceMetrics() {
        // Test that all distance metrics can be instantiated
        val metrics = LlamaMobileVD.DistanceMetric.values()
        assertEquals(3, metrics.size)
        
        // Verify all enum values exist
        assertTrue(metrics.contains(LlamaMobileVD.DistanceMetric.L2))
        assertTrue(metrics.contains(LlamaMobileVD.DistanceMetric.COSINE))
        assertTrue(metrics.contains(LlamaMobileVD.DistanceMetric.DOT))
    }
}"

# Java Unit Tests
mkdir -p "$JAVA_SDK_DIR/src/test/java/com/llamamobile/vd"
java_unit_test="package com.llamamobile.vd;

import org.junit.Assert;
import org.junit.Test;

/**
 * Unit tests for LlamaMobileVD Android SDK (Java)
 * Runs on the JVM, not on an Android device.
 */
public class LlamaMobileVDUnitTests {

    @Test
    public void testDistanceMetricEnum() {
        // Test that DistanceMetric enum values are correctly defined
        Assert.assertEquals(0, LlamaMobileVD.DistanceMetric.L2.ordinal());
        Assert.assertEquals(1, LlamaMobileVD.DistanceMetric.COSINE.ordinal());
        Assert.assertEquals(2, LlamaMobileVD.DistanceMetric.DOT.ordinal());
    }

    @Test
    public void testSearchResultEquality() {
        // Test SearchResult object equality
        LlamaMobileVD.SearchResult result1 = new LlamaMobileVD.SearchResult(1L, 0.5f);
        LlamaMobileVD.SearchResult result2 = new LlamaMobileVD.SearchResult(1L, 0.5f);
        LlamaMobileVD.SearchResult result3 = new LlamaMobileVD.SearchResult(2L, 0.5f);
        LlamaMobileVD.SearchResult result4 = new LlamaMobileVD.SearchResult(1L, 1.0f);

        // Since SearchResult doesn't override equals(), we test fields directly
        Assert.assertEquals(result1.id, result2.id);
        Assert.assertEquals(result1.distance, result2.distance, 0.0001f);
        Assert.assertNotEquals(result1.id, result3.id);
        Assert.assertNotEquals(result1.distance, result4.distance, 0.0001f);
    }

    @Test
    public void testSearchResultAccessors() {
        // Test SearchResult getters
        LlamaMobileVD.SearchResult result = new LlamaMobileVD.SearchResult(123L, 0.75f);
        Assert.assertEquals(123L, result.id);
        Assert.assertEquals(0.75f, result.distance, 0.0001f);
    }

    @Test
    public void testLlamaMobileVDException() {
        // Test LlamaMobileVDException class
        LlamaMobileVD.LlamaMobileVDException exception = new LlamaMobileVD.LlamaMobileVDException(\"Test error message\");
        Assert.assertEquals(\"Test error message\", exception.getMessage());
        Assert.assertTrue(exception instanceof Exception);
    }

    @Test
    public void testAllDistanceMetrics() {
        // Test that all distance metrics can be accessed
        LlamaMobileVD.DistanceMetric[] metrics = LlamaMobileVD.DistanceMetric.values();
        Assert.assertEquals(3, metrics.length);
        
        // Verify all enum values exist
        boolean foundL2 = false;
        boolean foundCosine = false;
        boolean foundDot = false;
        
        for (LlamaMobileVD.DistanceMetric metric : metrics) {
            if (metric == LlamaMobileVD.DistanceMetric.L2) foundL2 = true;
            if (metric == LlamaMobileVD.DistanceMetric.COSINE) foundCosine = true;
            if (metric == LlamaMobileVD.DistanceMetric.DOT) foundDot = true;
        }
        
        Assert.assertTrue(foundL2);
        Assert.assertTrue(foundCosine);
        Assert.assertTrue(foundDot);
    }

    @Test
    public void testDistanceMetricNames() {
        // Test that distance metrics have correct names
        Assert.assertEquals("L2", LlamaMobileVD.DistanceMetric.L2.name());
        Assert.assertEquals("COSINE", LlamaMobileVD.DistanceMetric.COSINE.name());
        Assert.assertEquals("DOT", LlamaMobileVD.DistanceMetric.DOT.name());
    }
}"

# Kotlin Instrumented Tests
mkdir -p "$KOTLIN_SDK_DIR/src/androidTest/java/com/llamamobile/vd"
kotlin_instrumented_test="package com.llamamobile.vd

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Instrumented test for LlamaMobileVD Android SDK (Kotlin)
 * Runs on an Android device or emulator.
 */
@RunWith(AndroidJUnit4::class)
class LlamaMobileVDInstrumentedTests {
    private val appContext = InstrumentationRegistry.getInstrumentation().targetContext

    @Test
    fun testVectorStoreCreation() {
        // Test that VectorStore can be created
        val vectorStore = LlamaMobileVD.VectorStore(
            dimension = 128,
            metric = LlamaMobileVD.DistanceMetric.L2
        )
        assertNotNull(vectorStore)
    }

    @Test
    fun testVectorStoreAddAndSearch() {
        // Test adding vectors and searching
        val dimension = 32
        val vectorStore = LlamaMobileVD.VectorStore(
            dimension = dimension,
            metric = LlamaMobileVD.DistanceMetric.L2
        )

        // Create test vectors
        val vector1 = FloatArray(dimension) { 1.0f }
        val vector2 = FloatArray(dimension) { 2.0f }

        // Add vectors
        vectorStore.add(1L, vector1)
        vectorStore.add(2L, vector2)

        // Search for nearest neighbors
        val query = FloatArray(dimension) { 1.0f }
        val results = vectorStore.search(query, k = 2)

        // Verify results
        assertEquals(2, results.size)
        assertEquals(1L, results[0].id)  // Closest should be vector1
        assertTrue(results[0].distance < results[1].distance)
    }
}"

# Java Instrumented Tests
mkdir -p "$JAVA_SDK_DIR/src/androidTest/java/com/llamamobile/vd"
java_instrumented_test="package com.llamamobile.vd;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Instrumented test for LlamaMobileVD Android SDK (Java)
 * Runs on an Android device or emulator.
 */
@RunWith(AndroidJUnit4.class)
public class LlamaMobileVDInstrumentedTests {
    private final android.content.Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();

    @Test
    public void testVectorStoreCreation() {
        // Test that VectorStore can be created
        LlamaMobileVD.VectorStore vectorStore = new LlamaMobileVD.VectorStore(
            128,
            LlamaMobileVD.DistanceMetric.L2
        );
        Assert.assertNotNull(vectorStore);
    }

    @Test
    public void testVectorStoreAddAndSearch() {
        // Test adding vectors and searching
        int dimension = 32;
        LlamaMobileVD.VectorStore vectorStore = new LlamaMobileVD.VectorStore(
            dimension,
            LlamaMobileVD.DistanceMetric.L2
        );

        // Create test vectors
        float[] vector1 = new float[dimension];
        float[] vector2 = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            vector1[i] = 1.0f;
            vector2[i] = 2.0f;
        }

        // Add vectors
        vectorStore.add(1L, vector1);
        vectorStore.add(2L, vector2);

        // Search for nearest neighbors
        float[] query = new float[dimension];
        for (int i = 0; i < dimension; i++) {
            query[i] = 1.0f;
        }
        LlamaMobileVD.SearchResult[] results = vectorStore.search(query, 2);

        // Verify results
        Assert.assertEquals(2, results.length);
        Assert.assertEquals(1L, results[0].id);  // Closest should be vector1
        Assert.assertTrue(results[0].distance < results[1].distance);
    }
}"

# Write test files
echo "$kotlin_unit_test" > "$KOTLIN_SDK_DIR/src/test/java/com/llamamobile/vd/LlamaMobileVDUnitTests.kt"
echo "$java_unit_test" > "$JAVA_SDK_DIR/src/test/java/com/llamamobile/vd/LlamaMobileVDUnitTests.java"
echo "$kotlin_instrumented_test" > "$KOTLIN_SDK_DIR/src/androidTest/java/com/llamamobile/vd/LlamaMobileVDInstrumentedTests.kt"
echo "$java_instrumented_test" > "$JAVA_SDK_DIR/src/androidTest/java/com/llamamobile/vd/LlamaMobileVDInstrumentedTests.java"

log_message "INFO" "Created test files for both SDKs"

# Make the script executable
chmod +x "$0"
log_message "INFO" "Made build script executable"

log_message "INFO" "Vector Database Android SDK build process completed successfully!"
log_message "INFO" "Generated SDKs:"  
log_message "INFO" "- Kotlin SDK: $KOTLIN_SDK_DIR"
log_message "INFO" "- Java SDK: $JAVA_SDK_DIR"
