// Package config carga la configuracion desde .env y el entorno.
package config

import (
	"bufio"
	"os"
	"strings"
)

type Config struct {
	Address                 string
	DatabaseURL             string
	JWTSecret               string
	FirebaseCredentialsJSON string
	StripeSecretKey         string
	AccountTransport        string
	GoogleAPIKey            string
}

// Load lee el archivo .env (si existe) y luego el entorno. Las variables ya
// presentes en el entorno tienen prioridad sobre el archivo.
func Load() *Config {
	loadDotEnv(".env")

	return &Config{
		Address:                 env("SERVER_ADDRESS", ":3000"),
		DatabaseURL:             databaseURL(),
		JWTSecret:               envFirst([]string{"JWT_SECRET", "JWT_SECREAT"}, "change-this-secret-in-production"),
		FirebaseCredentialsJSON: env("FIREBASE_CREDENTIAL_JSON", ""),
		StripeSecretKey:         env("STRIPE_SECRET_KEY", ""),
		AccountTransport:        env("ACCOUNT_TRANSPORT", ""),
		GoogleAPIKey:            env("API_KEY_GOOGLE", ""),
	}
}

// databaseURL usa DATABASE_URL y, si no esta definida, la construye a partir de
// las credenciales sueltas. Acepta tanto los nombres DB_* (los del .env de
// server/) como los POSTGRES_* que usa docker compose.
func databaseURL() string {
	if v := os.Getenv("DATABASE_URL"); v != "" {
		return v
	}
	user := envFirst([]string{"DB_USERNAME", "POSTGRES_USER"}, "postgres")
	pass := envFirst([]string{"DB_PASSWORD", "POSTGRES_PASSWORD"}, "")
	host := envFirst([]string{"DB_HOST", "POSTGRES_HOST"}, "localhost")
	port := envFirst([]string{"DB_PORT", "POSTGRES_PORT"}, "5432")
	name := envFirst([]string{"DB_NAME", "POSTGRES_DB"}, "delivery")
	return "postgres://" + user + ":" + pass + "@" + host + ":" + port + "/" + name + "?sslmode=disable"
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func envFirst(keys []string, fallback string) string {
	for _, k := range keys {
		if v := os.Getenv(k); v != "" {
			return v
		}
	}
	return fallback
}

// loadDotEnv implementa un lector minimo de .env:
//
//   - una variable por linea (KEY=VALUE), con # para comentarios;
//   - comillas simples o dobles opcionales alrededor del valor;
//   - expansion de ${VAR} y $VAR usando las variables definidas en el propio
//     archivo o, si no estan, el entorno.
//
// Las variables ya presentes en el entorno no se sobrescriben.
func loadDotEnv(path string) {
	file, err := os.Open(path)
	if err != nil {
		return
	}
	defer file.Close()

	// Primera pasada: recolectar todos los pares para que una variable pueda
	// referenciar otra definida mas abajo en el archivo.
	values := make(map[string]string)
	order := make([]string, 0)
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		key, raw, found := strings.Cut(line, "=")
		if !found {
			continue
		}
		key = strings.TrimSpace(key)
		if key == "" {
			continue
		}
		raw = strings.Trim(strings.TrimSpace(raw), `"'`)
		if _, seen := values[key]; !seen {
			order = append(order, key)
		}
		values[key] = raw
	}

	// Segunda pasada: expandir y publicar en el entorno.
	for _, key := range order {
		if _, exists := os.LookupEnv(key); exists {
			continue
		}
		_ = os.Setenv(key, expandEnv(values[key], values, nil))
	}
}

// expandEnv reemplaza ${VAR} y $VAR por su valor: primero busca en values (el
// propio archivo) y, si no esta, en el entorno. Si la variable no existe la
// reemplaza por vacio. El parametro visited corta las referencias circulares.
func expandEnv(value string, values map[string]string, visited map[string]bool) string {
	if visited == nil {
		visited = make(map[string]bool)
	}

	var out strings.Builder
	for i := 0; i < len(value); {
		if value[i] != '$' {
			out.WriteByte(value[i])
			i++
			continue
		}

		// Forma ${VAR}.
		if i+1 < len(value) && value[i+1] == '{' {
			end := strings.IndexByte(value[i+2:], '}')
			if end < 0 {
				out.WriteByte(value[i])
				i++
				continue
			}
			name := value[i+2 : i+2+end]
			out.WriteString(lookupEnv(name, values, visited))
			i += end + 3
			continue
		}

		// Forma $VAR.
		j := i + 1
		for j < len(value) && isEnvNameByte(value[j]) {
			j++
		}
		if j == i+1 {
			out.WriteByte(value[i])
			i++
			continue
		}
		out.WriteString(lookupEnv(value[i+1:j], values, visited))
		i = j
	}
	return out.String()
}

// lookupEnv resuelve una variable y expande su valor recursivamente. El entorno
// tiene prioridad sobre el archivo, igual que en el resto de Load; si la
// variable no esta en ninguno de los dos se resuelve como vacio.
func lookupEnv(name string, values map[string]string, visited map[string]bool) string {
	if name == "" || visited[name] {
		return ""
	}
	if v := os.Getenv(name); v != "" {
		return v
	}

	raw, ok := values[name]
	if !ok {
		return ""
	}
	visited[name] = true
	defer delete(visited, name)
	return expandEnv(raw, values, visited)
}

func isEnvNameByte(c byte) bool {
	return c == '_' ||
		(c >= 'a' && c <= 'z') ||
		(c >= 'A' && c <= 'Z') ||
		(c >= '0' && c <= '9')
}
