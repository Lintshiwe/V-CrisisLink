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

# Set up PostgreSQL
echo -e "${YELLOW}Setting up PostgreSQL database...${NC}"
# Set up PostgreSQL user and database
sudo -u postgres psql -c "CREATE USER crisislink_user WITH PASSWORD 'crisislink_password';"
sudo -u postgres psql -c "CREATE DATABASE crisislink;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE crisislink TO crisislink_user;"
sudo -u postgres psql -d crisislink -c "CREATE EXTENSION IF NOT EXISTS postgis;"
sudo -u postgres psql -d crisislink -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"

# Clone the CrisisLink repository
echo -e "${YELLOW}Cloning CrisisLink repository...${NC}"
git clone https://github.com/Lintshiwe/CrisisLink2.0.git /home/vagrant/CrisisLink
cd /home/vagrant/CrisisLink

# Set proper ownership
chown -R vagrant:vagrant /home/vagrant/CrisisLink

# Create environment files with sample configurations
echo -e "${YELLOW}Creating environment files...${NC}"

# Backend .env file
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

# Frontend .env file
cat > /home/vagrant/CrisisLink/frontend/.env << EOF
REACT_APP_API_URL=http://localhost:5000
REACT_APP_GOOGLE_MAPS_API_KEY=your_google_maps_api_key
REACT_APP_FIREBASE_CONFIG={"apiKey":"...","authDomain":"..."}
REACT_APP_ENVIRONMENT=development
EOF

# Initialize database schema if schema.sql exists
if [ -f /home/vagrant/CrisisLink/database/schema.sql ]; then
  echo -e "${YELLOW}Initializing database schema...${NC}"
  sudo -u postgres psql -d crisislink -f /home/vagrant/CrisisLink/database/schema.sql
fi

# Install project dependencies
echo -e "${YELLOW}Installing project dependencies...${NC}"
cd /home/vagrant/CrisisLink
sudo -u vagrant npm run install:all || sudo -u vagrant npm install && cd backend && sudo -u vagrant npm install && cd ../frontend && sudo -u vagrant npm install

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

echo -e "${GREEN}🎉 CrisisLink VM provisioning completed!${NC}"
echo -e "${GREEN}📱 Access the app at:${NC}"
echo -e "${GREEN}   Frontend: http://localhost:3000${NC}"
echo -e "${GREEN}   Backend API: http://localhost:5000${NC}"
echo -e "${GREEN}🆘 Ready to use the CrisisLink emergency response system!${NC}"
echo ""
echo -e "${YELLOW}Note: You may need to set up API keys in the environment files:${NC}"
echo -e "${YELLOW}  - /home/vagrant/CrisisLink/backend/.env${NC}"
echo -e "${YELLOW}  - /home/vagrant/CrisisLink/frontend/.env${NC}"