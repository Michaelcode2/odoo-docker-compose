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
- `POSTGRES_PASSWORD`: A strong password for the database

**Example:**
```env
POSTGRES_DB=odoo
POSTGRES_USER=odoo
POSTGRES_PASSWORD=MySecurePassword123!
TZ=Europe/Kiev
```

**Note:** Your domain is configured separately in the Caddyfile (next step).

Save and exit (Ctrl+X, then Y, then Enter).

### Step 3: Update Caddyfile with Your Domain

Edit the Caddyfile:

```bash
nano caddy_config/Caddyfile
```

**Replace line 2** with your actual domain:
```caddy
# Change this:
odoo.yourdomain.com {

# To your domain:
odoo.example.com {
```

Save and exit (Ctrl+X, then Y, then Enter).

### Step 4: Verify Domain Configuration

Make sure your domain's DNS A record points to your server's IP address:

```bash
dig +short your-domain.com
```

This should return your server's IP address.

### Step 5: Start Services

```bash
docker compose up -d
```

This will:
- Pull the Odoo, PostgreSQL, and Caddy images
- Start all services
- Automatically obtain SSL certificate from Let's Encrypt

### Step 6: Initialize Odoo Database

On first startup, Odoo needs to initialize the database. You have two options:

#### Option A: Initialize via Web Interface (Recommended)

1. Open your browser and go to `https://your-domain.com` or `http://localhost:8069`
2. You'll see the Odoo database creation page
3. Fill in the form:
   - **Database Name**: Choose a name (e.g., "production")
   - **Email**: Your admin email
   - **Password**: Your admin password
   - **Phone number**: Optional
   - **Language**: Select your language
   - **Country**: Select your country
4. Click "Create Database"

#### Option B: Initialize via Command Line

If the web interface shows errors or doesn't load properly, initialize manually:

```bash
docker compose down
docker compose run --rm odoo odoo -d odoo -i base --stop-after-init
docker compose up -d
```

This will initialize the database with base modules and restart all services.

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

### Database Not Initialized Error

If you see errors like:
```
ERROR ? odoo.modules.loading: Database odoo not initialized, you can force it with `-i base`
KeyError: 'ir.http'
```

**Solution:** Initialize the database manually:

```bash
docker compose down
docker compose run --rm odoo odoo -d odoo -i base --stop-after-init
docker compose up -d
```

After this, access Odoo at `https://your-domain.com` or `http://localhost:8069`.

You should see the Odoo Database Manager page where you can:
- Master Password: Leave blank or set a master password (this protects database management)
- Database Name: The database "odoo" should already exist and be listed
- Click on "odoo" to access it, and you'll be prompted to create the first admin user

Create a new (company) Database with Admin User:
- Look for the "Create Database" section
- Click "Create Database"
  - This will create a new database and set up your admin account
  - It may take a few minutes
- After creation, you'll be logged in automatically or can log in with:
  - Email: The email you just entered
  - Password: The password you just set

Note: The "odoo" database that was initialized is just the base structure - you still need to create a company database with your admin user!

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

## Next Steps

📘 **[Post-Deployment Configuration Guide](POST_DEPLOYMENT.md)** - Essential steps to properly configure your Odoo instance:
- Security configuration (2FA, password policies)
- Email setup (SMTP/IMAP)
- User management and permissions
- Company settings
- Automated backups
- Performance optimization
- Module installation
- System maintenance

Make sure to review and complete the post-deployment checklist!

