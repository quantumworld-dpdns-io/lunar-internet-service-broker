package auth

import (
	"testing"

	"github.com/google/uuid"
)

func TestGenerateAndValidateToken(t *testing.T) {
	service := NewAuthService()
	userID := uuid.New()
	email := "test@example.com"
	role := "operator"

	token, err := service.GenerateToken(userID, email, role)
	if err != nil {
		t.Fatalf("Failed to generate token: %v", err)
	}

	claims, err := service.ValidateToken(token)
	if err != nil {
		t.Fatalf("Failed to validate token: %v", err)
	}

	if claims.UserID != userID {
		t.Errorf("Expected user ID %v, got %v", userID, claims.UserID)
	}
	if claims.Email != email {
		t.Errorf("Expected email %s, got %s", email, claims.Email)
	}
	if claims.Role != role {
		t.Errorf("Expected role %s, got %s", role, claims.Role)
	}
}

func TestInvalidToken(t *testing.T) {
	service := NewAuthService()
	_, err := service.ValidateToken("invalid-token")
	if err != ErrInvalidToken {
		t.Errorf("Expected ErrInvalidToken, got %v", err)
	}
}

func TestExpiredToken(t *testing.T) {
	service := &AuthService{
		secret:     []byte("test-secret"),
		expiryTime: -1, // Already expired
	}
	token, _ := service.GenerateToken(uuid.New(), "test@test.com", "admin")
	_, err := service.ValidateToken(token)
	if err != ErrInvalidToken {
		t.Errorf("Expected ErrInvalidToken for expired token, got %v", err)
	}
}
