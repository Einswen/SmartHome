# SmartHome Backend

Spring Boot + MySQL backend for user login and per-user SmartHome state persistence.

## Local Run

Create the database:

```sql
CREATE DATABASE smarthome CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'smarthome'@'%' IDENTIFIED BY 'smarthome';
GRANT ALL PRIVILEGES ON smarthome.* TO 'smarthome'@'%';
FLUSH PRIVILEGES;
```

Run:

```bash
MYSQL_URL='jdbc:mysql://127.0.0.1:3306/smarthome?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true&useSSL=false' \
MYSQL_USER=smarthome \
MYSQL_PASSWORD=smarthome \
JWT_SECRET='replace-with-a-long-random-secret' \
mvn spring-boot:run
```

## API

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `GET /api/home/state`
- `PUT /api/home/state`
- `PATCH /api/home/active`
- `PUT /api/home/sections/{rooms|roomDevices|deviceStates|scenes|automations|notifications|agentRecords|agentMessages|preferences}`
- `PUT /api/home/room-devices/{roomId}`
- `PATCH /api/home/device-states/{pointId}`
- `POST /api/home/device-actions`

Every `/api/home/**` route requires `Authorization: Bearer <token>`.

`POST /api/home/device-actions` persists the requested adjustment and writes an action log. Physical device execution is intentionally left as the next integration step.
