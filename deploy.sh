#!/bin/bash
set -e  # Exit immediately if a command fails

# Define build and deployment directories
BUILD_DIR="build/web"
DEPLOY_BRANCH="gh-pages"
TEMP_DIR="$(mktemp -d)"

echo "Building Flutter web project..."
flutter build web

echo "Preparing temporary deployment directory..."
cp -r $BUILD_DIR/* $TEMP_DIR

cd $TEMP_DIR

echo "Initializing temporary git repo..."
git init
git remote add origin "$(git config --get remote.origin.url)"
git checkout -b $DEPLOY_BRANCH
git add .
git commit -m "build: $(date '+%Y-%m-%d %H:%M:%S')"

echo "Pushing to $DEPLOY_BRANCH branch..."
git push --force origin $DEPLOY_BRANCH

echo "Deployment complete!"