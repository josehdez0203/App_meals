-- Peticiones del repartidor (deliveryman/petition).
-- Reproduce PetitionService: cercania con PostGIS, ciclo de vida del pedido y
-- ajuste del balance del repartidor.

-- name: ListNearPetitions :many
-- Pedidos asignados al repartidor que aun no se entregan, mas los STARTED que
-- estan dentro del radio. Mismo filtro que _sqlFilterOrder.
SELECT o.id, o.note, o.address, o.status, o.products, o."deliveryFee", o.total,
       o.payment, o."notificationsDeliveryman", o."notificationsClient",
       o."deliverymanProfit", o."deliveryAppProfit", o."orderedAt", o."createdAt",
       o.location[0]::float8 AS latitude,
       o.location[1]::float8 AS longitude,
       u.id AS user_id, u."fullName" AS user_full_name, u.phone AS user_phone,
       u.image AS user_image,
       st.id AS store_id, st.name AS store_name, st.address AS store_address,
       st.contact AS store_contact,
       st.location[0]::float8 AS store_latitude,
       st.location[1]::float8 AS store_longitude,
       c.image AS company_image
FROM "order" o
INNER JOIN "user" u ON u.id = o."userId"
INNER JOIN store st ON st.id = o."storeId"
INNER JOIN company c ON c.id = st."companyId"
WHERE (
        o."deliverymanId" = sqlc.arg(deliveryman_id)::int
        AND o.status < sqlc.arg(status_delivered)::smallint
      )
   OR (
        o.status = sqlc.arg(status_started)::smallint
        AND ST_DistanceSphere(
              ST_MakePoint(sqlc.arg(latitude)::float8, sqlc.arg(longitude)::float8),
              o.location::geometry
            ) <= sqlc.arg(km)::float8
      )
ORDER BY o.id ASC;

-- name: GetPetition :one
SELECT o.id, o.note, o.address, o.status, o.products, o."deliveryFee", o.total,
       o.payment, o."notificationsDeliveryman", o."notificationsClient",
       o."deliverymanProfit", o."deliveryAppProfit", o."orderedAt", o."createdAt",
       o.location[0]::float8 AS latitude,
       o.location[1]::float8 AS longitude,
       u.id AS user_id, u."fullName" AS user_full_name, u.phone AS user_phone,
       u.image AS user_image,
       st.id AS store_id, st.name AS store_name, st.address AS store_address,
       st.contact AS store_contact,
       st.location[0]::float8 AS store_latitude,
       st.location[1]::float8 AS store_longitude,
       c.image AS company_image
FROM "order" o
INNER JOIN "user" u ON u.id = o."userId"
INNER JOIN store st ON st.id = o."storeId"
INNER JOIN company c ON c.id = st."companyId"
WHERE o.id = $1 AND o."deliverymanId" = $2;

-- name: ListPetitionHistory :many
SELECT o.id, o.note, o.address, o.status, o.products, o."deliveryFee", o.total,
       o.payment, o."notificationsDeliveryman", o."notificationsClient",
       o."deliverymanProfit", o."deliveryAppProfit", o."orderedAt", o."createdAt",
       o.location[0]::float8 AS latitude,
       o.location[1]::float8 AS longitude,
       u.id AS user_id, u."fullName" AS user_full_name, u.phone AS user_phone,
       u.image AS user_image,
       st.id AS store_id, st.name AS store_name, st.address AS store_address,
       st.contact AS store_contact,
       st.location[0]::float8 AS store_latitude,
       st.location[1]::float8 AS store_longitude,
       c.image AS company_image
FROM "order" o
INNER JOIN "user" u ON u.id = o."userId"
INNER JOIN store st ON st.id = o."storeId"
INNER JOIN company c ON c.id = st."companyId"
WHERE o."deliverymanId" = $1 AND o."orderedAt" = $2
ORDER BY o.id DESC;

-- name: GetOrderForApply :one
SELECT "deliveryFee", payment
FROM "order"
WHERE id = $1;

-- name: ApplyOrder :execrows
UPDATE "order"
SET "deliverymanId" = sqlc.arg(deliveryman_id)::int,
    status = sqlc.arg(new_status)::smallint,
    "deliverymanProfit" = sqlc.arg(deliveryman_profit)::float8,
    "deliveryAppProfit" = sqlc.arg(delivery_app_profit)::float8
WHERE id = sqlc.arg(order_id)::int
  AND status = sqlc.arg(current_status)::smallint
  AND "deliverymanId" IS NULL;

-- name: CollectOrder :execrows
UPDATE "order"
SET status = sqlc.arg(new_status)::smallint
WHERE id = sqlc.arg(order_id)::int
  AND status = sqlc.arg(current_status)::smallint
  AND "deliverymanId" = sqlc.arg(deliveryman_id)::int;

-- name: DeliverOrder :execrows
UPDATE "order"
SET status = sqlc.arg(new_status)::smallint,
    "scoreDeliveryman" = sqlc.arg(score_deliveryman)::float8
WHERE id = sqlc.arg(order_id)::int
  AND status = sqlc.arg(current_status)::smallint
  AND "deliverymanId" = sqlc.arg(deliveryman_id)::int;

-- name: CancelOrder :execrows
UPDATE "order"
SET status = sqlc.arg(new_status)::smallint
WHERE id = sqlc.arg(order_id)::int
  AND status = sqlc.arg(current_status)::smallint
  AND "deliverymanId" = sqlc.arg(deliveryman_id)::int;

-- name: GetOrderForCancel :one
SELECT o.total, o."deliverymanProfit", o."deliveryAppProfit", o.payment, o."userId"
FROM "order" o
WHERE o.id = $1 AND o.status = $2;

-- name: UpdateBalanceValues :execrows
-- El repartidor ajusta balance/amount y el cliente su money (cancelaciones).
UPDATE balance
SET balance = sqlc.arg(balance)::float8,
    amount = sqlc.arg(amount)::float8,
    money = sqlc.arg(money)::float8,
    "updatedAt" = now()
WHERE "userId" = sqlc.arg(user_id)::int;
