# Add project specific consumer ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your library depends on other libraries, you must include the
# consumer proguard rules of those libraries here.

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep LlamaMobileVD class and its methods
-keep class com.llamamobile.vd.LlamaMobileVD {
    *;
}

# Keep SearchResult class
-keep class com.llamamobile.vd.SearchResult {
    *;
}

# Keep LlamaMobileVDException class
-keep class com.llamamobile.vd.LlamaMobileVDException {
    *;
}
