package main

import (
	"net/http"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func sayHi(c echo.Context) error {
	return c.HTML(http.StatusOK, "Hello")
}

func main() {
	e := echo.New()

	e.Use(middleware.Logger())

	e.GET("/", sayHi)
	e.Logger.Fatal(e.Start(":8080"))
}
