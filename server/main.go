package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"

	"jhc-sistemas.com/app-meals/server/internal/database"
	authroutes "jhc-sistemas.com/app-meals/server/routes"
)

const (
	defaultAddress     = ":8088"
	defaultDatabaseURL = "postgres://app_meals:app_meals@localhost:5432/delivery?sslmode=disable"
	defaultJWTSecret   = "app-meals-local-development-secret"
)

func main() {
	if err := loadEnv(); err != nil {
		log.Fatalf("no se pudo leer el archivo .env: %v", err)
	}

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		databaseURL = defaultDatabaseURL
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = defaultJWTSecret
		log.Print("ADVERTENCIA: JWT_SECRET no está definido; se usará el secreto de desarrollo local")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		log.Fatalf("no se pudo configurar PostgreSQL: %v", err)
	}
	defer pool.Close()
	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("no se pudo conectar con PostgreSQL: %v", err)
	}

	address := os.Getenv("SERVER_ADDRESS")
	if address == "" {
		address = defaultAddress
	}
	auth := authroutes.NewAuth(database.New(pool), jwtSecret)
	server := &http.Server{
		Addr:              address,
		Handler:           authroutes.NewRouter(auth),
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Printf("Servidor escuchando en http://localhost%s", address)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}
}

func loadEnv() error {
	for _, path := range []string{".env", "../.env"} {
		if _, err := os.Stat(path); err == nil {
			return godotenv.Load(path)
		} else if !os.IsNotExist(err) {
			return err
		}
	}
	return nil
}
