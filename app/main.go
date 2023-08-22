package main

import (
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-xray-sdk-go/awsplugins/ecs"
	"github.com/aws/aws-xray-sdk-go/xray"
)

func init() {
	// conditionally load plugin
	if os.Getenv("ENVIRONMENT") == "production" {
		ecs.Init()
		log.Println("X-Ray initiated")
	}

	xray.Configure(xray.Config{
		ServiceVersion: "1.2.3",
	})
}

func main() {
	port := getPort()

	http.Handle("/", xray.Handler(xray.NewFixedSegmentNamer("MyApp"), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello!"))
	})))

	log.Println("Running on port " + port)
	http.ListenAndServe(":"+port, nil)
}

func getPort() string {
	port := os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}
	return port
}
