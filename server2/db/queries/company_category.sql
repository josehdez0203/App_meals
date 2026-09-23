-- Relacion empresa-categoria.

-- name: CreateCompanyCategory :one
INSERT INTO company_category ("companyId", "categoryId")
VALUES ($1, $2)
RETURNING id, "updatedAt", "companyId", "categoryId";

-- name: ListCompanyCategoriesByCompany :many
SELECT cc.id, cc."updatedAt", cc."companyId", cc."categoryId",
       cat.id AS category_id, cat.name AS category_name, cat.image AS category_image,
       cat."createdAt" AS category_created_at, cat."updatedAt" AS category_updated_at
FROM company_category cc
INNER JOIN category cat ON cat.id = cc."categoryId"
WHERE cc."companyId" = $1
ORDER BY cc.id
LIMIT $2 OFFSET $3;

-- name: DeleteCompanyCategory :execrows
DELETE FROM company_category
WHERE id = $1 AND "companyId" = $2 AND "categoryId" = $3;
