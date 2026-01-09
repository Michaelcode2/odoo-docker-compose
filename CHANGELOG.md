# Changelog

All notable changes to this Odoo Docker Compose deployment will be documented in this file.

## [2.0.0] - 2026-01-09

### Changed
- **MAJOR**: Updated Odoo from version 18.0 to **19.0**
- Updated all documentation to reflect Odoo 19.0
- Verified PostgreSQL 16 compatibility with Odoo 19

### Added
- `VERSION_INFO.md` - Comprehensive version compatibility documentation
- Detailed PostgreSQL version compatibility matrix (13-17 supported)
- Version upgrade procedures
- Docker image tag reference guide

### Verified
- ✅ Odoo 19.0 Docker image availability
- ✅ PostgreSQL 16 compatibility (Odoo 19 requires PostgreSQL 13+)
- ✅ All components working together

### Technical Details
- Odoo 19.0 requires PostgreSQL 13 or higher
- PostgreSQL 16 is fully compatible and recommended
- No breaking changes in Docker Compose configuration
- All existing volumes and configurations remain compatible

## [1.0.0] - 2026-01-09

### Added
- Initial release with Odoo 18.0
- Docker Compose setup with three services:
  - Odoo (web application)
  - PostgreSQL (database)
  - Caddy (reverse proxy with SSL)
- Automated setup script (`setup.sh`)
- Backup script (`backup.sh`)
- Restore script (`restore.sh`)
- Comprehensive README documentation
- Quick Start guide
- Environment variables template
- Caddyfile configuration for SSL/TLS
- Docker volume persistence
- Health checks for PostgreSQL
- Security headers configuration
- .gitignore file

### Features
- Automatic SSL certificate management via Caddy
- Longpolling support for real-time features
- WebSocket support
- Compression (gzip, zstd)
- Proper networking isolation
- Data persistence using Docker volumes
- Easy backup and restore procedures

---

## Version Compatibility

| Date       | Odoo Version | PostgreSQL Version | Caddy Version |
|------------|--------------|-------------------|---------------|
| 2026-01-09 | 19.0         | 16                | latest        |
| 2026-01-09 | 18.0         | 16                | latest        |

