// Package auth firma y valida los JWT de la API.
package auth

import (
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// Claims es el payload del token, identico al JwtPayload de la version NestJS.
type Claims struct {
	ID       int32  `json:"id"`
	Email    string `json:"email"`
	IDDevice string `json:"idDevice"`
	jwt.RegisteredClaims
}

// Manager firma y verifica tokens HS256 con el secreto compartido.
type Manager struct {
	secret []byte
}

func NewManager(secret string) *Manager {
	return &Manager{secret: []byte(secret)}
}

// tokenTTL replica el expiresIn: "1y" del JwtModule de NestJS.
const tokenTTL = 365 * 24 * time.Hour

// Sign genera el token de sesion.
func (m *Manager) Sign(id int32, email, idDevice string) (string, error) {
	now := time.Now()
	claims := Claims{
		ID:       id,
		Email:    email,
		IDDevice: idDevice,
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(tokenTTL)),
		},
	}
	token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(m.secret)
	if err != nil {
		return "", fmt.Errorf("sign token: %w", err)
	}
	return token, nil
}

// Parse valida el token y devuelve sus claims.
func (m *Manager) Parse(raw string) (*Claims, error) {
	parsed, err := jwt.ParseWithClaims(raw, &Claims{}, func(t *jwt.Token) (any, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		return m.secret, nil
	})
	if err != nil {
		return nil, fmt.Errorf("parse token: %w", err)
	}
	claims, ok := parsed.Claims.(*Claims)
	if !ok || !parsed.Valid {
		return nil, fmt.Errorf("invalid token")
	}
	return claims, nil
}
