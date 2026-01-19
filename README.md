<div align="center">
  <img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo">
  <h1>🐳 Laravel Docker Starter Kit</h1>
  <p><strong>A production-ready, multi-project capable Laravel development environment using Docker</strong></p>
  
  <p>
    <img src="https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" alt="Laravel">
    <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
    <img src="https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP">
    <img src="https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white" alt="MariaDB">
    <img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white" alt="Nginx">
  </p>
  
  <p><strong>Stack:</strong> Nginx • PHP 8.2 • MariaDB • Node.js 20 • Composer • npm</p>
</div>

---

## 📋 Prerequisites

> **Before you begin**, ensure you have the following installed:

| Requirement | Description |
|-------------|-------------|
| 🐳 **Docker** | Docker Desktop (Mac/Windows) or Docker Engine (Linux) |
| 🔧 **Git** | Version control system |

<details>
<summary>📥 Installation Links</summary>

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/downloads)

</details>

---

## 🚀 Scenario A: Creating a Brand New Project

> 💡 **Use this if you are the project creator starting from scratch**

### Quick Start

```bash
# 1️⃣ Run the setup wizard
./setup.sh
```

### 🎯 What the setup wizard does:
- ⚙️ Configures Docker environment
- 🎨 Installs Laravel with your preferred stack
- 🔐 Sets up Authentication (Breeze/Jetstream)
- 📁 Configures proper file permissions

### 📝 Setup Prompts:
| Prompt | Example | Notes |
|--------|---------|-------|
| **Project Name** | `my-awesome-app` | Used for container naming |
| **HTTP Port** | `8080` | Change if running multiple projects |
| **Database Port** | `3308` | Change if port conflicts |
| **Frontend Stack** | Vue/React/Blade | Choose your preferred stack |

### 🎉 Result
Your project will be running at `http://localhost:8080` (or your chosen port)

---

## 🤝 Scenario B: Collaborator Setup (Existing Project)

> 👥 **Use this if you cloned an existing repository**

### Step-by-Step Setup

```bash
# 1️⃣ Clone the repository
git clone https://github.com/your-username/your-repo.git
cd your-repo

# 2️⃣ Initialize the project
./init-project.sh
```

### 🔄 What the init script does:
- 📄 Creates `.env` file from template
- 🐳 Builds Docker containers
- 📦 Installs PHP & Node dependencies
- 🗄️ Runs database migrations
- 🔑 Generates application key

### ✅ Verification
Check the terminal output for your localhost URL (typically `http://localhost:8080`)

---

## 💻 Shell Access & Container Management

> 🔧 **Access Docker containers for development tasks**

### 🎯 Container Access Commands

| Container | Command | Purpose |
|-----------|---------|----------|
| 🐘 **Application** | `docker exec -it [project]_app bash` | Laravel, Artisan, Composer, npm |
| 🗄️ **Database** | `docker exec -it [project]_db bash` | MariaDB CLI, SQL queries |
| 🌐 **Web Server** | `docker exec -it [project]_nginx sh` | Nginx configuration |

### 📱 Application Container (Most Used)

```bash
# Enter the application container
docker exec -it jimgas_app bash

# Once inside (/var/www), you can run:
php artisan migrate          # Database migrations
composer require package     # Install PHP packages
npm install                  # Install Node packages
php artisan make:controller  # Generate files
```

### 🗄️ Database Container

```bash
# Access MariaDB CLI
docker exec -it jimgas_db mariadb -u laravel -p
# Password: secret
```

<details>
<summary>🔍 Advanced Container Commands</summary>

```bash
# View container logs
docker logs jimgas_app -f

# Check container status
docker ps

# Restart specific container
docker restart jimgas_app
```

</details>

---

## 🛠️ Common Daily Commands

> ⚡ **Run commands directly from your host terminal without entering containers**

### 🎨 Laravel Artisan Commands

```bash
# Database operations
docker exec -it jimgas_app php artisan migrate
docker exec -it jimgas_app php artisan migrate:fresh --seed
docker exec -it jimgas_app php artisan db:seed

# Cache management
docker exec -it jimgas_app php artisan optimize:clear
docker exec -it jimgas_app php artisan config:cache

# Code generation
docker exec -it jimgas_app php artisan make:controller UserController
docker exec -it jimgas_app php artisan make:model Product -m
docker exec -it jimgas_app php artisan make:middleware AuthCheck
```

### 📦 Package Management

```bash
# PHP Dependencies (Composer)
docker exec -it jimgas_app composer install
docker exec -it jimgas_app composer require spatie/laravel-permission
docker exec -it jimgas_app composer update

# Frontend Dependencies (npm)
docker exec -it jimgas_app npm install
docker exec -it jimgas_app npm run dev      # Development build
docker exec -it jimgas_app npm run build    # Production build
docker exec -it jimgas_app npm run watch    # Watch for changes
```

### 🐳 Docker Lifecycle

```bash
# Container management
docker-compose up -d          # Start all containers (background)
docker-compose down           # Stop all containers
docker-compose restart        # Restart all containers

# Monitoring
docker-compose logs -f        # View real-time logs
docker-compose ps             # Check container status
```

<details>
<summary>🚀 Pro Tips</summary>

```bash
# Quick container restart
docker-compose down && docker-compose up -d

# Rebuild containers after Dockerfile changes
docker-compose up -d --build

# Remove all containers and volumes (fresh start)
docker-compose down -v
```

</details>

---

## 🔌 Database Connection Info

> 🗄️ **Connect to your database using GUI tools**

### 📊 Supported GUI Tools
- 🐘 **TablePlus** (Recommended)
- 🔧 **MySQL Workbench**
- 🦫 **DBeaver**
- 📱 **Sequel Pro** (Mac)
- 🌐 **phpMyAdmin**

### 🔑 Connection Credentials

| Setting | Value | Notes |
|---------|-------|-------|
| **Host** | `127.0.0.1` | localhost |
| **Port** | `3308` | Check `docker-compose.yml` if modified |
| **Username** | `laravel` | Application user |
| **Password** | `secret` | Default password |
| **Database** | `jimgas_db` | Project-specific database |

### 🔗 Quick Connection String
```
mysql://laravel:secret@127.0.0.1:3308/jimgas_db
```

---

## 🆘 Troubleshooting

> 🔧 **Common issues and their solutions**

### 🚫 Permission Issues

**Problem:** "Permission Denied" on storage folder

```bash
# Fix file ownership
docker exec -it jimgas_app chown -R www-data:www-data storage bootstrap/cache

# Fix permissions
docker exec -it jimgas_app chmod -R 775 storage bootstrap/cache
```

### 🔌 Port Conflicts

**Problem:** Port 8080 or 3308 already in use

1. Edit `docker-compose.yml`:
   ```yaml
   ports:
     - "8081:80"    # Change 8080 to 8081
     - "3309:3306"  # Change 3308 to 3309
   ```

2. Restart containers:
   ```bash
   docker-compose down && docker-compose up -d
   ```

### 🗄️ Database Connection Issues

**Problem:** Database connection errors

```bash
# Check if database container is running
docker ps

# Verify database credentials in .env file
cat .env | grep DB_

# Restart database container
docker restart jimgas_db
```

### 🐳 Container Issues

**Problem:** Containers won't start

```bash
# Check container logs
docker logs jimgas_app
docker logs jimgas_db
docker logs jimgas_nginx

# Clean rebuild
docker-compose down -v
docker-compose up -d --build
```

<details>
<summary>🔍 Advanced Debugging</summary>

```bash
# Check Docker system info
docker system df
docker system prune  # Clean up unused resources

# Monitor resource usage
docker stats

# Access container filesystem
docker exec -it jimgas_app ls -la /var/www
```

</details>

---

<div align="center">
  <p><strong>🎉 Happy Coding with Laravel & Docker! 🎉</strong></p>
  <p><em>Built with ❤️ for developers</em></p>
</div>