# Quick Start Guide

This guide will help you deploy Odoo 19 in minutes.

## Prerequisites

- Ubuntu VM or Linux server
- Docker and Docker Compose installed
- Domain name pointing to your server's IP address

## Installation in 5 Steps

### Step 1: Run Setup Script

```bash
./setup.sh
```

This will:
- Create all necessary Docker volumes
- Create a `.env` file from the template

### Step 2: Configure Environment

Edit the `.env` file:

```bash
nano .env
```

**Required settings:**
- `DOMAIN_NAME`: Your domain (e.g., odoo.example.com)
- `POSTGRES_PASSWORD`: A strong password for the database

**Example:**
```env
DOMAIN_NAME=odoo.example.com
POSTGRES_DB=odoo
POSTGRES_USER=odoo
POSTGRES_PASSWORD=MySecurePassword123!
TZ=Europe/Kiev
```

Save and exit (Ctrl+X, then Y, then Enter).

### Step 3: Verify Domain Configuration

Make sure your domain's DNS A record points to your server's IP address:

```bash
dig +short your-domain.com
```

This should return your server's IP address.

### Step 4: Start Services

```bash
docker compose up -d
```

This will:
- Pull the Odoo, PostgreSQL, and Caddy images
- Start all services
- Automatically obtain SSL certificate from Let's Encrypt

### Step 5: Access Odoo

1. Open your browser and go to `https://your-domain.com`
2. You'll see the Odoo database creation page
3. Fill in the form:
   - **Database Name**: Choose a name (e.g., "production")
   - **Email**: Your admin email
   - **Password**: Your admin password
   - **Phone number**: Optional
   - **Language**: Select your language
   - **Country**: Select your country
4. Click "Create Database"

## Post-Installation

### Check Service Status

```bash
docker compose ps
```

All services should show "Up" status.

### View Logs

```bash
# All services
docker compose logs -f

# Only Odoo
docker compose logs -f odoo

# Only Postgres
docker compose logs -f postgres

# Only Caddy
docker compose logs -f caddy
```

### Access Odoo

- **Web Interface**: https://your-domain.com
- **Default Database**: The one you created in step 5

## Common Commands

```bash
# Stop all services
docker compose stop

# Start all services
docker compose start

# Restart all services
docker compose restart

# View logs
docker compose logs -f

# Update Odoo
docker compose pull
docker compose down
docker compose up -d

# Create backup
./backup.sh
```

## Troubleshooting

### SSL Certificate Not Working

1. Make sure your domain points to the correct IP
2. Check Caddy logs: `docker compose logs caddy`
3. Verify ports 80 and 443 are open on your firewall

### Can't Connect to Database

1. Check if PostgreSQL is running: `docker compose ps postgres`
2. Check PostgreSQL logs: `docker compose logs postgres`
3. Verify credentials in `.env` file

### Odoo Not Starting

1. Check Odoo logs: `docker compose logs odoo`
2. Make sure PostgreSQL is healthy: `docker compose ps`
3. Verify environment variables: `docker compose config`

## Security Checklist

- [ ] Strong PostgreSQL password set
- [ ] Strong Odoo admin password
- [ ] Firewall configured (allow only 80, 443, SSH)
- [ ] Regular backups scheduled
- [ ] SSL certificate obtained and valid
- [ ] Two-factor authentication enabled in Odoo
- [ ] Regular system updates

## Backup

Create a backup:

```bash
./backup.sh
```

Backups are stored in the `./backups` directory.

## Version Information

- **Odoo Version**: 19.0
- **PostgreSQL Version**: 16 (Odoo 19 requires PostgreSQL 13+)
- **Caddy Version**: Latest

## Support

- **Official Odoo Docker**: https://github.com/odoo/docker
- **Odoo 19 Documentation**: https://www.odoo.com/documentation/19.0/
- **Odoo 19 System Requirements**: https://kodershop.com/blog/odoo-articles-3/odoo-19-system-requirements-517
- **Community Forum**: https://www.odoo.com/forum

---

**That's it!** You now have a production-ready Odoo installation with automatic SSL certificates. 🎉

