// Package httpx agrupa los helpers HTTP: respuestas JSON, errores y router.
package httpx

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"

	"github.com/jackc/pgx/v5/pgconn"
)

// ErrorCode reproduce el enum ErrorCode de la version NestJS
// (server/src/common/glob/error.ts): el cliente Flutter lo lee en `codeError`.
type ErrorCode int

const (
	CodeNone      ErrorCode = 0
	CodeUnknown   ErrorCode = 100
	CodeEmailUsed ErrorCode = 101
	CodePhoneUsed ErrorCode = 102
	CodeNameUsed  ErrorCode = 103

	CodeNoBalance           ErrorCode = 501
	CodeInsufficientBalance ErrorCode = 502
	CodeOrderFulfilled      ErrorCode = 503

	CodeUnauthorized               ErrorCode = 401
	CodeAccountNotExist            ErrorCode = 402
	CodeFailedPayment              ErrorCode = 3003
	CodeDeliverymanNotFound        ErrorCode = 4001
	CodeDeliverymanCannotBeManager ErrorCode = 4002
)

// AppError es un error de negocio con codigo y status HTTP.
type AppError struct {
	Status  int
	Code    ErrorCode
	Message string
}

func (e *AppError) Error() string {
	if e.Message != "" {
		return e.Message
	}
	return http.StatusText(e.Status)
}

// New crea un AppError con status explicito.
func New(status int, code ErrorCode, message string) *AppError {
	return &AppError{Status: status, Code: code, Message: message}
}

func BadRequest(code ErrorCode) *AppError {
	return &AppError{Status: http.StatusBadRequest, Code: code}
}

func BadRequestMsg(code ErrorCode, message string) *AppError {
	return &AppError{Status: http.StatusBadRequest, Code: code, Message: message}
}

func Unauthorized() *AppError {
	return &AppError{Status: http.StatusUnauthorized, Code: CodeUnauthorized}
}

func UnauthorizedMsg(code ErrorCode, message string) *AppError {
	return &AppError{Status: http.StatusUnauthorized, Code: code, Message: message}
}

func Forbidden(message string) *AppError {
	return &AppError{Status: http.StatusForbidden, Code: CodeNone, Message: message}
}

func NotFound(message string) *AppError {
	return &AppError{Status: http.StatusNotFound, Code: CodeNone, Message: message}
}

// WriteError traduce el error a la respuesta HTTP. Los errores con codeError se
// devuelven como {"codeError": N} (opcionalmente con message) para mantener el
// contrato del cliente; el resto usa la forma de NestJS
// ({"statusCode":N,"message":"...","error":"..."}).
func WriteError(w http.ResponseWriter, err error) {
	var appErr *AppError
	if errors.As(err, &appErr) {
		writeAppError(w, appErr)
		return
	}

	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		writePgError(w, pgErr)
		return
	}

	slog.Error("unhandled error", "error", err)
	writeStatusError(w, http.StatusInternalServerError, "Unexpected error, check server logs")
}

func writeAppError(w http.ResponseWriter, e *AppError) {
	if e.Code != CodeNone {
		body := map[string]any{"codeError": int(e.Code)}
		if e.Message != "" {
			body["message"] = e.Message
		}
		WriteJSON(w, e.Status, body)
		return
	}
	writeStatusError(w, e.Status, e.Message)
}

func writePgError(w http.ResponseWriter, e *pgconn.PgError) {
	switch e.Code {
	case "23505", "23503":
		writeStatusError(w, http.StatusBadRequest, e.Detail)
	case "23502":
		writeStatusError(w, http.StatusBadRequest, "Relationships between entities, invalid")
	default:
		slog.Error("database error", "code", e.Code, "detail", e.Detail)
		writeStatusError(w, http.StatusInternalServerError, "Unexpected error, check server logs")
	}
}

func writeStatusError(w http.ResponseWriter, status int, message string) {
	WriteJSON(w, status, map[string]any{
		"statusCode": status,
		"message":    message,
		"error":      http.StatusText(status),
	})
}

// ValidationError responde 400 con el detalle de validacion de campos.
func ValidationError(w http.ResponseWriter, messages []string) {
	WriteJSON(w, http.StatusBadRequest, map[string]any{
		"statusCode": http.StatusBadRequest,
		"message":    messages,
		"error":      "Bad Request",
	})
}

var _ = json.Marshal
