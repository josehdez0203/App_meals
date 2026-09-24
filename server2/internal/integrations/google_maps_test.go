package integrations

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
)

func newGoogleTestClient(handler http.Handler) *http.Client {
	return &http.Client{Transport: roundTripFunc(func(req *http.Request) (*http.Response, error) {
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, req)
		return recorder.Result(), nil
	})}
}

type roundTripFunc func(*http.Request) (*http.Response, error)

func (f roundTripFunc) RoundTrip(req *http.Request) (*http.Response, error) {
	return f(req)
}

func TestGoogleGeocoderAutocomplete(t *testing.T) {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/place/autocomplete/json" {
			t.Fatalf("path = %q", r.URL.Path)
		}
		if got := r.URL.Query().Get("input"); got != "rap" {
			t.Errorf("input = %q, want rap", got)
		}
		if got := r.URL.Query().Get("location"); got != "19.9923452963255,-102.7184222638607" {
			t.Errorf("location = %q", got)
		}
		if got := r.URL.Query().Get("key"); got != "test-key" {
			t.Errorf("key = %q", got)
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"status":"OK","predictions":[{"description":"Rap...","place_id":"abc123"}]}`))
	})

	geocoder := NewGoogleGeocoder("test-key")
	geocoder.baseURL = "http://google.test"
	geocoder.client = newGoogleTestClient(handler)

	got, err := geocoder.Autocomplete(context.Background(), "Ráp", 19.9923452963255, -102.7184222638607)
	if err != nil {
		t.Fatalf("Autocomplete() error = %v", err)
	}
	if len(got) != 1 || got[0].Description != "Rap..." || got[0].PlaceID != "abc123" {
		t.Fatalf("Autocomplete() = %#v", got)
	}
}

func TestGoogleGeocoderGeocode(t *testing.T) {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/geocode/json" {
			t.Fatalf("path = %q", r.URL.Path)
		}
		if got := r.URL.Query().Get("place_id"); got != "abc 123" {
			t.Errorf("place_id = %q", got)
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"status":"OK","results":[{"geometry":{"location":{"lat":19.1,"lng":-102.2}}}]}`))
	})

	geocoder := NewGoogleGeocoder("test-key")
	geocoder.baseURL = "http://google.test"
	geocoder.client = newGoogleTestClient(handler)

	got, err := geocoder.Geocode(context.Background(), "abc 123")
	if err != nil {
		t.Fatalf("Geocode() error = %v", err)
	}
	if len(got) != 1 || got[0].Lat != 19.1 || got[0].Lng != -102.2 {
		t.Fatalf("Geocode() = %#v", got)
	}
}

func TestGoogleGeocoderReturnsEmptyForZeroResults(t *testing.T) {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte(`{"status":"ZERO_RESULTS","predictions":[]}`))
	})

	geocoder := NewGoogleGeocoder("test-key")
	geocoder.baseURL = "http://google.test"
	geocoder.client = newGoogleTestClient(handler)

	got, err := geocoder.Autocomplete(context.Background(), "rap", 19, -102)
	if err != nil {
		t.Fatalf("Autocomplete() error = %v", err)
	}
	if got == nil || len(got) != 0 {
		t.Fatalf("Autocomplete() = %#v, want empty non-nil slice", got)
	}
}

func TestGoogleGeocoderRequiresAPIKey(t *testing.T) {
	geocoder := NewGoogleGeocoder("")
	if _, err := geocoder.Autocomplete(context.Background(), "rap", 19, -102); err != ErrNotConfigured {
		t.Fatalf("Autocomplete() error = %v, want ErrNotConfigured", err)
	}
}

func TestCleanGoogleInput(t *testing.T) {
	if got := cleanGoogleInput("  Rápido   ágil "); got != "rapido agil" {
		t.Fatalf("cleanGoogleInput() = %q", got)
	}
}
