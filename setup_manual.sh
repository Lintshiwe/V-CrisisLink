#!/bin/bash

# 🚨 CrisisLink Setup Script
# This script sets up the CrisisLink disaster rescue system manually

echo "🚨 CrisisLink Setup Starting..."
echo "================================"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command_exists node; then
    echo "❌ Node.js not found. Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

if ! command_exists npm; then
    echo "❌ npm not found. Please install npm (comes with Node.js)"
    exit 1
fi

if ! command_exists git; then
    echo "❌ Git not found. Please install Git from https://git-scm.com/downloads"
    exit 1
fi

if ! command_exists psql; then
    echo "⚠️ PostgreSQL not found. Database setup will be skipped."
    DB_SKIP=true
else
    DB_SKIP=false
fi

echo "✅ Prerequisites check passed!"

# Clone the repository if it doesn't exist
if [ ! -d "CrisisLink2.0" ]; then
    echo "📦 Cloning repository..."
    git clone https://github.com/Lintshiwe/CrisisLink2.0.git
fi

# Navigate to the project directory
cd CrisisLink2.0

# Create environment files if they don't exist
if [ ! -f "backend/.env" ]; then
    echo "🔧 Creating backend environment file..."
    mkdir -p backend
    cat > backend/.env << EOF
# Server Configuration
NODE_ENV=development
PORT=5000
HOST=0.0.0.0

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=crisislink
DB_USER=crisislink_user
DB_PASSWORD=crisislink_password

# Redis Configuration
REDIS_URL=redis://localhost:6379

# API Keys
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
FIREBASE_SERVICE_ACCOUNT_KEY=path_to_firebase_service_account.json
OPENWEATHER_API_KEY=your_openweather_api_key
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token

# Security
JWT_SECRET=development_jwt_secret_key
SESSION_SECRET=development_session_secret_key
EOF
    echo "✅ Backend environment file created!"
fi

if [ ! -f "frontend/.env" ]; then
    echo "🔧 Creating frontend environment file..."
    mkdir -p frontend
    cat > frontend/.env << EOF
REACT_APP_API_URL=http://localhost:5000
REACT_APP_GOOGLE_MAPS_API_KEY=your_google_maps_api_key
REACT_APP_FIREBASE_CONFIG={"apiKey":"...","authDomain":"..."}
REACT_APP_ENVIRONMENT=development
EOF
    echo "✅ Frontend environment file created!"
fi

# Database setup (if PostgreSQL is installed)
if [ "$DB_SKIP" = false ]; then
    echo "🗄️ Setting up database..."
    
    # Get PostgreSQL superuser credentials
    read -p "Enter PostgreSQL superuser name (default: postgres): " db_superuser
    db_superuser=${db_superuser:-postgres}
    
    # Create database and user
    echo "Creating database and user..."
    psql -U "$db_superuser" -c "CREATE DATABASE crisislink;" || echo "Database may already exist"
    psql -U "$db_superuser" -c "CREATE USER crisislink_user WITH ENCRYPTED PASSWORD 'crisislink_password';" || echo "User may already exist"
    psql -U "$db_superuser" -c "GRANT ALL PRIVILEGES ON DATABASE crisislink TO crisislink_user;" || echo "Privileges may already be granted"
    
    # Enable PostGIS if it exists
    psql -U "$db_superuser" -d crisislink -c "CREATE EXTENSION IF NOT EXISTS postgis;" || echo "PostGIS extension not available"
    psql -U "$db_superuser" -d crisislink -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;" || echo "PostGIS topology extension not available"
    
    # Initialize schema if the file exists
    if [ -f "database/schema.sql" ]; then
        echo "Initializing database schema..."
        psql -U crisislink_user -d crisislink -f database/schema.sql || echo "Schema initialization may have issues"
    else
        echo "⚠️ Schema file not found. Database structure not initialized."
    fi
    
    echo "✅ Database setup complete!"
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm run install:all || (npm install && (cd backend && npm install) && (cd ../frontend && npm install))
echo "✅ Dependencies installed!"

echo ""
echo "🎉 CrisisLink setup complete!"
echo ""
echo "🚀 To start the system:"
echo "   npm run dev"
echo ""
echo "📱 Access the app at:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:5000"
echo ""
echo "🔑 You'll need to set up API keys in the environment files:"
echo "   - backend/.env"
echo "   - frontend/.env"
echo ""
echo "🆘 Ready to test the emergency response system!"