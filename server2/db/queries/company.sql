-- Empresas (comercios). Usado por manager/enrollment y, mas adelante, por admin.

-- name: GetCompanyByNameUpper :one
SELECT id, name, address, contact, image, marker, email,
       location[0]::float8 AS latitude,
       location[1]::float8 AS longitude,
       "createdAt", "updatedAt", "userId"
FROM company
WHERE UPPER(name) = UPPER($1);

-- name: GetCompanyByID :one
SELECT id, name, address, contact, image, marker, email,
       location[0]::float8 AS latitude,
       location[1]::float8 AS longitude,
       "createdAt", "updatedAt", "userId"
FROM company
WHERE id = $1;

-- name: CreateCompany :one
INSERT INTO company (name, address, contact, image, marker, email, location, "userId")
VALUES ($1, $2, $3, $4, $5, $6, point($7, $8), $9)
RETURNING id, name, address, contact, image, marker, email,
          location[0]::float8 AS latitude,
          location[1]::float8 AS longitude,
          "createdAt", "updatedAt", "userId";

-- name: ListCompanies :many
SELECT id, name, address, contact, image, marker, email,
       location[0]::float8 AS latitude,
       location[1]::float8 AS longitude,
       "createdAt", "updatedAt", "userId"
FROM company
ORDER BY id
LIMIT $1 OFFSET $2;

-- name: FindCompanyByTerm :one
SELECT id, name, address, contact, image, marker, email,
       location[0]::float8 AS latitude,
       location[1]::float8 AS longitude,
       "createdAt", "updatedAt", "userId"
FROM company
WHERE name = $1 OR address LIKE '%' || $1 || '%'
LIMIT 1;

-- name: UpdateCompany :one
UPDATE company
SET name = $2, address = $3, contact = $4, image = $5, marker = $6, email = $7,
    location = point($8, $9), "updatedAt" = now()
WHERE id = $1
RETURNING id, name, address, contact, image, marker, email,
          location[0]::float8 AS latitude,
          location[1]::float8 AS longitude,
          "createdAt", "updatedAt", "userId";

-- name: HardDeleteCompany :execrows
-- La entidad Company NO tiene columna deletedAt, por lo que el softDelete
-- original de NestJS no tenia columna que escribir. Se hace borrado real.
DELETE FROM company WHERE id = $1;
