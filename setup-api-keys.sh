#!/bin/bash

# CrisisLink API Keys Setup Script
# This script helps you set up your API keys securely

echo "🔐 CrisisLink API Keys Setup"
echo "============================="
echo ""

# Check if api-keys.env already exists
if [ -f "api-keys.env" ]; then
    echo "⚠️  api-keys.env already exists!"
    echo "Do you want to:"
    echo "1) Edit existing file"
    echo "2) Create backup and start fresh"
    echo "3) Exit"
    read -p "Choose option (1-3): " choice
    
    case $choice in
        1)
            echo "Opening existing api-keys.env file..."
            if command -v nano >/dev/null 2>&1; then
                nano api-keys.env
            elif command -v vim >/dev/null 2>&1; then
                vim api-keys.env
            else
                echo "Please edit api-keys.env manually with your preferred editor"
            fi
            exit 0
            ;;
        2)
            cp api-keys.env api-keys.env.backup.$(date +%Y%m%d_%H%M%S)
            echo "✅ Backup created: api-keys.env.backup.$(date +%Y%m%d_%H%M%S)"
            ;;
        3)
            echo "Setup cancelled."
            exit 0
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
fi

# Copy template to api-keys.env
if [ ! -f "api-keys.env.template" ]; then
    echo "❌ Error: api-keys.env.template not found!"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

cp api-keys.env.template api-keys.env
echo "✅ Created api-keys.env from template"
echo ""

echo "📝 API Key Configuration Guide:"
echo ""
echo "The following API keys are already configured with working values:"
echo "✅ OpenWeatherMap API (Primary + Backups)"
echo "✅ Ambee Environmental Data API"
echo "✅ Google Maps JavaScript API"
echo "✅ Google Firebase API"
echo ""
echo "⚠️  The following need your own credentials:"
echo "❌ Twilio SMS (Optional - for SMS alerts)"
echo "❌ JWT Secret (Recommended for production)"
echo ""

read -p "Do you want to configure Twilio SMS service? (y/N): " setup_twilio

if [[ $setup_twilio =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔗 Twilio Setup Instructions:"
    echo "1. Go to https://console.twilio.com/"
    echo "2. Sign up for a free account"
    echo "3. Get your Account SID, Auth Token, and Phone Number"
    echo "4. Replace the placeholder values in api-keys.env"
    echo ""
fi

read -p "Do you want to generate a new JWT secret? (y/N): " setup_jwt

if [[ $setup_jwt =~ ^[Yy]$ ]]; then
    # Generate a random JWT secret
    if command -v openssl >/dev/null 2>&1; then
        jwt_secret=$(openssl rand -base64 32)
        sed -i.bak "s/JWT_SECRET=.*/JWT_SECRET=${jwt_secret}/" api-keys.env
        echo "✅ Generated new JWT secret"
    elif command -v head >/dev/null 2>&1 && [ -f /dev/urandom ]; then
        jwt_secret=$(head -c 32 /dev/urandom | base64)
        sed -i.bak "s/JWT_SECRET=.*/JWT_SECRET=${jwt_secret}/" api-keys.env
        echo "✅ Generated new JWT secret"
    else
        echo "⚠️  Could not generate JWT secret automatically."
        echo "Please manually replace the JWT_SECRET value in api-keys.env"
    fi
fi

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "Your API keys are configured in: api-keys.env"
echo "This file is ignored by Git and won't be committed to your repository."
echo ""
echo "Next steps:"
echo "1. Review and edit api-keys.env if needed"
echo "2. Run 'vagrant up' to start the CrisisLink system"
echo "3. Access the app at http://localhost:3000"
echo ""
echo "🔒 Security Note:"
echo "- api-keys.env is in .gitignore and won't be pushed to GitHub"
echo "- Never share your API keys publicly"
echo "- Use different keys for development and production"
echo ""