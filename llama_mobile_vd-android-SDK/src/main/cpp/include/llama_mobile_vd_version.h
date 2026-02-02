// LLAMA_MOBILE_VD Version Header - Copyright (c) 2025 - MIT License
#pragma once

/**
 * @file llama_mobile_vd_version.h
 * @brief Llama Mobile VD version information.
 * 
 * This file defines the version information for the Llama Mobile VD library
 * and all its SDKs. It serves as the single source of version truth for the entire project.
 */

// Major version number
#define LLAMA_MOBILE_VD_VERSION_MAJOR 0

// Minor version number
#define LLAMA_MOBILE_VD_VERSION_MINOR 1

// Patch version number
#define LLAMA_MOBILE_VD_VERSION_PATCH 0

// Full version string
#define LLAMA_MOBILE_VD_VERSION_STRING "0.1.0"

// Version as a single integer for comparison
// Format: MAJOR * 10000 + MINOR * 100 + PATCH
#define LLAMA_MOBILE_VD_VERSION_NUMBER (LLAMA_MOBILE_VD_VERSION_MAJOR * 10000 + LLAMA_MOBILE_VD_VERSION_MINOR * 100 + LLAMA_MOBILE_VD_VERSION_PATCH)

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Returns the version string of the Llama Mobile VD library.
 * @return A null-terminated string containing the version information.
 */
const char* llama_mobile_vd_version();

/**
 * @brief Returns the major version number of the Llama Mobile VD library.
 * @return The major version number.
 */
int llama_mobile_vd_version_major();

/**
 * @brief Returns the minor version number of the Llama Mobile VD library.
 * @return The minor version number.
 */
int llama_mobile_vd_version_minor();

/**
 * @brief Returns the patch version number of the Llama Mobile VD library.
 * @return The patch version number.
 */
int llama_mobile_vd_version_patch();

#ifdef __cplusplus
}
#endif
