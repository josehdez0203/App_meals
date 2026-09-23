-- Consultas del mercado (client/market). Las columnas point se exponen como
-- latitud/longitud y la API arma {"x": lat, "y": lng}, igual que hacia
-- node-postgres en la version NestJS.
--
-- El filtro de cercania replica FilterKM.STORES_NEARBY = 80000000 (en la
-- practica, sin limite: todas las tiendas). Se usa ST_MakePoint en lugar de
-- ST_GeomFromText para que los parametros sean float8 tipados.

-- name: ListCompaniesNearby :many
SELECT DISTINCT ON (st.id)
    st.id, st."storeId", st.name, st.address, st.contact, st.image,
    st."categoryId", st.open, st.close, st.day, st."isOpen",
    st.location[0]::float8 AS latitude,
    st.location[1]::float8 AS longitude
FROM vw_company st
WHERE ST_DistanceSphere(
        ST_MakePoint(sqlc.arg(latitude)::float8, sqlc.arg(longitude)::float8),
        st.location::geometry
      ) <= sqlc.arg(km)::float8
  AND (sqlc.arg(categoryId)::int <= 0 OR st."categoryId" = sqlc.arg(categoryId)::int)
ORDER BY st.id
LIMIT sqlc.arg(limit_count)::int OFFSET sqlc.arg(offset_count)::int;

-- name: ListCategoriesNearby :many
SELECT ct.id, ct.name, ct.image,
       ct.location[0]::float8 AS latitude,
       ct.location[1]::float8 AS longitude
FROM vw_category ct
WHERE ST_DistanceSphere(
        ST_MakePoint(sqlc.arg(latitude)::float8, sqlc.arg(longitude)::float8),
        ct.location::geometry
      ) <= sqlc.arg(km)::float8
ORDER BY ct.id
LIMIT sqlc.arg(limit_count)::int OFFSET sqlc.arg(offset_count)::int;

-- name: ListProductsByCompany :many
SELECT id, "companyId", "companyName", name, image, description, type, price
FROM vw_product
WHERE "companyId" = $1
ORDER BY id
LIMIT $2 OFFSET $3;

-- name: ListProductsByCompanyIDs :many
SELECT id, "companyId", "companyName", name, image, description, type, price
FROM vw_product
WHERE "companyId" = ANY(sqlc.arg(company_ids)::int[])
ORDER BY "companyId";

-- name: ListNearbyStoreIDs :many
-- Tiendas abiertas y cercanas de una lista de companias (paso previo al costo
-- de envio). Reproduce MarketService.deliveryCost.
SELECT DISTINCT st."storeId"
FROM vw_company st
WHERE ST_DistanceSphere(
        ST_MakePoint(sqlc.arg(latitude)::float8, sqlc.arg(longitude)::float8),
        st.location::geometry
      ) <= sqlc.arg(km)::float8
  AND st.id = ANY(sqlc.arg(company_ids)::int[])
  AND st."isOpen" = true;

-- name: ListDeliveryFees :many
-- El alias va sin comillas a proposito: PostgreSQL lo devuelve en minusculas
-- ("deliveryfee"), que es la clave que espera el cliente.
SELECT s.name,
       s."companyId",
       c.image,
       c.marker,
       s.id AS store_id,
       (s."startupCost" + (
           (ST_DistanceSphere(
               ST_MakePoint(sqlc.arg(latitude)::float8, sqlc.arg(longitude)::float8),
               s.location::geometry
           ) / 1000) * s."costKm"
       ))::float8 AS deliveryfee
FROM store s
INNER JOIN company c ON c.id = s."companyId"
WHERE s.id = ANY(sqlc.arg(store_ids)::int[]);

-- name: ListOrdersByUser :many
-- Pedidos del cliente: status <= DELIVERED o CANCELLED, con las relaciones que
-- proyecta la consulta original de MarketService.findOrders.
SELECT o.id, o.note, o.address, o.status, o.products, o."deliveryFee", o.total,
       o.payment, o."scoreClient", o."scoreDeliveryman",
       o."notificationsClient", o."notificationsDeliveryman",
       o."orderedAt", o."createdAt",
       o.location[0]::float8 AS latitude,
       o.location[1]::float8 AS longitude,
       st.id AS store_id, st.name AS store_name, st.address AS store_address,
       st.location[0]::float8 AS store_latitude,
       st.location[1]::float8 AS store_longitude,
       c.image AS company_image, c.marker AS company_marker,
       u.id AS deliveryman_id, u."fullName" AS deliveryman_full_name, u.image AS deliveryman_image
FROM "order" o
INNER JOIN store st ON st.id = o."storeId"
INNER JOIN company c ON c.id = st."companyId"
LEFT JOIN "user" u ON u.id = o."deliverymanId"
WHERE o."userId" = sqlc.arg(user_id)::int
  AND (o.status <= sqlc.arg(status_delivered)::smallint OR o.status = sqlc.arg(status_cancelled)::smallint)
ORDER BY o.id DESC;

-- name: GetOrderByUser :one
SELECT o.id, o.note, o.address, o.status, o.products, o."deliveryFee", o.total,
       o.payment, o."scoreClient", o."scoreDeliveryman",
       o."notificationsClient", o."notificationsDeliveryman",
       o."orderedAt", o."createdAt",
       o.location[0]::float8 AS latitude,
       o.location[1]::float8 AS longitude,
       st.id AS store_id, st.name AS store_name, st.address AS store_address,
       st.location[0]::float8 AS store_latitude,
       st.location[1]::float8 AS store_longitude,
       c.image AS company_image, c.marker AS company_marker,
       u.id AS deliveryman_id, u."fullName" AS deliveryman_full_name, u.image AS deliveryman_image
FROM "order" o
INNER JOIN store st ON st.id = o."storeId"
INNER JOIN company c ON c.id = st."companyId"
LEFT JOIN "user" u ON u.id = o."deliverymanId"
WHERE o.id = $1 AND o."userId" = $2;

-- name: CreateOrder :one
INSERT INTO "order" (
    note, address, status, products, "deliveryFee", total, payment,
    location, "orderedAt", "storeId", "userId"
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, point($8, $9), $10, $11, $12
)
RETURNING id, note, address, status, products, "deliveryFee", total, payment,
          "scoreClient", "scoreDeliveryman", "notificationsClient",
          "notificationsDeliveryman", "orderedAt", "createdAt",
          location[0]::float8 AS latitude, location[1]::float8 AS longitude,
          "storeId", "userId", "deliverymanId";

-- name: QualifyOrder :execrows
UPDATE "order"
SET status = sqlc.arg(status_qualified)::smallint, "scoreClient" = sqlc.arg(score_client)::float8
WHERE id = sqlc.arg(order_id)::int AND "userId" = sqlc.arg(user_id)::int;

-- name: GetStoreOwnerIDByOrder :one
-- Dueno de la tienda del pedido: destino de la notificacion al comercio.
SELECT st."userId" AS owner_id
FROM "order" o
INNER JOIN store st ON st.id = o."storeId"
WHERE o.id = $1;
