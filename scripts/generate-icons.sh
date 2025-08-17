#!/bin/bash

# Generate app icons from SVG logo
# Requires: ImageMagick (brew install imagemagick)

echo "Generating Posta app icons..."

# Create output directories
mkdir -p assets/icons
mkdir -p assets/splash

# Generate app icons in various sizes
echo "Generating app icons..."

# iOS icons
convert -background white -density 300 logo-simple.svg -resize 1024x1024 assets/icons/ios-1024.png
convert -background white -density 300 logo-simple.svg -resize 180x180 assets/icons/ios-180.png
convert -background white -density 300 logo-simple.svg -resize 167x167 assets/icons/ios-167.png
convert -background white -density 300 logo-simple.svg -resize 152x152 assets/icons/ios-152.png
convert -background white -density 300 logo-simple.svg -resize 120x120 assets/icons/ios-120.png
convert -background white -density 300 logo-simple.svg -resize 87x87 assets/icons/ios-87.png
convert -background white -density 300 logo-simple.svg -resize 80x80 assets/icons/ios-80.png
convert -background white -density 300 logo-simple.svg -resize 76x76 assets/icons/ios-76.png
convert -background white -density 300 logo-simple.svg -resize 60x60 assets/icons/ios-60.png
convert -background white -density 300 logo-simple.svg -resize 40x40 assets/icons/ios-40.png
convert -background white -density 300 logo-simple.svg -resize 29x29 assets/icons/ios-29.png
convert -background white -density 300 logo-simple.svg -resize 20x20 assets/icons/ios-20.png

# Android icons
convert -background white -density 300 logo-simple.svg -resize 512x512 assets/icons/android-512.png
convert -background white -density 300 logo-simple.svg -resize 192x192 assets/icons/android-192.png
convert -background white -density 300 logo-simple.svg -resize 144x144 assets/icons/android-144.png
convert -background white -density 300 logo-simple.svg -resize 96x96 assets/icons/android-96.png
convert -background white -density 300 logo-simple.svg -resize 72x72 assets/icons/android-72.png
convert -background white -density 300 logo-simple.svg -resize 48x48 assets/icons/android-48.png
convert -background white -density 300 logo-simple.svg -resize 36x36 assets/icons/android-36.png

# Web icons
convert -background white -density 300 logo-simple.svg -resize 512x512 assets/icons/web-512.png
convert -background white -density 300 logo-simple.svg -resize 192x192 assets/icons/web-192.png
convert -background white -density 300 logo-simple.svg -resize 32x32 assets/icons/favicon.png

# Desktop icons
convert -background white -density 300 logo-simple.svg -resize 512x512 assets/icons/macos-512.png
convert -background white -density 300 logo-simple.svg -resize 256x256 assets/icons/macos-256.png
convert -background white -density 300 logo-simple.svg -resize 128x128 assets/icons/macos-128.png
convert -background white -density 300 logo-simple.svg -resize 64x64 assets/icons/macos-64.png
convert -background white -density 300 logo-simple.svg -resize 32x32 assets/icons/macos-32.png
convert -background white -density 300 logo-simple.svg -resize 16x16 assets/icons/macos-16.png

# Generate splash screens
echo "Generating splash screens..."
convert -background white -density 300 splash-screen.svg -resize 1080x1920 assets/splash/ios-splash.png
convert -background white -density 300 splash-screen.svg -resize 1080x1920 assets/splash/android-splash.png

echo "Icon generation complete!"
echo "Icons saved to assets/icons/"
echo "Splash screens saved to assets/splash/" 