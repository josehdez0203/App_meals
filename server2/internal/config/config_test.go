package config

import (
	"os"
	"path/filepath"
	"testing"
)

const envFixture = `
# credenciales sueltas
CFGTEST_DB_NAME=jose
CFGTEST_HOST=localhost
CFGTEST_PORT=5432
CFGTEST_USER=postgres
CFGTEST_PASSWORD=123456

# DATABASE_URL referencia variables definidas arriba y abajo en el mismo archivo
CFGTEST_URL=postgres://${CFGTEST_USER}:${CFGTEST_PASSWORD}@${CFGTEST_HOST}:${CFGTEST_PORT}/${CFGTEST_DB_NAME}?sslmode=disable
CFGTEST_PLAIN=$CFGTEST_USER
CFGTEST_MISSING=[${CFGTEST_NOPE}]
CFGTEST_QUOTED="${CFGTEST_USER}"
`

var fixtureKeys = []string{
	"CFGTEST_DB_NAME", "CFGTEST_HOST", "CFGTEST_PORT", "CFGTEST_USER",
	"CFGTEST_PASSWORD", "CFGTEST_URL", "CFGTEST_PLAIN", "CFGTEST_MISSING", "CFGTEST_QUOTED",
}

func writeEnvFile(t *testing.T, content string) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), ".env")
	if err := os.WriteFile(path, []byte(content), 0o600); err != nil {
		t.Fatalf("escribir .env de prueba: %v", err)
	}
	return path
}

func isolateEnv(t *testing.T, keys []string) {
	t.Helper()
	for _, key := range keys {
		_ = os.Unsetenv(key)
	}
	t.Cleanup(func() {
		for _, key := range keys {
			_ = os.Unsetenv(key)
		}
	})
}

func TestLoadDotEnvExpandsReferences(t *testing.T) {
	isolateEnv(t, fixtureKeys)
	loadDotEnv(writeEnvFile(t, envFixture))

	cases := map[string]string{
		"CFGTEST_URL":     "postgres://postgres:123456@localhost:5432/jose?sslmode=disable",
		"CFGTEST_PLAIN":   "postgres",
		"CFGTEST_MISSING": "[]",
		"CFGTEST_QUOTED":  "postgres",
	}
	for key, want := range cases {
		if got := os.Getenv(key); got != want {
			t.Errorf("%s = %q, want %q", key, got, want)
		}
	}
}

func TestLoadDotEnvKeepsEnvironmentPriority(t *testing.T) {
	isolateEnv(t, fixtureKeys)
	t.Setenv("CFGTEST_USER", "otro-usuario")

	loadDotEnv(writeEnvFile(t, envFixture))

	if got := os.Getenv("CFGTEST_USER"); got != "otro-usuario" {
		t.Fatalf("CFGTEST_USER = %q, queria respetar el entorno", got)
	}
	// El valor del archivo que referencia al usuario tambien ve el del entorno.
	if got := os.Getenv("CFGTEST_PLAIN"); got != "otro-usuario" {
		t.Fatalf("CFGTEST_PLAIN = %q, want %q", got, "otro-usuario")
	}
}

func TestLoadDotEnvHandlesCircularReference(t *testing.T) {
	keys := []string{"CFGCYCLE_A", "CFGCYCLE_B"}
	isolateEnv(t, keys)
	loadDotEnv(writeEnvFile(t, "CFGCYCLE_A=${CFGCYCLE_B}\nCFGCYCLE_B=${CFGCYCLE_A}\n"))

	// No debe colgarse; la referencia circular se resuelve como vacio.
	if got := os.Getenv("CFGCYCLE_A"); got != "" {
		t.Fatalf("CFGCYCLE_A = %q, want vacio", got)
	}
}

func TestLoadDotEnvMissingFileIsNoop(t *testing.T) {
	loadDotEnv(filepath.Join(t.TempDir(), "no-existe.env"))
}

func TestDatabaseURLUsesEnvironment(t *testing.T) {
	t.Setenv("DATABASE_URL", "")
	t.Setenv("DB_NAME", "jose")
	t.Setenv("DB_HOST", "localhost")
	t.Setenv("DB_PORT", "5432")
	t.Setenv("DB_USERNAME", "postgres")
	t.Setenv("DB_PASSWORD", "123456")

	want := "postgres://postgres:123456@localhost:5432/jose?sslmode=disable"
	if got := databaseURL(); got != want {
		t.Fatalf("databaseURL() = %q, want %q", got, want)
	}
}

func TestDatabaseURLPrefersExplicitValue(t *testing.T) {
	const explicit = "postgres://u:p@db:5432/otra?sslmode=disable"
	t.Setenv("DATABASE_URL", explicit)

	if got := databaseURL(); got != explicit {
		t.Fatalf("databaseURL() = %q, want %q", got, explicit)
	}
}

func TestDatabaseURLAcceptsPostgresNames(t *testing.T) {
	t.Setenv("DATABASE_URL", "")
	t.Setenv("DB_NAME", "")
	t.Setenv("DB_USERNAME", "")
	t.Setenv("DB_PASSWORD", "")
	t.Setenv("POSTGRES_DB", "delivery")
	t.Setenv("POSTGRES_USER", "postgres")
	t.Setenv("POSTGRES_PASSWORD", "123456")
	t.Setenv("POSTGRES_PORT", "5433")

	got := databaseURL()
	if got != "postgres://postgres:123456@localhost:5433/delivery?sslmode=disable" {
		t.Fatalf("databaseURL() = %q", got)
	}
}
