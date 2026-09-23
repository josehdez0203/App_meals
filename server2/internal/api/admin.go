package api

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/jackc/pgx/v5"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

func (a *API) registerAdminRoutes(mux *httpx.Mux) {
	admin := RequireRole("admin")

	// company
	mux.Handle(http.MethodPost, "/api/admin/company", a.adminCompanyCreate, a.RequireAuth, admin)
	mux.Handle(http.MethodGet, "/api/admin/company", a.adminCompanyList, a.RequireAuth, admin)
	mux.Handle(http.MethodGet, "/api/admin/company/{term}", a.adminCompanyByTerm, a.RequireAuth, admin)
	mux.Handle(http.MethodPatch, "/api/admin/company/{id}", a.adminCompanyUpdate, a.RequireAuth, admin)
	mux.Handle(http.MethodDelete, "/api/admin/company/{id}", a.adminCompanyDelete, a.RequireAuth, admin)

	// store
	mux.Handle(http.MethodPost, "/api/admin/store", a.adminStoreCreate, a.RequireAuth, admin)
	mux.Handle(http.MethodGet, "/api/admin/store/company/{companyId}", a.adminStoreByCompany, a.RequireAuth, admin)
	mux.Handle(http.MethodPatch, "/api/admin/store/{id}", a.adminStoreUpdate, a.RequireAuth, admin)
	mux.Handle(http.MethodDelete, "/api/admin/store/{id}", a.adminStoreDelete, a.RequireAuth, admin)

	// product
	mux.Handle(http.MethodPost, "/api/admin/product", a.adminProductCreate, a.RequireAuth, admin)
	mux.Handle(http.MethodGet, "/api/admin/product/company/{companyId}", a.adminProductByCompany, a.RequireAuth, admin)
	mux.Handle(http.MethodPatch, "/api/admin/product/{id}", a.adminProductUpdate, a.RequireAuth, admin)
	mux.Handle(http.MethodDelete, "/api/admin/product/{id}", a.adminProductDelete, a.RequireAuth, admin)

	// category
	mux.Handle(http.MethodPost, "/api/admin/category", a.adminCategoryCreate, a.RequireAuth, admin)
	mux.Handle(http.MethodGet, "/api/admin/category", a.adminCategoryList, a.RequireAuth, admin)
	mux.Handle(http.MethodPatch, "/api/admin/category/{id}", a.adminCategoryUpdate, a.RequireAuth, admin)

	// company-category
	mux.Handle(http.MethodPost, "/api/admin/company-category", a.adminCompanyCategoryCreate, a.RequireAuth, admin)
	mux.Handle(http.MethodGet, "/api/admin/company-category/company/{companyId}", a.adminCompanyCategoryByCompany, a.RequireAuth, admin)
	mux.Handle(http.MethodDelete, "/api/admin/company-category/{id}", a.adminCompanyCategoryDelete, a.RequireAuth, admin)

	// hours-operation
	mux.Handle(http.MethodPost, "/api/admin/hours-operation", a.adminHoursCreate, a.RequireAuth, admin)
	mux.Handle(http.MethodGet, "/api/admin/hours-operation/store/{id}", a.adminHoursByStore, a.RequireAuth, admin)
	mux.Handle(http.MethodPatch, "/api/admin/hours-operation/{id}", a.adminHoursUpdate, a.RequireAuth, admin)

	// credit
	mux.Handle(http.MethodPost, "/api/admin/credit/top-up-balance", a.adminCreditTopUp, a.RequireAuth, admin)
}

// --- JSON ---

type companyBody struct {
	ID        int32        `json:"id"`
	Name      string       `json:"name"`
	Address   string       `json:"address"`
	Contact   string       `json:"contact"`
	Image     string       `json:"image"`
	Marker    string       `json:"marker"`
	Email     string       `json:"email"`
	Location  locationJSON `json:"location"`
	CreatedAt any          `json:"createdAt"`
	UpdatedAt any          `json:"updatedAt"`
	UserID    *int32       `json:"userId"`
}

func companyBodyFrom(id int32, name, address, contact, image, marker, email string, latitude, longitude float64, createdAt, updatedAt any, userID *int32) companyBody {
	return companyBody{
		ID:        id,
		Name:      name,
		Address:   address,
		Contact:   contact,
		Image:     image,
		Marker:    marker,
		Email:     email,
		Location:  newLocation(latitude, longitude),
		CreatedAt: createdAt,
		UpdatedAt: updatedAt,
		UserID:    userID,
	}
}

type storeBody struct {
	ID          int32         `json:"id"`
	Name        string        `json:"name"`
	Address     string        `json:"address"`
	Contact     string        `json:"contact"`
	Email       string        `json:"email"`
	StartupCost float64       `json:"startupCost"`
	CostKm      float64       `json:"costKm"`
	Location    *locationJSON `json:"location,omitempty"`
	Sales       int32         `json:"sales"`
	CreatedAt   any           `json:"createdAt"`
	UpdatedAt   any           `json:"updatedAt"`
	CompanyID   *int32        `json:"companyId"`
	UserID      *int32        `json:"userId"`
}

type adminCategoryBody struct {
	ID        int32  `json:"id"`
	Name      string `json:"name"`
	Image     string `json:"image"`
	CreatedAt any    `json:"createdAt"`
	UpdatedAt any    `json:"updatedAt"`
}

func adminCategoryBodyFrom(c store.Category) adminCategoryBody {
	return adminCategoryBody{ID: c.ID, Name: c.Name, Image: c.Image, CreatedAt: tsJSON(c.CreatedAt), UpdatedAt: tsJSON(c.UpdatedAt)}
}

type companyCategoryBody struct {
	ID         int32             `json:"id"`
	UpdatedAt  any               `json:"updatedAt"`
	CompanyID  int32             `json:"companyId"`
	CategoryID int32             `json:"categoryId"`
	Category   adminCategoryBody `json:"category"`
}

type creditBody struct {
	ID            int32   `json:"id"`
	Amount        float64 `json:"amount"`
	CreatedAt     any     `json:"createdAt"`
	DeliverymanID *int32  `json:"deliverymanId"`
}

// --- company ---

type companyRequest struct {
	Name     string        `json:"name"`
	Address  string        `json:"address"`
	Image    string        `json:"image"`
	Marker   string        `json:"marker"`
	Contact  string        `json:"contact"`
	Email    string        `json:"email"`
	Location *locationJSON `json:"location"`
}

func (a *API) adminCompanyCreate(w http.ResponseWriter, r *http.Request) {
	var req companyRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	location := locationJSON{}
	if req.Location != nil {
		location = *req.Location
	}
	if invalid(w, []string{
		minLen("name", req.Name, 4),
		minLen("address", req.Address, 4),
		minLen("contact", req.Contact, 10),
		validateLocation(location),
	}...) {
		return
	}
	if !isEmail(req.Email) {
		httpx.ValidationError(w, []string{"email must be an email"})
		return
	}

	company, err := a.q.CreateCompany(r.Context(), store.CreateCompanyParams{
		Name:    req.Name,
		Address: req.Address,
		Contact: req.Contact,
		Image:   req.Image,
		Marker:  req.Marker,
		Email:   req.Email,
		Point:   location.X,
		Point_2: location.Y,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, companyBodyFrom(company.ID, company.Name, company.Address, company.Contact,
		company.Image, company.Marker, company.Email, company.Latitude, company.Longitude,
		tsJSON(company.CreatedAt), tsJSON(company.UpdatedAt), company.UserId))
}

func (a *API) adminCompanyList(w http.ResponseWriter, r *http.Request) {
	limit, offset := adminPagination(r)
	rows, err := a.q.ListCompanies(r.Context(), store.ListCompaniesParams{Limit: limit, Offset: offset})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	companies := make([]companyBody, 0, len(rows))
	for _, c := range rows {
		companies = append(companies, companyBodyFrom(c.ID, c.Name, c.Address, c.Contact,
			c.Image, c.Marker, c.Email, c.Latitude, c.Longitude,
			tsJSON(c.CreatedAt), tsJSON(c.UpdatedAt), c.UserId))
	}
	httpx.OK(w, companies)
}

func (a *API) adminCompanyByTerm(w http.ResponseWriter, r *http.Request) {
	term := r.PathValue("term")
	company, err := a.q.FindCompanyByTerm(r.Context(), term)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Company with term "+term+" is not exist"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, companyBodyFrom(company.ID, company.Name, company.Address, company.Contact,
		company.Image, company.Marker, company.Email, company.Latitude, company.Longitude,
		tsJSON(company.CreatedAt), tsJSON(company.UpdatedAt), company.UserId))
}

func (a *API) adminCompanyUpdate(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	var req companyRequest
	if !decodeJSON(w, r, &req) {
		return
	}

	ctx := r.Context()
	current, err := a.q.GetCompanyByID(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Company with id "+strconv.FormatInt(int64(id), 10)+" is not exist"))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	name, address, contact := current.Name, current.Address, current.Contact
	image, marker, email := current.Image, current.Marker, current.Email
	location := newLocation(current.Latitude, current.Longitude)
	if req.Name != "" {
		name = req.Name
	}
	if req.Address != "" {
		address = req.Address
	}
	if req.Contact != "" {
		contact = req.Contact
	}
	if req.Image != "" {
		image = req.Image
	}
	if req.Marker != "" {
		marker = req.Marker
	}
	if req.Email != "" {
		if !isEmail(req.Email) {
			httpx.ValidationError(w, []string{"email must be an email"})
			return
		}
		email = req.Email
	}
	if req.Location != nil {
		if msg := validateLocation(*req.Location); msg != "" {
			httpx.ValidationError(w, []string{msg})
			return
		}
		location = *req.Location
	}

	company, err := a.q.UpdateCompany(ctx, store.UpdateCompanyParams{
		ID:      id,
		Name:    name,
		Address: address,
		Contact: contact,
		Image:   image,
		Marker:  marker,
		Email:   email,
		Point:   location.X,
		Point_2: location.Y,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Company with id "+strconv.FormatInt(int64(id), 10)+" is not exist"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, companyBodyFrom(company.ID, company.Name, company.Address, company.Contact,
		company.Image, company.Marker, company.Email, company.Latitude, company.Longitude,
		tsJSON(company.CreatedAt), tsJSON(company.UpdatedAt), company.UserId))
}

// adminCompanyDelete: la entidad Company no tiene columna deletedAt, asi que el
// softDelete original no tenia donde escribir. Se hace borrado real.
func (a *API) adminCompanyDelete(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	if _, err := a.q.HardDeleteCompany(r.Context(), id); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, true)
}

// --- store ---

type storeRequest struct {
	Name     string        `json:"name"`
	Address  string        `json:"address"`
	Contact  string        `json:"contact"`
	Email    string        `json:"email"`
	Location *locationJSON `json:"location"`
	Company  *struct {
		ID int32 `json:"id"`
	} `json:"company"`
}

func (a *API) adminStoreCreate(w http.ResponseWriter, r *http.Request) {
	var req storeRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	location := locationJSON{}
	if req.Location != nil {
		location = *req.Location
	}
	if invalid(w, []string{
		minLen("name", req.Name, 4),
		minLen("address", req.Address, 4),
		minLen("contact", req.Contact, 10),
		validateLocation(location),
	}...) {
		return
	}
	if req.Company == nil || req.Company.ID == 0 {
		httpx.ValidationError(w, []string{"company should not be empty"})
		return
	}
	if !isEmail(req.Email) {
		httpx.ValidationError(w, []string{"email must be an email"})
		return
	}

	userID := currentUser(r).ID
	companyID := req.Company.ID
	created, err := a.q.CreateStore(r.Context(), store.CreateStoreParams{
		Name:      req.Name,
		Address:   req.Address,
		Contact:   req.Contact,
		Email:     req.Email,
		Point:     location.X,
		Point_2:   location.Y,
		CompanyId: &companyID,
		UserId:    &userID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	// El servicio original borra location antes de responder.
	httpx.Created(w, storeBody{
		ID: created.ID, Name: created.Name, Address: created.Address, Contact: created.Contact,
		Email: created.Email, StartupCost: created.StartupCost, CostKm: created.CostKm,
		Sales: created.Sales, CreatedAt: tsJSON(created.CreatedAt), UpdatedAt: tsJSON(created.UpdatedAt),
		CompanyID: created.CompanyId, UserID: created.UserId,
	})
}

func (a *API) adminStoreByCompany(w http.ResponseWriter, r *http.Request) {
	companyID, err := strconv.ParseInt(r.PathValue("companyId"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"companyId must be a number"})
		return
	}
	limit, offset := adminPagination(r)
	key := int32(companyID)
	rows, err := a.q.ListStoresByCompany(r.Context(), store.ListStoresByCompanyParams{
		CompanyId: &key, Limit: limit, Offset: offset,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	stores := make([]storeBody, 0, len(rows))
	for _, s := range rows {
		location := newLocation(s.Latitude, s.Longitude)
		stores = append(stores, storeBody{
			ID: s.ID, Name: s.Name, Address: s.Address, Contact: s.Contact, Email: s.Email,
			StartupCost: s.StartupCost, CostKm: s.CostKm, Location: &location, Sales: s.Sales,
			CreatedAt: tsJSON(s.CreatedAt), UpdatedAt: tsJSON(s.UpdatedAt),
			CompanyID: s.CompanyId, UserID: s.UserId,
		})
	}
	httpx.OK(w, stores)
}

func (a *API) adminStoreUpdate(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	var req storeRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if req.Company != nil {
		httpx.WriteError(w, httpx.BadRequestMsg(httpx.CodeNone, "property company should not exist"))
		return
	}

	ctx := r.Context()
	current, err := a.q.GetStoreByID(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Store with id: "+strconv.FormatInt(int64(id), 10)+" not found"))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	name, address, contact, email := current.Name, current.Address, current.Contact, current.Email
	location := newLocation(current.Latitude, current.Longitude)
	if req.Name != "" {
		name = req.Name
	}
	if req.Address != "" {
		address = req.Address
	}
	if req.Contact != "" {
		contact = req.Contact
	}
	if req.Email != "" {
		if !isEmail(req.Email) {
			httpx.ValidationError(w, []string{"email must be an email"})
			return
		}
		email = req.Email
	}
	if req.Location != nil {
		if msg := validateLocation(*req.Location); msg != "" {
			httpx.ValidationError(w, []string{msg})
			return
		}
		location = *req.Location
	}

	updated, err := a.q.UpdateStore(ctx, store.UpdateStoreParams{
		ID: id, Name: name, Address: address, Contact: contact, Email: email,
		Point: location.X, Point_2: location.Y,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Store with id: "+strconv.FormatInt(int64(id), 10)+" not found"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	loc := newLocation(updated.Latitude, updated.Longitude)
	httpx.OK(w, storeBody{
		ID: updated.ID, Name: updated.Name, Address: updated.Address, Contact: updated.Contact,
		Email: updated.Email, StartupCost: updated.StartupCost, CostKm: updated.CostKm,
		Location: &loc, Sales: updated.Sales, CreatedAt: tsJSON(updated.CreatedAt),
		UpdatedAt: tsJSON(updated.UpdatedAt), CompanyID: updated.CompanyId, UserID: updated.UserId,
	})
}

func (a *API) adminStoreDelete(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	if _, err := a.q.SoftDeleteStore(r.Context(), id); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, true)
}

// --- product ---

func (a *API) adminProductCreate(w http.ResponseWriter, r *http.Request) {
	var req createProductRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if !validateProductPayload(w, req.Name, req.Description, req.Type, req.Price) {
		return
	}
	if req.Company.ID == 0 {
		httpx.ValidationError(w, []string{"company should not be empty"})
		return
	}

	companyID := req.Company.ID
	product, err := a.q.CreateProduct(r.Context(), store.CreateProductParams{
		Name: req.Name, Description: req.Description, Image: req.Image,
		Type: req.Type, Price: req.Price, CompanyId: &companyID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, productJSONFrom(product.ID, product.Name, product.Description, product.Image,
		product.Type, product.Price, tsJSON(product.CreatedAt), tsJSON(product.UpdatedAt), product.CompanyId))
}

func (a *API) adminProductByCompany(w http.ResponseWriter, r *http.Request) {
	companyID, err := strconv.ParseInt(r.PathValue("companyId"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"companyId must be a number"})
		return
	}
	limit, offset := adminPagination(r)
	key := int32(companyID)
	rows, err := a.q.ListProductsByCompanyAdmin(r.Context(), store.ListProductsByCompanyAdminParams{
		CompanyId: &key, Limit: limit, Offset: offset,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	products := make([]productJSON, 0, len(rows))
	for _, p := range rows {
		products = append(products, productJSONFrom(p.ID, p.Name, p.Description, p.Image,
			p.Type, p.Price, tsJSON(p.CreatedAt), tsJSON(p.UpdatedAt), p.CompanyId))
	}
	httpx.OK(w, products)
}

func (a *API) adminProductUpdate(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	var req updateProductRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if req.Company != nil {
		httpx.WriteError(w, httpx.BadRequestMsg(httpx.CodeNone, "property company should not exist"))
		return
	}

	ctx := r.Context()
	current, err := a.q.GetProductByID(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Product with id: "+strconv.FormatInt(int64(id), 10)+" not found"))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	name, description, image := current.Name, current.Description, current.Image
	productType, price := current.Type, current.Price
	if req.Name != nil {
		name = *req.Name
	}
	if req.Description != nil {
		description = *req.Description
	}
	if req.Image != nil {
		image = *req.Image
	}
	if req.Type != nil {
		productType = *req.Type
	}
	if req.Price != nil {
		price = *req.Price
	}
	if !validateProductPayload(w, name, description, productType, price) {
		return
	}

	product, err := a.q.UpdateProduct(ctx, store.UpdateProductParams{
		ID: id, Name: name, Description: description, Image: image, Type: productType, Price: price,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Product with id: "+strconv.FormatInt(int64(id), 10)+" not found"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, productJSONFrom(product.ID, product.Name, product.Description, product.Image,
		product.Type, product.Price, tsJSON(product.CreatedAt), tsJSON(product.UpdatedAt), product.CompanyId))
}

func (a *API) adminProductDelete(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	if _, err := a.q.SoftDeleteProduct(r.Context(), id); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, true)
}

// --- category ---

func (a *API) adminCategoryCreate(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Name  string `json:"name"`
		Image string `json:"image"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{minLen("name", req.Name, 7), minLen("image", req.Image, 7)}...) {
		return
	}
	category, err := a.q.CreateCategory(r.Context(), store.CreateCategoryParams{Name: req.Name, Image: req.Image})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, adminCategoryBodyFrom(category))
}

func (a *API) adminCategoryList(w http.ResponseWriter, r *http.Request) {
	limit, offset := adminPagination(r)
	rows, err := a.q.ListCategoriesPaged(r.Context(), store.ListCategoriesPagedParams{Limit: limit, Offset: offset})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	categories := make([]adminCategoryBody, 0, len(rows))
	for _, c := range rows {
		categories = append(categories, adminCategoryBodyFrom(c))
	}
	httpx.OK(w, categories)
}

func (a *API) adminCategoryUpdate(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	var req struct {
		Name  *string `json:"name"`
		Image *string `json:"image"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}

	ctx := r.Context()
	current, err := a.q.GetCategoryByID(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Category with id "+strconv.FormatInt(int64(id), 10)+" is not exist"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	name, image := current.Name, current.Image
	if req.Name != nil {
		if len(*req.Name) < 7 {
			httpx.ValidationError(w, []string{"name must be longer than or equal to 7 characters"})
			return
		}
		name = *req.Name
	}
	if req.Image != nil {
		if len(*req.Image) < 7 {
			httpx.ValidationError(w, []string{"image must be longer than or equal to 7 characters"})
			return
		}
		image = *req.Image
	}

	category, err := a.q.UpdateCategory(ctx, store.UpdateCategoryParams{ID: id, Name: name, Image: image})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Category with id "+strconv.FormatInt(int64(id), 10)+" is not exist"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, adminCategoryBodyFrom(category))
}

// --- company-category ---

type companyCategoryRequest struct {
	Company *struct {
		ID int32 `json:"id"`
	} `json:"company"`
	Category *struct {
		ID int32 `json:"id"`
	} `json:"category"`
}

func (a *API) adminCompanyCategoryCreate(w http.ResponseWriter, r *http.Request) {
	var req companyCategoryRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if req.Company == nil || req.Category == nil || req.Company.ID == 0 || req.Category.ID == 0 {
		httpx.ValidationError(w, []string{"company and category should not be empty"})
		return
	}

	created, err := a.q.CreateCompanyCategory(r.Context(), store.CreateCompanyCategoryParams{
		CompanyId: req.Company.ID, CategoryId: req.Category.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	category, err := a.q.GetCategoryByID(r.Context(), created.CategoryId)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, companyCategoryBody{
		ID: created.ID, UpdatedAt: tsJSON(created.UpdatedAt),
		CompanyID: created.CompanyId, CategoryID: created.CategoryId,
		Category: adminCategoryBodyFrom(category),
	})
}

func (a *API) adminCompanyCategoryByCompany(w http.ResponseWriter, r *http.Request) {
	companyID, err := strconv.ParseInt(r.PathValue("companyId"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"companyId must be a number"})
		return
	}
	limit, offset := adminPagination(r)
	rows, err := a.q.ListCompanyCategoriesByCompany(r.Context(), store.ListCompanyCategoriesByCompanyParams{
		CompanyId: int32(companyID), Limit: limit, Offset: offset,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	out := make([]companyCategoryBody, 0, len(rows))
	for _, row := range rows {
		out = append(out, companyCategoryBody{
			ID: row.ID, UpdatedAt: tsJSON(row.UpdatedAt),
			CompanyID: row.CompanyId, CategoryID: row.CategoryId,
			Category: adminCategoryBody{
				ID: row.CategoryID, Name: row.CategoryName,
				Image:     row.CategoryImage,
				CreatedAt: tsJSON(row.CategoryCreatedAt), UpdatedAt: tsJSON(row.CategoryUpdatedAt),
			},
		})
	}
	httpx.OK(w, out)
}

// adminCompanyCategoryDelete recibe el id por ruta y company/category por body,
// igual que el DELETE original.
func (a *API) adminCompanyCategoryDelete(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	var req companyCategoryRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if req.Company == nil || req.Category == nil {
		httpx.ValidationError(w, []string{"company and category should not be empty"})
		return
	}
	if _, err := a.q.DeleteCompanyCategory(r.Context(), store.DeleteCompanyCategoryParams{
		ID: id, CompanyId: req.Company.ID, CategoryId: req.Category.ID,
	}); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, true)
}

// --- hours-operation ---

func (a *API) adminHoursCreate(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Day   int16  `json:"day"`
		Open  string `json:"open"`
		Close string `json:"close"`
		Store *struct {
			ID int32 `json:"id"`
		} `json:"store"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if req.Day < 0 || req.Day > 6 {
		httpx.ValidationError(w, []string{"day must be one of the following values: 1, 2, 3, 4, 5, 6, 0"})
		return
	}
	if invalid(w, []string{minLen("open", req.Open, 8), minLen("close", req.Close, 8)}...) {
		return
	}
	open, okOpen := parseClock(req.Open)
	closing, okClose := parseClock(req.Close)
	if !okOpen || !okClose {
		httpx.ValidationError(w, []string{"open/close must be a valid time string"})
		return
	}
	if req.Store == nil || req.Store.ID == 0 {
		httpx.ValidationError(w, []string{"store should not be empty"})
		return
	}

	storeID := req.Store.ID
	hour, err := a.q.CreateHoursOperationFull(r.Context(), store.CreateHoursOperationFullParams{
		Day: req.Day, Open: open, Close: closing, StoreId: &storeID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, hourJSONFrom(hour))
}

func (a *API) adminHoursByStore(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	rows, err := a.q.ListHoursByStore(r.Context(), &id)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, hoursJSON(rows))
}

func (a *API) adminHoursUpdate(w http.ResponseWriter, r *http.Request) {
	id, ok := parseIDParam(w, r, "id")
	if !ok {
		return
	}
	var req struct {
		Open  string `json:"open"`
		Close string `json:"close"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{minLen("open", req.Open, 8), minLen("close", req.Close, 8)}...) {
		return
	}
	open, okOpen := parseClock(req.Open)
	closing, okClose := parseClock(req.Close)
	if !okOpen || !okClose {
		httpx.ValidationError(w, []string{"open/close must be a valid time string"})
		return
	}

	hour, err := a.q.UpdateHoursOperation(r.Context(), store.UpdateHoursOperationParams{ID: id, Open: open, Close: closing})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("HoursOperation with id "+strconv.FormatInt(int64(id), 10)+" is not exist"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, hourJSONFrom(hour))
}

// --- credit ---

// adminCreditTopUp recarga el saldo de un repartidor identificado por telefono,
// le crea el registro de balance si no existe y le agrega el rol deliveryman.
func (a *API) adminCreditTopUp(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Amount float64 `json:"amount"`
		Phone  string  `json:"phone"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if req.Amount <= 0 {
		httpx.ValidationError(w, []string{"amount must be a positive number"})
		return
	}
	if invalid(w, []string{minLen("phone", req.Phone, 8)}...) {
		return
	}

	ctx := r.Context()
	deliveryman, err := a.q.GetUserByPhone(ctx, &req.Phone)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.BadRequest(httpx.CodeDeliverymanNotFound))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	if hasRole(deliveryman.Roles, "manager") {
		httpx.WriteError(w, httpx.BadRequest(httpx.CodeDeliverymanCannotBeManager))
		return
	}

	credit, err := a.q.CreateCredit(ctx, store.CreateCreditParams{
		Amount: req.Amount, DeliverymanId: &deliveryman.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	if err := a.q.AddBalanceAmount(ctx, store.AddBalanceAmountParams{
		UserId: deliveryman.ID, Balance: req.Amount,
	}); err != nil {
		httpx.WriteError(w, err)
		return
	}
	if !hasRole(deliveryman.Roles, "deliveryman") {
		if _, err := a.q.AddUserRole(ctx, store.AddUserRoleParams{ID: deliveryman.ID, ArrayAppend: "deliveryman"}); err != nil {
			httpx.WriteError(w, err)
			return
		}
	}

	balance, err := a.q.GetBalanceByUser(ctx, deliveryman.ID)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, map[string]any{
		"balance": balanceJSONFrom(balance),
		"credit": creditBody{
			ID: credit.ID, Amount: credit.Amount, CreatedAt: tsJSON(credit.CreatedAt),
			DeliverymanID: credit.DeliverymanId,
		},
	})
}

// --- helpers ---

// adminPagination usa los valores por defecto de PaginationDto en los servicios
// de admin: limit 10, offset 0.
func adminPagination(r *http.Request) (int32, int32) {
	limit := queryInt32(r, "limit", 10)
	if limit <= 0 || limit > 100 {
		limit = 10
	}
	offset := queryInt32(r, "offset", 0)
	if offset < 0 {
		offset = 0
	}
	return limit, offset
}

func parseIDParam(w http.ResponseWriter, r *http.Request, name string) (int32, bool) {
	value, err := strconv.ParseInt(r.PathValue(name), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{name + " must be a number"})
		return 0, false
	}
	return int32(value), true
}

func validateProductPayload(w http.ResponseWriter, name, description string, productType int32, price float64) bool {
	messages := []string{}
	if msg := minLen("name", name, 4); msg != "" {
		messages = append(messages, msg)
	}
	if msg := minLen("description", description, 10); msg != "" {
		messages = append(messages, msg)
	}
	if productType < 1 || productType > 3 {
		messages = append(messages, "type must be one of the following values: 1, 2, 3")
	}
	if price <= 0 {
		messages = append(messages, "price must be a positive number")
	}
	return !invalid(w, messages...)
}

func stringInt32Value(v *int32) int32 {
	if v == nil {
		return 0
	}
	return *v
}
