package httpx

import (
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"sync"
	"time"
)

// Recover evita que un panic tumbe el servidor.
func Recover(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if rec := recover(); rec != nil {
				slog.Error("panic recovered", "path", r.URL.Path, "panic", rec)
				writeStatusError(w, http.StatusInternalServerError, "Unexpected error, check server logs")
			}
		}()
		next.ServeHTTP(w, r)
	})
}

// CORS responde con permisos abiertos, equivalente al gateway Socket.IO de la
// version NestJS (origin '*').
func CORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h := w.Header()
		h.Set("Access-Control-Allow-Origin", "*")
		h.Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		h.Set("Access-Control-Allow-Headers", "Authorization, Content-Type")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// statusRecorder guarda el status para el log.
type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (s *statusRecorder) WriteHeader(code int) {
	s.status = code
	s.ResponseWriter.WriteHeader(code)
}

// --- Log de acceso ---
//
// Se escribe directamente a un io.Writer y no a traves de slog porque el
// TextHandler entrecomilla los mensajes que contienen caracteres de control, y
// los codigos ANSI se escaparian como texto en lugar de dar color.
//
// Los colores se desactivan definiendo la variable de entorno NO_COLOR
// (https://no-color.org).

const (
	ansiReset   = "\x1b[0m"
	ansiBold    = "\x1b[1m"
	ansiRed     = "\x1b[31m"
	ansiGreen   = "\x1b[32m"
	ansiYellow  = "\x1b[33m"
	ansiBlue    = "\x1b[34m"
	ansiMagenta = "\x1b[35m"
	ansiCyan    = "\x1b[36m"
	ansiGray    = "\x1b[90m"
)

// accessLogOut es el destino de los logs de acceso; es una variable para que
// las pruebas puedan capturar la salida.
var accessLogOut io.Writer = os.Stdout

// accessLogMu evita que dos peticiones concurrentes entrelacen sus lineas.
var accessLogMu sync.Mutex

func colorsEnabled() bool { return os.Getenv("NO_COLOR") == "" }

// verbColor asigna un color a cada verbo HTTP.
func verbColor(method string) string {
	switch method {
	case http.MethodGet:
		return ansiGreen
	case http.MethodPost:
		return ansiBlue
	case http.MethodPut:
		return ansiYellow
	case http.MethodPatch:
		return ansiMagenta
	case http.MethodDelete:
		return ansiRed
	case http.MethodHead, http.MethodOptions:
		return ansiCyan
	default:
		return ansiGray
	}
}

// statusColor colorea el status por familia (2xx, 3xx, 4xx, 5xx).
func statusColor(status int) string {
	switch {
	case status >= 200 && status < 300:
		return ansiGreen
	case status >= 300 && status < 400:
		return ansiCyan
	case status >= 400 && status < 500:
		return ansiYellow
	case status >= 500:
		return ansiRed
	default:
		return ansiGray
	}
}

// paint aplica el color salvo que NO_COLOR este definida.
func paint(color, s string) string {
	if !colorsEnabled() {
		return s
	}
	return color + s + ansiReset
}

// emit escribe una linea completa sin que se entrelace con otras peticiones.
func emit(out io.Writer, format string, args ...any) {
	accessLogMu.Lock()
	defer accessLogMu.Unlock()
	fmt.Fprintf(out, format, args...)
}

func timestamp() string {
	return time.Now().Format("2006-01-02T15:04:05.000-07:00")
}

// LogRequests registra la entrada y la salida de cada peticion. La salida
// incluye el status HTTP que se devolvio y la duracion; el verbo va coloreado
// segun el metodo.
func LogRequests(next http.Handler) http.Handler {
	return logRequestsTo(accessLogOut)(next)
}

// logRequestsTo permite inyectar el destino del log (usado por las pruebas).
func logRequestsTo(out io.Writer) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
			// El relleno se aplica antes de colorear: los codigos ANSI no
			// ocupan ancho, asi que las rutas quedan alineadas.
			verb := paint(verbColor(r.Method), fmt.Sprintf("%-7s", r.Method))

			emit(out, "%s %s %s %s\n", timestamp(), paint(ansiBold, "-->"), verb, r.URL.Path)

			defer func() {
				status := rec.status
				if p := recover(); p != nil {
					// La respuesta la escribe Recover, que va por fuera.
					status = http.StatusInternalServerError
					logExit(out, verb, r.URL.Path, status, time.Since(start))
					panic(p)
				}
				logExit(out, verb, r.URL.Path, status, time.Since(start))
			}()

			next.ServeHTTP(rec, r)
		})
	}
}

func logExit(out io.Writer, verb, path string, status int, elapsed time.Duration) {
	emit(out, "%s %s %s %s %s %s\n",
		timestamp(),
		paint(ansiBold, "<--"),
		verb,
		path,
		paint(statusColor(status), fmt.Sprintf("%d", status)),
		paint(ansiGray, elapsed.Round(time.Microsecond).String()),
	)
}
