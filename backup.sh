#!/bin/bash

# Odoo Backup Script
# Creates backups of PostgreSQL database, Odoo data, and custom addons

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "🔄 Starting Odoo backup process..."
echo "   Backup directory: $BACKUP_DIR"
echo "   Timestamp: $DATE"
echo ""

# Backup PostgreSQL database
echo "📊 Backing up PostgreSQL database..."
docker compose exec -T postgres pg_dump -U ${POSTGRES_USER:-odoo} ${POSTGRES_DB:-odoo} > "$BACKUP_DIR/odoo_db_$DATE.sql"
if [ $? -eq 0 ]; then
    gzip "$BACKUP_DIR/odoo_db_$DATE.sql"
    echo "   ✅ Database backup completed: odoo_db_$DATE.sql.gz"
else
    echo "   ❌ Database backup failed!"
    exit 1
fi

# Backup Odoo filestore/data
echo "📁 Backing up Odoo filestore..."
docker run --rm -v odoo_data:/data -v $(pwd)/$BACKUP_DIR:/backup ubuntu tar czf /backup/odoo_data_$DATE.tar.gz -C /data .
if [ $? -eq 0 ]; then
    echo "   ✅ Filestore backup completed: odoo_data_$DATE.tar.gz"
else
    echo "   ❌ Filestore backup failed!"
fi

# Backup custom addons
echo "📦 Backing up custom addons..."
docker run --rm -v odoo_addons:/data -v $(pwd)/$BACKUP_DIR:/backup ubuntu tar czf /backup/odoo_addons_$DATE.tar.gz -C /data .
if [ $? -eq 0 ]; then
    echo "   ✅ Addons backup completed: odoo_addons_$DATE.tar.gz"
else
    echo "   ❌ Addons backup failed!"
fi

echo ""
echo "🎉 Backup completed successfully!"
echo ""

# Calculate backup sizes
echo "📊 Backup Summary:"
ls -lh "$BACKUP_DIR" | grep "$DATE" | awk '{print "   " $9 " - " $5}'
echo ""

# Optional: Remove backups older than 30 days
read -p "Remove backups older than 30 days? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 Cleaning up old backups..."
    find "$BACKUP_DIR" -name "*.sql.gz" -mtime +30 -delete
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete
    echo "   ✅ Cleanup completed"
fi

echo ""
echo "✨ All done!"

