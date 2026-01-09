#!/bin/bash

# Odoo Docker Compose Setup Script
# This script creates necessary Docker volumes and sets up the environment

set -e

echo "🚀 Setting up Odoo Docker Compose environment..."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Create Docker volumes
echo "📦 Creating Docker volumes..."
volumes=("caddy_data" "caddy_config" "postgres_data" "odoo_data" "odoo_config" "odoo_addons")

for volume in "${volumes[@]}"; do
    if docker volume inspect "$volume" &> /dev/null; then
        echo "   Volume '$volume' already exists, skipping..."
    else
        docker volume create "$volume"
        echo "   ✅ Created volume: $volume"
    fi
done

echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found!"
    echo "   Creating .env from env.example..."
    cp env.example .env
    echo "   ✅ Created .env file"
    echo ""
    echo "📝 Please edit the .env file and configure your settings:"
    echo "   - Set your DOMAIN_NAME"
    echo "   - Set a strong POSTGRES_PASSWORD"
    echo "   - Adjust other settings as needed"
    echo ""
    echo "   Run: nano .env"
    echo ""
else
    echo "✅ .env file already exists"
    echo ""
fi

# Check if Caddyfile is configured
if grep -q "DOMAIN_NAME" caddy_config/Caddyfile; then
    echo "✅ Caddyfile is configured with environment variable"
else
    echo "⚠️  Please ensure your domain is configured in caddy_config/Caddyfile"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env file:        nano .env"
echo "2. Start services:        docker compose up -d"
echo "3. View logs:             docker compose logs -f"
echo "4. Access Odoo at:        https://your-domain.com"
echo ""

