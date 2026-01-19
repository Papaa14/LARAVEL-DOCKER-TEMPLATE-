#!/bin/bash
# init-project.sh
# Run this after cloning the repo to start the project

set -e
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Initializing Project from Git ===${NC}"

# 1. Handle .env
if [ ! -f .env ]; then
    echo -e "${GREEN}Copying .env.example to .env...${NC}"
    cp .env.example .env
else
    echo -e "${GREEN}.env file already exists.${NC}"
fi

# 2. Start Docker
echo -e "${BLUE}Starting Docker containers...${NC}"
# Check for "docker compose" or "docker-compose"
if docker compose version &> /dev/null 2>&1; then
    docker compose up -d --build
else
    docker-compose up -d --build
fi

echo -e "${BLUE}Waiting for container initialization...${NC}"
sleep 10

# 3. Install PHP Dependencies
echo -e "${GREEN}Installing Composer dependencies...${NC}"
docker compose exec -T app composer install

# 4. Generate Key (only if missing)
if ! grep -q "^APP_KEY=base64" .env; then
    echo -e "${GREEN}Generating Application Key...${NC}"
    docker compose exec -T app php artisan key:generate
fi

# 5. Run Migrations
echo -e "${GREEN}Running Database Migrations...${NC}"
# Loop to wait for DB to be ready
for i in {1..30}; do
    if docker compose exec -T app php artisan migrate --force; then
        break
    fi
    echo "Waiting for Database..."
    sleep 2
done

# 6. Install Node Dependencies & Build
echo -e "${GREEN}Installing Node dependencies & Building assets...${NC}"
docker compose exec -T app npm install --legacy-peer-deps
docker compose exec -T app npm run build

# 7. Permissions
echo -e "${GREEN}Fixing permissions...${NC}"
docker compose exec -T app chown -R www-data:www-data storage bootstrap/cache

echo -e "\n${GREEN}=== Project is Live! ===${NC}"
echo -e "Access it at: http://localhost:8080" # Update port if your .env.example differs