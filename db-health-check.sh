#!/bin/bash

# CrisisLink Database Health Check Script
# Run this script to verify database connectivity and status

echo "🔍 CrisisLink Database Health Check"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if PostgreSQL service is running
echo -n "PostgreSQL Service Status: "
if systemctl is-active --quiet postgresql; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${RED}❌ Not Running${NC}"
    echo "Try: sudo systemctl start postgresql"
    exit 1
fi

# Check PostgreSQL connection
echo -n "PostgreSQL Connection: "
if sudo -u postgres psql -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Connected${NC}"
else
    echo -e "${RED}❌ Connection Failed${NC}"
    exit 1
fi

# Check if crisislink database exists
echo -n "CrisisLink Database: "
if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw crisislink; then
    echo -e "${GREEN}✅ Exists${NC}"
else
    echo -e "${RED}❌ Not Found${NC}"
    echo "Database 'crisislink' does not exist!"
    exit 1
fi

# Check if crisislink_user exists
echo -n "Database User: "
if sudo -u postgres psql -t -c "SELECT 1 FROM pg_roles WHERE rolname='crisislink_user';" | grep -q 1; then
    echo -e "${GREEN}✅ crisislink_user exists${NC}"
else
    echo -e "${RED}❌ crisislink_user not found${NC}"
    exit 1
fi

# Check PostGIS extension
echo -n "PostGIS Extension: "
if sudo -u postgres psql -d crisislink -c "SELECT 1 FROM pg_extension WHERE extname='postgis';" | grep -q 1; then
    echo -e "${GREEN}✅ Installed${NC}"
else
    echo -e "${YELLOW}⚠️ Not Installed${NC}"
fi

# Check database connection with crisislink_user
echo -n "User Connection Test: "
if PGPASSWORD=crisislink_password psql -h localhost -U crisislink_user -d crisislink -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Can Connect${NC}"
else
    echo -e "${RED}❌ Cannot Connect${NC}"
    echo "User 'crisislink_user' cannot connect to database!"
fi

# Count tables in the database
echo -n "Database Tables: "
table_count=$(PGPASSWORD=crisislink_password psql -h localhost -U crisislink_user -d crisislink -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | xargs)
if [ "$table_count" -gt 0 ]; then
    echo -e "${GREEN}✅ $table_count tables found${NC}"
    echo ""
    echo "Table List:"
    PGPASSWORD=crisislink_password psql -h localhost -U crisislink_user -d crisislink -c "\dt" 2>/dev/null | head -20
else
    echo -e "${YELLOW}⚠️ No tables found${NC}"
    echo "Database appears to be empty. Schema may not be loaded."
fi

echo ""
echo -e "${GREEN}Database Health Check Complete!${NC}"

# Additional diagnostics
echo ""
echo "=== Additional Information ==="
echo -n "PostgreSQL Version: "
sudo -u postgres psql -c "SELECT version();" | grep PostgreSQL | head -1

echo -n "Database Size: "
sudo -u postgres psql -d crisislink -c "SELECT pg_size_pretty(pg_database_size('crisislink'));"

echo -n "Active Connections: "
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity WHERE datname='crisislink';"

echo ""
echo "=== Connection Information ==="
echo "Database Host: localhost"
echo "Database Port: 5432"
echo "Database Name: crisislink"
echo "Database User: crisislink_user"
echo "Connection URL: postgresql://crisislink_user:crisislink_password@localhost:5432/crisislink"