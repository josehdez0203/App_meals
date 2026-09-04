.PHONY: help install-air dev run build test fmt clean db-up db-down db-logs migrate-up migrate-down migrate-create sqlc-generate

BINARY := tmp/server
DATABASE_URL ?= postgres://app_meals:app_meals@localhost:5432/delivery?sslmode=disable
MIGRATIONS := migrations

help: ## Muestra los comandos disponibles
	@awk 'BEGIN {FS = ":.*## "; printf "Comandos disponibles:\n"} /^[a-zA-Z_-]+:.*?## / {printf "  %-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install-air: ## Instala Air para habilitar hot reload
	go install github.com/air-verse/air@latest

sqlc-generate: ## Genera el codigo Go para las consultas PostgreSQL
	@command -v sqlc >/dev/null 2>&1 || { echo "sqlc no esta instalado globalmente"; exit 1; }
	sqlc generate

db-up: ## Inicia PostgreSQL y espera hasta que este saludable
	docker compose up -d --wait postgres

db-down: ## Detiene PostgreSQL sin eliminar sus datos
	docker compose down

db-logs: ## Muestra los logs de PostgreSQL
	docker compose logs -f postgres

migrate-up: ## Aplica todas las migraciones pendientes
	migrate -path $(MIGRATIONS) -database "$(DATABASE_URL)" up

migrate-down: ## Revierte la ultima migracion
	migrate -path $(MIGRATIONS) -database "$(DATABASE_URL)" down 1

migrate-create: ## Crea una migracion: make migrate-create name=nombre
	@test -n "$(name)" || { echo "Falta name. Ejemplo: make migrate-create name=create_orders"; exit 1; }
	migrate create -ext sql -dir $(MIGRATIONS) -seq $(name)

dev: ## Ejecuta la API con hot reload usando Air
	@command -v air >/dev/null 2>&1 || { echo "Air no esta instalado. Ejecuta: make install-air"; exit 1; }
	air -c .air.toml

run: ## Ejecuta la API sin hot reload
	go run .

build: ## Compila la API en tmp/server
	@mkdir -p tmp
	go build -o $(BINARY) .

test: ## Ejecuta las pruebas
	go test ./...

fmt: ## Formatea el codigo Go
	gofmt -w $$(find . -type f -name '*.go' -not -path './tmp/*')

clean: ## Elimina los artefactos de compilacion
	go clean
	rm -f $(BINARY)
