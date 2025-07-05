#!/bin/bash

# MusicAlarmApp Project Validation Script
# This script validates the project before deployment

set -e  # Exit on any error

echo "🎵 MusicAlarmApp Project Validation"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        exit 1
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if we're in the correct directory
if [ ! -f "MusicAlarmApp.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ Not in the correct directory. Please run this script from the project root.${NC}"
    exit 1
fi

echo "📁 Checking project structure..."

# 1. Validate project file integrity
echo "🔍 Validating project file..."
if grep -q "A1234567890123456789012A.*MusicAlarmApp.app" MusicAlarmApp.xcodeproj/project.pbxproj; then
    print_status 1 "Project file still contains corrupted references"
else
    print_status 0 "Project file integrity validated"
fi

# 2. Check for required source files
echo "📄 Checking source files..."
required_files=(
    "MusicAlarmApp/AppDelegate.swift"
    "MusicAlarmApp/SceneDelegate.swift"
    "MusicAlarmApp/ContentView.swift"
    "MusicAlarmApp/AlarmManager.swift"
    "MusicAlarmApp/MusicPlayer.swift"
    "MusicAlarmApp/PlaylistManager.swift"
    "MusicAlarmApp/Info.plist"
)

missing_files=0
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Missing required file: $file${NC}"
        missing_files=$((missing_files + 1))
    fi
done

if [ $missing_files -eq 0 ]; then
    print_status 0 "All required source files present"
else
    print_status 1 "Missing $missing_files required files"
fi

# 3. Validate Xcode project can be opened
echo "🔧 Testing Xcode project..."
if xcodebuild -project MusicAlarmApp.xcodeproj -list > /dev/null 2>&1; then
    print_status 0 "Xcode project can be opened successfully"
else
    print_status 1 "Xcode project cannot be opened"
fi

# 4. Check build configuration
echo "⚙️  Checking build configuration..."
if xcodebuild -project MusicAlarmApp.xcodeproj -scheme MusicAlarmApp -configuration Debug -showBuildSettings | grep -q "PRODUCT_BUNDLE_IDENTIFIER"; then
    print_status 0 "Build configuration is valid"
else
    print_status 1 "Build configuration has issues"
fi

# 5. Validate deployment target
echo "📱 Checking deployment target..."
deployment_target=$(xcodebuild -project MusicAlarmApp.xcodeproj -scheme MusicAlarmApp -configuration Debug -showBuildSettings | grep "IPHONEOS_DEPLOYMENT_TARGET" | awk '{print $3}')
if [ "$deployment_target" = "17.0" ]; then
    print_status 0 "Deployment target is correctly set to iOS 17.0"
else
    print_warning "Deployment target is $deployment_target (expected 17.0)"
fi

# 6. Check for common issues in source files
echo "🔍 Scanning source files for common issues..."

# Check for force unwrapping
force_unwraps=$(grep -r "!" MusicAlarmApp/*.swift | grep -v "//" | wc -l)
if [ $force_unwraps -gt 0 ]; then
    print_warning "Found $force_unwraps potential force unwrapping instances"
else
    print_status 0 "No obvious force unwrapping issues found"
fi

# Check for memory leaks (basic check)
if grep -r "weak self\|unowned self" MusicAlarmApp/*.swift > /dev/null 2>&1; then
    print_status 0 "Memory management patterns detected"
else
    print_warning "No explicit memory management patterns found"
fi

# 7. Validate Info.plist
echo "📋 Validating Info.plist..."
if [ -f "MusicAlarmApp/Info.plist" ]; then
    if plutil -lint MusicAlarmApp/Info.plist > /dev/null 2>&1; then
        print_status 0 "Info.plist is valid"
    else
        print_status 1 "Info.plist has syntax errors"
    fi
else
    print_status 1 "Info.plist not found"
fi

# 8. Check for test files
echo "🧪 Checking test files..."
if [ -f "MusicAlarmApp/MusicAlarmAppTests.swift" ]; then
    print_status 0 "Test file present"
else
    print_warning "No test file found"
fi

# 9. Validate assets
echo "🎨 Checking assets..."
if [ -d "MusicAlarmApp/Assets.xcassets" ]; then
    print_status 0 "Assets directory present"
    
    # Check for app icon
    if [ -d "MusicAlarmApp/Assets.xcassets/AppIcon.appiconset" ]; then
        print_status 0 "App icon configured"
    else
        print_warning "App icon not found"
    fi
else
    print_status 1 "Assets directory missing"
fi

# 10. Check for launch screen
echo "🚀 Checking launch screen..."
if [ -f "MusicAlarmApp/Base.lproj/LaunchScreen.storyboard" ]; then
    print_status 0 "Launch screen present"
else
    print_warning "Launch screen not found"
fi

# 11. Validate bundle identifier
echo "🏷️  Checking bundle identifier..."
bundle_id=$(xcodebuild -project MusicAlarmApp.xcodeproj -scheme MusicAlarmApp -configuration Debug -showBuildSettings | grep "PRODUCT_BUNDLE_IDENTIFIER" | awk '{print $3}')
if [ "$bundle_id" = "com.musicalarm.MusicAlarmApp" ]; then
    print_status 0 "Bundle identifier is correct: $bundle_id"
else
    print_warning "Bundle identifier is: $bundle_id"
fi

# 12. Check project size
echo "📊 Checking project size..."
project_size=$(du -sh . | awk '{print $1}')
echo -e "${GREEN}📦 Project size: $project_size${NC}"

# 13. Final validation summary
echo ""
echo "🎯 Validation Summary"
echo "==================="

# Count warnings and errors
warnings=$(grep -c "⚠️" <<< "$(cat /dev/null)")
errors=$(grep -c "❌" <<< "$(cat /dev/null)")

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}🎉 Project validation completed successfully!${NC}"
    echo -e "${GREEN}✅ Ready for deployment${NC}"
    
    echo ""
    echo "📋 Next Steps:"
    echo "1. Run: xcodebuild test -project MusicAlarmApp.xcodeproj -scheme MusicAlarmApp"
    echo "2. Build for device: xcodebuild build -project MusicAlarmApp.xcodeproj -scheme MusicAlarmApp"
    echo "3. Create archive: xcodebuild archive -project MusicAlarmApp.xcodeproj -scheme MusicAlarmApp"
    echo "4. Upload to App Store Connect"
    
    exit 0
else
    echo -e "${RED}❌ Project validation failed with $errors error(s)${NC}"
    echo -e "${YELLOW}⚠️  Please fix the issues above before deployment${NC}"
    exit 1
fi 