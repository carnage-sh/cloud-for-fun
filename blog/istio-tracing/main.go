package main

import (
	"net/http"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"gopkg.in/go-playground/validator.v9"
)

var (
	version string
)

type (
	input struct {
		A int64 `json:"a" validate:"required"`
		B int64 `json:"b" validate:"required"`
	}

	sum struct {
		Result int64 `json:"result" validate:"required"`
	}

	// CustomValidator is a type that allows JSON custom validation
	CustomValidator struct {
		validator *validator.Validate
	}
)

// Validate performs the validation with validator.v9
func (cv *CustomValidator) Validate(i interface{}) error {
	return cv.validator.Struct(i)
}

func main() {
	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Validator = &CustomValidator{validator: validator.New()}
	e.GET("/version", func(c echo.Context) error {
		return c.JSON(http.StatusOK, &echo.Map{"version": version})
	})

	e.POST("/add", func(c echo.Context) error {
		var values input
		if err := c.Bind(&values); err != nil {
			return err
		}
		if err := c.Validate(values); err != nil {
			return err
		}

		result := &sum{Result: values.A + values.B}
		return c.JSON(http.StatusOK, result)
	})

	e.POST("/sum", func(c echo.Context) error {
		result := &sum{Result: int64(100)}
		return c.JSON(http.StatusOK, result)
	})

	e.Logger.Fatal(e.Start(":8080"))
}
