#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting post-create script..."

# --- Update and install system dependencies ---
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libpulse0 \
    libglu1-mesa \
    unzip \
    wget \
    tigervnc-standalone-server \
    websockify \
    # Add any other dependencies your project might need

# --- Install Android SDK ---
ANDROID_SDK_ROOT="/opt/sdk"
sudo mkdir -p $ANDROID_SDK_ROOT
sudo chown -R $(whoami) $ANDROID_SDK_ROOT

# Download and extract Android command line tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O commandlinetools.zip
unzip -q commandlinetools.zip -d $ANDROID_SDK_ROOT/cmdline-tools
rm commandlinetools.zip
# Rename to the expected 'latest' directory
mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest

# Set up environment variables for Android
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"
export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT

# Add to .bashrc so it's available in all terminals
echo 'export ANDROID_SDK_ROOT="/opt/sdk"' >> ~/.bashrc
echo 'export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"' >> ~/.bashrc

# --- Install Android packages (emulator, platform-tools, system image) ---
echo "Installing Android SDK packages..."
# The 'yes' command automatically accepts all licenses
yes | sdkmanager --licenses > /dev/null
sdkmanager "platform-tools" "platforms;android-34" "emulator" "system-images;android-34;google_apis;x86_64"

# --- Create the Android Virtual Device (AVD) ---
echo "no" | avdmanager create avd -n "pixel_6" -k "system-images;android-34;google_apis;x86_64" -d "pixel_6"

# --- Final setup checks ---
echo "Running flutter doctor..."
# Accept Flutter licenses
yes | flutter doctor --android-licenses
# Run doctor to verify everything
flutter doctor -v

echo "Post-create script finished successfully!"