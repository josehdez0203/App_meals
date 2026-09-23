package api

import (
	"context"

	"appmeals/api/internal/store"
)

// UpdateDeliverymanLocation persiste la ultima ubicacion del repartidor en todas
// sus sesiones.
//
// Es la parte de base de datos del gateway Socket.IO original
// (LocationWsService.updateLocation). El servidor Socket.IO en si no esta
// implementado: ver la interfaz integrations.Realtime.
func (a *API) UpdateDeliverymanLocation(ctx context.Context, userID int32, latitude, longitude float64) error {
	return a.q.UpdateSessionsLocationByUser(ctx, store.UpdateSessionsLocationByUserParams{
		UserId:  userID,
		Point:   latitude,
		Point_2: longitude,
	})
}
