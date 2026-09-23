package api

import (
	"errors"
	"net/http"

	"github.com/jackc/pgx/v5"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

func (a *API) registerBalanceRoutes(mux *httpx.Mux) {
	mux.Handle(http.MethodGet, "/api/client/balance", a.balanceGet, a.RequireAuth)
}

type balanceJSON struct {
	UserID    int32   `json:"userId"`
	Balance   float64 `json:"balance"`
	Profit    float64 `json:"profit"`
	Amount    float64 `json:"amount"`
	Money     float64 `json:"money"`
	CreatedAt any     `json:"createdAt"`
	UpdatedAt any     `json:"updatedAt"`
}

func balanceJSONFrom(b store.Balance) balanceJSON {
	return balanceJSON{
		UserID:    b.UserId,
		Balance:   b.Balance,
		Profit:    b.Profit,
		Amount:    b.Amount,
		Money:     b.Money,
		CreatedAt: tsJSON(b.CreatedAt),
		UpdatedAt: tsJSON(b.UpdatedAt),
	}
}

// balanceGet reproduce BalanceService.findOne: si no hay registro devuelve 400.
func (a *API) balanceGet(w http.ResponseWriter, r *http.Request) {
	balance, err := a.q.GetBalanceByUser(r.Context(), currentUser(r).ID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.New(http.StatusBadRequest, httpx.CodeNone, "The client does not have a registered balance"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"balance": balanceJSONFrom(balance)})
}
