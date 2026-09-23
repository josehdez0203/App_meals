-- Productos. Usado por manager/store y por admin/product.

-- name: ListProductsByCompanyManager :many
SELECT id, name, description, image, type, price, "createdAt", "updatedAt", "companyId"
FROM product
WHERE "companyId" = $1 AND "deletedAt" IS NULL
ORDER BY id DESC;

-- name: GetProductByID :one
SELECT id, name, description, image, type, price, "createdAt", "updatedAt", "companyId"
FROM product
WHERE id = $1 AND "deletedAt" IS NULL;

-- name: CreateProduct :one
INSERT INTO product (name, description, image, type, price, "companyId")
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id, name, description, image, type, price, "createdAt", "updatedAt", "companyId";

-- name: UpdateProduct :one
UPDATE product
SET name = $2, description = $3, image = $4, type = $5, price = $6, "updatedAt" = now()
WHERE id = $1 AND "deletedAt" IS NULL
RETURNING id, name, description, image, type, price, "createdAt", "updatedAt", "companyId";

-- name: SoftDeleteProduct :execrows
UPDATE product
SET "deletedAt" = now()
WHERE id = $1 AND "deletedAt" IS NULL;

-- name: ListProductsByCompanyAdmin :many
SELECT id, name, description, image, type, price, "createdAt", "updatedAt", "companyId"
FROM product
WHERE "companyId" = $1 AND "deletedAt" IS NULL
ORDER BY id
LIMIT $2 OFFSET $3;
