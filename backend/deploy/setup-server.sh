#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/smarthome"
APP_USER="smarthome"
DB_NAME="${DB_NAME:-smarthome}"
DB_USER="${DB_USER:-smarthome}"
DB_PASSWORD="${DB_PASSWORD:?Set DB_PASSWORD before running this script}"
JWT_SECRET="${JWT_SECRET:?Set JWT_SECRET before running this script}"

if ! id "$APP_USER" >/dev/null 2>&1; then
  useradd --system --home "$APP_DIR" --shell /usr/sbin/nologin "$APP_USER"
fi

mkdir -p "$APP_DIR" /etc/smarthome
chown -R "$APP_USER:$APP_USER" "$APP_DIR"

mysql -uroot <<SQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

cat >/etc/smarthome/backend.env <<EOF
SERVER_PORT=8080
MYSQL_URL=jdbc:mysql://127.0.0.1:3306/${DB_NAME}?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true&useSSL=false
MYSQL_USER=${DB_USER}
MYSQL_PASSWORD=${DB_PASSWORD}
JWT_SECRET=${JWT_SECRET}
JWT_TTL_SECONDS=2592000
CORS_ORIGINS=*
EOF

chmod 600 /etc/smarthome/backend.env
chown root:root /etc/smarthome/backend.env

install -m 0644 smarthome-backend.service /etc/systemd/system/smarthome-backend.service
install -m 0644 nginx-smarthome.conf /etc/nginx/conf.d/smarthome.conf
nginx -t
systemctl daemon-reload
systemctl enable smarthome-backend
systemctl reload nginx

echo "Server prepared. Copy smarthome-backend.jar to ${APP_DIR}/smarthome-backend.jar, then run: systemctl restart smarthome-backend"
