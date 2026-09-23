package api

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"

	"github.com/jackc/pgx/v5"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

// Estados y tipos de pago usados por el ciclo de vida del pedido.
const (
	statusStarted    = 1
	statusAssigned   = 100
	statusTaken      = 101
	typesPaymentCash = 5001
	notifChangeOrder = "5001" // TypesNotification.CHANGE_ORDER_STATUS
)

func (a *API) registerPetitionRoutes(mux *httpx.Mux) {
	const role = "deliveryman"
	mux.Handle(http.MethodGet, "/api/deliveryman/petition/near", a.petitionNear, a.RequireAuth, RequireRole(role))
	mux.Handle(http.MethodGet, "/api/deliveryman/petition/id/{orderId}", a.petitionGet, a.RequireAuth, RequireRole(role))
	mux.Handle(http.MethodGet, "/api/deliveryman/petition/ordered-at/{orderedAt}", a.petitionHistory, a.RequireAuth, RequireRole(role))
	mux.Handle(http.MethodPatch, "/api/deliveryman/petition/apply/{orderId}", a.petitionApply, a.RequireAuth, RequireRole(role))
	mux.Handle(http.MethodPatch, "/api/deliveryman/petition/collect/{orderId}", a.petitionCollect, a.RequireAuth, RequireRole(role))
	mux.Handle(http.MethodPatch, "/api/deliveryman/petition/deliver/{orderId}", a.petitionDeliver, a.RequireAuth, RequireRole(role))
	mux.Handle(http.MethodPatch, "/api/deliveryman/petition/cancel/{orderId}", a.petitionCancel, a.RequireAuth, RequireRole(role))
	mux.Handle(http.MethodPatch, "/api/deliveryman/petition/activate", a.petitionActivate, a.RequireAuth, RequireRole(role))
}

type petitionUserJSON struct {
	ID       int32   `json:"id"`
	FullName string  `json:"fullName"`
	Phone    *string `json:"phone"`
	Image    string  `json:"image"`
}

type petitionStoreCompanyJSON struct {
	Image string `json:"image"`
}

type petitionStoreJSON struct {
	ID       int32                    `json:"id"`
	Name     string                   `json:"name"`
	Address  string                   `json:"address"`
	Contact  string                   `json:"contact"`
	Location locationJSON             `json:"location"`
	Company  petitionStoreCompanyJSON `json:"company"`
}

type petitionJSON struct {
	ID                       int32             `json:"id"`
	Note                     string            `json:"note"`
	Address                  string            `json:"address"`
	Status                   int16             `json:"status"`
	Products                 json.RawMessage   `json:"products"`
	DeliveryFee              float64           `json:"deliveryFee"`
	Total                    float64           `json:"total"`
	Payment                  int32             `json:"payment"`
	NotificationsDeliveryman float64           `json:"notificationsDeliveryman"`
	NotificationsClient      float64           `json:"notificationsClient"`
	DeliverymanProfit        *float64          `json:"deliverymanProfit"`
	DeliveryAppProfit        *float64          `json:"deliveryAppProfit"`
	OrderedAt                any               `json:"orderedAt"`
	CreatedAt                any               `json:"createdAt"`
	Location                 locationJSON      `json:"location"`
	User                     petitionUserJSON  `json:"user"`
	Store                    petitionStoreJSON `json:"store"`
}

func petitionJSONFrom(row store.ListNearPetitionsRow) petitionJSON {
	return petitionJSON{
		ID:                       row.ID,
		Note:                     row.Note,
		Address:                  row.Address,
		Status:                   row.Status,
		Products:                 rawJSON(row.Products),
		DeliveryFee:              row.DeliveryFee,
		Total:                    row.Total,
		Payment:                  row.Payment,
		NotificationsDeliveryman: row.NotificationsDeliveryman,
		NotificationsClient:      row.NotificationsClient,
		DeliverymanProfit:        row.DeliverymanProfit,
		DeliveryAppProfit:        row.DeliveryAppProfit,
		OrderedAt:                dateJSON(row.OrderedAt),
		CreatedAt:                tsJSON(row.CreatedAt),
		Location:                 newLocation(row.Latitude, row.Longitude),
		User: petitionUserJSON{
			ID:       row.UserID,
			FullName: row.UserFullName,
			Phone:    row.UserPhone,
			Image:    row.UserImage,
		},
		Store: petitionStoreJSON{
			ID:       row.StoreID,
			Name:     row.StoreName,
			Address:  row.StoreAddress,
			Contact:  row.StoreContact,
			Location: newLocation(row.StoreLatitude, row.StoreLongitude),
			Company:  petitionStoreCompanyJSON{Image: row.CompanyImage},
		},
	}
}

// petitionNear lista los pedidos cercanos o ya asignados al repartidor.
func (a *API) petitionNear(w http.ResponseWriter, r *http.Request) {
	idDevice := r.URL.Query().Get("idDevice")
	if !isUUID(idDevice) {
		httpx.ValidationError(w, []string{"idDevice must be a UUID"})
		return
	}
	user := currentUser(r)
	ctx := r.Context()

	session, err := a.q.GetSessionByUserAndDevice(ctx, store.GetSessionByUserAndDeviceParams{
		UserId:   user.ID,
		IdDevice: idDevice,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			// La version NestJS retorna undefined en este caso.
			httpx.OK(w, nil)
			return
		}
		httpx.WriteError(w, err)
		return
	}

	rows, err := a.q.ListNearPetitions(ctx, store.ListNearPetitionsParams{
		DeliverymanID:   user.ID,
		StatusDelivered: statusDelivered,
		StatusStarted:   statusStarted,
		Latitude:        session.Latitude,
		Longitude:       session.Longitude,
		Km:              storesNearbyKM,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	petitions := make([]petitionJSON, 0, len(rows))
	for _, row := range rows {
		petitions = append(petitions, petitionJSONFrom(row))
	}
	httpx.OK(w, map[string]any{"petitions": petitions})
}

func (a *API) petitionGet(w http.ResponseWriter, r *http.Request) {
	orderID, ok := a.parseOrderID(w, r)
	if !ok {
		return
	}
	user := currentUser(r)

	row, err := a.q.GetPetition(r.Context(), store.GetPetitionParams{
		ID:            orderID,
		DeliverymanId: &user.ID,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.OK(w, map[string]any{"petition": nil})
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"petition": petitionJSONFrom(store.ListNearPetitionsRow(row))})
}

func (a *API) petitionHistory(w http.ResponseWriter, r *http.Request) {
	orderedAt, ok := parseDate(r.PathValue("orderedAt"))
	if !ok {
		httpx.ValidationError(w, []string{"orderedAt must be a valid ISO 8601 date string"})
		return
	}
	user := currentUser(r)

	rows, err := a.q.ListPetitionHistory(r.Context(), store.ListPetitionHistoryParams{
		DeliverymanId: &user.ID,
		OrderedAt:     orderedAt,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	petitions := make([]petitionJSON, 0, len(rows))
	for _, row := range rows {
		petitions = append(petitions, petitionJSONFrom(store.ListNearPetitionsRow(row)))
	}
	httpx.OK(w, map[string]any{"petitions": petitions})
}

// petitionApply asigna el pedido al repartidor, calcula las ganancias y ajusta
// su balance (BalanceService en la version NestJS).
func (a *API) petitionApply(w http.ResponseWriter, r *http.Request) {
	orderID, ok := a.parseOrderID(w, r)
	if !ok {
		return
	}
	user := currentUser(r)
	ctx := r.Context()

	balance, err := a.q.GetBalanceByUser(ctx, user.ID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.BadRequestMsg(httpx.CodeNoBalance, "The deliveryman does not have a balance sheet record"))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	order, err := a.q.GetOrderForApply(ctx, orderID)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	deliverymanProfit := order.DeliveryFee * balance.Profit
	deliveryAppProfit := order.DeliveryFee - deliverymanProfit
	if deliveryAppProfit > balance.Balance {
		httpx.WriteError(w, httpx.BadRequestMsg(httpx.CodeInsufficientBalance, "The delivery person has no balance to take the order"))
		return
	}

	affected, err := a.q.ApplyOrder(ctx, store.ApplyOrderParams{
		OrderID:           orderID,
		DeliverymanID:     user.ID,
		NewStatus:         statusAssigned,
		CurrentStatus:     statusStarted,
		DeliverymanProfit: deliverymanProfit,
		DeliveryAppProfit: deliveryAppProfit,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	if affected > 0 {
		newBalance := balance.Balance
		newAmount := balance.Amount
		switch order.Payment {
		case typesPaymentCash:
			newBalance -= deliveryAppProfit
		case typesPaymentMon:
			newAmount += deliverymanProfit
		}
		if _, err := a.q.UpdateBalanceValues(ctx, store.UpdateBalanceValuesParams{
			UserID:  user.ID,
			Balance: newBalance,
			Amount:  newAmount,
			Money:   balance.Money,
		}); err != nil {
			httpx.WriteError(w, err)
			return
		}
		a.respondPetition(w, ctx, orderID, user.ID)
		return
	}

	httpx.WriteError(w, httpx.BadRequestMsg(httpx.CodeOrderFulfilled, fmt.Sprintf("Order with id %d already attended", orderID)))
}

func (a *API) petitionCollect(w http.ResponseWriter, r *http.Request) {
	orderID, ok := a.parseOrderID(w, r)
	if !ok {
		return
	}
	user := currentUser(r)
	ctx := r.Context()

	affected, err := a.q.CollectOrder(ctx, store.CollectOrderParams{
		OrderID:       orderID,
		CurrentStatus: statusAssigned,
		NewStatus:     statusTaken,
		DeliverymanID: user.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	if affected == 0 {
		httpx.WriteError(w, httpx.NotFound(fmt.Sprintf("Order with id %d already picked up", orderID)))
		return
	}
	a.respondPetition(w, ctx, orderID, user.ID)
}

func (a *API) petitionDeliver(w http.ResponseWriter, r *http.Request) {
	orderID, ok := a.parseOrderID(w, r)
	if !ok {
		return
	}
	var req struct {
		ScoreDeliveryman float64 `json:"scoreDeliveryman"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if req.ScoreDeliveryman <= 0 || req.ScoreDeliveryman > 5 {
		httpx.ValidationError(w, []string{"scoreDeliveryman must not be less than 1 and not greater than 5"})
		return
	}

	user := currentUser(r)
	ctx := r.Context()

	affected, err := a.q.DeliverOrder(ctx, store.DeliverOrderParams{
		OrderID:          orderID,
		CurrentStatus:    statusTaken,
		NewStatus:        statusDelivered,
		ScoreDeliveryman: req.ScoreDeliveryman,
		DeliverymanID:    user.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	if affected == 0 {
		httpx.WriteError(w, httpx.NotFound(fmt.Sprintf("Order with id %d already delivered", orderID)))
		return
	}
	a.respondPetition(w, ctx, orderID, user.ID)
}

// petitionCancel cancela un pedido asignado y devuelve el dinero segun el metodo
// de pago (efectivo al repartidor, saldo al cliente).
func (a *API) petitionCancel(w http.ResponseWriter, r *http.Request) {
	orderID, ok := a.parseOrderID(w, r)
	if !ok {
		return
	}
	user := currentUser(r)
	ctx := r.Context()

	order, err := a.q.GetOrderForCancel(ctx, store.GetOrderForCancelParams{
		ID:     orderID,
		Status: statusAssigned,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound(fmt.Sprintf("Order with id %d already not ASSIGNED", orderID)))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	balanceDeliveryman, err := a.q.GetBalanceByUser(ctx, user.ID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("The deliveryman does not have a balance sheet record"))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	var balanceClient *store.Balance
	if order.Payment == typesPaymentMon {
		client, err := a.q.GetBalanceByUser(ctx, order.UserId)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				httpx.WriteError(w, httpx.NotFound("The client does not have a balance sheet record"))
				return
			}
			httpx.WriteError(w, err)
			return
		}
		balanceClient = &client
	}

	affected, err := a.q.CancelOrder(ctx, store.CancelOrderParams{
		OrderID:       orderID,
		CurrentStatus: statusAssigned,
		NewStatus:     statusCancelled,
		DeliverymanID: user.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	if affected == 0 {
		httpx.WriteError(w, httpx.NotFound(fmt.Sprintf("Order with id %d already not ASSIGNED", orderID)))
		return
	}

	switch order.Payment {
	case typesPaymentMon:
		if balanceClient != nil {
			if _, err := a.q.UpdateBalanceValues(ctx, store.UpdateBalanceValuesParams{
				UserID:  order.UserId,
				Balance: balanceClient.Balance,
				Amount:  balanceClient.Amount,
				Money:   balanceClient.Money + order.Total,
			}); err != nil {
				httpx.WriteError(w, err)
				return
			}
		}
		if _, err := a.q.UpdateBalanceValues(ctx, store.UpdateBalanceValuesParams{
			UserID:  user.ID,
			Balance: balanceDeliveryman.Balance,
			Amount:  balanceDeliveryman.Amount - floatValue(order.DeliverymanProfit),
			Money:   balanceDeliveryman.Money,
		}); err != nil {
			httpx.WriteError(w, err)
			return
		}
	case typesPaymentCash:
		if _, err := a.q.UpdateBalanceValues(ctx, store.UpdateBalanceValuesParams{
			UserID:  user.ID,
			Balance: balanceDeliveryman.Balance + floatValue(order.DeliveryAppProfit),
			Amount:  balanceDeliveryman.Amount,
			Money:   balanceDeliveryman.Money,
		}); err != nil {
			httpx.WriteError(w, err)
			return
		}
	}

	a.respondPetition(w, ctx, orderID, user.ID)
}

func (a *API) petitionActivate(w http.ResponseWriter, r *http.Request) {
	var req struct {
		IDDevice  string  `json:"idDevice"`
		IsOnline  bool    `json:"isOnline"`
		Latitude  float64 `json:"latitude"`
		Longitude float64 `json:"longitude"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if !isUUID(req.IDDevice) {
		httpx.ValidationError(w, []string{"idDevice must be a UUID"})
		return
	}
	if req.Latitude < -90 || req.Latitude > 90 || req.Longitude < -180 || req.Longitude > 180 {
		httpx.ValidationError(w, []string{"latitude/longitude out of range"})
		return
	}

	user := currentUser(r)
	if _, err := a.q.UpdateSessionActivate(r.Context(), store.UpdateSessionActivateParams{
		UserId:   user.ID,
		IdDevice: req.IDDevice,
		IsOnline: req.IsOnline,
		Point:    req.Latitude,
		Point_2:  req.Longitude,
	}); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, true)
}

// --- helpers ---

func (a *API) parseOrderID(w http.ResponseWriter, r *http.Request) (int32, bool) {
	orderID, err := strconv.ParseInt(r.PathValue("orderId"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"orderId must be a number"})
		return 0, false
	}
	return int32(orderID), true
}

// respondPetition reproduce _getOrderAndNotify: devuelve {petition} y avisa al
// cliente del cambio de estado.
func (a *API) respondPetition(w http.ResponseWriter, ctx context.Context, orderID, deliverymanID int32) {
	petition, err := a.q.GetPetition(ctx, store.GetPetitionParams{
		ID:            orderID,
		DeliverymanId: &deliverymanID,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.OK(w, nil)
			return
		}
		httpx.WriteError(w, err)
		return
	}

	data := map[string]string{
		"type":    notifChangeOrder,
		"status":  strconv.Itoa(int(petition.Status)),
		"orderId": strconv.FormatInt(int64(orderID), 10),
	}
	_ = a.notifyUser(ctx, petition.UserID, data)

	httpx.OK(w, map[string]any{"petition": petitionJSONFrom(store.ListNearPetitionsRow(petition))})
}

// notifyUser envia una notificacion push a todas las sesiones del usuario.
func (a *API) notifyUser(ctx context.Context, userID int32, data map[string]string) error {
	tokens, err := a.q.ListPushTokensByUser(ctx, userID)
	if err != nil {
		return err
	}
	valid := make([]string, 0, len(tokens))
	for _, t := range tokens {
		if t != nil && *t != "" {
			valid = append(valid, *t)
		}
	}
	return a.push.Send(ctx, valid, data)
}

func floatValue(v *float64) float64 {
	if v == nil {
		return 0
	}
	return *v
}
