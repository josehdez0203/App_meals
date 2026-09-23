-- Pagos con tarjeta. El campo response guarda la respuesta cruda de la pasarela
-- (Stripe), igual que la version NestJS.

-- name: CreatePayment :one
INSERT INTO payment (money, status, currency, products, response, "userId")
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id, money, status, currency, products, response, "createdAt", "updatedAt", "userId";

-- name: GetPaymentByIDAndUser :one
SELECT id, money, status, currency, products, response, "createdAt", "updatedAt", "userId"
FROM payment
WHERE id = $1 AND "userId" = $2;

-- name: UpdatePaymentStatus :execrows
UPDATE payment
SET status = sqlc.arg(new_status)::smallint, "updatedAt" = now()
WHERE id = sqlc.arg(payment_id)::int AND status = sqlc.arg(current_status)::smallint;

-- name: AddBalanceMoney :exec
-- Suma dinero al saldo del cliente, creando el registro si no existe.
INSERT INTO balance ("userId", money)
VALUES ($1, $2)
ON CONFLICT ("userId") DO UPDATE
SET money = balance.money + EXCLUDED.money, "updatedAt" = now();
