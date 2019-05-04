package main

import (
	"fmt"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"github.com/labstack/gommon/log"
	"net/http"
	"os"
	"time"
)

type messageJSON struct {
	Message  string `json:"message"`
	Datetime string `json:"date"`
	Host     string `json:"hostname"`
}

var count = 0

func sayHi(c echo.Context) error {
	count++
	dt := time.Now()

	m := messageJSON{}
	if err := c.Bind(&m); err != nil {
		return err
	}
	m.Datetime = fmt.Sprint(dt.Format("01-02-2006 15:04:05"))
	m.Host, _ = os.Hostname()
	log.Info(fmt.Sprintf("message: %s, date: %s, host: %s", m.Message, m.Datetime, m.Host))
	return c.JSON(http.StatusOK, m)
}

func healthZ(c echo.Context) error {
	return c.HTML(http.StatusOK, "OK")
}

func main() {
	e := echo.New()
	e.Use(middleware.Logger())

	e.POST("/", sayHi)
	e.GET("/healthz", healthZ)

	e.Logger.Fatal(e.Start(":8080"))
}
