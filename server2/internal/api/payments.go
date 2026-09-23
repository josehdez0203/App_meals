package api

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"github.com/jackc/pgx/v5"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/integrations"
	"appmeals/api/internal/store"
)

// Estados de pago (StatusPayment de la version NestJS).
const (
	statusPaymentStarted   = 1
	statusPaymentConfirmed = 100
	statusPaymentCancelled = 400
)

func (a *API) registerPaymentRoutes(mux *httpx.Mux) {
	mux.Handle(http.MethodPost, "/api/client/payments/payment", a.paymentCreate, a.RequireAuth, RequireRole("client"))
	mux.Handle(http.MethodPatch, "/api/client/payments/confirm/{paymentId}", a.paymentConfirm, a.RequireAuth, RequireRole("client"))
	mux.Handle(http.MethodPatch, "/api/client/payments/cancel/{paymentId}", a.paymentCancel, a.RequireAuth, RequireRole("client"))
}

type paymentJSON struct {
	ID        int32           `json:"id"`
	Money     float64         `json:"money"`
	Status    int16           `json:"status"`
	Currency  string          `json:"currency"`
	Products  json.RawMessage `json:"products"`
	Response  json.RawMessage `json:"response"`
	CreatedAt any             `json:"createdAt"`
	UpdatedAt any             `json:"updatedAt"`
	UserID    *int32          `json:"userId"`
}

func paymentJSONFrom(row store.Payment) paymentJSON {
	var response json.RawMessage
	if len(row.Response) > 0 {
		response = json.RawMessage(row.Response)
	}
	return paymentJSON{
		ID:        row.ID,
		Money:     row.Money,
		Status:    row.Status,
		Currency:  row.Currency,
		Products:  rawJSON(row.Products),
		Response:  response,
		CreatedAt: tsJSON(row.CreatedAt),
		UpdatedAt: tsJSON(row.UpdatedAt),
		UserID:    row.UserId,
	}
}

func (a *API) paymentCreate(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Money    float64         `json:"money"`
		Currency string          `json:"currency"`
		Products json.RawMessage `json:"products"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		required("currency", req.Currency),
	}...) {
		return
	}
	if len(rawJSON(req.Products)) == 0 || string(rawJSON(req.Products)) == "null" {
		httpx.ValidationError(w, []string{"products must contain at least 1 elements"})
		return
	}

	user := currentUser(r)
	ctx := r.Context()

	// La pasarela real (Stripe) se inyecta desde cmd/api. El stub devuelve
	// ErrNotConfigured, que se traduce a 501 para dejar claro que falta configurar.
	response, err := a.pay.CreateIntent(ctx, req.Money, req.Currency, map[string]string{
		"userId": strconv.FormatInt(int64(user.ID), 10),
	})
	if err != nil {
		if errors.Is(err, integrations.ErrNotConfigured) {
			httpx.WriteError(w, httpx.New(http.StatusNotImplemented, httpx.CodeNone, "Payment gateway not configured"))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	payment, err := a.q.CreatePayment(ctx, store.CreatePaymentParams{
		Money:    req.Money,
		Status:   statusPaymentStarted,
		Currency: req.Currency,
		Products: rawJSON(req.Products),
		Response: response,
		UserId:   &user.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, paymentJSONFrom(payment))
}

func (a *API) paymentConfirm(w http.ResponseWriter, r *http.Request) {
	a.updatePaymentStatus(w, r, statusPaymentConfirmed)
}

func (a *API) paymentCancel(w http.ResponseWriter, r *http.Request) {
	a.updatePaymentStatus(w, r, statusPaymentCancelled)
}

// updatePaymentStatus comparte la logica de confirm y cancel: busca el pago del
// usuario, cambia el estado solo si estaba STARTED y, al confirmar, acredita el
// dinero al balance del cliente.
func (a *API) updatePaymentStatus(w http.ResponseWriter, r *http.Request, newStatus int16) {
	paymentID, err := strconv.ParseInt(r.PathValue("paymentId"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"paymentId must be a number"})
		return
	}

	user := currentUser(r)
	ctx := r.Context()

	payment, err := a.q.GetPaymentByIDAndUser(ctx, store.GetPaymentByIDAndUserParams{
		ID:     int32(paymentID),
		UserId: &user.ID,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.BadRequest(httpx.CodeFailedPayment))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	affected, err := a.q.UpdatePaymentStatus(ctx, store.UpdatePaymentStatusParams{
		PaymentID:     int32(paymentID),
		CurrentStatus: statusPaymentStarted,
		NewStatus:     newStatus,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	if affected == 0 {
		httpx.WriteError(w, httpx.BadRequest(httpx.CodeFailedPayment))
		return
	}

	if newStatus == statusPaymentConfirmed {
		if err := a.q.AddBalanceMoney(ctx, store.AddBalanceMoneyParams{
			UserId: user.ID,
			Money:  payment.Money,
		}); err != nil {
			httpx.WriteError(w, err)
			return
		}
	}
	httpx.OK(w, true)
}
