package api

import (
	"context"
	"errors"
	"math/rand"
	"net/http"
	"strconv"

	"github.com/jackc/pgx/v5"
	"golang.org/x/crypto/bcrypt"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

func (a *API) registerAuthRoutes(mux *httpx.Mux) {
	mux.Handle(http.MethodPost, "/api/auth/google", a.authGoogle)
	mux.Handle(http.MethodPatch, "/api/auth/recover/{email}", a.authRecover)
	mux.Handle(http.MethodPost, "/api/auth/register", a.authRegister)
	mux.Handle(http.MethodPatch, "/api/auth/update", a.authUpdate, a.RequireAuth)
	mux.Handle(http.MethodPatch, "/api/auth/update-passwor", a.authUpdatePassword, a.RequireAuth)
	mux.Handle(http.MethodPost, "/api/auth/login", a.authLogin)
	mux.Handle(http.MethodPatch, "/api/auth/check/{idDevice}", a.authCheck, a.RequireAuth)
	mux.Handle(http.MethodPatch, "/api/auth/update-token-push", a.authUpdateTokenPush, a.RequireAuth)
	mux.Handle(http.MethodDelete, "/api/auth/log-out/{idDevice}", a.authLogout, a.RequireAuth)
}

type registerRequest struct {
	FullName  string  `json:"fullName"`
	Email     string  `json:"email"`
	Phone     *string `json:"phone"`
	Password  string  `json:"password"`
	Image     *string `json:"image"`
	IDDevice  string  `json:"idDevice"`
	TokenPush *string `json:"tokenPush"`
}

type loginRequest struct {
	Email     string  `json:"email"`
	Password  string  `json:"password"`
	IDDevice  string  `json:"idDevice"`
	TokenPush *string `json:"tokenPush"`
}

type googleRequest struct {
	FullName  string  `json:"fullName"`
	Email     string  `json:"email"`
	Image     *string `json:"image"`
	IDDevice  string  `json:"idDevice"`
	TokenPush *string `json:"tokenPush"`
	IDGoogle  string  `json:"idGoogle"`
}

type updateUserRequest struct {
	FullName *string `json:"fullName"`
	Email    *string `json:"email"`
	Phone    *string `json:"phone"`
	Image    *string `json:"image"`
}

type passwordRequest struct {
	Password string `json:"password"`
}

type tokenPushRequest struct {
	TokenPush string `json:"tokenPush"`
	IDDevice  string `json:"idDevice"`
}

func (a *API) authRegister(w http.ResponseWriter, r *http.Request) {
	var req registerRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		minLen("fullName", req.FullName, 4),
		required("email", req.Email),
		minLen("password", req.Password, 6),
	}...) {
		return
	}
	if !isEmail(req.Email) {
		httpx.ValidationError(w, []string{"email must be an email"})
		return
	}
	if !isUUID(req.IDDevice) {
		httpx.ValidationError(w, []string{"idDevice must be a UUID"})
		return
	}

	ctx := r.Context()
	existing, err := a.q.GetUserByEmailOrPhone(ctx, store.GetUserByEmailOrPhoneParams{
		Email: req.Email,
		Phone: req.Phone,
	})
	if err == nil {
		switch {
		case existing.Email == req.Email:
			httpx.WriteError(w, httpx.BadRequest(httpx.CodeEmailUsed))
		case req.Phone != nil && existing.Phone != nil && *existing.Phone == *req.Phone:
			httpx.WriteError(w, httpx.BadRequest(httpx.CodePhoneUsed))
		default:
			httpx.WriteError(w, httpx.BadRequest(httpx.CodeUnknown))
		}
		return
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		httpx.WriteError(w, err)
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), 3)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	image := ""
	if req.Image != nil {
		image = *req.Image
	}

	user, err := a.q.CreateUser(ctx, store.CreateUserParams{
		FullName: req.FullName,
		Email:    req.Email,
		Phone:    req.Phone,
		Password: string(hash),
		Image:    image,
		Roles:    []string{"client"},
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	if err := a.saveSession(ctx, user.ID, req.IDDevice, req.TokenPush); err != nil {
		httpx.WriteError(w, err)
		return
	}

	full, err := a.q.GetUserByID(ctx, user.ID)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	token, err := a.jwt.Sign(full.ID, full.Email, req.IDDevice)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	response := userJSON(full)
	response.Token = token
	httpx.Created(w, map[string]any{"user": response})
}

func (a *API) authLogin(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		required("email", req.Email),
		minLen("password", req.Password, 6),
	}...) {
		return
	}
	if !isUUID(req.IDDevice) {
		httpx.ValidationError(w, []string{"idDevice must be a UUID"})
		return
	}

	ctx := r.Context()
	user, err := a.q.GetUserAuthByEmail(ctx, req.Email)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			httpx.WriteError(w, httpx.UnauthorizedMsg(httpx.CodeNone, "UnauthorizedException"))
			return
		}
		httpx.WriteError(w, err)
		return
	}

	ok := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)) == nil
	if !ok && user.PasswordTemporary != nil {
		ok = bcrypt.CompareHashAndPassword([]byte(*user.PasswordTemporary), []byte(req.Password)) == nil
	}
	if !ok {
		httpx.WriteError(w, httpx.UnauthorizedMsg(httpx.CodeNone, "UnauthorizedException"))
		return
	}

	if err := a.saveSession(ctx, user.ID, req.IDDevice, req.TokenPush); err != nil {
		httpx.WriteError(w, err)
		return
	}

	full, err := a.q.GetUserByID(ctx, user.ID)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	token, err := a.jwt.Sign(full.ID, full.Email, req.IDDevice)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	response := userJSON(full)
	response.Token = token
	println(response.Token)
	httpx.OK(w, response)
}

func (a *API) authGoogle(w http.ResponseWriter, r *http.Request) {
	var req googleRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		minLen("fullName", req.FullName, 4),
		required("email", req.Email),
		minLen("idGoogle", req.IDGoogle, 15),
	}...) {
		return
	}
	if !isEmail(req.Email) {
		httpx.ValidationError(w, []string{"email must be an email"})
		return
	}
	if !isUUID(req.IDDevice) {
		httpx.ValidationError(w, []string{"idDevice must be a UUID"})
		return
	}

	ctx := r.Context()
	affected, err := a.q.UpdateUserGoogleID(ctx, store.UpdateUserGoogleIDParams{
		Email:    req.Email,
		IdGoogle: &req.IDGoogle,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	var userID int32
	if affected > 0 {
		linked, err := a.q.GetUserAuthByEmail(ctx, req.Email)
		if err != nil {
			httpx.WriteError(w, err)
			return
		}
		userID = linked.ID
	} else {
		hash, err := bcrypt.GenerateFromPassword([]byte(strconv.FormatInt(rand.Int63(), 10)), 1)
		if err != nil {
			httpx.WriteError(w, err)
			return
		}
		image := ""
		if req.Image != nil {
			image = *req.Image
		}
		created, err := a.q.CreateUser(ctx, store.CreateUserParams{
			IdGoogle: &req.IDGoogle,
			FullName: req.FullName,
			Email:    req.Email,
			Password: string(hash),
			Image:    image,
			Roles:    []string{"client"},
		})
		if err != nil {
			httpx.WriteError(w, err)
			return
		}
		userID = created.ID
	}

	if err := a.saveSession(ctx, userID, req.IDDevice, req.TokenPush); err != nil {
		httpx.WriteError(w, err)
		return
	}

	full, err := a.q.GetUserByID(ctx, userID)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	token, err := a.jwt.Sign(full.ID, full.Email, req.IDDevice)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	response := userJSON(full)
	response.Token = token
	httpx.Created(w, map[string]any{"user": response})
}

func (a *API) authRecover(w http.ResponseWriter, r *http.Request) {
	email := r.PathValue("email")
	ctx := r.Context()

	temporary := generatePassword()
	hash, err := bcrypt.GenerateFromPassword([]byte(temporary), 3)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	hashed := string(hash)

	affected, err := a.q.SetTemporaryPassword(ctx, store.SetTemporaryPasswordParams{
		Email:             email,
		PasswordTemporary: &hashed,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	if affected == 0 {
		httpx.WriteError(w, httpx.BadRequest(httpx.CodeAccountNotExist))
		return
	}

	user, err := a.q.GetUserNameByEmail(ctx, email)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	if err := a.mail.SendRecoveryPassword(ctx, user.FullName, email, temporary); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"recover": true})
}

func (a *API) authCheck(w http.ResponseWriter, r *http.Request) {
	user := currentUser(r)
	httpx.OK(w, map[string]any{"user": userJSON(*user)})
}

func (a *API) authUpdateTokenPush(w http.ResponseWriter, r *http.Request) {
	var req tokenPushRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		minLen("tokenPush", req.TokenPush, 118),
	}...) {
		return
	}
	if !isUUID(req.IDDevice) {
		httpx.ValidationError(w, []string{"idDevice must be a UUID"})
		return
	}

	user := currentUser(r)
	if _, err := a.q.UpdateSessionTokenPush(r.Context(), store.UpdateSessionTokenPushParams{
		UserId:    user.ID,
		IdDevice:  req.IDDevice,
		TokenPush: &req.TokenPush,
	}); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"updateTokenPush": true})
}

func (a *API) authLogout(w http.ResponseWriter, r *http.Request) {
	user := currentUser(r)
	if err := a.q.DeleteSessionByUserAndDevice(r.Context(), store.DeleteSessionByUserAndDeviceParams{
		UserId:   user.ID,
		IdDevice: r.PathValue("idDevice"),
	}); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"logOut": true})
}

func (a *API) authUpdate(w http.ResponseWriter, r *http.Request) {
	var req updateUserRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	current := currentUser(r)
	ctx := r.Context()

	fullName := current.FullName
	if req.FullName != nil {
		if len(*req.FullName) < 4 {
			httpx.ValidationError(w, []string{"fullName must be longer than or equal to 4 characters"})
			return
		}
		fullName = *req.FullName
	}
	email := current.Email
	if req.Email != nil {
		if !isEmail(*req.Email) {
			httpx.ValidationError(w, []string{"email must be an email"})
			return
		}
		email = *req.Email
	}
	phone := current.Phone
	if req.Phone != nil {
		phone = req.Phone
	}
	image := current.Image
	if req.Image != nil {
		image = *req.Image
	}

	existing, err := a.q.GetUserByEmailOrPhoneExcludingID(ctx, store.GetUserByEmailOrPhoneExcludingIDParams{
		Email: email,
		Phone: phone,
		ID:    current.ID,
	})
	if err == nil {
		switch {
		case existing.Email == email:
			httpx.WriteError(w, httpx.BadRequest(httpx.CodeEmailUsed))
		case phone != nil && existing.Phone != nil && *existing.Phone == *phone:
			httpx.WriteError(w, httpx.BadRequest(httpx.CodePhoneUsed))
		default:
			httpx.WriteError(w, httpx.BadRequest(httpx.CodeUnknown))
		}
		return
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		httpx.WriteError(w, err)
		return
	}

	updated, err := a.q.UpdateUserProfile(ctx, store.UpdateUserProfileParams{
		ID:       current.ID,
		FullName: fullName,
		Email:    email,
		Phone:    phone,
		Image:    image,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"user": userFromProfileRow(updated)})
}

func (a *API) authUpdatePassword(w http.ResponseWriter, r *http.Request) {
	var req passwordRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{minLen("password", req.Password, 6)}...) {
		return
	}

	current := currentUser(r)
	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), 3)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	if _, err := a.q.UpdateUserPassword(r.Context(), store.UpdateUserPasswordParams{
		ID:       current.ID,
		Password: string(hash),
	}); err != nil {
		httpx.WriteError(w, err)
		return
	}
	full, err := a.q.GetUserByID(r.Context(), current.ID)
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, map[string]any{"user": userJSON(full)})
}

func (a *API) saveSession(ctx context.Context, userID int32, idDevice string, tokenPush *string) error {
	if tokenPush != nil && *tokenPush != "" {
		if err := a.q.DeleteSessionsByTokenPush(ctx, tokenPush); err != nil {
			return err
		}
	}
	if err := a.q.DeleteSessionByUserAndDevice(ctx, store.DeleteSessionByUserAndDeviceParams{
		UserId:   userID,
		IdDevice: idDevice,
	}); err != nil {
		return err
	}
	var push *string
	if tokenPush != nil && *tokenPush != "" {
		push = tokenPush
	}
	_, err := a.q.CreateSession(ctx, store.CreateSessionParams{
		UserId:    userID,
		IdDevice:  idDevice,
		TokenPush: push,
	})
	return err
}

func generatePassword() string {
	digits := make([]byte, 6)
	for i := range digits {
		digits[i] = byte('1' + rand.Intn(9))
	}
	return string(digits)
}

func userFromProfileRow(u store.UpdateUserProfileRow) userResponse {
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
