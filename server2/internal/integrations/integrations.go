// Package integrations define las dependencias externas de la API.
//
// En esta migracion se entregan como interfaces con implementaciones stub
// (no-op, con log) para que la API compile y sea sustituible sin acoplarse a
// proveedores concretos. Las implementaciones reales (Firebase Admin, Stripe,
// SMTP/OAuth de Gmail, Socket.IO) se pueden inyectar desde cmd/api.
package integrations

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
)

// ErrNotConfigured indica que la integracion externa no esta configurada.
var ErrNotConfigured = errors.New("integration not configured")

// PushSender envia notificaciones push (Firebase Cloud Messaging).
type PushSender interface {
	Send(ctx context.Context, tokens []string, data map[string]string) error
}

// Mailer envia correos transaccionales.
type Mailer interface {
	SendRecoveryPassword(ctx context.Context, fullName, email, password string) error
}

// GoogleOAuth valida tokens de Google Sign-In.
type GoogleOAuth interface {
	EmailFromIDToken(ctx context.Context, idToken string) (string, error)
}

// PaymentGateway procesa pagos con tarjeta (Stripe).
type PaymentGateway interface {
	// CreateIntent crea el intento de pago y devuelve la respuesta cruda de la
	// pasarela, que se guarda tal cual en payment.response.
	CreateIntent(ctx context.Context, amount float64, currency string, metadata map[string]string) (json.RawMessage, error)
	// Confirm confirma un intento de pago ya autorizado por el cliente.
	Confirm(ctx context.Context, paymentIntentID string) (status string, err error)
}

// Realtime entrega eventos en tiempo real.
//
// La version NestJS usa un gateway Socket.IO (`location-ws`) que autentica por
// JWT en el handshake, une al socket a la sala del repartidor y maneja el evento
// "l" (ubicacion): reenvia el punto a la sala y lo persiste en `session`.
//
// En Go el gateway NO esta implementado: queda como interfaz para inyectar una
// implementacion (por ejemplo con un servidor Socket.IO) desde cmd/api. El stub
// por defecto registra la llamada y no hace nada.
type Realtime interface {
	// SendLocation entrega la ubicacion de un repartidor a un usuario suscrito.
	SendLocation(ctx context.Context, toUserID int32, payload any) error
	// BroadcastLocation emite la ubicacion a una sala (el id del usuario que
	// sigue el pedido). Equivale a server.to(id).emit("l", p).
	BroadcastLocation(ctx context.Context, room string, payload any) error
}

// Prediction es una sugerencia de direccion de Google Places.
type Prediction struct {
	Description string
	PlaceID     string
}

// LatLng es un par latitud/longitud devuelto por el geocoding.
type LatLng struct {
	Lat float64
	Lng float64
}

// Geocoder resuelve autocompletado de direcciones y geocodificacion (Google Maps).
type Geocoder interface {
	Autocomplete(ctx context.Context, place string, latitude, longitude float64) ([]Prediction, error)
	Geocode(ctx context.Context, placeID string) ([]LatLng, error)
}

// --- Implementaciones stub ---

// LogPushSender registra los envios en lugar de llamar a Firebase.
type LogPushSender struct{}

func (LogPushSender) Send(_ context.Context, tokens []string, data map[string]string) error {
	slog.Info("push (stub)", "tokens", len(tokens), "data", data)
	return nil
}

// LogMailer registra los correos en lugar de enviarlos.
type LogMailer struct{}

func (LogMailer) SendRecoveryPassword(_ context.Context, fullName, email, password string) error {
	slog.Info("email (stub) contrasena de recuperacion", "to", fullName, "email", email, "password", password)
	return nil
}

// NoopGoogleOAuth no valida tokens: la verificacion real requiere credenciales.
type NoopGoogleOAuth struct{}

func (NoopGoogleOAuth) EmailFromIDToken(_ context.Context, _ string) (string, error) {
	return "", ErrNotConfigured
}

// NoopPaymentGateway rechaza los cobros hasta configurar Stripe.
type NoopPaymentGateway struct{}

func (NoopPaymentGateway) CreateIntent(_ context.Context, _ float64, _ string, _ map[string]string) (json.RawMessage, error) {
	return nil, ErrNotConfigured
}

func (NoopPaymentGateway) Confirm(_ context.Context, _ string) (string, error) {
	return "", ErrNotConfigured
}

// NoopRealtime descarta los eventos en tiempo real.
type NoopRealtime struct{}

func (NoopRealtime) SendLocation(_ context.Context, _ int32, _ any) error {
	return nil
}

func (NoopRealtime) BroadcastLocation(_ context.Context, room string, _ any) error {
	slog.Info("realtime (stub) broadcast", "room", room)
	return nil
}

// NoopGeocoder devuelve listas vacias: el autocompletado real requiere la API de
// Google Maps. Los endpoints siguen respondiendo con la forma correcta.
type NoopGeocoder struct{}

func (NoopGeocoder) Autocomplete(_ context.Context, place string, _, _ float64) ([]Prediction, error) {
	slog.Info("geocoder (stub) autocomplete", "place", place)
	return []Prediction{}, nil
}

func (NoopGeocoder) Geocode(_ context.Context, placeID string) ([]LatLng, error) {
	slog.Info("geocoder (stub) geocode", "placeId", placeID)
	return []LatLng{}, nil
}
