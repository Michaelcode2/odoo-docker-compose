#!/bin/bash

# Odoo Restore Script
# Restores backups of PostgreSQL database, Odoo data, and custom addons

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

BACKUP_DIR="./backups"

echo "🔄 Odoo Restore Script"
echo ""

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup directory not found: $BACKUP_DIR"
    exit 1
fi

# List available backups
echo "📁 Available database backups:"
ls -1 "$BACKUP_DIR"/*.sql.gz 2>/dev/null | nl || echo "   No database backups found"
echo ""

# Prompt for database backup file
read -p "Enter the database backup filename (or press Enter to skip): " DB_BACKUP
echo ""

# Prompt for data backup file
echo "📁 Available data backups:"
ls -1 "$BACKUP_DIR"/odoo_data_*.tar.gz 2>/dev/null | nl || echo "   No data backups found"
echo ""
read -p "Enter the data backup filename (or press Enter to skip): " DATA_BACKUP
echo ""

# Prompt for addons backup file
echo "📁 Available addon backups:"
ls -1 "$BACKUP_DIR"/odoo_addons_*.tar.gz 2>/dev/null | nl || echo "   No addon backups found"
echo ""
read -p "Enter the addons backup filename (or press Enter to skip): " ADDONS_BACKUP
echo ""

# Confirm restore operation
echo "⚠️  WARNING: This will overwrite existing data!"
echo ""
if [ ! -z "$DB_BACKUP" ]; then
    echo "   Database: $DB_BACKUP"
fi
if [ ! -z "$DATA_BACKUP" ]; then
    echo "   Data: $DATA_BACKUP"
fi
if [ ! -z "$ADDONS_BACKUP" ]; then
    echo "   Addons: $ADDONS_BACKUP"
fi
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 0
fi

echo ""
echo "🔄 Starting restore process..."

# Stop Odoo service
echo "⏸️  Stopping Odoo service..."
docker compose stop odoo

# Restore database
if [ ! -z "$DB_BACKUP" ] && [ -f "$BACKUP_DIR/$DB_BACKUP" ]; then
    echo "📊 Restoring PostgreSQL database..."
    
    # Drop existing database
    docker compose exec -T postgres psql -U ${POSTGRES_USER:-odoo} -d postgres -c "DROP DATABASE IF EXISTS ${POSTGRES_DB:-odoo};"
    
    # Create new database
    docker compose exec -T postgres psql -U ${POSTGRES_USER:-odoo} -d postgres -c "CREATE DATABASE ${POSTGRES_DB:-odoo};"
    
    # Restore database
    gunzip -c "$BACKUP_DIR/$DB_BACKUP" | docker compose exec -T postgres psql -U ${POSTGRES_USER:-odoo} -d ${POSTGRES_DB:-odoo}
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Database restored successfully"
    else
        echo "   ❌ Database restore failed!"
        exit 1
    fi
else
    echo "⏭️  Skipping database restore"
fi

# Restore Odoo data
if [ ! -z "$DATA_BACKUP" ] && [ -f "$BACKUP_DIR/$DATA_BACKUP" ]; then
    echo "📁 Restoring Odoo filestore..."
    docker run --rm -v odoo_data:/data -v $(pwd)/$BACKUP_DIR:/backup ubuntu sh -c "rm -rf /data/* && tar xzf /backup/$DATA_BACKUP -C /data"
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Filestore restored successfully"
    else
        echo "   ❌ Filestore restore failed!"
    fi
else
    echo "⏭️  Skipping filestore restore"
fi

# Restore custom addons
if [ ! -z "$ADDONS_BACKUP" ] && [ -f "$BACKUP_DIR/$ADDONS_BACKUP" ]; then
    echo "📦 Restoring custom addons..."
    docker run --rm -v odoo_addons:/data -v $(pwd)/$BACKUP_DIR:/backup ubuntu sh -c "rm -rf /data/* && tar xzf /backup/$ADDONS_BACKUP -C /data"
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Addons restored successfully"
    else
        echo "   ❌ Addons restore failed!"
    fi
else
    echo "⏭️  Skipping addons restore"
fi

# Start Odoo service
echo "▶️  Starting Odoo service..."
docker compose start odoo

echo ""
echo "🎉 Restore completed!"
echo ""
echo "Next steps:"
echo "1. Check logs:        docker compose logs -f odoo"
echo "2. Access Odoo:       https://your-domain.com"
echo ""

