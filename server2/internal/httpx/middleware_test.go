package httpx

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestLogRequestsLogsEntryAndExitWithStatus(t *testing.T) {
	t.Setenv("NO_COLOR", "1") // sin ANSI, para aserciones legibles

	var buf bytes.Buffer
	handler := logRequestsTo(&buf)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusTeapot)
	}))
	handler.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodPatch, "/api/client/address/7", nil))

	lines := strings.Split(strings.TrimSpace(buf.String()), "\n")
	if len(lines) != 2 {
		t.Fatalf("se esperaban 2 lineas (entrada y salida), hubo %d:\n%s", len(lines), buf.String())
	}
	if !strings.Contains(lines[0], "-->") ||
		!strings.Contains(lines[0], "PATCH") ||
		!strings.Contains(lines[0], "/api/client/address/7") {
		t.Errorf("linea de entrada = %q", lines[0])
	}
	if !strings.Contains(lines[1], "<--") ||
		!strings.Contains(lines[1], "PATCH") ||
		!strings.Contains(lines[1], "418") {
		t.Errorf("linea de salida = %q", lines[1])
	}
}

// El status de la salida debe ser el que realmente se envio, no el de defecto.
func TestLogRequestsUsesRealStatus(t *testing.T) {
	t.Setenv("NO_COLOR", "1")

	var buf bytes.Buffer
	handler := logRequestsTo(&buf)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		WriteError(w, Unauthorized())
	}))
	handler.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodGet, "/api/x", nil))

	if !strings.Contains(buf.String(), "401") {
		t.Errorf("la salida deberia registrar 401:\n%s", buf.String())
	}
}

func TestLogRequestsLogsExitOnPanic(t *testing.T) {
	t.Setenv("NO_COLOR", "1")

	var buf bytes.Buffer
	handler := logRequestsTo(&buf)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		panic("boom")
	}))

	func() {
		defer func() { _ = recover() }() // el panic lo maneja Recover, mas afuera
		handler.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodGet, "/api/x", nil))
	}()

	if !strings.Contains(buf.String(), "500") {
		t.Errorf("la salida deberia registrar 500:\n%s", buf.String())
	}
}

func TestVerbColorDiffersPerMethod(t *testing.T) {
	seen := map[string]string{}
	for _, m := range []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodPatch, http.MethodDelete} {
		color := verbColor(m)
		if prev, ok := seen[color]; ok {
			t.Errorf("%s comparte color con %s", m, prev)
		}
		seen[color] = m
	}
}

func TestPaintRespectsNoColor(t *testing.T) {
	t.Setenv("NO_COLOR", "1")
	if got := paint(ansiRed, "x"); got != "x" {
		t.Errorf("paint con NO_COLOR = %q, want %q", got, "x")
	}
}

func TestPaintAddsColorByDefault(t *testing.T) {
	t.Setenv("NO_COLOR", "")
	got := paint(ansiRed, "x")
	if !strings.Contains(got, ansiRed) || !strings.Contains(got, ansiReset) {
		t.Errorf("paint = %q, want envuelto en ANSI", got)
	}
}

// El log de acceso no debe incluir el cuerpo de la peticion (contrasenas,
// tokens) ni lineas sueltas: exactamente una de entrada y otra de salida.
func TestLogRequestsDoesNotLeakRequestBody(t *testing.T) {
	t.Setenv("NO_COLOR", "1")

	var buf bytes.Buffer
	handler := logRequestsTo(&buf)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = Decode(r, &struct{}{})
		w.WriteHeader(http.StatusBadRequest)
	}))
	req := httptest.NewRequest(http.MethodPost, "/api/auth/login",
		strings.NewReader(`{"email":"a@b.com","password":"secret123"}`))
	handler.ServeHTTP(httptest.NewRecorder(), req)

	lines := strings.Split(strings.TrimSpace(buf.String()), "\n")
	if len(lines) != 2 {
		t.Fatalf("se esperaban exactamente 2 lineas, hubo %d:\n%s", len(lines), buf.String())
	}
	for _, unwanted := range []string{"a@b.com", "secret123", "0x0"} {
		if strings.Contains(buf.String(), unwanted) {
			t.Errorf("el log contiene %q:\n%s", unwanted, buf.String())
		}
	}
}
