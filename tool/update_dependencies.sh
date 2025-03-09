#!/bin/bash

# Make the script exit on any error
set -e

echo "🧹 Cleaning project..."
flutter clean

echo "♻️ Deleting Pods..."
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

echo "🗑️ Removing old dependencies..."
rm -f ios/Podfile.lock
rm -f pubspec.lock

echo "📦 Getting dependencies..."
flutter pub get

echo "🔄 Updating pods..."
cd ios
pod install --repo-update
cd ..

echo "✨ Running pub upgrade..."
flutter pub upgrade --major-versions

echo "🏃‍♂️ Building runner..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ Dependencies updated successfully!" 