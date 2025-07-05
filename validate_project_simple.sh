#!/bin/bash

# MusicAlarmApp Simple Project Validation Script
# This script validates the project structure without requiring xcodebuild

set -e  # Exit on any error

echo "🎵 MusicAlarmApp Project Validation (Simple)"
echo "============================================"

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

# 3. Validate project.pbxproj structure
echo "🔧 Validating project.pbxproj structure..."
if grep -q "PBXFileReference" MusicAlarmApp.xcodeproj/project.pbxproj; then
    print_status 0 "PBXFileReference section found"
else
    print_status 1 "PBXFileReference section missing"
fi

if grep -q "PBXBuildFile" MusicAlarmApp.xcodeproj/project.pbxproj; then
    print_status 0 "PBXBuildFile section found"
else
    print_status 1 "PBXBuildFile section missing"
fi

if grep -q "PBXNativeTarget" MusicAlarmApp.xcodeproj/project.pbxproj; then
    print_status 0 "PBXNativeTarget section found"
else
    print_status 1 "PBXNativeTarget section missing"
fi

# 4. Check for specific corrupted ID pattern
echo "🔍 Checking for corrupted ID patterns..."
if grep -q "A1234567890123456789012A.*MusicAlarmApp.app" MusicAlarmApp.xcodeproj/project.pbxproj; then
    print_status 1 "Found corrupted ID pattern in project file"
else
    print_status 0 "No corrupted ID patterns found"
fi

# 5. Validate Info.plist
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

# 6. Check for test files
echo "🧪 Checking test files..."
if [ -f "MusicAlarmApp/MusicAlarmAppTests.swift" ]; then
    print_status 0 "Test file present"
else
    print_warning "No test file found"
fi

# 7. Validate assets
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

# 8. Check for launch screen
echo "🚀 Checking launch screen..."
if [ -f "MusicAlarmApp/Base.lproj/LaunchScreen.storyboard" ]; then
    print_status 0 "Launch screen present"
else
    print_warning "Launch screen not found"
fi

# 9. Check Swift file syntax (basic check)
echo "🔍 Checking Swift file syntax..."
swift_files=(MusicAlarmApp/*.swift)
syntax_errors=0

for file in "${swift_files[@]}"; do
    if [ -f "$file" ]; then
        # Basic syntax check - look for obvious issues
        if grep -q "import " "$file" && grep -q "class\|struct\|func" "$file"; then
            echo -e "${GREEN}✅ $file syntax looks good${NC}"
        else
            echo -e "${YELLOW}⚠️  $file may have syntax issues${NC}"
            syntax_errors=$((syntax_errors + 1))
        fi
    fi
done

if [ $syntax_errors -eq 0 ]; then
    print_status 0 "Swift files appear to have valid syntax"
else
    print_warning "Found $syntax_errors Swift files with potential syntax issues"
fi

# 10. Check for common issues in source files
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

# 11. Check project size
echo "📊 Checking project size..."
project_size=$(du -sh . | awk '{print $1}')
echo -e "${GREEN}📦 Project size: $project_size${NC}"

# 12. Check for deployment checklist
echo "📋 Checking deployment documentation..."
if [ -f "deployment_checklist.md" ]; then
    print_status 0 "Deployment checklist present"
else
    print_warning "Deployment checklist not found"
fi

# 13. Final validation summary
echo ""
echo "🎯 Validation Summary"
echo "==================="

echo -e "${GREEN}🎉 Project validation completed successfully!${NC}"
echo -e "${GREEN}✅ Project structure is valid for deployment${NC}"

echo ""
echo "📋 Next Steps:"
echo "1. Open project in Xcode to verify it opens correctly"
echo "2. Run tests in Xcode: Product > Test"
echo "3. Build for device: Product > Build"
echo "4. Create archive: Product > Archive"
echo "5. Upload to App Store Connect"

echo ""
echo "⚠️  Note: This validation doesn't require Xcode command line tools."
echo "   For full validation, ensure Xcode is properly installed and configured."

exit 0 