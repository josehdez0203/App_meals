// Package api implementa los handlers HTTP de la API de delivery.
package api

import (
	"net/http"

	"github.com/jackc/pgx/v5/pgxpool"

	"appmeals/api/internal/auth"
	"appmeals/api/internal/config"
	"appmeals/api/internal/httpx"
	"appmeals/api/internal/integrations"
	"appmeals/api/internal/store"
)

// API agrupa las dependencias compartidas por los handlers.
type API struct {
	cfg   *config.Config
	q     *store.Queries
	pool  *pgxpool.Pool
	jwt   *auth.Manager
	push  integrations.PushSender
	mail  integrations.Mailer
	oauth integrations.GoogleOAuth
	pay   integrations.PaymentGateway
	rt    integrations.Realtime
	geo   integrations.Geocoder
}

// New construye la API. Las integraciones externas se inyectan con stubs por
// defecto; usa los setters With* para reemplazarlas.
func New(cfg *config.Config, q *store.Queries, pool *pgxpool.Pool, jwt *auth.Manager) *API {
	return &API{
		cfg:   cfg,
		q:     q,
		pool:  pool,
		jwt:   jwt,
		push:  integrations.LogPushSender{},
		mail:  integrations.LogMailer{},
		oauth: integrations.NoopGoogleOAuth{},
		pay:   integrations.NoopPaymentGateway{},
		rt:    integrations.NoopRealtime{},
		geo:   integrations.NoopGeocoder{},
	}
}

func (a *API) WithPush(p integrations.PushSender) *API         { a.push = p; return a }
func (a *API) WithMailer(m integrations.Mailer) *API           { a.mail = m; return a }
func (a *API) WithGoogleOAuth(g integrations.GoogleOAuth) *API { a.oauth = g; return a }
func (a *API) WithPayments(p integrations.PaymentGateway) *API { a.pay = p; return a }
func (a *API) WithRealtime(r integrations.Realtime) *API       { a.rt = r; return a }
func (a *API) WithGeocoder(g integrations.Geocoder) *API       { a.geo = g; return a }

// Router registra todas las rutas. El prefijo /api replica el
// setGlobalPrefix("api/") de la version NestJS.
func (a *API) Router() http.Handler {
	mux := httpx.NewMux(httpx.Recover, httpx.CORS, httpx.LogRequests)

	mux.Handle(http.MethodGet, "/health", a.health)
	// Alias bajo el prefijo global /api para quien lo monitorea ahi. Se conserva
	// /health porque el README y los healthchecks existentes lo usan.
	mux.Handle(http.MethodGet, "/api/health", a.health)

	a.registerAuthRoutes(mux)
	a.registerMarketRoutes(mux)
	a.registerAddressRoutes(mux)
	a.registerBalanceRoutes(mux)
	a.registerPaymentRoutes(mux)
	a.registerPetitionRoutes(mux)
	a.registerRequestRoutes(mux)
	a.registerEnrollmentRoutes(mux)
	a.registerStoreManagerRoutes(mux)
	a.registerAdminRoutes(mux)
	a.registerChatRoutes(mux)
	a.registerEmailRoutes(mux)

	return mux
}

// health permite comprobar que el proceso y la base de datos responden.
func (a *API) health(w http.ResponseWriter, r *http.Request) {
	if err := a.pool.Ping(r.Context()); err != nil {
		httpx.WriteJSON(w, http.StatusServiceUnavailable, map[string]any{"status": "degraded", "database": "down"})
		return
	}
	httpx.OK(w, map[string]any{"status": "ok", "database": "up"})
}
