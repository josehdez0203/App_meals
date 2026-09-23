# Repository Guidelines

`server2/` es la reescritura en Go de la API NestJS que vive en `../server/`.
Responde **solo JSON** (nada de plantillas HTML) y debe mantener el mismo
contrato de rutas, cuerpos y codigos de error que la version original, porque el
cliente Flutter (`../lib/`) ya depende de el.

## Project Structure & Module Organization

```text
cmd/api/main.go              arranque, configuracion y apagado ordenado
internal/config/             lectura de .env + entorno
internal/database/           pool de pgx
internal/httpx/              router, middlewares, JSON y contrato de errores
internal/auth/               firma y validacion de JWT (HS256)
internal/api/                handlers HTTP agrupados por modulo
internal/integrations/       interfaces de servicios externos + stubs
internal/store/              CODIGO GENERADO por sqlc (no editar a mano)
db/migrations/               migraciones golang-migrate (*.up.sql / *.down.sql)
db/queries/                  consultas SQL que consume sqlc
sqlc.yaml                    configuracion de sqlc
```

Reglas de organizacion:

- Todo acceso a base de datos pasa por `internal/store` (sqlc). No escribas SQL
  embebido en `internal/api`.
- El esquema vive en `db/migrations`; es la fuente de verdad. Si cambia el
  esquema, agrega una migracion nueva (nunca edites una ya aplicada).
- Cada modulo de la API tiene su archivo en `internal/api` y registra sus rutas
  en `registerXxxRoutes`, invocado desde `internal/api/api.go`.
- Las dependencias externas se usan a traves de las interfaces de
  `internal/integrations`; nunca llames a un SDK directamente desde un handler.

## Build, Test, and Development Commands

- `make run` compila y ejecuta la API.
- `make dev` ejecuta con recarga en caliente (air).
- `make db-up` levanta PostGIS; `make migrate-up` aplica el esquema.
- `make sqlc` regenera `internal/store` tras tocar `db/queries` o migraciones.
- `make build` compila en `bin/api`.
- `make test` / `make race` ejecutan las pruebas, `make vet` analiza el codigo.
- `make check` formatea, analiza, compila y prueba.

Ejecuta los comandos desde `server2/`: la configuracion se lee de `.env` en el
directorio actual.

## Coding Style & Naming Conventions

Go idiomatico, formateado con `gofmt`. `PascalCase` para lo exportado y
`camelCase` para lo interno. Los handlers son metodos de `*API` y se mantienen
cortos; la logica de negocio vive en funciones auxiliares del mismo paquete.
Envuelve los errores con contexto (`fmt.Errorf("...: %w", err)`).

Contrato que no se debe romper:

- Prefijo global `/api` en todas las rutas.
- Los errores de negocio responden `{"codeError": <int>}` con los valores de
  `internal/httpx/errors.go` (espejo de `ErrorCode` de la version NestJS).
- Las columnas `point` se exponen como `{"x": lat, "y": lng}`; en SQL se leen
  con `location[0]` / `location[1]`, nunca como `pgtype.Point`.
- Los POST responden 201 y los PATCH/DELETE 200, igual que NestJS.
- Se conservan los nombres con errata del original (`update-passwor`,
  `JWT_SECREAT`) para no romper a los clientes.

## Testing Guidelines

Usa el paquete `testing` con `net/http/httptest`. Nombra las pruebas
`TestFeature` y comprueba comportamiento observable: codigo de estado, cuerpo
JSON y rutas. Para las consultas usa una base PostGIS real o dobles del
`*store.Queries`; no mockees SQL a mano. Agrega cobertura de regresion por cada
bug corregido y una prueba por endpoint nuevo.

## Commit & Pull Request Guidelines

Asuntos cortos en imperativo (por ejemplo, `Add address endpoints`). Manten cada
commit enfocado. En el PR indica el cambio, los comandos de verificacion y, si
aplicas migraciones, la instruccion exacta de `migrate`. Señala explicitamente
cualquier cambio de configuracion o de contrato.
