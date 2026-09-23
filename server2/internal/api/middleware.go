package api

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"github.com/jackc/pgx/v5"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

type ctxKey string

const userCtxKey ctxKey = "currentUser"

// RequireAuth valida el JWT y la sesion activa del dispositivo, replicando
// JwtStrategy.validate de la version NestJS.
func (a *API) RequireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		raw := bearerToken(r)
		if raw == "" {
			httpx.WriteError(w, httpx.Unauthorized())
			return
		}

		claims, err := a.jwt.Parse(raw)
		if err != nil {
			httpx.WriteError(w, httpx.UnauthorizedMsg(httpx.CodeUnauthorized, "Token not valid"))
			return
		}

		user, err := a.q.GetUserByID(r.Context(), claims.ID)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				httpx.WriteError(w, httpx.UnauthorizedMsg(httpx.CodeUnauthorized, "Token not valid"))
				return
			}
			httpx.WriteError(w, err)
			return
		}

		if !user.IsActive {
			httpx.WriteError(w, httpx.UnauthorizedMsg(httpx.CodeUnauthorized, "User is inactive, talk with an admin"))
			return
		}

		exists, err := a.q.SessionExistsByUserAndDevice(r.Context(), store.SessionExistsByUserAndDeviceParams{
			UserId:   user.ID,
			IdDevice: claims.IDDevice,
		})
		if err != nil {
			httpx.WriteError(w, err)
			return
		}
		if !exists {
			httpx.WriteError(w, httpx.UnauthorizedMsg(httpx.CodeUnauthorized, "Session not valid"))
			return
		}

		ctx := context.WithValue(r.Context(), userCtxKey, &user)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// RequireRole exige que el usuario tenga alguno de los roles indicados
// (equivale a @Auth(TypesRol...) + UserRoleGuard).
func RequireRole(roles ...string) httpx.Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			user := currentUser(r)
			if user == nil {
				httpx.WriteError(w, httpx.New(http.StatusInternalServerError, httpx.CodeNone, "User not found in guard"))
				return
			}
			for _, have := range user.Roles {
				for _, want := range roles {
					if have == want {
						next.ServeHTTP(w, r)
						return
					}
				}
			}
			httpx.WriteError(w, httpx.Forbidden("User "+user.FullName+" need a valid role: [ "+strings.Join(roles, ", ")+" ]"))
		})
	}
}

// currentUser devuelve el usuario cargado por RequireAuth.
func currentUser(r *http.Request) *store.GetUserByIDRow {
	if u, ok := r.Context().Value(userCtxKey).(*store.GetUserByIDRow); ok {
		return u
	}
	return nil
}

// bearerToken extrae el token del encabezado Authorization.
func bearerToken(r *http.Request) string {
	header := r.Header.Get("Authorization")
	if header == "" {
		return ""
	}
	parts := strings.SplitN(header, " ", 2)
	if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
		return ""
	}
	return strings.TrimSpace(parts[1])
}
