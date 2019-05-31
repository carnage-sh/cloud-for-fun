package main

import (
	"encoding/json"
	"flag"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMain(m *testing.M) {
	flag.Parse()
	result := m.Run()
	os.Exit(result)
}

var (
	inputJSON = `{"a":1,"b":2}`
)

func TestAdd(t *testing.T) {
	body := []byte(inputJSON)
	var j *input
	json.Unmarshal(body, &j)
	assert.Equal(t, int64(1), j.A, "A should be equal to 1")
}
