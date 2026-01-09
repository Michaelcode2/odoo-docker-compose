# Odoo Docker Compose Deployment

A complete Docker Compose setup for deploying Odoo 19 Community Edition with PostgreSQL database and Caddy reverse proxy with automatic SSL certificates.

## 📋 Overview

This deployment includes:
- **Odoo 19.0** - Latest community edition
- **PostgreSQL 16** - Database backend (Odoo 19 requires PostgreSQL 13+)
- **Caddy** - Reverse proxy with automatic HTTPS/SSL certificate management

## 🚀 Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- A domain name pointing to your server (for SSL certificates)

### Installation Steps

1. **Clone or navigate to this repository:**
   ```bash
   cd /home/michael/Документи/Projects/odoo-docker-compose
   ```

2. **Create Docker volumes:**
   ```bash
   docker volume create caddy_data
   docker volume create caddy_config
   docker volume create postgres_data
   docker volume create odoo_data
   docker volume create odoo_config
   docker volume create odoo_addons
   ```

3. **Configure environment variables:**
   ```bash
   cp env.example .env
   nano .env
   ```

4. **Update the Caddyfile:**
   Edit `caddy_config/Caddyfile` and replace the domain name with your actual domain.

5. **Start the services:**
   ```bash
   docker compose up -d
   ```

6. **Access Odoo:**
   - Open your browser and navigate to your domain (e.g., https://odoo.yourdomain.com)
   - Create your first database and set up the admin account

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the project root with the following variables:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `DOMAIN_NAME` | Your domain name for Odoo | odoo.yourdomain.com | Yes |
| `POSTGRES_DB` | PostgreSQL database name | odoo | No |
| `POSTGRES_USER` | PostgreSQL username | odoo | No |
| `POSTGRES_PASSWORD` | PostgreSQL password | - | **Yes** |
| `TZ` | Timezone | Europe/Kiev | No |

**Example .env file:**
```env
DOMAIN_NAME=odoo.yourdomain.com
POSTGRES_DB=odoo
POSTGRES_USER=odoo
POSTGRES_PASSWORD=SuperSecurePassword123!
TZ=Europe/Kiev
```

### Caddyfile Configuration

The Caddyfile is located at `caddy_config/Caddyfile`. It's configured to:
- Automatically obtain and renew SSL certificates via Let's Encrypt
- Handle HTTP to HTTPS redirection
- Proxy requests to Odoo (port 8069)
- Handle longpolling requests (port 8072) for real-time features
- Enable compression (gzip, zstd)
- Add security headers

**Important:** Update the domain in the Caddyfile:
```caddy
{$DOMAIN_NAME} {
    # ... configuration
}
```

## 📦 Services

### Odoo
- **Image:** `odoo:19.0`
- **Ports:** 8069 (web), 8072 (longpolling)
- **Volumes:**
  - `odoo_data`: Application data
  - `odoo_config`: Configuration files
  - `odoo_addons`: Custom addons directory

### PostgreSQL
- **Image:** `postgres:16`
- **Port:** 5432 (internal only)
- **Volume:** `postgres_data`

### Caddy
- **Image:** `caddy:latest`
- **Ports:** 80 (HTTP), 443 (HTTPS)
- **Volumes:**
  - `caddy_data`: SSL certificates and data
  - `caddy_config`: Caddy configuration

## 🔄 Management Commands

### View logs
```bash
docker compose logs -f
docker compose logs -f odoo
docker compose logs -f postgres
docker compose logs -f caddy
```

### Stop services
```bash
docker compose stop
```

### Restart services
```bash
docker compose restart
```

### Stop and remove containers
```bash
docker compose down
```

### Update Odoo to latest version
```bash
# Pull latest images
docker compose pull

# Stop and remove containers
docker compose down

# Start with new images
docker compose up -d
```

## 📁 Data Persistence

All data is stored in Docker volumes:
- **caddy_data**: SSL certificates and Caddy data
- **caddy_config**: Caddy configuration cache
- **postgres_data**: PostgreSQL database files
- **odoo_data**: Odoo application data (filestore, sessions)
- **odoo_config**: Odoo configuration files
- **odoo_addons**: Custom Odoo modules/addons

### Backup

To backup your Odoo installation:

```bash
# Backup PostgreSQL database
docker compose exec -T postgres pg_dump -U odoo odoo > odoo_backup_$(date +%Y%m%d).sql

# Backup Odoo filestore
docker run --rm -v odoo_data:/data -v $(pwd):/backup ubuntu tar czf /backup/odoo_data_$(date +%Y%m%d).tar.gz /data

# Backup custom addons
docker run --rm -v odoo_addons:/data -v $(pwd):/backup ubuntu tar czf /backup/odoo_addons_$(date +%Y%m%d).tar.gz /data
```

### Restore

```bash
# Restore PostgreSQL database
docker compose exec -T postgres psql -U odoo odoo < odoo_backup_YYYYMMDD.sql

# Restore Odoo filestore
docker run --rm -v odoo_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/odoo_data_YYYYMMDD.tar.gz -C /
```

## 🔧 Troubleshooting

### Check service status
```bash
docker compose ps
```

### View container logs
```bash
docker compose logs odoo
```

### Access Odoo container shell
```bash
docker compose exec odoo bash
```

### Access PostgreSQL
```bash
docker compose exec postgres psql -U odoo -d odoo
```

### Reset database
```bash
docker compose down
docker volume rm postgres_data
docker volume create postgres_data
docker compose up -d
```

## 🌐 Custom Addons

To add custom Odoo modules:

1. Copy your addon folders to the `odoo_addons` volume:
   ```bash
   docker run --rm -v odoo_addons:/mnt/extra-addons -v $(pwd)/my_addon:/source ubuntu cp -r /source /mnt/extra-addons/
   ```

2. Restart Odoo:
   ```bash
   docker compose restart odoo
   ```

3. Update the apps list in Odoo (Settings → Apps → Update Apps List)

## 🔐 Security Recommendations

1. **Use strong passwords** for the PostgreSQL database
2. **Enable firewall** to restrict access to ports 80 and 443 only
3. **Regular backups** of database and filestore
4. **Keep Docker images updated** regularly
5. **Use fail2ban** to protect against brute force attacks
6. **Enable two-factor authentication** in Odoo for admin users

## 📚 References

- [Official Odoo Docker Image](https://github.com/odoo/docker)
- [Odoo 19 Documentation](https://www.odoo.com/documentation/19.0/)
- [Odoo 19 System Requirements](https://kodershop.com/blog/odoo-articles-3/odoo-19-system-requirements-517)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Deployment Guide](https://medium.com/@rajeshpachaikani/deploying-odoo-in-minutes-with-docker-compose-61a4d07b8877)

## ⚙️ Version Compatibility

- **Odoo 19**: Requires PostgreSQL 13 or higher
- **PostgreSQL 16**: Fully compatible with Odoo 19
- **Caddy**: Latest version with HTTP/3 support

## 📄 License

This deployment configuration is provided as-is. Odoo is licensed under LGPL-3.0.

## 🤝 Support

For issues related to:
- **Odoo functionality**: [Odoo Community Forum](https://www.odoo.com/forum)
- **Docker setup**: Create an issue in this repository
- **Caddy configuration**: [Caddy Community](https://caddy.community/)
Docker-compose configuration for odoo
