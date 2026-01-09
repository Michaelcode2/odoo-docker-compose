# Version Information and Compatibility

## Current Deployment Versions

| Component   | Version | Docker Image        |
|-------------|---------|---------------------|
| Odoo        | 19.0    | `odoo:19.0`        |
| PostgreSQL  | 16      | `postgres:16`      |
| Caddy       | Latest  | `caddy:latest`     |

## Version Compatibility Matrix

### Odoo 19.0 Requirements

**PostgreSQL Compatibility:**
- ✅ PostgreSQL 13 (Minimum required)
- ✅ PostgreSQL 14 (Supported)
- ✅ PostgreSQL 15 (Supported)
- ✅ PostgreSQL 16 (Recommended - Current deployment)
- ✅ PostgreSQL 17 (Supported)

**System Requirements:**
- Python 3.10+
- 64-bit operating system
- Minimum 2GB RAM (4GB+ recommended for production)
- Minimum 2GB disk space (more for production data)

### Why PostgreSQL 16?

PostgreSQL 16 is chosen for this deployment because:

1. **Fully Compatible**: Odoo 19 officially supports PostgreSQL 13-17
2. **Performance**: PostgreSQL 16 includes significant performance improvements:
   - Better query parallelization
   - Improved indexing
   - Enhanced JSON/JSONB operations
3. **Security**: Latest security patches and improvements
4. **Long-term Support**: Active development and maintenance
5. **Modern Features**: Latest PostgreSQL features available to Odoo

### Odoo Version History

- **Odoo 19.0** (Current) - Released 2024 - Latest features and improvements
- **Odoo 18.0** - Previous LTS version
- **Odoo 17.0** - Previous stable version

## Upgrading Versions

### Upgrading Odoo

To upgrade to a newer Odoo version (when available):

```bash
# Update docker-compose.yml to use new version
# Example: image: odoo:20.0

# Pull new image
docker compose pull odoo

# Stop services
docker compose down

# Start with new version
docker compose up -d

# Check logs
docker compose logs -f odoo
```

**⚠️ Important**: Always backup your database before upgrading!

### Upgrading PostgreSQL

Upgrading PostgreSQL requires data migration:

```bash
# 1. Backup current database
./backup.sh

# 2. Stop services
docker compose down

# 3. Update PostgreSQL version in docker-compose.yml
# Example: image: postgres:17

# 4. Remove old PostgreSQL volume (after backup!)
docker volume rm postgres_data

# 5. Create new volume
docker volume create postgres_data

# 6. Start services
docker compose up -d

# 7. Restore database to new PostgreSQL version
./restore.sh
```

## Docker Image Tags

### Odoo Tags

- `odoo:19.0` - Odoo 19.0 (current)
- `odoo:19` - Alias for 19.0
- `odoo:latest` - Latest stable version
- `odoo:18.0` - Odoo 18.0 LTS
- `odoo:17.0` - Odoo 17.0

### PostgreSQL Tags

- `postgres:16` - PostgreSQL 16.x (current)
- `postgres:15` - PostgreSQL 15.x
- `postgres:17` - PostgreSQL 17.x
- `postgres:latest` - Latest stable version (not recommended for production)

### Caddy Tags

- `caddy:latest` - Latest stable version (current)
- `caddy:2` - Caddy 2.x
- `caddy:2-alpine` - Smaller Alpine-based image

## Version Verification

After deployment, verify versions:

```bash
# Check Odoo version
docker compose exec odoo odoo --version

# Check PostgreSQL version
docker compose exec postgres psql -U odoo -c "SELECT version();"

# Check Caddy version
docker compose exec caddy caddy version
```

## References

- [Odoo 19 System Requirements](https://kodershop.com/blog/odoo-articles-3/odoo-19-system-requirements-517)
- [Odoo Docker Hub](https://hub.docker.com/_/odoo)
- [PostgreSQL Version Policy](https://www.postgresql.org/support/versioning/)
- [Caddy Releases](https://github.com/caddyserver/caddy/releases)

## Update Schedule

- **Odoo**: Major versions released annually (October)
- **PostgreSQL**: New major version annually
- **Caddy**: Regular updates, automatic patch updates recommended

---

Last Updated: January 2026

