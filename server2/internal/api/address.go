package api

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/jackc/pgx/v5"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

func (a *API) registerAddressRoutes(mux *httpx.Mux) {
	mux.Handle(http.MethodPost, "/api/client/address", a.addressCreate, a.RequireAuth)
	mux.Handle(http.MethodGet, "/api/client/address", a.addressList, a.RequireAuth)
	mux.Handle(http.MethodPatch, "/api/client/address/{id}", a.addressUpdate, a.RequireAuth)
	mux.Handle(http.MethodDelete, "/api/client/address/{id}", a.addressDelete, a.RequireAuth)
	mux.Handle(http.MethodGet, "/api/client/address/autocomplete/{place}", a.addressAutocomplete)
	mux.Handle(http.MethodGet, "/api/client/address/geocode/{placeId}", a.addressGeocode)
}

type addressJSON struct {
	ID       int32        `json:"id"`
	Alias    string       `json:"alias"`
	Address  string       `json:"address"`
	Location locationJSON `json:"location"`
}

type createAddressRequest struct {
	Alias    string       `json:"alias"`
	Address  string       `json:"address"`
	Location locationJSON `json:"location"`
}

type updateAddressRequest struct {
	Alias    *string       `json:"alias"`
	Address  *string       `json:"address"`
	Location *locationJSON `json:"location"`
}

func (a *API) addressCreate(w http.ResponseWriter, r *http.Request) {
	var req createAddressRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		minLen("alias", req.Alias, 2),
		minLen("address", req.Address, 3),
		validateLocation(req.Location),
	}...) {
		return
	}

	userID := currentUser(r).ID
	address, err := a.q.CreateAddress(r.Context(), store.CreateAddressParams{
		Alias:   req.Alias,
		Address: req.Address,
		Point:   req.Location.X,
		Point_2: req.Location.Y,
		UserId:  &userID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, map[string]any{"address": addressJSONFrom(address.ID, address.Alias, address.Address, address.Latitude, address.Longitude)})
}

func (a *API) addressList(w http.ResponseWriter, r *http.Request) {
	userID := currentUser(r).ID
	rows, err := a.q.ListAddressesByUser(r.Context(), &userID)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	addresses := make([]addressJSON, 0, len(rows))
	for _, row := range rows {
		addresses = append(addresses, addressJSONFrom(row.ID, row.Alias, row.Address, row.Latitude, row.Longitude))
	}
	httpx.OK(w, map[string]any{"addresses": addresses})
}

func (a *API) addressUpdate(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"id must be a number"})
		return
	}
	var req updateAddressRequest
	if !decodeJSON(w, r, &req) {
		return
	}

	ctx := r.Context()
	current, err := a.q.GetAddressByID(ctx, int32(id))
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Address with id: "+strconv.FormatInt(id, 10)+" not found"))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	alias := current.Alias
	if req.Alias != nil {
		if len(*req.Alias) < 2 {
			httpx.ValidationError(w, []string{"alias must be longer than or equal to 2 characters"})
			return
		}
		alias = *req.Alias
	}
	address := current.Address
	if req.Address != nil {
		if len(*req.Address) < 3 {
			httpx.ValidationError(w, []string{"address must be longer than or equal to 3 characters"})
			return
		}
		address = *req.Address
	}
	location := newLocation(current.Latitude, current.Longitude)
	if req.Location != nil {
		if msg := validateLocation(*req.Location); msg != "" {
			httpx.ValidationError(w, []string{msg})
			return
		}
		location = *req.Location
	}

	updated, err := a.q.UpdateAddress(ctx, store.UpdateAddressParams{
		ID:      int32(id),
		Alias:   alias,
		Address: address,
		Point:   location.X,
		Point_2: location.Y,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.NotFound("Address with id: "+strconv.FormatInt(id, 10)+" not found"))
			return
		}
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"address": addressJSONFrom(updated.ID, updated.Alias, updated.Address, updated.Latitude, updated.Longitude)})
}

func (a *API) addressDelete(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"id must be a number"})
		return
	}
	// softDelete de TypeORM no falla si la fila no existe: siempre responde true.
	if _, err := a.q.SoftDeleteAddress(r.Context(), int32(id)); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, true)
}

func (a *API) addressAutocomplete(w http.ResponseWriter, r *http.Request) {
	lat, lng, ok := a.parseCoordinates(w, r)
	if !ok {
		return
	}
	predictions, err := a.geo.Autocomplete(r.Context(), r.PathValue("place"), lat, lng)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	out := make([]map[string]any, 0, len(predictions))
	for _, p := range predictions {
		out = append(out, map[string]any{"description": p.Description, "place_id": p.PlaceID})
	}
	httpx.OK(w, map[string]any{"predictions": out})
}

func (a *API) addressGeocode(w http.ResponseWriter, r *http.Request) {
	locations, err := a.geo.Geocode(r.Context(), r.PathValue("placeId"))
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	out := make([]locationJSON, 0, len(locations))
	for _, l := range locations {
		out = append(out, newLocation(l.Lat, l.Lng))
	}
	httpx.OK(w, map[string]any{"locations": out})
}

func validateLocation(locationJSON locationJSON) string {
	if locationJSON.X < -90 || locationJSON.X > 90 {
		return "location.x must be a latitude string or number"
	}
	if locationJSON.Y < -180 || locationJSON.Y > 180 {
		return "location.y must be a longitude string or number"
	}
	return ""
}

func addressJSONFrom(id int32, alias, address string, latitude, longitude float64) addressJSON {
	return addressJSON{
		ID:       id,
		Alias:    alias,
		Address:  address,
		Location: newLocation(latitude, longitude),
	}
}
