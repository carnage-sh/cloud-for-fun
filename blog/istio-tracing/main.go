package main

import (
	"net/http"
	// "time"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"gopkg.in/go-playground/validator.v9"
	// opentracing "github.com/opentracing/opentracing-go"
	// jaeger "github.com/uber/jaeger-client-go"
	// "github.com/uber/jaeger-client-go/zipkin"
)

var (
	version string
)

type (
	Result struct {
		Value int `json:"value"`
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

// func someFunction() {
// 	parent := opentracing.GlobalTracer().StartSpan("hello")
// 	defer parent.Finish()
// 	child := opentracing.GlobalTracer().StartSpan(
// 		"world", opentracing.ChildOf(parent.Context()))
// 	defer child.Finish()
// }

func main() {
	// zipkinPropagator := zipkin.NewZipkinB3HTTPHeaderPropagator()
	// injector := jaeger.TracerOptions.Injector(opentracing.HTTPHeaders, zipkinPropagator)
	// extractor := jaeger.TracerOptions.Extractor(opentracing.HTTPHeaders, zipkinPropagator)
	// zipkinSharedRPCSpan := jaeger.TracerOptions.ZipkinSharedRPCSpan(true)

	// To get the Jaeger setup, there are a few issues you might want to review:
	// - https://github.com/istio/istio/issues/11340
	// - https://github.com/istio/istio/issues/8965
	// - https://github.com/banzaicloud/istio-operator/issues/118

	// On the othre hand anf for an install, see
	// https://github.com/jaegertracing/jaeger-client-go/blob/master/zipkin/README.md#NewZipkinB3HTTPHeaderPropagator
	// sender, _ := jaeger.NewUDPTransport("jaeger-agent.istio-system:5775", 0)
	// tracer, closer := jaeger.NewTracer(
	// 	"istio-tracing",
	// 	jaeger.NewConstSampler(true),
	// 	jaeger.NewRemoteReporter(
	// 		sender,
	// 		jaeger.ReporterOptions.BufferFlushInterval(1*time.Second)),
	// 	injector,
	// 	extractor,
	// 	zipkinSharedRPCSpan,
	// )
	// defer closer.Close()
	// opentracing.SetGlobalTracer(tracer)

	// see also https://github.com/hb-go/echo-web/blob/master/middleware/opentracing/opentracing.go
	// https://github.com/opentracing/opentracing-go
	// https://opentracing.io/docs/getting-started/
	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Validator = &CustomValidator{validator: validator.New()}
	e.GET("/version", func(c echo.Context) error {
		return c.JSON(http.StatusOK, &echo.Map{"version": version})
	})

	e.POST("/fibonacci", getFibonacci)

	e.Logger.Fatal(e.Start(":8080"))
}

func getFibonacci(c echo.Context) error {
	var values Result
	if err := c.Bind(&values); err != nil {
		return err
	}
	output := &Result{Value: values.Value}
	if values.Value == 2 {
		output = &Result{Value: 3}
	}
	//result := &Result{Value: 1}
	return c.JSON(http.StatusOK, output)
}
