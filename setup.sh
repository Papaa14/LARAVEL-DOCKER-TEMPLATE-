#!/bin/bash

# Laravel Docker Project Initializer (Enhanced Wizard)
# Sets up Laravel with Docker (Nginx, MariaDB), Auth options, and Spatie Permissions

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${PURPLE}
╔══════════════════════════════════════════════════════════════╗
║             Laravel Docker Project Initializer               ║
║       (Nginx + MariaDB + Auth + Roles + Multi-Project)       ║
╚══════════════════════════════════════════════════════════════╝
${NC}"

# --- SYSTEM CHECKS ---

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
        else
            OS="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
}

# Function to check Docker
check_docker() {
    if command -v docker &> /dev/null; then
        return 0
    else
        echo -e "${RED}✗ Docker is not installed.${NC} Please install Docker Desktop/Engine first."
        exit 1
    fi
}

# Verify Docker is running and handle permissions
verify_docker_running() {
    echo -e "${BLUE}Checking Docker status...${NC}"
    if ! docker info &> /dev/null; then
        if sudo docker info &> /dev/null; then
            echo -e "${YELLOW}Permission issue detected. Adding user to docker group...${NC}"
            sudo usermod -aG docker $USER
            echo -e "${GREEN}Reloading script with new permissions...${NC}"
            exec sg docker "$0 $@"
            exit
        fi
        echo -e "${RED}Docker is not running!${NC} Please start Docker and try again."
        exit 1
    fi
    echo -e "${GREEN}✓ Docker is running${NC}"
}

# Run Checks
detect_os
check_docker
verify_docker_running

# --- WIZARD SECTION ---

echo -e "\n${CYAN}--- Project Configuration ---${NC}"

# 1. Project Name
read -p "Enter project name (lowercase, no spaces): " PROJECT_NAME
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

if [ -z "$PROJECT_NAME" ]; then echo -e "${RED}Name cannot be empty!${NC}"; exit 1; fi
if [ -d "$PROJECT_NAME" ]; then echo -e "${RED}Directory $PROJECT_NAME already exists!${NC}"; exit 1; fi

# 2. Port Configuration (Crucial for Multi-Project Support)
echo -e "\n${YELLOW}--- Port Configuration ---${NC}"
echo "To run multiple projects, use unique ports for each project."
read -p "Enter HTTP Port (Default: 8080): " HTTP_PORT
HTTP_PORT=${HTTP_PORT:-8080}

read -p "Enter Database Port (Default: 3308): " DB_PORT
DB_PORT=${DB_PORT:-3308}

# 3. Authentication
echo -e "\n${YELLOW}--- Authentication Setup ---${NC}"
read -p "Do you want pre-built Authentication (Login/Register)? (y/n): " WANT_AUTH

KIT_NAME="none"
STACK=""

if [[ "$WANT_AUTH" =~ ^[Yy]$ ]]; then
    echo -e "\nSelect a Starter Kit:"
    echo "1) Breeze (Simple, recommended)"
    echo "2) Jetstream (Advanced, includes teams/2FA)"
    read -p "Choice (1-2): " AUTH_CHOICE

    if [ "$AUTH_CHOICE" == "1" ]; then
        KIT_NAME="breeze"
        echo -e "\nSelect Breeze Stack:"
        echo "1) Blade (Server-side rendering, simplest)"
        echo "2) Vue + Inertia (SPA, Modern)"
        echo "3) React + Inertia (SPA, Modern)"
        read -p "Choice (1-3): " STACK_CHOICE
        case $STACK_CHOICE in
            1) STACK="blade" ;;
            2) STACK="vue" ;;
            3) STACK="react" ;;
            *) STACK="blade" ;;
        esac
    elif [ "$AUTH_CHOICE" == "2" ]; then
        KIT_NAME="jetstream"
        echo -e "\nSelect Jetstream Stack:"
        echo "1) Livewire (Blade-like, no API required)"
        echo "2) Vue + Inertia"
        read -p "Choice (1-2): " STACK_CHOICE
        case $STACK_CHOICE in
            1) STACK="livewire" ;;
            2) STACK="inertia" ;;
            *) STACK="livewire" ;;
        esac
    fi
fi

# 4. Roles and Permissions
echo -e "\n${YELLOW}--- Roles & Permissions ---${NC}"
read -p "Do you need to manage User Roles & Permissions? (y/n): " WANT_SPATIE
echo "We will use 'spatie/laravel-permission' (The industry standard)."

# --- SCAFFOLDING SECTION ---

echo -e "\n${GREEN}Creating project directory...${NC}"
mkdir -p "$PROJECT_NAME/docker/nginx" "$PROJECT_NAME/docker/php"
cd "$PROJECT_NAME"

# Create Dockerfile
cat > docker/php/Dockerfile << 'EOF'
FROM php:8.2-fpm
RUN apt-get update && apt-get install -y git curl libpng-dev libonig-dev libxml2-dev zip unzip libzip-dev mariadb-client gnupg
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www
COPY --chown=www-data:www-data . /var/www
EXPOSE 9000
CMD ["php-fpm"]
EOF

# Create Nginx Config
cat > docker/nginx/default.conf << 'EOF'
server {
    listen 80;
    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/public;
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }
}
EOF

# Create docker-compose.yml with DYNAMIC PORTS
echo -e "${GREEN}Generating Docker Compose config...${NC}"
cat > docker-compose.yml << EOF
services:
  app:
    build:
      context: .
      dockerfile: docker/php/Dockerfile
    container_name: ${PROJECT_NAME}_app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./:/var/www
    networks:
      - ${PROJECT_NAME}_network
    depends_on:
      - db

  nginx:
    image: nginx:alpine
    container_name: ${PROJECT_NAME}_nginx
    restart: unless-stopped
    ports:
      - "${HTTP_PORT}:80"
    volumes:
      - ./:/var/www
      - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf
    networks:
      - ${PROJECT_NAME}_network
    depends_on:
      - app

  db:
    image: mariadb:10.11
    container_name: ${PROJECT_NAME}_db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: ${PROJECT_NAME}_db
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USER: laravel
      MYSQL_PASSWORD: secret
    volumes:
      - dbdata:/var/lib/mysql
    ports:
      - "${DB_PORT}:3306"
    networks:
      - ${PROJECT_NAME}_network

networks:
  ${PROJECT_NAME}_network:
    driver: bridge

volumes:
  dbdata:
    driver: local
EOF

# Create .env
cat > .env << EOF
APP_NAME=${PROJECT_NAME}
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:${HTTP_PORT}

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=${PROJECT_NAME}_db
DB_USERNAME=laravel
DB_PASSWORD=secret
EOF

# Installation Script
cat > install-laravel.sh << 'INSTALL_SCRIPT'
#!/bin/bash
cd /var/www
if [ ! -f "artisan" ]; then
    composer create-project laravel/laravel temp-laravel
    shopt -s dotglob
    mv temp-laravel/* .
    rm -rf temp-laravel
    php artisan key:generate
fi
INSTALL_SCRIPT
chmod +x install-laravel.sh

# Detect Compose Command
if docker compose version &> /dev/null 2>&1; then COMPOSE_CMD="docker compose"; else COMPOSE_CMD="docker-compose"; fi

# --- EXECUTION SECTION ---

echo -e "\n${BLUE}Building containers (This may take a moment)...${NC}"
$COMPOSE_CMD up -d --build

echo -e "${BLUE}Waiting for Database to initialize...${NC}"
sleep 10

echo -e "${BLUE}Installing Laravel Framework...${NC}"
$COMPOSE_CMD exec -T app bash /var/www/install-laravel.sh

# Install Auth
if [ "$KIT_NAME" != "none" ]; then
    echo -e "\n${PURPLE}Installing Authentication Stack (${KIT_NAME} + ${STACK})...${NC}"
    
    if [ "$KIT_NAME" = "breeze" ]; then
        $COMPOSE_CMD exec -T app composer require laravel/breeze --dev
        
        if [ "$STACK" = "vue" ]; then
            $COMPOSE_CMD exec -T app php artisan breeze:install vue || true
            echo -e "${YELLOW}Fixing Vite/Vue versions...${NC}"
            $COMPOSE_CMD exec -T app npm install vite@^6.0.0 laravel-vite-plugin@^1.0.0 --save-dev
        elif [ "$STACK" = "react" ]; then
            $COMPOSE_CMD exec -T app php artisan breeze:install react
        else
            $COMPOSE_CMD exec -T app php artisan breeze:install blade
        fi
    elif [ "$KIT_NAME" = "jetstream" ]; then
        $COMPOSE_CMD exec -T app composer require laravel/jetstream
        if [ "$STACK" = "livewire" ]; then
            $COMPOSE_CMD exec -T app php artisan jetstream:install livewire
        else
            $COMPOSE_CMD exec -T app php artisan jetstream:install inertia
        fi
    fi
    
    echo -e "${BLUE}Compiling Assets...${NC}"
    $COMPOSE_CMD exec -T app npm install --legacy-peer-deps
    $COMPOSE_CMD exec -T app npm run build
fi

# Install Spatie Roles
if [[ "$WANT_SPATIE" =~ ^[Yy]$ ]]; then
    echo -e "\n${PURPLE}Installing Spatie Roles & Permissions...${NC}"
    $COMPOSE_CMD exec -T app composer require spatie/laravel-permission
    
    echo "Publishing Spatie config..."
    $COMPOSE_CMD exec -T app php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
    
    echo "Clearing config cache..."
    $COMPOSE_CMD exec -T app php artisan config:clear
fi

# Final Migration
echo -e "\n${BLUE}Running Database Migrations...${NC}"
$COMPOSE_CMD exec -T app php artisan migrate --force

# Permissions
$COMPOSE_CMD exec -T app chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
rm install-laravel.sh

# --- SUMMARY ---

echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    SETUP COMPLETE! 🚀                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${YELLOW}Project Name :${NC} $PROJECT_NAME"
echo -e "${YELLOW}URL          :${NC} http://localhost:${HTTP_PORT}"
echo -e "${YELLOW}Database Port:${NC} ${DB_PORT} (External access)"
echo -e "${YELLOW}DB Host      :${NC} 127.0.0.1 (For Workbench/TablePlus)"
echo -e "${YELLOW}DB User/Pass :${NC} laravel / secret"
echo -e ""
if [[ "$WANT_SPATIE" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Spatie Info  :${NC} 'roles' and 'permissions' tables created."
fi
if [[ "$STACK" == "vue" ]] || [[ "$STACK" == "react" ]]; then
    echo -e "${CYAN}Dev Server   :${NC} run '${COMPOSE_CMD} exec app npm run dev' to start Vite."
fi
echo -e ""