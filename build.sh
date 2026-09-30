#!/bin/bash
cd frontend
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi
export PATH="$PATH:`pwd`/flutter/bin"

# Disable analytics to prevent CI hang on prompt
flutter/bin/flutter config --no-analytics

# Build the web app
flutter/bin/flutter build web --web-renderer html --release
