-- Consultas sobre "user". El password y passwordTemporary nunca se devuelven
-- al cliente: solo se seleccionan en las consultas de autenticacion.

-- name: CreateUser :one
INSERT INTO "user" ("idGoogle", "fullName", email, phone, password, image, roles)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING id, "idGoogle", "fullName", email, phone, image, "isActive", roles, "createdAt", "updatedAt";

-- name: GetUserByID :one
SELECT id, "idGoogle", "fullName", email, phone, image, "isActive", roles, "createdAt", "updatedAt"
FROM "user"
WHERE id = $1;

-- name: GetUserAuthByEmail :one
SELECT id, email, password, "passwordTemporary", "fullName", phone, image, "isActive", roles
FROM "user"
WHERE email = $1;

-- name: GetUserByEmailOrPhone :one
SELECT id, email, phone
FROM "user"
WHERE email = $1 OR phone = $2
LIMIT 1;

-- name: GetUserByEmailOrPhoneExcludingID :one
SELECT id, email, phone
FROM "user"
WHERE (email = $1 OR phone = $2) AND id <> $3
LIMIT 1;

-- name: UpdateUserGoogleID :execrows
UPDATE "user"
SET "idGoogle" = $2, "updatedAt" = now()
WHERE email = $1;

-- name: UpdateUserProfile :one
UPDATE "user"
SET "fullName" = $2, email = $3, phone = $4, image = $5, "updatedAt" = now()
WHERE id = $1
RETURNING id, "idGoogle", "fullName", email, phone, image, "isActive", roles, "createdAt", "updatedAt";

-- name: UpdateUserPassword :one
UPDATE "user"
SET password = $2, "updatedAt" = now()
WHERE id = $1
RETURNING id, "idGoogle", "fullName", email, phone, image, "isActive", roles, "createdAt", "updatedAt";

-- name: SetTemporaryPassword :execrows
UPDATE "user"
SET "passwordTemporary" = $2, "updatedAt" = now()
WHERE email = $1;

-- name: GetUserNameByEmail :one
SELECT id, "fullName"
FROM "user"
WHERE email = $1;
