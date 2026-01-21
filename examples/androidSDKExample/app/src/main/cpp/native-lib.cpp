#include <jni.h>

// Just a dummy function to force the app to include libc++_shared.so
extern "C" JNIEXPORT void JNICALL Java_com_llamamobile_androidsdkexample_MainActivity_nativeInit(JNIEnv* env, jobject /* this */) {
    // Do nothing
}
