-- Horarios de atencion por tienda.

-- name: CreateHoursOperation :one
INSERT INTO hours_operation (day, "storeId")
VALUES ($1, $2)
RETURNING id, day, open, close, "timeZone", "storeId";

-- name: ListHoursByStore :many
SELECT id, day, open, close, "timeZone", "storeId"
FROM hours_operation
WHERE "storeId" = $1
ORDER BY day ASC;

-- name: GetHoursOperationByID :one
SELECT id, day, open, close, "timeZone", "storeId"
FROM hours_operation
WHERE id = $1;

-- name: UpdateHoursOperation :one
UPDATE hours_operation
SET open = $2, close = $3
WHERE id = $1
RETURNING id, day, open, close, "timeZone", "storeId";

-- name: CreateHoursOperationFull :one
INSERT INTO hours_operation (day, open, close, "storeId")
VALUES ($1, $2, $3, $4)
RETURNING id, day, open, close, "timeZone", "storeId";
