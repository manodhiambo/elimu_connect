#!/bin/bash

# Code generation script for ElimuConnect

set -e

echo "🔄 Starting code generation..."

# Check if Melos is installed
if ! command -v melos &> /dev/null; then
    echo "# ElimuConnect Missing Files Implementation

Based on the comprehensive roadmap structure, here are the missing critical files:

## Core Missing Files

### File: `.github/workflows/ci.yml`
```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: 3.2.0
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install Melos
        run: dart pub global activate melos

      - name: Bootstrap packages
        run: melos bootstrap

      - name: Run analysis
        run: melos run analyze

      - name: Run tests
        run: melos run test

  build-backend:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: 3.2.0

      - name: Install Melos
        run: dart pub global activate melos

      - name: Bootstrap packages
        run: melos bootstrap

      - name: Build backend
        run: melos run build:backend

  build-flutter:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install Melos
        run: dart pub global activate melos

      - name: Bootstrap packages
        run: melos bootstrap

      - name: Build Flutter apps
        run: melos run build:app
