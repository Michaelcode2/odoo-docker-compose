# Post-Deployment Configuration Guide

This guide covers essential configuration steps after successfully deploying Odoo 19.

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Security Configuration](#security-configuration)
3. [Email Configuration](#email-configuration)
4. [User Management](#user-management)
5. [Company Settings](#company-settings)
6. [Backup Strategy](#backup-strategy)
7. [Performance Optimization](#performance-optimization)
8. [Module Installation](#module-installation)
9. [System Maintenance](#system-maintenance)

---

## Initial Setup

### 1. Access Your Odoo Instance

- **URL:** `https://your-domain.com` or `http://localhost:8069`
- **Admin Email:** The email you set during database creation
- **Admin Password:** The password you set during database creation

### 2. Complete Company Information

1. Go to **Settings** → **General Settings**
2. Scroll to **Companies** section
3. Click **Update Info** or **Manage Companies**
4. Fill in:
   - Company Name
   - Address
   - Phone
   - Email
   - Website
   - Tax ID / VAT number
   - Logo (upload your company logo)
   - Currency
   - Timezone

---

## Security Configuration

### 1. Enable Two-Factor Authentication (2FA)

**For Admin Account:**
1. Click your **profile icon** (top right) → **My Profile**
2. Click **Account Security** tab
3. Enable **Two-factor authentication**
4. Scan QR code with authenticator app (Google Authenticator, Authy, etc.)
5. Enter verification code

**Enforce for All Users:**
1. Go to **Settings** → **Users & Companies** → **Users**
2. Open each user account
3. Go to **Account Security** tab
4. Enable **Two-factor authentication**

### 2. Set Password Policy

1. Go to **Settings** → **General Settings**
2. Scroll to **Security** section
3. Configure:
   - **Password Expiration:** Set password expiration days (e.g., 90 days)
   - **Minimum Password Length:** Set to at least 8 characters
   - Enable **Password Policy** to require:
     - Lowercase letters
     - Uppercase letters
     - Numbers
     - Special characters

### 3. Configure Session Settings

1. In **Settings** → **General Settings** → **Security**
2. Set **Inactivity Session Timeout** (e.g., 30 minutes)
3. This automatically logs out inactive users

### 4. Restrict Access by IP (Optional)

If using Caddy, you can restrict access by IP in the Caddyfile:

```caddy
odoo.yourdomain.com {
    @allowed {
        remote_ip 192.168.1.0/24 203.0.113.0/24
    }
    handle @allowed {
        # ... existing reverse_proxy configuration
    }
    handle {
        respond "Access Denied" 403
    }
}
```

### 5. Review Database Manager Access

**Important:** Secure your database manager:

1. Access: `https://your-domain.com/web/database/manager`
2. Set a **strong master password** if not done already
3. **Disable database manager in production:**

Edit Odoo configuration:
```bash
docker compose exec odoo bash
nano /etc/odoo/odoo.conf
```

Add:
```ini
[options]
list_db = False
```

Restart Odoo:
```bash
docker compose restart odoo
```

---

## Email Configuration

### 1. Configure Outgoing Email (SMTP)

1. Go to **Settings** → **Technical** → **Outgoing Mail Servers**
   - If you don't see **Technical** menu, enable **Developer Mode**:
     - Settings → Activate Developer Mode
2. Click **Create**
3. Fill in SMTP details:
   - **Description:** e.g., "Company Mail Server"
   - **SMTP Server:** smtp.gmail.com (or your provider)
   - **SMTP Port:** 587 (TLS) or 465 (SSL)
   - **Connection Security:** TLS (STARTTLS) or SSL/TLS
   - **Username:** your-email@gmail.com
   - **Password:** Your email password or app password

**For Gmail:**
- Enable **2-Step Verification** in your Google account
- Generate an **App Password**: https://myaccount.google.com/apppasswords
- Use the app password instead of your regular password

4. Click **Test Connection** to verify
5. **Set as Default** if needed

### 2. Configure Incoming Email (IMAP) - Optional

For receiving emails in Odoo (helpdesk, leads, etc.):

1. Go to **Settings** → **Technical** → **Incoming Mail Servers**
2. Click **Create**
3. Fill in:
   - **Name:** e.g., "Support Inbox"
   - **Server Type:** IMAP Server
   - **Server:** imap.gmail.com
   - **Port:** 993
   - **SSL/TLS:** Enabled
   - **Username:** your-email@gmail.com
   - **Password:** Your app password
   - **Create New Record:** Choose destination (e.g., Lead/Opportunity)

4. Click **Test & Confirm**
5. Click **Fetch Now** to test

### 3. Configure Email Templates

1. Go to **Settings** → **Technical** → **Email Templates**
2. Customize default templates for:
   - Invoices
   - Sales Orders
   - Purchase Orders
   - User invitations

---

## User Management

### 1. Create User Accounts

1. Go to **Settings** → **Users & Companies** → **Users**
2. Click **Create**
3. Fill in:
   - **Name**
   - **Email Address** (used for login)
   - **Phone** (optional)
   - **Company** (if multi-company)

### 2. Assign Access Rights

**Access Rights Types:**
- **User:** Standard user access
- **Administrator:** Full access to settings

**Module-Specific Rights:**
1. In the user form, go to **Access Rights** tab
2. Set permissions for each module:
   - **Sales:** User / Administrator / None
   - **Inventory:** User / Administrator / None
   - **Accounting:** Billing / Accountant / Advisor / None
   - **HR:** Officer / Manager / None
   - etc.

### 3. Best Practices

- **Principle of Least Privilege:** Only grant necessary permissions
- **Separate Admin Account:** Don't use admin account for daily work
- **Regular Audits:** Review user access quarterly
- **Disable Unused Accounts:** Deactivate users who left the company

---

## Company Settings

### 1. Configure Fiscal Settings

1. Go to **Accounting** → **Configuration** → **Settings**
2. Set:
   - **Fiscal Country**
   - **Default Taxes**
   - **Fiscal Positions**
   - **Chart of Accounts** (if not loaded)

### 2. Configure Currency

1. Go to **Settings** → **General Settings**
2. In **Multi-Currencies** section:
   - **Enable if needed**
   - Set **Main Currency**
   - Activate other currencies if doing international business

### 3. Configure Payment Terms

1. Go to **Accounting** → **Configuration** → **Payment Terms**
2. Create common payment terms:
   - Immediate Payment
   - 15 Days
   - 30 Days
   - 30% Down, 70% on Delivery

### 4. Configure Bank Accounts

1. Go to **Accounting** → **Configuration** → **Bank Accounts**
2. Click **Create**
3. Add your company bank accounts with:
   - Account Number
   - Bank Name
   - SWIFT/BIC code

---

## Backup Strategy

### 1. Automated Database Backups

Create a cron job for daily backups:

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * cd /home/michael/Документи/Projects/odoo-docker-compose && ./backup.sh >> /var/log/odoo-backup.log 2>&1
```

### 2. Manual Backup

Use the provided backup script:

```bash
./backup.sh
```

This creates backups in `./backups/` directory.

### 3. Offsite Backup Storage

**Option A: Cloud Storage (rsync to cloud)**
```bash
# After backup, sync to cloud storage
rsync -avz ./backups/ user@remote-server:/backups/odoo/
```

**Option B: AWS S3**
```bash
# Install AWS CLI
apt install awscli

# Configure AWS credentials
aws configure

# Sync to S3 after backup
aws s3 sync ./backups/ s3://your-bucket-name/odoo-backups/
```

### 4. Test Restore Process

**Test your backups regularly:**
```bash
# Restore to a test instance
./restore.sh backups/latest_backup.sql
```

### 5. Backup Retention Policy

Recommended retention:
- **Daily backups:** Keep for 7 days
- **Weekly backups:** Keep for 4 weeks
- **Monthly backups:** Keep for 12 months

Create a cleanup script:
```bash
# cleanup_old_backups.sh
#!/bin/bash
find ./backups/ -name "*.sql" -mtime +7 -delete
find ./backups/ -name "*.tar.gz" -mtime +7 -delete
```

---

## Performance Optimization

### 1. Monitor Resource Usage

```bash
# Check container stats
docker stats

# Check Odoo memory usage
docker stats odoo-docker-compose-odoo-1

# Check PostgreSQL memory usage
docker stats odoo-docker-compose-postgres-1
```

### 2. Optimize PostgreSQL

Create a file `postgres_tuning.conf` (optional):

```bash
# For 4GB RAM server
docker compose exec postgres bash -c "cat >> /var/lib/postgresql/data/pgdata/postgresql.conf" << EOF
shared_buffers = 1GB
effective_cache_size = 3GB
maintenance_work_mem = 256MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 10MB
min_wal_size = 1GB
max_wal_size = 4GB
EOF

# Restart PostgreSQL
docker compose restart postgres
```

### 3. Enable Odoo Workers (Production)

For better performance, configure Odoo workers:

1. Create custom Odoo configuration:

```bash
docker compose exec odoo bash
cat >> /etc/odoo/odoo.conf << EOF

# Performance settings
workers = 4
max_cron_threads = 2
limit_memory_hard = 2684354560
limit_memory_soft = 2147483648
limit_request = 8192
limit_time_cpu = 600
limit_time_real = 1200
EOF

exit
```

2. Restart Odoo:
```bash
docker compose restart odoo
```

**Worker calculation formula:**
```
workers = (number_of_cpu_cores * 2) + 1
```

### 4. Monitor Logs

```bash
# Watch for slow queries
docker compose logs -f postgres | grep "slow"

# Watch for errors
docker compose logs -f odoo | grep "ERROR"
```

---

## Module Installation

### 1. Install Essential Modules

Go to **Apps** and install modules based on your needs:

**Core Business Modules:**
- ✅ **Sales Management** - CRM, quotes, sales orders
- ✅ **Invoicing / Accounting** - Invoices, payments, accounting
- ✅ **Inventory Management** - Stock, warehouse, logistics
- ✅ **Purchase Management** - RFQs, purchase orders, vendors
- ✅ **Manufacturing** - BOM, work orders, MRP
- ✅ **Project Management** - Projects, tasks, timesheets
- ✅ **HR Management** - Employees, leaves, expenses
- ✅ **Website Builder** - Public website, eCommerce
- ✅ **Marketing** - Email marketing, automation, events

**Productivity Modules:**
- ✅ **Calendar** - Meetings, appointments
- ✅ **Contacts** - Customer/vendor database
- ✅ **Documents** - Document management system
- ✅ **Approvals** - Approval workflows
- ✅ **Sign** - Electronic signatures

### 2. Install Custom Modules

If you have custom modules:

```bash
# Copy module to container
docker cp ./my_custom_module odoo-docker-compose-odoo-1:/mnt/extra-addons/

# Restart Odoo
docker compose restart odoo

# Update apps list in Odoo
# Settings → Apps → Update Apps List
```

### 3. Configure Installed Modules

After installing each module:
1. Go to module settings
2. Configure defaults
3. Import initial data if needed
4. Train users on the new module

---

## System Maintenance

### 1. Regular Updates

**Monthly maintenance routine:**

```bash
# 1. Create backup
./backup.sh

# 2. Update Docker images
docker compose pull

# 3. Recreate containers with new images
docker compose down
docker compose up -d

# 4. Check logs for errors
docker compose logs -f

# 5. Test critical functions
# - Login
# - Create/edit records
# - Generate reports
```

### 2. Database Maintenance

**Monthly vacuum (cleanup):**
```bash
docker compose exec postgres vacuumdb -U odoo -d odoo -v -f -z
```

### 3. Monitor Disk Space

```bash
# Check volume sizes
docker system df -v

# Check database size
docker compose exec postgres psql -U odoo -d odoo -c "SELECT pg_size_pretty(pg_database_size('odoo'));"

# Clean old logs
docker compose exec odoo bash -c "find /var/log -name '*.log' -mtime +30 -delete"
```

### 4. Security Updates

**Weekly security checks:**
- Review **Settings** → **Users** → **Log items** for suspicious activity
- Check failed login attempts
- Review access rights changes
- Update system packages:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Restart if kernel updated
sudo reboot
```

### 5. Health Check Script

Create `health_check.sh`:

```bash
#!/bin/bash
echo "=== Odoo Health Check ==="
echo "Services status:"
docker compose ps

echo -e "\nDisk usage:"
df -h | grep -E '/$|/var/lib/docker'

echo -e "\nDatabase size:"
docker compose exec -T postgres psql -U odoo -d odoo -c "SELECT pg_size_pretty(pg_database_size('odoo'));"

echo -e "\nOdoo HTTP check:"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8069

echo -e "\n\nRecent errors (last 50 lines):"
docker compose logs --tail=50 odoo | grep ERROR
```

Run weekly:
```bash
chmod +x health_check.sh
./health_check.sh
```

---

## Monitoring and Alerts

### 1. Setup Email Alerts

Configure server to send email alerts for:
- Low disk space
- Service failures
- Backup failures

### 2. Monitor Key Metrics

**Things to monitor:**
- CPU usage (should be < 80% average)
- RAM usage (should be < 90%)
- Disk space (keep 20% free)
- Response time (should be < 2 seconds)
- Database size growth
- Backup success/failure

### 3. Log Rotation

Ensure Docker logs don't fill up disk:

Edit `/etc/docker/daemon.json`:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Restart Docker:
```bash
sudo systemctl restart docker
docker compose up -d
```

---

## Troubleshooting Common Issues

### Issue: Odoo is Slow

**Solutions:**
1. Check resource usage: `docker stats`
2. Enable workers (see Performance Optimization)
3. Vacuum database: `docker compose exec postgres vacuumdb -U odoo -d odoo -z`
4. Check for long-running queries

### Issue: Can't Send Emails

**Solutions:**
1. Test SMTP settings in Settings → Technical → Outgoing Mail Servers
2. Check firewall allows outbound port 587/465
3. Verify email credentials
4. Check spam folder for test emails

### Issue: Users Can't Login

**Solutions:**
1. Verify user account is active
2. Check password hasn't expired
3. Clear browser cache
4. Check 2FA settings
5. Review logs: `docker compose logs odoo | grep LOGIN`

### Issue: Module Won't Install

**Solutions:**
1. Check Odoo logs: `docker compose logs odoo`
2. Verify all dependencies are met
3. Try updating apps list first
4. Restart Odoo: `docker compose restart odoo`

---

## Additional Resources

- **Odoo Documentation:** https://www.odoo.com/documentation/19.0/
- **Odoo Community Forum:** https://www.odoo.com/forum
- **Security Best Practices:** https://www.odoo.com/documentation/19.0/administration/security.html
- **Performance Optimization:** https://www.odoo.com/documentation/19.0/administration/deployment.html

---

## Checklist: Post-Deployment Complete

- [ ] Company information configured
- [ ] Admin account secured with 2FA
- [ ] Password policy enforced
- [ ] Email sending configured and tested
- [ ] User accounts created with proper permissions
- [ ] Automated backups scheduled
- [ ] Backup restoration tested
- [ ] Essential modules installed
- [ ] Database manager access secured
- [ ] Performance monitoring setup
- [ ] SSL certificate verified
- [ ] Firewall rules configured
- [ ] Documentation shared with team

---

**Congratulations!** Your Odoo instance is now properly configured and secured for production use. 🎉

