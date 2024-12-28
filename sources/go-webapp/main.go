package main

import (
	"bytes"
	"log"
	"fmt"
	"html/template"
	"net/http"
	"os"
)


// Fetch environment variables
var cluster = os.Getenv("CLUSTER")
var image = os.Getenv("IMAGE")
var clusterImagePath = os.Getenv("CLUSTER_IMAGE")
var htmlTemplate = template.Must(template.ParseFiles("templates/index.html"))

func livenessHandler(writer http.ResponseWriter, _ *http.Request) {
	writer.WriteHeader(http.StatusOK)
	fmt.Fprintln(writer, "Container is alive!")
}

func readinessHandler(writer http.ResponseWriter, _ *http.Request) {
	writer.WriteHeader(http.StatusOK)
	fmt.Fprintln(writer, "Application is ready!")
}

func indexHandler(writer http.ResponseWriter, _ *http.Request) {

	apiKey, err := os.ReadFile("/secrets/api_key.secret.example")
	if err != nil {
		log.Fatal("ApiKey must be set")
		os.Exit(1)
	}

    buf := &bytes.Buffer{}
    data := map[string]interface{}{
        "Cluster":  cluster,
        "Image":    image,
        "ApiKey":   apiKey,
        "ClusterImage": "assets/images/" + clusterImagePath,
    }
    err = htmlTemplate.Execute(buf, data)
	if err != nil {
		http.Error(writer, err.Error(), http.StatusInternalServerError)
		return
	}

	buf.WriteTo(writer)
}

func main() {

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Initializing the webserver.
	mux := http.NewServeMux()

	// Serving static files.
	fs := http.FileServer(http.Dir("assets"))
	mux.Handle("/assets/", http.StripPrefix("/assets/", fs))

	mux.HandleFunc("/", indexHandler)
	mux.HandleFunc("/health", livenessHandler) // Endpoint for liveness probe
    mux.HandleFunc("/ready", readinessHandler) // Endpoint for readiness probe

	http.ListenAndServe(":"+port, mux)
}
