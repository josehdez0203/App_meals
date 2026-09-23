package httpx

import (
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgconn"
)

func TestWriteErrorRendersCodeError(t *testing.T) {
	rec := httptest.NewRecorder()
	WriteError(rec, BadRequest(CodeEmailUsed))

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", rec.Code)
	}
	if got := strings.TrimSpace(rec.Body.String()); got != `{"codeError":101}` {
		t.Fatalf("body = %s", got)
	}
}

func TestWriteErrorRendersCodeErrorWithMessage(t *testing.T) {
	rec := httptest.NewRecorder()
	WriteError(rec, BadRequestMsg(CodeNoBalance, "sin saldo"))

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", rec.Code)
	}
	body := rec.Body.String()
	if !strings.Contains(body, `"codeError":501`) || !strings.Contains(body, `"message":"sin saldo"`) {
		t.Fatalf("body = %s", body)
	}
}

func TestWriteErrorMapsUniqueViolation(t *testing.T) {
	rec := httptest.NewRecorder()
	WriteError(rec, &pgconn.PgError{Code: "23505", Detail: "llave duplicada"})

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), "llave duplicada") {
		t.Fatalf("body = %s", rec.Body.String())
	}
}

func TestWriteErrorMapsNotNullViolation(t *testing.T) {
	rec := httptest.NewRecorder()
	WriteError(rec, &pgconn.PgError{Code: "23502"})

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), "Relationships between entities, invalid") {
		t.Fatalf("body = %s", rec.Body.String())
	}
}

func TestWriteErrorFallsBackToInternalError(t *testing.T) {
	rec := httptest.NewRecorder()
	WriteError(rec, errors.New("boom"))

	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("status = %d, want 500", rec.Code)
	}
}

func TestValidationErrorShape(t *testing.T) {
	rec := httptest.NewRecorder()
	ValidationError(rec, []string{"campo invalido"})

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", rec.Code)
	}
	body := rec.Body.String()
	if !strings.Contains(body, `"statusCode":400`) || !strings.Contains(body, "campo invalido") {
		t.Fatalf("body = %s", body)
	}
}

func TestOKWritesJSONContentType(t *testing.T) {
	rec := httptest.NewRecorder()
	OK(rec, map[string]any{"recover": true})

	if got := rec.Header().Get("Content-Type"); !strings.HasPrefix(got, "application/json") {
		t.Fatalf("content-type = %q", got)
	}
	if !strings.Contains(rec.Body.String(), `"recover":true`) {
		t.Fatalf("body = %s", rec.Body.String())
	}
}
