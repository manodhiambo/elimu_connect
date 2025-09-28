#!/bin/bash

# ElimuConnect App Deployment Script
set -e

echo "🚀 Starting ElimuConnect app deployment..."

# Go to the root directory first
cd ~/elimu_connect/elimuconnect

echo "📍 Current location: $(pwd)"

# The Flutter app is in packages/app
FLUTTER_APP_DIR="packages/app"
echo "📱 Flutter app directory: $FLUTTER_APP_DIR"

# Verify the Flutter app exists
if [ ! -f "$FLUTTER_APP_DIR/lib/main.dart" ]; then
    echo "❌ Flutter app not found in $FLUTTER_APP_DIR"
    exit 1
fi

if [ ! -f "$FLUTTER_APP_DIR/pubspec.yaml" ]; then
    echo "❌ pubspec.yaml not found in $FLUTTER_APP_DIR"
    exit 1
fi

echo "✅ Flutter app found at $FLUTTER_APP_DIR"

# Change to the Flutter app directory
cd "$FLUTTER_APP_DIR"
echo "📍 Now in: $(pwd)"

# Check Flutter
echo "🔧 Checking Flutter installation..."
flutter --version

# Clean and rebuild
echo "🧹 Cleaning Flutter project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

# Build the web app
echo "🔨 Building Flutter web app..."
if ! flutter build web --release; then
    echo "❌ Flutter build failed!"
    echo "💡 Check for compilation errors above"
    exit 1
fi

# Verify build succeeded
if [ ! -d "build/web" ]; then
    echo "❌ Build directory not created"
    exit 1
fi

if [ ! -f "build/web/index.html" ]; then
    echo "❌ index.html not created in build"
    exit 1
fi

echo "✅ Flutter build completed successfully!"
echo "📄 Build contents:"
ls -la build/web/

# Go back to root for Firebase deployment
cd ~/elimu_connect/elimuconnect

# Update Firebase configuration to point to the app's build directory
echo "🔧 Updating Firebase configuration..."

cat > firebase.json << 'EOF'
{
  "hosting": {
    "public": "packages/app/build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
EOF

echo "✅ Firebase configuration updated to use packages/app/build/web"

# Verify Firebase setup
echo "🔥 Checking Firebase setup..."

if [ ! -f ".firebaserc" ]; then
    echo "❌ .firebaserc not found. Please run 'firebase init' first"
    exit 1
fi

# Get project ID
PROJECT_ID=$(grep -o '"project_id": "[^"]*' .firebaserc 2>/dev/null | grep -o '[^"]*$' || echo "unknown")
echo "📋 Firebase Project ID: $PROJECT_ID"

# Check if we're logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged into Firebase. Please run: firebase login"
    exit 1
fi

# Deploy
echo "🚀 Deploying to Firebase Hosting..."
if firebase deploy --only hosting; then
    echo ""
    echo "🎉 Deployment successful!"
    echo ""
    echo "🌍 Your ElimuConnect app is now live at:"
    echo "   🔗 https://$PROJECT_ID.web.app"
    echo "   🔗 https://$PROJECT_ID.firebaseapp.com"
    echo ""
    echo "💡 If you still see the Firebase welcome page:"
    echo "   1. Wait 2-3 minutes for CDN propagation"
    echo "   2. Clear your browser cache (Ctrl+Shift+R or Cmd+Shift+R)"
    echo "   3. Try incognito/private browsing mode"
    echo "   4. Check the browser console for any errors"
    echo ""
    echo "🔧 If there are issues, check:"
    echo "   - Browser developer tools (F12)"
    echo "   - Firebase Hosting logs in the console"
else
    echo "❌ Firebase deployment failed!"
    echo "💡 Common fixes:"
    echo "   - Run: firebase login --reauth"
    echo "   - Check project permissions"
    echo "   - Verify .firebaserc has correct project"
    exit 1
fi

echo "✅ ElimuConnect deployment completed successfully!"
