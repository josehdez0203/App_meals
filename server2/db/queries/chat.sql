-- Mensajes de chat por pedido.

-- name: ListChatsByOrder :many
-- La consulta original selecciona solo estos campos y ordena por id DESC.
SELECT c.id, c.message, c.type, c.status, c."createdAt", c."fromId"
FROM chat c
WHERE c."orderId" = $1
ORDER BY c.id DESC;

-- name: CreateChat :one
INSERT INTO chat (message, type, status, "fromId", "toId", "orderId")
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id, message, type, status, "createdAt", "fromId", "toId", "orderId";

-- name: IncrementOrderNotificationsDeliveryman :exec
UPDATE "order"
SET "notificationsDeliveryman" = "notificationsDeliveryman" + 1
WHERE id = $1;

-- name: IncrementOrderNotificationsClient :exec
UPDATE "order"
SET "notificationsClient" = "notificationsClient" + 1
WHERE id = $1;

-- name: ResetOrderNotificationsClient :exec
UPDATE "order" SET "notificationsClient" = 0 WHERE id = $1;

-- name: ResetOrderNotificationsDeliveryman :exec
UPDATE "order" SET "notificationsDeliveryman" = 0 WHERE id = $1;
