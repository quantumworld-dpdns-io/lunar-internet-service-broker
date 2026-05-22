package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthEndpoint(t *testing.T) {
	router := setupRouter()
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/health", nil)
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", w.Code)
	}

	expected := `{"status":"ok","service":"lunar-broker-gateway"}`
	if w.Body.String() != expected {
		t.Errorf("Expected body %s, got %s", expected, w.Body.String())
	}
}

func setupRouter() *gin.Engine {
	r := gin.Default()
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"service": "lunar-broker-gateway",
		})
	})
	return r
}
