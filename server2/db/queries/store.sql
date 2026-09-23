-- Tiendas. Usado por manager/store (listado con empresa y categorias) y por
-- manager/enrollment (alta).

-- name: ListStoresByManager :many
-- Devuelve una fila por tienda/categoria; la API agrupa en Go. Equivale a
-- storeRepository.find({ relations: { company: { categories: true } } }).
SELECT s.id, s.name, s.address, s.contact, s.email,
       s."startupCost", s."costKm", s.sales, s."createdAt", s."updatedAt",
       s.location[0]::float8 AS latitude,
       s.location[1]::float8 AS longitude,
       c.id AS company_id, c.name AS company_name, c.address AS company_address,
       c.contact AS company_contact, c.image AS company_image,
       c.marker AS company_marker, c.email AS company_email,
       c."createdAt" AS company_created_at, c."updatedAt" AS company_updated_at,
       c.location[0]::float8 AS company_latitude,
       c.location[1]::float8 AS company_longitude,
       cc.id AS company_category_id,
       cc."updatedAt" AS company_category_updated_at,
       cat.id AS category_id, cat.name AS category_name,
       cat.image AS category_image,
       cat."createdAt" AS category_created_at,
       cat."updatedAt" AS category_updated_at
FROM store s
INNER JOIN company c ON c.id = s."companyId"
LEFT JOIN company_category cc ON cc."companyId" = c.id
LEFT JOIN category cat ON cat.id = cc."categoryId"
WHERE s."userId" = $1
ORDER BY s.id DESC, cc.id;

-- name: CreateStore :one
INSERT INTO store (name, address, contact, email, location, "companyId", "userId")
VALUES ($1, $2, $3, $4, point($5, $6), $7, $8)
RETURNING id, name, address, contact, email,
          "startupCost", "costKm", sales, "createdAt", "updatedAt",
          location[0]::float8 AS latitude,
          location[1]::float8 AS longitude,
          "companyId", "userId";

-- name: ListStoresByCompany :many
SELECT id, name, address, contact, email, "startupCost", "costKm", sales,
       "createdAt", "updatedAt",
       location[0]::float8 AS latitude,
       location[1]::float8 AS longitude,
       "companyId", "userId"
FROM store
WHERE "companyId" = $1 AND "deletedAt" IS NULL
ORDER BY id
LIMIT $2 OFFSET $3;

-- name: GetStoreByID :one
SELECT id, name, address, contact, email, "startupCost", "costKm", sales,
       "createdAt", "updatedAt",
       location[0]::float8 AS latitude,
       location[1]::float8 AS longitude,
       "companyId", "userId"
FROM store
WHERE id = $1 AND "deletedAt" IS NULL;

-- name: UpdateStore :one
-- UpdateStoreDto solo permite name, address, contact, email y location.
UPDATE store
SET name = $2, address = $3, contact = $4, email = $5,
    location = point($6, $7), "deletedAt" = NULL, "updatedAt" = now()
WHERE id = $1 AND "deletedAt" IS NULL
RETURNING id, name, address, contact, email, "startupCost", "costKm", sales,
          "createdAt", "updatedAt",
          location[0]::float8 AS latitude,
          location[1]::float8 AS longitude,
          "companyId", "userId";

-- name: SoftDeleteStore :execrows
UPDATE store SET "deletedAt" = now() WHERE id = $1 AND "deletedAt" IS NULL;
