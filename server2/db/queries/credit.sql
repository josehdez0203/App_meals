-- Creditos: recarga de saldo que hace un admin al repartidor.

-- name: GetUserByPhone :one
SELECT id, "idGoogle", "fullName", email, phone, image, "isActive", roles,
       "createdAt", "updatedAt"
FROM "user"
WHERE phone = $1;

-- name: CreateCredit :one
INSERT INTO credit (amount, "deliverymanId")
VALUES ($1, $2)
RETURNING id, amount, "createdAt", "deliverymanId";

-- name: AddBalanceAmount :exec
-- Suma al balance del repartidor, creando el registro si no existe.
INSERT INTO balance ("userId", balance)
VALUES ($1, $2)
ON CONFLICT ("userId") DO UPDATE
SET balance = balance.balance + EXCLUDED.balance, "updatedAt" = now();
