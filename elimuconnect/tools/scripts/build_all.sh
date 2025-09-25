#!/bin/bash

# Build all packages script

set -e

echo "🏗️  Building all ElimuConnect packages..."

# Clean everything first
echo "🧹 Cleaning previous builds..."
melos run clean:deep

# Bootstrap dependencies
echo "📦 Bootstrapping dependencies..."
melos bootstrap

# Generate code
echo "🔄 Generating code..."
melos run gen

# Analyze code
echo "🔍 Analyzing code..."
melos run analyze

# Run tests
echo "🧪 Running tests..."
melos run test

# Build backend
echo "🔧 Building backend..."
melos run build:backend

# Build Flutter apps
echo "📱 Building Flutter applications..."
melos run build:app

echo "✅ All packages built successfully!"
