package api

import (
	"net/http"
	"strconv"

	"appmeals/api/internal/httpx"
	"appmeals/api/internal/store"
)

const notifMessageChat = "3001" // TypesNotification.MESSAGE_CHAT

func (a *API) registerChatRoutes(mux *httpx.Mux) {
	// La consulta por pedido es publica en la version NestJS (sin @Auth).
	mux.Handle(http.MethodGet, "/api/chat/order/{id}", a.chatByOrder)
	mux.Handle(http.MethodPost, "/api/chat", a.chatSend, a.RequireAuth, RequireRole("deliveryman", "client"))
	mux.Handle(http.MethodPatch, "/api/chat", a.chatMarkAllRead, a.RequireAuth, RequireRole("deliveryman", "client"))
}

type chatFromJSON struct {
	ID int32 `json:"id"`
}

type chatMessageJSON struct {
	ID        int32        `json:"id"`
	Message   string       `json:"message"`
	Type      int16        `json:"type"`
	Status    int16        `json:"status"`
	CreatedAt any          `json:"createdAt"`
	From      chatFromJSON `json:"from"`
}

// chatByOrder lista los mensajes de un pedido (mas recientes primero).
func (a *API) chatByOrder(w http.ResponseWriter, r *http.Request) {
	orderID, err := strconv.ParseInt(r.PathValue("id"), 10, 32)
	if err != nil {
		httpx.ValidationError(w, []string{"id must be a number"})
		return
	}
	rows, err := a.q.ListChatsByOrder(r.Context(), int32(orderID))
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	messages := make([]chatMessageJSON, 0, len(rows))
	for _, row := range rows {
		messages = append(messages, chatMessageJSON{
			ID:        row.ID,
			Message:   row.Message,
			Type:      row.Type,
			Status:    row.Status,
			CreatedAt: tsJSON(row.CreatedAt),
			From:      chatFromJSON{ID: row.FromId},
		})
	}
	httpx.OK(w, map[string]any{"messages": messages})
}

type chatSendRequest struct {
	Message string `json:"message"`
	Type    int16  `json:"type"`
	To      struct {
		ID int32 `json:"id"`
	} `json:"to"`
	Order struct {
		ID int32 `json:"id"`
	} `json:"order"`
	Rol string `json:"rol"`
}

// chatSend guarda el mensaje, incrementa el contador de no leidos del pedido
// segun quien escribe y notifica al destinatario.
func (a *API) chatSend(w http.ResponseWriter, r *http.Request) {
	var req chatSendRequest
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{
		minLen("message", req.Message, 1),
		required("rol", req.Rol),
	}...) {
		return
	}
	if len(req.Message) > 1200 {
		httpx.ValidationError(w, []string{"message must be shorter than or equal to 1200 characters"})
		return
	}
	if req.Type <= 0 {
		httpx.ValidationError(w, []string{"type must be a positive number"})
		return
	}
	if req.To.ID == 0 || req.Order.ID == 0 {
		httpx.ValidationError(w, []string{"to and order should not be empty"})
		return
	}

	user := currentUser(r)
	if user.ID == req.To.ID {
		httpx.WriteError(w, httpx.BadRequestMsg(httpx.CodeNone, "The destination user cannot be the same as the sender"))
		return
	}

	ctx := r.Context()
	toID := req.To.ID
	chat, err := a.q.CreateChat(ctx, store.CreateChatParams{
		Message: req.Message,
		Type:    req.Type,
		Status:  1,
		FromId:  user.ID,
		ToId:    &toID,
		OrderId: req.Order.ID,
	})
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	switch req.Rol {
	case "client":
		err = a.q.IncrementOrderNotificationsDeliveryman(ctx, req.Order.ID)
	case "deliveryman":
		err = a.q.IncrementOrderNotificationsClient(ctx, req.Order.ID)
	}
	if err != nil {
		httpx.WriteError(w, err)
		return
	}

	data := map[string]string{
		"type":    notifMessageChat,
		"title":   user.FullName,
		"body":    req.Message,
		"message": req.Message,
		"fromId":  strconv.FormatInt(int64(user.ID), 10),
		"orderId": strconv.FormatInt(int64(req.Order.ID), 10),
	}
	_ = a.notifyUser(ctx, req.To.ID, data)

	httpx.Created(w, map[string]any{
		"id":        chat.ID,
		"message":   chat.Message,
		"type":      chat.Type,
		"status":    chat.Status,
		"createdAt": tsJSON(chat.CreatedAt),
		"fromId":    chat.FromId,
		"toId":      chat.ToId,
		"orderId":   chat.OrderId,
		"from":      userJSON(*user),
		"to":        map[string]any{"id": req.To.ID},
		"order":     map[string]any{"id": req.Order.ID},
	})
}

// chatMarkAllRead pone en cero el contador de no leidos del pedido.
func (a *API) chatMarkAllRead(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Rol   string `json:"rol"`
		Order struct {
			ID int32 `json:"id"`
		} `json:"order"`
	}
	if !decodeJSON(w, r, &req) {
		return
	}
	if invalid(w, []string{required("rol", req.Rol)}...) {
		return
	}
	if req.Order.ID == 0 {
		httpx.ValidationError(w, []string{"order should not be empty"})
		return
	}

	var err error
	switch req.Rol {
	case "client":
		err = a.q.ResetOrderNotificationsClient(r.Context(), req.Order.ID)
	case "deliveryman":
		err = a.q.ResetOrderNotificationsDeliveryman(r.Context(), req.Order.ID)
	}
	if err != nil {
		httpx.WriteError(w, err)
		return
	}
	httpx.OK(w, true)
}
