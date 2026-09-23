# API de delivery en Go

Reescritura en Go de la API NestJS de `../server/`. Expone **solo JSON**, con el
mismo contrato de rutas y errores para no romper al cliente Flutter de `../lib/`.

## Stack

- Go 1.26 con `net/http` (router de la biblioteca estandar, patrones `{param}`).
- PostgreSQL + PostGIS via `pgx/v5`.
- `golang-migrate` para el esquema (`db/migrations`).
- `sqlc` para el acceso a datos tipado (`db/queries` -> `internal/store`).
- JWT HS256 (`golang-jwt/jwt/v5`) y bcrypt (`golang.org/x/crypto`).

## Puesta en marcha

```bash
cp .env.example .env

make db-up        # PostGIS en localhost:5432
make migrate-up   # crea el esquema
make run          # API en http://localhost:3000
```

Comprobacion rapida:

```bash
curl localhost:3000/health
```

El contenedor usa el mismo puerto, usuario y password que el compose de
`../server/` (5432 / `postgres` / `123456`). **Cuidado:** si el contenedor `jose`
de `server/` esta levantado, ese puerto ya esta ocupado; para correr los dos a la
vez exporta `DB_PORT=5433` y ajusta `DATABASE_URL`.

## Configuracion

| Variable | Descripcion |
| --- | --- |
| `SERVER_ADDRESS` | Direccion de escucha (por defecto `:3000`). |
| `DATABASE_URL` | Cadena de conexion. Puede escribirse con referencias a las demas variables del propio `.env`, por ejemplo `postgres://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable`; el cargador las expande. Si falta, se arma con `DB_*` o, en su defecto, `POSTGRES_*`. |
| `JWT_SECRET` | Secreto de firma. Acepta tambien `JWT_SECREAT`, el nombre con errata del original. |
| `FIREBASE_CREDENTIAL_JSON` | Credenciales de Firebase (push). |
| `API_KEY_GOOGLE` | API key de Google (autocompletado de direcciones). |
| `ACCOUNT_TRANSPORT` | Cuenta de correo para el envio de contrasenas. |
| `STRIPE_SECRET_KEY` | Clave secreta de Stripe. |

## Estructura

```text
cmd/api/                 arranque y apagado
internal/api/            handlers por modulo
internal/auth/           JWT
internal/config/         .env + entorno
internal/database/       pool de pgx
internal/httpx/          router, middlewares, JSON, errores
internal/integrations/   interfaces de servicios externos (+ stubs)
internal/store/          generado por sqlc
db/migrations/           golang-migrate
db/queries/              consultas de sqlc
```

## Integraciones externas

Firebase (push), Stripe (pagos), el envio de correo y el WebSocket de ubicacion
se consumen a traves de las interfaces de `internal/integrations`. Por defecto
se inyectan implementaciones **stub** que registran la llamada y no fallan, de
modo que la API arranca sin credenciales. Para activarlas, inyecta la
implementacion real desde `cmd/api` con los metodos `With*` de `api.New`.

## Comandos

```bash
make help            # lista todos los comandos
make sqlc            # regenera internal/store
make migrate-create name=add_algo
make test            # pruebas
make check           # fmt + vet + build + test
```

## Nota sobre `db/init.sql` de `../server/`

El esquema de este proyecto es equivalente al de la version NestJS, salvo que se
omite la tabla `typeorm_metadata` (artefacto interno de TypeORM sin uso en Go) y
los nombres de las constraints son legibles en lugar de hashes. Las vistas
(`vw_company`, `vw_category`, `vw_product`) y los indices GiST se conservan.

## Estado del port

Los **73 endpoints** de la version NestJS estan implementados y verificados con
`curl` contra un PostGIS real:

| Modulo | Endpoints |
| --- | --- |
| `auth` | 9 |
| `client/market` | 8 |
| `client/address` | 6 |
| `client/balance` | 1 |
| `client/payments` | 3 |
| `deliveryman/petition` | 8 |
| `manager/request` | 3 |
| `manager/enrollment` | 2 |
| `manager/store` | 6 |
| `admin` (company, store, product, category, company-category, hours, credit) | 23 |
| `chat` | 3 |
| `email` | 1 |

## Integraciones externas (stubs)

| Integracion | Interfaz | Comportamiento por defecto |
| --- | --- | --- |
| Push (Firebase) | `integrations.PushSender` | registra el envio en el log |
| Correo | `integrations.Mailer` | registra el correo en el log |
| Google OAuth | `integrations.GoogleOAuth` | devuelve `ErrNotConfigured` |
| Google Maps | `integrations.Geocoder` | devuelve listas vacias |
| Stripe | `integrations.PaymentGateway` | `POST /client/payments/payment` responde **501** |
| Socket.IO (ubicacion) | `integrations.Realtime` | **no implementado**: interfaz + stub |

El gateway de ubicacion de la version NestJS (`location-ws`) autenticaba el
handshake con JWT y atendia el evento `l` (reenvio a la sala y persistencia en
`session`). En Go queda como interfaz `integrations.Realtime`, y la parte de
persistencia esta expuesta como `API.UpdateDeliverymanLocation`, lista para que
la use una implementacion real inyectada desde `cmd/api` con `WithRealtime`.

Para activar cualquiera de ellas, inyecta la implementacion en `cmd/api` con los
metodos `WithPush`, `WithMailer`, `WithGoogleOAuth`, `WithPayments` y
`WithRealtime`.

## Diferencias conocidas con el cliente Flutter

Al portar se detectaron desajustes **preexistentes** entre la API NestJS y los
modelos de `../lib`. Se replico el comportamiento del servidor tal cual (no se
inventaron campos ni se cambiaron codigos), asi que siguen presentes:

- `CompanyModel` espera `type` y `OrderModel`/`PetitionModel` esperan `start`; la API no los devuelve.
- `FeeModel` espera `fromlt`/`fromlg`; la API solo devuelve `name, companyId, image, marker, store_id, deliveryfee`.
- `MarketService.getProducts` lee un `groups` que la API no devuelve.
- `MarketService.buy` exige HTTP 200 y `{"order": ...}`; la API responde 201 con el pedido desnudo.

Adaptar la API a esos modelos es un cambio aparte y acotado.

## Pruebas

`go test ./...` cubre el contrato de errores (`codeError`), mapeo de errores de
PostgreSQL, autenticacion sin token, validacion de DTOs, rutas desconocidas y los
helpers de parseo (`parseClock`, `parseDate`, `splitInt32`, `validateLocation`).
No requieren base de datos.
