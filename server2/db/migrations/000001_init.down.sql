-- Revierte 000001_init.
-- No se elimina la extension PostGIS: puede haber sido provista por la imagen
-- base o estar en uso por otras aplicaciones de la misma base.

DROP VIEW IF EXISTS vw_product;
DROP VIEW IF EXISTS vw_company;
DROP VIEW IF EXISTS vw_category;

DROP TABLE IF EXISTS chat CASCADE;
DROP TABLE IF EXISTS "order" CASCADE;
DROP TABLE IF EXISTS session CASCADE;
DROP TABLE IF EXISTS credit CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS balance CASCADE;
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS hours_operation CASCADE;
DROP TABLE IF EXISTS store CASCADE;
DROP TABLE IF EXISTS company_category CASCADE;
DROP TABLE IF EXISTS company CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;
