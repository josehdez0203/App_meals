package api

import (
	"fmt"
	"net/http"
	"regexp"
	"time"

	"github.com/jackc/pgx/v5/pgtype"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

// locationJSON es la forma en que el cliente Flutter espera las columnas point:
// {"x": latitud, "y": longitud} (node-postgres las serializa igual).
type locationJSON struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

func newLocation(x, y float64) locationJSON {
	return locationJSON{X: x, Y: y}
}

// userResponse es el superconjunto de campos de usuario que devuelve la API.
type userResponse struct {
	ID        int32    `json:"id"`
	IDGoogle  *string  `json:"idGoogle"`
	FullName  string   `json:"fullName"`
	Email     string   `json:"email"`
	Phone     *string  `json:"phone"`
	Image     string   `json:"image"`
	IsActive  bool     `json:"isActive"`
	Roles     []string `json:"roles"`
	CreatedAt any      `json:"createdAt"`
	UpdatedAt any      `json:"updatedAt"`
	Token     string   `json:"token,omitempty"`
}

func userJSON(u store.GetUserByIDRow) userResponse {
	return userResponse{
		ID:        u.ID,
		IDGoogle:  u.IdGoogle,
		FullName:  u.FullName,
		Email:     u.Email,
		Phone:     u.Phone,
		Image:     u.Image,
		IsActive:  u.IsActive,
		Roles:     u.Roles,
		CreatedAt: tsJSON(u.CreatedAt),
		UpdatedAt: tsJSON(u.UpdatedAt),
	}
}

func tsJSON(t pgtype.Timestamptz) any {
	if !t.Valid {
		return nil
	}
	return t.Time.UTC().Format(time.RFC3339Nano)
}

func timestampJSON(t pgtype.Timestamp) any {
	if !t.Valid {
		return nil
	}
	return t.Time.UTC().Format(time.RFC3339Nano)
}

func dateJSON(d pgtype.Date) any {
	if !d.Valid {
		return nil
	}
	return d.Time.Format("2006-01-02")
}

// clockJSON convierte una columna time de PostgreSQL a "HH:MM:SS".
func clockJSON(t pgtype.Time) any {
	if !t.Valid {
		return nil
	}
	total := t.Microseconds
	hours := total / 3_600_000_000
	total %= 3_600_000_000
	minutes := total / 60_000_000
	total %= 60_000_000
	seconds := total / 1_000_000
	return fmt.Sprintf("%02d:%02d:%02d", hours, minutes, seconds)
}

func strOrNil(s *string) any {
	if s == nil {
		return nil
	}
	return *s
}

func intOrNil(i *int32) any {
	if i == nil {
		return nil
	}
	return *i
}

func floatOrNil(f *float64) any {
	if f == nil {
		return nil
	}
	return *f
}

// --- validacion ---

var (
	emailRe = regexp.MustCompile(`^[^@\s]+@[^@\s]+\.[^@\s]+$`)
	uuidRe  = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`)
)

func isEmail(s string) bool { return emailRe.MatchString(s) }
func isUUID(s string) bool  { return uuidRe.MatchString(s) }

// decodeJSON lee el cuerpo y responde 400 si no es valido (equivale al
// ValidationPipe con forbidNonWhitelisted).
func decodeJSON(w http.ResponseWriter, r *http.Request, dst any) bool {
	if err := httpx.Decode(r, dst); err != nil {
		httpx.ValidationError(w, []string{err.Error()})
		return false
	}
	return true
}

// invalid responde 400 si hay mensajes de validacion (ignora los vacios).
func invalid(w http.ResponseWriter, messages ...string) bool {
	filtered := make([]string, 0, len(messages))
	for _, m := range messages {
		if m != "" {
			filtered = append(filtered, m)
		}
	}
	if len(filtered) == 0 {
		return false
	}
	httpx.ValidationError(w, filtered)
	return true
}

// minLen valida longitud minima y devuelve el mensaje de error (vacio si ok).
func minLen(field, value string, min int) string {
	if len(value) < min {
		return fmt.Sprintf("%s must be longer than or equal to %d characters", field, min)
	}
	return ""
}

func required(field, value string) string {
	if value == "" {
		return field + " should not be empty"
	}
	return ""
}
