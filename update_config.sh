#!/bin/bash

# App Configuration Update Script
# This script updates all app configuration files from app_config.yaml

echo "🚀 Starting app configuration update..."

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "Please install Python 3 and try again."
    exit 1
fi

# Check if virtual environment exists, create if not
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment and install PyYAML if needed
source venv/bin/activate
if ! python -c "import yaml" &> /dev/null; then
    echo "📦 Installing PyYAML..."
    pip install PyYAML
fi

# Check if app_config.yaml exists
if [ ! -f "app_config.yaml" ]; then
    echo "❌ app_config.yaml not found!"
    echo "Please create app_config.yaml first."
    exit 1
fi

# Create scripts directory if it doesn't exist
mkdir -p scripts

# Run the Python script
python scripts/update_app_config.py

# Check if the script ran successfully
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Configuration update completed successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Review the changes in your project files"
    echo "2. Test the app on your target platforms"
    echo "3. Build and deploy your app"
    echo ""
    echo "🔄 To update again, just run: ./update_config.sh"
else
    echo "❌ Configuration update failed!"
    exit 1
fi
