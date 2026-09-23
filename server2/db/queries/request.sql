-- Peticiones del gerente (manager/request): pedidos entrantes de sus tiendas.

-- name: ListNearRequests :many
SELECT o.id, o.note, o.address, o.status, o.products, o."deliveryFee", o.total,
       o.payment, o."notificationsDeliveryman", o."scoreDeliveryman",
       o."createdAt",
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
WHERE st."userId" = $1 AND o.status < $2
ORDER BY o.id ASC;

-- name: GetRequest :one
SELECT o.id, o.note, o.address, o.status, o.products, o."deliveryFee", o.total,
       o.payment, o."notificationsDeliveryman", o."scoreDeliveryman",
       o."createdAt",
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
WHERE o.id = $1;

-- name: ListRequestHistory :many
SELECT o.id, o.note, o.address, o.status, o.products, o."deliveryFee", o.total,
       o.payment, o."notificationsDeliveryman", o."scoreDeliveryman",
       o."createdAt",
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
WHERE st."userId" = $1 AND o."orderedAt" = $2
ORDER BY o.id DESC;
