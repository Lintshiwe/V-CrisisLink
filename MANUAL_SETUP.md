# CrisisLink2.0 Manual Setup Guide

Since we encountered issues with the automated Vagrant setup, here's a step-by-step manual guide to set up the CrisisLink2.0 project.

## Prerequisites

1. Install [Node.js](https://nodejs.org/) version 18 or higher
2. Install [PostgreSQL](https://www.postgresql.org/download/) version 12 or higher with PostGIS extension
3. Install [Redis](https://redis.io/download) (optional, for session management)
4. Install [Git](https://git-scm.com/downloads)

## Step 1: Clone the Repository

```bash
# Create a directory for the project
mkdir -p CrisisLink
cd CrisisLink

# Clone the repository
git clone https://github.com/Lintshiwe/CrisisLink2.0.git .
```

## Step 2: Set Up PostgreSQL Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database and user
CREATE DATABASE crisislink;
CREATE USER crisislink_user WITH ENCRYPTED PASSWORD 'crisislink_password';
GRANT ALL PRIVILEGES ON DATABASE crisislink TO crisislink_user;

# Connect to the database
\c crisislink

# Enable PostGIS extension (if available)
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

# Exit PostgreSQL
\q
```

## Step 3: Set Up Environment Files

### Backend Environment File

Create a file at `backend/.env` with the following content:

```
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
```

### Frontend Environment File

Create a file at `frontend/.env` with the following content:

```
REACT_APP_API_URL=http://localhost:5000
REACT_APP_GOOGLE_MAPS_API_KEY=your_google_maps_api_key
REACT_APP_FIREBASE_CONFIG={"apiKey":"...","authDomain":"..."}
REACT_APP_ENVIRONMENT=development
```

## Step 4: Install Dependencies

```bash
# Install root dependencies
npm install

# Install backend dependencies
cd backend
npm install
cd ..

# Install frontend dependencies
cd frontend
npm install
cd ..

# Or use the script provided in the project (if available)
npm run install:all
```

## Step 5: Initialize the Database

```bash
# Run the schema SQL file (if it exists)
psql -U crisislink_user -d crisislink -f database/schema.sql
```

## Step 6: Start the Application

```bash
# Start both backend and frontend
npm run dev

# Or start them separately in different terminals
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Frontend
cd frontend
npm start
```

## Step 7: Access the Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:5000

## Troubleshooting

### Database Connection Issues

Check PostgreSQL is running:

```bash
# Windows
net start postgresql

# Linux/macOS
sudo service postgresql status
```

### Node.js Version Issues

```bash
node -v  # Should show v18.0.0 or higher
npm -v   # Should show v8.0.0 or higher
```

### Port Conflicts

If ports 3000 or 5000 are already in use, modify the PORT in the respective .env files.

## API Keys

For full functionality, you'll need to acquire and set up:

1. Google Maps API Key: https://developers.google.com/maps/documentation/javascript/get-api-key
2. OpenWeatherMap API Key: https://openweathermap.org/api
3. Firebase Service Account: https://firebase.google.com/docs/admin/setup
4. Twilio Account (for communication features): https://www.twilio.com/
