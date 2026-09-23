package api

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

func (a *API) registerRequestRoutes(mux *httpx.Mux) {
	mux.Handle(http.MethodGet, "/api/manager/request/near", a.requestNear, a.RequireAuth, RequireRole("manager"))
	mux.Handle(http.MethodGet, "/api/manager/request/id/{orderId}", a.requestGet, a.RequireAuth, RequireRole("manager"))
	mux.Handle(http.MethodGet, "/api/manager/request/ordered-at/{orderedAt}", a.requestHistory, a.RequireAuth, RequireRole("manager"))
}

func (a *API) registerEnrollmentRoutes(mux *httpx.Mux) {
	mux.Handle(http.MethodPost, "/api/manager/enrollment", a.enrollmentCreate, a.RequireAuth, RequireRole("client"))
	mux.Handle(http.MethodGet, "/api/manager/enrollment/get-categories", a.enrollmentCategories, a.RequireAuth, RequireRole("client"))
}

func (a *API) registerStoreManagerRoutes(mux *httpx.Mux) {
	mux.Handle(http.MethodGet, "/api/manager/store/companies", a.storeCompanies, a.RequireAuth, RequireRole("manager"))
	mux.Handle(http.MethodGet, "/api/manager/store/products/{companyId}", a.storeProducts, a.RequireAuth, RequireRole("manager"))
	mux.Handle(http.MethodPost, "/api/manager/store/product", a.storeCreateProduct, a.RequireAuth, RequireRole("manager"))
	mux.Handle(http.MethodPatch, "/api/manager/store/product/{id}", a.storeUpdateProduct, a.RequireAuth, RequireRole("manager"))
	mux.Handle(http.MethodGet, "/api/manager/store/hours/{id}", a.storeHours, a.RequireAuth, RequireRole("manager"))
	mux.Handle(http.MethodPatch, "/api/manager/store/hours/{id}", a.storeUpdateHour, a.RequireAuth, RequireRole("manager"))
}

// --- manager/request ---

type requestUserJSON struct {
	ID       int32   `json:"id"`
	FullName string  `json:"fullName"`
	Phone    *string `json:"phone"`
	Image    string  `json:"image"`
}

type requestStoreJSON struct {
	ID       int32                    `json:"id"`
	Name     string                   `json:"name"`
	Address  string                   `json:"address"`
	Contact  string                   `json:"contact"`
	Location locationJSON             `json:"location"`
	Company  petitionStoreCompanyJSON `json:"company"`
}

type requestJSON struct {
	ID                       int32            `json:"id"`
	Note                     string           `json:"note"`
	Address                  string           `json:"address"`
	Status                   int16            `json:"status"`
	Products                 json.RawMessage  `json:"products"`
	DeliveryFee              float64          `json:"deliveryFee"`
	Total                    float64          `json:"total"`
	Payment                  int32            `json:"payment"`
	NotificationsDeliveryman float64          `json:"notificationsDeliveryman"`
	ScoreDeliveryman         *float64         `json:"scoreDeliveryman"`
	CreatedAt                any              `json:"createdAt"`
	Location                 locationJSON     `json:"location"`
	User                     requestUserJSON  `json:"user"`
	Store                    requestStoreJSON `json:"store"`
}

func requestJSONFrom(row store.ListNearRequestsRow) requestJSON {
	return requestJSON{
		ID:                       row.ID,
		Note:                     row.Note,
		Address:                  row.Address,
		Status:                   row.Status,
		Products:                 rawJSON(row.Products),
		DeliveryFee:              row.DeliveryFee,
		Total:                    row.Total,
		Payment:                  row.Payment,
		NotificationsDeliveryman: row.NotificationsDeliveryman,
		ScoreDeliveryman:         row.ScoreDeliveryman,
		CreatedAt:                tsJSON(row.CreatedAt),
		Location:                 newLocation(row.Latitude, row.Longitude),
		User: requestUserJSON{
			ID:       row.UserID,
			FullName: row.UserFullName,
			Phone:    row.UserPhone,
			Image:    row.UserImage,
		},
		Store: requestStoreJSON{
			ID:       row.StoreID,
			Name:     row.StoreName,
			Address:  row.StoreAddress,
			Contact:  row.StoreContact,
			Location: newLocation(row.StoreLatitude, row.StoreLongitude),
			Company:  petitionStoreCompanyJSON{Image: row.CompanyImage},
		},
	}
}

func (a *API) requestNear(w http.ResponseWriter, r *http.Request) {
	user := currentUser(r)
	userID := user.ID
	rows, err := a.q.ListNearRequests(r.Context(), store.ListNearRequestsParams{
		UserId: &userID,
		Status: statusDelivered,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	requests := make([]requestJSON, 0, len(rows))
	for _, row := range rows {
		requests = append(requests, requestJSONFrom(row))
	}
	httpx.OK(w, map[string]any{"requests": requests})
}

func (a *API) requestGet(w http.ResponseWriter, r *http.Request) {
	orderID, ok := a.parseOrderID(w, r)
	if !ok {
		return
	}
	row, err := a.q.GetRequest(r.Context(), orderID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.OK(w, map[string]any{"request": nil})
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"request": requestJSONFrom(store.ListNearRequestsRow(row))})
}

func (a *API) requestHistory(w http.ResponseWriter, r *http.Request) {
	orderedAt, ok := parseDate(r.PathValue("orderedAt"))
	if !ok {
		httpx.ValidationError(w, []string{"orderedAt must be a valid ISO 8601 date string"})
		return
	}
	userID := currentUser(r).ID
	rows, err := a.q.ListRequestHistory(r.Context(), store.ListRequestHistoryParams{
		UserId:    &userID,
		OrderedAt: orderedAt,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	requests := make([]requestJSON, 0, len(rows))
	for _, row := range rows {
		requests = append(requests, requestJSONFrom(store.ListNearRequestsRow(row)))
	}
	httpx.OK(w, map[string]any{"requests": requests})
}

// --- manager/enrollment ---

type enrollmentRequest struct {
	Name       string       `json:"name"`
	Address    string       `json:"address"`
	Image      string       `json:"image"`
	Marker     string       `json:"marker"`
	Contact    string       `json:"contact"`
	Email      string       `json:"email"`
	Location   locationJSON `json:"location"`
	CategoryID int32        `json:"categoryId"`
}

// enrollmentCreate da de alta el comercio completo: empresa, tienda, categoria
// y los siete dias de horario; ademas agrega el rol manager al usuario.
func (a *API) enrollmentCreate(w http.ResponseWriter, r *http.Request) {
	var req enrollmentRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		minLen("name", req.Name, 4),
		minLen("address", req.Address, 4),
		minLen("contact", req.Contact, 10),
		validateLocation(req.Location),
	}...) {
		return
	}
	if !isEmail(req.Email) {
		httpx.ValidationError(w, []string{"email must be an email"})
		return
	}
	if req.CategoryID <= 0 {
		httpx.ValidationError(w, []string{"categoryId must be a positive number"})
		return
	}

	user := currentUser(r)
	if hasRole(user.Roles, "deliveryman") {
		httpx.WriteError(w, httpx.BadRequest(httpx.CodeDeliverymanCannotBeManager))
		return
	}

	ctx := r.Context()
	if _, err := a.q.GetCompanyByNameUpper(ctx, req.Name); err == nil {
		httpx.WriteError(w, httpx.BadRequest(httpx.CodeNameUsed))
		return
	} else if !errors.Is(err, pgx.ErrNoRows) {
		httpx.WriteError(w, err)
		return
	}

	company, err := a.q.CreateCompany(ctx, store.CreateCompanyParams{
		Name:    req.Name,
		Address: req.Address,
		Contact: req.Contact,
		Image:   req.Image,
		Marker:  req.Marker,
		Email:   req.Email,
		Point:   req.Location.X,
		Point_2: req.Location.Y,
		UserId:  &user.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	companyID := company.ID
	storeRow, err := a.q.CreateStore(ctx, store.CreateStoreParams{
		Name:      req.Name,
		Address:   req.Address,
		Contact:   req.Contact,
		Email:     req.Email,
		Point:     req.Location.X,
		Point_2:   req.Location.Y,
		CompanyId: &companyID,
		UserId:    &user.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	if _, err := a.q.CreateCompanyCategory(ctx, store.CreateCompanyCategoryParams{
		CompanyId:  company.ID,
		CategoryId: req.CategoryID,
	}); err != nil {
		httpx.WriteError(w, err)
		return
	}

	storeID := storeRow.ID
	for day := int16(0); day < 7; day++ {
		if _, err := a.q.CreateHoursOperation(ctx, store.CreateHoursOperationParams{
			Day:     day,
			StoreId: &storeID,
		}); err != nil {
			httpx.WriteError(w, err)
			return
		}
	}

	if !hasRole(user.Roles, "manager") {
		if _, err := a.q.AddUserRole(ctx, store.AddUserRoleParams{ID: user.ID, ArrayAppend: "manager"}); err != nil {
			httpx.WriteError(w, err)
			return
		}
	}

	httpx.Created(w, map[string]any{"company": map[string]any{
		"id":        company.ID,
		"name":      company.Name,
		"address":   company.Address,
		"contact":   company.Contact,
		"image":     company.Image,
		"marker":    company.Marker,
		"email":     company.Email,
		"location":  newLocation(company.Latitude, company.Longitude),
		"createdAt": tsJSON(company.CreatedAt),
		"updatedAt": tsJSON(company.UpdatedAt),
		"userId":    company.UserId,
		"user":      userJSON(*user),
	}})
}

func (a *API) enrollmentCategories(w http.ResponseWriter, r *http.Request) {
	categories, err := a.q.ListCategories(r.Context())
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	out := make([]map[string]any, 0, len(categories))
	for _, c := range categories {
		out = append(out, map[string]any{
			"id":        c.ID,
			"name":      c.Name,
			"image":     c.Image,
			"createdAt": tsJSON(c.CreatedAt),
			"updatedAt": tsJSON(c.UpdatedAt),
		})
	}
	httpx.OK(w, map[string]any{"categories": out})
}

// --- manager/store ---

type managerCategoryJSON struct {
	ID        int32  `json:"id"`
	Name      string `json:"name"`
	Image     string `json:"image"`
	CreatedAt any    `json:"createdAt"`
	UpdatedAt any    `json:"updatedAt"`
}

type managerCompanyCategoryJSON struct {
	ID        int32               `json:"id"`
	UpdatedAt any                 `json:"updatedAt"`
	Category  managerCategoryJSON `json:"category"`
}

type managerCompanyJSON struct {
	ID         int32                        `json:"id"`
	Name       string                       `json:"name"`
	Address    string                       `json:"address"`
	Contact    string                       `json:"contact"`
	Image      string                       `json:"image"`
	Marker     string                       `json:"marker"`
	Email      string                       `json:"email"`
	Location   locationJSON                 `json:"location"`
	CreatedAt  any                          `json:"createdAt"`
	UpdatedAt  any                          `json:"updatedAt"`
	Categories []managerCompanyCategoryJSON `json:"categories"`
}

type managerStoreJSON struct {
	ID          int32              `json:"id"`
	Name        string             `json:"name"`
	Address     string             `json:"address"`
	Contact     string             `json:"contact"`
	Email       string             `json:"email"`
	StartupCost float64            `json:"startupCost"`
	CostKm      float64            `json:"costKm"`
	Location    locationJSON       `json:"location"`
	Sales       int32              `json:"sales"`
	CreatedAt   any                `json:"createdAt"`
	UpdatedAt   any                `json:"updatedAt"`
	Company     managerCompanyJSON `json:"company"`
}

// storeCompanies agrupa el join tienda/empresa/categoria en la estructura
// anidada que devolvia TypeORM con relations: { company: { categories: true } }.
func (a *API) storeCompanies(w http.ResponseWriter, r *http.Request) {
	userID := currentUser(r).ID
	rows, err := a.q.ListStoresByManager(r.Context(), &userID)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	stores := make([]managerStoreJSON, 0, len(rows))
	index := make(map[int32]int, len(rows))
	for _, row := range rows {
		idx, ok := index[row.ID]
		if !ok {
			stores = append(stores, managerStoreJSON{
				ID:          row.ID,
				Name:        row.Name,
				Address:     row.Address,
				Contact:     row.Contact,
				Email:       row.Email,
				StartupCost: row.StartupCost,
				CostKm:      row.CostKm,
				Location:    newLocation(row.Latitude, row.Longitude),
				Sales:       row.Sales,
				CreatedAt:   tsJSON(row.CreatedAt),
				UpdatedAt:   tsJSON(row.UpdatedAt),
				Company: managerCompanyJSON{
					ID:         row.CompanyID,
					Name:       row.CompanyName,
					Address:    row.CompanyAddress,
					Contact:    row.CompanyContact,
					Image:      row.CompanyImage,
					Marker:     row.CompanyMarker,
					Email:      row.CompanyEmail,
					Location:   newLocation(row.CompanyLatitude, row.CompanyLongitude),
					CreatedAt:  tsJSON(row.CompanyCreatedAt),
					UpdatedAt:  tsJSON(row.CompanyUpdatedAt),
					Categories: []managerCompanyCategoryJSON{},
				},
			})
			idx = len(stores) - 1
			index[row.ID] = idx
		}
		if row.CompanyCategoryID != nil && row.CategoryID != nil {
			stores[idx].Company.Categories = append(stores[idx].Company.Categories, managerCompanyCategoryJSON{
				ID:        *row.CompanyCategoryID,
				UpdatedAt: tsJSON(row.CompanyCategoryUpdatedAt),
				Category: managerCategoryJSON{
					ID:        *row.CategoryID,
					Name:      stringValue(row.CategoryName),
					Image:     stringValue(row.CategoryImage),
					CreatedAt: tsJSON(row.CategoryCreatedAt),
					UpdatedAt: tsJSON(row.CategoryUpdatedAt),
				},
			})
		}
	}
	httpx.OK(w, map[string]any{"stores": stores})
}

type productJSON struct {
	ID          int32   `json:"id"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Image       string  `json:"image"`
	Type        int32   `json:"type"`
	Price       float64 `json:"price"`
	CreatedAt   any     `json:"createdAt"`
	UpdatedAt   any     `json:"updatedAt"`
	CompanyID   *int32  `json:"companyId"`
}

func productJSONFrom(id int32, name, description, image string, productType int32, price float64, createdAt, updatedAt any, companyID *int32) productJSON {
	return productJSON{
		ID:          id,
		Name:        name,
		Description: description,
		Image:       image,
		Type:        productType,
		Price:       price,
		CreatedAt:   createdAt,
		UpdatedAt:   updatedAt,
		CompanyID:   companyID,
	}
}

func (a *API) storeProducts(w http.ResponseWriter, r *http.Request) {
	companyID, err := strconv.ParseInt(r.PathValue("companyId"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"companyId must be a number"})
		return
	}
	key := int32(companyID)
	rows, err := a.q.ListProductsByCompanyManager(r.Context(), &key)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	products := make([]productJSON, 0, len(rows))
	for _, p := range rows {
		products = append(products, productJSONFrom(p.ID, p.Name, p.Description, p.Image, p.Type, p.Price, tsJSON(p.CreatedAt), tsJSON(p.UpdatedAt), p.CompanyId))
	}
	httpx.OK(w, map[string]any{"products": products})
}

type createProductRequest struct {
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Image       string  `json:"image"`
	Type        int32   `json:"type"`
	Price       float64 `json:"price"`
	Company     struct {
		ID int32 `json:"id"`
	} `json:"company"`
}

func (a *API) storeCreateProduct(w http.ResponseWriter, r *http.Request) {
	var req createProductRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		minLen("name", req.Name, 4),
		minLen("description", req.Description, 10),
	}...) {
		return
	}
	if req.Type < 1 || req.Type > 3 {
		httpx.ValidationError(w, []string{"type must be one of the following values: 1, 2, 3"})
		return
	}
	if req.Price <= 0 {
		httpx.ValidationError(w, []string{"price must be a positive number"})
		return
	}
	if req.Company.ID == 0 {
		httpx.ValidationError(w, []string{"company should not be empty"})
		return
	}

	companyID := req.Company.ID
	product, err := a.q.CreateProduct(r.Context(), store.CreateProductParams{
		Name:        req.Name,
		Description: req.Description,
		Image:       req.Image,
		Type:        req.Type,
		Price:       req.Price,
		CompanyId:   &companyID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, map[string]any{"product": productJSONFrom(
		product.ID, product.Name, product.Description, product.Image,
		product.Type, product.Price, tsJSON(product.CreatedAt), tsJSON(product.UpdatedAt), product.CompanyId,
	)})
}

type updateProductRequest struct {
	Name        *string  `json:"name"`
	Description *string  `json:"description"`
	Image       *string  `json:"image"`
	Type        *int32   `json:"type"`
	Price       *float64 `json:"price"`
	Company     *struct {
		ID int32 `json:"id"`
	} `json:"company"`
}

func (a *API) storeUpdateProduct(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"id must be a number"})
		return
	}
	var req updateProductRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	// UpdateProductDto hereda company de CreateProductDto, pero el servicio lo
	// rechaza explicitamente.
	if req.Company != nil {
		httpx.WriteError(w, httpx.BadRequestMsg(httpx.CodeNone, "property company should not exist"))
		return
	}

	ctx := r.Context()
	current, err := a.q.GetProductByID(ctx, int32(id))
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Product with id: "+strconv.FormatInt(id, 10)+" not found"))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	name := current.Name
	if req.Name != nil {
		if len(*req.Name) < 4 {
			httpx.ValidationError(w, []string{"name must be longer than or equal to 4 characters"})
			return
		}
		name = *req.Name
	}
	description := current.Description
	if req.Description != nil {
		if len(*req.Description) < 10 {
			httpx.ValidationError(w, []string{"description must be longer than or equal to 10 characters"})
			return
		}
		description = *req.Description
	}
	image := current.Image
	if req.Image != nil {
		image = *req.Image
	}
	productType := current.Type
	if req.Type != nil {
		if *req.Type < 1 || *req.Type > 3 {
			httpx.ValidationError(w, []string{"type must be one of the following values: 1, 2, 3"})
			return
		}
		productType = *req.Type
	}
	price := current.Price
	if req.Price != nil {
		if *req.Price <= 0 {
			httpx.ValidationError(w, []string{"price must be a positive number"})
			return
		}
		price = *req.Price
	}

	product, err := a.q.UpdateProduct(ctx, store.UpdateProductParams{
		ID:          int32(id),
		Name:        name,
		Description: description,
		Image:       image,
		Type:        productType,
		Price:       price,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Product with id: "+strconv.FormatInt(id, 10)+" not found"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"product": productJSONFrom(
		product.ID, product.Name, product.Description, product.Image,
		product.Type, product.Price, tsJSON(product.CreatedAt), tsJSON(product.UpdatedAt), product.CompanyId,
	)})
}

func (a *API) storeHours(w http.ResponseWriter, r *http.Request) {
	storeID, err := strconv.ParseInt(r.PathValue("id"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"id must be a number"})
		return
	}
	key := int32(storeID)
	rows, err := a.q.ListHoursByStore(r.Context(), &key)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"hours": hoursJSON(rows)})
}

func (a *API) storeUpdateHour(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"id must be a number"})
		return
	}
	var req struct {
		Open  string `json:"open"`
		Close string `json:"close"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		minLen("open", req.Open, 8),
		minLen("close", req.Close, 8),
	}...) {
		return
	}
	open, okOpen := parseClock(req.Open)
	closing, okClose := parseClock(req.Close)
	if !okOpen || !okClose {
		httpx.ValidationError(w, []string{"open/close must be a valid time string"})
		return
	}

	hour, err := a.q.UpdateHoursOperation(r.Context(), store.UpdateHoursOperationParams{
		ID:    int32(id),
		Open:  open,
		Close: closing,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("HoursOperation with id "+strconv.FormatInt(id, 10)+" is not exist"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"hour": hourJSONFrom(hour)})
}

// --- helpers ---

type hourJSON struct {
	ID       int32  `json:"id"`
	Day      int16  `json:"day"`
	Open     any    `json:"open"`
	Close    any    `json:"close"`
	TimeZone int16  `json:"timeZone"`
	StoreID  *int32 `json:"storeId"`
}

func hourJSONFrom(h store.HoursOperation) hourJSON {
	return hourJSON{
		ID:       h.ID,
		Day:      h.Day,
		Open:     clockJSON(h.Open),
		Close:    clockJSON(h.Close),
		TimeZone: h.TimeZone,
		StoreID:  h.StoreId,
	}
}

func hoursJSON(rows []store.HoursOperation) []hourJSON {
	out := make([]hourJSON, 0, len(rows))
	for _, h := range rows {
		out = append(out, hourJSONFrom(h))
	}
	return out
}

func hasRole(roles []string, role string) bool {
	for _, r := range roles {
		if r == role {
			return true
		}
	}
	return false
}

func stringValue(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

// parseClock convierte "HH:MM[:SS]" al tipo time de PostgreSQL.
func parseClock(raw string) (pgtype.Time, bool) {
	parts := strings.Split(raw, ":")
	if len(parts) < 2 {
		return pgtype.Time{}, false
	}
	hours, err1 := strconv.Atoi(parts[0])
	minutes, err2 := strconv.Atoi(parts[1])
	seconds := 0
	var err3 error
	if len(parts) > 2 {
		seconds, err3 = strconv.Atoi(parts[2])
	}
	if err1 != nil || err2 != nil || err3 != nil {
		return pgtype.Time{}, false
	}
	micro := int64(hours)*3_600_000_000 + int64(minutes)*60_000_000 + int64(seconds)*1_000_000
	return pgtype.Time{Microseconds: micro, Valid: true}, true
}
