#!/bin/bash

# Make the script exit on any error
set -e

# Function to print section headers
print_section() {
  echo ""
  echo "🔄 $1..."
  echo "--------------------"
}

print_section "Cleaning build cache"
rm -rf build
rm -rf .dart_tool/build
rm -rf .dart_tool/flutter_build
rm -rf ios/Pods
rm -rf ios/Flutter/Flutter.framework
rm -rf android/.gradle
rm -rf android/app/build

print_section "Cleaning Dart cache"
flutter clean

print_section "Updating dependencies"
flutter pub get
flutter pub upgrade

print_section "Installing pods"
cd ios
pod install --repo-update
cd ..

print_section "Enabling performance optimizations"
# iOS optimizations
defaults write com.apple.dt.XCBuild EnableSwiftBuildSystemIntegration 1
defaults write com.apple.dt.XCBuild EnableBuildSystemDeprecationDiagnostic 1

# Android optimizations
if [ -d "android" ]; then
  echo "Optimizing Android build..."
  cd android
  
  # Clean Android builds
  ./gradlew clean
  
  # Enable daemon for faster builds
  mkdir -p ~/.gradle
  echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties
  echo "org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=4096m -XX:+HeapDumpOnOutOfMemoryError" >> ~/.gradle/gradle.properties
  echo "org.gradle.parallel=true" >> ~/.gradle/gradle.properties
  echo "org.gradle.configureondemand=true" >> ~/.gradle/gradle.properties
  echo "android.enableR8=true" >> ~/.gradle/gradle.properties
  echo "android.enableD8=true" >> ~/.gradle/gradle.properties
  
  cd ..
fi

print_section "Building iOS"
flutter build ios \
  --release \
  --dart-define=Dart_DefineSymbol=dart.vm.product=true \
  --tree-shake-icons \
  --split-debug-info=build/debug-info \
  --obfuscate \
  --split-debug-info=symbols/ \
  --no-codesign

if [ -d "android" ]; then
  print_section "Building Android"
  flutter build apk \
    --release \
    --dart-define=Dart_DefineSymbol=dart.vm.product=true \
    --tree-shake-icons \
    --split-debug-info=build/debug-info \
    --obfuscate \
    --target-platform android-arm64 \
    --split-per-abi
fi

print_section "Running performance analysis"
flutter analyze
flutter run --profile --trace-startup

echo "✨ Build optimization complete!"
echo "📱 Check build/ios/iphoneos for iOS build"
echo "📱 Check build/app/outputs/flutter-apk for Android build" 