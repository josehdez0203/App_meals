package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	authroutes "jhc-sistemas.com/app-meals/server/routes"
)

func TestHome(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/home", nil)
	response := httptest.NewRecorder()

	authroutes.NewRouter(nil).ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("se esperaba status %d, se obtuvo %d", http.StatusOK, response.Code)
	}

	if contentType := response.Header().Get("Content-Type"); contentType != "application/json; charset=utf-8" {
		t.Fatalf("se esperaba Content-Type %q, se obtuvo %q", "application/json; charset=utf-8", contentType)
	}

	var body struct {
		Message string `json:"message"`
	}
	if err := json.NewDecoder(response.Body).Decode(&body); err != nil {
		t.Fatalf("se esperaba una respuesta JSON válida: %v", err)
	}

	if body.Message != "soy el servidor" {
		t.Fatalf("se esperaba %q, se obtuvo %q", "soy el servidor", body.Message)
	}
}
