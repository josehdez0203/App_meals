-- Direcciones del cliente. TypeORM aplicaba soft-delete (columna deletedAt),
-- por lo que las lecturas filtran deletedAt IS NULL.

-- name: CreateAddress :one
INSERT INTO address (alias, address, location, "userId")
VALUES ($1, $2, point($3, $4), $5)
RETURNING id, alias, address,
          location[0]::float8 AS latitude,
          location[1]::float8 AS longitude;

-- name: ListAddressesByUser :many
SELECT id, alias, address,
       location[0]::float8 AS latitude,
       location[1]::float8 AS longitude
FROM address
WHERE "userId" = $1 AND "deletedAt" IS NULL
ORDER BY id;

-- name: GetAddressByID :one
SELECT id, alias, address,
       location[0]::float8 AS latitude,
       location[1]::float8 AS longitude
FROM address
WHERE id = $1 AND "deletedAt" IS NULL;

-- name: UpdateAddress :one
UPDATE address
SET alias = $2, address = $3, location = point($4, $5),
    "deletedAt" = NULL, "updatedAt" = now()
WHERE id = $1 AND "deletedAt" IS NULL
RETURNING id, alias, address,
          location[0]::float8 AS latitude,
          location[1]::float8 AS longitude;

-- name: SoftDeleteAddress :execrows
UPDATE address
SET "deletedAt" = now()
WHERE id = $1 AND "deletedAt" IS NULL;
