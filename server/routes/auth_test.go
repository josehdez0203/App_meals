package routes

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"golang.org/x/crypto/bcrypt"

	"jhc-sistemas.com/app-meals/server/internal/database"
)

type fakeQueries struct {
	created   database.CreateUserParams
	loginUser database.User
}

func (f *fakeQueries) CreateUser(_ context.Context, params database.CreateUserParams) (database.CreateUserRow, error) {
	f.created = params
	now := pgtype.Timestamptz{Time: time.Date(2026, 8, 3, 12, 0, 0, 0, time.UTC), Valid: true}
	return database.CreateUserRow{
		ID: 1, Username: params.Username, Email: params.Email, CreatedAt: now, UpdatedAt: now,
	}, nil
}

func (f *fakeQueries) GetUserByEmail(_ context.Context, _ string) (database.User, error) {
	return f.loginUser, nil
}

func TestRegisterCreatesHashedUserAndReturnsToken(t *testing.T) {
	queries := &fakeQueries{}
	auth := NewAuth(queries, "test-secret")
	auth.now = func() time.Time { return time.Date(2026, 8, 3, 12, 0, 0, 0, time.UTC) }
	mux := http.NewServeMux()
	auth.RegisterRoutes(mux)

	request := httptest.NewRequest(http.MethodPost, "/auth/register", strings.NewReader(
		`{"username":"Jose","email":"JOSE@example.com","password":"secret123"}`,
	))
	response := httptest.NewRecorder()
	mux.ServeHTTP(response, request)

	if response.Code != http.StatusCreated {
		t.Fatalf("se esperaba status %d, se obtuvo %d: %s", http.StatusCreated, response.Code, response.Body.String())
	}
	if queries.created.Email != "jose@example.com" {
		t.Fatalf("se esperaba email normalizado, se obtuvo %q", queries.created.Email)
	}
	if queries.created.PasswordHash == "secret123" {
		t.Fatal("el password fue almacenado sin hash")
	}
	if err := bcrypt.CompareHashAndPassword([]byte(queries.created.PasswordHash), []byte("secret123")); err != nil {
		t.Fatalf("el hash no corresponde al password: %v", err)
	}

	var body authResponse
	if err := json.NewDecoder(response.Body).Decode(&body); err != nil {
		t.Fatalf("respuesta JSON inválida: %v", err)
	}
	if body.User.Email != "jose@example.com" || body.Token == "" {
		t.Fatalf("respuesta de registro inesperada: %+v", body)
	}
	if _, err := jwt.Parse(body.Token, func(_ *jwt.Token) (any, error) { return []byte("test-secret"), nil }); err != nil {
		t.Fatalf("JWT inválido: %v", err)
	}
}

func TestLoginAcceptsValidPassword(t *testing.T) {
	hash, err := bcrypt.GenerateFromPassword([]byte("secret123"), bcrypt.MinCost)
	if err != nil {
		t.Fatal(err)
	}
	now := pgtype.Timestamptz{Time: time.Now(), Valid: true}
	queries := &fakeQueries{loginUser: database.User{
		ID: 1, Username: "Jose", Email: "jose@example.com", PasswordHash: string(hash), CreatedAt: now, UpdatedAt: now,
	}}
	auth := NewAuth(queries, "test-secret")
	mux := http.NewServeMux()
	auth.RegisterRoutes(mux)

	request := httptest.NewRequest(http.MethodPost, "/auth/login", strings.NewReader(
		`{"email":"jose@example.com","password":"secret123"}`,
	))
	response := httptest.NewRecorder()
	mux.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("se esperaba status %d, se obtuvo %d: %s", http.StatusOK, response.Code, response.Body.String())
	}
}
