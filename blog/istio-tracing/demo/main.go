package main

import (
	"net/http"

	"github.com/labstack/echo"
)

type (
	User struct {
		Name  string `json:"name" form:"name"`
		Email string `json:"email" form:"email"`
	}
	handler struct {
		db map[string]*User
	}
)

func (h *handler) createUser(c echo.Context) error {
	u := new(User)
	if err := c.Bind(u); err != nil {
		return err
	}
	return c.JSON(http.StatusCreated, u)
}

func (h *handler) getUser(c echo.Context) error {
	email := c.Param("email")
	user := h.db[email]
	if user == nil {
		return echo.NewHTTPError(http.StatusNotFound, "user not found")
	}
	return c.JSON(http.StatusOK, user)
}

func main() {
	e := echo.New()

	e.GET("/version", func(c echo.Context) error {
		return c.JSON(http.StatusOK, &echo.Map{"version": "1"})
	})

	e.Logger.Fatal(e.Start(":8080"))
}
