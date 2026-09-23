package api

import (
	"context"
	"encoding/json"
	"errors"
	"math"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

// Constantes copiadas de la version NestJS.
const (
	storesNearbyKM  = 80000000.0 // FilterKM.STORES_NEARBY
	statusDelivered = 200        // StatusOrder.DELIVERED
	statusCancelled = 400        // StatusOrder.CANCELLED
	statusQualified = 300        // StatusOrder.QUALIFIED
	typesPaymentMon = 6002       // TypesPayment.money (saldo)
)

func (a *API) registerMarketRoutes(mux *httpx.Mux) {
	mux.Handle(http.MethodGet, "/api/client/market/companies", a.marketCompanies)
	mux.Handle(http.MethodGet, "/api/client/market/categories", a.marketCategories)
	mux.Handle(http.MethodGet, "/api/client/market/products/company/{companyId}", a.marketProducts)
	mux.Handle(http.MethodGet, "/api/client/market/delivery-cost/companies/{companyIds}", a.marketDeliveryCost, a.RequireAuth)
	mux.Handle(http.MethodGet, "/api/client/market/orders", a.marketOrders, a.RequireAuth, RequireRole("client"))
	mux.Handle(http.MethodGet, "/api/client/market/order/{orderId}", a.marketOrder, a.RequireAuth, RequireRole("client"))
	mux.Handle(http.MethodPost, "/api/client/market/buy", a.marketBuy, a.RequireAuth, RequireRole("client"))
	mux.Handle(http.MethodPatch, "/api/client/market/qualify/{orderId}", a.marketQualify, a.RequireAuth, RequireRole("client"))
}

// --- Respuestas JSON (mismos campos que serializaba la version NestJS) ---

type companyJSON struct {
	ID         int32        `json:"id"`
	StoreID    int32        `json:"storeId"`
	IsOpen     bool         `json:"isOpen"`
	Name       string       `json:"name"`
	Address    string       `json:"address"`
	Contact    string       `json:"contact"`
	Image      string       `json:"image"`
	Open       any          `json:"open"`
	Close      any          `json:"close"`
	CategoryID int32        `json:"categoryId"`
	Location   locationJSON `json:"location"`
}

type categoryJSON struct {
	ID       int32        `json:"id"`
	Name     string       `json:"name"`
	Image    string       `json:"image"`
	Location locationJSON `json:"location"`
}

type feeJSON struct {
	Name        string  `json:"name"`
	CompanyID   any     `json:"companyId"`
	Image       string  `json:"image"`
	Marker      string  `json:"marker"`
	StoreID     int32   `json:"store_id"`
	Deliveryfee float64 `json:"deliveryfee"`
}

type storeCompanyRefJSON struct {
	Image  string `json:"image"`
	Marker string `json:"marker"`
}

type orderStoreJSON struct {
	ID       int32               `json:"id"`
	Name     string              `json:"name"`
	Address  string              `json:"address"`
	Location locationJSON        `json:"location"`
	Company  storeCompanyRefJSON `json:"company"`
}

type deliverymanJSON struct {
	ID       int32  `json:"id"`
	FullName string `json:"fullName"`
	Image    string `json:"image"`
}

type orderJSON struct {
	ID                       int32            `json:"id"`
	Note                     string           `json:"note"`
	Address                  string           `json:"address"`
	Status                   int16            `json:"status"`
	Products                 json.RawMessage  `json:"products"`
	DeliveryFee              float64          `json:"deliveryFee"`
	Total                    float64          `json:"total"`
	Payment                  int32            `json:"payment"`
	ScoreClient              *float64         `json:"scoreClient"`
	ScoreDeliveryman         *float64         `json:"scoreDeliveryman"`
	NotificationsClient      float64          `json:"notificationsClient"`
	NotificationsDeliveryman float64          `json:"notificationsDeliveryman"`
	OrderedAt                any              `json:"orderedAt"`
	CreatedAt                any              `json:"createdAt"`
	Location                 locationJSON     `json:"location"`
	Store                    orderStoreJSON   `json:"store"`
	Deliveryman              *deliverymanJSON `json:"deliveryman"`
}

func rawJSON(b []byte) json.RawMessage {
	if len(b) == 0 {
		return json.RawMessage("[]")
	}
	return json.RawMessage(b)
}

func orderJSONFromRow(row store.ListOrdersByUserRow) orderJSON {
	return orderJSON{
		ID:                       row.ID,
		Note:                     row.Note,
		Address:                  row.Address,
		Status:                   row.Status,
		Products:                 rawJSON(row.Products),
		DeliveryFee:              row.DeliveryFee,
		Total:                    row.Total,
		Payment:                  row.Payment,
		ScoreClient:              row.ScoreClient,
		ScoreDeliveryman:         row.ScoreDeliveryman,
		NotificationsClient:      row.NotificationsClient,
		NotificationsDeliveryman: row.NotificationsDeliveryman,
		OrderedAt:                dateJSON(row.OrderedAt),
		CreatedAt:                tsJSON(row.CreatedAt),
		Location:                 newLocation(row.Latitude, row.Longitude),
		Store: orderStoreJSON{
			ID:       row.StoreID,
			Name:     row.StoreName,
			Address:  row.StoreAddress,
			Location: newLocation(row.StoreLatitude, row.StoreLongitude),
			Company:  storeCompanyRefJSON{Image: row.CompanyImage, Marker: row.CompanyMarker},
		},
		Deliveryman: deliverymanFrom(row.DeliverymanID, row.DeliverymanFullName, row.DeliverymanImage),
	}
}

func deliverymanFrom(id *int32, fullName, image *string) *deliverymanJSON {
	if id == nil {
		return nil
	}
	d := &deliverymanJSON{ID: *id}
	if fullName != nil {
		d.FullName = *fullName
	}
	if image != nil {
		d.Image = *image
	}
	return d
}

// --- Handlers ---

// marketCompanies reproduce MarketService.findCompanies, incluido el heuristica
// de rotacion ("jump") que elige que compania muestra producto destacado.
func (a *API) marketCompanies(w http.ResponseWriter, r *http.Request) {
	lat, lng, ok := a.parseCoordinates(w, r)
	if !ok {
		return
	}
	categoryID := queryInt32(r, "categoryId", 0)
	limit, offset := parsePagination(r)

	ctx := r.Context()
	companies, err := a.q.ListCompaniesNearby(ctx, store.ListCompaniesNearbyParams{
		Latitude:    lat,
		Longitude:   lng,
		Km:          storesNearbyKM,
		Categoryid:  categoryID,
		LimitCount:  limit,
		OffsetCount: offset,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	// La version NestJS ordena por isOpen descendente en memoria.
	sort.SliceStable(companies, func(i, j int) bool {
		return boolValue(companies[i].IsOpen) && !boolValue(companies[j].IsOpen)
	})

	jump := int(math.Round(float64(time.Now().Hour()) / 4.0))
	var companyIDs []int32
	if jump > 0 && len(companies) >= jump*3 {
		for i, c := range companies {
			if boolValue(c.IsOpen) && (i+1)%jump == 0 {
				companyIDs = append(companyIDs, c.ID)
			}
		}
	}
	if len(companyIDs) == 0 {
		for _, c := range companies {
			if boolValue(c.IsOpen) {
				companyIDs = append(companyIDs, c.ID)
			}
		}
	}

	products := []store.VwProduct{}
	if len(companyIDs) > 0 {
		products, err = a.q.ListProductsByCompanyIDs(ctx, companyIDs)
		if err != nil {
			httpx.WriteError(w, err)
			return
		}
		// Orden ascendente si jump es par, descendente si es impar.
		if jump%2 != 0 {
			sort.SliceStable(products, func(i, j int) bool {
				return int32Value(products[i].CompanyId) > int32Value(products[j].CompanyId)
			})
		}
		// Solo un producto por compania.
		seen := make(map[int32]bool, len(products))
		unique := make([]store.VwProduct, 0, len(products))
		for _, p := range products {
			if seen[int32Value(p.CompanyId)] {
				continue
			}
			seen[int32Value(p.CompanyId)] = true
			unique = append(unique, p)
		}
		products = unique
	}

	out := make([]companyJSON, 0, len(companies))
	for _, c := range companies {
		out = append(out, companyJSON{
			ID:         c.ID,
			StoreID:    c.StoreId,
			IsOpen:     boolValue(c.IsOpen),
			Name:       c.Name,
			Address:    c.Address,
			Contact:    c.Contact,
			Image:      c.Image,
			Open:       clockJSON(c.Open),
			Close:      clockJSON(c.Close),
			CategoryID: c.CategoryId,
			Location:   newLocation(c.Latitude, c.Longitude),
		})
	}

	httpx.OK(w, map[string]any{"companies": out, "products": productsJSON(products)})
}

func (a *API) marketCategories(w http.ResponseWriter, r *http.Request) {
	lat, lng, ok := a.parseCoordinates(w, r)
	if !ok {
		return
	}
	limit, offset := parsePagination(r)

	rows, err := a.q.ListCategoriesNearby(r.Context(), store.ListCategoriesNearbyParams{
		Latitude:    lat,
		Longitude:   lng,
		Km:          storesNearbyKM,
		LimitCount:  limit,
		OffsetCount: offset,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	categories := make([]categoryJSON, 0, len(rows))
	for _, c := range rows {
		categories = append(categories, categoryJSON{
			ID:       c.ID,
			Name:     c.Name,
			Image:    c.Image,
			Location: newLocation(c.Latitude, c.Longitude),
		})
	}
	httpx.OK(w, map[string]any{"categories": categories})
}

func (a *API) marketProducts(w http.ResponseWriter, r *http.Request) {
	companyID, err := strconv.ParseInt(r.PathValue("companyId"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"companyId must be a number"})
		return
	}
	limit, offset := parsePagination(r)

	companyKey := int32(companyID)
	products, err := a.q.ListProductsByCompany(r.Context(), store.ListProductsByCompanyParams{
		CompanyId: &companyKey,
		Limit:     limit,
		Offset:    offset,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"products": productsJSON(products)})
}

// marketDeliveryCost reproduce MarketService.deliveryCost: primero obtiene las
// tiendas cercanas y abiertas de las companias pedidas y luego calcula la tarifa.
func (a *API) marketDeliveryCost(w http.ResponseWriter, r *http.Request) {
	lat, lng, ok := a.parseCoordinates(w, r)
	if !ok {
		return
	}
	companyIDs, err := splitInt32(r.PathValue("companyIds"))
	if err != nil || len(companyIDs) == 0 {
		httpx.WriteError(w, httpx.New(http.StatusBadRequest, httpx.CodeNone, "companyIds"))
		return
	}

	ctx := r.Context()
	storeIDs, err := a.q.ListNearbyStoreIDs(ctx, store.ListNearbyStoreIDsParams{
		Latitude:   lat,
		Longitude:  lng,
		Km:         storesNearbyKM,
		CompanyIds: companyIDs,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	if len(storeIDs) == 0 {
		httpx.WriteError(w, httpx.New(http.StatusBadRequest, httpx.CodeNone, "companyIds"))
		return
	}

	fees, err := a.q.ListDeliveryFees(ctx, store.ListDeliveryFeesParams{
		Latitude:  lat,
		Longitude: lng,
		StoreIds:  storeIDs,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	out := make([]feeJSON, 0, len(fees))
	for _, f := range fees {
		out = append(out, feeJSON{
			Name:        f.Name,
			CompanyID:   intOrNil(f.CompanyId),
			Image:       f.Image,
			Marker:      f.Marker,
			StoreID:     f.StoreID,
			Deliveryfee: f.Deliveryfee,
		})
	}
	httpx.OK(w, map[string]any{"fees": out})
}

func (a *API) marketOrders(w http.ResponseWriter, r *http.Request) {
	user := currentUser(r)
	rows, err := a.q.ListOrdersByUser(r.Context(), store.ListOrdersByUserParams{
		UserID:          user.ID,
		StatusDelivered: statusDelivered,
		StatusCancelled: statusCancelled,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	orders := make([]orderJSON, 0, len(rows))
	for _, row := range rows {
		orders = append(orders, orderJSONFromRow(row))
	}
	httpx.OK(w, map[string]any{"orders": orders})
}

func (a *API) marketOrder(w http.ResponseWriter, r *http.Request) {
	user := currentUser(r)
	orderID, err := strconv.ParseInt(r.PathValue("orderId"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"orderId must be a number"})
		return
	}

	row, err := a.q.GetOrderByUser(r.Context(), store.GetOrderByUserParams{
		ID:     int32(orderID),
		UserId: user.ID,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.OK(w, map[string]any{"order": nil})
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"order": orderJSONFromRow(store.ListOrdersByUserRow(row))})
}

type buyRequest struct {
	Store struct {
		ID int32 `json:"id"`
	} `json:"store"`
	Note        string          `json:"note"`
	DeliveryFee float64         `json:"deliveryFee"`
	Total       float64         `json:"total"`
	Address     string          `json:"address"`
	Products    json.RawMessage `json:"products"`
	Location    locationJSON    `json:"location"`
	OrderedAt   string          `json:"orderedAt"`
	Payment     int32           `json:"payment"`
}

// marketBuy reproduce MarketService.buy. Con pago por saldo (6002) descuenta el
// total del dinero del cliente; luego crea el pedido y notifica.
func (a *API) marketBuy(w http.ResponseWriter, r *http.Request) {
	var req buyRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		minLen("address", req.Address, 3),
	}...) {
		return
	}
	if req.Store.ID == 0 {
		httpx.ValidationError(w, []string{"store should not be empty"})
		return
	}
	if req.Payment <= 0 {
		httpx.ValidationError(w, []string{"payment must be a positive number"})
		return
	}
	products := rawJSON(req.Products)
	if len(products) == 0 || string(products) == "null" {
		httpx.ValidationError(w, []string{"products must contain at least 1 elements"})
		return
	}
	orderedAt, ok := parseDate(req.OrderedAt)
	if !ok {
		httpx.ValidationError(w, []string{"orderedAt must be a valid ISO 8601 date string"})
		return
	}

	user := currentUser(r)
	ctx := r.Context()

	if req.Payment == typesPaymentMon {
		balance, err := a.q.GetBalanceByUser(ctx, user.ID)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				httpx.WriteError(w, httpx.New(http.StatusBadRequest, httpx.CodeNone, "The client does not have a balance sheet record"))
				return
			}
			httpx.WriteError(w, err)
			return
		}
		if req.Total > balance.Money {
			httpx.WriteError(w, httpx.New(http.StatusBadRequest, httpx.CodeNone, "The client has no balance to take the order"))
			return
		}
		if _, err := a.q.UpdateBalanceMoney(ctx, store.UpdateBalanceMoneyParams{
			UserId: user.ID,
			Money:  balance.Money - req.Total,
		}); err != nil {
			httpx.WriteError(w, err)
			return
		}
	}

	order, err := a.q.CreateOrder(ctx, store.CreateOrderParams{
		Note:        req.Note,
		Address:     req.Address,
		Status:      1, // StatusOrder.STARTED
		Products:    products,
		DeliveryFee: req.DeliveryFee,
		Total:       req.Total,
		Payment:     req.Payment,
		Point:       req.Location.X,
		Point_2:     req.Location.Y,
		OrderedAt:   orderedAt,
		StoreId:     req.Store.ID,
		UserId:      user.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	data := map[string]string{
		"type":    "1010", // TypesNotification.NEW_ORDER
		"title":   "New order",
		"body":    user.FullName,
		"orderId": strconv.FormatInt(int64(order.ID), 10),
	}
	// Best effort, igual que la version NestJS (no bloquea la respuesta).
	_ = a.notifyOrderNearby(ctx, order.ID, req.Location.X, req.Location.Y, data)

	// NestJS hace `delete order.user` y `delete order.location` antes de
	// responder; se replica para no cambiar el contrato.
	httpx.Created(w, map[string]any{
		"id":                       order.ID,
		"note":                     order.Note,
		"address":                  order.Address,
		"status":                   order.Status,
		"products":                 rawJSON(order.Products),
		"deliveryFee":              order.DeliveryFee,
		"total":                    order.Total,
		"payment":                  order.Payment,
		"scoreClient":              order.ScoreClient,
		"scoreDeliveryman":         order.ScoreDeliveryman,
		"notificationsClient":      order.NotificationsClient,
		"notificationsDeliveryman": order.NotificationsDeliveryman,
		"orderedAt":                dateJSON(order.OrderedAt),
		"createdAt":                tsJSON(order.CreatedAt),
		"storeId":                  order.StoreId,
		"userId":                   order.UserId,
		"deliverymanId":            order.DeliverymanId,
		"store":                    map[string]any{"id": order.StoreId},
	})
}

func (a *API) marketQualify(w http.ResponseWriter, r *http.Request) {
	orderID, err := strconv.ParseInt(r.PathValue("orderId"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"orderId must be a number"})
		return
	}
	var req struct {
		ScoreClient float64 `json:"scoreClient"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if req.ScoreClient < 1 || req.ScoreClient > 5 {
		httpx.ValidationError(w, []string{"scoreClient must not be less than 1 and not greater than 5"})
		return
	}

	user := currentUser(r)
	if _, err := a.q.QualifyOrder(r.Context(), store.QualifyOrderParams{
		OrderID:         int32(orderID),
		UserID:          user.ID,
		StatusQualified: statusQualified,
		ScoreClient:     req.ScoreClient,
	}); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, true)
}

// --- Helpers ---

func productsJSON(products []store.VwProduct) []map[string]any {
	out := make([]map[string]any, 0, len(products))
	for _, p := range products {
		out = append(out, map[string]any{
			"id":          p.ID,
			"companyId":   intOrNil(p.CompanyId),
			"companyName": p.CompanyName,
			"name":        p.Name,
			"image":       p.Image,
			"description": p.Description,
			"type":        p.Type,
			"price":       p.Price,
		})
	}
	return out
}

func boolValue(b *bool) bool { return b != nil && *b }

// parseCoordinates valida latitude/longitude como hacia el DTO con
// @IsLatitude/@IsLongitude (obligatorios).
func (a *API) parseCoordinates(w http.ResponseWriter, r *http.Request) (float64, float64, bool) {
	lat, errLat := strconv.ParseFloat(r.URL.Query().Get("latitude"), 64)
	lng, errLng := strconv.ParseFloat(r.URL.Query().Get("longitude"), 64)
	messages := []string{}
	if errLat != nil || lat < -90 || lat > 90 {
		messages = append(messages, "latitude must be a latitude string or number")
	}
	if errLng != nil || lng < -180 || lng > 180 {
		messages = append(messages, "longitude must be a longitude string or number")
	}
	if len(messages) > 0 {
		httpx.ValidationError(w, messages)
		return 0, 0, false
	}
	return lat, lng, true
}

// parsePagination aplica los limites de PaginationDto (limit <= 100).
func parsePagination(r *http.Request) (int32, int32) {
	limit := queryInt32(r, "limit", 100)
	if limit <= 0 || limit > 100 {
		limit = 100
	}
	offset := queryInt32(r, "offset", 0)
	if offset < 0 {
		offset = 0
	}
	return limit, offset
}

func queryInt32(r *http.Request, key string, fallback int32) int32 {
	raw := r.URL.Query().Get(key)
	if raw == "" {
		return fallback
	}
	value, err := strconv.ParseInt(raw, 10, 32)
	if err != nil {
		return fallback
	}
	return int32(value)
}

// splitInt32 parsea el parametro de ruta "1,2,3" (ParseArrayPipe de NestJS).
func splitInt32(raw string) ([]int32, error) {
	parts := strings.Split(raw, ",")
	out := make([]int32, 0, len(parts))
	for _, part := range parts {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}
		value, err := strconv.ParseInt(part, 10, 32)
		if err != nil {
			return nil, err
		}
		out = append(out, int32(value))
	}
	return out, nil
}

// parseDate acepta "YYYY-MM-DD" o un ISO 8601 completo.
func parseDate(raw string) (pgtype.Date, bool) {
	if raw == "" {
		return pgtype.Date{}, false
	}
	if len(raw) >= 10 {
		if parsed, err := time.Parse("2006-01-02", raw[:10]); err == nil {
			return pgtype.Date{Time: parsed, Valid: true}, true
		}
	}
	if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
		return pgtype.Date{Time: parsed, Valid: true}, true
	}
	return pgtype.Date{}, false
}

// notifyOrderNearby envia el aviso a los repartidores cercanos y al dueno de la
// tienda. Se implementa por completo al portar el modulo de notificaciones.
func (a *API) notifyOrderNearby(ctx context.Context, orderID int32, lat, lng float64, data map[string]string) error {
	tokens, err := a.q.ListPushTokensNearby(ctx, store.ListPushTokensNearbyParams{
		Latitude:  strconv.FormatFloat(lat, 'f', -1, 64),
		Longitude: strconv.FormatFloat(lng, 'f', -1, 64),
		Km:        storesNearbyKM,
	})
	if err != nil {
		return err
	}
	valid := make([]string, 0, len(tokens))
	for _, t := range tokens {
		if t != nil && *t != "" {
			valid = append(valid, *t)
		}
	}
	if err := a.push.Send(ctx, valid, data); err != nil {
		return err
	}
	return a.notifyStoreOwner(ctx, orderID, data)
}

// notifyStoreOwner avisa al dueno de la tienda del pedido nuevo
// (NotificationService.notify sobre order.store.user.id).
func (a *API) notifyStoreOwner(ctx context.Context, orderID int32, data map[string]string) error {
	ownerID, err := a.q.GetStoreOwnerIDByOrder(ctx, orderID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		return err
	}
	if ownerID == nil {
		return nil
	}
	tokens, err := a.q.ListPushTokensByUser(ctx, *ownerID)
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

func int32Value(v *int32) int32 {
	if v == nil {
		return 0
	}
	return *v
}
