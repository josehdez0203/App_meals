# App Meals API

## Inicio local

```sh
cp .env.example .env
make db-up
make migrate-up
set -a; source .env; set +a
make run
```

Para desarrollo local, la API usa por defecto la base `delivery` del Compose y
un secreto JWT de desarrollo. En producción debes definir `DATABASE_URL` y
`JWT_SECRET` explícitamente.

Para detener PostgreSQL sin borrar los datos:

```sh
make db-down
```

Después de modificar `queries/` o `migrations/`, regenera el acceso a datos:

```sh
make sqlc-generate
```

Este comando utiliza la instalación global de `sqlc`; el proyecto no descarga
ni mantiene una copia local del CLI.

## Autenticación

Registro:

```http
POST /auth/register
Content-Type: application/json

{"username":"Jose","email":"jose@example.com","password":"secret123"}
```

Inicio de sesión:

```http
POST /auth/login
Content-Type: application/json

{"email":"jose@example.com","password":"secret123"}
```

Ambos endpoints devuelven el usuario público y un JWT válido durante 24 horas.
