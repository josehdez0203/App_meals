// Command api arranca la API REST de delivery.
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"appmeals/api/internal/api"
	"appmeals/api/internal/auth"
	"appmeals/api/internal/config"
	"appmeals/api/internal/database"
	"appmeals/api/internal/store"
)

func main() {
	slog.SetDefault(slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo})))

	cfg := config.Load()
	// Nunca registrar los VALORES de configuracion: contienen secretos (clave
	// privada de Firebase, STRIPE_SECRET_KEY, clientSecret de OAuth, JWT). Solo
	// se reporta si estan presentes.
	slog.Info("configuracion cargada",
		"address", cfg.Address,
		"firebase", cfg.FirebaseCredentialsJSON != "",
		"stripe", cfg.StripeSecretKey != "",
		"google", cfg.GoogleAPIKey != "",
		"mailer", cfg.AccountTransport != "",
	)
	slog.Info(cfg.JWTSecret, "escuchando en", cfg.Address)
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	pool, err := database.Connect(ctx, cfg.DatabaseURL)
	if err != nil {
		slog.Error("no se pudo conectar a la base de datos", "error", err)
		os.Exit(1)
	}
	defer pool.Close()

	app := api.New(cfg, store.New(pool), pool, auth.NewManager(cfg.JWTSecret))

	srv := &http.Server{
		Addr:              cfg.Address,
		Handler:           app.Router(),
		ReadHeaderTimeout: 10 * time.Second,
	}

	go func() {
		slog.Info("api escuchando", "address", cfg.Address)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			slog.Error("servidor detenido", "error", err)
			stop()
		}
	}()

	<-ctx.Done()
	slog.Info("apagando servidor")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		slog.Error("error al apagar", "error", err)
	}
}
