# Makefile de la API de delivery (server2)
#
# Las credenciales de PostgreSQL se resuelven con esta prioridad:
#   1. variable de entorno   (DB_NAME=otra make migrate-up)
#   2. valor definido en .env
#   3. valor por defecto
#
# GNU Make NO lee .env por si solo, por eso se extraen con `dotenv`.

.DEFAULT_GOAL := help

# Directorio de datos del contenedor: es ilegible para el usuario y rompe el
# patron ./... de Go, asi que las tareas usan rutas de paquete explicitas.
GO_PKGS := ./cmd/... ./internal/...

# dotenv(VARIABLE, por_defecto): entorno > .env > por_defecto
dotenv = $(or $(shell sed -n 's/^$(1)=//p' .env 2>/dev/null | tail -1 | sed "s/[\"']//g"),$(2))

APP         ?= jose
DB_NAME     ?= $(call dotenv,DB_NAME,delivery)
DB_HOST     ?= $(call dotenv,DB_HOST,localhost)
DB_PORT     ?= $(call dotenv,DB_PORT,5432)
DB_USERNAME ?= $(call dotenv,DB_USERNAME,postgres)
DB_PASSWORD ?= $(call dotenv,DB_PASSWORD,123456)
DB_IMAGE    ?= postgis/postgis:14-3.2

# DATABASE_URL se arma con las variables de arriba. Exportala para imponer otra.
DATABASE_URL ?= postgres://$(DB_USERNAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable

.PHONY: help all run dev build test race vet fmt check db-up db-down db-logs \
        migrate-up migrate-down migrate-version migrate-create \
        createdb dropdb server-up server-down sqlc sqlc-vet clean

help: ## Muestra los comandos disponibles
	@echo "Conexion: $(DATABASE_URL)"
	@echo
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z_-]+:.*## / {printf "  make %-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: build test ## Compila y prueba

run: ## Ejecuta la API
	go run ./cmd/api

dev: ## Ejecuta la API con recarga en caliente (air)
	air -c .air.toml

build: ## Compila el binario en bin/api y verifica que todo compile
	@echo "Building..."
	go build -o bin/api ./cmd/api
	go build $(GO_PKGS)

test: ## Ejecuta las pruebas
	@echo "Testing..."
	go test $(GO_PKGS) -v

race: ## Ejecuta las pruebas con el detector de carreras
	go test -race $(GO_PKGS)

vet: ## Busca construcciones sospechosas
	go vet $(GO_PKGS)

fmt: ## Formatea el codigo Go
	gofmt -w ./cmd ./internal

check: fmt vet build test ## Formatea y valida el proyecto

clean: ## Elimina el binario y los artefactos temporales
	@echo "Cleaning..."
	rm -f main bin/api
	rm -rf tmp

# --- PostgreSQL (docker compose) ---

db-up: ## Inicia PostGIS en segundo plano
	docker compose up -d db

db-down: ## Detiene PostGIS
	docker compose down

db-logs: ## Muestra los logs de PostGIS
	docker compose logs -f db

createdb: ## Crea la base indicada por DB_NAME dentro del contenedor
	docker compose exec -T db createdb --username=$(DB_USERNAME) $(DB_NAME)

dropdb: ## Elimina la base indicada por DB_NAME dentro del contenedor
	docker compose exec -T db dropdb --username=$(DB_USERNAME) $(DB_NAME)

server-up: db-up ## Alias de db-up

server-down: db-down ## Alias de db-down

# --- migraciones (golang-migrate) ---

migrate-up: ## Aplica todas las migraciones pendientes
	migrate -path db/migrations -database "$(DATABASE_URL)" -verbose up

migrate-down: ## Revierte la ultima migracion
	migrate -path db/migrations -database "$(DATABASE_URL)" -verbose down 1

migrate-version: ## Muestra la version actual del esquema
	migrate -path db/migrations -database "$(DATABASE_URL)" version

migrate-create: ## Crea una migracion nueva (name=descripcion)
	migrate create -ext sql -dir db/migrations -seq $(name)

# --- sqlc ---

sqlc: ## Regenera el codigo de acceso a datos
	sqlc generate

sqlc-vet: ## Valida las consultas sqlc
	sqlc vet
