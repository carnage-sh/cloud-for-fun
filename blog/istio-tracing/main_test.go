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
	inputJSON = `{"value":3}`
)

func TestAdd(t *testing.T) {
	e := echo.New()

	req := httptest.NewRequest(http.MethodPost, "/fibonacci", strings.NewReader(inputJSON))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	req.Header.Set(echo.HeaderAccept, echo.MIMEApplicationJSON)

	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	fibonacci(c)
	assert.Equal(t, http.StatusOK, rec.Code)
	t.Log(rec.Body.String())
	var j input
	json.Unmarshal(rec.Body.Bytes(), &j)
	t.Logf("And now... %v", j)
	assert.Equal(t, int64(3), j.Value, "A should be equal to 3")
}
