package httpx

import (
	"net/http"
	"strings"
)

// Middleware envuelve un handler.
type Middleware func(http.Handler) http.Handler

// Mux es un envoltorio de http.ServeMux con registro por metodo y middlewares.
type Mux struct {
	mux         *http.ServeMux
	middlewares []Middleware
}

func NewMux(mw ...Middleware) *Mux {
	return &Mux{mux: http.NewServeMux(), middlewares: mw}
}

// Handle registra "METHOD /ruta" aplicando los middlewares propios de la ruta.
// Los patrones usan la sintaxis de Go 1.22 ("/client/order/{orderId}").
func (m *Mux) Handle(method, pattern string, h http.HandlerFunc, mw ...Middleware) {
	var handler http.Handler = h
	for i := len(mw) - 1; i >= 0; i-- {
		handler = mw[i](handler)
	}
	m.mux.Handle(method+" "+pattern, handler)
}

func (m *Mux) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// NestJS/Express no distingue la barra final ("/near/" == "/near"), pero el
	// ServeMux de Go si (404, sin redirect). El cliente Flutter llama a
	// deliveryman/petition/near/ y activate/ con barra final, asi que se
	// normaliza antes de despachar. Ningun patron registrado termina en "/", de
	// modo que quitar una barra sobrante no puede colisionar con un subarbol.
	if p := r.URL.Path; p != "/" && strings.HasSuffix(p, "/") {
		r.URL.Path = strings.TrimSuffix(p, "/")
		r.URL.RawPath = ""
	}

	var h http.Handler = m.mux
	for i := len(m.middlewares) - 1; i >= 0; i-- {
		h = m.middlewares[i](h)
	}
	h.ServeHTTP(w, r)
}
