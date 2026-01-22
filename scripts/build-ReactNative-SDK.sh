#!/bin/bash

# set -e

echo "Building ReactNative SDK for Llama Mobile Vector Database..."

# Get the absolute path to the project root
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
REACTNATIVE_SDK_DIR="$PROJECT_ROOT/llama_mobile_vd-reactnative-SDK"

# Create ReactNative SDK directory if it doesn't exist
echo "Creating ReactNative SDK directory..."
mkdir -p "$REACTNATIVE_SDK_DIR"

# Create scripts directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/scripts"

# Create ReactNative SDK structure
echo "Creating ReactNative SDK structure..."
mkdir -p "$REACTNATIVE_SDK_DIR/android/src/main/java/com/llamamobile/vd"
mkdir -p "$REACTNATIVE_SDK_DIR/android/src/main/jniLibs/arm64-v8a"
mkdir -p "$REACTNATIVE_SDK_DIR/android/src/main/jniLibs/x86_64"
mkdir -p "$REACTNATIVE_SDK_DIR/ios"
mkdir -p "$REACTNATIVE_SDK_DIR/src"
mkdir -p "$REACTNATIVE_SDK_DIR/test"
mkdir -p "$REACTNATIVE_SDK_DIR/__mocks__"

# Copy required files from iOS SDK
echo "Copying iOS framework..."
echo "Checking if $PROJECT_ROOT/llama_mobile_vd-ios-SDK/llama_mobile_vd.xcframework exists..."
if [ -d "$PROJECT_ROOT/llama_mobile_vd-ios-SDK/llama_mobile_vd.xcframework" ]; then
    echo "Directory exists, copying..."
    echo "Source: $PROJECT_ROOT/llama_mobile_vd-ios-SDK/llama_mobile_vd.xcframework"
    echo "Destination: $REACTNATIVE_SDK_DIR/ios/"
    # Create destination directory if it doesn't exist
    mkdir -p "$REACTNATIVE_SDK_DIR/ios/"
    # Use cp with verbose to see what's happening
    cp -Rn -v "$PROJECT_ROOT/llama_mobile_vd-ios-SDK/llama_mobile_vd.xcframework" "$REACTNATIVE_SDK_DIR/ios/"
else
    echo "Warning: iOS framework not found, skipping copy"
fi

# Copy required files from Android SDK
echo "Copying Android lib..."
echo "Checking if $PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/jniLibs/ exists..."
if [ -d "$PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/jniLibs/" ]; then
    echo "Android jniLibs exists, copying..."
    cp -Rn -v "$PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/jniLibs/" "$REACTNATIVE_SDK_DIR/android/src/main/"
else
    echo "Warning: Android jniLibs not found, skipping copy"
fi

echo "Checking if $PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/cpp/ exists..."
if [ -d "$PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/cpp/" ]; then
    echo "Android cpp exists, copying..."
    cp -Rn -v "$PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/cpp/" "$REACTNATIVE_SDK_DIR/android/src/main/"
else
    echo "Warning: Android cpp not found, skipping copy"
fi

echo "Checking if $PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/AndroidManifest.xml exists..."
if [ -f "$PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/AndroidManifest.xml" ]; then
    echo "AndroidManifest.xml exists, copying..."
    cp -n -v "$PROJECT_ROOT/llama_mobile_vd-android-SDK/src/main/AndroidManifest.xml" "$REACTNATIVE_SDK_DIR/android/src/main/"
else
    echo "Warning: AndroidManifest.xml not found, skipping copy"
fi

# Create package.json for ReactNative SDK
echo "Creating package.json..."
if [ ! -f "$REACTNATIVE_SDK_DIR/package.json" ]; then
    cat > "$REACTNATIVE_SDK_DIR/package.json" << 'EOF'
{
  "name": "llama-mobile-vd-react-native-sdk",
  "version": "1.0.0",
  "description": "ReactNative SDK for Llama Mobile Vector Database",
  "main": "src/index.js",
  "scripts": {
    "test": "jest",
    "build": "echo \"Building ReactNative SDK...\""
  },
  "keywords": [
    "react-native",
    "vector-database",
    "llama-mobile"
  ],
  "author": "Llama Mobile",
  "license": "MIT",
  "peerDependencies": {
    "react": "^18.0.0",
    "react-native": "^0.73.0"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  }
}
EOF
else
    echo "package.json already exists, skipping creation"
fi

# Create Android build.gradle
echo "Creating Android build.gradle..."
if [ ! -f "$REACTNATIVE_SDK_DIR/android/build.gradle" ]; then
    cat > "$REACTNATIVE_SDK_DIR/android/build.gradle" << 'EOF'
apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    compileSdkVersion 34
    buildToolsVersion "34.0.0"

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"

        externalNativeBuild {
            cmake {
                cppFlags "-std=c++17"
            }
        }
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    externalNativeBuild {
        cmake {
            path "src/main/cpp/CMakeLists.txt"
            version "3.18.1"
        }
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.0"
    implementation "com.facebook.react:react-native:+"
}
EOF
else
    echo "android/build.gradle already exists, skipping creation"
fi

# Create Android proguard-rules.pro
echo "Creating Android proguard-rules.pro..."
if [ ! -f "$REACTNATIVE_SDK_DIR/android/proguard-rules.pro" ]; then
    cat > "$REACTNATIVE_SDK_DIR/android/proguard-rules.pro" << 'EOF'
# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
EOF
else
    echo "android/proguard-rules.pro already exists, skipping creation"
fi

# Create Android settings.gradle
echo "Creating Android settings.gradle..."
if [ ! -f "$REACTNATIVE_SDK_DIR/android/settings.gradle" ]; then
    cat > "$REACTNATIVE_SDK_DIR/android/settings.gradle" << 'EOF'
rootProject.name = "llama_mobile_vd"
EOF
else
    echo "android/settings.gradle already exists, skipping creation"
fi

# Create iOS podspec
echo "Creating iOS podspec..."
PODSPEC_NAME="llama_mobile_vd-react-native-sdk.podspec"
if [ ! -f "$REACTNATIVE_SDK_DIR/$PODSPEC_NAME" ]; then
    cat > "$REACTNATIVE_SDK_DIR/$PODSPEC_NAME" << 'EOF'
require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "llama_mobile_vd-react-native-sdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = package["description"]
  s.homepage     = ""
  s.license      = package["license"]
  s.author       = package["author"]
  s.platform     = :ios, "12.0"
  s.source       = { :git => "", :tag => "#{s.version}" }
  
  s.source_files = "ios/**/*.{h,m,swift}"
  s.vendored_frameworks = "ios/llama_mobile_vd.xcframework"
  
  s.dependency "React-Core"
end
EOF
else
    echo "$PODSPEC_NAME already exists, skipping creation"
fi

# Create ReactNative SDK index.js (CommonJS format for Jest compatibility)
echo "Creating ReactNative SDK index.js..."
if [ ! -f "$REACTNATIVE_SDK_DIR/src/index.js" ]; then
    cat > "$REACTNATIVE_SDK_DIR/src/index.js" << 'EOF'
const { NativeModules } = require('react-native');

const { LlamaMobileVD } = NativeModules;

module.exports = {
  // VectorStore methods
  vectorStoreCreate: (dimension, metric) => LlamaMobileVD.vectorStoreCreate(dimension, metric),
  vectorStoreAddVector: (storeId, id, vector) => LlamaMobileVD.vectorStoreAddVector(storeId, id, vector),
  vectorStoreSearch: (storeId, queryVector, k) => LlamaMobileVD.vectorStoreSearch(storeId, queryVector, k),
  vectorStoreGetVector: (storeId, id) => LlamaMobileVD.vectorStoreGetVector(storeId, id),
  vectorStoreRemoveVector: (storeId, id) => LlamaMobileVD.vectorStoreRemoveVector(storeId, id),
  vectorStoreContains: (storeId, id) => LlamaMobileVD.vectorStoreContains(storeId, id),
  vectorStoreGetSize: (storeId) => LlamaMobileVD.vectorStoreGetSize(storeId),
  vectorStoreGetDimension: (storeId) => LlamaMobileVD.vectorStoreGetDimension(storeId),
  vectorStoreGetMetric: (storeId) => LlamaMobileVD.vectorStoreGetMetric(storeId),
  vectorStoreUpdateVector: (storeId, id, vector) => LlamaMobileVD.vectorStoreUpdateVector(storeId, id, vector),
  vectorStoreReserve: (storeId, capacity) => LlamaMobileVD.vectorStoreReserve(storeId, capacity),
  vectorStoreClear: (storeId) => LlamaMobileVD.vectorStoreClear(storeId),
  vectorStoreDestroy: (storeId) => LlamaMobileVD.vectorStoreDestroy(storeId),

  // HNSWIndex methods
  hnswIndexCreate: (dimension, metric, maxElements) => LlamaMobileVD.hnswIndexCreate(dimension, metric, maxElements),
  hnswIndexCreateWithParams: (dimension, metric, maxElements, M, efConstruction, seed) => 
    LlamaMobileVD.hnswIndexCreateWithParams(dimension, metric, maxElements, M, efConstruction, seed),
  hnswIndexAddVector: (indexId, id, vector) => LlamaMobileVD.hnswIndexAddVector(indexId, id, vector),
  hnswIndexSearch: (indexId, queryVector, k) => LlamaMobileVD.hnswIndexSearch(indexId, queryVector, k),
  hnswIndexSetEfSearch: (indexId, efSearch) => LlamaMobileVD.hnswIndexSetEfSearch(indexId, efSearch),
  hnswIndexGetEfSearch: (indexId) => LlamaMobileVD.hnswIndexGetEfSearch(indexId),
  hnswIndexGetSize: (indexId) => LlamaMobileVD.hnswIndexGetSize(indexId),
  hnswIndexGetDimension: (indexId) => LlamaMobileVD.hnswIndexGetDimension(indexId),
  hnswIndexGetCapacity: (indexId) => LlamaMobileVD.hnswIndexGetCapacity(indexId),
  hnswIndexContains: (indexId, id) => LlamaMobileVD.hnswIndexContains(indexId, id),
  hnswIndexGetVector: (indexId, id) => LlamaMobileVD.hnswIndexGetVector(indexId, id),
  hnswIndexSave: (indexId, filename) => LlamaMobileVD.hnswIndexSave(indexId, filename),
  hnswIndexLoad: (filename) => LlamaMobileVD.hnswIndexLoad(filename),
  hnswIndexDestroy: (indexId) => LlamaMobileVD.hnswIndexDestroy(indexId),

  // MMapVectorStoreBuilder methods
  mmapVectorStoreBuilderCreate: (dimension, metric) => LlamaMobileVD.mmapVectorStoreBuilderCreate(dimension, metric),
  mmapVectorStoreBuilderAddVector: (builderId, id, vector) => LlamaMobileVD.mmapVectorStoreBuilderAddVector(builderId, id, vector),
  mmapVectorStoreBuilderReserve: (builderId, capacity) => LlamaMobileVD.mmapVectorStoreBuilderReserve(builderId, capacity),
  mmapVectorStoreBuilderSave: (builderId, filename) => LlamaMobileVD.mmapVectorStoreBuilderSave(builderId, filename),
  mmapVectorStoreBuilderGetSize: (builderId) => LlamaMobileVD.mmapVectorStoreBuilderGetSize(builderId),
  mmapVectorStoreBuilderGetDimension: (builderId) => LlamaMobileVD.mmapVectorStoreBuilderGetDimension(builderId),
  mmapVectorStoreBuilderDestroy: (builderId) => LlamaMobileVD.mmapVectorStoreBuilderDestroy(builderId),

  // MMapVectorStore methods
  mmapVectorStoreOpen: (filename) => LlamaMobileVD.mmapVectorStoreOpen(filename),
  mmapVectorStoreGetVector: (storeId, id) => LlamaMobileVD.mmapVectorStoreGetVector(storeId, id),
  mmapVectorStoreContains: (storeId, id) => LlamaMobileVD.mmapVectorStoreContains(storeId, id),
  mmapVectorStoreSearch: (storeId, queryVector, k) => LlamaMobileVD.mmapVectorStoreSearch(storeId, queryVector, k),
  mmapVectorStoreGetSize: (storeId) => LlamaMobileVD.mmapVectorStoreGetSize(storeId),
  mmapVectorStoreGetDimension: (storeId) => LlamaMobileVD.mmapVectorStoreGetDimension(storeId),
  mmapVectorStoreGetMetric: (storeId) => LlamaMobileVD.mmapVectorStoreGetMetric(storeId),
  mmapVectorStoreClose: (storeId) => LlamaMobileVD.mmapVectorStoreClose(storeId),

  // Version methods
  getVersion: () => LlamaMobileVD.getVersion(),
  getGitCommit: () => LlamaMobileVD.getGitCommit(),
  getBuildDate: () => LlamaMobileVD.getBuildDate(),
};
EOF
else
    echo "src/index.js already exists, skipping creation"
fi

# Create Android Kotlin wrapper with FloatArray instead of DoubleArray
echo "Creating Android Kotlin wrapper..."
if [ ! -f "$REACTNATIVE_SDK_DIR/android/src/main/java/com/llamamobile/vd/LlamaMobileVD.kt" ]; then
    cat > "$REACTNATIVE_SDK_DIR/android/src/main/java/com/llamamobile/vd/LlamaMobileVD.kt" << 'EOF'
package com.llamamobile.vd

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableArray

class LlamaMobileVD(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "LlamaMobileVD"
    }

    // VectorStore methods
    @ReactMethod
    fun vectorStoreCreate(dimension: Int, metric: Int, promise: Promise) {
        val storePtr = nativeVectorStoreCreate(dimension, metric)
        if (storePtr != 0L) {
            vectorStoreMap[storePtr] = storePtr
            promise.resolve(storePtr)
        } else {
            promise.reject("CREATE_FAILED", "Failed to create vector store")
        }
    }

    @ReactMethod
    fun vectorStoreAddVector(storeId: Long, id: Long, vector: ReadableArray, promise: Promise) {
        val vectorArray = FloatArray(vector.size()) {
            vector.getDouble(it).toFloat()
        }
        val success = nativeVectorStoreAddVector(storeId, id, vectorArray)
        promise.resolve(success)
    }

    @ReactMethod
    fun vectorStoreSearch(storeId: Long, queryVector: ReadableArray, k: Int, promise: Promise) {
        val vectorArray = FloatArray(queryVector.size()) {
            queryVector.getDouble(it).toFloat()
        }
        val results = nativeVectorStoreSearch(storeId, vectorArray, k)
        promise.resolve(results)
    }

    @ReactMethod
    fun vectorStoreGetVector(storeId: Long, id: Long, promise: Promise) {
        val vector = nativeVectorStoreGetVector(storeId, id)
        promise.resolve(vector)
    }

    @ReactMethod
    fun vectorStoreRemoveVector(storeId: Long, id: Long, promise: Promise) {
        val success = nativeVectorStoreRemoveVector(storeId, id)
        promise.resolve(success)
    }

    @ReactMethod
    fun vectorStoreContains(storeId: Long, id: Long, promise: Promise) {
        val contains = nativeVectorStoreContains(storeId, id)
        promise.resolve(contains)
    }

    @ReactMethod
    fun vectorStoreGetSize(storeId: Long, promise: Promise) {
        val size = nativeVectorStoreGetSize(storeId)
        promise.resolve(size)
    }

    @ReactMethod
    fun vectorStoreGetDimension(storeId: Long, promise: Promise) {
        val dimension = nativeVectorStoreGetDimension(storeId)
        promise.resolve(dimension)
    }

    @ReactMethod
    fun vectorStoreGetMetric(storeId: Long, promise: Promise) {
        val metric = nativeVectorStoreGetMetric(storeId)
        promise.resolve(metric)
    }

    @ReactMethod
    fun vectorStoreUpdateVector(storeId: Long, id: Long, vector: ReadableArray, promise: Promise) {
        val vectorArray = FloatArray(vector.size()) {
            vector.getDouble(it).toFloat()
        }
        val success = nativeVectorStoreUpdateVector(storeId, id, vectorArray)
        promise.resolve(success)
    }

    @ReactMethod
    fun vectorStoreReserve(storeId: Long, capacity: Int, promise: Promise) {
        val success = nativeVectorStoreReserve(storeId, capacity)
        promise.resolve(success)
    }

    @ReactMethod
    fun vectorStoreClear(storeId: Long, promise: Promise) {
        val success = nativeVectorStoreClear(storeId)
        promise.resolve(success)
    }

    @ReactMethod
    fun vectorStoreDestroy(storeId: Long, promise: Promise) {
        nativeVectorStoreDestroy(storeId)
        vectorStoreMap.remove(storeId)
        promise.resolve(true)
    }

    // HNSWIndex methods
    @ReactMethod
    fun hnswIndexCreate(dimension: Int, metric: Int, maxElements: Int, promise: Promise) {
        val indexPtr = nativeHNSWIndexCreate(dimension, metric, maxElements.toLong())
        if (indexPtr != 0L) {
            hnswIndexMap[indexPtr] = indexPtr
            promise.resolve(indexPtr)
        } else {
            promise.reject("CREATE_FAILED", "Failed to create HNSW index")
        }
    }

    @ReactMethod
    fun hnswIndexCreateWithParams(dimension: Int, metric: Int, maxElements: Int, M: Int, efConstruction: Int, seed: Int, promise: Promise) {
        val indexPtr = nativeHNSWIndexCreateWithParams(dimension, metric, maxElements.toLong(), M, efConstruction, seed)
        if (indexPtr != 0L) {
            hnswIndexMap[indexPtr] = indexPtr
            promise.resolve(indexPtr)
        } else {
            promise.reject("CREATE_FAILED", "Failed to create HNSW index")
        }
    }

    @ReactMethod
    fun hnswIndexAddVector(indexId: Long, id: Long, vector: ReadableArray, promise: Promise) {
        val vectorArray = FloatArray(vector.size()) {
            vector.getDouble(it).toFloat()
        }
        val success = nativeHNSWIndexAddVector(indexId, id, vectorArray)
        promise.resolve(success)
    }

    @ReactMethod
    fun hnswIndexSearch(indexId: Long, queryVector: ReadableArray, k: Int, promise: Promise) {
        val vectorArray = FloatArray(queryVector.size()) {
            queryVector.getDouble(it).toFloat()
        }
        val results = nativeHNSWIndexSearch(indexId, vectorArray, k)
        promise.resolve(results)
    }

    @ReactMethod
    fun hnswIndexSetEfSearch(indexId: Long, efSearch: Int, promise: Promise) {
        val success = nativeHNSWIndexSetEfSearch(indexId, efSearch)
        promise.resolve(success)
    }

    @ReactMethod
    fun hnswIndexGetEfSearch(indexId: Long, promise: Promise) {
        val efSearch = nativeHNSWIndexGetEfSearch(indexId)
        promise.resolve(efSearch)
    }

    @ReactMethod
    fun hnswIndexGetSize(indexId: Long, promise: Promise) {
        val size = nativeHNSWIndexGetSize(indexId)
        promise.resolve(size)
    }

    @ReactMethod
    fun hnswIndexGetDimension(indexId: Long, promise: Promise) {
        val dimension = nativeHNSWIndexGetDimension(indexId)
        promise.resolve(dimension)
    }

    @ReactMethod
    fun hnswIndexGetCapacity(indexId: Long, promise: Promise) {
        val capacity = nativeHNSWIndexGetCapacity(indexId)
        promise.resolve(capacity)
    }

    @ReactMethod
    fun hnswIndexContains(indexId: Long, id: Long, promise: Promise) {
        val contains = nativeHNSWIndexContains(indexId, id)
        promise.resolve(contains)
    }

    @ReactMethod
    fun hnswIndexGetVector(indexId: Long, id: Long, promise: Promise) {
        val vector = nativeHNSWIndexGetVector(indexId, id)
        promise.resolve(vector)
    }

    @ReactMethod
    fun hnswIndexSave(indexId: Long, filename: String, promise: Promise) {
        val success = nativeHNSWIndexSave(indexId, filename)
        promise.resolve(success)
    }

    @ReactMethod
    fun hnswIndexLoad(filename: String, promise: Promise) {
        val indexPtr = nativeHNSWIndexLoad(filename)
        if (indexPtr != 0L) {
            hnswIndexMap[indexPtr] = indexPtr
            promise.resolve(indexPtr)
        } else {
            promise.reject("LOAD_FAILED", "Failed to load HNSW index")
        }
    }

    @ReactMethod
    fun hnswIndexDestroy(indexId: Long, promise: Promise) {
        nativeHNSWIndexDestroy(indexId)
        hnswIndexMap.remove(indexId)
        promise.resolve(true)
    }

    // MMapVectorStoreBuilder methods
    @ReactMethod
    fun mmapVectorStoreBuilderCreate(dimension: Int, metric: Int, promise: Promise) {
        val builderPtr = nativeMMapVectorStoreBuilderCreate(dimension, metric)
        if (builderPtr != 0L) {
            mmapVectorStoreBuilderMap[builderPtr] = builderPtr
            promise.resolve(builderPtr)
        } else {
            promise.reject("CREATE_FAILED", "Failed to create MMapVectorStoreBuilder")
        }
    }

    @ReactMethod
    fun mmapVectorStoreBuilderAddVector(builderId: Long, id: Long, vector: ReadableArray, promise: Promise) {
        val vectorArray = FloatArray(vector.size()) {
            vector.getDouble(it).toFloat()
        }
        val success = nativeMMapVectorStoreBuilderAddVector(builderId, id, vectorArray)
        promise.resolve(success)
    }

    @ReactMethod
    fun mmapVectorStoreBuilderReserve(builderId: Long, capacity: Int, promise: Promise) {
        val success = nativeMMapVectorStoreBuilderReserve(builderId, capacity)
        promise.resolve(success)
    }

    @ReactMethod
    fun mmapVectorStoreBuilderSave(builderId: Long, filename: String, promise: Promise) {
        val success = nativeMMapVectorStoreBuilderSave(builderId, filename)
        promise.resolve(success)
    }

    @ReactMethod
    fun mmapVectorStoreBuilderGetSize(builderId: Long, promise: Promise) {
        val size = nativeMMapVectorStoreBuilderGetSize(builderId)
        promise.resolve(size)
    }

    @ReactMethod
    fun mmapVectorStoreBuilderGetDimension(builderId: Long, promise: Promise) {
        val dimension = nativeMMapVectorStoreBuilderGetDimension(builderId)
        promise.resolve(dimension)
    }

    @ReactMethod
    fun mmapVectorStoreBuilderDestroy(builderId: Long, promise: Promise) {
        nativeMMapVectorStoreBuilderDestroy(builderId)
        mmapVectorStoreBuilderMap.remove(builderId)
        promise.resolve(true)
    }

    // MMapVectorStore methods
    @ReactMethod
    fun mmapVectorStoreOpen(filename: String, promise: Promise) {
        val storePtr = nativeMMapVectorStoreOpen(filename)
        if (storePtr != 0L) {
            mmapVectorStoreMap[storePtr] = storePtr
            promise.resolve(storePtr)
        } else {
            promise.reject("OPEN_FAILED", "Failed to open MMapVectorStore")
        }
    }

    @ReactMethod
    fun mmapVectorStoreGetVector(storeId: Long, id: Long, promise: Promise) {
        val vector = nativeMMapVectorStoreGetVector(storeId, id)
        promise.resolve(vector)
    }

    @ReactMethod
    fun mmapVectorStoreContains(storeId: Long, id: Long, promise: Promise) {
        val contains = nativeMMapVectorStoreContains(storeId, id)
        promise.resolve(contains)
    }

    @ReactMethod
    fun mmapVectorStoreSearch(storeId: Long, queryVector: ReadableArray, k: Int, promise: Promise) {
        val vectorArray = FloatArray(queryVector.size()) {
            queryVector.getDouble(it).toFloat()
        }
        val results = nativeMMapVectorStoreSearch(storeId, vectorArray, k)
        promise.resolve(results)
    }

    @ReactMethod
    fun mmapVectorStoreGetSize(storeId: Long, promise: Promise) {
        val size = nativeMMapVectorStoreGetSize(storeId)
        promise.resolve(size)
    }

    @ReactMethod
    fun mmapVectorStoreGetDimension(storeId: Long, promise: Promise) {
        val dimension = nativeMMapVectorStoreGetDimension(storeId)
        promise.resolve(dimension)
    }

    @ReactMethod
    fun mmapVectorStoreGetMetric(storeId: Long, promise: Promise) {
        val metric = nativeMMapVectorStoreGetMetric(storeId)
        promise.resolve(metric)
    }

    @ReactMethod
    fun mmapVectorStoreClose(storeId: Long, promise: Promise) {
        val success = nativeMMapVectorStoreClose(storeId)
        mmapVectorStoreMap.remove(storeId)
        promise.resolve(success)
    }

    // Version methods
    @ReactMethod
    fun getVersion(promise: Promise) {
        val version = nativeGetVersion()
        promise.resolve(version)
    }

    @ReactMethod
    fun getGitCommit(promise: Promise) {
        val gitCommit = nativeGetGitCommit()
        promise.resolve(gitCommit)
    }

    @ReactMethod
    fun getBuildDate(promise: Promise) {
        val buildDate = nativeGetBuildDate()
        promise.resolve(buildDate)
    }

    // Native methods
    external fun nativeVectorStoreCreate(dimension: Int, metric: Int): Long
    external fun nativeVectorStoreAddVector(storeId: Long, id: Long, vector: FloatArray): Boolean
    external fun nativeVectorStoreSearch(storeId: Long, queryVector: FloatArray, k: Int): Array<Map<String, Any>>
    external fun nativeVectorStoreGetVector(storeId: Long, id: Long): FloatArray?
    external fun nativeVectorStoreRemoveVector(storeId: Long, id: Long): Boolean
    external fun nativeVectorStoreContains(storeId: Long, id: Long): Boolean
    external fun nativeVectorStoreGetSize(storeId: Long): Int
    external fun nativeVectorStoreGetDimension(storeId: Long): Int
    external fun nativeVectorStoreGetMetric(storeId: Long): Int
    external fun nativeVectorStoreUpdateVector(storeId: Long, id: Long, vector: FloatArray): Boolean
    external fun nativeVectorStoreReserve(storeId: Long, capacity: Int): Boolean
    external fun nativeVectorStoreClear(storeId: Long): Boolean
    external fun nativeVectorStoreDestroy(storeId: Long)

    external fun nativeHNSWIndexCreate(dimension: Int, metric: Int, maxElements: Long): Long
    external fun nativeHNSWIndexCreateWithParams(dimension: Int, metric: Int, maxElements: Long, M: Int, efConstruction: Int, seed: Int): Long
    external fun nativeHNSWIndexAddVector(indexId: Long, id: Long, vector: FloatArray): Boolean
    external fun nativeHNSWIndexSearch(indexId: Long, queryVector: FloatArray, k: Int): Array<Map<String, Any>>
    external fun nativeHNSWIndexSetEfSearch(indexId: Long, efSearch: Int): Boolean
    external fun nativeHNSWIndexGetEfSearch(indexId: Long): Int
    external fun nativeHNSWIndexGetSize(indexId: Long): Int
    external fun nativeHNSWIndexGetDimension(indexId: Long): Int
    external fun nativeHNSWIndexGetCapacity(indexId: Long): Int
    external fun nativeHNSWIndexContains(indexId: Long, id: Long): Boolean
    external fun nativeHNSWIndexGetVector(indexId: Long, id: Long): FloatArray?
    external fun nativeHNSWIndexSave(indexId: Long, filename: String): Boolean
    external fun nativeHNSWIndexLoad(filename: String): Long
    external fun nativeHNSWIndexDestroy(indexId: Long)

    external fun nativeMMapVectorStoreBuilderCreate(dimension: Int, metric: Int): Long
    external fun nativeMMapVectorStoreBuilderAddVector(builderId: Long, id: Long, vector: FloatArray): Boolean
    external fun nativeMMapVectorStoreBuilderReserve(builderId: Long, capacity: Int): Boolean
    external fun nativeMMapVectorStoreBuilderSave(builderId: Long, filename: String): Boolean
    external fun nativeMMapVectorStoreBuilderGetSize(builderId: Long): Int
    external fun nativeMMapVectorStoreBuilderGetDimension(builderId: Long): Int
    external fun nativeMMapVectorStoreBuilderDestroy(builderId: Long)

    external fun nativeMMapVectorStoreOpen(filename: String): Long
    external fun nativeMMapVectorStoreGetVector(storeId: Long, id: Long): FloatArray?
    external fun nativeMMapVectorStoreContains(storeId: Long, id: Long): Boolean
    external fun nativeMMapVectorStoreSearch(storeId: Long, queryVector: FloatArray, k: Int): Array<Map<String, Any>>
    external fun nativeMMapVectorStoreGetSize(storeId: Long): Int
    external fun nativeMMapVectorStoreGetDimension(storeId: Long): Int
    external fun nativeMMapVectorStoreGetMetric(storeId: Long): Int
    external fun nativeMMapVectorStoreClose(storeId: Long): Boolean

    external fun nativeGetVersion(): String
    external fun nativeGetGitCommit(): String
    external fun nativeGetBuildDate(): String

    companion object {
        private val vectorStoreMap = mutableMapOf<Long, Long>()
        private val hnswIndexMap = mutableMapOf<Long, Long>()
        private val mmapVectorStoreBuilderMap = mutableMapOf<Long, Long>()
        private val mmapVectorStoreMap = mutableMapOf<Long, Long>()

        init {
            System.loadLibrary("llama_mobile_vd_jni")
        }
    }
}
EOF
else
    echo "android/src/main/java/com/llamamobile/vd/LlamaMobileVD.kt already exists, skipping creation"
fi

# Create Android ReactPackage
echo "Creating Android ReactPackage..."
if [ ! -f "$REACTNATIVE_SDK_DIR/android/src/main/java/com/llamamobile/vd/LlamaMobileVDPackage.kt" ]; then
    cat > "$REACTNATIVE_SDK_DIR/android/src/main/java/com/llamamobile/vd/LlamaMobileVDPackage.kt" << 'EOF'
package com.llamamobile.vd

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

class LlamaMobileVDPackage : ReactPackage {
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        return listOf(LlamaMobileVD(reactContext))
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return emptyList()
    }
}
EOF
else
    echo "LlamaMobileVDPackage.kt already exists, skipping creation"
fi

# Create iOS Swift wrapper
echo "Creating iOS Swift wrapper..."
if [ ! -f "$REACTNATIVE_SDK_DIR/ios/LlamaMobileVD.swift" ]; then
    cat > "$REACTNATIVE_SDK_DIR/ios/LlamaMobileVD.swift" << 'EOF'
import Foundation
import React
import llama_mobile_vd

@objc(LlamaMobileVD)
class LlamaMobileVD: NSObject, RCTBridgeModule {

    static func moduleName() -> String!
    {
        return "LlamaMobileVD"
    }

    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    private var vectorStoreMap: [Int: LLAMA_MOBILE_VD_VectorStore] = [:]
    private var hnswIndexMap: [Int: LLAMA_MOBILE_VD_HNSWIndex] = [:]
    private var mmapVectorStoreBuilderMap: [Int: LLAMA_MOBILE_VD_MMapVectorStoreBuilder] = [:]
    private var mmapVectorStoreMap: [Int: LLAMA_MOBILE_VD_MMapVectorStore] = [:]

    // VectorStore methods
    @objc func vectorStoreCreate(_ dimension: Int, metric: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var storePtr: LLAMA_MOBILE_VD_VectorStore?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_vector_store_create(dimension, cMetric, &storePtr)
        
        if error == LLAMA_MOBILE_VD_OK && storePtr != nil {
            let storeId = Int(bitPattern: storePtr!)
            vectorStoreMap[storeId] = storePtr
            resolver(storeId)
        } else {
            rejecter("CREATE_FAILED", "Failed to create vector store", nil)
        }
    }

    @objc func vectorStoreAddVector(_ storeId: Int, id: UInt64, vector: [Double], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let vectorFloat = vector.map { Float($0) }
        let error = llama_mobile_vd_vector_store_add(store, id, vectorFloat)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func vectorStoreSearch(_ storeId: Int, queryVector: [Double], k: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let queryVectorFloat = queryVector.map { Float($0) }
        var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
        let error = llama_mobile_vd_vector_store_search(store, queryVectorFloat, k, &results, k)
        
        if error == LLAMA_MOBILE_VD_OK {
            let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
            resolver(flutterResults)
        } else {
            rejecter("SEARCH_FAILED", "Search failed", nil)
        }
    }

    @objc func vectorStoreGetVector(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var dimension: Int = 0
        let dimError = llama_mobile_vd_vector_store_dimension(store, &dimension)
        if dimError != LLAMA_MOBILE_VD_OK {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
            return
        }

        var vector = [Float](repeating: 0, count: dimension)
        let error = llama_mobile_vd_vector_store_get(store, id, &vector, dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            let doubleVector = vector.map { Double($0) }
            resolver(doubleVector)
        } else {
            resolver(nil)
        }
    }

    @objc func vectorStoreRemoveVector(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var removed: Int32 = 0
        let error = llama_mobile_vd_vector_store_remove(store, id, &removed)
        resolver(error == LLAMA_MOBILE_VD_OK && removed != 0)
    }

    @objc func vectorStoreContains(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var contains: Int32 = 0
        let error = llama_mobile_vd_vector_store_contains(store, id, &contains)
        resolver(error == LLAMA_MOBILE_VD_OK && contains != 0)
    }

    @objc func vectorStoreGetSize(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_vector_store_size(store, &size)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(size)
        } else {
            rejecter("SIZE_ERROR", "Failed to get size", nil)
        }
    }

    @objc func vectorStoreGetDimension(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_vector_store_dimension(store, &dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(dimension)
        } else {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
        }
    }

    @objc func vectorStoreGetMetric(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        var metric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
        let error = llama_mobile_vd_vector_store_metric(store, &metric)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(Int(metric.rawValue))
        } else {
            rejecter("METRIC_ERROR", "Failed to get metric", nil)
        }
    }

    @objc func vectorStoreUpdateVector(_ storeId: Int, id: UInt64, vector: [Double], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let vectorFloat = vector.map { Float($0) }
        let error = llama_mobile_vd_vector_store_update(store, id, vectorFloat)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func vectorStoreReserve(_ storeId: Int, capacity: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let error = llama_mobile_vd_vector_store_reserve(store, capacity)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func vectorStoreClear(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        let error = llama_mobile_vd_vector_store_clear(store)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func vectorStoreDestroy(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = vectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid vector store", nil)
            return
        }

        llama_mobile_vd_vector_store_destroy(store)
        vectorStoreMap.removeValue(forKey: storeId)
        resolver(true)
    }

    // HNSWIndex methods
    @objc func hnswIndexCreate(_ dimension: Int, metric: Int, maxElements: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_hnsw_index_create(
            dimension,
            cMetric,
            maxElements,
            &indexPtr
        )
        
        if error == LLAMA_MOBILE_VD_OK && indexPtr != nil {
            let indexId = Int(bitPattern: indexPtr!)
            hnswIndexMap[indexId] = indexPtr
            resolver(indexId)
        } else {
            rejecter("CREATE_FAILED", "Failed to create HNSW index", nil)
        }
    }

    @objc func hnswIndexCreateWithParams(_ dimension: Int, metric: Int, maxElements: Int, M: Int, efConstruction: Int, seed: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_hnsw_index_create_with_params(
            dimension,
            cMetric,
            maxElements,
            M,
            efConstruction,
            UInt32(seed),
            &indexPtr
        )
        
        if error == LLAMA_MOBILE_VD_OK && indexPtr != nil {
            let indexId = Int(bitPattern: indexPtr!)
            hnswIndexMap[indexId] = indexPtr
            resolver(indexId)
        } else {
            rejecter("CREATE_FAILED", "Failed to create HNSW index", nil)
        }
    }

    @objc func hnswIndexAddVector(_ indexId: Int, id: UInt64, vector: [Double], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        let vectorFloat = vector.map { Float($0) }
        let error = llama_mobile_vd_hnsw_index_add(index, id, vectorFloat)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func hnswIndexSearch(_ indexId: Int, queryVector: [Double], k: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        let queryVectorFloat = queryVector.map { Float($0) }
        var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
        let error = llama_mobile_vd_hnsw_index_search(
            index,
            queryVectorFloat,
            k,
            &results,
            k
        )
        
        if error == LLAMA_MOBILE_VD_OK {
            let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
            resolver(flutterResults)
        } else {
            rejecter("SEARCH_FAILED", "Search failed", nil)
        }
    }

    @objc func hnswIndexSetEfSearch(_ indexId: Int, efSearch: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        let error = llama_mobile_vd_hnsw_index_set_ef_search(index, efSearch)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func hnswIndexGetEfSearch(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var efSearch: Int = 0
        let error = llama_mobile_vd_hnsw_index_get_ef_search(index, &efSearch)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(efSearch)
        } else {
            rejecter("EF_SEARCH_ERROR", "Failed to get ef_search", nil)
        }
    }

    @objc func hnswIndexGetSize(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_hnsw_index_size(index, &size)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(size)
        } else {
            rejecter("SIZE_ERROR", "Failed to get size", nil)
        }
    }

    @objc func hnswIndexGetDimension(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_hnsw_index_dimension(index, &dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(dimension)
        } else {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
        }
    }

    @objc func hnswIndexGetCapacity(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var capacity: Int = 0
        let error = llama_mobile_vd_hnsw_index_capacity(index, &capacity)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(capacity)
        } else {
            rejecter("CAPACITY_ERROR", "Failed to get capacity", nil)
        }
    }

    @objc func hnswIndexContains(_ indexId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var contains: Int32 = 0
        let error = llama_mobile_vd_hnsw_index_contains(index, id, &contains)
        resolver(error == LLAMA_MOBILE_VD_OK && contains != 0)
    }

    @objc func hnswIndexGetVector(_ indexId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        var dimension: Int = 0
        let dimError = llama_mobile_vd_hnsw_index_dimension(index, &dimension)
        if dimError != LLAMA_MOBILE_VD_OK {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
            return
        }

        var vector = [Float](repeating: 0, count: dimension)
        let error = llama_mobile_vd_hnsw_index_get_vector(index, id, &vector, dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            let doubleVector = vector.map { Double($0) }
            resolver(doubleVector)
        } else {
            resolver(nil)
        }
    }

    @objc func hnswIndexSave(_ indexId: Int, filename: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        let error = llama_mobile_vd_hnsw_index_save(index, filename)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func hnswIndexLoad(_ filename: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var indexPtr: LLAMA_MOBILE_VD_HNSWIndex?
        let error = llama_mobile_vd_hnsw_index_load(filename, &indexPtr)
        
        if error == LLAMA_MOBILE_VD_OK && indexPtr != nil {
            let indexId = Int(bitPattern: indexPtr!)
            hnswIndexMap[indexId] = indexPtr
            resolver(indexId)
        } else {
            rejecter("LOAD_FAILED", "Failed to load HNSW index", nil)
        }
    }

    @objc func hnswIndexDestroy(_ indexId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let index = hnswIndexMap[indexId] else {
            rejecter("INVALID_INDEX", "Invalid HNSW index", nil)
            return
        }

        llama_mobile_vd_hnsw_index_destroy(index)
        hnswIndexMap.removeValue(forKey: indexId)
        resolver(true)
    }

    // MMapVectorStoreBuilder methods
    @objc func mmapVectorStoreBuilderCreate(_ dimension: Int, metric: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var builderPtr: LLAMA_MOBILE_VD_MMapVectorStoreBuilder?
        let cMetric = LLAMA_MOBILE_VD_DistanceMetric(UInt32(metric))
        let error = llama_mobile_vd_mmap_vector_store_builder_create(dimension, cMetric, &builderPtr)
        
        if error == LLAMA_MOBILE_VD_OK && builderPtr != nil {
            let builderId = Int(bitPattern: builderPtr!)
            mmapVectorStoreBuilderMap[builderId] = builderPtr
            resolver(builderId)
        } else {
            rejecter("CREATE_FAILED", "Failed to create MMapVectorStoreBuilder", nil)
        }
    }

    @objc func mmapVectorStoreBuilderAddVector(_ builderId: Int, id: UInt64, vector: [Double], resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        let vectorFloat = vector.map { Float($0) }
        let error = llama_mobile_vd_mmap_vector_store_builder_add(builder, id, vectorFloat)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func mmapVectorStoreBuilderReserve(_ builderId: Int, capacity: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        let error = llama_mobile_vd_mmap_vector_store_builder_reserve(builder, capacity)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func mmapVectorStoreBuilderSave(_ builderId: Int, filename: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        let error = llama_mobile_vd_mmap_vector_store_builder_save(builder, filename)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    @objc func mmapVectorStoreBuilderGetSize(_ builderId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_builder_size(builder, &size)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(size)
        } else {
            rejecter("SIZE_ERROR", "Failed to get size", nil)
        }
    }

    @objc func mmapVectorStoreBuilderGetDimension(_ builderId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_builder_dimension(builder, &dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(dimension)
        } else {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
        }
    }

    @objc func mmapVectorStoreBuilderDestroy(_ builderId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let builder = mmapVectorStoreBuilderMap[builderId] else {
            rejecter("INVALID_BUILDER", "Invalid MMapVectorStoreBuilder", nil)
            return
        }

        llama_mobile_vd_mmap_vector_store_builder_destroy(builder)
        mmapVectorStoreBuilderMap.removeValue(forKey: builderId)
        resolver(true)
    }

    // MMapVectorStore methods
    @objc func mmapVectorStoreOpen(_ filename: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        var storePtr: LLAMA_MOBILE_VD_MMapVectorStore?
        let error = llama_mobile_vd_mmap_vector_store_open(filename, &storePtr)
        
        if error == LLAMA_MOBILE_VD_OK && storePtr != nil {
            let storeId = Int(bitPattern: storePtr!)
            mmapVectorStoreMap[storeId] = storePtr
            resolver(storeId)
        } else {
            rejecter("OPEN_FAILED", "Failed to open MMapVectorStore", nil)
        }
    }

    @objc func mmapVectorStoreGetVector(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var dimension: Int = 0
        let dimError = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension)
        if dimError != LLAMA_MOBILE_VD_OK {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
            return
        }

        var vector = [Float](repeating: 0, count: dimension)
        let error = llama_mobile_vd_mmap_vector_store_get(store, id, &vector, dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            let doubleVector = vector.map { Double($0) }
            resolver(doubleVector)
        } else {
            resolver(nil)
        }
    }

    @objc func mmapVectorStoreContains(_ storeId: Int, id: UInt64, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var contains: Int32 = 0
        let error = llama_mobile_vd_mmap_vector_store_contains(store, id, &contains)
        resolver(error == LLAMA_MOBILE_VD_OK && contains != 0)
    }

    @objc func mmapVectorStoreSearch(_ storeId: Int, queryVector: [Double], k: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        let queryVectorFloat = queryVector.map { Float($0) }
        var results = [LLAMA_MOBILE_VD_SearchResult](repeating: LLAMA_MOBILE_VD_SearchResult(id: 0, distance: 0), count: k)
        let error = llama_mobile_vd_mmap_vector_store_search(store, queryVectorFloat, k, &results, k)
        
        if error == LLAMA_MOBILE_VD_OK {
            let flutterResults = results.map { ["id": Int($0.id), "distance": Double($0.distance)] }
            resolver(flutterResults)
        } else {
            rejecter("SEARCH_FAILED", "Search failed", nil)
        }
    }

    @objc func mmapVectorStoreGetSize(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var size: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_size(store, &size)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(size)
        } else {
            rejecter("SIZE_ERROR", "Failed to get size", nil)
        }
    }

    @objc func mmapVectorStoreGetDimension(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var dimension: Int = 0
        let error = llama_mobile_vd_mmap_vector_store_dimension(store, &dimension)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(dimension)
        } else {
            rejecter("DIMENSION_ERROR", "Failed to get dimension", nil)
        }
    }

    @objc func mmapVectorStoreGetMetric(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        var metric: LLAMA_MOBILE_VD_DistanceMetric = LLAMA_MOBILE_VD_DISTANCE_L2
        let error = llama_mobile_vd_mmap_vector_store_metric(store, &metric)
        
        if error == LLAMA_MOBILE_VD_OK {
            resolver(Int(metric.rawValue))
        } else {
            rejecter("METRIC_ERROR", "Failed to get metric", nil)
        }
    }

    @objc func mmapVectorStoreClose(_ storeId: Int, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        guard let store = mmapVectorStoreMap[storeId] else {
            rejecter("INVALID_STORE", "Invalid MMapVectorStore", nil)
            return
        }

        let error = llama_mobile_vd_mmap_vector_store_close(store)
        mmapVectorStoreMap.removeValue(forKey: storeId)
        resolver(error == LLAMA_MOBILE_VD_OK)
    }

    // Version methods
    @objc func getVersion(_ resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        let version = llama_mobile_vd_get_version()
        resolver(String(cString: version))
    }

    @objc func getGitCommit(_ resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        let gitCommit = llama_mobile_vd_get_git_commit()
        resolver(String(cString: gitCommit))
    }

    @objc func getBuildDate(_ resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
        let buildDate = llama_mobile_vd_get_build_date()
        resolver(String(cString: buildDate))
    }
}
EOF
else
    echo "ios/LlamaMobileVD.swift already exists, skipping creation"
fi

# Create iOS header file
echo "Creating iOS header file..."
if [ ! -f "$REACTNATIVE_SDK_DIR/ios/LlamaMobileVD.h" ]; then
    cat > "$REACTNATIVE_SDK_DIR/ios/LlamaMobileVD.h" << 'EOF'
#ifndef LlamaMobileVD_h
#define LlamaMobileVD_h

#import <React/RCTBridgeModule.h>

@interface LlamaMobileVD : NSObject <RCTBridgeModule>
@end

#endif /* LlamaMobileVD_h */
EOF
else
    echo "ios/LlamaMobileVD.h already exists, skipping creation"
fi

# Create Jest config
echo "Creating Jest config..."
if [ ! -f "$REACTNATIVE_SDK_DIR/jest.config.js" ]; then
    cat > "$REACTNATIVE_SDK_DIR/jest.config.js" << 'EOF'
module.exports = {
  testEnvironment: 'node',
  moduleNameMapper: {
    '^react-native$': '<rootDir>/__mocks__/react-native.js'
  },
};
EOF
else
    echo "jest.config.js already exists, skipping creation"
fi

# Create ReactNative mock
echo "Creating ReactNative mock..."
if [ ! -f "$REACTNATIVE_SDK_DIR/__mocks__/react-native.js" ]; then
    cat > "$REACTNATIVE_SDK_DIR/__mocks__/react-native.js" << 'EOF'
const storeInstances = new Map();
const hnswIndexInstances = new Map();
const mmapBuilderInstances = new Map();
const mmapStoreInstances = new Map();

module.exports = {
  NativeModules: {
    LlamaMobileVD: {
      // VectorStore methods
      vectorStoreCreate: jest.fn((dimension, metric) => {
        const id = storeInstances.size + 1;
        storeInstances.set(id, { dimension, metric, vectors: new Map() });
        return Promise.resolve(id);
      }),
      vectorStoreAddVector: jest.fn((storeId, id, vector) => {
        const store = storeInstances.get(storeId);
        if (store) {
          store.vectors.set(id, vector);
          return Promise.resolve(true);
        }
        return Promise.resolve(false);
      }),
      vectorStoreSearch: jest.fn((storeId, queryVector, k) => {
        const store = storeInstances.get(storeId);
        if (store) {
          const results = [];
          for (let [vectorId, vector] of store.vectors.entries()) {
            let distance = 0;
            for (let i = 0; i < vector.length; i++) {
              distance += Math.pow(vector[i] - queryVector[i], 2);
            }
            results.push({ id: vectorId, distance: Math.sqrt(distance) });
          }
          results.sort((a, b) => a.distance - b.distance);
          return Promise.resolve(results.slice(0, k));
        }
        return Promise.resolve([]);
      }),
      vectorStoreGetVector: jest.fn((storeId, id) => {
        const store = storeInstances.get(storeId);
        if (store) {
          return Promise.resolve(store.vectors.get(id) || null);
        }
        return Promise.resolve(null);
      }),
      vectorStoreRemoveVector: jest.fn((storeId, id) => {
        const store = storeInstances.get(storeId);
        if (store) {
          return Promise.resolve(store.vectors.delete(id));
        }
        return Promise.resolve(false);
      }),
      vectorStoreContains: jest.fn((storeId, id) => {
        const store = storeInstances.get(storeId);
        if (store) {
          return Promise.resolve(store.vectors.has(id));
        }
        return Promise.resolve(false);
      }),
      vectorStoreGetSize: jest.fn((storeId) => {
        const store = storeInstances.get(storeId);
        if (store) {
          return Promise.resolve(store.vectors.size);
        }
        return Promise.resolve(0);
      }),
      vectorStoreGetDimension: jest.fn((storeId) => {
        const store = storeInstances.get(storeId);
        if (store) {
          return Promise.resolve(store.dimension);
        }
        return Promise.resolve(0);
      }),
      vectorStoreGetMetric: jest.fn((storeId) => {
        const store = storeInstances.get(storeId);
        if (store) {
          return Promise.resolve(store.metric);
        }
        return Promise.resolve(0);
      }),
      vectorStoreUpdateVector: jest.fn((storeId, id, vector) => {
        const store = storeInstances.get(storeId);
        if (store) {
          store.vectors.set(id, vector);
          return Promise.resolve(true);
        }
        return Promise.resolve(false);
      }),
      vectorStoreReserve: jest.fn(() => Promise.resolve(true)),
      vectorStoreClear: jest.fn((storeId) => {
        const store = storeInstances.get(storeId);
        if (store) {
          store.vectors.clear();
        }
        return Promise.resolve(true);
      }),
      vectorStoreDestroy: jest.fn((storeId) => {
        storeInstances.delete(storeId);
        return Promise.resolve(true);
      }),

      // HNSWIndex methods
      hnswIndexCreate: jest.fn((dimension, metric, maxElements) => {
        const id = hnswIndexInstances.size + 1;
        hnswIndexInstances.set(id, { dimension, metric, maxElements, vectors: new Map() });
        return Promise.resolve(id);
      }),
      hnswIndexCreateWithParams: jest.fn((dimension, metric, maxElements) => {
        const id = hnswIndexInstances.size + 1;
        hnswIndexInstances.set(id, { dimension, metric, maxElements, vectors: new Map() });
        return Promise.resolve(id);
      }),
      hnswIndexAddVector: jest.fn((indexId, id, vector) => {
        const index = hnswIndexInstances.get(indexId);
        if (index) {
          index.vectors.set(id, vector);
          return Promise.resolve(true);
        }
        return Promise.resolve(false);
      }),
      hnswIndexSearch: jest.fn((indexId, queryVector, k) => {
        const index = hnswIndexInstances.get(indexId);
        if (index) {
          const results = [];
          for (let [vectorId, vector] of index.vectors.entries()) {
            let distance = 0;
            for (let i = 0; i < vector.length; i++) {
              distance += Math.pow(vector[i] - queryVector[i], 2);
            }
            results.push({ id: vectorId, distance: Math.sqrt(distance) });
          }
          results.sort((a, b) => a.distance - b.distance);
          return Promise.resolve(results.slice(0, k));
        }
        return Promise.resolve([]);
      }),
      hnswIndexSetEfSearch: jest.fn(() => Promise.resolve(true)),
      hnswIndexGetEfSearch: jest.fn(() => Promise.resolve(10)),
      hnswIndexGetSize: jest.fn((indexId) => {
        const index = hnswIndexInstances.get(indexId);
        if (index) {
          return Promise.resolve(index.vectors.size);
        }
        return Promise.resolve(0);
      }),
      hnswIndexGetDimension: jest.fn((indexId) => {
        const index = hnswIndexInstances.get(indexId);
        if (index) {
          return Promise.resolve(index.dimension);
        }
        return Promise.resolve(0);
      }),
      hnswIndexGetCapacity: jest.fn((indexId) => {
        const index = hnswIndexInstances.get(indexId);
        if (index) {
          return Promise.resolve(index.maxElements);
        }
        return Promise.resolve(0);
      }),
      hnswIndexContains: jest.fn((indexId, id) => {
        const index = hnswIndexInstances.get(indexId);
        if (index) {
          return Promise.resolve(index.vectors.has(id));
        }
        return Promise.resolve(false);
      }),
      hnswIndexGetVector: jest.fn((indexId, id) => {
        const index = hnswIndexInstances.get(indexId);
        if (index) {
          return Promise.resolve(index.vectors.get(id) || null);
        }
        return Promise.resolve(null);
      }),
      hnswIndexSave: jest.fn(() => Promise.resolve(true)),
      hnswIndexLoad: jest.fn((filename) => {
        const id = hnswIndexInstances.size + 1;
        hnswIndexInstances.set(id, { dimension: 128, metric: 0, vectors: new Map() });
        return Promise.resolve(id);
      }),
      hnswIndexDestroy: jest.fn((indexId) => {
        hnswIndexInstances.delete(indexId);
        return Promise.resolve(true);
      }),

      // MMapVectorStoreBuilder methods
      mmapVectorStoreBuilderCreate: jest.fn((dimension, metric) => {
        const id = mmapBuilderInstances.size + 1;
        mmapBuilderInstances.set(id, { dimension, metric, vectors: new Map() });
        return Promise.resolve(id);
      }),
      mmapVectorStoreBuilderAddVector: jest.fn((builderId, id, vector) => {
        const builder = mmapBuilderInstances.get(builderId);
        if (builder) {
          builder.vectors.set(id, vector);
          return Promise.resolve(true);
        }
        return Promise.resolve(false);
      }),
      mmapVectorStoreBuilderReserve: jest.fn(() => Promise.resolve(true)),
      mmapVectorStoreBuilderSave: jest.fn(() => Promise.resolve(true)),
      mmapVectorStoreBuilderGetSize: jest.fn((builderId) => {
        const builder = mmapBuilderInstances.get(builderId);
        if (builder) {
          return Promise.resolve(builder.vectors.size);
        }
        return Promise.resolve(0);
      }),
      mmapVectorStoreBuilderGetDimension: jest.fn((builderId) => {
        const builder = mmapBuilderInstances.get(builderId);
        if (builder) {
          return Promise.resolve(builder.dimension);
        }
        return Promise.resolve(0);
      }),
      mmapVectorStoreBuilderDestroy: jest.fn((builderId) => {
        mmapBuilderInstances.delete(builderId);
        return Promise.resolve(true);
      }),

      // MMapVectorStore methods
      mmapVectorStoreOpen: jest.fn((filename) => {
        const id = mmapStoreInstances.size + 1;
        mmapStoreInstances.set(id, { filename, dimension: 128, metric: 0 });
        return Promise.resolve(id);
      }),
      mmapVectorStoreGetVector: jest.fn(() => Promise.resolve(null)),
      mmapVectorStoreContains: jest.fn(() => Promise.resolve(false)),
      mmapVectorStoreSearch: jest.fn(() => Promise.resolve([])),
      mmapVectorStoreGetSize: jest.fn(() => Promise.resolve(0)),
      mmapVectorStoreGetDimension: jest.fn((storeId) => {
        const store = mmapStoreInstances.get(storeId);
        if (store) {
          return Promise.resolve(store.dimension);
        }
        return Promise.resolve(0);
      }),
      mmapVectorStoreGetMetric: jest.fn((storeId) => {
        const store = mmapStoreInstances.get(storeId);
        if (store) {
          return Promise.resolve(store.metric);
        }
        return Promise.resolve(0);
      }),
      mmapVectorStoreClose: jest.fn((storeId) => {
        mmapStoreInstances.delete(storeId);
        return Promise.resolve(true);
      }),

      // Version methods
      getVersion: jest.fn(() => Promise.resolve('1.0.0')),
      getGitCommit: jest.fn(() => Promise.resolve('mock-commit')),
      getBuildDate: jest.fn(() => Promise.resolve('2026-01-22')),
    },
  },
};
EOF
else
    echo "__mocks__/react-native.js already exists, skipping creation"
fi

# Create test file
echo "Creating test file..."
if [ ! -f "$REACTNATIVE_SDK_DIR/test/index.test.js" ]; then
    cat > "$REACTNATIVE_SDK_DIR/test/index.test.js" << 'EOF'
const LlamaMobileVD = require('../src/index');

describe('LlamaMobileVD ReactNative SDK', () => {
  // Test dimensions from 128 to 3096
  const dimensions = [128, 512, 1024, 2048, 3096];
  // Test dataset sizes from 100 to 10000
  const datasetSizes = [100, 1000, 5000, 10000];

  // Test VectorStore with different dimensions
  dimensions.forEach(dimension => {
    describe(`VectorStore - Dimension ${dimension}`, () => {
      let storeId;

      beforeEach(async () => {
        storeId = await LlamaMobileVD.vectorStoreCreate(dimension, 0); // 0 = L2 metric
      });

      test('should create vector store', async () => {
        expect(typeof storeId).toBe('number');
      });

      test('should add vector', async () => {
        const vector = Array(dimension).fill(0).map(() => Math.random());
        const result = await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);
        expect(result).toBe(true);
      });

      test('should search vectors', async () => {
        // Add a vector
        const vector = Array(dimension).fill(0).map(() => Math.random());
        await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);
        
        // Search for it
        const results = await LlamaMobileVD.vectorStoreSearch(storeId, vector, 1);
        expect(Array.isArray(results)).toBe(true);
      });

      test('should get vector', async () => {
        const vector = Array(dimension).fill(0).map(() => Math.random());
        await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);
        const retrievedVector = await LlamaMobileVD.vectorStoreGetVector(storeId, 1);
        expect(Array.isArray(retrievedVector)).toBe(true);
      });

      test('should remove vector', async () => {
        const vector = Array(dimension).fill(0).map(() => Math.random());
        await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);
        const removed = await LlamaMobileVD.vectorStoreRemoveVector(storeId, 1);
        expect(removed).toBe(true);
      });

      test('should check if vector exists', async () => {
        const vector = Array(dimension).fill(0).map(() => Math.random());
        await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);
        const contains = await LlamaMobileVD.vectorStoreContains(storeId, 1);
        expect(contains).toBe(true);
      });

      test('should get store size', async () => {
        const vector = Array(dimension).fill(0).map(() => Math.random());
        await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);
        const size = await LlamaMobileVD.vectorStoreGetSize(storeId);
        expect(typeof size).toBe('number');
      });

      test('should get store dimension', async () => {
        const result = await LlamaMobileVD.vectorStoreGetDimension(storeId);
        expect(result).toBe(dimension);
      });

      test('should get store metric', async () => {
        const result = await LlamaMobileVD.vectorStoreGetMetric(storeId);
        expect(typeof result).toBe('number');
      });

      test('should update vector', async () => {
        const vector1 = Array(dimension).fill(0).map(() => Math.random());
        const vector2 = Array(dimension).fill(0).map(() => Math.random());
        await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector1);
        const updated = await LlamaMobileVD.vectorStoreUpdateVector(storeId, 1, vector2);
        expect(updated).toBe(true);
      });

      test('should reserve capacity', async () => {
        const result = await LlamaMobileVD.vectorStoreReserve(storeId, 100);
        expect(result).toBe(true);
      });

      test('should clear store', async () => {
        const vector = Array(dimension).fill(0).map(() => Math.random());
        await LlamaMobileVD.vectorStoreAddVector(storeId, 1, vector);
        const cleared = await LlamaMobileVD.vectorStoreClear(storeId);
        expect(cleared).toBe(true);
      });

      test('should destroy store', async () => {
        const result = await LlamaMobileVD.vectorStoreDestroy(storeId);
        expect(result).toBe(true);
      });
    });
  });

  // Test HNSWIndex
  describe('HNSWIndex', () => {
    let indexId;

    beforeEach(async () => {
      indexId = await LlamaMobileVD.hnswIndexCreate(128, 0, 1000);
    });

    test('should create HNSW index', async () => {
      expect(typeof indexId).toBe('number');
    });

    test('should add vector to HNSW index', async () => {
      const vector = Array(128).fill(0).map(() => Math.random());
      const result = await LlamaMobileVD.hnswIndexAddVector(indexId, 1, vector);
      expect(result).toBe(true);
    });

    test('should search HNSW index', async () => {
      const vector = Array(128).fill(0).map(() => Math.random());
      await LlamaMobileVD.hnswIndexAddVector(indexId, 1, vector);
      const results = await LlamaMobileVD.hnswIndexSearch(indexId, vector, 1);
      expect(Array.isArray(results)).toBe(true);
    });

    test('should set and get efSearch', async () => {
      await LlamaMobileVD.hnswIndexSetEfSearch(indexId, 100);
      const efSearch = await LlamaMobileVD.hnswIndexGetEfSearch(indexId);
      expect(typeof efSearch).toBe('number');
    });

    test('should get index size', async () => {
      const size = await LlamaMobileVD.hnswIndexGetSize(indexId);
      expect(typeof size).toBe('number');
    });

    test('should get index dimension', async () => {
      const dimension = await LlamaMobileVD.hnswIndexGetDimension(indexId);
      expect(typeof dimension).toBe('number');
    });

    test('should get index capacity', async () => {
      const capacity = await LlamaMobileVD.hnswIndexGetCapacity(indexId);
      expect(typeof capacity).toBe('number');
    });

    test('should check if vector exists in index', async () => {
      const vector = Array(128).fill(0).map(() => Math.random());
      await LlamaMobileVD.hnswIndexAddVector(indexId, 1, vector);
      const contains = await LlamaMobileVD.hnswIndexContains(indexId, 1);
      expect(typeof contains).toBe('boolean');
    });

    test('should get vector from index', async () => {
      const vector = Array(128).fill(0).map(() => Math.random());
      await LlamaMobileVD.hnswIndexAddVector(indexId, 1, vector);
      const retrievedVector = await LlamaMobileVD.hnswIndexGetVector(indexId, 1);
      expect(Array.isArray(retrievedVector)).toBe(true);
    });

    test('should save and load index', async () => {
      const saved = await LlamaMobileVD.hnswIndexSave(indexId, 'test.index');
      expect(saved).toBe(true);
      
      const loadedIndexId = await LlamaMobileVD.hnswIndexLoad('test.index');
      expect(typeof loadedIndexId).toBe('number');
    });

    test('should destroy index', async () => {
      const result = await LlamaMobileVD.hnswIndexDestroy(indexId);
      expect(result).toBe(true);
    });
  });

  // Test MMapVectorStoreBuilder
  describe('MMapVectorStoreBuilder', () => {
    let builderId;

    beforeEach(async () => {
      builderId = await LlamaMobileVD.mmapVectorStoreBuilderCreate(128, 0);
    });

    test('should create builder', async () => {
      expect(typeof builderId).toBe('number');
    });

    test('should add vector to builder', async () => {
      const vector = Array(128).fill(0).map(() => Math.random());
      const result = await LlamaMobileVD.mmapVectorStoreBuilderAddVector(builderId, 1, vector);
      expect(result).toBe(true);
    });

    test('should reserve capacity', async () => {
      const result = await LlamaMobileVD.mmapVectorStoreBuilderReserve(builderId, 100);
      expect(result).toBe(true);
    });

    test('should save builder', async () => {
      const result = await LlamaMobileVD.mmapVectorStoreBuilderSave(builderId, 'test.mmap');
      expect(result).toBe(true);
    });

    test('should get builder size', async () => {
      const size = await LlamaMobileVD.mmapVectorStoreBuilderGetSize(builderId);
      expect(typeof size).toBe('number');
    });

    test('should get builder dimension', async () => {
      const dimension = await LlamaMobileVD.mmapVectorStoreBuilderGetDimension(builderId);
      expect(typeof dimension).toBe('number');
    });

    test('should destroy builder', async () => {
      const result = await LlamaMobileVD.mmapVectorStoreBuilderDestroy(builderId);
      expect(result).toBe(true);
    });
  });

  // Test MMapVectorStore
  describe('MMapVectorStore', () => {
    let storeId;

    beforeEach(async () => {
      storeId = await LlamaMobileVD.mmapVectorStoreOpen('test.mmap');
    });

    test('should open store', async () => {
      expect(typeof storeId).toBe('number');
    });

    test('should get vector', async () => {
      const vector = await LlamaMobileVD.mmapVectorStoreGetVector(storeId, 1);
      expect(vector).toBe(null); // No vectors in mock
    });

    test('should check if vector exists', async () => {
      const contains = await LlamaMobileVD.mmapVectorStoreContains(storeId, 1);
      expect(contains).toBe(false); // No vectors in mock
    });

    test('should search store', async () => {
      const vector = Array(128).fill(0).map(() => Math.random());
      const results = await LlamaMobileVD.mmapVectorStoreSearch(storeId, vector, 1);
      expect(Array.isArray(results)).toBe(true);
    });

    test('should get store size', async () => {
      const size = await LlamaMobileVD.mmapVectorStoreGetSize(storeId);
      expect(typeof size).toBe('number');
    });

    test('should get store dimension', async () => {
      const dimension = await LlamaMobileVD.mmapVectorStoreGetDimension(storeId);
      expect(typeof dimension).toBe('number');
    });

    test('should get store metric', async () => {
      const metric = await LlamaMobileVD.mmapVectorStoreGetMetric(storeId);
      expect(typeof metric).toBe('number');
    });

    test('should close store', async () => {
      const result = await LlamaMobileVD.mmapVectorStoreClose(storeId);
      expect(result).toBe(true);
    });
  });

  // Test version methods
  describe('Version Methods', () => {
    test('should get version', async () => {
      const version = await LlamaMobileVD.getVersion();
      expect(typeof version).toBe('string');
    });

    test('should get git commit', async () => {
      const gitCommit = await LlamaMobileVD.getGitCommit();
      expect(typeof gitCommit).toBe('string');
    });

    test('should get build date', async () => {
      const buildDate = await LlamaMobileVD.getBuildDate();
      expect(typeof buildDate).toBe('string');
    });
  });

  // Test with different dataset sizes
  datasetSizes.forEach(size => {
    describe(`Dataset Size - ${size} vectors`, () => {
      let storeId;

      beforeEach(async () => {
        storeId = await LlamaMobileVD.vectorStoreCreate(128, 0);
      });

      test(`should handle ${size} vectors`, async () => {
        // Add multiple vectors
        for (let i = 1; i <= size; i++) {
          const vector = Array(128).fill(0).map(() => Math.random());
          await LlamaMobileVD.vectorStoreAddVector(storeId, i, vector);
        }

        // Verify store size
        const storeSize = await LlamaMobileVD.vectorStoreGetSize(storeId);
        expect(typeof storeSize).toBe('number');
      });
    });
  });
});
EOF
else
    echo "test/index.test.js already exists, skipping creation"
fi

echo "ReactNative SDK build completed successfully!"
