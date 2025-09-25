#!/bin/bash

# Deployment script for ElimuConnect

set -e

ENVIRONMENT=${1:-staging}

echo "🚀 Deploying ElimuConnect to $ENVIRONMENT..."

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    echo "❌ Invalid environment. Use 'staging' or 'production'"
    exit 1
fi

# Build all packages
echo "🏗️  Building all packages..."
./tools/scripts/build_all.sh

# Deploy backend
echo "🔧 Deploying backend..."
if [ "$ENVIRONMENT" = "production" ]; then
    docker-compose -f docker-compose.prod.yml up -d --build
else
    docker-compose -f docker-compose.staging.yml up -d --build
fi

# Deploy Flutter web app
echo "📱 Deploying web application..."
cd packages/app
flutter build web --release
# Copy to web server or CDN
cd ../..

# Deploy admin dashboard
echo "👨‍💼 Deploying admin dashboard..."
cd packages/web_admin
flutter build web --release
# Copy to web server or CDN
cd ../..

echo "✅ Deployment to $ENVIRONMENT completed successfully!"
