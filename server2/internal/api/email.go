package api

import (
	"net/http"

	"appmeals/api/internal/httpx"
)

func (a *API) registerEmailRoutes(mux *httpx.Mux) {
	mux.Handle(http.MethodPost, "/api/email", a.emailCreate)
}

// emailCreate replica EmailController.create de la version NestJS: envia un
// correo de prueba con datos fijos (a traves de la interfaz Mailer, stub por
// defecto) y responde con el mismo texto.
func (a *API) emailCreate(w http.ResponseWriter, r *http.Request) {
	if err := a.mail.SendRecoveryPassword(r.Context(), "Juan Pablo", "juanpa.desert@gmail.com", "1234"); err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.Created(w, "This action adds a new email")
}
