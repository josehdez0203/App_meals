-- Saldos. La tabla balance tiene como clave primaria userId.

-- name: GetBalanceByUser :one
SELECT "userId", balance, profit, amount, money, "createdAt", "updatedAt"
FROM balance
WHERE "userId" = $1;

-- name: UpsertBalance :exec
INSERT INTO balance ("userId") VALUES ($1)
ON CONFLICT ("userId") DO NOTHING;

-- name: UpdateBalanceMoney :execrows
UPDATE balance
SET money = $2, "updatedAt" = now()
WHERE "userId" = $1;
