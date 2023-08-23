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
	if os.Getenv("XRAY_ENABLED") == "true" {
		ecs.Init()
		log.Println("X-Ray initiated")
	}

	xray.Configure(xray.Config{
		ServiceVersion: "1.2.3",
	})
}

func main() {
	port := getPort()

	http.Handle("/api/hello", xray.Handler(xray.NewFixedSegmentNamer("MyApp"), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello!"))
	})))

	http.HandleFunc("/health", health)

	log.Println("Running on port " + port)
	http.ListenAndServe(":"+port, nil)
}

func health(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("OK\n"))
}

func getPort() string {
	port := os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}
	return port
}
