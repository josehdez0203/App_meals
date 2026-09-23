-- Categorias.

-- name: ListCategories :many
SELECT id, name, image, "createdAt", "updatedAt"
FROM category
ORDER BY name ASC;

-- name: GetCategoryByID :one
SELECT id, name, image, "createdAt", "updatedAt"
FROM category
WHERE id = $1;

-- name: AddUserRole :execrows
-- Agrega el rol solo si no lo tiene (equivalente al update de EnrollmentService).
UPDATE "user"
SET roles = array_append(roles, $2), "updatedAt" = now()
WHERE id = $1 AND NOT ($2 = ANY(roles));

-- name: ListCategoriesPaged :many
SELECT id, name, image, "createdAt", "updatedAt"
FROM category
ORDER BY id
LIMIT $1 OFFSET $2;

-- name: CreateCategory :one
INSERT INTO category (name, image)
VALUES ($1, $2)
RETURNING id, name, image, "createdAt", "updatedAt";

-- name: UpdateCategory :one
UPDATE category
SET name = $2, image = $3, "updatedAt" = now()
WHERE id = $1
RETURNING id, name, image, "createdAt", "updatedAt";
