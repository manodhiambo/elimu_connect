#!/bin/bash

# ElimuConnect Development Environment Setup Script

set -e

echo "🚀 Setting up ElimuConnect development environment..."

# Check if required tools are installed
echo "📋 Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed. Please install Docker first."
    exit 1
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is required but not installed. Please install Docker Compose first."
    exit 1
fi

# Check Dart
if ! command -v dart &> /dev/null; then
    echo "❌ Dart is required but not installed. Please install Dart first."
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is required but not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Prerequisites check passed!"

# Install Melos globally
echo "📦 Installing Melos..."
dart pub global activate melos

# Create .env file from .env.example if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please update .env file with your specific configuration values."
fi

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Bootstrap the monorepo
echo "🔧 Bootstrapping monorepo..."
melos bootstrap

# Generate code
echo "🏗️  Generating code..."
melos run gen

# Run tests to ensure everything is working
echo "🧪 Running tests..."
melos run test

echo "🎉 Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env file with your configuration"
echo "2. Run 'cd packages/app && flutter run' to start the mobile app"
echo "3. Run 'cd packages/backend && dart run bin/server.dart' to start the backend"
echo "4. Visit http://localhost:8080/health to verify backend is running"
echo ""
echo "Happy coding! 🚀"
