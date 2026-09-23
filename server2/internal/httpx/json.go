package httpx

import (
	"encoding/json"
	"io"
	"net/http"
)

// WriteJSON serializa v como JSON con el status indicado.
func WriteJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	if v == nil {
		return
	}
	if err := json.NewEncoder(w).Encode(v); err != nil {
		// La cabecera ya se envio: solo queda registrar.
		_ = err
	}
}

// OK responde 200 con el cuerpo indicado.
func OK(w http.ResponseWriter, v any) {
	WriteJSON(w, http.StatusOK, v)
}

// Created responde 201 (NestJS usa 201 en los POST).
func Created(w http.ResponseWriter, v any) {
	WriteJSON(w, http.StatusCreated, v)
}

// NoContent responde 204.
func NoContent(w http.ResponseWriter) {
	w.WriteHeader(http.StatusNoContent)
}

// Decode lee el cuerpo JSON en dst. Un cuerpo vacio no es error.
func Decode(r *http.Request, dst any) error {
	defer r.Body.Close()
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		if err == io.EOF {
			return nil
		}
		return err
	}
	return nil
}
