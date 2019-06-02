package main

import (
	"encoding/json"
	"flag"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"

	"github.com/labstack/echo"
	"github.com/stretchr/testify/assert"
)

func TestMain(m *testing.M) {
	flag.Parse()
	result := m.Run()
	os.Exit(result)
}

var (
	inputJSON = `{"value":2}`
)

func TestGetFibonacci(t *testing.T) {
	// Setup
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/", strings.NewReader(inputJSON))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	req.Header.Set(echo.HeaderAccept, echo.MIMEApplicationJSON)

	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetPath("/fibonacci")

	// Assertions
	if assert.NoError(t, getFibonacci(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)
		var result Result
		json.Unmarshal(rec.Body.Bytes(), &result)
		assert.Equal(t, 3, result.Value, "Result should be 3")
	}
}
