package integrations

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"
)

const googleMapsAPIBaseURL = "https://maps.googleapis.com/maps/api"

// GoogleGeocoder consulta el API REST de Google Places y Geocoding.
type GoogleGeocoder struct {
	apiKey  string
	client  *http.Client
	baseURL string
}

func NewGoogleGeocoder(apiKey string) *GoogleGeocoder {
	return &GoogleGeocoder{
		apiKey:  apiKey,
		client:  http.DefaultClient,
		baseURL: googleMapsAPIBaseURL,
	}
}

type googleAutocompleteResponse struct {
	Status       string `json:"status"`
	ErrorMessage string `json:"error_message"`
	Predictions  []struct {
		Description string `json:"description"`
		PlaceID     string `json:"place_id"`
	} `json:"predictions"`
}

type googleGeocodeResponse struct {
	Status       string `json:"status"`
	ErrorMessage string `json:"error_message"`
	Results      []struct {
		Geometry struct {
			Location struct {
				Lat float64 `json:"lat"`
				Lng float64 `json:"lng"`
			} `json:"location"`
		} `json:"geometry"`
	} `json:"results"`
}

func (g *GoogleGeocoder) Autocomplete(ctx context.Context, place string, latitude, longitude float64) ([]Prediction, error) {
	if g.apiKey == "" {
		return nil, ErrNotConfigured
	}

	query := url.Values{}
	query.Set("input", cleanGoogleInput(place))
	query.Set("location", strconv.FormatFloat(latitude, 'f', -1, 64)+","+strconv.FormatFloat(longitude, 'f', -1, 64))
	query.Set("radius", "90000")
	query.Set("strictbounds", "")
	query.Set("key", g.apiKey)

	var response googleAutocompleteResponse
	if err := g.get(ctx, "/place/autocomplete/json", query, &response); err != nil {
		return nil, err
	}
	if err := googleAPIError(response.Status, response.ErrorMessage); err != nil {
		return nil, err
	}

	predictions := make([]Prediction, 0, len(response.Predictions))
	for _, prediction := range response.Predictions {
		predictions = append(predictions, Prediction{
			Description: prediction.Description,
			PlaceID:     prediction.PlaceID,
		})
	}
	return predictions, nil
}

func (g *GoogleGeocoder) Geocode(ctx context.Context, placeID string) ([]LatLng, error) {
	if g.apiKey == "" {
		return nil, ErrNotConfigured
	}

	query := url.Values{}
	query.Set("place_id", placeID)
	query.Set("key", g.apiKey)

	var response googleGeocodeResponse
	if err := g.get(ctx, "/geocode/json", query, &response); err != nil {
		return nil, err
	}
	if err := googleAPIError(response.Status, response.ErrorMessage); err != nil {
		return nil, err
	}

	locations := make([]LatLng, 0, len(response.Results))
	for _, result := range response.Results {
		locations = append(locations, LatLng{
			Lat: result.Geometry.Location.Lat,
			Lng: result.Geometry.Location.Lng,
		})
	}
	return locations, nil
}

func (g *GoogleGeocoder) get(ctx context.Context, path string, query url.Values, target any) error {
	endpoint := strings.TrimRight(g.baseURL, "/") + path + "?" + query.Encode()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return fmt.Errorf("create Google Maps request: %w", err)
	}

	response, err := g.client.Do(req)
	if err != nil {
		return fmt.Errorf("request Google Maps: %w", err)
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("Google Maps returned HTTP %d", response.StatusCode)
	}
	if err := json.NewDecoder(response.Body).Decode(target); err != nil {
		return fmt.Errorf("decode Google Maps response: %w", err)
	}
	return nil
}

func googleAPIError(status, message string) error {
	if status == "OK" || status == "ZERO_RESULTS" {
		return nil
	}
	if message == "" {
		message = "Google Maps returned status " + status
	}
	return fmt.Errorf("Google Maps: %s", message)
}

func cleanGoogleInput(value string) string {
	value = strings.ToLower(value)
	value = strings.NewReplacer(
		"à", "a", "á", "a", "â", "a", "ã", "a", "ä", "a", "å", "a",
		"è", "e", "é", "e", "ê", "e", "ë", "e",
		"ì", "i", "í", "i", "î", "i", "ï", "i",
		"ñ", "n",
		"ò", "o", "ó", "o", "ô", "o", "õ", "o", "ö", "o",
		"ù", "u", "ú", "u", "û", "u", "ü", "u",
	).Replace(value)
	return strings.Join(strings.Fields(value), " ")
}
