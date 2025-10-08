#!/bin/bash

# Set noninteractive mode for automated installation
export DEBIAN_FRONTEND=noninteractive

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚨 Starting CrisisLink provisioning...${NC}"
echo "================================================="

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
apt-get update && apt-get upgrade -y

# Install basic utilities
echo -e "${YELLOW}Installing basic utilities...${NC}"
apt-get install -y curl wget git unzip apt-transport-https ca-certificates gnupg build-essential

# Install Node.js 18.x
echo -e "${YELLOW}Installing Node.js 18.x...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Verify Node.js and npm versions
node_version=$(node -v)
npm_version=$(npm -v)
echo -e "${GREEN}Node.js version: ${node_version}${NC}"
echo -e "${GREEN}npm version: ${npm_version}${NC}"

# Install PostgreSQL with PostGIS
echo -e "${YELLOW}Installing PostgreSQL with PostGIS...${NC}"
apt-get install -y postgresql postgresql-contrib postgis

# Install Redis
echo -e "${YELLOW}Installing Redis...${NC}"
apt-get install -y redis-server

# Configure Redis to start on boot
systemctl enable redis-server
systemctl start redis-server

# Test Redis connection
echo -e "${YELLOW}Testing Redis connection...${NC}"
if redis-cli ping > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Redis connection successful${NC}"
else
  echo -e "${YELLOW}⚠️ Redis not responding, restarting service...${NC}"
  systemctl restart redis-server
  sleep 2
  if redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Redis connection successful after restart${NC}"
  else
    echo -e "${RED}❌ Redis connection failed${NC}"
  fi
fi

# Set up PostgreSQL
echo -e "${YELLOW}Setting up PostgreSQL database...${NC}"

# Start PostgreSQL service
systemctl start postgresql
systemctl enable postgresql

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}Waiting for PostgreSQL to be ready...${NC}"
sleep 5

# Set up PostgreSQL user and database with error handling
echo -e "${YELLOW}Creating database user and database...${NC}"

# Drop existing user/database if they exist (for clean setup)
sudo -u postgres psql -c "DROP DATABASE IF EXISTS crisislink;" 2>/dev/null || true
sudo -u postgres psql -c "DROP USER IF EXISTS crisislink_user;" 2>/dev/null || true

# Create user and database
sudo -u postgres psql -c "CREATE USER crisislink_user WITH PASSWORD 'crisislink_password';"
sudo -u postgres psql -c "CREATE DATABASE crisislink OWNER crisislink_user;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE crisislink TO crisislink_user;"
sudo -u postgres psql -c "ALTER USER crisislink_user CREATEDB;"

# Add PostGIS extensions
echo -e "${YELLOW}Adding PostGIS extensions...${NC}"
sudo -u postgres psql -d crisislink -c "CREATE EXTENSION IF NOT EXISTS postgis;"
sudo -u postgres psql -d crisislink -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"

# Grant necessary permissions for the user
sudo -u postgres psql -d crisislink -c "GRANT ALL ON SCHEMA public TO crisislink_user;"
sudo -u postgres psql -d crisislink -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO crisislink_user;"
sudo -u postgres psql -d crisislink -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO crisislink_user;"
sudo -u postgres psql -d crisislink -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO crisislink_user;"
sudo -u postgres psql -d crisislink -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO crisislink_user;"

# Clone the CrisisLink repository
echo -e "${YELLOW}Cloning CrisisLink repository...${NC}"
git clone https://github.com/Lintshiwe/CrisisLink2.0.git /home/vagrant/CrisisLink
cd /home/vagrant/CrisisLink

# Set proper ownership
chown -R vagrant:vagrant /home/vagrant/CrisisLink

# Create environment files with API keys from host
echo -e "${YELLOW}Creating environment files with API keys...${NC}"

# Load API keys from host machine if available
if [ -f /vagrant/api-keys.env ]; then
  echo -e "${GREEN}Found API keys file, loading configuration...${NC}"
  source /vagrant/api-keys.env
else
  echo -e "${YELLOW}No api-keys.env file found, using template values...${NC}"
  # Load from template as fallback
  OPENWEATHER_API_KEY="2a77d07eca9efa19773d83cdc5856a52"
  GOOGLE_MAPS_API_KEY="AIzaSyCQA8VqX84ND_7IuJVBjC8PvbiGr4m-Awc"
  GOOGLE_API_KEY="AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8"
  FIREBASE_API_KEY="AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8"
  AMBEE_API_KEY="47d5c87e426158ff259d42439a41a28a630852877aa63d8d174c11e8998592da"
  JWT_SECRET="crisislink_super_secret_jwt_key_change_in_production_2024"
  TWILIO_ACCOUNT_SID="your_twilio_account_sid_here"
  TWILIO_AUTH_TOKEN="your_twilio_auth_token_here"
  TWILIO_PHONE_NUMBER="your_twilio_phone_number_here"
fi

# Backend .env file with actual API keys
cat > /home/vagrant/CrisisLink/backend/.env << EOF
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
DB_SSL=false
DB_DIALECT=postgres
DATABASE_URL=postgresql://crisislink_user:crisislink_password@localhost:5432/crisislink

# Redis Configuration
REDIS_URL=redis://localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# Weather & Environmental API Keys
OPENWEATHER_API_KEY=${OPENWEATHER_API_KEY}
AMBEE_API_KEY=${AMBEE_API_KEY}

# Google Services API Keys
GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY}
GOOGLE_API_KEY=${GOOGLE_API_KEY}
FIREBASE_API_KEY=${FIREBASE_API_KEY}

# Communication Services
TWILIO_ACCOUNT_SID=${TWILIO_ACCOUNT_SID}
TWILIO_AUTH_TOKEN=${TWILIO_AUTH_TOKEN}
TWILIO_PHONE_NUMBER=${TWILIO_PHONE_NUMBER}

# Security
JWT_SECRET=${JWT_SECRET}
SESSION_SECRET=development_session_secret_key
EOF

# Frontend .env file with actual API keys
cat > /home/vagrant/CrisisLink/frontend/.env << EOF
# API Configuration
REACT_APP_API_URL=http://localhost:5000

# Google Services API Keys
REACT_APP_GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY}
REACT_APP_GOOGLE_API_KEY=${GOOGLE_API_KEY}
REACT_APP_FIREBASE_API_KEY=${FIREBASE_API_KEY}

# Weather API Keys
REACT_APP_OPENWEATHER_API_KEY=${OPENWEATHER_API_KEY}

# Environment
REACT_APP_ENVIRONMENT=development
EOF

# Update hardcoded API keys in source files
echo -e "${YELLOW}Updating hardcoded API keys in source files...${NC}"

# Update Ambee API key in ambeeService.js
if [ -f /home/vagrant/CrisisLink/backend/src/services/ambeeService.js ]; then
  sed -i "s/47d5c87e426158ff259d42439a41a28a630852877aa63d8d174c11e8998592da/${AMBEE_API_KEY}/g" /home/vagrant/CrisisLink/backend/src/services/ambeeService.js
fi

# Update Firebase config in service worker
if [ -f /home/vagrant/CrisisLink/frontend/public/sw.js ]; then
  sed -i "s/AIzaSyDRMaid3NqgUE-mgyGpooyCPSqE_3YeJB8/${FIREBASE_API_KEY}/g" /home/vagrant/CrisisLink/frontend/public/sw.js
fi

# Update OpenWeather backup keys if the file exists
if [ -f /home/vagrant/CrisisLink/backend/src/services/liveWeatherService.js ]; then
  if [ ! -z "$OPENWEATHER_BACKUP_KEY1" ]; then
    sed -i "s/47f39e2c3c1fb1d2c2c0a0c6f89e2a04/${OPENWEATHER_BACKUP_KEY1}/g" /home/vagrant/CrisisLink/backend/src/services/liveWeatherService.js
  fi
  if [ ! -z "$OPENWEATHER_BACKUP_KEY2" ]; then
    sed -i "s/949678e6f2a5b82bbc459044b85563f5/${OPENWEATHER_BACKUP_KEY2}/g" /home/vagrant/CrisisLink/backend/src/services/liveWeatherService.js
  fi
fi

# Test database connection
echo -e "${YELLOW}Testing database connection...${NC}"
if sudo -u postgres psql -d crisislink -c "SELECT version();" > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Database connection successful${NC}"
else
  echo -e "${RED}❌ Database connection failed${NC}"
  exit 1
fi

# Initialize database schema if schema.sql exists
if [ -f /home/vagrant/CrisisLink/database/schema.sql ]; then
  echo -e "${YELLOW}Initializing database schema...${NC}"
  # Run schema as the crisislink_user to ensure proper ownership
  PGPASSWORD=crisislink_password psql -h localhost -U crisislink_user -d crisislink -f /home/vagrant/CrisisLink/database/schema.sql 2>/dev/null || {
    echo -e "${YELLOW}Schema file not compatible with user permissions, running as postgres...${NC}"
    sudo -u postgres psql -d crisislink -f /home/vagrant/CrisisLink/database/schema.sql
    # Fix ownership after running as postgres
    sudo -u postgres psql -d crisislink -c "REASSIGN OWNED BY postgres TO crisislink_user;"
  }
  echo -e "${GREEN}✅ Database schema initialized${NC}"
else
  echo -e "${YELLOW}⚠️ No schema.sql file found, skipping database initialization${NC}"
fi

# Verify database setup
echo -e "${YELLOW}Verifying database setup...${NC}"
table_count=$(PGPASSWORD=crisislink_password psql -h localhost -U crisislink_user -d crisislink -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | xargs)
if [ "$table_count" -gt 0 ]; then
  echo -e "${GREEN}✅ Database has $table_count tables${NC}"
else
  echo -e "${YELLOW}⚠️ Database is empty (no tables found)${NC}"
fi

# Install project dependencies
echo -e "${YELLOW}Installing project dependencies...${NC}"
cd /home/vagrant/CrisisLink
sudo -u vagrant npm run install:all || sudo -u vagrant npm install && cd backend && sudo -u vagrant npm install && cd ../frontend && sudo -u vagrant npm install

# Fix bcrypt native module issue
echo -e "${YELLOW}Rebuilding bcrypt to fix native module issues...${NC}"
cd /home/vagrant/CrisisLink/backend
sudo -u vagrant npm rebuild bcrypt --build-from-source

# Create startup script
echo -e "${YELLOW}Creating startup script...${NC}"
cat > /home/vagrant/start_crisislink.sh << EOF
#!/bin/bash
cd /home/vagrant/CrisisLink
npm run dev
EOF

chmod +x /home/vagrant/start_crisislink.sh

# Create systemd service for auto-start
echo -e "${YELLOW}Creating systemd service for auto-start...${NC}"
cat > /etc/systemd/system/crisislink.service << EOF
[Unit]
Description=CrisisLink Application
After=network.target postgresql.service redis-server.service

[Service]
Type=simple
User=vagrant
WorkingDirectory=/home/vagrant/CrisisLink
ExecStart=/usr/bin/npm run dev
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=crisislink

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl enable crisislink.service
systemctl start crisislink.service

# Wait for services to fully start
echo -e "${YELLOW}Waiting for services to start (15 seconds)...${NC}"
sleep 15

# Check if services are running
echo -e "${YELLOW}Verifying services are running...${NC}"
frontend_running=$(netstat -tulpn | grep -q ":3000" && echo "yes" || echo "no")
backend_running=$(netstat -tulpn | grep -q ":5000" && echo "yes" || echo "no")

if [ "$frontend_running" = "no" ] || [ "$backend_running" = "no" ]; then
  echo -e "${RED}⚠️ Service check failed. Attempting to restart...${NC}"
  systemctl restart crisislink.service
  sleep 10
fi

# Install net-tools for easier service checking
apt-get install -y net-tools

echo -e "${GREEN}🎉 CrisisLink VM provisioning completed!${NC}"
echo -e "${GREEN}📱 Access the app at:${NC}"
echo -e "${GREEN}   Frontend: http://localhost:3000${NC}"
echo -e "${GREEN}   Backend API: http://localhost:5000${NC}"
echo -e "${GREEN}🆘 Ready to use the CrisisLink emergency response system!${NC}"
echo ""
echo -e "${YELLOW}Note: You may need to set up API keys in the environment files:${NC}"
echo -e "${YELLOW}  - /home/vagrant/CrisisLink/backend/.env${NC}"
echo -e "${YELLOW}  - /home/vagrant/CrisisLink/frontend/.env${NC}"
echo ""
echo -e "${GREEN}Troubleshooting:${NC}"
echo -e "${YELLOW}- If the app doesn't start, try: sudo systemctl restart crisislink${NC}"
echo -e "${YELLOW}- To view service logs: sudo journalctl -u crisislink${NC}"
echo -e "${YELLOW}- To check ports in use: netstat -tulpn | grep -E '3000|5000'${NC}"
echo -e "${YELLOW}- To check database connection: sudo -u postgres psql -d crisislink -c 'SELECT version();'${NC}"
echo -e "${YELLOW}- To view database tables: sudo -u postgres psql -d crisislink -c '\\dt'${NC}"
echo -e "${YELLOW}- To restart database: sudo systemctl restart postgresql${NC}"