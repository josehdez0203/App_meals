package routes

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"net/mail"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"golang.org/x/crypto/bcrypt"

	"jhc-sistemas.com/app-meals/server/internal/database"
)

const maxRequestBody = 1 << 20

type Auth struct {
	queries   database.Querier
	jwtSecret []byte
	now       func() time.Time
}

type credentials struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type registerRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type userResponse struct {
	ID        int64     `json:"id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type authResponse struct {
	Token string       `json:"token"`
	User  userResponse `json:"user"`
}

func homeHandler(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if err := json.NewEncoder(w).Encode(map[string]string{
		"message": "soy el servidor",
	}); err != nil {
		log.Printf("error al codificar la respuesta de home: %v", err)
	}
}

func NewAuth(queries database.Querier, jwtSecret string) *Auth {
	return &Auth{queries: queries, jwtSecret: []byte(jwtSecret), now: time.Now}
}

func NewRouter(auth *Auth) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /home", homeHandler)
	if auth != nil {
		auth.RegisterRoutes(mux)
	}
	return mux
}

func (a *Auth) RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("POST /auth/register", a.register)
	mux.HandleFunc("POST /auth/login", a.login)
}

func (a *Auth) register(w http.ResponseWriter, r *http.Request) {
	var request registerRequest
	if err := decodeJSON(w, r, &request); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	request.Username = strings.TrimSpace(request.Username)
	request.Email = strings.ToLower(strings.TrimSpace(request.Email))
	if err := validateRegistration(request); err != nil {
		writeError(w, http.StatusUnprocessableEntity, err.Error())
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(request.Password), bcrypt.DefaultCost)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "no se pudo registrar el usuario")
		return
	}

	user, err := a.queries.CreateUser(r.Context(), database.CreateUserParams{
		Username:     request.Username,
		Email:        request.Email,
		PasswordHash: string(hash),
	})
	if err != nil {
		var postgresError *pgconn.PgError
		if errors.As(err, &postgresError) && postgresError.Code == "23505" {
			writeError(w, http.StatusConflict, "el email ya está registrado")
			return
		}
		writeError(w, http.StatusInternalServerError, "no se pudo registrar el usuario")
		return
	}

	responseUser := userResponse{
		ID: user.ID, Username: user.Username, Email: user.Email,
		CreatedAt: user.CreatedAt.Time, UpdatedAt: user.UpdatedAt.Time,
	}
	token, err := a.createToken(responseUser)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "no se pudo crear la sesión")
		return
	}

	writeJSON(w, http.StatusCreated, authResponse{Token: token, User: responseUser})
}

func (a *Auth) login(w http.ResponseWriter, r *http.Request) {
	var request credentials
	if err := decodeJSON(w, r, &request); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	request.Email = strings.ToLower(strings.TrimSpace(request.Email))
	if request.Email == "" || request.Password == "" {
		writeError(w, http.StatusUnprocessableEntity, "email y password son obligatorios")
		return
	}

	user, err := a.queries.GetUserByEmail(r.Context(), request.Email)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			writeError(w, http.StatusUnauthorized, "credenciales incorrectas")
			return
		}
		writeError(w, http.StatusInternalServerError, "no se pudo iniciar sesión")
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(request.Password)); err != nil {
		writeError(w, http.StatusUnauthorized, "credenciales incorrectas")
		return
	}

	responseUser := userResponse{
		ID: user.ID, Username: user.Username, Email: user.Email,
		CreatedAt: user.CreatedAt.Time, UpdatedAt: user.UpdatedAt.Time,
	}
	token, err := a.createToken(responseUser)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "no se pudo crear la sesión")
		return
	}

	writeJSON(w, http.StatusOK, authResponse{Token: token, User: responseUser})
}

func validateRegistration(request registerRequest) error {
	if request.Username == "" || request.Email == "" || request.Password == "" {
		return errors.New("username, email y password son obligatorios")
	}
	address, err := mail.ParseAddress(request.Email)
	if err != nil || address.Address != request.Email {
		return errors.New("el email no es válido")
	}
	if len(request.Password) < 6 {
		return errors.New("el password debe tener al menos 6 caracteres")
	}
	return nil
}

func (a *Auth) createToken(user userResponse) (string, error) {
	now := a.now()
	claims := jwt.RegisteredClaims{
		Subject:   user.Email,
		Issuer:    "app-meals",
		IssuedAt:  jwt.NewNumericDate(now),
		ExpiresAt: jwt.NewNumericDate(now.Add(24 * time.Hour)),
	}
	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(a.jwtSecret)
}

func decodeJSON(w http.ResponseWriter, r *http.Request, target any) error {
	r.Body = http.MaxBytesReader(w, r.Body, maxRequestBody)
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(target); err != nil {
		return errors.New("el cuerpo debe ser un JSON válido")
	}
	if err := decoder.Decode(&struct{}{}); !errors.Is(err, io.EOF) {
		return errors.New("el cuerpo debe contener un solo objeto JSON")
	}
	return nil
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"error": message})
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(value)
}
