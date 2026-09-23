-- Sesiones por dispositivo. La columna location es point y se expone como
-- latitud/longitud para que la API arme {"x": lat, "y": lng}.

-- name: DeleteSessionsByTokenPush :exec
DELETE FROM session
WHERE "tokenPush" = $1 AND "tokenPush" IS NOT NULL;

-- name: DeleteSessionByUserAndDevice :exec
DELETE FROM session
WHERE "userId" = $1 AND "idDevice" = $2;

-- name: CreateSession :one
INSERT INTO session ("userId", "idDevice", "tokenPush")
VALUES ($1, $2, $3)
RETURNING id, "userId", "idDevice", "tokenPush", "isOnline", "createdAt", "updateAt";

-- name: GetSessionByUserAndDevice :one
SELECT id, "userId", "idDevice", "tokenPush", "isOnline", "createdAt", "updateAt",
       COALESCE(location[0], 0)::float8 AS latitude,
       COALESCE(location[1], 0)::float8 AS longitude
FROM session
WHERE "userId" = $1 AND "idDevice" = $2;

-- name: SessionExistsByUserAndDevice :one
-- Comprobacion ligera usada por el middleware de autenticacion.
SELECT EXISTS (
    SELECT 1 FROM session WHERE "userId" = $1 AND "idDevice" = $2
) AS exists;

-- name: GetSessionByID :one
SELECT id, "userId", "idDevice", "tokenPush", "isOnline", "createdAt", "updateAt",
       COALESCE(location[0], 0)::float8 AS latitude,
       COALESCE(location[1], 0)::float8 AS longitude
FROM session
WHERE id = $1;

-- name: UpdateSessionTokenPush :execrows
UPDATE session
SET "tokenPush" = $3, "updateAt" = now()
WHERE "userId" = $1 AND "idDevice" = $2;

-- name: UpdateSessionActivate :execrows
UPDATE session
SET "isOnline" = $3, location = point($4, $5), "updateAt" = now()
WHERE "userId" = $1 AND "idDevice" = $2;

-- name: ListPushTokensByUser :many
SELECT "tokenPush"
FROM session
WHERE "userId" = $1 AND "tokenPush" IS NOT NULL AND "tokenPush" <> '';

-- name: ListSessionsDetailByID :many
SELECT id, "userId", "idDevice", "tokenPush", "isOnline", "createdAt", "updateAt",
       COALESCE(location[0], 0)::float8 AS latitude,
       COALESCE(location[1], 0)::float8 AS longitude
FROM session
WHERE "userId" = $1
ORDER BY id;

-- name: ListPushTokensNearby :many
-- Repartidores en linea dentro del radio (usado por las notificaciones).
SELECT s."tokenPush"
FROM session s
WHERE s."isOnline" = true
  AND s.location IS NOT NULL
  AND s."tokenPush" IS NOT NULL AND s."tokenPush" <> ''
  AND ST_DistanceSphere(ST_GeomFromText('POINT(' || sqlc.arg(latitude)::text || ' ' || sqlc.arg(longitude)::text || ')'), s.location::geometry) <= sqlc.arg(km)::float8;

-- name: UpdateSessionsLocationByUser :exec
-- Usado por el gateway de ubicacion (evento "l" de Socket.IO en la version
-- NestJS): actualiza la ubicacion de todas las sesiones del usuario.
UPDATE session
SET location = point($2, $3), "updateAt" = now()
WHERE "userId" = $1;
