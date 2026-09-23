package api

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"appmeals/api/internal/auth"
	"appmeals/api/internal/config"
	"appmeals/api/internal/store"
)

// newTestHandler construye el router con un pool que nunca conecta: las rutas
// bajo prueba responden antes de tocar la base (autenticacion, validacion o 404).
func newTestHandler(t *testing.T) http.Handler {
	t.Helper()
	pool, err := pgxpool.New(context.Background(), "postgres://u:p@127.0.0.1:1/none?sslmode=disable")
	if err != nil {
		t.Fatalf("crear pool: %v", err)
	}
	t.Cleanup(pool.Close)

	cfg := &config.Config{Address: ":0", JWTSecret: "test-secret"}
	return New(cfg, store.New(pool), pool, auth.NewManager("test-secret")).Router()
}

func request(t *testing.T, h http.Handler, method, path, body string, headers map[string]string) *httptest.ResponseRecorder {
	t.Helper()
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	if body != "" {
		req.Header.Set("Content-Type", "application/json")
	}
	for key, value := range headers {
		req.Header.Set(key, value)
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func TestProtectedRouteWithoutToken(t *testing.T) {
	handler := newTestHandler(t)
	rec := request(t, handler, http.MethodPatch, "/api/auth/update", "", nil)

	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want 401", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), `"codeError":401`) {
		t.Fatalf("body = %s", rec.Body.String())
	}
}

func TestProtectedRouteWithInvalidToken(t *testing.T) {
	handler := newTestHandler(t)
	rec := request(t, handler, http.MethodGet, "/api/client/market/orders", "",
		map[string]string{"Authorization": "Bearer no-es-un-jwt"})

	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want 401", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), "Token not valid") {
		t.Fatalf("body = %s", rec.Body.String())
	}
}

func TestRegisterRejectsShortPassword(t *testing.T) {
	handler := newTestHandler(t)
	rec := request(t, handler, http.MethodPost, "/api/auth/register",
		`{"fullName":"Test User","email":"a@b.com","password":"abc","idDevice":"0a509966-493d-4f2a-b2fa-3636aa0bb605"}`, nil)

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), "password") {
		t.Fatalf("body = %s", rec.Body.String())
	}
}

func TestRegisterRejectsUnknownField(t *testing.T) {
	handler := newTestHandler(t)
	rec := request(t, handler, http.MethodPost, "/api/auth/register",
		`{"fullName":"Test User","email":"a@b.com","password":"secret123","idDevice":"0a509966-493d-4f2a-b2fa-3636aa0bb605","extra":1}`, nil)

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400 (forbidNonWhitelisted)", rec.Code)
	}
}

func TestLoginRejectsInvalidDevice(t *testing.T) {
	handler := newTestHandler(t)
	rec := request(t, handler, http.MethodPost, "/api/auth/login",
		`{"email":"a@b.com","password":"secret123","idDevice":"nope"}`, nil)

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), "idDevice must be a UUID") {
		t.Fatalf("body = %s", rec.Body.String())
	}
}

func TestUnknownRouteReturns404(t *testing.T) {
	handler := newTestHandler(t)
	rec := request(t, handler, http.MethodGet, "/api/no-existe", "", nil)

	if rec.Code != http.StatusNotFound {
		t.Fatalf("status = %d, want 404", rec.Code)
	}
}

func TestHealthReportsDatabaseDown(t *testing.T) {
	handler := newTestHandler(t)
	rec := request(t, handler, http.MethodGet, "/health", "", nil)

	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("status = %d, want 503", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), `"database":"down"`) {
		t.Fatalf("body = %s", rec.Body.String())
	}
}

// Regresion: el cliente Flutter llama a estas dos rutas con barra final y el
// ServeMux de Go respondia 404. Deben llegar al middleware de autenticacion
// (401 sin token), no al 404 del router.
func TestTrailingSlashRoutesResolve(t *testing.T) {
	handler := newTestHandler(t)
	cases := []struct {
		method, path string
	}{
		{http.MethodGet, "/api/deliveryman/petition/near/?idDevice=0a509966-493d-4f2a-b2fa-3636aa0bb605"},
		{http.MethodPatch, "/api/deliveryman/petition/activate/"},
	}
	for _, tc := range cases {
		rec := request(t, handler, tc.method, tc.path, "", nil)
		if rec.Code == http.StatusNotFound {
			t.Errorf("%s %s -> 404: la barra final no se normaliza", tc.method, tc.path)
			continue
		}
		if rec.Code != http.StatusUnauthorized {
			t.Errorf("%s %s -> %d, want 401", tc.method, tc.path, rec.Code)
		}
	}
}

// El healthcheck tambien responde bajo el prefijo global /api (regresion: solo
// estaba montado en /health y /api/health devolvia 404).
func TestHealthAliasUnderAPIPrefix(t *testing.T) {
	handler := newTestHandler(t)
	rec := request(t, handler, http.MethodGet, "/api/health", "", nil)

	if rec.Code == http.StatusNotFound {
		t.Fatalf("status = 404: la ruta /api/health no esta registrada")
	}
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("status = %d, want 503 (sin base de datos)", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), `"database":"down"`) {
		t.Fatalf("body = %s", rec.Body.String())
	}
}

func TestParseClock(t *testing.T) {
	cases := []struct {
		in    string
		valid bool
		micro int64
	}{
		{"08:00:00", true, 8 * 3_600_000_000},
		{"22:30", true, 22*3_600_000_000 + 30*60_000_000},
		{"00:00:15", true, 15 * 1_000_000},
		{"abc", false, 0},
	}
	for _, tc := range cases {
		got, ok := parseClock(tc.in)
		if ok != tc.valid {
			t.Errorf("parseClock(%q) valid = %v, want %v", tc.in, ok, tc.valid)
			continue
		}
		if ok && got.Microseconds != tc.micro {
			t.Errorf("parseClock(%q) = %d, want %d", tc.in, got.Microseconds, tc.micro)
		}
	}
}

func TestParseDate(t *testing.T) {
	if _, ok := parseDate("2026-09-19"); !ok {
		t.Error("parseDate fecha simple deberia ser valida")
	}
	if _, ok := parseDate("2026-09-19T10:00:00Z"); !ok {
		t.Error("parseDate RFC3339 deberia ser valida")
	}
	if _, ok := parseDate("nope"); ok {
		t.Error("parseDate texto invalido no deberia pasar")
	}
}

func TestSplitInt32(t *testing.T) {
	got, err := splitInt32("1, 2,3")
	if err != nil {
		t.Fatalf("error inesperado: %v", err)
	}
	if len(got) != 3 || got[0] != 1 || got[1] != 2 || got[2] != 3 {
		t.Fatalf("splitInt32 = %v", got)
	}
	if _, err := splitInt32("1,x"); err == nil {
		t.Fatal("splitInt32 deberia fallar con valores no numericos")
	}
}

func TestValidateLocation(t *testing.T) {
	if msg := validateLocation(locationJSON{X: 19.99, Y: -102.72}); msg != "" {
		t.Fatalf("ubicacion valida devolvio %q", msg)
	}
	if msg := validateLocation(locationJSON{X: 120, Y: 0}); msg == "" {
		t.Fatal("latitud fuera de rango deberia fallar")
	}
	if msg := validateLocation(locationJSON{X: 0, Y: 200}); msg == "" {
		t.Fatal("longitud fuera de rango deberia fallar")
	}
}

func TestHasRole(t *testing.T) {
	roles := []string{"client", "manager"}
	if !hasRole(roles, "manager") {
		t.Error("hasRole deberia encontrar manager")
	}
	if hasRole(roles, "admin") {
		t.Error("hasRole no deberia encontrar admin")
	}
}

func TestBoolAndIntHelpers(t *testing.T) {
	yes := true
	no := false
	if !boolValue(&yes) || boolValue(&no) || boolValue(nil) {
		t.Error("boolValue incorrecto")
	}
	value := int32(7)
	if int32Value(&value) != 7 || int32Value(nil) != 0 {
		t.Error("int32Value incorrecto")
	}
	text := "x"
	if stringValue(nil) != "" || stringValue(&text) != "x" {
		t.Error("stringValue incorrecto")
	}
	if floatValue(nil) != 0 {
		t.Error("floatValue(nil) deberia ser 0")
	}
}

func TestClockJSONFormat(t *testing.T) {
	got := clockJSON(pgtype.Time{Microseconds: 8*3_600_000_000 + 5*60_000_000, Valid: true})
	if got != "08:05:00" {
		t.Fatalf("clockJSON = %v", got)
	}
	if clockJSON(pgtype.Time{}) != nil {
		t.Fatal("clockJSON invalido deberia ser nil")
	}
}
