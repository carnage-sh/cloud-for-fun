package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/labstack/echo"
	"github.com/stretchr/testify/assert"
)

func TestHealthZ(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/heathz", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	if healthZ(c) == nil {
		assert.Equal(t, http.StatusOK, rec.Code)
		assert.Equal(t, "OK", rec.Body.String())
	}

}

func TestKEvent(t *testing.T) {
	// Setup
	e := echo.New()
	req := httptest.NewRequest(http.MethodPost, "/", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	if sayHi(c) == nil {
		assert.Equal(t, http.StatusOK, rec.Code)
	}
}
