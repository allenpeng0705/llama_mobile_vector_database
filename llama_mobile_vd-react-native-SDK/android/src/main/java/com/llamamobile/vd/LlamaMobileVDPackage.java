package com.llamamobile.vd;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * React Native package for LlamaMobileVD vector database
 * Implements ReactPackage to register the native module
 */
public class LlamaMobileVDPackage implements ReactPackage {

    /**
     * Creates and returns the LlamaMobileVDModule
     * @param reactContext The React application context
     * @return A list containing the LlamaMobileVDModule
     */
    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();
        modules.add(new LlamaMobileVDModule(reactContext));
        return modules;
    }

    /**
     * Returns an empty list since this package doesn't provide any view managers
     * @param reactContext The React application context
     * @return An empty list
     */
    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }
}