#!/bin/bash

# Navigate to project root
cd "$(dirname "$0")"

echo "Cleaning Flutter project..."
flutter clean

echo "Removing derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "Removing Pods..."
cd ios
rm -rf Pods
rm -rf .symlinks
rm -f Podfile.lock

echo "Reinstalling pods..."
pod deintegrate
pod setup
pod install

echo "Updating Flutter dependencies..."
cd ..
flutter pub get

echo "Opening Xcode workspace..."
open ios/Runner.xcworkspace

echo "Done! Now try building your project in Xcode." 