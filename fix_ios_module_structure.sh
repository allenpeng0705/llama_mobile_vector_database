#!/bin/bash

# Script to fix iOS framework module structure for all SDKs

# Function to add module structure to a framework
fix_framework() {
    local framework_path="$1"
    
    if [ -d "$framework_path" ]; then
        echo "Fixing module structure for $framework_path"
        
        # Create Modules directory if it doesn't exist
        mkdir -p "$framework_path/Modules"
        
        # Create module.modulemap file
        cat > "$framework_path/Modules/module.modulemap" << 'MODULE_EOF'
module LlamaMobileVD {
    header "../Headers/LlamaMobileVD.h"
    export *
}
MODULE_EOF
        
        echo "✓ Fixed module structure for $framework_path"
    else
        echo "✗ Framework not found: $framework_path"
    fi
}

# List of frameworks to fix
frameworks=(
    "/Users/shileipeng/Documents/mygithub/llama_mobile_vector_database/llama_mobile_vd-ios-SDK/ios/Frameworks/LlamaMobileVD.framework"
    "/Users/shileipeng/Documents/mygithub/llama_mobile_vector_database/llama_mobile_vd-flutter-SDK/ios/LlamaMobileVD.framework"
    "/Users/shileipeng/Documents/mygithub/llama_mobile_vector_database/llama_mobile_vd-capacitor-plugin/ios/LlamaMobileVD.framework"
    "/Users/shileipeng/Documents/mygithub/llama_mobile_vector_database/llama_mobile_vd-react-native-SDK/ios/LlamaMobileVD.framework"
)

# Fix all frameworks
echo "Starting iOS framework module structure fix..."
for framework in "${frameworks[@]}"; do
    fix_framework "$framework"
done

echo ""
echo "All frameworks processed!"
echo "Note: This script should be run whenever iOS frameworks are updated or regenerated."
